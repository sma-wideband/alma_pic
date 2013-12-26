-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

-- This block simply selects between the sum data and test data based on a bit from the microprocessor.

entity out_data_sel is
  port(
  --a 0 selects normal data (default) and a 1 selects test data from micro_proc
  data_sel:	in std_logic;

  --sum data, from data interface
  sum_in:	in std_logic_vector(63 downto 0);

  --test data from test_data_gen
  td_in:		in std_logic_vector(63 downto 0);
   
  --sum data to formatter
  sum_di:	out std_logic_vector(63 downto 0)
  );
end out_data_sel;

architecture arch of out_data_sel is
 
  begin

    process(data_sel, sum_in, td_in)
    begin
      case data_sel is                 -- data selection signals-
      	when '0' => sum_di <= sum_in;
      	when '1' => sum_di <= td_in;
        when others => sum_di <= td_in;
      end case;  
    end process;
   
end arch;
