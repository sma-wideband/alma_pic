library ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.rdbe_pkg.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-- # $Id: opb_vdif_interface.vhd,v 1.4 2014/01/31 21:09:14 rlacasse Exp $

entity opb_vdif_interface is
  generic ( 

    -- Bus protocol parameters
    C_BASEADDR : std_logic_vector := X"00010000";
    C_HIGHADDR : std_logic_vector := X"0001FFFF";
    C_OPB_AWIDTH : integer := 32;
    C_OPB_DWIDTH : integer := 32;
    C_FAMILY : string := "virtex5";

    -- other parameters
    REV_MAJOR_INT   :   std_logic_vector(7 downto 0) := x"01";   -- major revision, integer part
    REV_MAJOR_FRAC  :   std_logic_vector(7 downto 0) := x"00";   -- major revision, fractional part
    P_TYPE          :   std_logic_vector(7 downto 0) := x"83";   -- personality type
    ADDRHI      : std_logic_vector(23 downto 0) := X"000000";
    nch         : integer range 0 to 7 := 4;      -- number of channels synthesized
    REG12_LGTH  : integer := 40
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
      CD_I      : in std_logic_vector(7 downto 0); -- uP bus
      CD_O      : out std_logic_vector(7 downto 0); -- uP bus
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
      AUXTIME_p       : in std_logic;   --an extram time signal distributed with the TE; not used, but an FPGA interface in included
      AUXTIME_n       : in std_logic;      
      TIME0           : out std_logic;  --the 1 msec TE signal to the microprocessor interrupt
      TIME1           : out std_logic;  --the 48 msec TE signal to the microprocessor interrupt      
      DONE            : out std_logic;  --signal to indicate to microprocessor that FPGA is programmed.  Drive high      
      DLL             : out std_logic;  --signal to indicate that DLL is locked.  Eventually tie to MMCM.  For now tie high      
--      DataRdy         : in std_logic_vector(nch-1 downto 0);
--      TimeCode        : in std_logic_vector(31 downto 0);
--      dataIn          : in std_logic_vector(63 downto 0);  --data for VLBA; need to delete sometime

      -- ten GbE ports
      To10GbeTxData   : out std_logic_vector(63 downto 0);
      To10GbeTxDataValid  : out std_logic;
      To10GbeTxEOF    : out std_logic;
      To10Gbe_CFIFO   : out std_logic; --10GbE needs fifo clock to be in sync
      
      --DAC ports
      DAC_CLK_p       : out std_logic;
      DAC_CLK_n       : out std_logic;
      DAC_IN_A        : out std_logic_vector(3 downto 0);      
      DAC_IN_B        : out std_logic_vector(3 downto 0);
--      DAC_IN_A0       : out std_logic_vector(3 downto 0);  --test to try to get DAC data bits working
      
      -- test ports
      test_port_out   : out std_logic_vector(31 downto 0);  --I/O to PPC registers
      test_port_in0   : in  std_logic_vector(31 downto 0);  --I/O to PPC registers
      test_port_in1   : in  std_logic_vector(31 downto 0);  --I/O to PPC registers                
      ROACHTP         : out std_logic_vector(1 downto 0);
      ROUTB           : out std_logic_vector(3 downto 0)  --test points to JR1           
      
    );
end entity opb_vdif_interface;

architecture vdif_arch OF opb_vdif_interface
is
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- the two components below are from the VLBA design; they are commented out for now and should eventually be deleted
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
		   data_from_cpu	: out std_logic_vector (7 downto 0); -- data_from_CPU, must be used together with C167_WE and C167_ADDR
		   data_to_cpu		: in std_logic_vector (7 downto 0);	-- data_to_CPU, must be used together with C167_ADDR
--		   C167_RD_EN			: out std_logic_vector (31 downto 0);	-- Read enable signals, they must be individually connected to the tri-state controller associated with desired signals
--		   C167_WR_EN		  : out std_logic_vector (31 downto 0);	-- Write enable signals, they must be individually connected to the "clock enable" associated to the addressed register.
	     C167_WE        : out std_logic;                    -- new write enable signal
	     C167_ADDR      : out std_logic_vector(7 downto 0); -- new address bus		   
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
    
    component treg8
       port(
          D:    in  std_logic_vector(7 downto 0);
          Q:    out std_logic_vector(7 downto 0) := "00000000";
          CE: in  std_logic;
          CK: in  std_logic
       );
    end component treg8;
    
    component data_interface  --has input data checking, statistics, test_data generator and data select
       port(  
          sum_data   : in std_logic_vector(63 downto 0); --sum data
          C125       : in std_logic; --clock from timing generator
          Grs        : in std_logic;
          chan       : in std_logic_vector(5 downto 0);
          stat_msec  : in std_logic_vector(6 downto 0);
          prn_run    : in std_logic;
          stat_start : in std_logic;
          OneMsec    : in std_logic;
          ecnt       : out std_logic_vector(7 downto 0);
          stat_p3    : out std_logic_vector(23 downto 0);
          stat_p1    : out std_logic_vector(23 downto 0);
          stat_m1    : out std_logic_vector(23 downto 0);
          stat_m3    : out std_logic_vector(23 downto 0);
          stat_rdy   : out std_logic;
          td_sel     : in std_logic_vector(2 downto 0);
          frm_sync   : in std_logic;
          td_out     : out std_logic_vector(63 downto 0);
          data_sel   : in std_logic;
          sum_di     : out std_logic_vector(63 downto 0)
       );
    end component;    
    
    component timing_generator  -- timing generator 
    port(
         Grs    		: in std_logic;		-- Grs is the general reset; initialize while = 1; from uP_interface         
							-- Start counters at the next 1PPS (Grs needs to be zero)
         						-- This allows external 1PPS to be monitored when not sending frames
         RunTG    		: in std_logic;         -- from uP_interface
         RunFm    		: in std_logic;         -- from uP_interface
         
         C125              	: in std_logic;         -- correlator 125 MHz clock (LVDS input)
         one_PPS_Maser     	: in std_logic;       	-- 1 PPS from Maser via distributor (LVDS input)
         one_PPS_GPS       	: in std_logic;         -- 1 PPS from GPS via distributor (LVDS input)
         TE                	: in std_logic;         -- 48 msec Timing Event from QCC (LVDS input)
         
	       						-- taken from bits 29 to 0 for HdrInfo to provide initial value for SFRE at 
         						-- rising edge of 1PPS after armed by RunTG
         SFRE_Init         	: in std_logic_vector (29 downto 0);  	-- initial value for SFRE;
         
         FrameSync         	: out std_logic;			-- high one clock at beginning of frame
         FrameNum          	: out std_logic_vector (23 downto 0); 	-- for VDIF frame number
--         epoch             	: in  std_logic_vector (29 downto 0);  	-- initial value for SFRE  get rid of this duplicate!!!!!!!!!
         SFRE              	: out std_logic_vector (29 downto 0); 	-- for VDIF seconds field
         TIME1             	: out std_logic; 				-- for c167 1-msec interrupt; 
         TIME0             	: out std_logic; 				-- for c167 48-msec interrupt;
         one_PPS_PIC       	: out std_logic; 				-- for monitoring internal 1 PPS (LVDS output)
         one_PPS_MASER_OFF 	: out std_logic_vector(27 downto 0); 	-- maser vs local 1PPS offset
         one_PPS_GPS_OFF   	: out std_logic_vector(27 downto 0); 	-- gps vs local 1PPS offset         
	       								-- latched high when internal and external TE are not coincident
         								-- cleared to low by reset_te bit = 1 from uP_interface
         TE_Err          	: out std_logic;         
         reset_te        	: in  std_logic;		        -- high resets TE_Err
         one_PPS_PIC_adv    : out std_logic;
         nchan              : in std_logic_vector(4 downto 0)     --log base 2 of number of channels

       );
    end component; 
    
    component data_formatter
       port(    
        sum_di              :  in std_logic_vector(63 downto 0);
        
        PSN_init            : in std_logic_vector(63 downto 0);--initial packet ser. num.
        badFrame            : in std_logic; --bit 31 word 0
        SFRE                : in std_logic_vector(29 downto 0); --seconds from ref. epoch
        FrameNum            : in std_logic_vector(23 downto 0); --data frame number
        refEpoch            : in std_logic_vector(5 downto 0); --reference epoch
        nchan               : in std_logic_vector(4 downto 0); --n_chan_log2
        frameLength         : in std_logic_vector(23 downto 0);
        threadID            : in std_logic_vector(9 downto 0);
        stationID           : in std_logic_vector(15 downto 0);
        magicWord           : in std_logic_vector(23 downto 0);
        statusWord          : in std_logic_vector(31 downto 0);

        CFIFO               : in std_logic;
        C125                : in std_logic;
        FrameSync           : in std_logic;  --from timing generator
        TE_PIC              : in std_logic;  --from timing generator
        PPS_PIC_Adv         : in std_logic;
        PPS_PIC             : in std_logic;

        Grs                 : in std_logic;
        RunFm               : in std_logic; --from uP_interface
        hdr_sel_C167        : in std_logic_vector(5 downto 0); -- from uP_interface

        To10GbeTxData       : out std_logic_vector(63 downto 0);
        To10GbeTxDataValid  : out std_logic;
        To10GbeTxEOF        : out std_logic;

        sum_ch_demux_0      : out std_logic; --LSB of demux data, monitor point
        hdr_sel_0           : out std_logic; --LSB of hdr_sel, monitor point
        h_wr_en             : out std_logic; --header write enable, monitor point
        d_wr_en             : out std_logic; --data write enable, monitor point         
        FHOF                : out std_logic; --header fifo overflow, monitor point
        FDOF                : out std_logic; --data fifo overflow, monitor point
        FDPE                : out std_logic; --data fifo program_empty, monitor point
        h_rd_en             : out std_logic; --header read enable, monitor point
        d_rd_en             : out std_logic; --data read enable, monitor point   
        To10GbeTxData_1     : out std_logic; --Bit 1 of transmit data, monitor point

        PPS_read            : out std_logic; --PPS PIC captured by CFIFO clock
        
        coll_out_C167       : out std_logic_vector(7 downto 0) --captured header

       );
     end component;           
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    -- maximum number of channels that can be used. Initially set to 7.
    -- if this is to increase - the PPC DeviceData case definitions must change
