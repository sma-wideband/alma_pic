-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--Library UNISIM;
--use UNISIM.vcomponents.all;

-------------------------------------------------------
-- This component generates required timing signals and monitors internally 
-- generated signals against external references
-- $Id: timing_generator.vhd,v 1.6 2014/04/11 14:03:41 rlacasse Exp $

entity timing_generator is
port(
   
   Grs    				: in std_logic;															-- Grs is the general reset; initialize while = 1; from uP_interface
   
   -- Start counters at the next 1PPS (Grs needs to be zero)
   -- This allows external 1PPS to be monitored when not sending frames
   RunTG    			: in std_logic;                           -- from uP_interface
   RunFm    			: in std_logic;                           -- from uP_interface
   
   C125              : in std_logic;                        -- correlator 125 MHz clock (LVDS input)
   one_PPS_Maser     : in std_logic;                        -- 1 PPS from Maser via distributor (LVDS input)
   one_PPS_GPS       : in std_logic;                        -- 1 PPS from GPS via distributor (LVDS input)
   TE                : in std_logic;                        -- 48 msec Timing Event from QCC (LVDS input)
   
	 -- taken from bits 29 to 0 for HdrInfo to provide initial value for SFRE at 
   -- rising edge of 1PPS after armed by RunTG
   SFRE_Init         : in std_logic_vector (29 downto 0);  -- initial value for SFRE;
   
   FrameSync         : out std_logic; 										  -- high one clock at beginning of frame
   FrameNum          : out std_logic_vector (23 downto 0); 	-- for VDIF frame number
--   epoch             : in  std_logic_vector (29 downto 0);  -- initial value for SFRE       get rid of this duplicate!!!!!!!!!
   SFRE              : out std_logic_vector (29 downto 0); 	-- for VDIF seconds field
   OneMsec_pic       : out std_logic; 											-- 8-ns wide 1-msec pulse for data_interface
   TIME1             : out std_logic; 											-- for c167 1-msec interrupt; drives ZDOK0-A4
   TIME0             : out std_logic; 											-- for c167 48-msec interrupt; drives ZDOK0-D2
   one_PPS_PIC       : out std_logic; 											-- for monitoring internal 1 PPS (LVDS output)
   one_PPS_MASER_OFF : out std_logic_vector(27 downto 0); 	-- maser vs local 1PPS offset
   one_PPS_GPS_OFF   : out std_logic_vector(27 downto 0); 	-- gps vs local 1PPS offset
   
	 -- latched high when internal and external TE are not coincident
   -- cleared to low by reset_te bit = 1 from uP_interface
   TE_Err          		: out std_logic;
   reset_te        		: in  std_logic;														-- high resets TE_Err
   one_PPS_PIC_adv    : out std_logic;		
   nchan              : in std_logic_vector(4 downto 0)    --log base 2 of number of channels
);
end timing_generator;

architecture comportamental of timing_generator is

component bufg
	port(
	i : in std_logic;
	o : out std_logic
	);
end component;

component sfre_gen
	port(
     grs              : in  std_logic;                      -- Grs is the general reset.  It holds the logic reset while it is high  
     RunFm            : in  std_logic;                      -- the rising edge of RunTg tells the logic to start at the next 1PPS
     c125             : in  std_logic;                      -- 125 MHz clock		   
     one_pps_pic_adv  : in  std_logic;                      -- internally generated 1PPS
     epoch        : in  std_logic_vector (29 downto 0);
     sfre             : out std_logic_vector (29 downto 0)  -- 	for VDIF frame		   
   );
end component;

component int_gen
	port(
     C125         : in std_logic;    -- 125 MHz clock 
     TE_in        : in std_logic;    -- signal derived from TE_p
     Reset_te     : in std_logic;    -- when = 1, forces TE_err = 0		   
     TE_pic       : out std_logic;   -- high for one clock
     OneMsec_pic  : out std_logic;   -- high for one clock
     TIME1        : out std_logic;   -- 1 msec interrupt for c167 microprocessor		   
     TIME0        : out std_logic;   -- 48 msec interrupt for c167 microprocessor
     TE_err       : out std_logic    -- when = 1 indicates TE error 

   );
end component;

component frame_gen
  port(
     Grs              : in std_logic;                       -- Grs is the general reset.  It holds the logic reset while it is high   
     RunFm            : in std_logic;                       -- The rising edge of Run tells the logic to start at the next 1PPS   
     nchan            : in std_logic_vector(4 downto 0);    -- nchan has an effect on the frame length
     C125             : in std_logic;                       -- 125 MHz clock
     one_PPS_PIC_Adv  : in std_logic;                       -- From 1PPS_PIC component
     FrameNum         : out std_logic_vector(23 downto 0);  -- For VDIF frame   
     FrameSync        : out std_logic                       -- goes high for one clock at the beginning of each frame
   );
end component;

component one_pps_pic_gen
   port	(   
      Grs              : in std_logic;   -- Grs is the general reset.  It holds the logic reset while it is high
   
      -- Start 1 PPS counter at the next 1PPS (Grs needs to be zero)
      RunTG            : in std_logic;   -- from uP_interface
   
      TE               : in std_logic;   -- TE connects to a signal derived from TE_p
      C125             : in std_logic;   -- 125 MHz clock
      ONE_PPS_PIC      : out std_logic;  -- internal 1PPS, high for one C125 clock 
      ONE_PPS_PIC_Adv  : out std_logic   -- high for one clock exactly one clock before 1PPS_PIC
   );
