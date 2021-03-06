-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------
-- This component is used to generate seconds from reference epoch field in the VDIF frame.  It receives an initial 
-- value from the uP_interface and then free-runs based on the C125 clock.
-- # $Id: sfre_gen.vhd,v 1.5 2014/04/03 15:53:51 rlacasse Exp $

entity sfre_gen is
	port(

		   grs     				: in std_logic; 								-- Grs is the general reset.  It holds the logic reset while it is high
		   
		   RunFm     			: in std_logic; 								-- the rising edge of RunFm tells the logic to start at the next 1PPS

		   c125					: in std_logic; 								-- 125 MHz clock
		   
		   one_pps_pic_adv		: in std_logic;									-- internally generated 1PPS
		   
		   epoch				: in std_logic_vector (29 downto 0); 			-- 	Initial value from the up_interface

		   sfre					: out std_logic_vector (29 downto 0) 			-- 	for VDIF frame
		   
	);
end sfre_gen;

architecture comportamental of sfre_gen is
signal init_req: std_logic:= '0';												-- This signal is used to request initialization of the SFRE
signal RunFm_Z1: std_logic:= '0';												-- This signal is used to positive edge detect RunFm
signal one_pps_counter: std_logic_vector(29 downto 0):= "00" & X"000_0000"; 			-- 30 bits counter
signal epoch_register: std_logic_vector(29 downto 0):= "00" & X"000_0000"; 			  -- 30 bits register for storing the epoch value, initial value is 0x0000000

begin

	sfre <= one_pps_counter;
	
	process(C125)
	begin

	if C125='1' and C125'event then										-- all the events happens upon the clock rising edge
		epoch_register <= epoch;												-- load epoch register with the epoch input value
		RunFm_Z1 <= RunFm;                              -- generate RunFm delayed by 1 clock

		if grs='1' or RunFm = '0' then 									-- grs=1 => general reset, RunFm=0, stop this module
			one_pps_counter <= "00" & X"000_0000";				-- reset the one pps counter
			init_req <= '0';													    -- reset the "init_req" signal
		else	
		  if RunFm ='1' AND RunFm_Z1 = '0' then 
			  init_req <= '1' ;									          -- request initialization at the next 1PPS
			end if;
			
		  if init_req = '1' AND one_pps_pic_adv = '1' then												
				one_pps_counter <= epoch_register;								
				init_req <= '0';
		  else 
		    if one_pps_pic_adv = '1' then
				  one_pps_counter <= one_pps_counter + '1';		-- increment one unit the one_pps_counter variable (upon one_pps_pic_adv is '1')
				end if;
		  end if;
		end if;	
	end if;
	
	end process;																-- end main process
	
end comportamental;
