library ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.rdbe_pkg.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity opb_vdif_interface is
  generic ( 

    -- Bus protocol parameters
    C_BASEADDR : std_logic_vector := X"00000000";
    C_HIGHADDR : std_logic_vector := X"0000FFFF";
    C_OPB_AWIDTH : integer := 32;
    C_OPB_DWIDTH : integer := 32;
    C_FAMILY : string := "virtex5";

    -- other parameters
    REV_MAJOR_INT   :   std_logic_vector(7 downto 0) := x"01";   -- major revision, integer part
    REV_MAJOR_FRAC  :   std_logic_vector(7 downto 0) := x"00";   -- major revision, fractional part
    P_TYPE          :   std_logic_vector(7 downto 0) := x"83";   -- personality type
    ADDRHI      : std_logic_vector(23 downto 0) := X"000000";
    nch         : integer range 0 to 7 := 4      -- number of channels synthesized
   );
    port
    (

      -- Bus protocol ports
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      Sl_DBus : out std_logic_vector(0 to C_OPB_DWIDTH-1); -- note: MSB is bit 0
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      OPB_ABus : in std_logic_vector(0 to C_OPB_AWIDTH-1);  -- note: MSB is bit 0
      OPB_BE : in std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_DBus : in std_logic_vector(0 to C_OPB_DWIDTH-1);  -- note: MSB is bit 0
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      
      --Multi-Drop Bus Interface
      CD_I      : in std_logic_vector(0 to 7); -- uP bus
      CD_O      : out std_logic_vector(0 to 7); -- uP bus
      CD_T      : out std_logic; -- uP bus
      CTRL_DATA : in std_logic; -- control line for uP data bus
      RnW       : in std_logic; -- read not write
      uCLK0     : in std_logic; -- clock for microprocessor bus

      -- other ports
      clk_in_p        : in std_logic;  --correlator 125 MHz clock
      clk_in_n        : in std_logic;
      adc_clk         : in std_logic;  --alternate clock, connected to on-board 100MHz, for bench testing      
      sum_data_p      : in std_logic_vector(63 downto 0); --sum_data_p(0) is the LSB of channel 0; sum_data_p(63) is the MSB of channel 31, etc.
      sum_data_n      : in std_logic_vector(63 downto 0);
      PPS_Maser_p     : in std_logic;  --1-PPS from Maser for sanity check of the locally generated 1-PPS from the TE
      PPS_Maser_n     : in std_logic;
      PPS_GPS_p       : in std_logic;  --1-PPS from GPS for sanity check of the locally generated 1-PPS from the TE
      PPS_GPS_n       : in std_logic;
      PPS_PIC_p       : out std_logic;  --local 1-PPS generated 1-PPS from the TE, for output to test point on 1-PPS buffer card
      PPS_PIC_n       : out std_logic;
      TE_p            : in std_logic;   --the 48 msec TE signal from the QCC, called TIME_IN on PIC schematic
      TE_n            : in std_logic;
      TIME0           : out std_logic;  --the 48 msec TE signal to the microprocessor interrupt
      DONE            : out std_logic;  --signal to indicate to microprocessor that FPGA is programmed.  Drive low      
--      DataRdy         : in std_logic_vector(nch-1 downto 0);
--      TimeCode        : in std_logic_vector(31 downto 0);
--      dataIn          : in std_logic_vector(63 downto 0);  --data for VLBA; need to delete sometime

      -- ten GbE ports
      To10GbeTxData   : out std_logic_vector(63 downto 0);
      To10GbeTxDataValid  : out std_logic;
      To10GbeTxEOF    : out std_logic;
      
      --DAC ports
      DAC_CLK_p       : out std_logic;
      DAC_CLK_n       : out std_logic;
      DAC_IN_A        : out std_logic_vector(3 downto 0);      
      DAC_IN_B        : out std_logic_vector(3 downto 0);
--      DAC_IN_A0       : out std_logic_vector(3 downto 0);  --test to try to get DAC data bits working
      
      -- test ports
      test_port_out   : out std_logic_vector(31 downto 0);
      test_port_in0   : in  std_logic_vector(31 downto 0);
      test_port_in1   : in  std_logic_vector(31 downto 0);                  
      ROACHTP         : out std_logic_vector(1 downto 0);
      ROUTB           : out std_logic_vector(3 downto 0)  --test points to JR1           
      
    );
end entity opb_vdif_interface;

architecture vdif_arch OF opb_vdif_interface
is
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--    component vdif_input_sel
--        port
--        (
--            wrClk       : in std_logic;
--            rdClk       : in std_logic;
--            reset       : in std_logic;     -- global reset
--            valid       : in std_logic;     -- valid data started
--            dataRdy     : in std_logic;
--            rdFifoEna   : in std_logic;
--            cplxFlg     : in std_logic;
--            numBit      : in std_logic_vector(4 downto 0);

--            data_in     : in std_logic_vector(15 downto 0);

--            full        : out std_logic;
--            prog_full   : out std_logic;
--            data_out    : out std_logic_vector(63 downto 0)
--        );
--    end component vdif_input_sel;

--    component vdif_formatter is
--        port
--        (
--            Clk         : in std_logic; -- tx clock
--            Grs         : in std_logic;
--            MstrEna     : in std_logic;
--            Header      : in vdifHdr;   -- 8 x 32 bits
--            FifoData    : in std_logic_vector(63 downto 0);

--            FifoEna             : out std_logic;
--            To10GbeTxData       : out std_logic_vector(63 downto 0);
--            To10GbeTxDataValid  : out std_logic;
--            To10GbeTxEOF        : out std_logic
--        );
--    end component vdif_formatter;

