-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

-------------------------------------------------------
-- This component generates required timing signals and monitors internally 
-- generated signals against external references
-- $Id: timing_generator.vhd,v 1.10 2014/08/07 21:18:37 asaez Exp $

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
   one_PPS_TE_OFF    : out std_logic_vector(27 downto 0); 	-- TE vs local 1PPS offset, measured at seconds 0, 6, ...
   
	 -- latched high when internal and external TE are not coincident
   -- cleared to low by reset_te bit = 1 from uP_interface
   TE_Err          		: out std_logic;
   reset_te        		: in  std_logic;														-- high resets TE_Err
   one_PPS_PIC_adv    : out std_logic;		
   nchan              : in std_logic_vector(4 downto 0);    --log base 2 of number of channels
   samp_PPS_Ctr       : out std_logic_vector(27 downto 0);  --the 1PPS counter sampled at the TE rising edge   
   tgtp0              : out std_logic;  --general purpose test points
   tgtp1              : out std_logic;
   tgtp2              : out std_logic         
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
     TE_err       : out std_logic;   -- when = 1 indicates TE error 
     igtp0        : out std_logic;
     igtp1        : out std_logic;
     igtp2        : out std_logic

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
      ONE_PPS_PIC_Adv  : out std_logic;  -- high for one clock exactly one clock before 1PPS_PIC
      samp_PPS_Ctr     : out std_logic_vector(27 downto 0)  --the 1PPS counter sampled at the TE rising edge         
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
signal TE_input_sig         : std_logic;
signal TE_input_sig_z1      : std_logic;
signal OneMsec_pic_sig      : std_logic;
signal samp_PPS_Ctr_sig     : std_logic_vector(27 downto 0);
signal dummy                : std_logic_vector(1 downto 0);
signal tgtp0_sig            : std_logic;
signal tgtp1_sig            : std_logic;
signal tgtp2_sig            : std_logic;
signal test_counter	    : std_logic_vector(7 downto 0);
signal every6seconds        : std_logic;
signal every6seconds_Z1     : std_logic;
signal one_PPS_TE_OFF_sig   : std_logic_vector(27 downto 0):=X"000_0000"; 
signal TE_OFF_counter_sig   : std_logic_vector(27 downto 0):=X"000_0000"; 

begin

	nchan_sig <= nchan;								
	OneMsec_pic <= OneMsec_pic_sig;
	one_PPS_PIC <= one_pps_pic_sig ;						-- one pps internally generated signal (component one_pps_pic_gen)
	one_PPS_PIC_adv <= one_pps_pic_adv_sig; 				-- to the test points 	
  samp_PPS_Ctr <= samp_PPS_Ctr_sig;
  one_PPS_TE_OFF <= one_PPS_TE_OFF_sig;
	
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
			TE_err      => TE_Err,       -- output,when = 1 indicates TE error, connected to TE_Err
			igtp0       => tgtp0_sig,
			igtp1       => tgtp0_sig,
			igtp2       => tgtp0_sig
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
			ONE_PPS_PIC_Adv  => one_pps_pic_adv_sig, -- output, high for one clock exactly one clock before 1PPS_PIC
			samp_PPS_Ctr     => samp_PPS_Ctr_sig
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




FDCE_1 : FDCE
port map (
Q => every6seconds_Z1, 	-- Data output
C => C125, 		-- Clock input
CE => '1', 		-- Clock enable input
CLR => '0', 		-- Asynchronous clear input
D => every6seconds 	-- Data input
);

TE_input_sig <= TE;

FDCE_2 : FDCE
port map (
Q => TE_input_sig_z1, 	-- Data output
C => C125, 		-- Clock input
CE => '1', 		-- Clock enable input
CLR => '0', 		-- Asynchronous clear input
D => TE_input_sig 	-- Data input
);



process(C125) is
	begin
	if rising_edge(C125) then
		if TE_input_sig ='1' and TE_input_sig_z1='0' then
			TE_OFF_counter_sig <= X"000_0000";
		else
			TE_OFF_counter_sig <= TE_OFF_counter_sig + '1';
		end if;
	end if;
end process;


process(one_pps_pic_sig,C125) is
        begin
	if rising_edge(C125) then
		if one_pps_pic_sig='1' then
			test_counter <= test_counter + '1';
		end if;
		if test_counter=x"06" or RunTG='0' then
			test_counter <= x"00";
		end if;
		if test_counter=X"00" then
			every6seconds <='1';
		else
			every6seconds <='0';
		end if;
	end if; 
end process;

process(C125) is
	begin
	if rising_edge(C125) then
		if every6seconds='1' and every6seconds_Z1='0' then
			one_PPS_TE_OFF_sig <= TE_OFF_counter_sig;
		end if;
	end if;
end process;




end comportamental;
