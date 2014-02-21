-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

-- This component measures the time interval between the rising edge of the (internally generated) 1PPS_PIC and the
-- rising edge of a copy of the maser 1PPS.  The counter must be buffered so that it can be easily read by the
-- uP_interface.
-- # $Id: one_PPS_Maser_Chk.vhd,v 1.6 2014/01/31 15:16:36 rlacasse Exp $

entity one_PPS_Maser_Chk is
   port	(
		Grs        			: in std_logic;						--Grs is the general reset.  It holds the logic reset while it is high
		one_PPS_PIC  		: in std_logic; 					--internal 1PPS, high for one C125 clock 
		one_PPS_Maser		: in std_logic;						--1PPS_Maser connects to a signal derived from 1PPS_Maser_p
		C125 	      		: in std_logic; 					--125 MHz clock
		one_PPS_MASER_OFF  	: out std_logic_vector(27 downto 0)	--maser vs local 1PPS offset
   	);
end one_PPS_Maser_Chk;

architecture comportamental of one_PPS_Maser_Chk is
  signal one_PPS_MASER_OFF_register		: std_logic_vector(27 downto 0); -- BUS:=X"000_0000";  		--28 bits register
  signal one_PPS_MASER_counter			: std_logic_vector(27 downto 0);		-- BUS:=X"000_0000";  		--one PPS Maser counter

  signal one_PPS_Maser_Z1     			: std_logic := '0';								--use a few flip-flops to capture the basically asynchronous pulse
  signal one_PPS_Maser_Z2           : std_logic := '0';	
  signal one_PPS_Maser_register			: std_logic := '0';								--this register will be used for detecting the rising edge of the PPS_Maser
  signal one_PPS_Maser_pulse        : std_logic 	:= '0';							-- will be 1 during 1 clock cycle upon the rising edge of one_pps_MASER
  signal one_PPS_Maser_counter_CE   : std_logic 	:= '0';							-- counte enable

begin  

  one_PPS_MASER_OFF <= one_PPS_MASER_OFF_register;
  
	compare: process(C125)
	begin
	
		if C125='1' and C125'event then							-- upon 125MHz clock rising edge
			one_PPS_Maser_Z1 		    <= one_PPS_Maser;     --run this essentially asynchronous signal through 2 flip-flops before using it
			one_PPS_Maser_Z2 		    <= one_PPS_Maser_Z1;
			one_PPS_Maser_register 	<= one_PPS_Maser_Z2;		
			one_PPS_Maser_pulse  		<= one_PPS_Maser_Z2 and not(one_PPS_Maser_register);	-- rising edge detector


			if Grs='1' then												-- Synchronous reset
				one_PPS_MASER_OFF_register        <= X"000_0000";	
				one_PPS_MASER_counter		          <= X"000_0000";				-- reset the counter associated to the PIC oulse
				one_PPS_Maser_Z1 		              <= '0';
				one_PPS_Maser_Z2    		          <= '0';				
				one_PPS_Maser_register	          <= '0';
				one_PPS_Maser_pulse  		          <= '0';
			
			else
			--this is a start stop counter.  Count starts one_PPS_PIC and stops with one_PPS_Maser_pulse
        if one_PPS_Maser_counter_CE = '1' then
  				one_PPS_MASER_counter		<= one_PPS_MASER_counter 	+ '1';						--	counter associated to the one PPS MASER signal
  			end if;
  					
			  if one_PPS_Maser_pulse = '1' then							-- reset the counter associated to the Maser pulse
				  one_PPS_Maser_counter_CE <= '0';
				end if;

			  if one_PPS_PIC='1' then								-- reset the counter associated to the PIC oulse
				 one_PPS_Maser_counter_CE <= '1';
				 one_PPS_MASER_counter    <=  X"000_0000";
			   if one_PPS_Maser_counter_CE = '1' then
				   one_PPS_MASER_OFF_register <= X"FFF_FFFF";   --indicates missing Maser 1PPS with this count
				 else
				   one_PPS_MASER_OFF_register <= one_PPS_MASER_counter;			--put the count in the register
				 end if;
				end if;
			
			end if;	--else
		
		end if;   --C125
		
	end process compare;	
end comportamental;