--    component vdif_data
--      generic (
--        SAMPLES_IN : integer);          -- samples in
--      port (
--        clk_p      : in  std_logic;
--        clk_n      : in  std_logic;
--        sum_data_p : in  std_logic_vector(63 downto 0);
--        sum_data_n : in  std_logic_vector(63 downto 0);
--        clk_out    : out std_logic;
--        data_out   : out std_logic_vector(63 downto 0));
--    end component vdif_data;
    
    component  c167_interface
	     port(
		   uclk	       	: in std_logic;					-- processor clock 
		   read_write  	: in std_logic;					-- read and write selection, read_write='1' => read, '0' => write
		   ctrl_data		: in std_logic; 			-- control data selector, ctr_data='1' => control, '0' => data 
		   c167_data_I	: in std_logic_vector (7 downto 0); 	-- bus connection with the c167, bidirectional
		   c167_data_O	: out std_logic_vector (7 downto 0); 	-- bus connection with the c167, bidirectional
		   data_from_cpu	: out std_logic_vector (7 downto 0); -- data_from_CPU, must be used together with C167_WR_EN(X) being 0<=X<=31
		   data_to_cpu		: in std_logic_vector (7 downto 0);	-- data_to_CPU, must be used together with C167_RR_EN(X) being 0<=X<=31
		   C167_RD_EN			: out std_logic_vector (31 downto 0);	-- Read enable signals, they must be individually connected to the tri-state controller associated to teh desired signals
		   C167_WR_EN		  : out std_logic_vector (31 downto 0);	-- Write enable signals, they must be individually connected to the "clock enable" associated to the addressed register.
		   C167_CLK				: out std_logic	-- C167 clock signal, the first 4 clocks were removed.
	);
  end component c167_interface;
  
    component mux64
       port(
            data_sel:	in std_logic_vector(5 downto 0);
            data_in:	in std_logic_vector(63 downto 0);
            data_out:		out std_logic
       );
    end component mux64;
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

    -- clock management
    signal epb_clk : std_logic;         -- connected to OPB_Clk for now

    -- OPB management
    signal DeviceAddr    : std_logic_vector(31 downto 0);  -- original address
    signal DeviceDataIn  : std_logic_vector(31 downto 0);  -- original data in bus
    signal DeviceDataOut : std_logic_vector(31 downto 0);  -- original data out bus


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

    -- data capture signals
    signal clk_p         : std_logic;
    signal clk_n         : std_logic;   
    signal sum_data    : std_logic_vector(63 downto 0);  
    signal clk_out       : std_logic;
    signal sum_out       : std_logic_vector(63 downto 0);

    --signals for opb acknowledge
    signal ackSigW         :  std_logic := '0';
    signal ackSigWZ1       :  std_logic := '0';
    signal ackSigR         :  std_logic := '0';
    signal ackSigRZ1       :  std_logic := '0';
    signal xferAck_sig     :  std_logic := '0';

    -- test signals
    signal test_port_sig : std_logic_vector(31 downto 0) := x"0000_0000";
    signal test_c_baseaddr : std_logic_vector(31 downto 0) := C_BASEADDR;
    signal test_c_highaddr : std_logic_vector(31 downto 0) := C_HIGHADDR;
    signal test_ctr        : std_logic_vector(7 downto 0)  := X"00";
    signal test_ctr_fifo   : std_logic_vector(7 downto 0)  := X"00";    
    signal C125_ds         : std_logic;                    -- for testing C125 clock     
    signal C125            : std_logic;                    -- for testing C125 clock  
    signal ROUTB_sig       : std_logic_vector(3 downto 0) := "0000";
    signal TimeCode_sig    : std_logic_vector(31 downto 0) := X"0000_0000";
        
    --C167 registers
    signal c167_reg0_sig     :std_logic_vector(7 downto 0);  --a few registers
    signal c167_reg1_sig     :std_logic_vector(7 downto 0);
    signal c167_reg2_sig     :std_logic_vector(7 downto 0);  
    signal C167_CLK_sig      :std_logic;                    --clock for those registers
    signal data_from_cpu_sig : std_logic_vector(7 downto 0);    
    signal data_to_cpu_sig   : std_logic_vector(7 downto 0);
    signal C167_RD_EN_sig    :std_logic_vector(31 downto 0); --one line goes high
    signal C167_WR_EN_sig    :std_logic_vector(31 downto 0); --one line goes high   
    
    --signals for DAC
    signal DAC_CLK_p_sig        : std_logic;
    signal DAC_CLK_n_sig        : std_logic; 
    signal DAC_IN_A_sig         : std_logic_vector(3 downto 0) := "0000"; -- for DAC A
    signal DAC_IN_B_sig         : std_logic_vector(3 downto 0) := "0000"; -- for DAC B
--    signal DAC_IN_A0_sig        :std_logic_vector(3 downto 0) := X"0";
    
    -- system-timing-related signals
    signal OnePPS               :std_logic := '0';
    signal PPS_PIC_sig          :std_logic := '0'; --FPGA-derived 1-PPS based on TE and command from CCC
    signal TE_sig               :std_logic := '0';
    signal TIME0_sig            :std_logic := '0';
    signal PPS_Maser_sig        :std_logic;  --1-PPS from Maser for sanity check of the locally generated 1-PPS from the TE
    signal PPS_GPS_sig          :std_logic;  --1-PPS from GPS for sanity check of the locally generated 1-PPS from the TE
    signal CFIFO_Z1_sig         :std_logic;  --clock used for formatting at FIFO outputs, input to BUFG
    signal CFIFO                :std_logic;  --clock used for formatting at FIFO outputs  
    signal CLKFB_sig            :std_logic;  --MMC feedback
    signal CLKFBSTOPPED_sig     :std_logic;  --clock feedback stopped test point from MMCM  
    signal CLKINSTOPPED_sig     :std_logic;  --clock input stopped test point from MMCM
    signal LOCKED_sig           :std_logic;  --clock locked test point from MMCM
    signal RST_sig              :std_logic := '0';  --MMCM reset
           
    
            
    
   
    --status signals
    signal DONE_sig             :std_logic := '0';
        



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--I/O buffers
  -- buffer for 125 MHz correlator clock
  C125_inst : IBUFGDS
  generic map (
    DIFF_TERM => TRUE, -- Differential Termination
    IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for refernced I/O standards
    IOSTANDARD => "DEFAULT")
  port map (
    O => C125_ds, -- Clock buffer output
    I => clk_in_p, -- Diff_p clock buffer input (connect directly to top-level port)
    IB => clk_in_n -- Diff_n clock buffer input (connect directly to top-level port)
  );
 
  C125_BUFG_inst : BUFG
  port map (
    O => C125,    -- 1-bit output: 125 MHz Data Clock buffer output
    I => C125_ds  -- 1-bit input: Clock buffer input
  );
 
   CFIFO_BUFG_inst : BUFG
  port map (
    O => CFIFO,        -- 1-bit output: FIFO Clock buffer output
    I => CFIFO_Z1_sig  -- 1-bit input: Clock buffer input
  );
 
  -- buffers for sum data

   sum_data_inputs: for i in 0 to 63 generate  -- connect differential buffers to signals
   begin
   
    sum_data_bufs: IBUFDS
   generic map (
      CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM => TRUE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
      IOSTANDARD => "DEFAULT")
      
   port map (
      O => sum_data(i), -- Clock buffer output
      I => sum_data_p(i), -- Diff_p clock buffer input (connect directly to top-level port)
      IB => sum_data_n(i) -- Diff_n clock buffer input (connect directly to top-level port)
   );   
   end generate sum_data_inputs;   
   
    -- Output for DAC CLK
   OBUFDS_DAC_CLK : OBUFDS
     generic map (
       IOSTANDARD => "DEFAULT")
     port map (
       O  => DAC_CLK_p_sig, -- Diff_p output (connect directly to top-level port)
       OB => DAC_CLK_n_sig, -- Diff_n output (connect directly to top-level port)
       I  => test_ctr(7) -- Buffer input
     ); 

    -- Output for DAC data; single ended so don't need to specify buffers here    

    --connect signals to ports
    DAC_CLK_p <= DAC_CLK_p_sig;
    DAC_CLK_n <= DAC_CLK_n_sig;      
    DAC_IN_A  <= DAC_IN_A_sig;
    DAC_IN_B  <= DAC_IN_B_sig;
