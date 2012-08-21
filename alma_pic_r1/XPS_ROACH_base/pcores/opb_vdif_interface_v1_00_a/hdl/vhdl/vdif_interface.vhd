library ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use work.rdbe_pkg.all;

entity opb_vdif_interface is
  generic ( -- Default address = 0x0800 0000
    REV_MAJOR_INT   :   std_logic_vector(7 downto 0) := x"01";   -- major revision, integer part
    REV_MAJOR_FRAC  :   std_logic_vector(7 downto 0) := x"00";   -- major revision, fractional part
    P_TYPE          :   std_logic_vector(7 downto 0) := x"83";   -- personality type
    ADDRHI      : std_logic_vector(18 downto 12) := "0000000";
    nch         : integer range 0 to 7      -- number of channels synthesized
   );
    port
    (
        sys_clk         : in std_logic;
        adc_clk         : in std_logic;
        epb_clk         : in std_logic;
        Grs             : in std_logic;
        OnePPS          : in std_logic;
        DataRdy         : in std_logic_vector(nch-1 downto 0);
        TimeCode        : in std_logic_vector(31 downto 0);
        dataIn          : in vdifData;
        DeviceCSn       : in std_logic;
        DeviceRWn       : in std_logic;
        DeviceAddr      : in std_logic_vector(18 downto 0);
        DeviceDataIn    : in std_logic_vector(15 downto 0);
        DeviceDataOut   : out std_logic_vector(15 downto 0);
        To10GbeTxData   : out std_logic_vector(63 downto 0);
        To10GbeTxDataValid  : out std_logic;
        To10GbeTxEOF    : out std_logic
    );
end entity opb_vdif_interface;

architecture vdif_arch OF opb_vdif_interface
is
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    component vdif_input_sel
        port
        (
            wrClk       : in std_logic;
            rdClk       : in std_logic;
            reset       : in std_logic;     -- global reset
            valid       : in std_logic;     -- valid data started
            dataRdy     : in std_logic;
            rdFifoEna   : in std_logic;
            cplxFlg     : in std_logic;
            numBit      : in std_logic_vector(4 downto 0);

            data_in     : in std_logic_vector(15 downto 0);

            full        : out std_logic;
            prog_full   : out std_logic;
            data_out    : out std_logic_vector(63 downto 0)
        );
    end component vdif_input_sel;

    component vdif_formatter is
        port
        (
            Clk         : in std_logic; -- tx clock
            Grs         : in std_logic;
            MstrEna     : in std_logic;
            Header      : in vdifHdr;   -- 8 x 32 bits
            FifoData    : in std_logic_vector(63 downto 0);

            FifoEna             : out std_logic;
            To10GbeTxData       : out std_logic_vector(63 downto 0);
            To10GbeTxDataValid  : out std_logic;
            To10GbeTxEOF        : out std_logic
        );
    end component vdif_formatter;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    -- maximum number of channels that can be used. Initially set to 7.
    -- if this is to increase - the PPC DeviceData case definitions must change
    constant MXCH : integer := 7;

    type FrameNArray is array (0 to nch-1) of std_logic_vector(23 downto 0);
    signal FrameNum    : FrameNArray;

    signal ComplexFlags: std_logic_vector(0 to 7);

    type BpS_Array is array (0 to MXCH) of std_logic_vector(4 downto 0);
    signal Bits_SampA   : BpS_Array;

    type SampRateArray is array (0 to MXCH) of std_logic_vector(23 downto 0);
    signal SampleRateA  : SampRateArray;

    type Loif_Ftw is array (0 to MXCH) of std_logic_vector(31 downto 0);
    signal LoifFtwA     : Loif_Ftw;

    type IFnumArray is array (0 to MXCH) of std_logic_vector(3 downto 0);
    signal IFnumA       : IFnumArray;

    type SubBandArray is array (0 to MXCH) of std_logic_vector(3 downto 0);
    signal SubBandA     : SubBandArray;

    --type RateArray is array (0 to MXCH) of std_logic_vector(1 downto 0);
    signal selRate : std_logic_vector(1 downto 0);

    signal ESideBand: std_logic_vector(7 downto 0);

    -- VDIF Header definition
