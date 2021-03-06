library ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.rdbe_pkg.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-- # $Id: opb_vdif_interface.vhd,v 1.25 2014/10/15 19:27:38 rlacasse Exp $

entity opb_vdif_interface is
  generic ( 

    -- Bus protocol parameters
    C_BASEADDR : std_logic_vector := X"00010000";
    C_HIGHADDR : std_logic_vector := X"0001FFFF";
    C_OPB_AWIDTH : integer := 32;
    C_OPB_DWIDTH : integer := 32;
    C_FAMILY : string := "virtex5";

    -- other parameters
    VERSION     : std_logic_vector(7 downto 0) := X"05";  --manually programmed version number
    ADDRHI      : std_logic_vector(23 downto 0) := X"000000";
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
      TIME0           : out std_logic;  --the 48 msec TE signal to the microprocessor interrupt
      TIME1           : out std_logic;  --the 1 msec TE signal to the microprocessor interrupt      
      DONE            : out std_logic;  --signal to indicate to microprocessor that FPGA is programmed.  Drive high      
      DLL             : out std_logic;  --signal to indicate that DLL is locked.  Eventually tie to MMCM.  For now tie high      

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
      ROUTB           : out std_logic_vector(3 downto 0);   --test points to JR1         

      -- 10GB Ethernet 
      reset10GBE      : out std_logic      
    );
end entity opb_vdif_interface;

architecture vdif_arch OF opb_vdif_interface
is
-------------------------------------------------------------------------------
   
    component  c167_interface
	     port(
		   uclk	       		: in std_logic;					-- processor clock 
		   read_write  		: in std_logic;					-- read and write selection, read_write='1' => read, '0' => write
		   ctrl_data		: in std_logic; 				-- control data selector, ctr_data='1' => control, '0' => data 
		   c167_data_I		: in std_logic_vector (7 downto 0); 		-- bus connection with the c167, bidirectional
		   c167_data_O		: out std_logic_vector (7 downto 0); 		-- bus connection with the c167, bidirectional
		   data_from_cpu	: out std_logic_vector (7 downto 0); 		-- data_from_CPU, must be used together with C167_WE and C167_ADDR
		   data_to_cpu		: in std_logic_vector (7 downto 0);		-- data_to_CPU, must be used together with C167_ADDR
	     	   C167_WE      	: out std_logic;                    		-- new write enable signal
	           C167_ADDR      	: out std_logic_vector(7 downto 0); 		-- new address bus		   
		   C167_CLK		: out std_logic					-- C167 clock signal, the first 4 clocks were removed.
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
          Grs_stat   : in std_logic;
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
          sum_di     : out std_logic_vector(63 downto 0);
          ditp0      : out std_logic;
          ditp1      : out std_logic;
          ditp2      : out std_logic 
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
         OneMsec_pic        : out std_logic; 											-- 8-ns wide 1-msec pulse for data_interface
         TIME1             	: out std_logic; 				-- for c167 1-msec interrupt; 
         TIME0             	: out std_logic; 				-- for c167 48-msec interrupt;
         one_PPS_PIC       	: out std_logic; 				-- for monitoring internal 1 PPS (LVDS output)
         one_PPS_MASER_OFF 	: out std_logic_vector(27 downto 0); 	-- maser vs local 1PPS offset
         one_PPS_GPS_OFF   	: out std_logic_vector(27 downto 0); 	-- gps vs local 1PPS offset
         one_PPS_TE_OFF   	: out std_logic_vector(27 downto 0); 	-- TE vs local 1PPS offset measured at seconds 0, 6, ...
	       								-- latched high when internal and external TE are not coincident
         								-- cleared to low by reset_te bit = 1 from uP_interface
         TE_Err          	: out std_logic;         
         reset_te        	: in  std_logic;		        -- high resets TE_Err
         one_PPS_PIC_adv    : out std_logic;
         nchan              : in std_logic_vector(4 downto 0);     --log base 2 of number of channels
         samp_PPS_Ctr       : out std_logic_vector(27 downto 0);  --the 1PPS counter sampled at the TE rising edge
         tgtp0              : out std_logic;  --general purpose test points
         tgtp1              : out std_logic;
         tgtp2              : out std_logic          

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
        statusWord0         : in std_logic_vector(31 downto 0);
        statusWord1         : in std_logic_vector(31 downto 0);
        statusWord2         : in std_logic_vector(31 downto 0);
        statusWord3         : in std_logic_vector(31 downto 0);
        statusWord4         : in std_logic_vector(31 downto 0);
        statusWord5         : in std_logic_vector(31 downto 0);
        statusWord6         : in std_logic_vector(31 downto 0);
        statusWord7         : in std_logic_vector(31 downto 0);

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
        
        coll_out_C167       : out std_logic_vector(7 downto 0); --captured header
        psn_out 	    : out std_logic_vector(63 downto 0)  --captured PSN

       );
     end component;           
