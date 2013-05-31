library ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;


--  A testbench has no ports.
     entity test_opb_tb is
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
    ADDRHI      : std_logic_vector(18 downto 12) := "0000000";
    nch         : integer range 0 to 7 := 4      -- number of channels synthesized
   );
     end test_opb_tb;
     
     architecture behav of test_opb_tb is
        --  Declaration of the component that will be instantiated.
        component opb_vdif_interface
          generic (
            C_BASEADDR : std_logic_vector(31 downto 0);
            C_HIGHADDR : std_logic_vector(31 downto 0)
                 );
          port (
     -- Bus protocol ports
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      Sl_DBus : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      OPB_ABus : in std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE : in std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_DBus : in std_logic_vector(0 to C_OPB_DWIDTH-1);
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
      clk_in_p        : in std_logic;
      clk_in_n        : in std_logic;
      sum_in_p        : in std_logic_vector(63 downto 0);
      sum_in_n        : in std_logic_vector(63 downto 0);
      adc_clk         : in std_logic;
      OnePPS          : in std_logic;
      TE              : in std_logic;
      DataRdy         : in std_logic_vector(nch-1 downto 0);
      TimeCode        : in std_logic_vector(31 downto 0);
      dataIn          : in std_logic_vector(63 downto 0);

      -- test port
      test_port       : out std_logic_vector(31 downto 0);
      ROACHTP         : out std_logic_vector(1 downto 0);
      TP_p            : in std_logic_vector(5 downto 0);

      -- ten GbE ports
      To10GbeTxData   : out std_logic_vector(63 downto 0);
      To10GbeTxDataValid  : out std_logic;
      To10GbeTxEOF    : out std_logic
            );
        end component;
        --  Specifies which entity is bound with the component.
        for test_opb_0: opb_vdif_interface use entity work.opb_vdif_interface;

        signal OPB_Clk_sig    :   std_logic;
        signal Sl_xferAck_sig :   std_logic;
        signal OPB_select_sig     :   std_logic;
        signal OPB_RNW_sig     :   std_logic;
        signal Sl_errAck_sig     :   std_logic;
        signal Sl_retry_sig     :   std_logic;
        signal Sl_toutSup_sig     :   std_logic;
        signal OPB_ABus_sig    :   std_logic_vector(31 downto 0);
        signal OPB_DBus_sig    :   std_logic_vector(31 downto 0);
        signal Sl_DBus_sig    :   std_logic_vector(31 downto 0);
        signal OPB_rst_sig       :   std_logic;
        
        signal CD_I_sig : std_logic_vector(0 to 7);
        signal CD_O_sig : std_logic_vector(0 to 7);
        signal CD_T_sig : std_logic;
        signal CTRL_DATA_sig : std_logic;
        signal RnW_sig : std_logic;
        signal uCLK0_sig : std_logic;

        signal To10GbeTxData_sig  :   std_logic_vector(63 downto 0);
        signal To10GbeTxDataValid_sig  :   std_logic;
        signal To10GbeTxEOF_sig  :   std_logic;

        signal test_sig1:  std_logic;
        signal test_sig2: std_logic;

     begin

        --assigned unused signals to avoid warnings
        test_sig1              <= '0';
        test_sig2              <= '0';
        --CD_I_sig               <= x"00";
        --CTRL_DATA_sig          <= '0';
        --RnW_sig                <= '0';
        --uCLK0_sig              <= '0';
        To10GbeTxDataValid_sig <= '0';
        To10GbeTxEOF_sig       <= '0';

        --  Component instantiation.
        test_opb_0: opb_vdif_interface
           generic map (
             C_BASEADDR => X"00010000",
             C_HIGHADDR => X"0001FFFF")
           port map (
             -- Bus protocol ports
             OPB_Clk => OPB_Clk_sig,
             OPB_Rst => OPB_rst_sig,
             Sl_DBus => Sl_DBus_sig,
             Sl_errAck => Sl_errAck_sig,
             Sl_retry => Sl_retry_sig,
             Sl_toutSup => Sl_toutSup_sig,
             Sl_xferAck => Sl_xferAck_sig,
             OPB_ABus => OPB_ABus_sig,
             OPB_BE => "0000",
             OPB_DBus => OPB_DBus_sig,
             OPB_RNW => OPB_RNW_sig,
             OPB_select => OPB_select_sig,
             OPB_seqAddr => '0',
  
             -- Multi-drop bus
             CD_I => CD_I_sig,
             CD_O => CD_O_sig,
             CD_T => CD_T_sig,
             CTRL_DATA => CTRL_DATA_sig,
             RnW => RnW_sig,
             uCLK0 => uCLK0_sig,

             -- other ports
             clk_in_p => '0',
             clk_in_n => '0',
             sum_in_p => X"0000000000000000",
             sum_in_n => X"0000000000000000",
             adc_clk => '0',
             OnePPS => '0',
             TE => '0',
             DataRdy => "0000",
             TimeCode => X"00000000",
             dataIn => X"0000000000000000",

             -- test ports
             TP_p => "000000",

             -- ten GbE ports
             To10GbeTxData => To10GbeTxData_sig,
             To10GbeTxDataValid => To10GbeTxDataValid_sig,
             To10GbeTxEOF => To10GbeTxEOF_sig
             );
     
        --  This process does the real job.
        process
           type pattern_type is record
              --  The inputs and outputs of the circuit
              OPB_Clk, OPB_RNW, OPB_select, Sl_xferAck, reset : std_logic;
              OPB_ABus: std_logic_vector(0 to 31);  --here follow the OPB bus convention
              OPB_Dbus: std_logic_vector(0 to 31);
              Sl_Dbus:  std_logic_vector(0 to 31);  
              
              CD_I:       std_logic_vector(0 to 7); -- uP bus
              CD_O:       std_logic_vector(0 to 7); -- uP bus
              CD_T:       std_logic; -- uP bus
              CTRL_DATA:  std_logic; -- control line for uP data bus
              RnW:        std_logic; -- read not write
              uCLK0:      std_logic; -- clock for microprocessor bus 
              data_to_cpu: std_logic_vector(0 to 7); --provide data to C167_interface that a register should have provided             
                           
           end record;
           --  The patterns to apply.
           type pattern_array is array (natural range <>) of pattern_type;
           constant patterns : pattern_array :=
             --OPB_Clk                                                                             C             d
                   --OPB_RNW                                                                       T             a
                         --OPB_select                                                              R             t_
                              --Sl_xferAck                                                         L/       u    t
                                  --spare                                        C     C      C    D        C    o_
                                       --OPB_ABus                                D     D      D    A    R   L    C
                                                     --OPB_DBus                  _     _      _    T    n   K    P
                                                                --Sl_DBus        I     O      T    A    W   0    U
             (('0', '0', '0', '0', '1', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab"), 
              ('1', '0', '0', '0', '1', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),  --read from addr 0x0010001
              ('1', '1', '1', '0', '0', X"00010000", X"00000000", X"11101101", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('0', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('1', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('0', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('1', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),

              ('0', '0', '0', '0', '0', X"00000000", X"11101101", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),  --write to addr 0x0010001
              ('1', '0', '1', '0', '0', X"00010000", X"11101101", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('0', '0', '1', '0', '0', X"00010000", X"11101101", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('1', '0', '1', '0', '0', X"00010000", X"11101101", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('0', '0', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('1', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),

              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),  --read from addr 0x0010001
              ('1', '1', '1', '0', '0', X"00010000", X"00000000", X"11101101", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('0', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('1', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('0', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),
              ('1', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1', X"ab" ),

              ('0', '0', '0', '0', '0', X"00000000", X"00010010", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),  --write again different value  
              ('1', '0', '1', '0', '0', X"00010001", X"00010010", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('0', '0', '1', '0', '0', X"00010001", X"00010010", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('1', '0', '1', '0', '0', X"00010001", X"00010010", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('0', '0', '1', '0', '0', X"00010001", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('1', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),

              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),  --read again
              ('1', '1', '1', '0', '0', X"00010000", X"00000000", X"00010010", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('0', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('1', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('0', '1', '1', '0', '0', X"00010000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              ('1', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab"),
              
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ), --now exercise C167 bus
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','0',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ),  --provide four clocks
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','0',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','0',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','0',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '1', '0','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '0', '1', '0','1',  X"ab" ),  --write to control register
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"01", X"00", '0', '1', '0','0',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"01", X"00", '0', '1', '0','1',  X"ab" ),  
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ),  -- write 0x55 to address given in controlreg
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','0',  X"ab" ),              
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '1', '0', '0','1',  X"ab" ),                                       
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '0', '0', '1','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"00", '0', '0', '1','1',  X"ab" ),  --wait one clock, leave write high            
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"00", X"00", '0', '0', '1','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"00", X"55", '0', '0', '1','0',  X"ab" ),     --read from address 1           
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"00", X"55", '0', '0', '1','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"55", '0', '0', '0','1',  X"ab" ),             
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"55", '0', '0', '0','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"55", '0', '0', '0','1',  X"ab" ),            
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"55", '0', '0', '0','1',  X"ab" ),
              ('0', '0', '0', '0', '0', X"00000000", X"00000000", X"00000000", X"55", X"55", '0', '0', '0','1',  X"ab" )

                );
        begin
OPB_clk_sig     <= '1';
OPB_RnW_sig     <= '1';
OPB_ABus_sig    <= X"00000000";
OPB_select_sig  <= '0';
uCLK0_sig       <= '1';

wait for 1 ns;
           --  Check each pattern.
           for i in patterns'range loop
              --  Set the inputs.
              OPB_clk_sig <= patterns(i).OPB_clk;
              OPB_RnW_sig <= patterns(i).OPB_RNW;
              OPB_select_sig <= patterns(i).OPB_select;
              OPB_ABus_sig <= patterns(i).OPB_ABus;
              OPB_DBus_sig <= patterns(i).OPB_DBus;
              OPB_rst_sig  <= patterns(i).reset;
              --Sl_DBus_sig <= patterns(i).Sl_DBus;
              
              CD_I_sig       <= patterns(i).CD_I;
              CTRL_DATA_sig  <= patterns(i).CTRL_DATA;
              RnW_sig        <= patterns(i).RnW;
              uCLK0_sig      <= patterns(i).uCLK0;
              wait for 1 ns;

              --  Check the outputs.

--              assert Sl_xferAck_sig = patterns(i).Sl_xferAck
--                 report "bad ack value" severity error;

           end loop;
           assert false report "end of test" severity note;
           --  Wait forever; this will finish the simulation.
           wait;
        end process;
     end behav;