type HdrArray is record
    --Word 0    words are 32 bits wide
    InvFlg   : std_logic;-- := 0;
    Legacy   : std_logic;-- := 0;
    SFRE     : std_logic_vector(29 downto 0); -- seconds from ref epoch
    --Word 1
    RefEpoch : std_logic_vector(7 downto 0);  -- only 6 bits valid
    FrameNum : std_logic_vector(23 downto 0);
    --Word 2
    VERS   : std_logic_vector(2 downto 0);-- := "001";
    LogCh  : std_logic_vector(4 downto 0);-- := "00000"; --num chan in array=1 (2^^0)?
    FrameLen : std_logic_vector(23 downto 0);-- := x"1388"; -- =5000?
    --Word 3
    CmplxFlg : std_logic;
    Bits_Samp: std_logic_vector(4 downto 0);-- initially defaults to 2
    ThreadID : std_logic_vector(9 downto 0);-- default to channel number
    StationID: std_logic_vector(15 downto 0);
    --Word 4
    EDV    : std_logic_vector(7 downto 0);-- := x"3C"; -- ExtendedUserDataVersion
    --signal UnitFlg  : std_logic;  add this bit to SRU vector below
    SRU      : std_logic_vector(23 downto 0);
    --Word 5
    SYNC   : std_logic_vector(31 downto 0);--:= x"ACABFEED";
    --Word 6
    LoifFtw  : std_logic_vector(31 downto 0);
    --Word 7
    DBEnum   : std_logic_vector(3 downto 0);
    IFnum    : std_logic_vector(3 downto 0);
    SubBand  : std_logic_vector(2 downto 0);
    ESideBand: std_logic;
    MajRev   : std_logic_vector(3 downto 0);
    MinRev   : std_logic_vector(3 downto 0);
    Persnlity: std_logic_vector(7 downto 0);
end record HdrArray;

    signal HdrAry : HdrArray;
    signal HdrBlk : vdifHdr;
 -------------------------------------------------------------------------------
    -- definitions for vdif channel counter state machine
    type vdifChCntr is
    (
        ccStartWait,
        ccFifoFull,
        ccWaitFE1,
        ccWaitFE0,
        ccIncFrame,
        ccIncCh
    ); -- Define the states to increment to next channel/packet
    signal ccCntrState : vdifChCntr;
 -------------------------------------------------------------------------------

    signal currCh       : integer range 0 to nch-1;
    signal Legacy       : std_logic;
    signal StationID    : std_logic_vector(15 downto 0);
    signal DBEnum       : std_logic_vector(3 downto 0);


    signal selInput     : std_logic_vector(3 downto 0);
    signal TimeAlign    : std_logic_vector(15 downto 0);
    signal TimeAlign_adc: std_logic_vector(15 downto 0);
    signal data_out     : vdifHdr;

    signal RefEpoch     : std_logic_vector(7 downto 0);