-------------------------------------------------------------------------------

    -- clock management
    signal epb_clk : std_logic;         -- connected to OPB_Clk for now

    -- OPB management
    signal DeviceAddr    : std_logic_vector(31 downto 0);  -- original address
    signal DeviceDataIn  : std_logic_vector(31 downto 0);  -- original data in bus
    signal DeviceDataOut : std_logic_vector(31 downto 0);  -- original data out bus

 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------

    signal SyncWord     : std_logic_vector(31 downto 0);

    -- clock and data signals
    signal clk_p         : std_logic;
    signal clk_n         : std_logic;   
    signal sum_data      : std_logic_vector(63 downto 0);  
    signal DATA2_sig     : std_logic_vector(63 downto 0); -- connect data_interface to data_formatter

    --signals for opb acknowledge
    signal ackSigW         :  std_logic := '0';
    signal ackSigWZ1       :  std_logic := '0';
    signal ackSigR         :  std_logic := '0';
    signal ackSigRZ1       :  std_logic := '0';
    signal xferAck_sig     :  std_logic := '0';

    -- test signals
    signal test_port_sig : std_logic_vector(31 downto 0) := x"0000_0000";
    signal test_ctr        : std_logic_vector(7 downto 0)  := X"00";
    signal test_ctr_fifo   : std_logic_vector(7 downto 0)  := X"00";    
    signal test_ctr_125    : std_logic_vector(7 downto 0)  := X"00";      
    signal C125_ds         : std_logic;                    -- for testing C125 clock     
    signal C125            : std_logic;                    -- for testing C125 clock  
    signal C200		   : std_logic;	
    signal C200_ds	   : std_logic;
    signal ROUTB_sig       : std_logic_vector(3 downto 0) := "0000";
    signal td_out_sig      : std_logic_vector(63 downto 0) := X"0000_0000_0000_0000";
    
        
    --C167 registers
    signal c167_reg0_sig     :std_logic_vector(7 downto 0) := X"00";  --initialization register
    signal c167_reg1_sig     :std_logic_vector(7 downto 0);           --ROACHTP0 select
    signal c167_reg2_sig     :std_logic_vector(7 downto 0);           --ROACHTP1 select
    signal c167_reg3_sig     :std_logic_vector(7 downto 0) := X"00";           --    
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
    signal c167_reg18_sig     :std_logic_vector(7 downto 0);           --for byte 2 of PPS_TE_Off
    signal c167_reg19_sig     :std_logic_vector(7 downto 0);           --control register 5
    signal c167_reg20_sig     :std_logic_vector(7 downto 0);           --control register 6  
	  --reg21 is a read/write pair to get status data from the accessing the captured 1PPS
    signal c167_reg21_w_sig   :std_logic_vector(7 downto 0) := X"00";   --for writing to PPS_sel_c167
	  signal c167_reg21_r_sig   :std_logic_vector(7 downto 0) := X"00";   --for reading from cap_PPS_c167	      
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
    
    --c167 bus clock and control signals                                   -                                                                    
    signal C167_CLK_sig       :std_logic;                    --clock for those registers
    signal data_from_cpu_sig  : std_logic_vector(7 downto 0);    
    signal data_to_cpu_sig    : std_logic_vector(7 downto 0);  
    signal C167_WE_sig        :std_logic; --write to register when low and ctrl_data is low
    signal C167_ADDR_sig      :std_logic_vector(7 downto 0); --address for read/write
    signal apply_sig          :std_logic := '0';  --for testing apply_vdif_header
    signal RunTG_ctrl_sig     :std_logic := '0';  --for sync'ing to the 1PPS 
    signal RunFm_sig          : std_logic;                             --"run formatter" derived from c167_reg14_sig(5) sync'd to clock
    signal RunFm_ctrl_sig     : std_logic;                             --"run formatter" derived from c167_reg14_sig(5)       
    signal RunFm_ctrl2_sig    : std_logic;                             --"run formatter" derived from c167_reg14_sig(5)       
    signal RunFm_ctrl3_sig    : std_logic;                             --"run formatter" derived from c167_reg14_sig(5)       
    signal Grs_sig            : std_logic;                             --general reset for everything except data_formatter
    signal GrsFm_sig          : std_logic;                              --general reset for data_formatter
    
    --signals for DAC
    signal DAC_CLK_p_sig        : std_logic;
    signal DAC_CLK_n_sig        : std_logic; 
    signal DAC_IN_A_sig         : std_logic_vector(3 downto 0) := "0000"; -- for DAC A
    signal DAC_IN_B_sig         : std_logic_vector(3 downto 0) := "0000"; -- for DAC B
    
    -- system-timing-related signals
    signal PPS_PIC_sig          :std_logic := '0'; --FPGA-derived 1-PPS based on TE and command from CCC
    signal PPS_PIC_p_sig        :std_logic ;       --FPGA-derived 1-PPS based on TE and command from CCC buffer output
    signal PPS_PIC_n_sig        :std_logic ;       --FPGA-derived 1-PPS based on TE and command from CCC buffer output
    signal TE_sys_sig           :std_logic := '0'; --for output of differential buffer
    signal TE_sig               :std_logic := '0';
    signal TE_Z1_sig            :std_logic := '0';
    signal AUXTIME_sig          :std_logic := '0';    
    signal TIME0_sig            :std_logic := '0';
    signal TIME0_Z1_sig         :std_logic := '0';    
    signal TE_Pulse_sig         :std_logic := '0';    
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
   signal FrameNum_sig          : std_logic_vector (23 downto 0) := x"00_0000"; 	        -- for VDIF frame number
   signal FrameNum_sig_captured : std_logic_vector (23 downto 0) := x"AB_CDEF";          	-- for VDIF frame number
   signal epoch_sig             : std_logic_vector (29 downto 0) := b"00" & x"000_0000";   -- initial value for SFRE
   signal SFRE_sig              : std_logic_vector (29 downto 0) := b"00" & x"000_0000"; 	-- for VDIF seconds field
   signal OneMsec_pic_sig       : std_logic;                                              -- 1 msec pulse, 8-ns wide
   signal TIME1_sig             : std_logic := '0'; 											                    -- for c167 48-msec interrupt; drives MGT_TX_p10 (LVDS output)
   signal GPS_Offset_sig        : std_logic_vector(27 downto 0):= x"000_0000"; 	          -- maser vs local 1PPS offset
   signal Maser_Offset_sig      : std_logic_vector(27 downto 0):= x"000_0000"; 	          -- gps vs local 1PPS offset
   signal TE_Offset_sig         : std_logic_vector(27 downto 0):= x"000_0000"; 	          -- TE vs local 1PPS offset measured on seconds 0, 6, ...
   signal TE_Err_sig          	: std_logic := '0';
   signal PPS_PIC_adv_sig       : std_logic;
   signal nchan_sig             : std_logic_vector(4 downto 0) := "00101";     --log, base 2, of the number of channels
   signal samp_PPS_Ctr_sig      : std_logic_vector(27 downto 0) := X"000_0000";-- sampled 1-PPS coutner     
   
   --data_formatter related signals
   signal PSN_init_sig          : std_logic_vector (63 downto 0) ;  --initial packet serial number from CCC via C167
   signal badFrame_sig          : std_logic;                        --badFrame bit from C167
   signal refEpoch_sig          : std_logic_vector(5 downto 0);     --reference epoch from CCC via C167
   signal frameLength_sig       : std_logic_vector(23 downto 0);    --data frame length from CCC via C167
   signal threadID_sig          : std_logic_vector(9 downto 0);     --thread ID from CCC via C167
   signal stationID_sig         : std_logic_vector(15 downto 0);    --station ID from CCC via C167
   signal magicWord_sig         : std_logic_vector(23 downto 0);    --magic word from CCC via C167   
   signal statusWord0_sig       : std_logic_vector(31 downto 0);    --status from CCC via C167, C167 itself and FPGA 
   signal statusWord1_sig       : std_logic_vector(31 downto 0):= x"0000_0001";
   signal statusWord2_sig       : std_logic_vector(31 downto 0):= x"0000_0002";
   signal statusWord3_sig       : std_logic_vector(31 downto 0):= x"0000_0003";
   signal statusWord4_sig       : std_logic_vector(31 downto 0):= x"0000_0004";
   signal statusWord5_sig       : std_logic_vector(31 downto 0):= x"0000_0005";
   signal statusWord6_sig       : std_logic_vector(31 downto 0):= x"0000_0006";
   signal statusWord7_sig       : std_logic_vector(31 downto 0):= x"0000_0007";


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
   
    --status signals
    signal DONE_sig             :std_logic := '1';
    signal DLL_sig              :std_logic := '1';
    
    --statistics signals    
    signal stat_p3_sig          : std_logic_vector(23 downto 0) := X"03_0201";
    signal stat_p1_sig          : std_logic_vector(23 downto 0) := X"07_0605";
    signal stat_m1_sig          : std_logic_vector(23 downto 0) := X"0B_0A09";
    signal stat_m3_sig          : std_logic_vector(23 downto 0) := X"0F_0E0D";

    --auxiliary signal for operating the system monitor
    signal clkfbout             : std_logic;
    signal CLK_OUT2             : std_logic;
    signal clkout1              : std_logic;
    
    --test points from modules
    signal ditp0_sig    : std_logic;
    signal ditp1_sig    : std_logic;
    signal ditp2_sig    : std_logic; 
    signal tgtp0_sig    : std_logic;
    signal tgtp1_sig    : std_logic;
    signal tgtp2_sig    : std_logic;     
	
    --delay control signals
    type delay_profile is array (0 to 63) of std_logic_vector(4 downto 0);
    signal delay_reg			: delay_profile;
    signal int_delay_reg		: delay_profile;
    signal sum_data_out			: std_logic_vector(63 downto 0);	
    signal sum_data_out_b		: std_logic_vector(63 downto 0);	
    signal sum_data_out_bb		: std_logic_vector(63 downto 0);
    signal output_test			: std_logic;
    signal delay_reg_address		: std_logic_vector(5 downto 0);	
    signal int_delay_reg_address	: std_logic_vector(5 downto 0);	
    signal rdy0                 	: std_logic;	
    signal rdy1                 	: std_logic;	

    -- integer delay adjustment signals
    signal data_a               	: std_logic;	
    signal data_b               	: std_logic;	
    signal data_a_selection             : std_logic_vector(5 downto 0);
    signal data_b_selection             : std_logic_vector(5 downto 0);
    signal integer_delay_error          : std_logic;
    signal integer_delay_error_reset    : std_logic;
    signal current_int_delay		: std_logic_vector(5 downto 0);

    -- System monitor	
    signal CHANNEL_OUT			: std_logic_vector(4 downto 0);
    signal DO_OUT			: std_logic_vector(15 downto 0);
    signal temperature			: std_logic_vector(15 downto 0);
    signal DRDY			    	: std_logic;

    -- Port and IP addresses	
    signal tx_dest_ip_sig      		: std_logic_vector(31 downto 0):= X"C0A8_0311";   	--Destination IP address
    signal tx_dest_port_sig    		: std_logic_vector(15 downto 0):= X"EA60";   		--Destination port

    signal To10GbeTxDataValid_sig2    	: std_logic;
    signal To10GbeTxEOF_sig2     	: std_logic;
    signal To10GbeTxData2		: std_logic_vector(63 downto 0);
    signal To10GbeTxData_sig		: std_logic_vector(63 downto 0);
    signal send_data_pattern_cnt	: std_logic_vector(31 downto 0);
    signal psn_out_sig			: std_logic_vector(63 downto 0);
    signal every6seconds     	        : std_logic;
    signal test_counter			: std_logic_vector(7 downto 0);

    signal prn_run_sig   		: std_logic;
    signal prn_re_seed_sig	: std_logic;    
    signal stat_start_sig 		: std_logic;
    signal stat_rdy_sig			: std_logic;
    signal Grs_stat_sig			: std_logic;

    signal kill_enable_from_c167	: std_logic:='0';
    signal kill_control	  		: std_logic:='0';
    signal kill_counter 		: std_logic_vector(7 downto 0):=X"00";

    signal PPS_PIC_Z1_sig   		: std_logic;

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
   
   
   
  -- IODELAYE1s for sum data

     iodelay_data_inputs: for i in 0 to 63 generate
     begin
  	io_delay: IODELAYE1
       	generic map (
  	CINVCTRL_SEL => FALSE, 			-- Enable dynamic clock inversion ("TRUE"/"FALSE")
  	DELAY_SRC => "I", 			-- Delay input ("I", "CLKIN", "DATAIN", "IO", "O")
  	HIGH_PERFORMANCE_MODE => TRUE, 		-- Reduced jitter ("TRUE"), Reduced power ("FALSE")
  	IDELAY_TYPE => "VAR_LOADABLE", 		-- "DEFAULT", "FIXED", "VARIABLE", or "VAR_LOADABLE"
  	IDELAY_VALUE => 0, 			-- Input delay tap setting (0-32)
  	ODELAY_TYPE => "FIXED", 		-- "FIXED", "VARIABLE", or "VAR_LOADABLE"
  	ODELAY_VALUE => 0, 			-- Output delay tap setting (0-32)
  	REFCLK_FREQUENCY => 200.0, 		-- IDELAYCTRL clock input frequency in MHz
  	SIGNAL_PATTERN => "DATA" 		-- "DATA" or "CLOCK" input signal
  	)
  	port map(
  	CNTVALUEOUT => OPEN,	 		-- 5-bit output - Counter value for monitoring purpose
  	DATAOUT => sum_data_out(i), 		-- 1-bit output - Delayed data output
  	C => C125, 				-- 1-bit input - Clock input
  	CE => '0', 				-- 1-bit input - Active high enable increment/decrement function
  	CINVCTRL => '0', 			-- 1-bit input - Dynamically inverts the Clock (C) polarity
  	CLKIN => '0', 				-- 1-bit input - Clock Access into the IODELAY
  	CNTVALUEIN => delay_reg(i), 		-- 5-bit input - Counter value for loadable counter application
  	DATAIN => '0', 				-- 1-bit input - Internal delay data
  	IDATAIN => sum_data(i), 		-- 1-bit input - Delay data input
 	INC => '0', 				-- 1-bit input - Increment / Decrement tap delay
  	ODATAIN => '0', 			-- 1-bit input - Data input for the output datapath from the device
  	RST => '1', 				-- 1-bit input - Active high, synchronous reset, resets delay chain to IDELAY_VALUE/
						-- ODELAY_VALUE tap. If no value is specified, the default is 0.
  	T => '1' 				-- 1-bit input - 3-state input control. Tie high for input-only or internal delay or
						-- tie low for output only.
 	);
     end generate iodelay_data_inputs;