--    DAC_IN_A0  <= DAC_IN_A0_sig;            

   -- buffer for TE signal

   
    TE_buf: IBUFDS
   generic map (
      CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM => TRUE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
      IOSTANDARD => "DEFAULT")
      
   port map (
      O => TE_sig, -- TE buffer output
      I => TE_p, -- Diff_p clock buffer input (connect directly to top-level port)
      IB => TE_n -- Diff_n clock buffer input (connect directly to top-level port)
   );  
   
   
    PIC_1PPS_BUF: OBUFDS
     generic map (
       IOSTANDARD => "DEFAULT")
     port map (
       O  => PPS_PIC_p, -- Diff_p output (connect directly to top-level port)
       OB => PPS_PIC_n, -- Diff_n output (connect directly to top-level port)
       I  => PPS_PIC_sig -- Buffer input
     ); 
     
   Maser_buf: IBUFDS
   generic map (
      CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM => TRUE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
      IOSTANDARD => "DEFAULT")
      
   port map (
      O => PPS_Maser_sig, -- TE buffer output
      I => PPS_Maser_p, -- Diff_p clock buffer input (connect directly to top-level port)
      IB => PPS_Maser_n -- Diff_n clock buffer input (connect directly to top-level port)
   );  
   
   GPS_buf: IBUFDS
   generic map (
      CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM => TRUE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
      IOSTANDARD => "DEFAULT")
      
   port map (
      O => PPS_GPS_sig, -- TE buffer output
      I => PPS_GPS_p, -- Diff_p clock buffer input (connect directly to top-level port)
      IB => PPS_GPS_n -- Diff_n clock buffer input (connect directly to top-level port)
   ); 
   
--***********************************************************************************
-- MMCM_ADV: Advanced Mixed Mode Clock Manager
-- Virtex-6
-- Xilinx HDL Libraries Guide, version 13.2
-- use to generate formatting clock CFIFO
MMCM_ADV_inst : MMCM_ADV
generic map (
BANDWIDTH => "LOW", -- Jitter programming ("HIGH","LOW","OPTIMIZED"); must use LOW when Fpfd < 135 MHz
CLKFBOUT_MULT_F => 8.0, -- Multiply value for all CLKOUT (5.0-64.0); keep as low as possible; 600 <= Fvco <= 1200 MHz
CLKFBOUT_PHASE => 0.0, -- Phase offset in degrees of CLKFB (0.00-360.00).
-- CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
CLKIN1_PERIOD => 8.000,
CLKIN2_PERIOD => 10.000,
CLKOUT0_DIVIDE_F => 7.0, -- Divide amount for CLKOUT0 (1.000-128.000).
-- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
CLKOUT0_DUTY_CYCLE => 0.5,
CLKOUT1_DUTY_CYCLE => 0.5,
CLKOUT2_DUTY_CYCLE => 0.5,
CLKOUT3_DUTY_CYCLE => 0.5,
CLKOUT4_DUTY_CYCLE => 0.5,
CLKOUT5_DUTY_CYCLE => 0.5,
CLKOUT6_DUTY_CYCLE => 0.5,
-- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
CLKOUT0_PHASE => 0.0,
CLKOUT1_PHASE => 0.0,
CLKOUT2_PHASE => 0.0,
CLKOUT3_PHASE => 0.0,
CLKOUT4_PHASE => 0.0,
CLKOUT5_PHASE => 0.0,
CLKOUT6_PHASE => 0.0,
-- CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
CLKOUT1_DIVIDE => 128,
CLKOUT2_DIVIDE => 128,
CLKOUT3_DIVIDE => 128,
CLKOUT4_DIVIDE => 128,
CLKOUT5_DIVIDE => 128,
CLKOUT6_DIVIDE => 128,
CLKOUT4_CASCADE => FALSE, -- Cascase CLKOUT4 counter with CLKOUT6 (TRUE/FALSE)
CLOCK_HOLD => FALSE, -- Hold VCO Frequency (TRUE/FALSE)
COMPENSATION => "ZHOLD", -- "ZHOLD", "INTERNAL", "EXTERNAL", "CASCADE" or "BUF_IN"
DIVCLK_DIVIDE => 1, -- Master division value (1-80); keep as low as possible
-- REF_JITTER: Reference input jitter in UI (0.000-0.999).
REF_JITTER1 => 0.100,
REF_JITTER2 => 0.100,
STARTUP_WAIT => FALSE, -- Not supported. Must be set to FALSE.
-- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
CLKFBOUT_USE_FINE_PS => FALSE,
CLKOUT0_USE_FINE_PS => FALSE,
CLKOUT1_USE_FINE_PS => FALSE,
CLKOUT2_USE_FINE_PS => FALSE,
CLKOUT3_USE_FINE_PS => FALSE,
CLKOUT4_USE_FINE_PS => FALSE,
CLKOUT5_USE_FINE_PS => FALSE,
CLKOUT6_USE_FINE_PS => FALSE
)
port map (
-- Clock Outputs: 1-bit (each) output: User configurable clock outputs
CLKOUT0 => CFIFO_Z1_sig, -- 1-bit output: CLKOUT0 output
CLKOUT0B => OPEN, -- 1-bit output: Inverted CLKOUT0 output
CLKOUT1 => OPEN, -- 1-bit output: CLKOUT1 output
CLKOUT1B => OPEN, -- 1-bit output: Inverted CLKOUT1 output
CLKOUT2 => OPEN, -- 1-bit output: CLKOUT2 output
CLKOUT2B => OPEN, -- 1-bit output: Inverted CLKOUT2 output
CLKOUT3 => OPEN, -- 1-bit output: CLKOUT3 output
CLKOUT3B => OPEN, -- 1-bit output: Inverted CLKOUT3 output
CLKOUT4 => OPEN, -- 1-bit output: CLKOUT4 output
CLKOUT5 => OPEN, -- 1-bit output: CLKOUT5 output
CLKOUT6 => OPEN, -- 1-bit output: CLKOUT6 output
-- DRP Ports: 16-bit (each) output: Dynamic reconfigration ports
DO => OPEN, -- 16-bit output: DRP data output
DRDY => OPEN, -- 1-bit output: DRP ready output
-- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
PSDONE => OPEN, -- 1-bit output: Phase shift done output
-- Feedback Clocks: 1-bit (each) output: Clock feedback ports
CLKFBOUT => CLKFB_sig, -- 1-bit output: Feedback clock output
CLKFBOUTB => OPEN, -- 1-bit output: Inverted CLKFBOUT
-- Status Ports: 1-bit (each) output: MMCM status ports
CLKFBSTOPPED => CLKFBSTOPPED_sig, -- 1-bit output: Feedback clock stopped output
CLKINSTOPPED => CLKINSTOPPED_sig, -- 1-bit output: Input clock stopped output
LOCKED => LOCKED_sig, -- 1-bit output: LOCK output
-- Clock Inputs: 1-bit (each) input: Clock inputs
CLKIN1 => adc_clk, -- 1-bit input: Primary clock input
CLKIN2 => C125, -- 1-bit input: Secondary clock input
-- Control Ports: 1-bit (each) input: MMCM control ports
CLKINSEL => '1', -- 1-bit input: Clock select input
PWRDWN => '0', -- 1-bit input: Power-down input
RST => RST_sig, -- 1-bit input: Reset input
-- DRP Ports: 7-bit (each) input: Dynamic reconfigration ports
DADDR => "0000000", -- 7-bit input: DRP adrress input
DCLK => '0', -- 1-bit input: DRP clock input
DEN => '0', -- 1-bit input: DRP enable input
DI => X"0000", -- 16-bit input: DRP data input
DWE => '0', -- 1-bit input: DRP write enable input
-- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
PSCLK => '0', -- 1-bit input: Phase shift clock input
PSEN => '0', -- 1-bit input: Phase shift enable input
PSINCDEC => '0', -- 1-bit input: Phase shift increment/decrement input
-- Feedback Clocks: 1-bit (each) input: Clock feedback ports
CLKFBIN => CLKFB_sig -- 1-bit input: Feedback clock input
);
-- End of MMCM_ADV_inst instantiation

