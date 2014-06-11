-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_BIT.ALL;
-------------------------------------------------------

-- This entity produces test signals that can be substituted for real signals
-- $Id: test_data_gen.vhd,v 1.4 2014/06/11 19:40:59 rlacasse Exp $

entity test_data_gen is
   port	(
   	  --125 MHz clock
   		C125        : in std_logic;
   		
   		--000 = 64-bit PRN, 001 = counter, 010 = all zeroes, 011 = TBD, 100 = off
   		td_sel  : in std_logic_vector(2 downto 0);
   		
   		--used to start the counter and PRN in sync with the frame; from timing gen
		  frm_sync : in std_logic;
		
		  --Grs is the general reset; a one causes PRN and counter to go to initial state
		  Grs    : in std_logic;

		  --output data
		  td_out      : out std_logic_vector(63 downto 0)
		

   	);
end test_data_gen;

architecture comportamental of test_data_gen is
signal counter_pattern 	: std_logic_vector(63 downto 0);  					--64 bits counter
signal prg_pattern 	: std_logic_vector(34 downto 0);  					--35 bits prg
signal test_prg_init	: std_logic := '0';

component test_prg
	port(
		clk      : in std_logic;
		init     : in std_logic;
		prg_out  : out std_logic_vector(34 downto 0)
	);
end component;

for test_prg_0: test_prg use entity work.test_prg;

begin

   --  Component instantiation.
   test_prg_0: test_prg
   port map (
      clk		=> C125,
      init     	=> test_prg_init,
      prg_out	=> prg_pattern
   );
         
	process(C125,td_sel)
	begin
	  if(Grs = '1') then
	    counter_pattern <= X"0000_0000_0000_0000";
	    test_prg_init   <= '1';
		elsif C125='1' and C125'event then
		 	counter_pattern <= counter_pattern + "1";
			case td_sel is   -- td_out as a function of td_sel bits
				when "010" => td_out <= X"0000_0000_0000_0000";							-- all zeroes
				when "001" => td_out <= counter_pattern;							-- 001 counter pattern
				when "000" => td_out <= prg_pattern(28 downto 0) & prg_pattern(34 downto 0); 			-- 000 Pseudo Random Number Generator
				when others => td_out <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			end case;
			test_prg_init <= Grs or frm_sync;
		end if; 
		
	end process;
	
end comportamental;