-- End of IODELAYE1_inst instantiation	

  	idelayctrlInst0 : IDELAYCTRL
  	port map (
  	RDY => rdy0, 				-- 1-bit output indicates validity of the REFCLK
  	REFCLK => C200, 			-- 1-bit reference clock input
  	RST => '0' 				-- 1-bit reset input
 	);

  	idelayctrlInst1 : IDELAYCTRL
  	port map (
  	RDY => rdy1, 				-- 1-bit output indicates validity of the REFCLK
  	REFCLK => C200, 			-- 1-bit reference clock input
  	RST => '0' 				-- 1-bit reset input
  	);

    c167_reg3_sig(4) <= rdy1 and rdy0;   
   
   
   
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
      sum_data   => sum_data_out_bb,
      C125       => C125,        
      Grs        => Grs_sig,          --control reg 0, bit 2 from C167    
      Grs_stat   => Grs_stat_sig,      
      chan       => c167_reg16_sig(5 downto 0), --control reg 2, bits 5 to 0 from C167       
      stat_msec  => c167_reg17_sig(6 downto 0), --control reg 3, bits 6 to 0 from C167       
      prn_run    => prn_run_sig,          	--control reg 1, bit 0 from C167     
      stat_start => stat_start_sig,          	--control reg 1, bit 1 from C167
      OneMsec    => OneMsec_pic_sig,     
      ecnt       => c167_reg34_sig,             --error counter reg, target 34        
      stat_p3    => stat_p3_sig, --statistics, +3, 3 bytes max
      stat_p1    => stat_p1_sig, --statistics, +1, 3 bytes max     
      stat_m1    => stat_m1_sig, --statistics, -1, 3 bytes max
      stat_m3    => stat_m3_sig, --statistics, +3, 3 bytes max
      stat_rdy   => stat_rdy_sig,    
      td_sel     => td_sel_sig,      
      frm_sync   => TE_Pulse_sig,    
      td_out     => td_out_sig,  
      data_sel   => data_sel_sig,
      sum_di     => DATA2_sig, 
      ditp0      => ditp0_sig, 
      ditp1      => ditp1_sig, 
      ditp2      => ditp2_sig 
      
   );
   

   
   fdre_inputs: for i in 0 to 63 generate
   begin
	fdre_inputs: FDRE
	port map (
	Q => sum_data_out_b(i), 	-- Data output
	C => C125,	 				-- Clock input
	CE => '1', 					-- Clock enable input
	R => '0', 					-- Synchronous reset input
	D => sum_data_out(i) 		-- Data input
	);
   end generate fdre_inputs;
   
   sr_inputs: for i in 0 to 63 generate
   begin
	SRL16E_inst : SRL16E
	generic map (
	INIT => X"0000")
	port map (
	Q => sum_data_out_bb(i), 	-- SRL data output
	A0 => int_delay_reg(i)(0), 	-- Select[0] input
	A1 => int_delay_reg(i)(1), 	-- Select[1] input
	A2 => int_delay_reg(i)(2), 	-- Select[2] input
	A3 => int_delay_reg(i)(3), 	-- Select[3] input
	CE => '1', 			-- Clock enable input
	CLK => C125, 			-- Clock input
	D => sum_data_out_b(i) 		-- SRL data input
	);
   end generate sr_inputs;

   
   -- timing generator connection
   timing_generator_0: timing_generator
   port map(

          Grs                => Grs_sig,            
          RunTG              => RunTG_ctrl_sig,     -- rising edge and TE used to start timing generator
          RunFm              => RunFm_sig,          --rising edge (and 1 PPS) used to start formatter and part of timing gen
          C125               => C125,               
          one_PPS_Maser      => PPS_Maser_sig,      
          One_PPS_GPS        => PPS_GPS_sig,        
          TE                 => TE_sig,             
          SFRE_Init          => SFRE_init_sig,      -- to data formatter
          FrameSync          => FrameSync_sig,      -- to data formatter
          FrameNum           => FrameNum_sig,       -- to data formatter
--          epoch              => epoch_sig,          -- needs to be added    IN  replaced by SFRE_init
          SFRE               => SFRE_sig,           -- to data formatter
          OneMsec_pic        => OneMsec_pic_sig, 		-- 8-ns wide 1-msec pulse for data_interface
          TIME0              => TIME0_sig,          -- 48 msec interrupt to C167
          TIME1              => TIME1_sig,          -- 1 msec interrupt to C167
          one_PPS_PIC        => PPS_PIC_sig,        
          one_PPS_Maser_OFF  => Maser_Offset_sig,   
          one_PPS_GPS_OFF    => GPS_Offset_sig,     
          one_PPS_TE_OFF     => TE_Offset_sig,          
          TE_Err             => c167_reg3_sig(0),   
          reset_TE           => c167_reg0_sig(1),         
          one_PPS_PIC_adv    => PPS_PIC_adv_sig,
          nchan              => nchan_sig,
          samp_PPS_Ctr       => samp_PPS_Ctr_sig,
          tgtp0              => tgtp0_sig,
          tgtp1              => tgtp1_sig,
          tgtp2              => tgtp2_sig
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
      statusWord0   => statusWord0_sig,  --header data from various sources
      statusWord1   => statusWord1_sig,  --header data from various sources
      statusWord2   => statusWord2_sig,  --header data from various sources
      statusWord3   => statusWord3_sig,  --header data from various sources
      statusWord4   => statusWord4_sig,  --header data from various sources
      statusWord5   => statusWord5_sig,  --header data from various sources
      statusWord6   => statusWord6_sig,  --header data from various sources
      statusWord7   => statusWord7_sig,  --header data from various sources

      CFIFO         => CFIFO,           --output rate clock ~143 MHz
      C125          => C125,            --correlator clock, 125 MHz
      FrameSync     => FrameSync_sig,   --frame sync pulse from timing gen 
      TE_PIC        => TIME0_sig,       --TE signal from timing gen; rising edge is detected by formatter
      PPS_PIC_Adv   => PPS_PIC_Adv_sig, --1 PPS from timing gen, 1 clock early
      PPS_PIC       => PPS_PIC_sig,     --1PPS from timing gen
      Grs           => GrsFm_sig,           --from C167; a 1 causes reset
      RunFM         => RunFm_sig,           --from C167;rising edge (and 1 PPS) used to start formatter and part of timing gen 
      hdr_sel_C167  => c167_reg11_w_sig(5 downto 0),  --used to select which part of header data captured at TE to transmit
      To10GbeTxData => To10GbeTxData_sig,           --three signals to 10 GbE module
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
      coll_out_C167 => coll_out_C167_sig,    --header data captured at TE, for status to C167
      psn_out       => psn_out_sig    --PSN out

   );
        
