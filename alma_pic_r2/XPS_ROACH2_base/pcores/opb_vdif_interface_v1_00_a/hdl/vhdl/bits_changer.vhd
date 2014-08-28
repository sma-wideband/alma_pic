-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------


entity bits_changer is
  port(

  I:	in  std_logic_vector(1 downto 0);
  O:	out std_logic_vector(1 downto 0);
clk:    in  std_logic
  );
end bits_changer;

architecture arch of bits_changer is
signal output_sig : std_logic_vector(1 downto 0):= "00";
  begin
    process(clk,I)
         begin
		 if(rising_edge(clk)) then
			case I is                 -- data selection signals
	      	  		when "01"  => output_sig <= "11";	-- +3
				when "00"  => output_sig <= "10";     	-- +1
				when "11"  => output_sig <= "01";	-- -1
				when "10"  => output_sig <= "00";	-- -3
				when others => output_sig <= "00";
	       		end case;
		end if;
    end process;
  O <= output_sig; 	
end arch;
