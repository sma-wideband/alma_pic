-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--Library UNISIM;
--use UNISIM.vcomponents.all;

-------------------------------------------------------
-- This component formats the sum data into a VDIF data frame and sends it to the 10 GbE module

-- $Id:  Exp $

entity data_formatter is
  port(
     
   --data to format from data interface (real sum or test data)
   sum_di    :  in std_logic_vector(63 downto 0);

   --data from which to form header from C167 and Timing Gen
   --see VDIF document for further info
      PSN_init    : in std_logic_vector(63 downto 0);--initial packet ser. num.
      badFrame    : in std_logic; --bit 31 word 0
      SFRE: in std_logic_vector(29 downto 0); --seconds from ref. epoch
      FrameNum : in std_logic_vector(23 downto 0); --data frame number
      refEpoch : in std_logic_vector(5 downto 0); --reference epoch
      nchan : in std_logic_vector(4 downto 0); --n_chan_log2
      frameLength : in std_logic_vector(23 downto 0);
      threadID    : in std_logic_vector(9 downto 0);
      stationID   : in std_logic_vector(15 downto 0);
      magicWord   : in std_logic_vector(23 downto 0);
      statusWord  : in std_logic_vector(31 downto 0);

   --timing and control signals
      --higher frequency clock for FIFO output, from timing_generator
      CFIFO  : in std_logic;

      --125 MHz clock, from timing_generator
      C125   : in std_logic;

      --high for one clock at the beginning of each frame
      FrameSync : in std_logic;  --from timing generator

      --high for one clock at each timing event (48 msec ALMA heartbeat)
      TE_PIC : in std_logic;  --from timing generator


      --internally generated advanced 1PPS from timing_generator
      PPS_PIC_Adv     : in std_logic;

      --internally generated 1PPS from timing_generator
      PPS_PIC     : in std_logic;

      --Grs is the general reset; initialize while = 1; from uP_interface
      Grs    : in std_logic;

      --Start transmitting frames at the next 1PPS (Grs needs to be zero)
      RunFm   : in std_logic; --from uP_interface

      --for selecting header data collected at TE
      hdr_sel_C167   : in std_logic_vector(5 downto 0); -- from uP_interface

   --connect to ten_Gbe module
   To10GbeTxData       : out std_logic_vector(63 downto 0);
   To10GbeTxDataValid  : out std_logic;
   To10GbeTxEOF        : out std_logic;

   --signals to go to test points for verification and monitoring
   sum_ch_demux_0     : out std_logic; --LSB of demux data
   hdr_sel_0          : out std_logic; --LSB of hdr_sel
   h_wr_en            : out std_logic; --header write enable
   d_wr_en            : out std_logic; --data write enable
   FHOF               : out std_logic; --header fifo overflow
   FDOF               : out std_logic; --data fifo overflow
   FDPE               : out std_logic; --data fifo program_empty
   h_rd_en            : out std_logic; --header read enable
   d_rd_en            : out std_logic; --data read enable   
   To10GbeTxData_1    : out std_logic; --LSB of transmit data
   --To10GbeTxDataValid : out std_logic; --data valid to test point, already declared above
   --To10GbeTxDataEOF   : out std_logic; --end of frame to test point, already declared above
   PPS_read           : out std_logic; --PPS PIC captured by CFIFO clock

   --status signals for C167
   --FHOF              : std_logic; --header fifo overflow, already declared above
   --FDOF              : std_logic; --data fifo overflow, already declared above
   coll_out_C167     : out std_logic_vector(7 downto 0) --captured header

  );
end data_formatter;

architecture comportamental of data_formatter is

  component  header_collator
    port(
       C125           : in std_logic;
       TE             : in std_logic;
       PSN            : in std_logic_vector(63 downto 0);
       badFrame       : in std_logic;
       SFRE           : in std_logic_vector(29 downto 0); --seconds from ref. epoch
       FrameNum       : in std_logic_vector(23 downto 0); --data frame number
       refEpoch       : in std_logic_vector(5 downto 0);
       nchan          : in std_logic_vector(4 downto 0);
       frameLength    : in std_logic_vector(23 downto 0);
       threadID       : in std_logic_vector(9 downto 0);
       stationID      : in std_logic_vector(15 downto 0);
       magicWord      : in std_logic_vector(23 downto 0);
       statusWord     : in std_logic_vector(31 downto 0);
       coll_out       : out std_logic_vector(63 downto 0); 
       Hdr_sel        : in std_logic_vector(2 downto 0);
       coll_out_c167  : out std_logic_vector(7 downto 0); 
       hdr_sel_c167   : in std_logic_vector(5 downto 0)     
     );
  end component;

  component channel_demux
	  port(
     sum_di    :  in std_logic_vector(63 downto 0);
     sum_ch_demux : out std_logic_vector(63 downto 0);
     nchan   : in std_logic_vector(4 downto 0); -- from uP_interface
     FrameSync : in std_logic;  --from timing generator
     C125   : in std_logic;
     Grs    : in std_logic;
     RunFm  : in std_logic --from uP_interface   
     );
  end component;
  
  component header_write_control
  port	(   
    Grs          : in std_logic;
    RunFm        : in std_logic; --from uP_interface
    C125         : in std_logic;
    FrameSync    : in std_logic;  --from timing generator
    PPS_PIC_Adv          : in std_logic;
    hdr_sel      : out std_logic_vector(2 downto 0);
    h_wr_en      : out std_logic;
    PSN_init     : in std_logic_vector(63 downto 0);
    PSN          : out std_logic_vector(63 downto 0)     
    );
  end component;

  component data_write_ctrl
	  port(
     Grs    : in std_logic;
     RunFm    : in std_logic; --from uP_interface
     C125   : in std_logic;
     FrameSync : in std_logic;  --from timing generator
     PPS_PIC_Adv : in std_logic;  --from timing generator
     nchan   : in std_logic_vector(4 downto 0); -- from uP_interface
     d_wr_en : out std_logic
     );
  end component;

  component fifo_66x2k_behav  --for synthesis