--    constant MXCH : integer := 7;
--all VLBA stuff; comment out for now; probably delete later
--    type FrameNArray is array (0 to nch-1) of std_logic_vector(23 downto 0);
--    signal FrameNum    : FrameNArray;
--
--    signal ComplexFlags: std_logic_vector(0 to 7);
--
--    type BpS_Array is array (0 to MXCH) of std_logic_vector(4 downto 0);
--    signal Bits_SampA   : BpS_Array;
--
--    type SampRateArray is array (0 to MXCH) of std_logic_vector(23 downto 0);
--    signal SampleRateA  : SampRateArray;
--
--    type Loif_Ftw is array (0 to MXCH) of std_logic_vector(31 downto 0);
--    signal LoifFtwA     : Loif_Ftw;
--
--    type IFnumArray is array (0 to MXCH) of std_logic_vector(3 downto 0);
--    signal IFnumA       : IFnumArray;
--
--    type SubBandArray is array (0 to MXCH) of std_logic_vector(3 downto 0);
--    signal SubBandA     : SubBandArray;
--
--    --type RateArray is array (0 to MXCH) of std_logic_vector(1 downto 0);
--    signal selRate : std_logic_vector(1 downto 0);
--
--    signal ESideBand: std_logic_vector(7 downto 0);


    -- VDIF Header definition (from VLBA design; comment out)
--type HdrArray is record
--    --Word 0    words are 32 bits wide
--    InvFlg   : std_logic;-- := 0;
--    Legacy   : std_logic;-- := 0;
--    SFRE     : std_logic_vector(29 downto 0); -- seconds from ref epoch
--    --Word 1
--    RefEpoch : std_logic_vector(7 downto 0);  -- only 6 bits valid
--    FrameNum : std_logic_vector(23 downto 0);
--    --Word 2
--    VERS   : std_logic_vector(2 downto 0);-- := "001";
--    LogCh  : std_logic_vector(4 downto 0);-- := "00000"; --num chan in array=1 (2^^0)?
--    FrameLen : std_logic_vector(23 downto 0);-- := x"1388"; -- =5000?
--    --Word 3
--    CmplxFlg : std_logic;
--    Bits_Samp: std_logic_vector(4 downto 0);-- initially defaults to 2
--    ThreadID : std_logic_vector(9 downto 0);-- default to channel number
--    StationID: std_logic_vector(15 downto 0);
--    --Word 4
--    EDV    : std_logic_vector(7 downto 0);-- := x"3C"; -- ExtendedUserDataVersion
--    --signal UnitFlg  : std_logic;  add this bit to SRU vector below
--    SRU      : std_logic_vector(23 downto 0);
--    --Word 5
--    SYNC   : std_logic_vector(31 downto 0);--:= x"ACABFEED";
--    --Word 6
--    LoifFtw  : std_logic_vector(31 downto 0);
--    --Word 7
--    DBEnum   : std_logic_vector(3 downto 0);
--    IFnum    : std_logic_vector(3 downto 0);
--    SubBand  : std_logic_vector(2 downto 0);
--    ESideBand: std_logic;
--    MajRev   : std_logic_vector(3 downto 0);
--    MinRev   : std_logic_vector(3 downto 0);
--    Persnlity: std_logic_vector(7 downto 0);
--end record HdrArray;

    -- clock management
    signal epb_clk : std_logic;         -- connected to OPB_Clk for now

    -- OPB management
    signal DeviceAddr    : std_logic_vector(31 downto 0);  -- original address
    signal DeviceDataIn  : std_logic_vector(31 downto 0);  -- original data in bus
    signal DeviceDataOut : std_logic_vector(31 downto 0);  -- original data out bus


--    signal HdrAry : HdrArray; from VLBA design; comment out
--    signal HdrBlk : vdifHdr;  from VLBA design; comment out
 -------------------------------------------------------------------------------
    -- definitions for vdif channel counter state machine
    -- this is part of VLBA design
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

    -- clock and data signals
    signal clk_p         : std_logic;
    signal clk_n         : std_logic;   
    signal sum_data    : std_logic_vector(63 downto 0);  
    signal clk_out       : std_logic;
    signal sum_out       : std_logic_vector(63 downto 0);
    signal DATA2_sig     : std_logic_vector(63 downto 0); -- connect data_interface to data_formatter
    signal DATA3_sig     : std_logic_vector(63 downto 0); -- connect data_formatter to 10 GbE

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
    signal test_ctr_125    : std_logic_vector(7 downto 0)  := X"00";      
    signal C125_ds         : std_logic;                    -- for testing C125 clock     
    signal C125            : std_logic;                    -- for testing C125 clock  
    signal ROUTB_sig       : std_logic_vector(3 downto 0) := "0000";
    signal TimeCode_sig    : std_logic_vector(31 downto 0) := X"0000_0000";
    signal td_out_sig      : std_logic_vector(63 downto 0) := X"0000_0000_0000_0000";
    
        
    --C167 registers
    signal c167_reg0_sig     :std_logic_vector(7 downto 0) := X"00";  --initialization register
    signal c167_reg1_sig     :std_logic_vector(7 downto 0);           --ROACHTP0 select
    signal c167_reg2_sig     :std_logic_vector(7 downto 0);           --ROACHTP1 select
    signal c167_reg3_sig     :std_logic_vector(7 downto 0) := X"A0";           --    
                                                                      --registers 3 to 11 are spare 
	  signal c167_reg4_sig     :std_logic_vector(7 downto 0) := X"00";           --spare register 4															  
	  signal c167_reg5_sig     :std_logic_vector(7 downto 0) := X"00";           --spare register 5
	  signal c167_reg6_sig     :std_logic_vector(7 downto 0) := X"00";           --spare register 6
	  signal c167_reg7_sig     :std_logic_vector(7 downto 0) := X"00";           --spare register 7	 														  
	  signal c167_reg8_sig     :std_logic_vector(7 downto 0) := X"00";           --spare register 8
	  signal c167_reg9_sig     :std_logic_vector(7 downto 0) := X"00";           --spare register 9																	  
	  signal c167_reg10_sig    :std_logic_vector(7 downto 0) := X"00";           --spare register 10
	  --reg11 is a read/write pair to get status data from the header collator
	  signal c167_reg11_w_sig  :std_logic_vector(7 downto 0) := X"00";           --for writing to hdr_sel_c167
	  signal c167_reg11_r_sig  :std_logic_vector(7 downto 0) := X"00";           --for reading from coll_out_c167	  
																	  
																	  
    type array_reg12 is array(0 to REG12_LGTH-1) of std_logic_vector(7 downto 0);    
    signal QREG12: array_reg12;  --array of 8-bit registers for register 12; see generate statement below                                                                     
    signal c167_reg12_Q_sig     :std_logic_vector(7 downto 0);           --for last register in the chain
    signal c167_reg12_CE_sig    :std_logic; 
    
    signal c167_reg13_sig     :std_logic_vector(7 downto 0);           --transfer request to operational registers
    signal c167_reg14_sig     :std_logic_vector(7 downto 0);           --control register 0
    signal c167_reg15_sig     :std_logic_vector(7 downto 0);           --control register 1
    signal c167_reg16_sig     :std_logic_vector(7 downto 0);           --control register 2
    signal c167_reg17_sig     :std_logic_vector(7 downto 0);           --control register 3
    signal c167_reg18_sig     :std_logic_vector(7 downto 0);           --control register 4
    signal c167_reg19_sig     :std_logic_vector(7 downto 0);           --control register 5
    signal c167_reg20_sig     :std_logic_vector(7 downto 0);           --control register 6        
    signal c167_reg21_sig     :std_logic_vector(7 downto 0);           --address register for status RAM
    signal c167_reg22_sig     :std_logic_vector(7 downto 0);           --read request for status RAM           
    signal c167_reg23_sig     :std_logic_vector(7 downto 0) := X"01";  --for LSB of PPS_Maser_Off   
    signal c167_reg24_sig     :std_logic_vector(7 downto 0) := X"02";  --for byte 1 of PPS_Maser_Off
    signal c167_reg25_sig     :std_logic_vector(7 downto 0) := X"03";  --for byte 2 of PPS_Maser_Off
    signal c167_reg26_sig     :std_logic_vector(7 downto 0) := X"04";  --for MSB of PPS_Maser_Off
    signal c167_reg27_sig     :std_logic_vector(7 downto 0) := X"05";  --for LSB of PPS_GPS_Off   
    signal c167_reg28_sig     :std_logic_vector(7 downto 0) := X"06";  --for byte 1 of PPS_GPS_Off
    signal c167_reg29_sig     :std_logic_vector(7 downto 0) := X"07";  --for byte 2 of PPS_GPS_Off
    signal c167_reg30_sig     :std_logic_vector(7 downto 0) := X"08";  --for MSB of PPS_GPS_Off                            
    signal c167_reg31_sig     :std_logic_vector(7 downto 0) := X"09";  --for LSB of PPS_TE_Off   
    signal c167_reg32_sig     :std_logic_vector(7 downto 0) := X"0a";  --for byte 1 of PPS_TE_Off
    signal c167_reg33_sig     :std_logic_vector(7 downto 0) := X"0b";  --for byte 2 of PPS_TE_Off
    signal c167_reg34_sig     :std_logic_vector(7 downto 0) := X"0c";  --for PRN error
    signal c167_reg35_sig     :std_logic_vector(7 downto 0) := X"0d";  --for environmental monitor
    signal c167_reg36_sig     :std_logic_vector(7 downto 0) := X"0e";  --for environmental monitor
    signal c167_reg37_sig     :std_logic_vector(7 downto 0) := X"0f";  --for environmental monitor
    signal c167_reg38_sig     :std_logic_vector(7 downto 0) := X"10";  --for environmental monitor
    signal c167_reg39_sig     :std_logic_vector(7 downto 0) := X"11";  --for environmental monitor
    signal c167_reg40_sig     :std_logic_vector(7 downto 0) := X"12";  --for environmental monitor
    signal c167_reg41_sig     :std_logic_vector(7 downto 0) := X"13";  --for environmental monitor
    signal c167_reg42_sig     :std_logic_vector(7 downto 0) := X"14";  --for statistics status
    signal c167_reg43_sig     :std_logic_vector(7 downto 0) := X"15";  --for +3 statistics, LSB
    signal c167_reg44_sig     :std_logic_vector(7 downto 0) := X"16";  --for +3 statistics, byte 1
    signal c167_reg45_sig     :std_logic_vector(7 downto 0) := X"17";  --for +3 statistics, byte 2
    signal c167_reg46_sig     :std_logic_vector(7 downto 0) := X"18";  --for +3 statistics, MSB
    signal c167_reg47_sig     :std_logic_vector(7 downto 0) := X"19";  --for +1 statistics, LSB
    signal c167_reg48_sig     :std_logic_vector(7 downto 0) := X"1a";  --for +1 statistics, byte 1
    signal c167_reg49_sig     :std_logic_vector(7 downto 0) := X"1b";  --for +1 statistics, byte 2
    signal c167_reg50_sig     :std_logic_vector(7 downto 0) := X"1c";  --for +1 statistics, MSB
    signal c167_reg51_sig     :std_logic_vector(7 downto 0) := X"1d";  --for -1 statistics, LSB
    signal c167_reg52_sig     :std_logic_vector(7 downto 0) := X"1e";  --for -1 statistics, byte 1
    signal c167_reg53_sig     :std_logic_vector(7 downto 0) := X"1f";  --for -1 statistics, byte 2
    signal c167_reg54_sig     :std_logic_vector(7 downto 0) := X"20";  --for -1 statistics, MSB
    signal c167_reg55_sig     :std_logic_vector(7 downto 0) := X"21";  --for -3 statistics, LSB
    signal c167_reg56_sig     :std_logic_vector(7 downto 0) := X"22";  --for -3 statistics, byte 1
    signal c167_reg57_sig     :std_logic_vector(7 downto 0) := X"23";  --for -3 statistics, byte 2
    signal c167_reg58_sig     :std_logic_vector(7 downto 0) := X"24";  --for -3 statistics, MSB

    signal c167_reg59_sig     :std_logic_vector(7 downto 0) := X"30";  -- for VDIF frame number, 8 least significant bits
    signal c167_reg60_sig     :std_logic_vector(7 downto 0) := X"31";  -- for VDIF seconds field, 8 least significant bits
    signal c167_reg61_sig     :std_logic_vector(7 downto 0) := X"32";  -- maser vs local 1PPS offset, 8 least significant bits
    signal c167_reg62_sig     :std_logic_vector(7 downto 0) := X"33";  -- gps vs local 1PPS offset, 8 least significant bits
    signal c167_reg63_sig     :std_logic_vector(7 downto 0) := X"34";  -- unused

    signal td_sel_sig         :std_logic_vector(2 downto 0) := "000";  --ctrl bits derived from reg 14
    signal data_sel_sig       :std_logic:= '0';                        --ctrl bits derived from reg 14
    
    signal RunFm_sig          : std_logic;                             --"run formatter" derived from c167_reg14_sig(5)
    signal RunFm_a1_sig       : std_logic;                             --"run formatter" advanced version for syncing to clock
    signal RunFm_a2_sig       : std_logic;                             --"run formatter" advanced version for syncing to clock 
    signal RunFm_Z1_sig       : std_logic;                             --"run formatter" delayed version for detecting rising edge

    --c167 bus clock and control signals                                   -                                                                    
    signal C167_CLK_sig      :std_logic;                    --clock for those registers
    signal data_from_cpu_sig : std_logic_vector(7 downto 0);    
    signal data_to_cpu_sig   : std_logic_vector(7 downto 0);
