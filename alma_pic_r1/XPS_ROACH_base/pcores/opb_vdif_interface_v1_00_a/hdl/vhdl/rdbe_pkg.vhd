library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package rdbe_pkg is

-- constants
constant num_dc : integer := 4;

-- down-converter output type
type dc_array is array (num_dc-1 downto 0) of std_logic_vector(15 downto 0);

-- quantizer data types
type qin_array is array (num_dc-1 downto 0) of signed(15 downto 0);
type qout_array is array (num_dc-1 downto 0) of std_logic_vector(1 downto 0);

-- VDIF data types
type vdifHdr is array (integer range 0 to 3) of std_logic_vector(63 downto 0);
type vdifData is array (integer range 0 to num_dc-1) of
                                    std_logic_vector(15 downto 0);

-- constants for version information
constant TARGET_BOARD    :   std_logic_vector(7 downto 0) := x"01";   -- target board : ROACH
constant C_ID            :   std_logic_vector(7 downto 0) := x"01";   -- creator ID :  NRAO
constant REV_MAJOR_INT   :   std_logic_vector(7 downto 0) := x"01";   -- major revision, integer part
constant REV_MAJOR_FRAC  :   std_logic_vector(7 downto 0) := x"05";   -- major revision, fractional part
constant REV_MINOR       :   std_logic_vector(7 downto 0) := x"04";   -- minor revision
constant FF              :   std_logic_vector(7 downto 0) := x"01";   -- frustration factor
constant P_TYPE          :   std_logic_vector(7 downto 0) := x"83";   -- personality type: DDC real w/VDIF
constant O_FORMAT        :   std_logic_vector(7 downto 0) := x"01";   -- output format : VDIF

end package rdbe_pkg;