--  component fifo_66x2k_struct  --for simulation
    port	(   
      rst : in STD_LOGIC := 'X'; 
      wr_clk : in STD_LOGIC := 'X'; 
      rd_clk : in STD_LOGIC := 'X'; 
      wr_en : in STD_LOGIC := 'X'; 
      rd_en : in STD_LOGIC := 'X'; 
      full : out STD_LOGIC; 
      overflow : out STD_LOGIC; 
      empty : out STD_LOGIC; 
      valid : out STD_LOGIC; 
      prog_empty : out STD_LOGIC; 
      din : in STD_LOGIC_VECTOR ( 65 downto 0 ); 
      dout : out STD_LOGIC_VECTOR ( 65 downto 0 )     
    );
  end component;
    
  component read_control
    port	(      
      Grs                 : in std_logic;
      RunFm               : in std_logic; --from uP_interface
      PPS_PIC             : in std_logic;
      CFIFO               : in std_logic;
      nchan               : in std_logic_vector(4 downto 0); -- from uP_interface
      prog_empty          : in std_logic;
      h_fifo_out          : in std_logic_vector(63 downto 0); -- from header fifo
      d_fifo_out          : in std_logic_vector(63 downto 0); -- from data fifo      
      h_rd_en	            : out std_logic;
      d_rd_en	            : out std_logic;
      To10GbeTxData       : out std_logic_vector(63 downto 0);
      To10GbeTxDataValid  : out std_logic;
      To10GbeTxEOF        : out std_logic;
      PPS_read            : out std_logic  --PPS_PIC as captured by CFIFO
    );
  end component;	

  signal coll_out_sig       : std_logic_vector(63 downto 0);  --header collator output
  signal coll_out_sig2      : std_logic_vector(65 downto 0);  --header collator output
  signal d_fifo_out_sig     : std_logic_vector(63 downto 0);  --data fifo output data signal
  signal d_fifo_out_sig2    : std_logic_vector(65 downto 0);  --header fifo data output
  signal d_rd_en_sig        : std_logic;                      --data fifo read enable
  signal d_wr_en_sig        : std_logic;                      --data fifo write enable
  signal FDOF_sig           : std_logic;                      --data fifo overflow
  signal FDPE_sig           : std_logic;                      --data fifo program_empty
  signal FHOF_sig           : std_logic;                      --header fifo overflow
  signal Grs_Z1_sig         : std_logic;                      --Grs delayed by 1 clock
  signal Grs_Z2_sig         : std_logic;                      --Grs delayed by 2 clock
  signal Grs_Z3_sig         : std_logic;                      --Grs delayed by 3 clock
  signal Grs_Z4_sig         : std_logic;                      --Grs delayed by 4 clock
  signal Grs_Z5_sig         : std_logic;                      --Grs delayed by 5 clock
  signal h_fifo_out_sig     : std_logic_vector(63 downto 0);  --header fifo data output
  signal h_fifo_out_sig2    : std_logic_vector(65 downto 0);  --header fifo data output
  signal h_rd_en_sig        : std_logic;                      --header fifo read enable
  signal h_wr_en_sig        : std_logic;                      --header fifo write enable
  signal hdr_sel_sig        : std_logic_vector(2 downto 0);   --header select signal for header collator from header write control
  signal PSN_sig            : std_logic_vector(63 downto 0);  --packet serial number from header write control
  signal sum_ch_demux_sig   : std_logic_vector(63 downto 0);  --data ouput of channel demux module
  signal sum_ch_demux_sig2  : std_logic_vector(65 downto 0);  --data ouput of channel demux module
  signal To10GbeTxData_sig  : std_logic_vector(63 downto 0);  --data ouput 10 10 GbE module