--    signal C167_RD_EN_sig    :std_logic_vector(31 downto 0); --one line goes high
--    signal C167_WR_EN_sig    :std_logic_vector(31 downto 0); --one line goes high  
    signal C167_WE_sig       :std_logic; --write to register when low and ctrl_data is low
    signal C167_ADDR_sig     :std_logic_vector(7 downto 0); --address for read/write 
    
    --signals for DAC
    signal DAC_CLK_p_sig        : std_logic;
    signal DAC_CLK_n_sig        : std_logic; 
    signal DAC_IN_A_sig         : std_logic_vector(3 downto 0) := "0000"; -- for DAC A
    signal DAC_IN_B_sig         : std_logic_vector(3 downto 0) := "0000"; -- for DAC B
--    signal DAC_IN_A0_sig        :std_logic_vector(3 downto 0) := X"0";
    
    -- system-timing-related signals
    signal OnePPS               :std_logic := '0';
    signal PPS_PIC_sig          :std_logic := '0'; --FPGA-derived 1-PPS based on TE and command from CCC
    signal PPS_PIC_p_sig        :std_logic ;       --FPGA-derived 1-PPS based on TE and command from CCC buffer output
    signal PPS_PIC_n_sig        :std_logic ;       --FPGA-derived 1-PPS based on TE and command from CCC buffer output
    signal TE_sig               :std_logic := '0';
    signal AUXTIME_sig          :std_logic := '0';    
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
    
    -- timing generator related signals                
   signal SFRE_init_sig         : std_logic_vector (29 downto 0) := "00" & x"000_0000"; 										                      -- high one clock at beginning of frame
   signal FrameSync_sig         : std_logic := '0'; 										                      -- high one clock at beginning of frame
   signal FrameNum_sig          : std_logic_vector (23 downto 0) := x"00_0000"; 	          -- for VDIF frame number
   signal epoch_sig             : std_logic_vector (29 downto 0) := b"00" & x"000_0000";   -- initial value for SFRE
   signal SFRE_sig              : std_logic_vector (29 downto 0) := b"00" & x"000_0000"; 	-- for VDIF seconds field
   signal TIME1_sig             : std_logic := '0'; 											                    -- for c167 48-msec interrupt; drives MGT_TX_p10 (LVDS output)
   signal GPS_Offset_sig        : std_logic_vector(27 downto 0):= x"000_0000"; 	          -- maser vs local 1PPS offset
   signal Maser_Offset_sig      : std_logic_vector(27 downto 0):= x"000_0000"; 	          -- gps vs local 1PPS offset
   signal TE_Err_sig          	: std_logic := '0';
   signal PPS_PIC_adv_sig   : std_logic;
   signal nchan_sig             : std_logic_vector(4 downto 0) := "00101";     --log, base 2, of the number of channels