end component;

component one_PPS_Maser_Chk
   port	(      
		Grs                : in std_logic;                      -- Grs is the general reset.  It holds the logic reset while it is high
		one_PPS_PIC        : in std_logic;                      -- internal 1PPS, high for one C125 clock    
		one_PPS_Maser      : in std_logic;                      -- 1PPS_Maser connects to a signal derived from 1PPS_Maser_p
		C125               : in std_logic;                      -- 125 MHz clock
		one_PPS_MASER_OFF  : out std_logic_vector(27 downto 0)  -- maser vs local 1PPS offset
   	);
end component;	

signal one_pps_pic_sig      : std_logic;
signal one_pps_pic_adv_sig  : std_logic;
signal nchan_sig            : std_logic_vector(4 downto 0);
signal TE_pic_sig           : std_logic;
signal OneMsec_pic_sig      : std_logic;
signal dummy                : std_logic_vector(1 downto 0);


begin

	nchan_sig <= nchan;								
	OneMsec_pic <= OneMsec_pic_sig;
	one_PPS_PIC <= one_pps_pic_sig ;						-- one pps internally generated signal (component one_pps_pic_gen)
	one_PPS_PIC_adv <= one_pps_pic_adv_sig; 				-- to the test points 	
	
  sfre_gen_0: sfre_gen
      port map (
		grs              => Grs,	             -- input, connected to GRS
		RunFm            => RunFm,						-- input, connected to RunTG
		c125             => C125,						-- input, general 125MHz clock
		one_pps_pic_adv  => one_pps_pic_adv_sig,			-- input, one PPS, internally generated
		epoch            => SFRE_init,
		sfre				     => SFRE							-- output, for the VDIF frame
   );	  
	 
	int_gen_0: int_gen
        port map (
			C125        => C125,        -- input, general 125MHz clock
			TE_in       => TE,          -- input, connected to the TE, external TE
			Reset_te    => reset_te,    -- input, connected to the reset_te, forces TE_err = 0
			TE_pic      => TE_pic_sig,  -- output, derived TE; free-runs or syncs to external TE if available, high for one clock
			OneMsec_pic => OneMsec_pic_sig,  --high one clock
			TIME1       => TIME1,          -- output, 48 msec interrupt for c167 microprocessor, connected to TIME0
			TIME0       => TIME0,         -- output, 1 msec interrupt for c167 microprocessor, connected to TIME1
			TE_err      => TE_Err       -- output,when = 1 indicates TE error, connected to TE_Err
    );
	
	frame_gen_0: frame_gen
        port map (
			Grs              => Grs,                  -- input, connected to GRS
			RunFm            => RunFm ,                -- input, connected to RunTG
			nchan            => nchan_sig,            -- input, h
			C125             => C125,                 -- input, general 125MHz clock
			ONE_PPS_PIC_Adv  => one_pps_pic_adv_sig,  -- input, from 1PPS_PIC component 
			FrameNum         => FrameNum,             -- output, std_logic_vector (23 downto 0), for VDIF frame number
			FrameSync        => FrameSync             -- output, connected to the FrameSync
    );	
	
	one_pps_pic_gen_0: one_pps_pic_gen
        port map (
			Grs              => Grs,                 -- input, connected to GRS
			RunTG            => RunTG,               -- input, connected to RunTG
			TE               => TE,                  -- input, connected to the TE, external TE
			C125             => C125,                -- input, general 125MHz clock
			ONE_PPS_PIC      => one_pps_pic_sig,     -- output, internal 1PPS, high for one C125 clock 
			ONE_PPS_PIC_Adv  => one_pps_pic_adv_sig  -- output, high for one clock exactly one clock before 1PPS_PIC
    );		
	
	one_PPS_Maser_Chk_0: one_PPS_Maser_Chk			
        port map (
      Grs                => Grs,               -- input, connected to GRS
      one_PPS_PIC        => one_pps_pic_sig,   -- input, internal 1PPS, high for one C125 clock
      one_PPS_Maser      => one_PPS_Maser,     -- input, 1PPS_Maser connects to a signal derived from 1PPS_Maser
      C125               => C125,              -- input, general 125MHz clock
      one_PPS_MASER_OFF  => one_PPS_MASER_OFF  -- output, Maser vs local 1PPS offset
    );
		 
	one_PPS_Maser_Chk_1: one_PPS_Maser_Chk			
        port map (
      Grs                => Grs,             -- input, connected to GRS
      one_PPS_PIC        => one_pps_pic_sig, -- input, internal 1PPS, high for one C125 clock 
      one_PPS_Maser      => one_PPS_GPS,     -- input, 1PPS_GPS connects to a signal derived from 1PPS_GPS
      C125               => C125,            -- input, general 125MHz clock
      one_PPS_MASER_OFF  => one_PPS_GPS_OFF  -- output, GPS vs local 1PPS offset
         );		 

end comportamental;