-- status words connections
    statusWord0_sig    <= VERSION
                          & X"000" & "000" 
                          & c167_reg14_sig(7 downto 6) -- data source selection
                          & kill_enable_from_c167      --forces first 1.92 usec of data to zero
                          & NOT c167_reg3_sig(4)       --delay controller error; 1 = error
                          & c167_reg3_sig(3)           --CRC error probably indicating SEU; 1 = error
                          & c167_reg3_sig(2)           --FPGA over-temperature; 1 = error
                          & NOT LOCKED_sig             --MMCM for CFIFO; 1 = error
                          & c167_reg3_sig(0)           --TE error; 1 = error
                          & badFrame_sig;              --duplicates Word 0, bit 31 as a sanity check
    statusWord1_sig    <= x"1" & GPS_Offset_sig;
    statusWord2_sig    <= x"2" & Maser_Offset_sig;
    statusWord3_sig    <= x"3" & TE_Offset_sig;    
    statusWord4_sig    <= x"4000" & temperature;
      



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
      O => TE_sys_sig, -- TE buffer output
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
  
  --connect DAC signals
  DAC_IN_A_sig <= test_ctr(7 downto 4);
  DAC_IN_B_sig <= test_ctr(7 downto 4); 
  
   --C167-related mappings
	
	process(C125) is
		begin 
		if rising_edge(C125) then
       			RunTG_ctrl_sig    	<= c167_reg14_sig(4);
       			RunFm_ctrl_sig    	<= c167_reg14_sig(5);       
       			Grs_sig           	<= c167_reg14_sig(3);    --General reset for all modules except data_formatter
       			Grs_stat_sig	  	<= c167_reg14_sig(2);    --Dedicated reset signal for the "sum_data_chk_0" entity.
       			GrsFm_sig         	<= c167_reg15_sig(3);    --General reset for data_formatter to allow restart independent of data_formatter
       			prn_run_sig   	  	<= c167_reg15_sig(0);    -- this is for the data-checker PRN
       			prn_re_seed_sig     <= c167_reg15_sig(2);    -- this is for the data-generator PRN
       			stat_start_sig    	<= c167_reg15_sig(1);    -- starts statistics aquisition.
       			kill_enable_from_c167	<= c167_reg14_sig(1);    -- enables the kill feature (zeroing the first data samples to be sent out by the pic)	   	
		end if;
	end process; 
       
       --because of conflicts between the FPGA requirements and ICD with Computing,
       --the DOUT bits of C167 control word must be mapped to td_sel and data_sel as follows                               ;

       process(C125,c167_reg14_sig(7 downto 6)) is
		begin
		if(rising_edge(C125)) then
			if kill_control='0' then
				case c167_reg14_sig(7 downto 6) is
					when "00"   => td_sel_sig <= "000";	--PRN, but NORMAL data will be selected, since data_sel_sig will "0"
					when "01"   => td_sel_sig <= "001";	--INC
					when "10"   => td_sel_sig <= "000";	--PRN
					when "11"   => td_sel_sig <= "010";	--Zeroes
					when others => td_sel_sig <= "000";	
				end case;
		       		data_sel_sig <= c167_reg14_sig(7) OR c167_reg14_sig(6);  
			else
				td_sel_sig 	<= "010";	--Zeroes
		       		data_sel_sig	<= '1';
			end if;			-- end if kill_control='0'
		end if;				-- end if rising_edge(C125)
       end process;	

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
       c167_reg42_sig(0)    <= stat_rdy_sig;
       
       --C167 header mapping
       PSN_init_sig       <= QREG12(32) & QREG12(33) & QREG12(34) & QREG12(35) & QREG12(36) & QREG12(37) & QREG12(38) & QREG12(39);
       badFrame_sig       <= c167_reg19_sig(0);   --C167 sets this bit based on latest data from CCC and local status info
       SFRE_init_sig      <= QREG12(28)(5 downto 0) & QREG12(29) & QREG12(30) & QREG12(31);
       refEpoch_sig       <= QREG12(24)(5 downto 0);
       nchan_sig       <= QREG12(20)(4 downto 0); 
       frameLength_sig    <= QREG12(21) & QREG12(22) & QREG12(23);
       threadID_sig       <= QREG12(16)(1 downto 0) & QREG12(17);
       stationID_sig      <= QREG12(18) & QREG12(19);
       magicWord_sig      <= QREG12(13) & QREG12(14) & QREG12(15);



            
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

       c167_reg31_sig <= TE_Offset_sig(7 downto 0);
       c167_reg32_sig <= TE_Offset_sig(15 downto 8); 
       c167_reg33_sig <= TE_Offset_sig(23 downto 16);
       c167_reg18_sig <= "0000" & TE_Offset_sig(27 downto 24);

           
       --misc status
       c167_reg3_sig(1) <= LOCKED_sig;
       c167_reg4_sig    <= VERSION;       
       c167_reg59_sig   <= FrameNum_sig_captured(7 downto 0);     
       c167_reg60_sig   <= FrameNum_sig_captured(15 downto 8);     
       c167_reg61_sig   <= FrameNum_sig_captured(23 downto 16);     
       --c167_reg60_sig <= SFRE_sig(7 downto 0);
       --c167_reg61_sig <= Maser_Offset_sig(7 downto 0);
       c167_reg62_sig <= FrameNum_sig(7 downto 0);   

      --C167 interupt signals
      TIME0 <= TIME0_sig; --48 ms
      TIME1 <= TIME1_sig; --1 ms
      
      --multiplex captured 1-PPS signals to reg21
      PPS_mux : process(C167_reg21_w_sig(1 downto 0), samp_PPS_Ctr_sig)
      begin
      	case c167_reg21_w_sig(1 downto 0) is
				  when "00"   => c167_reg21_r_sig <= samp_PPS_Ctr_sig(7 downto 0);	--LSB, etc.
				  when "01"   => c167_reg21_r_sig <= samp_PPS_Ctr_sig(15 downto 8);	--
				  when "10"   => c167_reg21_r_sig <= samp_PPS_Ctr_sig(23 downto 16);--
				  when "11"   => c167_reg21_r_sig <= "0000" & samp_PPS_Ctr_sig(27 downto 24);	--MS nibble
				  when others => c167_reg21_r_sig <= "00000000";	
			  end case;
      end process PPS_mux;
      
  --signals to 10 GbE module

TenGbe_selection : process(c167_reg0_sig(5))	--this process selects among simulated test pattern or real data produced by the analog sum.
begin
	if(c167_reg0_sig(5)='0') then		
	  To10GbeTxData		<= To10GbeTxData_sig;
	  To10GbeTxDataValid  	<= To10GbeTxDataValid_sig;
	  To10GbeTxEOF        	<= To10GbeTxEOF_sig; 
	  To10Gbe_CFIFO       	<= CFIFO;
	  reset10GBE 	        <= c167_reg0_sig(6) and not(To10GbeTxDataValid_sig);	-- reset10GBE will be asserte only if To10GbeTxDataValid is '0'
	else
	  To10GbeTxData	        <= To10GbeTxData2;
	  To10GbeTxDataValid    <= To10GbeTxDataValid_sig2;
	  To10GbeTxEOF          <= To10GbeTxEOF_sig2; 
	  To10Gbe_CFIFO         <= CFIFO;
	  reset10GBE 	        <= c167_reg0_sig(6) and not(To10GbeTxDataValid_sig2);	-- reset10GBE will be asserte only if To10GbeTxDataValid is '0'
	end if;
end process TenGbe_selection;
-------------------------

send_data_pattern : process(CFIFO)
begin
if (rising_edge(CFIFO)) then

	if send_data_pattern_cnt = X"0858_3B00" then
		send_data_pattern_cnt <= X"0000_0000";
	else
		send_data_pattern_cnt <= send_data_pattern_cnt + X"0000_0001";
	end if;

	if send_data_pattern_cnt < X"0000_0400" then
		To10GbeTxDataValid_sig2 <= '1';
	else
		To10GbeTxDataValid_sig2 <= '0';	
	end if;

	if send_data_pattern_cnt = X"0000_03FF" then
		To10GbeTxEOF_sig2 <= '1';
	else
		To10GbeTxEOF_sig2 <= '0';	
	end if;

	To10GbeTxData2 <= X"00000000" & send_data_pattern_cnt;

end if;
end process send_data_pattern;

capture_TE : process (C125)  --capture the TE input with the 125 MHz clock
begin
  if(rising_edge(C125)) then
    TE_sig <= TE_sys_sig;
  end if;
end process capture_TE;       

capture_ctrl : process (C125)  --capture critical control signals 
begin
  if(rising_edge(C125)) then
    RunFm_ctrl2_sig <= RunFm_ctrl_sig;    
    RunFm_ctrl3_sig <= RunFm_ctrl2_sig;    
    RunFm_sig <= RunFm_ctrl3_sig;    
  end if;
end process capture_ctrl;       
-------------------------

TE_pulse : process (C125)  --capture critical control signals 
begin
  if(rising_edge(C125)) then
    TIME0_Z1_sig <= TIME0_sig;    
    if (TIME0_sig = '1') AND (TIME0_Z1_sig = '0') AND (prn_re_seed_sig = '1')then 
      TE_Pulse_sig <= '1';
    else  
      TE_Pulse_sig <= '0';
    end if;
  end if;
end process TE_pulse;       
-------------------------


  -- EPB register access process
    RegisterAccess : process(OPB_Rst, epb_clk, OPB_select,
                            OPB_RNW, DeviceAddr(18 downto 0))
    begin

    if (OPB_Rst = '1') then
        SyncWord <= x"ACABFEED";

    elsif rising_edge(epb_clk) then

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
              when others => null;
            end case;
            
          else				
					-- read
 
            case (DeviceAddr(7 downto 2)) is
            when "000000" => DeviceDataOut <= c167_reg0_sig & c167_reg1_sig & c167_reg2_sig & c167_reg3_sig ;      				--registers 0,1,2,3
            when "000001" => DeviceDataOut <= c167_reg4_sig & c167_reg5_sig & c167_reg6_sig & c167_reg7_sig ;      				--registers 4,5,6,7
            when "000010" => DeviceDataOut <= c167_reg8_sig & c167_reg9_sig & c167_reg10_sig & c167_reg11_r_sig ;      			--registers 8,9,10,11
            when "000011" => DeviceDataOut <= c167_reg12_Q_sig & c167_reg13_sig & c167_reg14_sig & c167_reg15_sig ;      		--registers 12,13,14,15
            when "000100" => DeviceDataOut <= c167_reg16_sig & c167_reg17_sig & c167_reg18_sig & c167_reg19_sig ;      			--registers 16,17,18,19
            when "000101" => DeviceDataOut <= c167_reg20_sig & c167_reg21_r_sig & c167_reg22_sig & c167_reg23_sig ;      			--registers 20,21,22,23
            when "000110" => DeviceDataOut <= c167_reg24_sig & c167_reg25_sig & c167_reg26_sig & c167_reg27_sig ;      			--registers 24,25,26,27
            when "000111" => DeviceDataOut <= c167_reg28_sig & c167_reg29_sig & c167_reg30_sig & c167_reg31_sig ;      			--registers 28,29,30,31
            when "001000" => DeviceDataOut <= c167_reg32_sig & c167_reg33_sig & c167_reg34_sig & c167_reg35_sig ;      			--registers 32,33,34,35
            when "001001" => DeviceDataOut <= c167_reg36_sig & c167_reg37_sig & c167_reg38_sig & c167_reg39_sig ;      			--registers 36,37,38,39
            when "001010" => DeviceDataOut <= c167_reg40_sig & c167_reg41_sig & c167_reg42_sig & c167_reg43_sig ;      			--registers 40,41,42,43
            when "001011" => DeviceDataOut <= c167_reg44_sig & c167_reg45_sig & c167_reg46_sig & c167_reg47_sig ;      			--registers 44,45,46,47
            when "001100" => DeviceDataOut <= c167_reg48_sig & c167_reg49_sig & c167_reg50_sig & c167_reg51_sig ;      			--registers 48,49,50,51			
            when "001101" => DeviceDataOut <= c167_reg52_sig & c167_reg53_sig & temperature(7 downto 0) & c167_reg55_sig ;      			--registers 52,53,54,55			
            when "001110" => DeviceDataOut <= c167_reg56_sig & c167_reg57_sig & temperature(15 downto 8) & c167_reg59_sig ;      			--registers 56,57,58,59
            when "001111" => DeviceDataOut <= c167_reg60_sig & c167_reg61_sig & c167_reg62_sig & c167_reg63_sig ;      			--registers 60,61,62,63
            when others => DeviceDataOut <= (others => '0');
            end case;

         end if;
         
      end if;

    end if;

    end process RegisterAccess;

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
		   data_to_cpu => data_to_cpu_sig, 		-- data_to_CPU, must be used together with C167_RR_EN(X) being 0<=X<=31		   