--   signal nchan_a2_sig          : std_logic_vector(4 downto 0);     --log, base 2, of the number of channels, advanced 2 clocks
--   signal nchan_a1_sig          : std_logic_vector(4 downto 0);     --log, base 2, of the number of channels, advanced 2 clocks      
   
   --data_formatter related signals
   signal PSN_init_sig          : std_logic_vector (63 downto 0) ;  --initial packet serial number from CCC via C167
   signal badFrame_sig          : std_logic;                        --badFrame bit from C167
   signal refEpoch_sig          : std_logic_vector(5 downto 0);     --reference epoch from CCC via C167
   signal frameLength_sig       : std_logic_vector(23 downto 0);    --data frame length from CCC via C167
   signal threadID_sig          : std_logic_vector(9 downto 0);     --thread ID from CCC via C167
   signal stationID_sig         : std_logic_vector(15 downto 0);    --station ID from CCC via C167
   signal magicWord_sig         : std_logic_vector(23 downto 0);    --magic word from CCC via C167   
   signal statusWord_sig        : std_logic_vector(31 downto 0);    --status from CCC via C167, C167 itself and FPGA 
   signal sum_ch_demux_0_sig    : std_logic;                        --lsb of demuxed data, for monitoring
   signal hrd_sel_0_sig         : std_logic;                        --lsb of demuxed data, for monitoring
   signal h_wr_en_sig           : std_logic;                        --header write enable signal, for monitoring
   signal d_wr_en_sig           : std_logic;                        --data write enable signal, for monitoring   
   signal FHOF_sig              : std_logic;                        --header fifo overflow, for monitoring and status
   signal FDOF_sig              : std_logic;                        --data fifo overflow, for monitoring and status
   signal FDPE_sig              : std_logic;                        --data fifo program_empty, for monitoring
   signal h_rd_en_sig           : std_logic;                        --header read enable signal, for monitoring
   signal d_rd_en_sig           : std_logic;                        --data read enable signal, for monitoring      
   signal To10GbeTxData_1_sig   : std_logic;                        --framed data to 10 GbE module, for monitoring
   signal PPS_read_sig          : std_logic;                        --PIC 1PPS captured by CFIFO clock, for monitoring
   signal coll_out_C167_sig     : std_logic_vector(7 downto 0);     --8 bits of header captured at TE, for status to C167
   signal To10GbeTxDataValid_sig  : std_logic;                      --data valid to 10 Gbe module and test point from formatter
   signal To10GbeTxEOF_sig      : std_logic;                        --end of frame to 10 Gbe module and test point from formatter   
    
    --temporary counter to generate OneMsec until we integrate the timing_gen module
    signal OneMsecCtr           : std_logic_vector(17 downto 0) := "000000000000000000";
    signal OneMsecRst          : std_logic; 
    
    signal frm_sync_sig         : std_logic := '0';
   
    --status signals
    signal DONE_sig             :std_logic := '1';
    signal DLL_sig              :std_logic := '1';
    
    --statistics signals    
    signal stat_p3_sig          : std_logic_vector(23 downto 0) := X"03_0201";
    signal stat_p1_sig          : std_logic_vector(23 downto 0) := X"07_0605";
    signal stat_m1_sig          : std_logic_vector(23 downto 0) := X"0B_0A09";
    signal stat_m3_sig          : std_logic_vector(23 downto 0) := X"0F_0E0D";



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
      O => sum_data(i), -- buffer output
      I => sum_data_p(i), -- Diff_p  buffer input (connect directly to top-level port)
      IB => sum_data_n(i) -- Diff_n  buffer input (connect directly to top-level port)
   );   
   end generate sum_data_inputs;   
   
    -- Output for DAC CLK
   OBUFDS_DAC_CLK : OBUFDS
     generic map (
       IOSTANDARD => "DEFAULT")
     port map (
       O  => DAC_CLK_p_sig, -- Diff_p output (connect directly to top-level port)
       OB => DAC_CLK_n_sig, -- Diff_n output (connect directly to top-level port)
       I  => adc_clk -- Buffer input
     ); 

    -- Output for DAC data; single ended so don't need to specify buffers here    
    
    -- instantiate details of C167 register 12
      REG12: for i in 0 to REG12_LGTH generate
        FIRST: if i = 0 generate
          REG12_0: treg8
            port map (
	            D  => data_from_cpu_sig,
	            Q	 => QREG12(i),	
	            CE => C167_reg12_CE_sig,
	            CK => C167_CLK_sig
            );
          end generate FIRST;
  
        OTH: if (i > 0) AND (i <= REG12_LGTH - 1) generate
          REG12_x: treg8
            port map (
              D  => QREG12(i-1),
	            Q	 => QREG12(i),	
	            CE => C167_reg12_CE_sig,
	            CK => C167_CLK_sig
           );
        end generate OTH;
      end generate REG12; 
      c167_reg12_Q_sig <= QREG12(REG12_LGTH - 1);  -- for readability
      
   data_interface_0: data_interface
   port map(
      sum_data   => sum_data,
      C125       => C125,        
      Grs        => c167_reg14_sig(3),          --control reg 0, bit 2 from C167          
      chan       => c167_reg16_sig(5 downto 0), --control reg 2, bits 5 to 0 from C167       
      stat_msec  => c167_reg17_sig(6 downto 0), --control reg 3, bits 6 to 0 from C167       
      prn_run    => c167_reg15_sig(0),          --control reg 1, bit 0 from C167     
      stat_start => c167_reg15_sig(1),          --control reg 1, bit 1 from C167
      OneMsec    => OneMsecRst,     
      ecnt       => c167_reg34_sig,             --error counter reg, target 34        
      stat_p3    => stat_p3_sig, --statistics, +3, 3 bytes max
      stat_p1    => stat_p1_sig, --statistics, +1, 3 bytes max     
      stat_m1    => stat_m1_sig, --statistics, -1, 3 bytes max
      stat_m3    => stat_m3_sig, --statistics, +3, 3 bytes max
      stat_rdy   => c167_reg42_sig(0),    
      td_sel     => td_sel_sig,      
      frm_sync   => frm_sync_sig,    
      td_out     => td_out_sig,  
      data_sel   => data_sel_sig,
      sum_di     => DATA2_sig 
   );
   -- timing generator connection
   timing_generator_0: timing_generator
   port map(

          Grs                => c167_reg14_sig(03), -- ok (1=> reset)       IN
          RunTG              => c167_reg14_sig(4),  -- ok                   IN
          RunFm              => RunFm_sig,          --rising edge (and 1 PPS) used to start formatter and part of timing gen
          C125               => C125,               -- ok                   IN
          one_PPS_Maser      => PPS_Maser_sig,      -- ok                   IN
          One_PPS_GPS        => PPS_GPS_sig,        -- ok                   IN
          TE                 => TE_sig,             -- ok                   IN
          SFRE_Init          => SFRE_init_sig,          --    IN
          FrameSync          => FrameSync_sig,      -- needs to be added    OUT
          FrameNum           => FrameNum_sig,       -- to data formatter
--          epoch              => epoch_sig,          -- needs to be added    IN  replaced by SFRE_init
          SFRE               => SFRE_sig,           -- to data formatter
          TIME0              => TIME0_sig,          -- 1 msec interrupt to C167
          TIME1              => TIME1_sig,          -- 48 msec interrupt to C167
          one_PPS_PIC        => PPS_PIC_sig,        -- ok                   OUT
          one_PPS_Maser_OFF  => Maser_Offset_sig,   -- needs to be added    OUT
          one_PPS_GPS_OFF    => GPS_Offset_sig,     -- needs to be added    OUT
          TE_Err             => c167_reg3_sig(0),   -- needs to be added    OUT
          reset_TE           => c167_reg0_sig(1),   -- ok                   IN      
          one_PPS_PIC_adv    => PPS_PIC_adv_sig,
          nchan              => nchan_sig
   );
   
   data_formatter_0: data_formatter
   port map(
      sum_di        => DATA2_sig,       --connects to data_interface
      PSN_init      => PSN_init_sig,    --from CCC via C167
      badFrame      => badFrame_sig,    --determined by logic in C167 based on local and CCC input
      SFRE          => SFRE_sig,        --from timing generator
      FrameNum      => FrameNum_sig,    --from timing generator
      refEpoch      => refEpoch_sig,    --header data from C167
      nchan         => nchan_sig,       --header data from C167
      frameLength   => frameLength_sig, --header data from C167
      threadID      => threadID_sig,    --header data from C167
      stationID     => stationID_sig,   --header data from C167
      magicWord     => magicWord_sig,   --header data from C167
      statusWord    => statusWord_sig,  --header data from various sources
      CFIFO         => CFIFO,           --output rate clock ~143 MHz
      C125          => C125,            --correlator clock, 125 MHz
      FrameSync     => FrameSync_sig,   --frame sync pulse from timing gen 
      TE_PIC        => TIME1_sig,       --TE pulse from timing gen
      PPS_PIC_Adv   => PPS_PIC_Adv_sig, --1 PPS from timing gen, 1 clock early
      PPS_PIC       => PPS_PIC_sig,     --1PPS from timing gen
      Grs           => c167_reg14_sig(03),  --from C167; a 1 causes reset
      RunFM         => RunFm_sig,           --from C167;rising edge (and 1 PPS) used to start formatter and part of timing gen 
      hdr_sel_C167  => c167_reg11_w_sig(5 downto 0),  --used to select which part of header data captured at TE to transmit
      To10GbeTxData => To10GbeTxData,           --three signals to 10 GbE module
      To10GbeTxDataValid => To10GbeTxDataValid_sig,
      To10GbeTxEOF  => To10GbeTxEOF_sig,    
      sum_ch_demux_0=> sum_ch_demux_0_sig,  --bit 0 of demuxed data, to monitor point
      hdr_sel_0     => hrd_sel_0_sig,       --bit 0 of header select signal, to monitor point
      h_wr_en       => h_wr_en_sig,         --header write enable signal, to monitor point
      d_wr_en       => d_wr_en_sig,         --data write enable signal, to monitor point           
      FHOF          => FHOF_sig,            --header fifo overflow, to monitor point 
      FDOF          => FDOF_sig,            --data fifo overflow, to monitor point
      FDPE          => FDPE_sig,            --data fifo program empty, to monitor point, goes low when one frame's worth of data is available in the fifo.
      h_rd_en       => h_rd_en_sig,         --header write enable signal, to monitor point
      d_rd_en       => d_rd_en_sig,         --data write enable signal, to monitor point      
      To10GbeTxData_1 => To10GbeTxData_1_sig, --Bit 1 of data sent to 10 GbE
      PPS_read      => PPS_read_sig,        --PIC 1PPS as captured by CFIFO
      coll_out_C167 => coll_out_C167_sig    --header data captured at TE, for status to C167
   );
        
      
    -- Output for DAC data; single ended so don't need to specify buffers here 
    --connect signals to ports
    DAC_CLK_p <= DAC_CLK_p_sig;
    DAC_CLK_n <= DAC_CLK_n_sig;      
    DAC_IN_A  <= DAC_IN_A_sig;
    DAC_IN_B  <= DAC_IN_B_sig;
