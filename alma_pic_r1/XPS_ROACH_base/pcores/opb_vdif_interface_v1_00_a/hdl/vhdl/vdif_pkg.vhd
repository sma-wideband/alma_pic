-- </doc vdif_Pkg.vhd
--  define vdifHdr
-- doc/>

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rdbe_Pkg.all;

package vdif_Pkg is

-------------------------------------------------------------------------------

type vdifHdr is array (integer range 0 to 3) of std_logic_vector(63 downto 0);
type vdifData is array (integer range 0 to num_dc-1) of 
                                    std_logic_vector(15 downto 0);
-------------------------------------------------------------------------------
    -- VDIF Header definition
--type HdrArray is record
--    --Word 0
--    signal InvFlg   : std_logic := 0;
--    signal Legacy   : std_logic := 0;
--    signal SFRE     : std_logic_vector(29 downto 0); -- seconds from ref epoch
--    --Word 1
--    signal RefEpoch : std_logic_vector(7 downto 0);  -- only 6 bits valid
--    signal FrameNum : std_logic_vector(23 downto 0);
--    --Word 2
--    constant VERS   : std_logic_vector(2 downto 0) := "001";
--    signal LogCh    : std_logic_vector(4 downto 0); --num chan in array=1?
--    signal FrameLen : std_logic_vector(23 downto 0); -- =5000?
--    --Word 3
--    signal CmplxFlg : std_logic;
--    signal Bits_Samp: std_logic_vector(4 downto 0);-- initially defaults to 2
--    signal ThreadID : std_logic_vector(9 downto 0);-- default to channel number
--    signal StationID: std_logic_vector(15 downto 0);
--    --Word 4
--    constant EDV    : std_logic_vector(7 downto 0) := x"3C"; -- ExtendedUserDataVersion
--    signal UnitFlg  : std_logic;
--    signal SRU      : std_logic_vector(22 downto 0);
--    --Word 5
--    constant SYNC   : std_logic_vector(31 downto 0):= x"ACABFEED";
--    --Word 6
--    signal LoifFtw  : std_logic_vector(31 downto 0);
--    --Word 7
--    signal DBEnum   : std_logic_vector(3 downto 0);
--    signal IFnum    : std_logic_vector(3 downto 0);
--    signal SubBand  : std_logic_vector(2 downto 0);
--    signal ESideBand: std_logic;
--    signal MajRev   : std_logic_vector(3 downto 0);
--    signal MinRev   : std_logic_vector(3 downto 0);
--    signal Persnlity: std_logic_vector(3 downto 0);
--end record HdrArray;
--

end package vdif_Pkg;