--***********************************************************************************        

  -- connect test ports
  test_port_sig <= test_port_in0;  
  test_port_out <= test_port_sig;
  ROUTB         <= ROUTB_sig;
   
  --connect misc signals
  DONE           <= DONE_sig;          
  


  -- C167 connections
  CD_T <=  NOT RnW;
  
       
  -- connect clocks
  epb_clk <= OPB_Clk;
  clk_p <= clk_in_p;
  clk_n <= clk_in_n;



  -- connect OPB signals
  DeviceAddr(31 downto 0)       <= OPB_ABus(0 to 31);  --take care of the bit reversals in the OPB data bus
  DeviceDataIn(31 downto 0)     <= OPB_DBus(0 to 31);  
  
 
  Sl_errAck        <= '0';
  Sl_retry         <= '0';
  Sl_toutSup       <= '0';

  --generate opb acknowledge signal
  --Sl_xferAck <= (ackSigR AND NOT ackSigRZ1) OR (ackSigW AND NOT ackSigWZ1);
  --xferAck_sig <= ackSigR OR ackSigW;
  
  --connect DAC signals
  

  -- EPB register access process
    RegisterAccess : process(OPB_Rst, epb_clk, OPB_select,
                            OPB_RNW, DeviceAddr(18 downto 0))

    begin

    if (OPB_Rst = '1') then
        TimeAlign(15 downto 0) <= x"0000";
        SyncWord <= x"ACABFEED";
        Legacy <= '0';
        selInput <= x"F";       -- bottom 4 channels on
        log2numchan <= "00010"; -- 4 channels total default
--        test_port_sig <= x"00000000";
    elsif rising_edge(epb_clk) then
    
--        if (test_port_sig = x"FFFFFFFF") then
--          test_port_sig <= x"00000000";
--       else
--          test_port_sig <= test_port_sig + 1;  
--        end if;

        ackSigWZ1 <= ackSigW;
        ackSigRZ1 <= ackSigR;
        
        xferAck_sig <= '0';
        DeviceDataOut <= x"00000000";
        Sl_xferAck <= xferAck_sig;
        
        Sl_DBus(0 to 31)<= DeviceDataOut ;
                  
        if (OPB_select = '1') AND (xferAck_sig = '0') AND
            (DeviceAddr <= C_HIGHADDR) AND
            (DeviceAddr >= C_BASEADDR) then
          
          xferAck_sig <= '1';

          if (OPB_RNW = '0') then

            case (DeviceAddr(7 downto 2)) is

            when "000000" => SyncWord <= DeviceDataIn;       --0x000
--            when x"000" => SyncWord(15 downto 0) <= DeviceDataIn;       --0x000
--            when x"001" => SyncWord(31 downto 16) <= DeviceDataIn;      --0x002
--            when x"002" => RefEpoch <= DeviceDataIn(7 downto 0);        --0x004
--            when x"003" => Legacy <= DeviceDataIn(0);                   --0x006
--            when x"004" => StationID <= DeviceDataIn;                   --0x008
--            when x"005" => DBEnum <= DeviceDataIn(3 downto 0);          --0x00A
--            when x"006" => TestMode <= DeviceDataIn(0);                 --0x00C
--            when x"00A" => TimeSlot1On(15 downto 0) <= DeviceDataIn;    --0x014
--            when x"00B" => TimeSlot1On(31 downto 16) <= DeviceDataIn;   --0x016
--            when x"00C" => TimeSlot1Off(15 downto 0) <= DeviceDataIn;   --0x018
--            when x"00D" => TimeSlot1Off(31 downto 16) <= DeviceDataIn;  --0x01A
--            when x"00E" => TimeAlign <= DeviceDataIn;                   --0x01C
--            when x"00F" => selInput <= DeviceDataIn(3 downto 0);        --0x01E

