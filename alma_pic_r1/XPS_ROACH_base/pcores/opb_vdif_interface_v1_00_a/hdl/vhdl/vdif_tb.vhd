-- libraries
library IEEE;

-- load libraries
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use work.rdbe_pkg.all;

entity vdif_tb is
end entity vdif_tb;

architecture test of vdif_tb is
    -- components
    component vdif_interface
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
    end component vdif_interface;

    component m5b_epb
        port
        (
            epb_go      : in    std_logic;                      -- totally artificial to start an EPB bus transaction
            epb_din     : out   std_logic_vector(15 downto 0);  -- data_in to the EPB peripheral
            epb_csn     : out   std_logic;                      -- chip select to the peripheral (active low)
            epb_rwn     : out   std_logic;                      -- read/write select to the peripheral (read=1, write=0)
            epb_addr    : out   std_logic_vector(18 downto 0);  -- address to the EPB peripheral
            epb_clk     : in    std_logic                       -- bus clock, used here and in the peripheral
        );
    end component m5b_epb;

    component bcd_count
        generic
        (
            edge_active     :   std_logic :='1';  -- clock polarity
            clr_active      :   std_logic :='1'   -- reset polarity
        );
        port
        (
            qout    :   out std_logic_vector(31 downto 0);  -- data out
            data_in :   in  std_logic_vector(31 downto 0);  -- data in
            ld  :   in  std_logic;  -- load counter
            cnt_en  :   in  std_logic;  -- count enable
            clr :   in  std_logic;  -- asynch clear
            clk :   in  std_logic   -- clock
        );
    end component bcd_count;

    component random
        generic
        (
            width : integer :=  32
        );
        port
        (
          random_num : out std_logic_vector (width-1 downto 0);  --output vector
          clk : in std_logic
        );
    end component random;

    -- *********************************************************
    -- test signals
    -- *********************************************************

    -- clocks and resets
    signal sys_clk      : std_logic;
    signal adc_clk  : std_logic;
    signal epb_clk  : std_logic;
    signal pps      : std_logic;
    signal rst      : std_logic;
    -- timecode
    signal tc       : std_logic_vector(31 downto 0);
    signal tc_ld    : std_logic;
    -- rate select
    signal sel_rate : std_logic_vector(15 downto 0);
    -- data signals
    --signal dsp_rdy  : std_logic_vector(7 downto 0);
    signal dsp_rdy  : std_logic_vector(0 downto 0);

    signal data_in0 : std_logic_vector(1 downto 0);
    signal data_in1 : std_logic_vector(1 downto 0);
    signal data_in2 : std_logic_vector(1 downto 0);
    signal data_in3 : std_logic_vector(1 downto 0);
    signal data_in4 : std_logic_vector(1 downto 0);
    signal data_in5 : std_logic_vector(1 downto 0);
    signal data_in6 : std_logic_vector(1 downto 0);
    signal data_in7 : std_logic_vector(1 downto 0);
    signal data_rng : std_logic_vector(1 downto 0);
    signal data_bad : vdifData;
    -- EPB signals
    signal epb_csn  : std_logic;
    signal epb_rwn  : std_logic;
    signal epb_addr : std_logic_vector(18 downto 0);
    signal epb_din  : std_logic_vector(15 downto 0);
    signal epb_dout : std_logic_vector(15 downto 0);
    signal epb_go   : std_logic;
    -- 10GbE signals
    signal ten_data : std_logic_vector(63 downto 0);
    signal ten_dv   : std_logic;
    signal ten_eof  : std_logic;
    signal ten_full : std_logic;

begin

    -- create sys_clk, 100MHz
    sys_gen:  process
    begin
        sys_clk <= '1';
        wait for 5 ns;
        sys_clk <= '0';
        wait for 5 ns;
    end process sys_gen;

    -- create adc_clk, 250MHz
    adc_gen:  process
    begin
        adc_clk <= '1';
        wait for 2 ns;
        adc_clk <= '0';
        wait for 2 ns;
    end process adc_gen;

    -- create epb_clk, ~50MHz
    epb_gen:  process
    begin
        epb_clk <= '1';
        wait for 10 ns;
        epb_clk <= '0';
        wait for 10 ns;
    end process epb_gen;

    -- create pps, much slower than other clocks
    -- note that this is not 1pps.  too many cycles to simulate with that
    pps_gen:  process
    begin
        pps <= '1';
        wait for 20 us;
        pps <= '0';
        wait for 1980 us;
    end process pps_gen;

    -- julian time generator
    time1:  bcd_count
    generic map
    (
        edge_active => '1',
        clr_active => '1'
    )
    port map
    (
        qout => tc,
        data_in => x"00000000",
        ld => tc_ld,
        cnt_en => '1',
        clr => rst,
        clk => pps
    );

    -- powerPC external peripheral bus emulator
    epb1:  m5b_epb
    port map
    (
        epb_go => epb_go,
        epb_din => epb_din,
        epb_csn => epb_csn,
        epb_rwn => epb_rwn,
        epb_addr => epb_addr,
        epb_clk => epb_clk
    );

    -- 10GbE emulator
    ten_full <= '0';
    --ten_data
    --ten_dv
    --ten_eof

    -- dsp emulator
    r1:  random
    generic map
    (
        width => 2
    )
    port map
    (
      random_num => data_rng,
      clk => adc_clk
    );

    --dsp_rdy <= (others =>'1');
    dsp_rdy(0) <= '1';
    data_in0 <= data_rng;
    data_in1 <= data_rng;
    data_in2 <= data_rng;
    data_in3 <= data_rng;
    data_in4 <= data_rng;
    data_in5 <= data_rng;
    data_in6 <= data_rng;
    data_in7 <= data_rng;

    -- instantiate mark5b interface

    data_bad(0) <= data_in0 & "00" & x"000";

    vdif1:  vdif_interface
    generic map
    (
        REV_MAJOR_INT => x"01",
        REV_MAJOR_FRAC => x"05",
        P_TYPE => x"83",
        ADDRHI => "0000000",
        nch => 1
    )
    port map
    (
        sys_clk => sys_clk,
        adc_clk => adc_clk,
        epb_clk => epb_clk,
        Grs => rst,
        OnePPS => pps,
        DataRdy => dsp_rdy,
        TimeCode => tc,
        dataIn => data_bad,
        DeviceCSn => epb_csn,
        DeviceRWn => epb_rwn,
        DeviceAddr => epb_addr,
        DeviceDataIn => epb_din,
        DeviceDataOut => epb_dout,
        To10GbeTxData => ten_data,
        To10GbeTxDataValid => ten_dv,
        To10GbeTxEOF => ten_eof
    );

    -- timekeeper process
    tk1:  process
    begin
        rst <= '1';
        tc_ld <= '0';
        sel_rate <= (others => '0');
        epb_go <= '0';
        wait for 8 ns;
        rst <= '0';
        wait for 21 us;
        epb_go <= '1';
        wait for 47 ns;
        epb_go <= '0';
        wait;
    end process tk1;

end architecture test;