begin

  hdr_sel_0         <= hdr_sel_sig(0);
  sum_ch_demux_0    <= sum_ch_demux_sig(0);
  To10GbeTxData     <= To10GbeTxData_sig;
  To10GbeTxData_1   <= To10GbeTxData_sig(1);
  d_fifo_out_sig    <= d_fifo_out_sig2(63 downto 0);
  h_fifo_out_sig    <= h_fifo_out_sig2(63 downto 0);
  coll_out_sig2     <= "00" & coll_out_sig(63 downto 0);  --trick to handle 65-bit wide fifo.
  sum_ch_demux_sig2 <= "00" & sum_ch_demux_sig(63 downto 0);
  fdpe              <= fdpe_sig;
  d_wr_en           <= d_wr_en_sig;
  h_wr_en           <= h_wr_en_sig;
  d_rd_en           <= d_rd_en_sig;
  h_rd_en           <= h_rd_en_sig;  
  FHOF              <= FHOF_sig;
  FDOF              <= FDOF_sig;

  header_collator0:  header_collator
    port map(
      C125          =>  C125,
      TE            =>  TE_PIC,
      PSN           =>  PSN_sig,
      badFrame      =>  badFrame,
      SFRE          =>  SFRE,
      FrameNum      =>  FrameNum,
      refEpoch      =>  refEpoch,
      nchan         =>  nchan,
      frameLength   =>  frameLength,
      threadID      =>  threadID,
      stationID     =>  stationID,
      magicWord     =>  magicWord,
      statusWord    =>  statusWord,
      coll_out      =>  coll_out_sig,
      hdr_sel       =>  hdr_sel_sig,
      coll_out_c167 =>  coll_out_c167,
      Hdr_sel_c167  =>  Hdr_sel_c167
     );        
	
  channel_demux0: channel_demux
	  port map(
      sum_di       => sum_di,
      sum_ch_demux => sum_ch_demux_sig,
      nchan        => nchan,
      FrameSync    => FrameSync,
      C125         => C125,
      Grs          => Grs,
      RunFm        => RunFm
    );
      
  header_write_control0: header_write_control
    port map(
      Grs         =>  Grs,
      RunFm       =>  RunFm,
      C125        =>  C125,
      FrameSync   =>  FrameSync,
      PPS_PIC_Adv =>  PPS_PIC_Adv,
      hdr_sel     =>  hdr_sel_sig,
      h_wr_en     =>  h_wr_en_sig,
      PSN_init    =>  PSN_init,
      PSN         =>  PSN_sig
      );    
      
  data_write_ctrl_0: data_write_ctrl
	  port map(
     Grs          =>  Grs,
     RunFm        =>  RunFm,
     C125         =>  C125,
     FrameSync    =>  FrameSync,
     PPS_PIC_Adv  =>  PPS_PIC_Adv,
     nchan        =>  nchan,
     d_wr_en      =>  d_wr_en_sig
   ); 

  header_fifo: fifo_66x2k_behav      --for synthesis
--  header_fifo: fifo_66x2k_struct      --for simulation
    port map(  
      rst         =>  Grs_Z5_sig,  --needs a 4-clock delay to make the simulation happy
      wr_clk      =>  C125,
      rd_clk      =>  CFIFO,
      wr_en       =>  h_wr_en_sig,
      rd_en       =>  h_rd_en_sig,
      full        =>  open,
      overflow    =>  FHOF_sig,
      empty       =>  open,
      valid       =>  open,
      prog_empty  =>  open,
      din         =>  coll_out_sig2,  --fifo has 2 extra bits in case we ever need them
      dout        =>  h_fifo_out_sig2      
    );
  data_fifo: fifo_66x2k_behav   --for synthesis
--  data_fifo: fifo_66x2k_struct   --for simulation
    port map(  
      rst         =>  Grs_Z5_sig,  --needs a 4-clock delay to make the simulation happy
      wr_clk      =>  C125,
      rd_clk      =>  CFIFO,
      wr_en       =>  d_wr_en_sig,  
      rd_en       =>  d_rd_en_sig,
      full        =>  open,
      overflow    =>  FDOF_sig,
      empty       =>  open,
      valid       =>  open,
      prog_empty  =>  FDPE_sig,
      din         =>  sum_ch_demux_sig2,  --fifo has 2 extra bits in case we ever need them
      dout        =>  d_fifo_out_sig2
    );

  read_control0: read_control
    port map(
      Grs                 =>  Grs,
      RunFm               =>  RunFm,
      PPS_PIC             =>  PPS_PIC,
      CFIFO               =>  CFIFO,
      nchan               =>  nchan,
      prog_empty          =>  FDPE_sig,
      h_fifo_out          =>  h_fifo_out_sig,
      d_fifo_out          =>  d_fifo_out_sig,
      h_rd_en             =>  h_rd_en_sig,
      d_rd_en             =>  d_rd_en_sig,
      To10GbeTxData       =>  To10GbeTxData_sig,
      To10GbeTxDataValid  =>  To10GbeTxDataValid,
      To10GbeTxEOF        =>  To10GbeTxEOF,
      PPS_read            =>  PPS_read
    );
    
    delayed_Grs: process(CFIFO)
    begin
      if(rising_edge(CFIFO)) then
        Grs_Z1_sig <= Grs;
        Grs_Z2_sig <= Grs_Z1_sig;
        Grs_Z3_sig <= Grs_Z2_sig;
        Grs_Z4_sig <= Grs_Z3_sig;
        Grs_Z5_sig <= Grs_Z4_sig;
      end if; 
    end process delayed_Grs; 


end comportamental;