--            when x"010" => log2numchan <= DeviceDataIn(4 downto 0);     --0x020

--            when x"080" => LOIFftwA(0)(15 downto  0) <= DeviceDataIn;   --0x100
--            when x"081" => LOIFftwA(0)(31 downto 16) <= DeviceDataIn;   --0x102
--            when x"082" => LOIFftwA(1)(15 downto  0) <= DeviceDataIn;   --0x104
--            when x"083" => LOIFftwA(1)(31 downto 16) <= DeviceDataIn;   --0x106
--            when x"084" => LOIFftwA(2)(15 downto  0) <= DeviceDataIn;   --0x108
--            when x"085" => LOIFftwA(2)(31 downto 16) <= DeviceDataIn;   --0x10A
--            when x"086" => LOIFftwA(3)(15 downto  0) <= DeviceDataIn;   --0x10C
--            when x"087" => LOIFftwA(3)(31 downto 16) <= DeviceDataIn;   --0x10E
--            when x"088" => LOIFftwA(4)(15 downto  0) <= DeviceDataIn;   --0x110
--            when x"089" => LOIFftwA(4)(31 downto 16) <= DeviceDataIn;   --0x112
--            when x"08A" => LOIFftwA(5)(15 downto  0) <= DeviceDataIn;   --0x114
--            when x"08B" => LOIFftwA(5)(31 downto 16) <= DeviceDataIn;   --0x116
--            when x"08C" => LOIFftwA(6)(15 downto  0) <= DeviceDataIn;   --0x118
--            when x"08D" => LOIFftwA(6)(31 downto 16) <= DeviceDataIn;   --0x11A
--            when x"08E" => LOIFftwA(7)(15 downto  0) <= DeviceDataIn;   --0x11C
--            when x"08F" => LOIFftwA(7)(31 downto 16) <= DeviceDataIn;   --0x11E

--            when x"090" => SampleRateA(0)(15 downto 0) <= DeviceDataIn; --0x120
--            when x"091" => SampleRateA(0)(23 downto 16) <=
--                                            DeviceDataIn(7 downto 0);   --0x122
--            when x"092" => SampleRateA(1)(15 downto 0) <= DeviceDataIn; --0x124
--            when x"093" => SampleRateA(1)(23 downto 16) <=
--                                            DeviceDataIn(7 downto 0);   --0x126
--            when x"094" => SampleRateA(2)(15 downto 0) <= DeviceDataIn; --0x128
--            when x"095" => SampleRateA(2)(23 downto 16) <=
--                                            DeviceDataIn(7 downto 0);   --0x12A
--            when x"096" => SampleRateA(3)(15 downto 0) <= DeviceDataIn; --0x12C
--            when x"097" => SampleRateA(3)(23 downto 16) <=
--                                            DeviceDataIn(7 downto 0);   --0x12E
--            when x"098" => SampleRateA(4)(15 downto 0) <= DeviceDataIn; --0x130
--            when x"099" => SampleRateA(4)(23 downto 16) <=
--                                            DeviceDataIn(7 downto 0);   --0x132
--            when x"09A" => SampleRateA(5)(15 downto 0) <= DeviceDataIn; --0x134
--            when x"09B" => SampleRateA(5)(23 downto 16) <=
--                                            DeviceDataIn(7 downto 0);   --0x136
--            when x"09C" => SampleRateA(6)(15 downto 0) <= DeviceDataIn; --0x138
--            when x"09D" => SampleRateA(6)(23 downto 16) <=
--                                            DeviceDataIn(7 downto 0);   --0x13A
--            when x"09E" => SampleRateA(7)(15 downto 0) <= DeviceDataIn; --0x13C
--            when x"09F" => SampleRateA(7)(23 downto 16) <=
  --                                          DeviceDataIn(7 downto 0);   --0x13E

--            when x"0A0" => Bits_SampA(0) <= DeviceDataIn(4 downto 0);
--                           Bits_SampA(1) <= DeviceDataIn(12 downto 8);  --0x140
--            when x"0A1" => Bits_SampA(2) <= DeviceDataIn(4 downto 0);
--                           Bits_SampA(3) <= DeviceDataIn(12 downto 8);  --0x142
--            when x"0A2" => Bits_SampA(4) <= DeviceDataIn(4 downto 0);
--                           Bits_SampA(5) <= DeviceDataIn(12 downto 8);  --0x144
--            when x"0A3" => Bits_SampA(6) <= DeviceDataIn(4 downto 0);
--                           Bits_SampA(7) <= DeviceDataIn(12 downto 8);  --0x146
--            when x"0A4" => IFnumA(3) <= DeviceDataIn(15 downto 12);
--                           IFnumA(2) <= DeviceDataIn(11 downto 8);
--                           IFnumA(1) <= DeviceDataIn(7 downto 4);
--                           IFnumA(0) <= DeviceDataIn(3 downto 0);       --0x148
--            when x"0A5" => IFnumA(7) <= DeviceDataIn(15 downto 12);
--                           IFnumA(6) <= DeviceDataIn(11 downto 8);
--                           IFnumA(5) <= DeviceDataIn(7 downto 4);
--                           IFnumA(4) <= DeviceDataIn(3 downto 0);       --0x14A
--            when x"0A6" => SubBandA(3) <= DeviceDataIn(15 downto 12);
--                           SubBandA(2) <= DeviceDataIn(11 downto 8);
--                           SubBandA(1) <= DeviceDataIn(7 downto 4);
--                           SubBandA(0) <= DeviceDataIn(3 downto 0);     --0x14C
--            when x"0A7" => SubBandA(7) <= DeviceDataIn(15 downto 12);
--                           SubBandA(6) <= DeviceDataIn(11 downto 8);
--                           SubBandA(5) <= DeviceDataIn(7 downto 4);
--                           SubBandA(4) <= DeviceDataIn(3 downto 0);     --0x14E
--
--            when x"100" => ComplexFlags <= DeviceDataIn(7 downto 0);    --0x200
--            when x"101" => ESideBand    <= DeviceDataIn(7 downto 0);    --0x202
--
--            when x"105" => EpochSecSet(15 downto 0) <= DeviceDataIn;   --0x210
--            when x"106" => EpochSecSet(29 downto 16) <=
--                                            DeviceDataIn(13 downto 0);  --0x212
              when others => null;
            end case;
            
          else
 
            case (DeviceAddr(7 downto 2)) is
            when "000000" => DeviceDataOut <= SyncWord;      --0x0000
            when "000001" => DeviceDataOut <= x"000001" & c167_reg0_sig;      --0x0004
            when "000010" => DeviceDataOut <= x"000002" & c167_reg1_sig;      --0x0008
            when "000011" => DeviceDataOut <= x"000003" & c167_reg2_sig;      --0x00012