--    DAC_IN_A0  <= DAC_IN_A0_sig; 

    PPS_PIC_p <= PPS_PIC_p_sig;
    PPS_PIC_n <= PPS_PIC_n_sig;    

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

    --buffer for auxtime signal (not used for anything)
    AUXTIME_buf: IBUFDS
   generic map (
      CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
      DIFF_TERM => TRUE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
      IOSTANDARD => "DEFAULT")
      
   port map (
      O => AUXTIME_sig, -- AUXTIME buffer output
      I => AUXTIME_p, -- Diff_p clock buffer input (connect directly to top-level port)
      IB => AUXTIME_n -- Diff_n clock buffer input (connect directly to top-level port)
   );   
   
    PIC_1PPS_BUF: OBUFDS
     generic map (
       IOSTANDARD => "DEFAULT")
     port map (
       O  => PPS_PIC_p_sig, -- Diff_p output 
       OB => PPS_PIC_n_sig, -- Diff_n output 
       I  => test_ctr(7) -- Buffer input  
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
CLKIN1_PERIOD => 10.000,
CLKIN2_PERIOD => 8.000,
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
CLKINSEL => c167_reg0_sig(0), -- 1-bit input: Clock select input; High = CLKIN1, Low = CLKIN2
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
  test_port_out <= test_port_sig;  --loop back for testing
  ROUTB         <= ROUTB_sig;
   
  --connect misc signals
  DONE           <= DONE_sig;          
  DLL            <= DLL_sig;  
--  PPS_PIC_sig <= test_ctr(0);

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
  DAC_IN_A_sig <= test_ctr(7 downto 4);
  DAC_IN_B_sig <= test_ctr(7 downto 4); 
  
   --C167-related mappings
       --because of conflicts between the FPGA requirements and ICD with Computing,
       --the DOUT bits of C167 control word must be mapped to td_sel and data_sel as follows
       td_sel_sig(2)     <= ( NOT c167_reg14_sig(7) ) AND ( NOT c167_reg14_sig(6) );
       td_sel_sig(1)     <=    c167_reg14_sig(7)      AND     c167_reg14_sig(6)    ;
       td_sel_sig(0)     <=    c167_reg14_sig(6)                                   ;
       data_sel_sig      <=    c167_reg14_sig(7)      OR      c167_reg14_sig(6)    ;  
       --C167 statistics mapping 
       c167_reg43_sig    <= stat_m3_sig(7  downto  0);
       c167_reg44_sig    <= stat_m3_sig(15 downto  8);
       c167_reg45_sig    <= stat_m3_sig(23 downto 16);
       c167_reg47_sig    <= stat_m1_sig(7  downto  0);
       c167_reg48_sig    <= stat_m1_sig(15 downto  8);
       c167_reg49_sig    <= stat_m1_sig(23 downto 16);
       c167_reg51_sig    <= stat_p1_sig(7  downto  0);
       c167_reg52_sig    <= stat_p1_sig(15 downto  8);
       c167_reg53_sig    <= stat_p1_sig(23 downto 16);
       c167_reg55_sig    <= stat_p3_sig(7  downto  0);
       c167_reg56_sig    <= stat_p3_sig(15 downto  8);
       c167_reg57_sig    <= stat_p3_sig(23 downto 16);
       --C167 header mapping
       PSN_init_sig       <= QREG12(32) & QREG12(33) & QREG12(34) & QREG12(35) & QREG12(36) & QREG12(37) & QREG12(38) & QREG12(39);
       badFrame_sig       <= c167_reg19_sig(0);   --C167 sets this bit based on latest data from CCC and local status info
       SFRE_init_sig      <= QREG12(28)(5 downto 0) & QREG12(29) & QREG12(30) & QREG12(31);
       refEpoch_sig       <= QREG12(24)(5 downto 0);
       --FrameNum_init_sig  <= QREG12(25) & QREG12(26) & QREG12(27); not needed since frame num self-initializes at 1PPS
       nchan_sig       <= QREG12(20)(4 downto 0); 
       frameLength_sig    <= QREG12(21) & QREG12(22) & QREG12(23);
       threadID_sig       <= QREG12(16)(1 downto 0) & QREG12(17);
       stationID_sig      <= QREG12(18) & QREG12(19);
       magicWord_sig      <= QREG12(13) & QREG12(14) & QREG12(15);
       statusWord_sig     <= X"000_0000" & '0' & NOT LOCKED_sig & c167_reg3_sig(0) & badFrame_sig;            
       c167_reg11_r_sig   <= coll_out_C167_sig;         --captured header data
--       epoch_sig          <= QREG12(28)(5 downto 0) & QREG12(29) & QREG12(30) & QREG12(31);  get rid of this duplicate!


       -- time difference
       c167_reg23_sig <= Maser_Offset_sig(7 downto 0);
       c167_reg24_sig <= Maser_Offset_sig(15 downto 8); 
       c167_reg25_sig <= Maser_Offset_sig(23 downto 16);
       c167_reg26_sig <= "0000" & Maser_Offset_sig(27 downto 24);

       c167_reg27_sig <= GPS_Offset_sig(7 downto 0);
       c167_reg28_sig <= GPS_Offset_sig(15 downto 8); 
       c167_reg29_sig <= GPS_Offset_sig(23 downto 16);
       c167_reg30_sig <= "0000" & GPS_Offset_sig(27 downto 24);
           
       --misc status
       c167_reg3_sig(1) <= LOCKED_sig;
       c167_reg59_sig <= FrameNum_sig(7 downto 0);     
       c167_reg60_sig <= SFRE_sig(7 downto 0);
       c167_reg61_sig <= Maser_Offset_sig(7 downto 0);
       c167_reg62_sig <= GPS_Offset_sig(7 downto 0);  
       RunFm_sig   <= c167_reg14_sig(5);  

      --C167 interupt signals
      TIME0 <= TIME0_sig; --48 ms
      TIME1 <= TIME1_sig; --1 ms
      
  --signals to 10 GbE module
  To10GbeTxDataValid  <= To10GbeTxDataValid_sig;
  To10GbeTxEOF        <= To10GbeTxEOF_sig; 
  To10Gbe_CFIFO       <= CFIFO;

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

          if (OPB_RNW = '0' and C167_WE_sig='1') then				-- write 

            case (DeviceAddr(7 downto 2)) is

            when "000000" => SyncWord <= DeviceDataIn;       				   --0x000
            --when "000001" => c167_reg0_sig  <= DeviceDataIn(7 downto 0);       --0x001
            --when "000010" => c167_reg1_sig  <= DeviceDataIn(7 downto 0);       --0x002
            --when "000011" => c167_reg2_sig  <= DeviceDataIn(7 downto 0);       --0x003
            --when "000100" => c167_reg3_sig  <= DeviceDataIn(7 downto 0);       --0x004			
            --when "000101" => c167_reg4_sig  <= DeviceDataIn(7 downto 0);       --0x005
            --when "000110" => c167_reg5_sig  <= DeviceDataIn(7 downto 0);       --0x006
            --when "000111" => c167_reg6_sig  <= DeviceDataIn(7 downto 0);       --0x007
            --when "001000" => c167_reg7_sig  <= DeviceDataIn(7 downto 0);       --0x008			
            --when "001001" => c167_reg8_sig  <= DeviceDataIn(7 downto 0);       --0x009
            --when "001010" => c167_reg9_sig  <= DeviceDataIn(7 downto 0);       --0x00A
            --when "001011" => c167_reg10_sig <= DeviceDataIn(7 downto 0);       --0x00B
            --when "001100" => c167_reg11_sig <= DeviceDataIn(7 downto 0);       --0x00C			
            --when "001101" => c167_reg12_Q_sig <= DeviceDataIn(7 downto 0);       --0x00D
            --when "001110" => c167_reg13_sig <= DeviceDataIn(7 downto 0);       --0x00E
            --when "001111" => c167_reg14_sig <= DeviceDataIn(7 downto 0);       --0x00F
            --when "010000" => c167_reg15_sig <= DeviceDataIn(7 downto 0);       --0x010
            --when "010001" => c167_reg16_sig <= DeviceDataIn(7 downto 0);       --0x011
            --when "010010" => c167_reg17_sig <= DeviceDataIn(7 downto 0);       --0x012
            --when "010011" => c167_reg18_sig <= DeviceDataIn(7 downto 0);       --0x013
            --when "010100" => c167_reg19_sig <= DeviceDataIn(7 downto 0);       --0x014			
            --when "010101" => c167_reg20_sig <= DeviceDataIn(7 downto 0);       --0x015
            --when "010110" => c167_reg21_sig <= DeviceDataIn(7 downto 0);       --0x016
            --when "010111" => c167_reg22_sig <= DeviceDataIn(7 downto 0);       --0x017
            --when "011000" => c167_reg23_sig <= DeviceDataIn(7 downto 0);       --0x018			
            --when "011001" => c167_reg24_sig <= DeviceDataIn(7 downto 0);       --0x019
            --when "011010" => c167_reg25_sig <= DeviceDataIn(7 downto 0);       --0x01A
            --when "011011" => c167_reg26_sig <= DeviceDataIn(7 downto 0);       --0x01B
            --when "011100" => c167_reg27_sig <= DeviceDataIn(7 downto 0);       --0x01C			
            --when "011101" => c167_reg28_sig <= DeviceDataIn(7 downto 0);       --0x01D
            --when "011110" => c167_reg29_sig <= DeviceDataIn(7 downto 0);       --0x01E
            --when "011111" => c167_reg30_sig <= DeviceDataIn(7 downto 0);       --0x01F
            --when "100000" => c167_reg31_sig <= DeviceDataIn(7 downto 0);       --0x020
            --when "100001" => c167_reg32_sig <= DeviceDataIn(7 downto 0);       --0x021
            --when "100010" => c167_reg33_sig <= DeviceDataIn(7 downto 0);       --0x022
            --when "100011" => c167_reg34_sig <= DeviceDataIn(7 downto 0);       --0x023
            --when "100100" => c167_reg35_sig <= DeviceDataIn(7 downto 0);       --0x024			
            --when "100101" => c167_reg36_sig <= DeviceDataIn(7 downto 0);       --0x025
            --when "100110" => c167_reg37_sig <= DeviceDataIn(7 downto 0);       --0x026
            --when "100111" => c167_reg38_sig <= DeviceDataIn(7 downto 0);       --0x027
            --when "101000" => c167_reg39_sig <= DeviceDataIn(7 downto 0);       --0x028			
            --when "101001" => c167_reg40_sig <= DeviceDataIn(7 downto 0);       --0x029
            --when "101010" => c167_reg41_sig <= DeviceDataIn(7 downto 0);       --0x02A
            --when "101011" => c167_reg42_sig <= DeviceDataIn(7 downto 0);       --0x02B
            --when "101100" => c167_reg43_sig <= DeviceDataIn(7 downto 0);       --0x02C			
            --when "101101" => c167_reg44_sig <= DeviceDataIn(7 downto 0);       --0x02D
            --when "101110" => c167_reg45_sig <= DeviceDataIn(7 downto 0);       --0x02E
            --when "101111" => c167_reg46_sig <= DeviceDataIn(7 downto 0);       --0x02F
            --when "110000" => c167_reg47_sig <= DeviceDataIn(7 downto 0);       --0x030
            --when "110001" => c167_reg48_sig <= DeviceDataIn(7 downto 0);       --0x031
            --when "110010" => c167_reg49_sig <= DeviceDataIn(7 downto 0);       --0x032
            --when "110011" => c167_reg50_sig <= DeviceDataIn(7 downto 0);       --0x033
            --when "110100" => c167_reg51_sig <= DeviceDataIn(7 downto 0);       --0x034			
            --when "110101" => c167_reg52_sig <= DeviceDataIn(7 downto 0);       --0x035
            --when "110110" => c167_reg53_sig <= DeviceDataIn(7 downto 0);       --0x036
            --when "110111" => c167_reg54_sig <= DeviceDataIn(7 downto 0);       --0x037
            --when "111000" => c167_reg55_sig <= DeviceDataIn(7 downto 0);       --0x038			
            --when "111001" => c167_reg56_sig <= DeviceDataIn(7 downto 0);       --0x039
            --when "111010" => c167_reg57_sig <= DeviceDataIn(7 downto 0);       --0x03A
            --when "111011" => c167_reg58_sig <= DeviceDataIn(7 downto 0);       --0x03B
            --when "111100" => c167_reg59_sig <= DeviceDataIn(7 downto 0);       --0x03C			
            --when "111101" => c167_reg60_sig <= DeviceDataIn(7 downto 0);       --0x03D
            --when "111110" => c167_reg61_sig <= DeviceDataIn(7 downto 0);       --0x03E
            --when "111111" => c167_reg62_sig <= DeviceDataIn(7 downto 0);       --0x03F

              when others => null;
            end case;
            
          else									-- read
 
            case (DeviceAddr(7 downto 2)) is
            when "000000" => DeviceDataOut <= c167_reg0_sig & c167_reg1_sig & c167_reg2_sig & c167_reg3_sig ;      				--registers 0,1,2,3
            when "000001" => DeviceDataOut <= c167_reg4_sig & c167_reg5_sig & c167_reg6_sig & c167_reg7_sig ;      				--registers 4,5,6,7
            when "000010" => DeviceDataOut <= c167_reg8_sig & c167_reg9_sig & c167_reg10_sig & c167_reg11_r_sig ;      			--registers 8,9,10,11
            when "000011" => DeviceDataOut <= c167_reg12_Q_sig & c167_reg13_sig & c167_reg14_sig & c167_reg15_sig ;      		--registers 12,13,14,15
            when "000100" => DeviceDataOut <= c167_reg16_sig & c167_reg17_sig & c167_reg18_sig & c167_reg19_sig ;      			--registers 16,17,18,19
            when "000101" => DeviceDataOut <= c167_reg20_sig & c167_reg21_sig & c167_reg22_sig & c167_reg23_sig ;      			--registers 20,21,22,23
            when "000110" => DeviceDataOut <= c167_reg24_sig & c167_reg25_sig & c167_reg26_sig & c167_reg27_sig ;      			--registers 24,25,26,27
            when "000111" => DeviceDataOut <= c167_reg28_sig & c167_reg29_sig & c167_reg30_sig & c167_reg31_sig ;      			--registers 28,29,30,31
            when "001000" => DeviceDataOut <= c167_reg32_sig & c167_reg33_sig & c167_reg34_sig & c167_reg35_sig ;      			--registers 32,33,34,35
            when "001001" => DeviceDataOut <= c167_reg36_sig & c167_reg37_sig & c167_reg38_sig & c167_reg39_sig ;      			--registers 36,37,38,39
            when "001010" => DeviceDataOut <= c167_reg40_sig & c167_reg41_sig & c167_reg42_sig & c167_reg43_sig ;      			--registers 40,41,42,43
            when "001011" => DeviceDataOut <= c167_reg44_sig & c167_reg45_sig & c167_reg46_sig & c167_reg47_sig ;      			--registers 44,45,46,47
            when "001100" => DeviceDataOut <= c167_reg48_sig & c167_reg49_sig & c167_reg50_sig & c167_reg51_sig ;      			--registers 48,49,50,51			
            when "001101" => DeviceDataOut <= c167_reg52_sig & c167_reg53_sig & c167_reg54_sig & c167_reg55_sig ;      			--registers 52,53,54,55			
            when "001110" => DeviceDataOut <= c167_reg56_sig & c167_reg57_sig & c167_reg58_sig & c167_reg59_sig ;      			--registers 56,57,58,59
            when "001111" => DeviceDataOut <= c167_reg60_sig & c167_reg61_sig & c167_reg62_sig & c167_reg63_sig ;      			--registers 60,61,62,63
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
    -- VLBA code; comment out for now
--    dlySel : process (adc_clk)
--    begin
--        if rising_edge(adc_clk) then
--
--            -- set sample rate delay for all channels from chan(0)...
--            -- ...this code says all channels must be at the same sample
--            -- rate to get the data to align with external world.
--            if SampleRateA(0)(5 downto 0) = "00000" then
--                 selRate <= SampleRateA(0)(22 downto 21) OR
--                    (NOT SampleRateA(0)(23) & NOT SampleRateA(0)(23));
--            else
--                 selRate <= "11";
--            end if;
--
--
--          case(selRate)is
--                when "10" =>     -- 1x data rate (128MHz)
--                    IntDelay <= WVR_DELAY;
--                when "01" =>    -- 2x data rate (64MHz)
--                    IntDelay <= WVR_DELAY + MUX_DELAY + FIR_DELAY;
--                when "00" =>    -- 4x data rate (32MHz)
--                    IntDelay <= WVR_DELAY + MUX_DELAY + FIR_DELAY + 1;
--                when others =>    -- more than 4x data rate (16MHz or less)
--                    IntDelay <= WVR_DELAY + CIC_DELAY + MUX_DELAY + FIR_DELAY;
--            end case;
--
--            TotalDelay <= TimeAlign_adc + IntDelay;
--        end if;
--    end process dlySel;

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
    -- VLBA code; comment out for now; delete later
--    fctr : process(OPB_Clk)
--    begin
--        if rising_edge(OPB_Clk) then
--            if (pps_sys = '1')then
--                arm <= '1';
--            elsif (arm = '1') AND (ccCntrState = ccStartWait) then
--                if (ppsFinish = '0') then --1st frame of this second
--                    for i in 0 to (nch-1) loop
--                        FrameNum(i) <=  (others => '0');
--                    end loop;
--                    arm <= '0';
--                -- else clear after this frame
--               end if;
--            elsif (ccCntrState = ccIncFrame) then
--                FrameNum(currCh) <= FrameNum(currCh) + 1;
--            end if;
--        end if;
--    end process;

-------------------------------------------------------------------------------
-- change channels each time the fifo has been read 625 times in formatter
-- VLBA code; comment out for now; delete later
--    chcntr : process(OPB_Clk)
--    begin
--        if rising_edge(OPB_Clk) then
--            if (ValidFlag_sys = '0') then
--                currCh <= 0;
--                FmtrEna <= '0';
--                ccCntrState <= ccStartWait;
--                ppsFinish <= '0';
--            else
--                case(ccCntrState) is
--                    when ccStartWait =>     -- wait for start of frame
--                        if prog_full(0) = '0' then
--                            ccCntrState <= ccFifoFull;
--                        end if;
--                    when ccFifoFull =>
--                        if prog_full(currCh) = '0' then -- send a packet for
--                            ccCntrState <= ccWaitFE1;   -- this channel
--                            FmtrEna <= '1';
--                        else
--                            ccCntrState <= ccIncCh;     -- go to next channel
--                        end if;
--                        ppsFinish <= '0';
--                    when ccWaitFE1 =>
--                        if FifoEna = '1' then
--                            ccCntrState <= ccWaitFE0;   -- packet tx started
--                        end if;
--                    when ccWaitFE0 =>
--                        if FifoEna = '0' then
--                            ccCntrState <= ccIncFrame;  -- packet tx ended
--                            FmtrEna <= '0';
--                        end if;
--                    when ccIncFrame =>      -- frame counter for this channel
--                        ccCntrState <= ccIncCh;
--                    when ccIncCh =>
--                        if(currCh < nch-1) then
--                            currCh <= currCh + 1;
--                            ccCntrState <= ccFifoFull;
--                        else
--                            currCh <= 0;
--                            ccCntrState <= ccStartWait; -- next frame
--                            if(arm = '1')  then
--                                ppsFinish <= NOT ppsFinish;
--                            end if;--tell FrameNum whether or not to clear
--                        end if;
--                    when others =>  --huh?
--                        ccCntrState <= ccStartWait;
--                end case;
--            end if;
--        end if;
--    end process;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- HdrAry was used in VLBA design; comment out for now; delete later
--HdrAry.VERS     <= "001";
--HdrAry.FrameLen <= x"000275"; --629d=units of 8bytes=5032bytes,including header
--HdrAry.EDV      <= x"02";
--HdrAry.MajRev   <= REV_MAJOR_INT(3 downto 0);
--HdrAry.MinRev   <= REV_MAJOR_FRAC(3 downto 0);
--HdrAry.Persnlity<= P_TYPE;

-- fill in the header block each time the channel changes; from VLBA design; comment out
--    HdrBlk(0) <= HdrAry.InvFlg & HdrAry.Legacy & HdrAry.SFRE &
--                    HdrAry.RefEpoch & HdrAry.FrameNum;
--    HdrBlk(1) <= HdrAry.VERS & HdrAry.LogCh & HdrAry.FrameLen &
--                    HdrAry.CmplxFlg & HdrAry.Bits_Samp &
--                    HdrAry.ThreadID & HdrAry.StationID;
--    HdrBlk(2) <= HdrAry.EDV & HdrAry.SRU &
--                    HdrAry.SYNC;
--    HdrBlk(3) <= HdrAry.LoifFtw &
--                    "1111" & HdrAry.DBEnum & HdrAry.IFnum & HdrAry.SubBand &
--                    HdrAry.ESideBand & HdrAry.MajRev & HdrAry.MinRev &
--                    HdrAry.Persnlity;

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
    -- change clock domains to OPB_Clk; from VLBA design; comment out for now
--    syncsys : process(OPB_Clk)
--    begin
--        if rising_edge(OPB_Clk) then
--            ValidFlag_sys       <= ValidFlag;
--            if ccCntrState = ccFifoFull then
--                HdrAry.InvFlg       <= (NOT ValidFlag) OR FifoError;
--                HdrAry.Legacy       <= Legacy;
--                HdrAry.SFRE         <= EpochSeconds;
--                HdrAry.RefEpoch     <= RefEpoch;
--                HdrAry.LogCh        <= log2numchan;
--                HdrAry.FrameNum     <= FrameNum(currCh);signal c167_reg34_sig     :std_logic_vector(7 downto 0) := X"0c";  --for MSB of PPS_TE_Off
--                HdrAry.CmplxFlg     <= ComplexFlags(currCh);
--                HdrAry.Bits_Samp    <= Bits_SampA(currCh);
--                HdrAry.ThreadID     <= std_logic_vector(to_unsigned(currCh,10));
--                HdrAry.StationID    <= StationID;
--                HdrAry.SRU          <= SampleRateA(currCh);
--                HdrAry.SYNC         <= SyncWord;
--                --HdrAry.LoifFtw      <= LoifFtwA(currCh);
--                HdrAry.DBEnum       <= DBEnum;
--                HdrAry.IFnum        <= IFnumA(currCh);
--                HdrAry.SubBand      <= SubBandA(currCh)(2 downto 0);
--                HdrAry.ESideBand    <= ESideBand(currCh);
--                if TestMode = '0' then
--                    HdrAry.LoifFtw <= LoifFtwA(currCh);
--                else
--                    HdrAry.LoifFtw <= TimeCntr & LoifFtwA(currCh)(15 downto 0);
--                end if;
--            end if;
--        end if;
--    end process;

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
--		   C167_RD_EN => C167_RD_EN_sig,			-- Read enable signals, they must be individually connected to the tri-state controller associated to teh desired signals
--		   C167_WR_EN	=> C167_Wr_EN_sig,	-- Write enable signals, they must be individually connected to the "clock enable" associated to the addressed register.
		   C167_WE	=> C167_WE_sig,				-- C167 clock signal, the first 4 clocks were removed.
 		   C167_ADDR	=> C167_ADDR_sig,				-- C167 clock signal, the first 4 clocks were removed.
		   C167_CLK	=> C167_CLK_sig				-- C167 clock signal
	);
	
	--process for testing C167 interface
	C167_reg_read: process(C167_CLK_sig, C167_addr_sig)
	begin
	   	case (C167_ADDR_sig) is
        when X"00" => data_to_cpu_sig <= c167_reg0_sig;     
        when X"01" => data_to_cpu_sig <= c167_reg1_sig;     
        when X"02" => data_to_cpu_sig <= c167_reg2_sig;
        when X"03" => data_to_cpu_sig <= c167_reg3_sig;
        when X"04" => data_to_cpu_sig <= c167_reg4_sig;
        when X"05" => data_to_cpu_sig <= SFRE_sig(7 downto 0);
        when X"06" => data_to_cpu_sig <= SFRE_sig(15 downto 8);
        when X"07" => data_to_cpu_sig <= SFRE_sig(23 downto 16);
        when X"08" => data_to_cpu_sig <= "00" & SFRE_sig(29 downto 24);                                
        when X"0B" => data_to_cpu_sig <= c167_reg11_r_sig;
        when X"0C" => data_to_cpu_sig <= c167_reg12_Q_sig;
        when X"0D" => data_to_cpu_sig <= c167_reg13_sig;
        when X"0E" => data_to_cpu_sig <= c167_reg14_sig;
        when X"0F" => data_to_cpu_sig <= c167_reg15_sig;
        when X"10" => data_to_cpu_sig <= c167_reg16_sig;
        when X"11" => data_to_cpu_sig <= c167_reg17_sig;
        when X"12" => data_to_cpu_sig <= c167_reg18_sig;
        when X"13" => data_to_cpu_sig <= c167_reg19_sig;
        when X"14" => data_to_cpu_sig <= c167_reg20_sig;
        when X"15" => data_to_cpu_sig <= c167_reg21_sig;
        when X"16" => data_to_cpu_sig <= c167_reg22_sig;
        when X"17" => data_to_cpu_sig <= c167_reg23_sig;
        when X"18" => data_to_cpu_sig <= c167_reg24_sig;
        when X"19" => data_to_cpu_sig <= c167_reg25_sig;
        when X"1a" => data_to_cpu_sig <= c167_reg26_sig;
        when X"1b" => data_to_cpu_sig <= c167_reg27_sig;
        when X"1c" => data_to_cpu_sig <= c167_reg28_sig;
        when X"1d" => data_to_cpu_sig <= c167_reg29_sig;
        when X"1e" => data_to_cpu_sig <= c167_reg30_sig;
        when X"1f" => data_to_cpu_sig <= c167_reg31_sig;
        when X"20" => data_to_cpu_sig <= c167_reg32_sig;
        when X"21" => data_to_cpu_sig <= c167_reg33_sig;
        when X"22" => data_to_cpu_sig <= c167_reg34_sig;
        when X"23" => data_to_cpu_sig <= c167_reg35_sig;
        when X"24" => data_to_cpu_sig <= c167_reg36_sig;
        when X"25" => data_to_cpu_sig <= c167_reg37_sig;
        when X"26" => data_to_cpu_sig <= c167_reg38_sig;
        when X"27" => data_to_cpu_sig <= c167_reg39_sig;
        when X"28" => data_to_cpu_sig <= c167_reg40_sig;
        when X"29" => data_to_cpu_sig <= c167_reg41_sig;
        when X"2a" => data_to_cpu_sig <= c167_reg42_sig;
        when X"2b" => data_to_cpu_sig <= c167_reg43_sig;
        when X"2c" => data_to_cpu_sig <= c167_reg44_sig;
        when X"2d" => data_to_cpu_sig <= c167_reg45_sig;
        when X"2e" => data_to_cpu_sig <= c167_reg46_sig;
        when X"2f" => data_to_cpu_sig <= c167_reg47_sig;
        when X"30" => data_to_cpu_sig <= c167_reg48_sig;
        when X"31" => data_to_cpu_sig <= c167_reg49_sig;
        when X"32" => data_to_cpu_sig <= c167_reg50_sig;
        when X"33" => data_to_cpu_sig <= c167_reg51_sig;
        when X"34" => data_to_cpu_sig <= c167_reg52_sig;
        when X"35" => data_to_cpu_sig <= c167_reg53_sig;
        when X"36" => data_to_cpu_sig <= c167_reg54_sig;
        when X"37" => data_to_cpu_sig <= c167_reg55_sig;
        when X"38" => data_to_cpu_sig <= c167_reg56_sig;
        when X"39" => data_to_cpu_sig <= c167_reg57_sig;
        when X"3a" => data_to_cpu_sig <= c167_reg58_sig;
        when X"3b" => data_to_cpu_sig <= c167_reg59_sig;
        when X"3c" => data_to_cpu_sig <= c167_reg60_sig;
        when X"3d" => data_to_cpu_sig <= c167_reg61_sig;
        when X"3e" => data_to_cpu_sig <= c167_reg62_sig;
        when X"3f" => data_to_cpu_sig <= c167_reg63_sig;
        
        when others  => data_to_cpu_sig <= (others => '0');  
    end case;       
 	end process;   

	C167_reg_write: process(C167_CLK_sig)
	begin
	   if (rising_edge(C167_CLK_sig))  then
	     if(C167_WE_sig = '0') then
   	     case (C167_ADDR_sig) is
            when X"00" => c167_reg0_sig   <= data_from_cpu_sig;     
            when X"01" => c167_reg1_sig   <= data_from_cpu_sig;   
            when X"02" => c167_reg2_sig   <= data_from_cpu_sig;             
            when X"04" => c167_reg4_sig   <= data_from_cpu_sig;  
            when X"0B" => c167_reg11_w_sig   <= data_from_cpu_sig;
            when X"0D" => c167_reg13_sig  <= data_from_cpu_sig;
            when X"0E" => c167_reg14_sig  <= data_from_cpu_sig;
            when X"0F" => c167_reg15_sig  <= data_from_cpu_sig;
            when X"10" => c167_reg16_sig  <= data_from_cpu_sig;
            when X"11" => c167_reg17_sig  <= data_from_cpu_sig;
            when X"12" => c167_reg18_sig  <= data_from_cpu_sig;
            when X"13" => c167_reg19_sig  <= data_from_cpu_sig;
            when X"14" => c167_reg20_sig  <= data_from_cpu_sig;
            when X"15" => c167_reg21_sig  <= data_from_cpu_sig;
            when X"16" => c167_reg22_sig  <= data_from_cpu_sig;
            --the rest of the registers are read only
            when others  => null;  
         end case;
       end if;
     end if; 
     --special case of register 12
     if((C167_WE_sig = '0') AND ( c167_ADDR_sig = X"0C")) then 
       C167_reg12_CE_sig <= '1';
     else
       C167_reg12_CE_sig <= '0';
     end if;                                   
	end process;	

	
	-------------------------------------------------------------------------------