--		   C167_RD_EN => C167_RD_EN_sig,			-- Read enable signals, they must be individually connected to the tri-state controller associated to teh desired signals
--		   C167_WR_EN	=> C167_Wr_EN_sig,	-- Write enable signals, they must be individually connected to the "clock enable" associated to the addressed register.
		   C167_WE	=> C167_WE_sig,				-- C167 clock signal, the first 4 clocks were removed.
 		   C167_ADDR	=> C167_ADDR_sig,				-- C167 clock signal, the first 4 clocks were removed.
		   C167_CLK	=> C167_CLK_sig				-- C167 clock signal
	);
	
	--process for reading C167 interface
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
        when X"15" => data_to_cpu_sig <= c167_reg21_r_sig;
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
        when X"36" => data_to_cpu_sig <= temperature(7 downto 0);--c167_reg54_sig;
        when X"37" => data_to_cpu_sig <= c167_reg55_sig;
        when X"38" => data_to_cpu_sig <= c167_reg56_sig;
        when X"39" => data_to_cpu_sig <= c167_reg57_sig;
        when X"3a" => data_to_cpu_sig <= temperature(15 downto 8);--c167_reg58_sig;-- 
        when X"3b" => data_to_cpu_sig <= c167_reg59_sig;
        when X"3c" => data_to_cpu_sig <= c167_reg60_sig;
        when X"3d" => data_to_cpu_sig <= c167_reg61_sig;
        when X"3e" => data_to_cpu_sig <= c167_reg62_sig;
        when X"3f" => data_to_cpu_sig <= integer_delay_error & delay_reg_address(1 downto 0) & delay_reg(0);	-- debugging purposes
        
        when others  => data_to_cpu_sig <= (others => '0');  
    end case;       
 	end process;   

	C167_reg_write: process(C167_CLK_sig)
	begin
	   if (rising_edge(C167_CLK_sig))  then			-- IF level 1
	    if(C167_WE_sig = '0') then				-- IF level 2
	   	    case (C167_ADDR_sig) is
			    when X"00" => c167_reg0_sig   		<= data_from_cpu_sig;     
			    when X"01" => c167_reg1_sig   		<= data_from_cpu_sig;   
			    when X"02" => c167_reg2_sig   		<= data_from_cpu_sig;               
			    when X"0B" => c167_reg11_w_sig   		<= data_from_cpu_sig;
			    when X"0D" => c167_reg13_sig  		<= data_from_cpu_sig;
			    when X"0E" => c167_reg14_sig  		<= data_from_cpu_sig;
			    when X"0F" => c167_reg15_sig  		<= data_from_cpu_sig;
			    when X"10" => c167_reg16_sig  		<= data_from_cpu_sig;
			    when X"11" => c167_reg17_sig  		<= data_from_cpu_sig;
			    --when X"12" => c167_reg18_sig  		<= data_from_cpu_sig;  now used for TE_Offset MHB
			    when X"13" => c167_reg19_sig  		<= data_from_cpu_sig;
			    when X"14" => c167_reg20_sig  		<= data_from_cpu_sig;
			    when X"15" => c167_reg21_w_sig 		<= data_from_cpu_sig;
			    when X"16" => c167_reg22_sig  		<= data_from_cpu_sig;
			    when X"17" => delay_reg_address  		<= data_from_cpu_sig(5 downto 0);	
			    when X"19" => int_delay_reg_address  	<= data_from_cpu_sig(5 downto 0);	
			    when X"1B" => data_a_selection  		<= data_from_cpu_sig(5 downto 0);	
			    when X"1C" => data_b_selection	  	<= data_from_cpu_sig(5 downto 0);	
			    when X"1D" => integer_delay_error_reset     <= data_from_cpu_sig(0);	

			    --the rest of the registers are read only
			    when others  => null;  
		    end case;
	    end if;						-- END IF level 2
 
                         
     if((C167_WE_sig = '0') AND ( c167_ADDR_sig = X"18")) then	--IF level 2 
   	    case (delay_reg_address) is
		    when "000000" => delay_reg(0)    <= data_from_cpu_sig(4 downto 0);     
		    when "000001" => delay_reg(1)    <= data_from_cpu_sig(4 downto 0);     
		    when "000010" => delay_reg(2)    <= data_from_cpu_sig(4 downto 0);     
		    when "000011" => delay_reg(3)    <= data_from_cpu_sig(4 downto 0);     
		    when "000100" => delay_reg(4)    <= data_from_cpu_sig(4 downto 0);     
		    when "000101" => delay_reg(5)    <= data_from_cpu_sig(4 downto 0);     
		    when "000110" => delay_reg(6)    <= data_from_cpu_sig(4 downto 0);     
		    when "000111" => delay_reg(7)    <= data_from_cpu_sig(4 downto 0);     
		    when "001000" => delay_reg(8)    <= data_from_cpu_sig(4 downto 0);     
		    when "001001" => delay_reg(9)    <= data_from_cpu_sig(4 downto 0);     
		    when "001010" => delay_reg(10)   <= data_from_cpu_sig(4 downto 0);     
		    when "001011" => delay_reg(11)   <= data_from_cpu_sig(4 downto 0);     
		    when "001100" => delay_reg(12)   <= data_from_cpu_sig(4 downto 0);     
		    when "001101" => delay_reg(13)   <= data_from_cpu_sig(4 downto 0);     
		    when "001110" => delay_reg(14)   <= data_from_cpu_sig(4 downto 0);     
		    when "001111" => delay_reg(15)   <= data_from_cpu_sig(4 downto 0);     
		    when "010000" => delay_reg(16)   <= data_from_cpu_sig(4 downto 0);     
		    when "010001" => delay_reg(17)   <= data_from_cpu_sig(4 downto 0);     
		    when "010010" => delay_reg(18)   <= data_from_cpu_sig(4 downto 0);     
		    when "010011" => delay_reg(19)   <= data_from_cpu_sig(4 downto 0);     
		    when "010100" => delay_reg(20)   <= data_from_cpu_sig(4 downto 0);     
		    when "010101" => delay_reg(21)   <= data_from_cpu_sig(4 downto 0);     
		    when "010110" => delay_reg(22)   <= data_from_cpu_sig(4 downto 0);     
		    when "010111" => delay_reg(23)   <= data_from_cpu_sig(4 downto 0);     
		    when "011000" => delay_reg(24)   <= data_from_cpu_sig(4 downto 0);     
		    when "011001" => delay_reg(25)   <= data_from_cpu_sig(4 downto 0);     
		    when "011010" => delay_reg(26)   <= data_from_cpu_sig(4 downto 0);     
		    when "011011" => delay_reg(27)   <= data_from_cpu_sig(4 downto 0);     
		    when "011100" => delay_reg(28)   <= data_from_cpu_sig(4 downto 0);     
		    when "011101" => delay_reg(29)   <= data_from_cpu_sig(4 downto 0);     
		    when "011110" => delay_reg(30)   <= data_from_cpu_sig(4 downto 0);     
		    when "011111" => delay_reg(31)   <= data_from_cpu_sig(4 downto 0);     
		    when "100000" => delay_reg(32)   <= data_from_cpu_sig(4 downto 0);     
		    when "100001" => delay_reg(33)   <= data_from_cpu_sig(4 downto 0);     
		    when "100010" => delay_reg(34)   <= data_from_cpu_sig(4 downto 0);     
		    when "100011" => delay_reg(35)   <= data_from_cpu_sig(4 downto 0);     
		    when "100100" => delay_reg(36)   <= data_from_cpu_sig(4 downto 0);     
		    when "100101" => delay_reg(37)   <= data_from_cpu_sig(4 downto 0);     
		    when "100110" => delay_reg(38)   <= data_from_cpu_sig(4 downto 0);     
		    when "100111" => delay_reg(39)   <= data_from_cpu_sig(4 downto 0);     
		    when "101000" => delay_reg(40)   <= data_from_cpu_sig(4 downto 0);     
		    when "101001" => delay_reg(41)   <= data_from_cpu_sig(4 downto 0);     
		    when "101010" => delay_reg(42)   <= data_from_cpu_sig(4 downto 0);     
		    when "101011" => delay_reg(43)   <= data_from_cpu_sig(4 downto 0);     
		    when "101100" => delay_reg(44)   <= data_from_cpu_sig(4 downto 0);     
		    when "101101" => delay_reg(45)   <= data_from_cpu_sig(4 downto 0);     
		    when "101110" => delay_reg(46)   <= data_from_cpu_sig(4 downto 0);     
		    when "101111" => delay_reg(47)   <= data_from_cpu_sig(4 downto 0);     
		    when "110000" => delay_reg(48)   <= data_from_cpu_sig(4 downto 0);     
		    when "110001" => delay_reg(49)   <= data_from_cpu_sig(4 downto 0);     
		    when "110010" => delay_reg(50)   <= data_from_cpu_sig(4 downto 0);     
		    when "110011" => delay_reg(51)   <= data_from_cpu_sig(4 downto 0);     
		    when "110100" => delay_reg(52)   <= data_from_cpu_sig(4 downto 0);     
		    when "110101" => delay_reg(53)   <= data_from_cpu_sig(4 downto 0);     
		    when "110110" => delay_reg(54)   <= data_from_cpu_sig(4 downto 0);     
		    when "110111" => delay_reg(55)   <= data_from_cpu_sig(4 downto 0);     
		    when "111000" => delay_reg(56)   <= data_from_cpu_sig(4 downto 0);     
		    when "111001" => delay_reg(57)   <= data_from_cpu_sig(4 downto 0);     
		    when "111010" => delay_reg(58)   <= data_from_cpu_sig(4 downto 0);     
		    when "111011" => delay_reg(59)   <= data_from_cpu_sig(4 downto 0);     
		    when "111100" => delay_reg(60)   <= data_from_cpu_sig(4 downto 0);     
		    when "111101" => delay_reg(61)   <= data_from_cpu_sig(4 downto 0);     
		    when "111110" => delay_reg(62)   <= data_from_cpu_sig(4 downto 0);     
		    when "111111" => delay_reg(63)   <= data_from_cpu_sig(4 downto 0);     

		    --the rest of the registers are read only
		    when others  => null;  
            end case;
     end if;							--END IF level 2
     
     --special case for testing apply
     if((C167_WE_sig = '0') AND ( c167_ADDR_sig = X"0D")) then 
      apply_sig <= '1';
     else
      apply_sig <= '0';
     end if;							


     if((C167_WE_sig = '0') AND ( c167_ADDR_sig = X"1A")) then	--IF level 2 
   	    case (int_delay_reg_address) is
		    when "000000" => int_delay_reg(0)    <= data_from_cpu_sig(4 downto 0);     
		    when "000001" => int_delay_reg(1)    <= data_from_cpu_sig(4 downto 0);     
		    when "000010" => int_delay_reg(2)    <= data_from_cpu_sig(4 downto 0);     
		    when "000011" => int_delay_reg(3)    <= data_from_cpu_sig(4 downto 0);     
		    when "000100" => int_delay_reg(4)    <= data_from_cpu_sig(4 downto 0);     
		    when "000101" => int_delay_reg(5)    <= data_from_cpu_sig(4 downto 0);     
		    when "000110" => int_delay_reg(6)    <= data_from_cpu_sig(4 downto 0);     
		    when "000111" => int_delay_reg(7)    <= data_from_cpu_sig(4 downto 0);     
		    when "001000" => int_delay_reg(8)    <= data_from_cpu_sig(4 downto 0);     
		    when "001001" => int_delay_reg(9)    <= data_from_cpu_sig(4 downto 0);     
		    when "001010" => int_delay_reg(10)   <= data_from_cpu_sig(4 downto 0);     
		    when "001011" => int_delay_reg(11)   <= data_from_cpu_sig(4 downto 0);     
		    when "001100" => int_delay_reg(12)   <= data_from_cpu_sig(4 downto 0);     
		    when "001101" => int_delay_reg(13)   <= data_from_cpu_sig(4 downto 0);     
		    when "001110" => int_delay_reg(14)   <= data_from_cpu_sig(4 downto 0);     
		    when "001111" => int_delay_reg(15)   <= data_from_cpu_sig(4 downto 0);     
		    when "010000" => int_delay_reg(16)   <= data_from_cpu_sig(4 downto 0);     
		    when "010001" => int_delay_reg(17)   <= data_from_cpu_sig(4 downto 0);     
		    when "010010" => int_delay_reg(18)   <= data_from_cpu_sig(4 downto 0);     
		    when "010011" => int_delay_reg(19)   <= data_from_cpu_sig(4 downto 0);     
		    when "010100" => int_delay_reg(20)   <= data_from_cpu_sig(4 downto 0);     
		    when "010101" => int_delay_reg(21)   <= data_from_cpu_sig(4 downto 0);     
		    when "010110" => int_delay_reg(22)   <= data_from_cpu_sig(4 downto 0);     
		    when "010111" => int_delay_reg(23)   <= data_from_cpu_sig(4 downto 0);     
		    when "011000" => int_delay_reg(24)   <= data_from_cpu_sig(4 downto 0);     
		    when "011001" => int_delay_reg(25)   <= data_from_cpu_sig(4 downto 0);     
		    when "011010" => int_delay_reg(26)   <= data_from_cpu_sig(4 downto 0);     
		    when "011011" => int_delay_reg(27)   <= data_from_cpu_sig(4 downto 0);     
		    when "011100" => int_delay_reg(28)   <= data_from_cpu_sig(4 downto 0);     
		    when "011101" => int_delay_reg(29)   <= data_from_cpu_sig(4 downto 0);     
		    when "011110" => int_delay_reg(30)   <= data_from_cpu_sig(4 downto 0);     
		    when "011111" => int_delay_reg(31)   <= data_from_cpu_sig(4 downto 0);     
		    when "100000" => int_delay_reg(32)   <= data_from_cpu_sig(4 downto 0);     
		    when "100001" => int_delay_reg(33)   <= data_from_cpu_sig(4 downto 0);     
		    when "100010" => int_delay_reg(34)   <= data_from_cpu_sig(4 downto 0);     
		    when "100011" => int_delay_reg(35)   <= data_from_cpu_sig(4 downto 0);     
		    when "100100" => int_delay_reg(36)   <= data_from_cpu_sig(4 downto 0);     
		    when "100101" => int_delay_reg(37)   <= data_from_cpu_sig(4 downto 0);     
		    when "100110" => int_delay_reg(38)   <= data_from_cpu_sig(4 downto 0);     
		    when "100111" => int_delay_reg(39)   <= data_from_cpu_sig(4 downto 0);     
		    when "101000" => int_delay_reg(40)   <= data_from_cpu_sig(4 downto 0);     
		    when "101001" => int_delay_reg(41)   <= data_from_cpu_sig(4 downto 0);     
		    when "101010" => int_delay_reg(42)   <= data_from_cpu_sig(4 downto 0);     
		    when "101011" => int_delay_reg(43)   <= data_from_cpu_sig(4 downto 0);     
		    when "101100" => int_delay_reg(44)   <= data_from_cpu_sig(4 downto 0);     
		    when "101101" => int_delay_reg(45)   <= data_from_cpu_sig(4 downto 0);     
		    when "101110" => int_delay_reg(46)   <= data_from_cpu_sig(4 downto 0);     
		    when "101111" => int_delay_reg(47)   <= data_from_cpu_sig(4 downto 0);     
		    when "110000" => int_delay_reg(48)   <= data_from_cpu_sig(4 downto 0);     
		    when "110001" => int_delay_reg(49)   <= data_from_cpu_sig(4 downto 0);     
		    when "110010" => int_delay_reg(50)   <= data_from_cpu_sig(4 downto 0);     
		    when "110011" => int_delay_reg(51)   <= data_from_cpu_sig(4 downto 0);     
		    when "110100" => int_delay_reg(52)   <= data_from_cpu_sig(4 downto 0);     
		    when "110101" => int_delay_reg(53)   <= data_from_cpu_sig(4 downto 0);     
		    when "110110" => int_delay_reg(54)   <= data_from_cpu_sig(4 downto 0);     
		    when "110111" => int_delay_reg(55)   <= data_from_cpu_sig(4 downto 0);     
		    when "111000" => int_delay_reg(56)   <= data_from_cpu_sig(4 downto 0);     
		    when "111001" => int_delay_reg(57)   <= data_from_cpu_sig(4 downto 0);     
		    when "111010" => int_delay_reg(58)   <= data_from_cpu_sig(4 downto 0);     
		    when "111011" => int_delay_reg(59)   <= data_from_cpu_sig(4 downto 0);     
		    when "111100" => int_delay_reg(60)   <= data_from_cpu_sig(4 downto 0);     
		    when "111101" => int_delay_reg(61)   <= data_from_cpu_sig(4 downto 0);     
		    when "111110" => int_delay_reg(62)   <= data_from_cpu_sig(4 downto 0);     
		    when "111111" => int_delay_reg(63)   <= data_from_cpu_sig(4 downto 0);     
		    --the rest of the registers are read only
		    when others  => null;  
            end case;
     end if;							--END IF level 2

     end if;							--END IF level 1

     --special case of register 12
     if((C167_WE_sig = '0') AND ( c167_ADDR_sig = X"0C")) then 	--IF level 1
       C167_reg12_CE_sig <= '1';
     else
       C167_reg12_CE_sig <= '0';
      end if;							-- END IF level 1          

	end process;
	
	-------------------------------------------------------------------------------