--            when x"000" => DeviceDataOut <= SyncWord(15 downto 0);      --0x0000
--            when x"001" => DeviceDataOut <= SyncWord(31 downto 16);     --0x0002
--            when x"002" => DeviceDataOut <= x"00" & RefEpoch;           --0x0004
--            when x"003" => DeviceDataOut <= x"000" & "000" & Legacy;    --0x0006
--            when x"004" => DeviceDataOut <= TimeSlot1Off(31 downto 16); --0x001A
--            when x"00E" => DeviceDataOut <= TimeAlign;                  --0x001C
--            when x"00F" => DeviceDataOut <= prog_full & x"0" & selInput;--0x001E

--            when x"010" => DeviceDataOut <= x"00"&"000"&log2numchan;    --0x0020

            -- fill in the individual channel header blocks
--            when x"080" => DeviceDataOut <= LOIFftwA(0)(15 downto  0);  --0x0100
--            when x"081" => DeviceDataOut <= LOIFftwA(0)(31 downto 16);  --0x0102
--            when x"082" => DeviceDataOut <= LOIFftwA(1)(15 downto  0);  --0x0104
--            when x"083" => DeviceDataOut <= LOIFftwA(1)(31 downto 16);  --0x0106
--            when x"084" => DeviceDataOut <= LOIFftwA(2)(15 downto  0);  --0x0108
--            when x"085" => DeviceDataOut <= LOIFftwA(2)(31 downto 16);  --0x010A
--            when x"086" => DeviceDataOut <= LOIFftwA(3)(15 downto  0);  --0x010C
--            when x"087" => DeviceDataOut <= LOIFftwA(3)(31 downto 16);  --0x010E
--            when x"088" => DeviceDataOut <= LOIFftwA(4)(15 downto  0);  --0x0110
--            when x"089" => DeviceDataOut <= LOIFftwA(4)(31 downto 16);  --0x0112
--            when x"08A" => DeviceDataOut <= LOIFftwA(5)(15 downto  0);  --0x0114
--            when x"08B" => DeviceDataOut <= LOIFftwA(5)(31 downto 16);  --0x0116
--            when x"08C" => DeviceDataOut <= LOIFftwA(6)(15 downto  0);  --0x0118
--            when x"08D" => DeviceDataOut <= LOIFftwA(6)(31 downto 16);  --0x011A
--            when x"08E" => DeviceDataOut <= LOIFftwA(7)(15 downto  0);  --0x011C
--            when x"08F" => DeviceDataOut <= LOIFftwA(7)(31 downto 16);  --0x011E

--            when x"090" => DeviceDataOut <=          SampleRateA(0)(15 downto 0);  --0x0120
--            when x"091" => DeviceDataOut <= x"00" & SampleRateA(0)(23 downto 16);  --0x0122
--            when x"092" => DeviceDataOut <=          SampleRateA(1)(15 downto 0);  --0x0124
--            when x"093" => DeviceDataOut <= x"00" & SampleRateA(1)(23 downto 16);  --0x0126
--            when x"094" => DeviceDataOut <=          SampleRateA(2)(15 downto 0);  --0x0128
--            when x"095" => DeviceDataOut <= x"00" & SampleRateA(2)(23 downto 16);  --0x012A
--            when x"096" => DeviceDataOut <=          SampleRateA(3)(15 downto 0);  --0x012C
--            when x"097" => DeviceDataOut <= x"00" & SampleRateA(3)(23 downto 16);  --0x012E
--            when x"098" => DeviceDataOut <=          SampleRateA(4)(15 downto 0);  --0x0130
--            when x"099" => DeviceDataOut <= x"00" & SampleRateA(4)(23 downto 16);  --0x0132
--            when x"09A" => DeviceDataOut <=          SampleRateA(5)(15 downto 0);  --0x0134
--            when x"09B" => DeviceDataOut <= x"00" & SampleRateA(5)(23 downto 16);  --0x0136
--            when x"09C" => DeviceDataOut <=          SampleRateA(6)(15 downto 0);  --0x0138
--            when x"09D" => DeviceDataOut <= x"00" & SampleRateA(6)(23 downto 16);  --0x013A
--            when x"09E" => DeviceDataOut <=          SampleRateA(7)(15 downto 0);  --0x013C
--            when x"09F" => DeviceDataOut <= x"00" & SampleRateA(7)(23 downto 16);  --0x013E

--            when x"0A0" => DeviceDataOut <= "000" & Bits_SampA(1) &
--                                            "000" & Bits_SampA(0);  --0x0140
--            when x"0A1" => DeviceDataOut <= "000" & Bits_SampA(3) &
--                                            "000" & Bits_SampA(2);  --0x0142
--            when x"0A2" => DeviceDataOut <= "000" & Bits_SampA(5) &
--                                            "000" & Bits_SampA(4);  --0x0144
--            when x"0A3" => DeviceDataOut <= "000" & Bits_SampA(7) &
--                                            "000" & Bits_SampA(6);  --0x0146
--            when x"0A4" => DeviceDataOut <= IFnumA(3) & IFnumA(2) &
--                                            IFnumA(1) & IFnumA(0);  --0x0148
--            when x"0A5" => DeviceDataOut <= IFnumA(7) & IFnumA(6) &
--                                            IFnumA(5) & IFnumA(4);  --0x014A
--            when x"0A6" => DeviceDataOut <= SubBandA(3) & SubBandA(2) &
--                                            SubBandA(1) & SubBandA(0);  --0x014C
--            when x"0A7" => DeviceDataOut <= SubBandA(7) & SubBandA(6) &
--                                            SubBandA(5) & SubBandA(4);  --0x014E