--    signal SecFromRefEpoch : std_logic_vector(29 downto 0);
    signal SyncWord     : std_logic_vector(31 downto 0);
    signal Status       : std_logic_vector(15 downto 0);
    signal CurrData     : std_logic_vector(63 downto 0);

    --signal DTMControlReg: std_logic_vector(15 downto 0);
    signal DTMStatus    : std_logic_vector(2 downto 0);
    signal TimeSlot1On  : std_logic_vector(31 downto 0);
    signal TimeSlot1Off : std_logic_vector(31 downto 0);
    signal DTMOnReg     : std_logic_vector(31 downto 0);
    signal DTMOffReg    : std_logic_vector(31 downto 0);
    signal ValidFlag, ValidFlag_sys, ValidFlag_epb, ValidFlag_adc : std_logic;
    signal ValidA       : std_logic_vector(7 downto 0);
    signal pps1,pps2,pps3: std_logic;
    signal pps_sys      : std_logic;
    signal arm          : std_logic;
    signal FmtrEna      : std_logic;
    signal prog_full    : std_logic_vector(nch-1 downto 0);
    signal full         : std_logic_vector(nch-1 downto 0);
    signal FifoError    : std_logic;
    signal FifoEna      : std_logic;
    signal rdFifoEna    : std_logic_vector(nch-1 downto 0);
    signal TestMode     : std_logic;
    signal TimeCntr     : std_logic_vector(15 downto 0);
    signal log2numchan  : std_logic_vector(4 downto 0);
    signal EpochSeconds : std_logic_vector(29 downto 0);
    signal EpochSecSet  : std_logic_vector(29 downto 0);
    signal EpochSecReg  : std_logic_vector(29 downto 0);

    -- weaver delay should include all other constant delays (like quantizer)
    constant WVR_DELAY       : std_logic_vector(15 downto 0) := x"000F";
    constant CIC_DELAY       : std_logic_vector(15 downto 0) := x"0017";
    constant MUX_DELAY       : std_logic_vector(15 downto 0) := x"0001";
    constant FIR_DELAY       : std_logic_vector(15 downto 0) := x"0002";
    signal OnePPSDelayCount : std_logic_vector(15 downto 0);
    signal TotalDelay       : std_logic_vector(15 downto 0);
    signal IntDelay         : std_logic_vector(15 downto 0);
    signal ppsFinish        : std_logic;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  -- EPB register write process
    RegisterWrite : process(Grs, epb_clk, DeviceCSn,
                            DeviceRWn, DeviceAddr(18 downto 0))
    begin

    if (Grs = '1') then
        TimeAlign(15 downto 0) <= x"0000";
        SyncWord <= x"ACABFEED";
        Legacy <= '0';
        selInput <= x"F";       -- bottom 4 channels on
        log2numchan <= "00010"; -- 4 channels total default
    elsif rising_edge(epb_clk) then
        if (DeviceCSn = '0') AND (DeviceRWn = '0') AND
            DeviceAddr(18 downto 12) = ADDRHI then
          case (DeviceAddr(11 downto 0)) is

            when x"000" => SyncWord(15 downto 0) <= DeviceDataIn;       --0x000
            when x"001" => SyncWord(31 downto 16) <= DeviceDataIn;      --0x002
            when x"002" => RefEpoch <= DeviceDataIn(7 downto 0);        --0x004
            when x"003" => Legacy <= DeviceDataIn(0);                   --0x006
            when x"004" => StationID <= DeviceDataIn;                   --0x008
            when x"005" => DBEnum <= DeviceDataIn(3 downto 0);          --0x00A
            when x"006" => TestMode <= DeviceDataIn(0);                 --0x00C
            when x"00A" => TimeSlot1On(15 downto 0) <= DeviceDataIn;    --0x014
            when x"00B" => TimeSlot1On(31 downto 16) <= DeviceDataIn;   --0x016
            when x"00C" => TimeSlot1Off(15 downto 0) <= DeviceDataIn;   --0x018
            when x"00D" => TimeSlot1Off(31 downto 16) <= DeviceDataIn;  --0x01A
            when x"00E" => TimeAlign <= DeviceDataIn;                   --0x01C
            when x"00F" => selInput <= DeviceDataIn(3 downto 0);        --0x01E
            when x"010" => log2numchan <= DeviceDataIn(4 downto 0);     --0x020

            when x"080" => LOIFftwA(0)(15 downto  0) <= DeviceDataIn;   --0x100
            when x"081" => LOIFftwA(0)(31 downto 16) <= DeviceDataIn;   --0x102
            when x"082" => LOIFftwA(1)(15 downto  0) <= DeviceDataIn;   --0x104
            when x"083" => LOIFftwA(1)(31 downto 16) <= DeviceDataIn;   --0x106
            when x"084" => LOIFftwA(2)(15 downto  0) <= DeviceDataIn;   --0x108
            when x"085" => LOIFftwA(2)(31 downto 16) <= DeviceDataIn;   --0x10A
            when x"086" => LOIFftwA(3)(15 downto  0) <= DeviceDataIn;   --0x10C
            when x"087" => LOIFftwA(3)(31 downto 16) <= DeviceDataIn;   --0x10E
            when x"088" => LOIFftwA(4)(15 downto  0) <= DeviceDataIn;   --0x110
            when x"089" => LOIFftwA(4)(31 downto 16) <= DeviceDataIn;   --0x112
            when x"08A" => LOIFftwA(5)(15 downto  0) <= DeviceDataIn;   --0x114
            when x"08B" => LOIFftwA(5)(31 downto 16) <= DeviceDataIn;   --0x116
            when x"08C" => LOIFftwA(6)(15 downto  0) <= DeviceDataIn;   --0x118
            when x"08D" => LOIFftwA(6)(31 downto 16) <= DeviceDataIn;   --0x11A
            when x"08E" => LOIFftwA(7)(15 downto  0) <= DeviceDataIn;   --0x11C
            when x"08F" => LOIFftwA(7)(31 downto 16) <= DeviceDataIn;   --0x11E

            when x"090" => SampleRateA(0)(15 downto 0) <= DeviceDataIn; --0x120
            when x"091" => SampleRateA(0)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x122
            when x"092" => SampleRateA(1)(15 downto 0) <= DeviceDataIn; --0x124
            when x"093" => SampleRateA(1)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x126
            when x"094" => SampleRateA(2)(15 downto 0) <= DeviceDataIn; --0x128
            when x"095" => SampleRateA(2)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x12A
            when x"096" => SampleRateA(3)(15 downto 0) <= DeviceDataIn; --0x12C
            when x"097" => SampleRateA(3)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x12E
            when x"098" => SampleRateA(4)(15 downto 0) <= DeviceDataIn; --0x130
            when x"099" => SampleRateA(4)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x132
            when x"09A" => SampleRateA(5)(15 downto 0) <= DeviceDataIn; --0x134
            when x"09B" => SampleRateA(5)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x136
            when x"09C" => SampleRateA(6)(15 downto 0) <= DeviceDataIn; --0x138
            when x"09D" => SampleRateA(6)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x13A
            when x"09E" => SampleRateA(7)(15 downto 0) <= DeviceDataIn; --0x13C
            when x"09F" => SampleRateA(7)(23 downto 16) <=
                                            DeviceDataIn(7 downto 0);   --0x13E

            when x"0A0" => Bits_SampA(0) <= DeviceDataIn(4 downto 0);
                           Bits_SampA(1) <= DeviceDataIn(12 downto 8);  --0x140
            when x"0A1" => Bits_SampA(2) <= DeviceDataIn(4 downto 0);
                           Bits_SampA(3) <= DeviceDataIn(12 downto 8);  --0x142
            when x"0A2" => Bits_SampA(4) <= DeviceDataIn(4 downto 0);
                           Bits_SampA(5) <= DeviceDataIn(12 downto 8);  --0x144
            when x"0A3" => Bits_SampA(6) <= DeviceDataIn(4 downto 0);
                           Bits_SampA(7) <= DeviceDataIn(12 downto 8);  --0x146
            when x"0A4" => IFnumA(3) <= DeviceDataIn(15 downto 12);
                           IFnumA(2) <= DeviceDataIn(11 downto 8);
                           IFnumA(1) <= DeviceDataIn(7 downto 4);
                           IFnumA(0) <= DeviceDataIn(3 downto 0);       --0x148
            when x"0A5" => IFnumA(7) <= DeviceDataIn(15 downto 12);
                           IFnumA(6) <= DeviceDataIn(11 downto 8);
                           IFnumA(5) <= DeviceDataIn(7 downto 4);
                           IFnumA(4) <= DeviceDataIn(3 downto 0);       --0x14A
            when x"0A6" => SubBandA(3) <= DeviceDataIn(15 downto 12);
                           SubBandA(2) <= DeviceDataIn(11 downto 8);
                           SubBandA(1) <= DeviceDataIn(7 downto 4);
                           SubBandA(0) <= DeviceDataIn(3 downto 0);     --0x14C
            when x"0A7" => SubBandA(7) <= DeviceDataIn(15 downto 12);
                           SubBandA(6) <= DeviceDataIn(11 downto 8);
                           SubBandA(5) <= DeviceDataIn(7 downto 4);
                           SubBandA(4) <= DeviceDataIn(3 downto 0);     --0x14E

            when x"100" => ComplexFlags <= DeviceDataIn(7 downto 0);    --0x200
            when x"101" => ESideBand    <= DeviceDataIn(7 downto 0);    --0x202

            when x"105" => EpochSecSet(15 downto 0) <= DeviceDataIn;   --0x210
            when x"106" => EpochSecSet(29 downto 16) <=
                                            DeviceDataIn(13 downto 0);  --0x212

            when others => null;
            end case;
         end if;
    end if;
    end process RegisterWrite;