--mux64 for ROACHTP0

  mux_rtp0 : mux64
  	     port map (
            data_sel => c167_reg1_sig(5 downto 0),
            data_in(0)  => c167_reg14_sig(03),  --Grs
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
            data_in(29) => stat_start_sig,
            data_in(30) => To10GbeTxDataValid_sig,	--0x1E
            data_in(31) => To10GbeTxEOF_sig,		--0x1F
            data_in(32) => TE_sig,             --0x20
            data_in(33) => AUXTIME_sig,            
            data_in(34) => PPS_Maser_sig,
            data_in(35) => PPS_GPS_sig,            
            data_in(36) => c167_reg0_sig(0),   
            data_in(37) => c167_reg0_sig(7),                      
            data_in(38) => ditp0_sig,          --init_ctr from data interface,0x26
            data_in(39) => ditp1_sig,          -- ctr LSB, 0x27
            data_in(40) => ditp2_sig,
            data_in(41) => every6seconds,
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
            data_in(53) => FrameNum_sig(0),
            data_in(54) => TIME0_sig,
            data_in(55) => TIME1_sig,
            data_in(56) => TE_Pulse_sig,
            data_in(57) => RunFm_sig,  --RunFm, address 0x39
            data_in(58) => PPS_PIC_adv_sig,
            data_in(59) => OneMsec_pic_sig,
            data_in(60) => apply_sig,           
            data_in(61) => CFIFO_Z1_sig, 
            data_in(62) => To10GbeTxData2(0),          
            data_in(63) => open,   --address 0x3f
            data_out => ROACHTP(0)	     
  	     );
	     
