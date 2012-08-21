library ieee;
USE ieee.std_logic_1164.all;

entity m5b_epb is
    port
    (
        epb_go      : in    std_logic;                      -- totally artificial to start an EPB bus transaction
        epb_din     : out   std_logic_vector(15 downto 0);  -- data_in to the EPB peripheral
        epb_csn     : out   std_logic;                      -- chip select to the peripheral (active low)
        epb_rwn     : out   std_logic;                      -- read/write select to the peripheral (read=1, write=0)
        epb_addr    : out   std_logic_vector(18 downto 0);  -- address to the EPB peripheral
        epb_clk     : in    std_logic                       -- bus clock, used here and in the peripheral
    );
end entity m5b_epb;

architecture beh of m5b_epb is
begin
    epb_dummy:  process
    begin
        -- set default control signal values and then wait for a start request
        epb_din <= (others => '0');
        epb_csn <= '1';
        epb_rwn <= '0';
        epb_addr <= (others => '0');
        wait until epb_go = '1';

        -- ***********************************************
        -- ***********************************************
        -- write the necessary stuff from the conf file
        -- fpga_wr=W:0x800004:0x000C:  # Reference Epoch
        -- fpga_wr=W:0x800008:0xDEAD:  # Station ID
        -- fpga_wr=W:0x80000A:0x000D:  # DBE num
        -- fpga_wr=W:0x80001E:0x000F:  # Channel active (sel input)
        -- fpga_wr=W:0x800120:0x0080:  # Sample Rate lsw 0
        -- fpga_wr=W:0x800122:0x0080:  # unit + Sample Rate msw 0
        -- fpga_wr=W:0x800124:0x0080:  # Sample Rate lsw 1
        -- fpga_wr=W:0x800126:0x0080:  # unit + Sample Rate msw 1
        -- fpga_wr=W:0x800128:0x0080:  # Sample Rate lsw 2
        -- fpga_wr=W:0x80012A:0x0080:  # unit + Sample Rate msw 2
        -- fpga_wr=W:0x80012C:0x0080:  # Sample Rate lsw 3
        -- fpga_wr=W:0x80012E:0x0080:  # unit + Sample Rate msw 3
        -- fpga_wr=W:0x800140:0x0101:  # Bits per Sample 1, 0 (set to 2 bits)
        -- fpga_wr=W:0x800142:0x0101:  # Bits per Sample 3, 2
        -- fpga_wr=W:0x800144:0x0101:  # Bits per Sample 5, 4
        -- fpga_wr=W:0x800146:0x0101:  # Bits per Sample 7, 6
        -- fpga_wr=W:0x800148:0x3210:  # IF num ch 0-3
        -- fpga_wr=W:0x80014A:0x7654:  # IF num ch 4-7 not used
        -- fpga_wr=W:0x80014C:0x2222:  # SubBand ch 0 - 3
        -- fpga_wr=W:0x80014E:0xFEDC:  # SubBand ch 4-7
        -- fpga_wr=W:0x800202:0xABF0:  # ESideBand
        -- OR, to look at the register map, we need to fill in:
        -- x"000" => SyncWord(15 downto 0) <= DeviceDataIn;      --0x0000
        -- x"001" => SyncWord(31 downto 16) <= DeviceDataIn;     --0x0002
        -- x"002" => RefEpoch <= DeviceDataIn(7 downto 0);       --0x0004
        -- x"003" => Legacy <= DeviceDataIn(0);                  --0x0006
        -- x"004" => StationID <= DeviceDataIn;                  --0x0008
        -- x"005" => DBEnum <= DeviceDataIn(3 downto 0);         --0x000A
        -- x"006" => TestMode <= DeviceDataIn(0);                --0x000C
        -- x"00A" => TimeSlot1On(15 downto 0) <= DeviceDataIn;   --0x0014
        -- x"00B" => TimeSlot1On(31 downto 16) <= DeviceDataIn;  --0x0016
        -- x"00C" => TimeSlot1Off(15 downto 0) <= DeviceDataIn;  --0x0018
        -- x"00D" => TimeSlot1Off(31 downto 16) <= DeviceDataIn; --0x001A
        -- x"00E" => TimeAlign <= DeviceDataIn;                  --0x001C
        -- x"00F" => selInput <= DeviceDataIn(3 downto 0);       --0x001E
        -- x"080" => LOIFftwA(0)(15 downto  0) <= DeviceDataIn;  --0x0100
        -- x"081" => LOIFftwA(0)(31 downto 16) <= DeviceDataIn;  --0x0102
        -- x"082" => LOIFftwA(1)(15 downto  0) <= DeviceDataIn;  --0x0104
        -- x"083" => LOIFftwA(1)(31 downto 16) <= DeviceDataIn;  --0x0106
        -- x"084" => LOIFftwA(2)(15 downto  0) <= DeviceDataIn;  --0x0108
        -- x"085" => LOIFftwA(2)(31 downto 16) <= DeviceDataIn;  --0x010A
        -- x"086" => LOIFftwA(3)(15 downto  0) <= DeviceDataIn;  --0x010C
        -- x"087" => LOIFftwA(3)(31 downto 16) <= DeviceDataIn;  --0x010E
        -- x"088" => LOIFftwA(4)(15 downto  0) <= DeviceDataIn;  --0x0110
        -- x"089" => LOIFftwA(4)(31 downto 16) <= DeviceDataIn;  --0x0112
        -- x"08A" => LOIFftwA(5)(15 downto  0) <= DeviceDataIn;  --0x0114
        -- x"08B" => LOIFftwA(5)(31 downto 16) <= DeviceDataIn;  --0x0116
        -- x"08C" => LOIFftwA(6)(15 downto  0) <= DeviceDataIn;  --0x0118
        -- x"08D" => LOIFftwA(6)(31 downto 16) <= DeviceDataIn;  --0x011A
        -- x"08E" => LOIFftwA(7)(15 downto  0) <= DeviceDataIn;  --0x011C
        -- x"08F" => LOIFftwA(7)(31 downto 16) <= DeviceDataIn;  --0x011E
        -- x"090" => SampleRateA(0)(15 downto 0) <= DeviceDataIn;   --0x0120
        -- x"091" => SampleRateA(0)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x0122
        -- x"092" => SampleRateA(1)(15 downto 0) <= DeviceDataIn;   --0x0124
        -- x"093" => SampleRateA(1)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x0126
        -- x"094" => SampleRateA(2)(15 downto 0) <= DeviceDataIn;   --0x0128
        -- x"095" => SampleRateA(2)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x012A
        -- x"096" => SampleRateA(3)(15 downto 0) <= DeviceDataIn;   --0x012C
        -- x"097" => SampleRateA(3)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x012E
        -- x"098" => SampleRateA(4)(15 downto 0) <= DeviceDataIn;   --0x0130
        -- x"099" => SampleRateA(4)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x0132
        -- x"09A" => SampleRateA(5)(15 downto 0) <= DeviceDataIn;   --0x0134
        -- x"09B" => SampleRateA(5)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x0136
        -- x"09C" => SampleRateA(6)(15 downto 0) <= DeviceDataIn;   --0x0138
        -- x"09D" => SampleRateA(6)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x013A
        -- x"09E" => SampleRateA(7)(15 downto 0) <= DeviceDataIn;   --0x013C
        -- x"09F" => SampleRateA(7)(23 downto 16) <= DeviceDataIn(7 downto 0);  --0x013E
        -- x"0A0" => Bits_SampA(0) <= DeviceDataIn(4 downto 0);
        --           Bits_SampA(1) <= DeviceDataIn(12 downto 8); --0x0140
        -- x"0A1" => Bits_SampA(2) <= DeviceDataIn(4 downto 0);
        --           Bits_SampA(3) <= DeviceDataIn(12 downto 8); --0x0142
        -- x"0A2" => Bits_SampA(4) <= DeviceDataIn(4 downto 0);
        --           Bits_SampA(5) <= DeviceDataIn(12 downto 8); --0x0144
        -- x"0A3" => Bits_SampA(6) <= DeviceDataIn(4 downto 0);
        --           Bits_SampA(7) <= DeviceDataIn(12 downto 8); --0x0146
        -- x"0A4" => IFnumA(3) <= DeviceDataIn(15 downto 12);
        --           IFnumA(2) <= DeviceDataIn(11 downto 8);
        --           IFnumA(1) <= DeviceDataIn(7 downto 4);
        --           IFnumA(0) <= DeviceDataIn(3 downto 0);      --0x0148
        -- x"0A5" => IFnumA(7) <= DeviceDataIn(15 downto 12);
        --           IFnumA(6) <= DeviceDataIn(11 downto 8);
        --           IFnumA(5) <= DeviceDataIn(7 downto 4);
        --           IFnumA(4) <= DeviceDataIn(3 downto 0);      --0x014A
        -- x"0A6" => SubBandA(3) <= DeviceDataIn(15 downto 12);
        --           SubBandA(2) <= DeviceDataIn(11 downto 8);
        --           SubBandA(1) <= DeviceDataIn(7 downto 4);
        --           SubBandA(0) <= DeviceDataIn(3 downto 0);    --0x014C
        -- x"0A7" => SubBandA(7) <= DeviceDataIn(15 downto 12);
        --           SubBandA(6) <= DeviceDataIn(11 downto 8);
        --           SubBandA(5) <= DeviceDataIn(7 downto 4);
        --           SubBandA(4) <= DeviceDataIn(3 downto 0);    --0x014E
        -- x"100" => ComplexFlags <= DeviceDataIn(7 downto 0);   --0x0200
        -- x"101" => ESideBand    <= DeviceDataIn(7 downto 0);   --0x0202
        -- x"105" => EpochSecSet(15 downto 0) <= DeviceDataIn;   --0x210
        -- x"106" => EpochSecSet(29 downto 16) <= DeviceDataIn(13 downto 0);  --0x212
        -- ***********************************************
        -- ***********************************************

        -- write to syncword(15 downto 0)
        epb_addr <= "0000000000000000000";
        epb_din <= x"DEED";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to syncword(31 downto 16)
        epb_addr <= "0000000000000000001";
        epb_din <= x"ABAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to RefEpoch
        epb_addr <= "0000000000000000010";
        epb_din <= x"000C";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to Legacy
        epb_addr <= "0000000000000000011";
        epb_din <= x"0001";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to StationID
        epb_addr <= "0000000000000000100";
        epb_din <= x"DEAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to DBEnum
        epb_addr <= "0000000000000000101";
        epb_din <= x"000D";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to TestMode
        epb_addr <= "0000000000000000110";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to TimeSlot1On(15 downto 0);
        epb_addr <= "0000000000000001010";
        epb_din <= x"0002";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to TimeSlot1On(31 downto 16);
        epb_addr <= "0000000000000001011";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;


        -- write to TimeSlot1Off(15 downto 0);
        epb_addr <= "0000000000000001100";
        epb_din <= x"0005";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to TimeSlot1Off(31 downto 16);
        epb_addr <= "0000000000000001101";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to TimeAlign(15 downto 0)
        epb_addr <= "0000000000000001110";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to selInput
        epb_addr <= "0000000000000001111";
        epb_din <= x"000F";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(0)(15 downto 0)
        epb_addr <= "0000000000010000000";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(0)(31 downto 16)
        epb_addr <= "0000000000010000001";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(1)(15 downto 0)
        epb_addr <= "0000000000010000010";
        epb_din <= x"0001";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(1)(31 downto 16)
        epb_addr <= "0000000000010000011";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(2)(15 downto 0)
        epb_addr <= "0000000000010000100";
        epb_din <= x"0002";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(2)(31 downto 16)
        epb_addr <= "0000000000010000101";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(3)(15 downto 0)
        epb_addr <= "0000000000010000110";
        epb_din <= x"0003";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(3)(31 downto 16)
        epb_addr <= "0000000000010000111";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(4)(15 downto 0)
        epb_addr <= "0000000000010001000";
        epb_din <= x"0004";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(4)(31 downto 16)
        epb_addr <= "0000000000010001001";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(5)(15 downto 0)
        epb_addr <= "0000000000010001010";
        epb_din <= x"0005";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(5)(31 downto 16)
        epb_addr <= "0000000000010001011";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(6)(15 downto 0)
        epb_addr <= "0000000000010001100";
        epb_din <= x"0006";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(6)(31 downto 16)
        epb_addr <= "0000000000010001101";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(7)(15 downto 0)
        epb_addr <= "0000000000010001110";
        epb_din <= x"0007";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to LOIFftwA(7)(31 downto 16)
        epb_addr <= "0000000000010001111";
        epb_din <= x"0BAD";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(0)(15 downto 0)
        epb_addr <= "0000000000010010000";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(0)(31 downto 16)
        epb_addr <= "0000000000010010001";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(1)(15 downto 0)
        epb_addr <= "0000000000010010010";
        epb_din <= x"0001";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(1)(31 downto 16)
        epb_addr <= "0000000000010010011";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(2)(15 downto 0)
        epb_addr <= "0000000000010010100";
        epb_din <= x"0002";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(2)(31 downto 16)
        epb_addr <= "0000000000010010101";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(3)(15 downto 0)
        epb_addr <= "0000000000010010110";
        epb_din <= x"0003";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(3)(31 downto 16)
        epb_addr <= "0000000000010010111";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(4)(15 downto 0)
        epb_addr <= "0000000000010011000";
        epb_din <= x"0004";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(4)(31 downto 16)
        epb_addr <= "0000000000010011001";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(5)(15 downto 0)
        epb_addr <= "0000000000010011010";
        epb_din <= x"0005";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(5)(31 downto 16)
        epb_addr <= "0000000000010011011";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(6)(15 downto 0)
        epb_addr <= "0000000000010011100";
        epb_din <= x"0006";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(6)(31 downto 16)
        epb_addr <= "0000000000010011101";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(7)(15 downto 0)
        epb_addr <= "0000000000010011110";
        epb_din <= x"0006";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to samprateA(7)(31 downto 16)
        epb_addr <= "0000000000010011111";
        epb_din <= x"ABBA";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to bits_sampA(0) & bits_sampA(1)
        epb_addr <= "0000000000010100000";
        epb_din <= x"0101";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to bits_sampA(2) & bits_sampA(3)
        epb_addr <= "0000000000010100001";
        epb_din <= x"0101";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to bits_sampA(4) & bits_sampA(5)
        epb_addr <= "0000000000010100010";
        epb_din <= x"0101";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to bits_sampA(6) & bits_sampA(7)
        epb_addr <= "0000000000010100011";
        epb_din <= x"0101";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to ifnumA(0) & ifnumA(1) & ifnumA(2) & ifnumA(3)
        epb_addr <= "0000000000010100100";
        epb_din <= x"3210";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to ifnumA(4) & ifnumA(5) & ifnumA(6) & ifnumA(7)
        epb_addr <= "0000000000010100101";
        epb_din <= x"7654";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to subbandA(0) & subbandA(1) & subbandA(2) & subbandA(3)
        epb_addr <= "0000000000010100110";
        epb_din <= x"2222";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to subbandA(4) & subbandA(5) & subbandA(6) & subbandA(7)
        epb_addr <= "0000000000010100111";
        epb_din <= x"FEDC";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to complexFlags
        epb_addr <= "0000000000100000000";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to esideband
        epb_addr <= "0000000000100000001";
        epb_din <= x"ABF0";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        -- write to EpochSecSet(15 downto 0)
        epb_addr <= "0000000000100000101";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

        epb_addr <= "0000000000100000110";
        epb_din <= x"0000";
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '0';
        epb_rwn <= '0';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        wait until epb_clk = '1';
        epb_csn <= '1';
        wait for 30 ns;

    end process epb_dummy;
end architecture beh;