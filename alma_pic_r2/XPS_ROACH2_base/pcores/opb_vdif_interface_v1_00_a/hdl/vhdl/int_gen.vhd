-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
-------------------------------------------------------
-- This component is used to generate the 1-msec and 48-msec interrupts for the c167 microprocessor on the PIC.
-- Unlike many components in this design, these interrupts should not wait for Grs and Run.  Instead, they should go
-- active as soon as possible.
-- -- # $Id: int_gen.vhd,v 1.9 2014/06/11 19:36:46 rlacasse Exp $

--modified 2014-4-7 by rlacasse to that a TE error would be identifed for both an early and late TE pulse.

entity int_gen is
	port(

		   C125     		: in std_logic; 								-- 125 MHz clock
		   
		   TE_in     		: in std_logic; 								-- signal derived from TE_p

		   Reset_te			: in std_logic; 								-- when = 1, forces TE_err = 0
		   
		   TE_pic			  : out std_logic;								-- high for one clock every 48 msec
		   
		   OneMsec_pic  : out std_logic;								-- high for one clock every 1 msec

		   TIME1			  : out std_logic; 								-- 	1 msec interrupt for c167 microprocessor
		   
		   TIME0			  : out std_logic; 								-- 48 msec interrupt for c167 microprocessor

		   TE_err			  : out std_logic;								-- when = 1 indicates TE error 

       igtp0        : out std_logic;                -- general purpose test points
       igtp1        : out std_logic;
       igtp2        : out std_logic		   

	);
end int_gen;


architecture comportamental of int_gen is
--for systhesis
constant duty_cycle_TIME1: integer 	:=  62500; 								-- as the amount of clock cycles where the signal will be high: 50% duty cycle
constant duty_cycle_TIME0: integer  	:= 	62500; 							-- as the amount of clock cycles where the signal will be high: 2/3 duty cycle
constant limit_TIME1: integer		:= 124999;								-- (Signal period / clock period) -1, (1e-3/8e-9)-1= 124999
constant limit_TIME0: integer			:= 5999999;								-- (Signal period / clock period) -1, (48e-3/8e-9)-1= 5999999
--for simulation
--constant duty_cycle_TIME1: integer 	:=  14; 								-- as the amount of clock cycles where the signal will be high: 50% duty cycle
--constant duty_cycle_TIME0: integer  	:= 	14; 							-- as the amount of clock cycles where the signal will be high: 2/3 duty cycle
--constant limit_TIME1: integer		:= 27;								-- (Signal period / clock period) -1, (1e-3/8e-9)-1= 124999
--constant limit_TIME0: integer			:= 27;								-- (Signal period / clock period) -1, (48e-3/8e-9)-1= 5999999
	

signal TE_err_sig:        std_logic;                      --for making TE_err available at test point
signal TE_in_register: 			std_logic;										-- used for detecting the rising edge
signal TE_rising_edge: 			std_logic;										-- 1 during one clock cycle, it detects a rising edge event
signal internal_TE:  			std_logic;										-- this signal is used for checking the external TE signal
signal TE_rising_edge_delayed:	std_logic;										-- for matching the pipeline
signal counter_TIME0_sig: std_logic_vector (23 downto 0);      --to be able to see counter_TIME0 i simulation
signal igtp0_sig:         std_logic;
signal igtp1_sig:         std_logic;
signal igtp2_sig:         std_logic;
signal no_te:		  std_logic;

begin
  igtp0     <= igtp0_sig;
  igtp0_sig <= TE_rising_edge;
  igtp2     <= igtp2_sig;
  igtp2_sig <= TE_err_sig;
  TE_err    <= TE_err_sig or no_te;
	oneMsec_generation: process(C125)  is
		variable counter_TIME1: integer:= 0 ;		
		begin

		if C125='1' and C125'event then								-- generates 1msec signal
			if TE_rising_edge='1' or counter_TIME1=limit_TIME1 then
				counter_TIME1 := 0;
				OneMsec_pic <= '1';
			else 
				counter_TIME1 := counter_TIME1 + 1;
				OneMsec_pic <= '0';
			end if;	
			
			if counter_TIME1<duty_cycle_TIME1 then						-- generates the TIME1 signal according to the duty cycle specs
				TIME1 <= '1';
			else
				TIME1 <= '0';
			end if;
				
		end if;
	end process oneMsec_generation;
	
	FDCE_inst : FDCE
	port map (
	Q => TE_in_register, 	-- Data output
	C => C125, 		-- Clock input
	CE => '1', 		-- Clock enable input
	CLR => '0', 		-- Asynchronous clear input
	D => TE_in 		-- Data input
	);
	TE_rising_edge <= TE_in and not(TE_in_register);

	TIME0_generation: process(C125)  is
		variable counter_TIME0: integer:= 0 ;		
		begin

		if C125='1' and C125'event then								-- generates TE signal (48 msec)
			if TE_rising_edge='1' or counter_TIME0=limit_TIME0 then
				counter_TIME0 := 0;
				TIME0 <= '1';
			else 
				counter_TIME0 := counter_TIME0 + 1;
			end if;	
			
			if counter_TIME0 < duty_cycle_TIME0 then						-- generates the TIME1 signal according to the duty cycle specs
				TIME0 <= '1';
			else
				TIME0 <= '0';
			end if;
				
		end if;
	end process TIME0_generation;
	


	check_te: process(C125) is
		begin
		if (rising_edge(C125)) then
			if(TE_rising_edge='1') then
				no_te <= '0';
				counter_TIME0_sig <= X"000000";
				if counter_TIME0_sig /= X"5B8D7F" then
					TE_err_sig <= '1';
				end if;
			else 
				counter_TIME0_sig <= counter_TIME0_sig + X"000001";	
				if Reset_te='1' then
					TE_err_sig <= '0';
				end if;
			end if;

			if counter_TIME0_sig > X"5B8D80" then
				no_te <= '1';
			end if;

		end if;
	end process check_te;


end comportamental;
