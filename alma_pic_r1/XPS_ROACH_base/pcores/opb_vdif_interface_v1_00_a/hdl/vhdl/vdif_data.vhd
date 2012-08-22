library ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity vdif_data is
  generic ( 
    SAMPLES_IN : integer          -- samples in
    );
  port
    (
      -- differential inputs
      clk_p      : in  std_logic;
      clk_n      : in  std_logic;
      sum_data_p : in  std_logic_vector(63 downto 0);
      sum_data_n : in  std_logic_vector(63 downto 0);
      -- single-ended outputs
      clk_out    : out std_logic;
      data_out   : out std_logic_vector(63 downto 0)
      );
end entity vdif_data;

architecture vdif_arch OF vdif_data
is
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
end architecture vdif_arch;
