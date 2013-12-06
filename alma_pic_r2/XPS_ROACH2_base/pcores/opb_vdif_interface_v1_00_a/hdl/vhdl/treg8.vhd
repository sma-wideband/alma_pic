-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

-- this is an 8-bit register with clock enable and clock

entity treg8 is
  port(

  D:	in  std_logic_vector(7 downto 0);
  Q:	out std_logic_vector(7 downto 0) := "00000000"; 
  CE: in  std_logic; 
  CK: in  std_logic
  );
end treg8;

architecture arch of treg8 is
  begin
    process(CK)
      begin
        if(rising_edge(CK)) then
          if(CE = '1') then
            Q <= D;
          end if;
        end if;
    end process;
end arch;
