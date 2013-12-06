-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

-- This block simply selects one of 64 signals for routing to a test point.

entity mux64 is
  port(
  --a 0 selects normal data (default) and a 1 selects test data from micro_proc
  data_sel:	in std_logic_vector(5 downto 0);

  --select one of these 64 signals
  data_in:	in std_logic_vector(63 downto 0);

  --and route to output port
  data_out:		out std_logic
  );
end mux64;

architecture arch of mux64 is
  begin
    process(data_sel, data_in)
      begin
        case data_sel is                 -- data selection signals
      	  when "000000" => data_out <= data_in(0);
        	when "000001" => data_out <= data_in(1); 
        	when "000010" => data_out <= data_in(2);
        	when "000011" => data_out <= data_in(3);
        	when "000100" => data_out <= data_in(4);
        	when "000101" => data_out <= data_in(5);
        	when "000110" => data_out <= data_in(6);
        	when "000111" => data_out <= data_in(7);
        	when "001000" => data_out <= data_in(8);
        	when "001001" => data_out <= data_in(9);
        	when "001010" => data_out <= data_in(10);
        	when "001011" => data_out <= data_in(11);
        	when "001100" => data_out <= data_in(12);
        	when "001101" => data_out <= data_in(13);
        	when "001110" => data_out <= data_in(14);
        	when "001111" => data_out <= data_in(15);
        	when "010000" => data_out <= data_in(16);
        	when "010001" => data_out <= data_in(17);
        	when "010010" => data_out <= data_in(18);
        	when "010011" => data_out <= data_in(19);
        	when "010100" => data_out <= data_in(20);
        	when "010101" => data_out <= data_in(21);
        	when "010110" => data_out <= data_in(22);
        	when "010111" => data_out <= data_in(23);
        	when "011000" => data_out <= data_in(24);
        	when "011001" => data_out <= data_in(25);
        	when "011010" => data_out <= data_in(26);
        	when "011011" => data_out <= data_in(27);
        	when "011100" => data_out <= data_in(28);
        	when "011101" => data_out <= data_in(29);
        	when "011110" => data_out <= data_in(30);
        	when "011111" => data_out <= data_in(31);
        	when "100000" => data_out <= data_in(32);
        	when "100001" => data_out <= data_in(33);
        	when "100010" => data_out <= data_in(34);
        	when "100011" => data_out <= data_in(35);
        	when "100100" => data_out <= data_in(36);
        	when "100101" => data_out <= data_in(37);
        	when "100110" => data_out <= data_in(38);
        	when "100111" => data_out <= data_in(39);
        	when "101000" => data_out <= data_in(40);
        	when "101001" => data_out <= data_in(41);
        	when "101010" => data_out <= data_in(42);
        	when "101011" => data_out <= data_in(43);
        	when "101100" => data_out <= data_in(44);
        	when "101101" => data_out <= data_in(45);
        	when "101110" => data_out <= data_in(46);
        	when "101111" => data_out <= data_in(47);
        	when "110000" => data_out <= data_in(48);
        	when "110001" => data_out <= data_in(49);
        	when "110010" => data_out <= data_in(50);
        	when "110011" => data_out <= data_in(51);
        	when "110100" => data_out <= data_in(52);
        	when "110101" => data_out <= data_in(53);
        	when "110110" => data_out <= data_in(54);
        	when "110111" => data_out <= data_in(55);
        	when "111000" => data_out <= data_in(56);
        	when "111001" => data_out <= data_in(57);
        	when "111010" => data_out <= data_in(58);
        	when "111011" => data_out <= data_in(59);
        	when "111100" => data_out <= data_in(60);
        	when "111101" => data_out <= data_in(61);
        	when "111110" => data_out <= data_in(62);
      	  when "111111" => data_out <= data_in(63);
          when others => data_out <= data_in(0);
        end case;  
    end process;
end arch;