--mux64 for ROACHTP1

  mux_rtp1 : mux64
  	     port map (
            data_sel => c167_reg2_sig(5 downto 0),
            data_in(0)  => tgtp0_sig,     --sum_data(1),        --Sum Data MSB channel 0
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
            data_in(31) => kill_control,        --Sum Data MSB channel 31
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
            data_in(44) => FrameSync_sig,         --high 1 clock at beg of each frame, 0x2c
            data_in(45) => TIME0_sig,             --48-msec interrupt to C167, addr 0x2d
            data_in(46) => TIME1_sig,             --1-msec interrupt to C167, addr 0x2e
            data_in(47) => PPS_PIC_sig,           --internal 1 PPS, addr 0x2f
            data_in(48) => RunTG_ctrl_sig,     --RunTG control signal, addr 0x30
            data_in(49) => sum_ch_demux_0_sig,    --demultiplexed data to fifo,LSB, addr 0x31
            data_in(50) => h_wr_en_sig,           --header write enable, address 0x32 
            data_in(51) => d_wr_en_sig,           --data write enable, address 0x33
            data_in(52) => stat_rdy_sig,          --statistics ready, address 0x34
            data_in(53) => FDPE_sig,              --data fifo program empty, low after 1000 words in memory,address 0x35
            data_in(54) => h_rd_en_sig,           --header read enable, addr 0x36
            data_in(55) => d_rd_en_sig,           --data read enable, addr 0x37            
            data_in(56) => To10GbeTxData_1_sig,   --LSB of data to 10 GbE module,address 0x38
            data_in(57) => To10GbeTxDataValid_sig2,--data valid signal from formatter,address 0x39
            data_in(58) => To10GbeTxEOF_sig2,      --LSB of data to 10 GbE module,address 0x3a            
            data_in(59) => PPS_read_sig,          --PIC 1PPS as captured by CFIFO,address 0x3b
            data_in(60) => tgtp2_sig,                 --sum_in_bit_Z1 from data interface
            data_in(61) => To10GbeTxDataValid_sig,
            data_in(62) => To10GbeTxEOF_sig,
            data_in(63) => every6seconds,
            data_out => ROACHTP(1)            
  	     );  	
  	     
--ROUTB(3 downto 0) test points  	          
  ROUTB_sig(0) <= PPS_PIC_sig;   --test_ctr(7);  --JR1-5
  ROUTB_sig(1) <= PPS_Maser_sig;                 --JR1-7
  ROUTB_sig(2) <= PPS_GPS_sig;        --JR1-9
  ROUTB_sig(3) <= TE_sys_sig;              --JR1-11
	
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
	


-------------
  mmcm_adv_inst_2 : MMCM_ADV
  generic map
   (BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    CLOCK_HOLD           => FALSE,
    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 1,
    CLKFBOUT_MULT_F      => 10.000,
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 10.000,
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKOUT1_DIVIDE       => 20,
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKOUT2_DIVIDE       => 5,
    CLKOUT2_PHASE        => 0.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT2_USE_FINE_PS  => FALSE,
    CLKIN1_PERIOD        => 10.000,
    REF_JITTER1          => 0.010)
  port map
    -- Output clocks
   (CLKFBOUT            => clkfbout,
    CLKFBOUTB           => OPEN,
    CLKOUT0             => OPEN,
    CLKOUT0B            => OPEN,
    CLKOUT1             => clkout1,
    CLKOUT1B            => OPEN,
    CLKOUT2             => C200_ds,
    CLKOUT2B            => OPEN,
    CLKOUT3             => OPEN,
    CLKOUT3B            => OPEN,
    CLKOUT4             => OPEN,
    CLKOUT5             => OPEN,
    CLKOUT6             => OPEN,
    -- Input clock control
    CLKFBIN             => clkfbout,
    CLKIN1              => adc_clk,
    CLKIN2              => '0',
    -- Tied to always select the primary input clock
    CLKINSEL            => '1',
    -- Ports for dynamic reconfiguration
    DADDR               => (others => '0'),
    DCLK                => '0',
    DEN                 => '0',
    DI                  => (others => '0'),
    DO                  => OPEN,
    DRDY                => OPEN,
    DWE                 => '0',
    -- Ports for dynamic phase shift
    PSCLK               => '0',
    PSEN                => '0',
    PSINCDEC            => '0',
    PSDONE              => OPEN,
    -- Other control and status signals
    LOCKED              => OPEN,
    CLKINSTOPPED        => OPEN,
    CLKFBSTOPPED        => OPEN,
    PWRDWN              => '0',
    RST                 => '0');
	
  -- Output buffering
  -------------------------------------


  clkout2_buf : BUFG
  port map
   (O   => CLK_OUT2,
    I   => clkout1);
	
  clkout3_buf : BUFG
  port map
   (O   => C200,
    I   => C200_ds);	


 SYSMON_INST : SYSMON
     generic map(
        INIT_40 => X"1000", -- config reg 0
        INIT_41 => X"20fe", -- config reg 1
        INIT_42 => X"0a00", -- config reg 2
        INIT_48 => X"0100", -- Sequencer channel selection
        INIT_49 => X"0000", -- Sequencer channel selection
        INIT_4A => X"0100", -- Sequencer Average selection
        INIT_4B => X"0000", -- Sequencer Average selection
        INIT_4C => X"0000", -- Sequencer Bipolar selection
        INIT_4D => X"0000", -- Sequencer Bipolar selection
        INIT_4E => X"0000", -- Sequencer Acq time selection
        INIT_4F => X"0000", -- Sequencer Acq time selection
        INIT_50 => X"b5ed", -- Temp alarm trigger
        INIT_51 => X"5999", -- Vccint upper alarm limit
        INIT_52 => X"e000", -- Vccaux upper alarm limit
        INIT_53 => X"a6b3",  -- Temp alarm OT upper
        INIT_54 => X"a93a", -- Temp alarm reset
        INIT_55 => X"5111", -- Vccint lower alarm limit
        INIT_56 => X"caaa", -- Vccaux lower alarm limit
        INIT_57 => X"a19b",  -- Temp alarm OT reset
        SIM_DEVICE => "VIRTEX6",
        SIM_MONITOR_FILE => "design.txt"
        )

port map (
        CONVST              => '0',
        CONVSTCLK           => '0',
        DADDR(6 downto 0)   => "0000000",
        DCLK                => CLK_OUT2,
        DEN                 => '1',
        DI(15 downto 0)     => "0000000000000000",
        DWE                 => '0',
        RESET               => '0',
        VAUXN(15 downto 0)  => "0000000000000000",
        VAUXP(15 downto 0)  => "0000000000000000",
        ALM                 => open,
        BUSY                => open,
        CHANNEL             => CHANNEL_OUT(4 downto 0),
        DO                  => DO_OUT(15 downto 0),
        DRDY                => DRDY,
        EOC                 => open,
        EOS                 => open,
        JTAGBUSY            => open,
        JTAGLOCKED          => open,
        JTAGMODIFIED        => open,
        OT                  => c167_reg3_sig(2),  --1 = error
        VN                  => '0',
        VP                  => '0'
         );

process(DRDY)
begin
	if(DRDY='1' and CHANNEL_OUT="00000") then
		temperature <= DO_OUT;
	end if;
end process;

-- FRAME_ECC_VIRTEX6: Configuration Frame Error Correction
-- Virtex-6
-- Xilinx HDL Libraries Guide, version 13.1
FRAME_ECC_VIRTEX6_inst : FRAME_ECC_VIRTEX6
generic map (
FARSRC => "EFAR", -- Determines if the output of FAR[23:0] configuration register points
-- to the FAR or EFAR. Sets configuration option register bit CTL0[7].
FRAME_RBT_IN_FILENAME => "NONE" -- This file is output by the ICAP_VIRTEX6 model and it contains Frame
-- Data information for the Raw Bitstream (RBT) file. The FRAME_ECC
-- model will parse this file, calculate ECC and output any error
-- conditions.
)
port map (
CRCERROR => c167_reg3_sig(3), -- 1-bit output: Output indicating a CRC error.  High = error
ECCERROR => OPEN, -- 1-bit output: Output indicating an ECC error
ECCERRORSINGLE => OPEN, -- 1-bit output: Output Indicating single-bit Frame ECC error detected.
FAR => OPEN, -- 24-bit output: Frame Address Register Value output
SYNBIT => OPEN, -- 5-bit output: Output bit address of error
SYNDROME => OPEN, -- 13-bit output: Output location of erroneous bit
SYNDROMEVALID => OPEN, -- 1-bit output: Frame ECC output indicating the SYNDROME output is
-- valid.
SYNWORD => OPEN -- 7-bit output: Word output in the frame where an ECC error has been
-- detected
);