--mux64 for ROACHTP0

  mux_rtp0 : mux64
  	     port map (
            data_sel => c167_reg1_sig(5 downto 0),
            data_in(0)  => sum_data(0),        --Sum Data LSB channel 0
            data_in(1)  => sum_data(2),        --Sum Data LSB channel 1
            data_in(2)  => sum_data(4),        --          .
            data_in(3)  => sum_data(6),        --          .
            data_in(4)  => sum_data(8),        --          .
            data_in(5)  => sum_data(10),
            data_in(6)  => sum_data(12),
            data_in(7)  => sum_data(14),
            data_in(8)  => sum_data(16),
            data_in(9)  => sum_data(18),
            data_in(10) => sum_data(20),
            data_in(11) => sum_data(22),
            data_in(12) => sum_data(24),
            data_in(13) => sum_data(26),
            data_in(14) => sum_data(28),
            data_in(15) => sum_data(30),
            data_in(16) => sum_data(32),
            data_in(17) => sum_data(34),
            data_in(18) => sum_data(36),
            data_in(19) => sum_data(38),
            data_in(20) => sum_data(40),
            data_in(21) => sum_data(42),
            data_in(22) => sum_data(44),
            data_in(23) => sum_data(46),
            data_in(24) => sum_data(48),
            data_in(25) => sum_data(50),
            data_in(26) => sum_data(52),
            data_in(27) => sum_data(54),
            data_in(28) => sum_data(56),
            data_in(29) => sum_data(58),
            data_in(30) => sum_data(60),
            data_in(31) => sum_data(62),       --Sum Data LSB channel 31
            data_in(32) => TE_sig,
            data_in(33) => AUXTIME_sig,            
            data_in(34) => PPS_Maser_sig,
            data_in(35) => PPS_GPS_sig,            
            data_in(36) => c167_reg0_sig(0),   
            data_in(37) => c167_reg0_sig(7),                      
            data_in(38) => OneMsecRst,              
            data_in(39) => OneMsecCtr(0),
            data_in(40) => OneMsecCtr(1),
            data_in(41) => OneMsecCtr(2),
            data_in(42) => stat_p1_sig(0),
            data_in(43) => stat_p1_sig(2),
            data_in(44) => stat_p1_sig(6),  --prg(2) XOR prg(0)
            data_in(45) => stat_p1_sig(7),
            data_in(46) => stat_p1_sig(8),
            data_in(47) => stat_p3_sig(5),
            data_in(48) => stat_p3_sig(6),
            data_in(49) => stat_p3_sig(7),
            data_in(50) => FrameSync_sig,
            data_in(51) => PPS_GPS_sig,
            data_in(52) => TE_sig,
            data_in(53) => FrameSync_sig,
            data_in(54) => TIME0_sig,
            data_in(55) => TIME1_sig,
            data_in(56) => PPS_PIC_sig,
            data_in(57) => c167_reg14_sig(4),
            data_in(58) => PPS_PIC_adv_sig,           
            data_in(63 downto 59) => (others => '0'),
            data_out => ROACHTP(0)	     
  	     );
	     
