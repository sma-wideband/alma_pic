-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-------------------------------------------------------

entity test_prg is
   port(
      clk      : in std_logic;
      init     : in std_logic;
      prg_out  : out std_logic_vector(34 downto 0) := "000" & X"00000005"
   );
end test_prg;

architecture arch of test_prg is

      signal rand_ff    : std_logic_vector(34 downto 0);

   begin
      
      prg_out <= rand_ff;   


      process(clk, init) begin
         if(init = '1') then
            rand_ff <= "000" & X"00000001";     --need to assign to a signal which is assigned
         else
            if(rising_edge(clk)) then
               --rand_ff <= (rand_ff(0) XOR rand_ff(2)) & rand_ff(34 downto 1);
               for i in 0 to 31 loop
                  rand_ff(i + 3) <= rand_ff(i + 2) xor rand_ff(i);
               end loop;
               rand_ff(2 downto 0) <= rand_ff(34 downto 32);
            end if;
         end if;
      end process;
   end arch;

      
   