mux_data_0: mux64
  	     port map (
            data_sel    => data_a_selection,
            data_in(0)  => sum_data_out_bb(0), 
            data_in(1)  => sum_data_out_bb(1),        
            data_in(2)  => sum_data_out_bb(2),        
            data_in(3)  => sum_data_out_bb(3),        
            data_in(4)  => sum_data_out_bb(4),        
            data_in(5)  => sum_data_out_bb(5),
            data_in(6)  => sum_data_out_bb(6),
            data_in(7)  => sum_data_out_bb(7),
            data_in(8)  => sum_data_out_bb(8),
            data_in(9)  => sum_data_out_bb(9),
            data_in(10) => sum_data_out_bb(10),
            data_in(11) => sum_data_out_bb(11),
            data_in(12) => sum_data_out_bb(12),
            data_in(13) => sum_data_out_bb(13),
            data_in(14) => sum_data_out_bb(14),
            data_in(15) => sum_data_out_bb(15),
            data_in(16) => sum_data_out_bb(16),
            data_in(17) => sum_data_out_bb(17),
            data_in(18) => sum_data_out_bb(18),
            data_in(19) => sum_data_out_bb(19),
            data_in(20) => sum_data_out_bb(20),
            data_in(21) => sum_data_out_bb(21),
            data_in(22) => sum_data_out_bb(22),
            data_in(23) => sum_data_out_bb(23),
            data_in(24) => sum_data_out_bb(24),
            data_in(25) => sum_data_out_bb(25),
            data_in(26) => sum_data_out_bb(26),
            data_in(27) => sum_data_out_bb(27),
            data_in(28) => sum_data_out_bb(28),
            data_in(29) => sum_data_out_bb(29),
            data_in(30) => sum_data_out_bb(30),
            data_in(31) => sum_data_out_bb(31),
            data_in(32) => sum_data_out_bb(32),
            data_in(33) => sum_data_out_bb(33),
            data_in(34) => sum_data_out_bb(34),
            data_in(35) => sum_data_out_bb(35),
            data_in(36) => sum_data_out_bb(36),
            data_in(37) => sum_data_out_bb(37),
            data_in(38) => sum_data_out_bb(38),
            data_in(39) => sum_data_out_bb(39),
            data_in(40) => sum_data_out_bb(40),  
            data_in(41) => sum_data_out_bb(41),
            data_in(42) => sum_data_out_bb(42),
            data_in(43) => sum_data_out_bb(43),
            data_in(44) => sum_data_out_bb(44),
            data_in(45) => sum_data_out_bb(45),
            data_in(46) => sum_data_out_bb(46),
            data_in(47) => sum_data_out_bb(47),
            data_in(48) => sum_data_out_bb(48),
            data_in(49) => sum_data_out_bb(49),
            data_in(50) => sum_data_out_bb(50),
            data_in(51) => sum_data_out_bb(51),
            data_in(52) => sum_data_out_bb(52),
            data_in(53) => sum_data_out_bb(53),
            data_in(54) => sum_data_out_bb(54),
            data_in(55) => sum_data_out_bb(55),
            data_in(56) => sum_data_out_bb(56),
            data_in(57) => sum_data_out_bb(57),
            data_in(58) => sum_data_out_bb(58),
            data_in(59) => sum_data_out_bb(59),
            data_in(60) => sum_data_out_bb(60),
            data_in(61) => sum_data_out_bb(61),
            data_in(62) => sum_data_out_bb(62),
            data_in(63) => sum_data_out_bb(63),
            data_out => data_a            
  	     );  


mux_data_1: mux64
  	     port map (
            data_sel    => data_b_selection,
            data_in(0)  => sum_data_out_bb(0), 
            data_in(1)  => sum_data_out_bb(1),        
            data_in(2)  => sum_data_out_bb(2),        
            data_in(3)  => sum_data_out_bb(3),        
            data_in(4)  => sum_data_out_bb(4),        
            data_in(5)  => sum_data_out_bb(5),
            data_in(6)  => sum_data_out_bb(6),
            data_in(7)  => sum_data_out_bb(7),
            data_in(8)  => sum_data_out_bb(8),
            data_in(9)  => sum_data_out_bb(9),
            data_in(10) => sum_data_out_bb(10),
            data_in(11) => sum_data_out_bb(11),
            data_in(12) => sum_data_out_bb(12),
            data_in(13) => sum_data_out_bb(13),
            data_in(14) => sum_data_out_bb(14),
            data_in(15) => sum_data_out_bb(15),
            data_in(16) => sum_data_out_bb(16),
            data_in(17) => sum_data_out_bb(17),
            data_in(18) => sum_data_out_bb(18),
            data_in(19) => sum_data_out_bb(19),
            data_in(20) => sum_data_out_bb(20),
            data_in(21) => sum_data_out_bb(21),
            data_in(22) => sum_data_out_bb(22),
            data_in(23) => sum_data_out_bb(23),
            data_in(24) => sum_data_out_bb(24),
            data_in(25) => sum_data_out_bb(25),
            data_in(26) => sum_data_out_bb(26),
            data_in(27) => sum_data_out_bb(27),
            data_in(28) => sum_data_out_bb(28),
            data_in(29) => sum_data_out_bb(29),
            data_in(30) => sum_data_out_bb(30),
            data_in(31) => sum_data_out_bb(31),
            data_in(32) => sum_data_out_bb(32),
            data_in(33) => sum_data_out_bb(33),
            data_in(34) => sum_data_out_bb(34),
            data_in(35) => sum_data_out_bb(35),
            data_in(36) => sum_data_out_bb(36),
            data_in(37) => sum_data_out_bb(37),
            data_in(38) => sum_data_out_bb(38),
            data_in(39) => sum_data_out_bb(39),
            data_in(40) => sum_data_out_bb(40),  
            data_in(41) => sum_data_out_bb(41),
            data_in(42) => sum_data_out_bb(42),
            data_in(43) => sum_data_out_bb(43),
            data_in(44) => sum_data_out_bb(44),
            data_in(45) => sum_data_out_bb(45),
            data_in(46) => sum_data_out_bb(46),
            data_in(47) => sum_data_out_bb(47),
            data_in(48) => sum_data_out_bb(48),
            data_in(49) => sum_data_out_bb(49),
            data_in(50) => sum_data_out_bb(50),
            data_in(51) => sum_data_out_bb(51),
            data_in(52) => sum_data_out_bb(52),
            data_in(53) => sum_data_out_bb(53),
            data_in(54) => sum_data_out_bb(54),
            data_in(55) => sum_data_out_bb(55),
            data_in(56) => sum_data_out_bb(56),
            data_in(57) => sum_data_out_bb(57),
            data_in(58) => sum_data_out_bb(58),
            data_in(59) => sum_data_out_bb(59),
            data_in(60) => sum_data_out_bb(60),
            data_in(61) => sum_data_out_bb(61),
            data_in(62) => sum_data_out_bb(62),
            data_in(63) => sum_data_out_bb(63),
            data_out => data_b            
  	     );  

test_integer_delay: process(C125) is
	variable state: std_logic :='0';
	begin
	  if(rising_edge(C125)) then
	     if(data_a=data_b and state='0') then
		integer_delay_error <= '0';
             else 
		integer_delay_error <= '1';
		state := '1';
	     end if;

	     if(integer_delay_error_reset='1') then
		state := '0';	
		integer_delay_error <= '0';	
	     end if;

	  end if;
	end process;



FDCE_TE : FDCE
port map (
Q => TE_Z1_sig, 	-- Data output
C => C125, 		-- Clock input
CE => '1', 		-- Clock enable input
CLR => '0', 		-- Asynchronous clear input
D => TE_sig 		-- Data input
);

process(C125) is  
  begin
	  if TE_sig='1' and TE_Z1_sig='0' and rising_edge(C125) then
		  FrameNum_sig_captured <= FrameNum_sig(23 downto 0);
	  end if; 
end process;


process(PPS_PIC_sig,C125) is

        begin
	if rising_edge(C125) then
		if PPS_PIC_sig='1' then
			test_counter <= test_counter + '1';
		end if;
		if test_counter=x"06" or RunTG_ctrl_sig='0' then
			test_counter <= x"00";
		end if;
		if test_counter=X"00" then
			every6seconds <='1';
		else
			every6seconds <='0';
		end if;
	end if; 
end process;


FDCE_PPS : FDCE
port map (
Q => PPS_PIC_Z1_sig, 	-- Data output
C => C125, 		-- Clock input
CE => '1', 		-- Clock enable input
CLR => '0', 		-- Asynchronous clear input
D => PPS_PIC_sig 	-- Data input
);

process(C125) is
begin
	if rising_edge(C125) then
		if kill_enable_from_c167='1' then
			if PPS_PIC_sig='1' and PPS_PIC_Z1_sig='0' then
				kill_counter <= X"00";			-- reset counter upon PPS rising edge
			end if;						-- end if TE_sig='1' and TE_Z1_sig='0'

			if kill_counter < X"F0" then
				kill_counter <= kill_counter + '1';
				kill_control <= '1';
			else
				kill_control <= '0';
			end if;						-- end if kill_counter < X"F0"
		else
			kill_control <= '0';
		end if;							-- end if kill_enable_from_c167='1' 
	end if;								-- end if rising_edge(C125)
end process;

end architecture vdif_arch;