--mux64 for ROACHTP1

  mux_rtp1 : mux64
  	     port map (
            data_sel => c167_reg2_sig(5 downto 0),
            data_in(0)  => sum_data(1),        --Sum Data MSB channel 0
            data_in(1)  => sum_data(3),        --Sum Data MSB channel 1
            data_in(2)  => sum_data(5),        --          .
            data_in(3)  => sum_data(7),        --          .
            data_in(4)  => sum_data(9),        --          .
            data_in(5)  => sum_data(11),
            data_in(6)  => sum_data(13),
            data_in(7)  => sum_data(15),
            data_in(8)  => sum_data(17),
            data_in(9)  => sum_data(19),
            data_in(10) => sum_data(21),
            data_in(11) => sum_data(23),
            data_in(12) => sum_data(25),
            data_in(13) => sum_data(27),
            data_in(14) => sum_data(29),
            data_in(15) => sum_data(31),
            data_in(16) => sum_data(33),
            data_in(17) => sum_data(35),
            data_in(18) => sum_data(37),
            data_in(19) => sum_data(39),
            data_in(20) => sum_data(41),
            data_in(21) => sum_data(43),
            data_in(22) => sum_data(45),
            data_in(23) => sum_data(47),
            data_in(24) => sum_data(49),
            data_in(25) => sum_data(51),
            data_in(26) => sum_data(53),
            data_in(27) => sum_data(55),
            data_in(28) => sum_data(57),
            data_in(29) => sum_data(59),
            data_in(30) => sum_data(61),
            data_in(31) => sum_data(63),        --Sum Data MSB channel 31
            data_in(32) => DATA2_sig(0),
            data_in(33) => DATA2_sig(1),
            data_in(34) => DATA2_sig(2),
            data_in(35) => stat_p1_sig(1),
            data_in(36) => stat_p1_sig(3),
            data_in(37) => stat_p1_sig(4),
            data_in(38) => stat_p1_sig(5),
            data_in(39) => stat_p3_sig(12),
            data_in(40) => stat_p3_sig(13),  --input data to PRG
            data_in(41) => PPS_Maser_sig,
            data_in(42) => PPS_GPS_sig,
            data_in(43) => TE_sig,
            data_in(44) => FrameSync_sig,
            data_in(45) => TIME0_sig,             --48-msec interrupt to C167, addr 0x2d
            data_in(46) => TIME1_sig,             --1-msec interrupt to C167, addr 0x2e
            data_in(47) => PPS_PIC_sig,           --internal 1 PPS, addr 0x2f
            data_in(48) => c167_reg14_sig(4),     --RunTG control signal, addr 0x30
            data_in(49) => sum_ch_demux_0_sig,    --demultiplexed data to fifo,LSB, addr 0x31
            data_in(50) => h_wr_en_sig,           --header write enable, address 0x32 
            data_in(51) => d_wr_en_sig,           --data write enable, address 0x33
            data_in(52) => FDOF_sig,              --data fifo overflow, address 0x34
            data_in(53) => FDPE_sig,              --data fifo program empty, low after 1000 words in memory,address 0x35
            data_in(54) => h_rd_en_sig,           --header read enable, addr 0x36
            data_in(55) => d_rd_en_sig,           --data read enable, addr 0x37            
            data_in(56) => To10GbeTxData_1_sig,   --LSB of data to 10 GbE module,address 0x38
            data_in(57) => To10GbeTxDataValid_sig,--data valid signal from formatter,address 0x39
            data_in(58) => To10GbeTxEOF_sig,      --LSB of data to 10 GbE module,address 0x3a            
            data_in(59) => PPS_read_sig,          --PIC 1PPS as captured by CFIFO,address 0x3b
            data_in(63 downto 60) => (others => '0'),
            data_out => ROACHTP(1)            
  	     );  	
  	     
