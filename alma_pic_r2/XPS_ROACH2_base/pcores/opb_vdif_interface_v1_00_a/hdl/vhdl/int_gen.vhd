-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------
-- This component is used to generate the 1-msec and 48-msec interrupts for the c167 microprocessor on the PIC.
-- Unlike many components in this design, these interrupts should not wait for Grs and Run.  Instead, they should go
-- active as soon as possible.
-- -- # $Id: int_gen.vhd,v 1.4 2014/01/13 15:26:17 asaez Exp $

entity int_gen is
	port(

		   C125     		: in std_logic; 								-- 125 MHz clock
		   
		   TE_in     		: in std_logic; 								-- signal derived from TE_p

		   Reset_te			: in std_logic; 								-- when = 1, forces TE_err = 0
		   
		   TE_pic			: out std_logic;								-- high for one clock

		   TIME1			: out std_logic; 								-- 	1 msec interrupt for c167 microprocessor
		   
		   TIME0			: out std_logic; 								-- 48 msec interrupt for c167 microprocessor

		   TE_err			: out std_logic									-- when = 1 indicates TE error 

	);
end int_gen;


architecture comportamental of int_gen is
constant duty_cycle_TIME1: integer 	:=  62500; 								-- as the amount of clock cycles where the signal will be high: 50% duty cycle
constant duty_cycle_TIME0: integer  	:= 	62500; 							-- as the amount of clock cycles where the signal will be high: 2/3 duty cycle
constant limit_TIME1: integer		:= 124999;								-- (Signal period / clock period) -1, (1e-3/8e-9)-1= 124999
constant limit_TIME0: integer			:= 5999999;								-- (Signal period / clock period) -1, (48e-3/8e-9)-1= 5999999
	

signal TE_in_register: 			std_logic;										-- used for detecting the rising edge
signal TE_rising_edge: 			std_logic;										-- 1 during one clock cycle, it detects a rising edge event
signal internal_TE:  			std_logic;										-- this signal is used for checking the external TE signal
signal TE_rising_edge_delayed:	std_logic;										-- for matching the pipeline

begin

	oneMsec_generation: process(C125)  is
		variable counter_TIME1: integer:= 0 ;
				
		begin

		if C125='1' and C125'event then											-- generates 1msec signal
			if TE_rising_edge='1' or counter_TIME1=limit_TIME1 then
				counter_TIME1 := 0;
			else 
				counter_TIME1 := counter_TIME1 + 1;
			end if;	
			
			if counter_TIME1<duty_cycle_TIME1 then						-- generates the TIME1 signal according to the duty cycle specs
				TIME1 <= '1';
			else
				TIME1 <= '0';
			end if;
				
		end if;
	end process oneMsec_generation;
	

	check_te: process(C125) is
		variable counter_TIME0: integer:= 0 ;
		begin
		if C125='1' and C125'event then

			TE_in_register <= TE_in;											-- update "TE_in_register" value upon the clock rising edge.
			TE_rising_edge_delayed <= TE_rising_edge;
			TE_rising_edge <= TE_in and not(TE_in_register);					-- check for rising edges in TE_in

			if counter_TIME0=limit_TIME0 or TE_rising_edge='1' then
				counter_TIME0:=0;
				TE_pic <=  '1';
				internal_TE <= '1';
			else 
				counter_TIME0:= counter_TIME0 + 1;
				internal_TE <= '0';
				TE_pic <=  '0';
			end if;	
			
			if counter_TIME0 < duty_cycle_TIME0 then						-- generates the timeOne signal according to the duty cycle specs
				TIME0 <= '1';
			else
				TIME0 <= '0';
			end if;
			
			if (TE_rising_edge_delayed xor internal_TE)='1' then				-- check if the external TE signal matches with the one generated internally
				TE_err <= '1'; 
			elsif Reset_te='1' then
				TE_err <= '0';
			end if;		
			
		end if;
	end process check_te;


end comportamental;