--            when x"100" => DeviceDataOut <= x"00" & ComplexFlags;   --0x0200
--            when x"101" => DeviceDataOut <= x"00" & ESideBand;      --0x0202
--            when x"105" => DeviceDataOut <= EpochSeconds(15 downto 0);  --0x0210
--            when x"106" => DeviceDataOut <= "00" & EpochSeconds(29 downto 16); --0x0212

            when others => DeviceDataOut <= (others => '0');
            end case;

         end if;
         
      end if;

    end if;

    end process RegisterAccess;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    -- build a status vector
--    status <= std_logic_vector(to_unsigned(vdifChCntr'pos(ccCntrState),8))
--                & "00" & FifoError & ValidFlag_epb
--                & std_logic_vector(to_unsigned(currCh,4));


-------------------------------------------------------------------------------
    -- wait for time to start.
    -- TimeCode is clocked with onePPS
    -- ValidFlag indicates in test time
    valid_proc: process(TimeCode_sig, DTMOnReg, DTMOffReg, epb_clk)
    begin
        if (TimeCode_sig >= DTMOnReg and TimeCode_sig < DTMOffReg) then
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
    dtm_proc:  process(DTMOnReg, ValidFlag_epb, TimeCode_sig, DTMOffReg)
    begin
        if (DTMOnReg = X"00000000") then
            DTMStatus   <= ValidFlag_epb & "00";    --ready (init)
        elsif (TimeCode_sig < DTMOnReg) then
            DTMStatus <= ValidFlag_epb & "10";      --waiting
        elsif (TimeCode_sig < DTMOffReg) then
            DTMStatus <= ValidFlag_epb & "01";      --transmitting
        else --if (TimeCode_sig >= DTMOffReg) then
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
    ppssys : process(OPB_Rst, OPB_Clk)
    begin
        if OPB_Rst = '1' then
            pps_sys <= '1';
            pps2 <= '0';
            pps3 <= '1';
        elsif rising_edge(OPB_Clk) then
            pps2 <= pps1;
            pps3 <= NOT pps2;
            pps_sys <= pps2 AND pps3;
        end if;
    end process;

    -- for test mode
    testmd : process(OPB_Clk)
    begin
        if rising_edge(OPB_Clk) then
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
--                if (DataRdy(0) = '1') then    ##comment out to get rid of DataRdy port; eventually this whole process will disappear
                if (ackSigW = '1') then
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
    fctr : process(OPB_Clk)
    begin
        if rising_edge(OPB_Clk) then
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
    chcntr : process(OPB_Clk)
    begin
        if rising_edge(OPB_Clk) then
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
    epochcnt : process(OPB_Rst, OPB_Clk)
    begin
        if (OPB_Rst = '1') then
            EpochSeconds <= (others => '0');
        elsif rising_edge(OPB_Clk) then
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
    -- change clock domains to OPB_Clk
    syncsys : process(OPB_Clk)
    begin
        if rising_edge(OPB_Clk) then
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
    syncadc : process(OPB_Rst, adc_clk)
    begin
        if OPB_Rst = '1' then
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
--  selIn    : for i in 0 to nch-1 generate
--    chSel   : vdif_input_sel
--    port map(
--        wrClk       =>  adc_clk,        --: in std_logic;
--        rdClk       =>  OPB_Clk,        --: in std_logic;
--        reset       =>  OPB_Rst,            --: in std_logic;
--        valid       =>  ValidA(i),      --: in std_logic;
--        dataRdy     =>  DataRdy(i),     --: in std_logic;
--        rdFifoEna   =>  rdFifoEna(i),   --: in std_logic;
--        cplxFlg     =>  ComplexFlags(i),--: in std_logic;
--        numBit      =>  Bits_SampA(i),  --: in std_logic_vector(4 downto 0);

--        data_in     =>  dataIn(i*16+15 downto i*16),      --: in std_logic_vector(15 downto 0);

--        full        =>  full(i),        --: out std_logic
--        prog_full   =>  prog_full(i),   --: out std_logic;
--        data_out    =>  data_out(i)     --: out std_logic_vector(63 downto 0)
--    );
--    end generate;

    ckff: process(OPB_Clk, full, ValidFlag_sys)
    begin
        if rising_edge(OPB_Clk) then
            if full /= x"0" then        -- compile for 4 channels
                FifoError <= '1';       -- latch for duration of test
            elsif ValidFlag_sys = '0' then
                FifoError <= '0';       -- clear once this test is over
            end if;
        end if;
    end process;

-------------------------------------------------------------------------------
--Formatter
--CurrData <= data_out(currCh);

    --format a single channel when FifoRdy says there are 625 words in fifo
--    fmt_ch : vdif_formatter
--        port map
--        (
--            Clk         =>  OPB_Clk,            --: in std_logic;
--            Grs         =>  OPB_Rst,                --: in std_logic;
--            MstrEna     =>  FmtrEna,            --: in std_logic;
--            Header      =>  HdrBlk,             --: in vdifHdr;
--            FifoData    =>  CurrData,           --: in slvector(63 downto 0);

--            FifoEna             => FifoEna,     --: out std_logic;
--            To10GbeTxData       => To10GbeTxData,   --: out slv(63 downto 0);
--            To10GbeTxDataValid  => To10GbeTxDataValid,  --: out std_logic;
--            To10GbeTxEOF        => To10GbeTxEOF --: out std_logic
--       );


-------------------------------------------------------------------------------
--Data capture

--    --synchronously capture incoming differential data
--    data_capt : vdif_data
--      generic map (
--        SAMPLES_IN => 32)
--      port map
--      (
--        clk_p      => clk_p,
--        clk_n      => clk_n,
--        sum_data_p => sum_data_p,
--        sum_data_n => sum_data_n,
--        clk_out    => clk_out,
--        data_out   => sum_out
--        );


-------------------------------------------------------------------------------
--C167 Interface

  c167 : c167_interface
  	     port map (
		   uclk	       =>  uCLK0,     				-- processor clock 
		   read_write  => RnW, 				-- read and write selection, read_write='1' => read, '0' => write
		   ctrl_data	 => CTRL_DATA,			-- control data selector, ctr_data='1' => control, '0' => data 
		   c167_data_I => CD_I, 	-- bus connection with the c167, bidirectional
		   c167_data_O => CD_O, 	-- bus connection with the c167, bidirectional
		   data_from_cpu => data_from_cpu_sig,	-- data_from_CPU, must be used together with C167_WR_EN(X) being 0<=X<=31
--		   data_to_cpu => SyncWord(7 downto 0), 		-- data_to_CPU, must be used together with C167_RR_EN(X) being 0<=X<=31
		   data_to_cpu => data_to_cpu_sig, 		-- data_to_CPU, must be used together with C167_RR_EN(X) being 0<=X<=31		   
		   C167_RD_EN => C167_RD_EN_sig,			-- Read enable signals, they must be individually connected to the tri-state controller associated to teh desired signals
		   C167_WR_EN	=> C167_Wr_EN_sig,	-- Write enable signals, they must be individually connected to the "clock enable" associated to the addressed register.
		   C167_CLK	=> C167_CLK_sig				-- C167 clock signal, the first 4 clocks were removed.
	);
	
	--process for testing C167 interface
	test_C167: process(C167_CLK_sig, C167_RD_EN_sig)
	begin
	

   	case (C167_RD_EN_sig) is
        when X"00000001" => data_to_cpu_sig <= c167_reg0_sig;     
        when X"00000002" => data_to_cpu_sig <= c167_reg1_sig;     
        when X"00000004" => data_to_cpu_sig <= c167_reg2_sig;
        when others  => data_to_cpu_sig <= (others => '0');  
    end case;       
    

	   if rising_edge(C167_CLK_sig) then
   	   case (C167_WR_EN_sig) is
          when X"0000_0001" => c167_reg0_sig <= data_from_cpu_sig;     
          when X"0000_0002" => c167_reg1_sig <= data_from_cpu_sig;   
          when X"0000_0004" => c167_reg2_sig <= data_from_cpu_sig;
          when others  => null;  
       end case;
        
--       if(C167_WR_EN_sig > 0) then
--          test_port_sig(7 downto 0) <= test_port_sig(7 downto 0) + 1;      
--       end if;

--       if(C167_RD_EN_sig > 0) then
--          test_port_sig(15 downto 8) <= test_port_sig(15 downto 8) + 1;
--       end if;
        
--       test_port_sig(31 downto 16) <= test_port_sig(31 downto 16) + 1;
     end if;    
                                 
	end process;
	
	-------------------------------------------------------------------------------
--mux64 for ROACHTP0

  mux_rtp0 : mux64
  	     port map (
            data_sel => test_port_in0(5 downto 0),
            data_in(0)  => test_ctr(7),
            data_in(1) => CLKFBSTOPPED_sig,
            data_in(2) => CLKINSTOPPED_sig,
            data_in(3) => LOCKED_sig,
            data_in(4) => c167_reg0_sig(0),
            data_in(5) => c167_reg0_sig(1),
            data_in(6) => c167_reg0_sig(2),
            data_in(7) => c167_reg0_sig(3),
            data_in(8) => c167_reg0_sig(4),
            data_in(9) => c167_reg0_sig(5),
            data_in(10) => c167_reg0_sig(6),
            data_in(11) => c167_reg0_sig(7),
            data_in(63 downto 12) => (others => '0'),
            data_out => ROACHTP(0)	     
  	     );
  	     
--mux64 for ROACHTP1

  mux_rtp1 : mux64
  	     port map (
            data_sel => test_port_in0(13 downto 8),
            data_in(0) => test_ctr_fifo(7),
            data_in(1) => sum_data(1),
            data_in(2) => sum_data(2),
            data_in(3) => sum_data(3),
            data_in(4) => sum_data(4),
            data_in(5) => sum_data(5),
            data_in(6) => sum_data(6),
            data_in(7) => sum_data(7),
            data_in(8) => sum_data(8),
            data_in(9) => sum_data(9),
            data_in(10) => sum_data(10),
            data_in(11) => sum_data(11),
            data_in(12) => sum_data(12),
            data_in(13) => sum_data(13),
            data_in(14) => sum_data(14),
            data_in(15) => sum_data(15),
            data_in(16) => sum_data(16),
            data_in(17) => sum_data(17),
            data_in(18) => sum_data(18),
            data_in(19) => sum_data(19),
            data_in(20) => sum_data(20),
            data_in(21) => sum_data(21),
            data_in(22) => sum_data(22),
            data_in(23) => sum_data(23),
            data_in(24) => sum_data(24),
            data_in(25) => sum_data(25),
            data_in(26) => sum_data(26),
            data_in(27) => sum_data(27),
            data_in(28) => sum_data(28),
            data_in(29) => sum_data(29),
            data_in(30) => sum_data(30),
            data_in(31) => sum_data(31),
            data_in(32) => sum_data(32),
            data_in(33) => sum_data(33),
            data_in(34) => sum_data(34),
            data_in(35) => sum_data(35),
            data_in(36) => sum_data(36),
            data_in(37) => sum_data(37),
            data_in(38) => sum_data(38),
            data_in(39) => sum_data(39),
            data_in(40) => sum_data(40),
            data_in(41) => sum_data(41),
            data_in(42) => sum_data(42),
            data_in(43) => sum_data(43),
            data_in(44) => sum_data(44),
            data_in(45) => sum_data(45),
            data_in(46) => sum_data(46),
            data_in(47) => sum_data(47),
            data_in(48) => sum_data(48),
            data_in(49) => sum_data(49),
            data_in(50) => sum_data(50),
            data_in(51) => sum_data(51),
            data_in(52) => sum_data(52),
            data_in(53) => sum_data(53),
            data_in(54) => sum_data(54),
            data_in(55) => sum_data(55),
            data_in(56) => sum_data(56),
            data_in(57) => sum_data(57),
            data_in(58) => sum_data(58),
            data_in(59) => sum_data(59),
            data_in(60) => sum_data(60),
            data_in(61) => sum_data(61),
            data_in(62) => sum_data(62),
            data_in(63) => sum_data(63),
            
--            data_in(63 downto 8) => (others => '0'),
            data_out => ROACHTP(1)
  	     );  	     
	
--process for generating test frequencies
get_tst_freq: process(C125)
	begin
	  if(rising_edge(adc_clk)) then
	     test_ctr <= test_ctr + 1;
	  end if;
	end process;	
	
	--process for generating test frequencies
get_tst_freq2: process(CFIFO)
	begin
	  if(rising_edge(CFIFO)) then
	     test_ctr_fifo <= test_ctr_fifo + 1;
	  end if;
	end process;	
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
end architecture vdif_arch;
