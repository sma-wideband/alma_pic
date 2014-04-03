-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------
-- This component is used to generate a frame sync pulse and a frame count for the VDIF format, based on the 
-- 1PPS_PIC, Run (from uP_interface), nchan (from uP_interface).  Frame length varies with the number of channels formatted; 
-- # $Id: frame_gen.vhd,v 1.6 2014/01/10 17:28:14 asaez Exp $

entity frame_gen is
port(

   Grs     		 	: in std_logic;									-- Grs is the general reset.  It holds the logic reset while it is high
   
   RunFm     		: in std_logic;									-- The rising edge of RunFm tells the logic to start at the next 1PPS
   
   nchan    		: in std_logic_vector(4 downto 0);				-- nchan has an effect on the frame length

   C125     		: in std_logic; 								-- 125 MHz clock

   one_PPS_PIC_Adv	: in std_logic; 								-- From 1PPS_PIC component

   FrameNum 		: out std_logic_vector(23 downto 0); 			-- For VDIF frame
   
   FrameSync		: out std_logic 								-- goes high for one clock at the beginning of each frame
);
end frame_gen;

-- Number of IF channels | Micro-seconds | clock cycles |
-- 32                       |   8 |                 1000 |
-- 16                       |  16 |                 2000 |
--  8                       |  32 |                 4000 |
--  4                       |  64 |                 8000 |
--  2                       |  80 |                10000 |
--  1                       | 160 |                20000 |


architecture comportamental of frame_gen is
signal FrameNum_register	: std_logic_vector(23 downto 0); 	-- BUS:=X"00_0000";  		-- 24 bits counter
signal RunFm_Z1_sig       : std_logic ; 	-- for detecting rising edge
signal stopped_state      : std_logic := '1'; --initial state and also go to it if RunFM goes low
signal startReq_state     : std_logic := '0'; --state after RunFM goes high and before PPS_PIC goes high
signal running_state      : std_logic := '0'; --the running state

begin

  FrameNum <= FrameNum_register;
  
	process(C125,Grs,nchan)
	variable 	timer_limit: integer;
	variable 	timer: integer;
	
	begin
		case nchan is									-- set clock divisor according to the "nchan" value
			when "00101" => timer_limit :=  1000;		-- nchan 5 => number of IF Channels/frame =32, frame/sec = 125000
			when "00100" => timer_limit :=  2000;		-- nchan 4 => number of IF Channels/frame =16, frame/sec =  62500
			when "00011" => timer_limit :=  4000;		-- nchan 3 => number of IF Channels/frame =8, frame/sec  =  31250
			when "00010" => timer_limit :=  8000;		-- nchan 2 => number of IF Channels/frame =4, frame/sec  =  15625
			when "00001" => timer_limit := 10000;		-- nchan 1 => number of IF Channels/frame =2, frame/sec  =  12500
			when "00000" => timer_limit := 20000;		-- nchan 0 => number of IF Channels/frame =1, frame/sec  =   6250
			when others   => timer_limit :=    10;		-- for testing purposes
		end case;
		
		if Grs='1' then									-- Asynchronous reset
			FrameNum_register 	<= X"00_0000";
			FrameSync			      <= '0';
			timer				        := 0;
      stopped_state       <= '1';
      startReq_state      <= '0';
      running_state       <= '0';
		
		elsif c125='1' and c125'event then				-- Actions which happens synchronously.
			
			RunFm_Z1_sig <= RunFm;
			
			-- FrameSync generator
			if running_state = '1' then
			  if timer = timer_limit - 1 then
				  timer := 0;
				  FrameSync <= '1';
				  FrameNum_register <= FrameNum_register + '1';
			  else 
				  timer := timer + 1;
				  FrameSync <= '0';
			  end if;
      end if;
      			
			if RunFm = '1' AND runFm_Z1_sig ='0' then
        stopped_state       <= '0';
        startReq_state      <= '1';
        running_state       <= '0';			
			end if;
			
			
			if startReq_state = '1' AND one_PPS_PIC_Adv ='1' then			
				FrameNum_register 	<= X"00_0000";
				FrameSync			<= '1';  --high for the frame 0
				timer				:= 0;			
        stopped_state       <= '0';
        startReq_state      <= '0';
        running_state       <= '1';							
			end if;
		end if;											-- End of actions which happens synchronously.
	end process;	
end comportamental;