--ROUTB(3 downto 0) test points  	          
  ROUTB_sig(0) <= test_ctr(7);
--  ROUTB_sig(1) <= test_ctr_fifo(7);
--  ROUTB_sig(1) <= OneMsecRst;
  ROUTB_sig(1) <= PPS_PIC_sig;
  ROUTB_sig(2) <= test_ctr_125(7);
  ROUTB_sig(3) <= C125;  
	
--process for generating test frequencies
get_tst_freq: process(adc_clk)
	begin
	  if(rising_edge(adc_clk)) then
	     test_ctr <= test_ctr + 1;
	  end if;
	end process;	
	
	--process for generating test frequency from 125 MHz clock
get_tst_freq2: process(C125)
	begin
	  if(rising_edge(C125)) then
	     test_ctr_125 <= test_ctr_125 + 1;
	  end if;
	end process;	
	
		--process for generating test frequencies
get_tst_freq3: process(CFIFO)
	begin
	  if(rising_edge(CFIFO)) then
	     test_ctr_fifo <= test_ctr_fifo + 1;
	  end if;
	end process;
	
   --temporary process for generating a 1msec tic until we integrate the timing generator module
   temp_1msec: process(C125)
   begin
     if(rising_edge(C125)) then
       if OneMsecRst = '1' then
         OneMsecCtr <= "000000000000000000";
         OneMsecRst <= '0';
         OneMsecCtr <= OneMsecCtr + 1;
       else
--       if OneMsecCtr = X"00003" then
         if OneMsecCtr = X"1E847" then
           OneMsecCtr <= "000000000000000000"; 
           OneMsecRst <= '1';
         else
           OneMsecCtr <= OneMsecCtr + 1;
         end if;
       end if;
     end if;  
   end process;	
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
end architecture vdif_arch;