-- default vdif address for PPC = 0xD080_0xxx
-------------------------------------------------------------------------------
    -- EPB register read process
    RegisterRead : process(epb_clk, DeviceCSn,
                    DeviceRWn, DeviceAddr(18 downto 0))
   begin
    if rising_edge(epb_clk) then
        if (DeviceCSn = '0') AND (DeviceRWn = '1') AND
            DeviceAddr(18 downto 12) = ADDRHI then
          case (DeviceAddr(11 downto 0)) is

            when x"000" => DeviceDataOut <= SyncWord(15 downto 0);      --0x0000
            when x"001" => DeviceDataOut <= SyncWord(31 downto 16);     --0x0002
            when x"002" => DeviceDataOut <= x"00" & RefEpoch;           --0x0004
            when x"003" => DeviceDataOut <= x"000" & "000" & Legacy;    --0x0006
            when x"004" => DeviceDataOut <= StationID;                  --0x0008
            when x"005" => DeviceDataOut <= x"000" & DBEnum;            --0x000A
            when x"006" => DeviceDataOut <=
             std_logic_vector(to_unsigned(currCh,4)) & FrameNum(currCh);--0x000C
            when x"007" => DeviceDataOut <= status;                     --0x000E
            when x"009" => DeviceDataOut <= x"000" &"0" & DTMStatus;    --0x0012
            when x"00A" => DeviceDataOut <= TimeSlot1On(15 downto 0);   --0x0014
            when x"00B" => DeviceDataOut <= TimeSlot1On(31 downto 16);  --0x0016
            when x"00C" => DeviceDataOut <= TimeSlot1Off(15 downto 0);  --0x0018
            when x"00D" => DeviceDataOut <= TimeSlot1Off(31 downto 16); --0x001A
            when x"00E" => DeviceDataOut <= TimeAlign;                  --0x001C
            when x"00F" => DeviceDataOut <= prog_full & x"0" & selInput;--0x001E

            when x"010" => DeviceDataOut <= x"00"&"000"&log2numchan;    --0x0020

            -- fill in the individual channel header blocks
            when x"080" => DeviceDataOut <= LOIFftwA(0)(15 downto  0);  --0x0100
            when x"081" => DeviceDataOut <= LOIFftwA(0)(31 downto 16);  --0x0102
            when x"082" => DeviceDataOut <= LOIFftwA(1)(15 downto  0);  --0x0104
            when x"083" => DeviceDataOut <= LOIFftwA(1)(31 downto 16);  --0x0106
            when x"084" => DeviceDataOut <= LOIFftwA(2)(15 downto  0);  --0x0108
            when x"085" => DeviceDataOut <= LOIFftwA(2)(31 downto 16);  --0x010A
            when x"086" => DeviceDataOut <= LOIFftwA(3)(15 downto  0);  --0x010C
            when x"087" => DeviceDataOut <= LOIFftwA(3)(31 downto 16);  --0x010E
            when x"088" => DeviceDataOut <= LOIFftwA(4)(15 downto  0);  --0x0110
            when x"089" => DeviceDataOut <= LOIFftwA(4)(31 downto 16);  --0x0112
            when x"08A" => DeviceDataOut <= LOIFftwA(5)(15 downto  0);  --0x0114
            when x"08B" => DeviceDataOut <= LOIFftwA(5)(31 downto 16);  --0x0116
            when x"08C" => DeviceDataOut <= LOIFftwA(6)(15 downto  0);  --0x0118
            when x"08D" => DeviceDataOut <= LOIFftwA(6)(31 downto 16);  --0x011A
            when x"08E" => DeviceDataOut <= LOIFftwA(7)(15 downto  0);  --0x011C
            when x"08F" => DeviceDataOut <= LOIFftwA(7)(31 downto 16);  --0x011E

            when x"090" => DeviceDataOut <=          SampleRateA(0)(15 downto 0);  --0x0120
            when x"091" => DeviceDataOut <= x"00" & SampleRateA(0)(23 downto 16);  --0x0122
            when x"092" => DeviceDataOut <=          SampleRateA(1)(15 downto 0);  --0x0124
            when x"093" => DeviceDataOut <= x"00" & SampleRateA(1)(23 downto 16);  --0x0126
            when x"094" => DeviceDataOut <=          SampleRateA(2)(15 downto 0);  --0x0128
            when x"095" => DeviceDataOut <= x"00" & SampleRateA(2)(23 downto 16);  --0x012A
            when x"096" => DeviceDataOut <=          SampleRateA(3)(15 downto 0);  --0x012C
            when x"097" => DeviceDataOut <= x"00" & SampleRateA(3)(23 downto 16);  --0x012E
            when x"098" => DeviceDataOut <=          SampleRateA(4)(15 downto 0);  --0x0130
            when x"099" => DeviceDataOut <= x"00" & SampleRateA(4)(23 downto 16);  --0x0132
            when x"09A" => DeviceDataOut <=          SampleRateA(5)(15 downto 0);  --0x0134
            when x"09B" => DeviceDataOut <= x"00" & SampleRateA(5)(23 downto 16);  --0x0136
            when x"09C" => DeviceDataOut <=          SampleRateA(6)(15 downto 0);  --0x0138
            when x"09D" => DeviceDataOut <= x"00" & SampleRateA(6)(23 downto 16);  --0x013A
            when x"09E" => DeviceDataOut <=          SampleRateA(7)(15 downto 0);  --0x013C
            when x"09F" => DeviceDataOut <= x"00" & SampleRateA(7)(23 downto 16);  --0x013E

            when x"0A0" => DeviceDataOut <= "000" & Bits_SampA(1) &
                                            "000" & Bits_SampA(0);  --0x0140
            when x"0A1" => DeviceDataOut <= "000" & Bits_SampA(3) &
                                            "000" & Bits_SampA(2);  --0x0142
            when x"0A2" => DeviceDataOut <= "000" & Bits_SampA(5) &
                                            "000" & Bits_SampA(4);  --0x0144
            when x"0A3" => DeviceDataOut <= "000" & Bits_SampA(7) &
                                            "000" & Bits_SampA(6);  --0x0146
            when x"0A4" => DeviceDataOut <= IFnumA(3) & IFnumA(2) &
                                            IFnumA(1) & IFnumA(0);  --0x0148
            when x"0A5" => DeviceDataOut <= IFnumA(7) & IFnumA(6) &
                                            IFnumA(5) & IFnumA(4);  --0x014A
            when x"0A6" => DeviceDataOut <= SubBandA(3) & SubBandA(2) &
                                            SubBandA(1) & SubBandA(0);  --0x014C
            when x"0A7" => DeviceDataOut <= SubBandA(7) & SubBandA(6) &
                                            SubBandA(5) & SubBandA(4);  --0x014E

            when x"100" => DeviceDataOut <= x"00" & ComplexFlags;   --0x0200
            when x"101" => DeviceDataOut <= x"00" & ESideBand;      --0x0202
            when x"105" => DeviceDataOut <= EpochSeconds(15 downto 0);  --0x0210
            when x"106" => DeviceDataOut <= "00" & EpochSeconds(29 downto 16); --0x0212

            when others => DeviceDataOut <= (others => '0');
        end case;
        end if;
    end if;
    end process RegisterRead;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    -- build a status vector
    status <= std_logic_vector(to_unsigned(vdifChCntr'pos(ccCntrState),8))
                & "00" & FifoError & ValidFlag_epb
                & std_logic_vector(to_unsigned(currCh,4));


-------------------------------------------------------------------------------
    -- wait for time to start.
    -- TimeCode is clocked with onePPS
    -- ValidFlag indicates in test time
    valid_proc: process(TimeCode, DTMOnReg, DTMOffReg, epb_clk)
    begin
        if (TimeCode >= DTMOnReg and TimeCode < DTMOffReg) then
            ValidFlag <= '1';
        else
            ValidFlag <= '0';
        end if;
        -- register it to epb clock domain
        if rising_edge(epb_clk) then
            ValidFlag_epb <= ValidFlag;
        end if;
    end process;

    -- build a DTM status register
    -- "00" : off/no command received
    -- "01" : off/waiting to turn on
    -- "10" : on
    -- "11" : off/done
    dtm_proc:  process(DTMOnReg, ValidFlag_epb, TimeCode, DTMOffReg)
    begin
        if (DTMOnReg = X"00000000") then
            DTMStatus   <= ValidFlag_epb & "00";    --ready (init)
        elsif (TimeCode < DTMOnReg) then
            DTMStatus <= ValidFlag_epb & "10";      --waiting
        elsif (TimeCode < DTMOffReg) then
            DTMStatus <= ValidFlag_epb & "01";      --transmitting
        else --if (TimeCode >= DTMOffReg) then
            DTMStatus   <= ValidFlag_epb & "11";    --finished (rdy)
        end if;
    end process dtm_proc;

-------------------------------------------------------------------------------

    -- resync the OnePPS
    ppsclk : process(OnePPS, pps_sys)
    begin
        if (pps_sys = '1') then
            pps1 <= '0';
        elsif rising_edge(OnePPS) then
            pps1 <= '1';
        end if;
    end process;

    -- for use with the frame counter
    ppssys : process(Grs, sys_clk)
    begin
        if Grs = '1' then
            pps_sys <= '1';
            pps2 <= '0';
            pps3 <= '1';
        elsif rising_edge(sys_clk) then
            pps2 <= pps1;
            pps3 <= NOT pps2;
            pps_sys <= pps2 AND pps3;
        end if;
    end process;

    -- for test mode
    testmd : process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if pps_sys = '1' then
                TimeCntr <= (others => '0');
            else
                TimeCntr <= TimeCntr + 1;
            end if;
        end if;
    end process;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

    -- adjust the delay according to the data path
    dlySel : process (adc_clk)
    begin
        if rising_edge(adc_clk) then

            -- set sample rate delay for all channels from chan(0)...
            -- ...this code says all channels must be at the same sample
            -- rate to get the data to align with external world.
            if SampleRateA(0)(5 downto 0) = "00000" then
                 selRate <= SampleRateA(0)(22 downto 21) OR
                    (NOT SampleRateA(0)(23) & NOT SampleRateA(0)(23));
            else
                 selRate <= "11";
            end if;


            case(selRate)is
                when "10" =>     -- 1x data rate (128MHz)
                    IntDelay <= WVR_DELAY;
                when "01" =>    -- 2x data rate (64MHz)
                    IntDelay <= WVR_DELAY + MUX_DELAY + FIR_DELAY;
                when "00" =>    -- 4x data rate (32MHz)
                    IntDelay <= WVR_DELAY + MUX_DELAY + FIR_DELAY + 1;
                when others =>    -- more than 4x data rate (16MHz or less)
                    IntDelay <= WVR_DELAY + CIC_DELAY + MUX_DELAY + FIR_DELAY;
            end case;

            TotalDelay <= TimeAlign_adc + IntDelay;
        end if;
    end process dlySel;

    -- wait for start time: 'ValidFlag' signals the start time for test
    dlySt : process (adc_clk)
    begin
        if rising_edge(adc_clk) then
            if (ValidFlag = '0') then
                OnePPSDelayCount <= x"0000";
                ValidFlag_adc <= '0';
            elsif (OnePPSDelayCount <= TotalDelay) then
                if (DataRdy(0) = '1') then
                    OnePPSDelayCount <= OnePPSDelayCount + 1;
                end if;
            else
                ValidFlag_adc <= '1';
            end if;
        end if;
    end process dlySt;

-------------------------------------------------------------------------------
    -- Frame Counter - different end count depending on decimation rate.
    -- Use OnePPS and EndOfPacket flag to reset the Frame Counter or count up.
    fctr : process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if (pps_sys = '1')then
                arm <= '1';
            elsif (arm = '1') AND (ccCntrState = ccStartWait) then
                if (ppsFinish = '0') then --1st frame of this second
                    for i in 0 to (nch-1) loop
                        FrameNum(i) <=  (others => '0');
                    end loop;
                    arm <= '0';
                -- else clear after this frame
               end if;
            elsif (ccCntrState = ccIncFrame) then
                FrameNum(currCh) <= FrameNum(currCh) + 1;
            end if;
        end if;
    end process;

-------------------------------------------------------------------------------
-- change channels each time the fifo has been read 625 times in formatter
    chcntr : process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if (ValidFlag_sys = '0') then
                currCh <= 0;
                FmtrEna <= '0';
                ccCntrState <= ccStartWait;
                ppsFinish <= '0';
            else
                case(ccCntrState) is
                    when ccStartWait =>     -- wait for start of frame
                        if prog_full(0) = '0' then
                            ccCntrState <= ccFifoFull;
                        end if;
                    when ccFifoFull =>
                        if prog_full(currCh) = '0' then -- send a packet for
                            ccCntrState <= ccWaitFE1;   -- this channel
                            FmtrEna <= '1';
                        else
                            ccCntrState <= ccIncCh;     -- go to next channel
                        end if;
                        ppsFinish <= '0';
                    when ccWaitFE1 =>
                        if FifoEna = '1' then
                            ccCntrState <= ccWaitFE0;   -- packet tx started
                        end if;
                    when ccWaitFE0 =>
                        if FifoEna = '0' then
                            ccCntrState <= ccIncFrame;  -- packet tx ended
                            FmtrEna <= '0';
                        end if;
                    when ccIncFrame =>      -- frame counter for this channel
                        ccCntrState <= ccIncCh;
                    when ccIncCh =>
                        if(currCh < nch-1) then
                            currCh <= currCh + 1;
                            ccCntrState <= ccFifoFull;
                        else
                            currCh <= 0;
                            ccCntrState <= ccStartWait; -- next frame
                            if(arm = '1')  then
                                ppsFinish <= NOT ppsFinish;
                            end if;--tell FrameNum whether or not to clear
                        end if;
                    when others =>  --huh?
                        ccCntrState <= ccStartWait;
                end case;
            end if;
        end if;
    end process;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
HdrAry.VERS     <= "001";
HdrAry.FrameLen <= x"000275"; --629d=units of 8bytes=5032bytes,including header
HdrAry.EDV      <= x"02";
HdrAry.MajRev   <= REV_MAJOR_INT(3 downto 0);
HdrAry.MinRev   <= REV_MAJOR_FRAC(3 downto 0);
HdrAry.Persnlity<= P_TYPE;

-- fill in the header block each time the channel changes
    HdrBlk(0) <= HdrAry.InvFlg & HdrAry.Legacy & HdrAry.SFRE &
                    HdrAry.RefEpoch & HdrAry.FrameNum;
    HdrBlk(1) <= HdrAry.VERS & HdrAry.LogCh & HdrAry.FrameLen &
                    HdrAry.CmplxFlg & HdrAry.Bits_Samp &
                    HdrAry.ThreadID & HdrAry.StationID;
    HdrBlk(2) <= HdrAry.EDV & HdrAry.SRU &
                    HdrAry.SYNC;
    HdrBlk(3) <= HdrAry.LoifFtw &
                    "1111" & HdrAry.DBEnum & HdrAry.IFnum & HdrAry.SubBand &
                    HdrAry.ESideBand & HdrAry.MajRev & HdrAry.MinRev &
                    HdrAry.Persnlity;

-------------------------------------------------------------------------------
    -- seconds from epoch is reported in header instead of TimeCode
    epochcnt : process(Grs, sys_clk)
    begin
        if (Grs = '1') then
            EpochSeconds <= (others => '0');
        elsif rising_edge(sys_clk) then
            if pps_sys = '1' then
                EpochSeconds <= EpochSeconds + 1;
            elsif EpochSecSet /= EpochSecReg then
                EpochSeconds <= EpochSecSet;
                EpochSecReg <= EpochSecSet;
            end if;
        end if;
    end process;
--SecFromRefEpoch <= EpochSeconds(29 downto 0);       -- rename
-------------------------------------------------------------------------------
    -- change clock domains to sys_clk
    syncsys : process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            ValidFlag_sys       <= ValidFlag;
            if ccCntrState = ccFifoFull then
                HdrAry.InvFlg       <= (NOT ValidFlag) OR FifoError;
                HdrAry.Legacy       <= Legacy;
                HdrAry.SFRE         <= EpochSeconds;
                HdrAry.RefEpoch     <= RefEpoch;
                HdrAry.LogCh        <= log2numchan;
                HdrAry.FrameNum     <= FrameNum(currCh);
                HdrAry.CmplxFlg     <= ComplexFlags(currCh);
                HdrAry.Bits_Samp    <= Bits_SampA(currCh);
                HdrAry.ThreadID     <= std_logic_vector(to_unsigned(currCh,10));
                HdrAry.StationID    <= StationID;
                HdrAry.SRU          <= SampleRateA(currCh);
                HdrAry.SYNC         <= SyncWord;
                --HdrAry.LoifFtw      <= LoifFtwA(currCh);
                HdrAry.DBEnum       <= DBEnum;
                HdrAry.IFnum        <= IFnumA(currCh);
                HdrAry.SubBand      <= SubBandA(currCh)(2 downto 0);
                HdrAry.ESideBand    <= ESideBand(currCh);
                if TestMode = '0' then
                    HdrAry.LoifFtw <= LoifFtwA(currCh);
                else
                    HdrAry.LoifFtw <= TimeCntr & LoifFtwA(currCh)(15 downto 0);
                end if;
            end if;
        end if;
    end process;

-------------------------------------------------------------------------------
    -- change clock domains to adc_clk
    syncadc : process(Grs, adc_clk)
    begin
        if Grs = '1' then
            DTMOnReg            <= (others => '0');
            DTMOffReg           <= (others => '1');
            TimeAlign_adc       <= (others => '0');
        elsif rising_edge(adc_clk) then
            DTMOnReg            <= TimeSlot1On;
            DTMOffReg           <= TimeSlot1Off;
            TimeAlign_adc       <= TimeAlign;

            for i in 0 to (nch-1) loop
                -- turn channel off or on
                ValidA(i) <= ValidFlag_adc AND selInput(i);
                -- choose which fifo is being read now
                if currCh = i then
                    rdFifoEna(i) <= FifoEna;
                else
                    rdFifoEna(i) <= '0';
                end if;
           end loop;

        end if;
    end process;


-------------------------------------------------------------------------------
-- Input select and enable
  selIn    : for i in 0 to nch-1 generate
    chSel   : vdif_input_sel
    port map(
        wrClk       =>  adc_clk,        --: in std_logic;
        rdClk       =>  sys_clk,        --: in std_logic;
        reset       =>  Grs,            --: in std_logic;
        valid       =>  ValidA(i),      --: in std_logic;
        dataRdy     =>  DataRdy(i),     --: in std_logic;
        rdFifoEna   =>  rdFifoEna(i),   --: in std_logic;
        cplxFlg     =>  ComplexFlags(i),--: in std_logic;
        numBit      =>  Bits_SampA(i),  --: in std_logic_vector(4 downto 0);

        data_in     =>  dataIn(i),      --: in std_logic_vector(15 downto 0);

        full        =>  full(i),        --: out std_logic
        prog_full   =>  prog_full(i),   --: out std_logic;
        data_out    =>  data_out(i)     --: out std_logic_vector(63 downto 0)
    );
    end generate;

    ckff: process(sys_clk, full, ValidFlag_sys)
    begin
        if rising_edge(sys_clk) then
            if full /= x"0" then        -- compile for 4 channels
                FifoError <= '1';       -- latch for duration of test
            elsif ValidFlag_sys = '0' then
                FifoError <= '0';       -- clear once this test is over
            end if;
        end if;
    end process;

-------------------------------------------------------------------------------
--Formatter
CurrData <= data_out(currCh);

    --format a single channel when FifoRdy says there are 625 words in fifo
    fmt_ch : vdif_formatter
        port map
        (
            Clk         =>  sys_clk,            --: in std_logic;
            Grs         =>  Grs,                --: in std_logic;
            MstrEna     =>  FmtrEna,            --: in std_logic;
            Header      =>  HdrBlk,             --: in vdifHdr;
            FifoData    =>  CurrData,           --: in slvector(63 downto 0);

            FifoEna             => FifoEna,     --: out std_logic;
            To10GbeTxData       => To10GbeTxData,   --: out slv(63 downto 0);
            To10GbeTxDataValid  => To10GbeTxDataValid,  --: out std_logic;
            To10GbeTxEOF        => To10GbeTxEOF --: out std_logic
        );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
end architecture vdif_arch;
