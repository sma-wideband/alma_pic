-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

entity bus_multiplexer is
  port(
     statusWord0 : in std_logic_vector(31 downto 0); 
     statusWord1 : in std_logic_vector(31 downto 0); 
     statusWord2 : in std_logic_vector(31 downto 0); 
     statusWord3 : in std_logic_vector(31 downto 0); 
     statusWord4 : in std_logic_vector(31 downto 0); 
     statusWord5 : in std_logic_vector(31 downto 0); 
     statusWord6 : in std_logic_vector(31 downto 0); 
     statusWord7 : in std_logic_vector(31 downto 0); 
     sel         : in std_logic_vector(2 downto 0);
     output      : out std_logic_vector(31 downto 0); 
     clk         : in  std_logic
  );
end bus_multiplexer;

architecture arch of bus_multiplexer is
signal output_sig : std_logic_vector(31 downto 0):= X"0000_0000";
  begin
    process(clk)
      begin
        if(rising_edge(clk)) then
		case sel is                 -- data selection signals
      	  		when "000"  => output_sig <= statusWord0;
        		when "001"  => output_sig <= statusWord1;     
        		when "010"  => output_sig <= statusWord2;
        		when "011"  => output_sig <= statusWord3;
        		when "100"  => output_sig <= statusWord4;
        		when "101"  => output_sig <= statusWord5;     
        		when "110"  => output_sig <= statusWord6;
        		when "111"  => output_sig <= statusWord7;
			when others => output_sig <= X"0000_0000";
       		end case;
        end if;
    end process;
  output <= output_sig;
end arch;
