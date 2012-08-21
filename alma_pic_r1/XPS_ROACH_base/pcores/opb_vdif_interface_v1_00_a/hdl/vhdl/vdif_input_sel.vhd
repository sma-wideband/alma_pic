--  m5b_input_sel.vhd
--
--  Select which inputs and how many bit goi into the vdif fifo
--
--  april 2011 pfm

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

entity vdif_input_sel is
    port(
        wrClk       : in std_logic;
        rdClk       : in std_logic;
        reset       : in std_logic;     -- global reset
        valid       : in std_logic;     -- valid data started
        dataRdy     : in std_logic;     -- data ready signal
        rdFifoEna   : in std_logic;
        cplxFlg     : in std_logic;
        numBit      : in std_logic_vector(4 downto 0);

        data_in     : in std_logic_vector(15 downto 0);

        full        : out std_logic;
        prog_full   : out std_logic;
        data_out    : out std_logic_vector(63 downto 0)
    );
end vdif_input_sel;

architecture behavioral of vdif_input_sel is
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- modules
component VDIF_fifo
    port (
        rst         : in std_logic;
        din         : in std_logic_vector(15 downto 0);
        wr_clk      : in std_logic;
        wr_en       : in std_logic;
        rd_clk      : in std_logic;
        rd_en       : in std_logic;

        dout        : out std_logic_vector(63 downto 0);
        full        : out std_logic;
        empty       : out std_logic;
        prog_empty  : out std_logic     -- 625
    );
end component VDIF_fifo;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- signals

    signal cntr             : std_logic_vector(11 downto 0);
    signal data             : std_logic_vector(15 downto 0);
    signal ffreset          : std_logic;
    signal numBits          : std_logic_vector(3 downto 0);
    signal wrFifoEna        : std_logic;
    signal fifo_input       : std_logic_vector(15 downto 0);
 -------------------------------------------------------------------------------
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- keep fifo reset until valid data available
ffreset <= NOT Valid;

-- if complex data then double the size of bits (shift left 1 or 0)
numBits <= numBit(3 downto 0) when cplxFlg='0' else (numBit(2 downto 0) & '0');

-------------------------------------------------------------------------------
    -- count how many times to write to the fifo
    cntr_proc:  process(wrClk)
    begin
        if rising_edge(wrClk) then
            if(valid ='0') then -- start on 1pps signal
                cntr <= (others => '0');
            elsif(dataRdy = '1') then
                cntr <= cntr + '1';
            end if;
        end if;
    end process cntr_proc;
    -- cntr can also be used with test data to count # of clocks until output
-------------------------------------------------------------------------------
    -- determine the fifo write time from number of bits selected (2^numBits)
     -- the more bits per write, the less time it takes to fill the fifo
    mkFFen : process(wrClk)
    begin
        if rising_edge(wrClk) then
            if Valid = '1' then
                case(numBits)is
                    when x"0" =>    -- 1 bit
                        if cntr(3 downto 0) = b"1111" then
                            wrFifoEna <= dataRdy;
                        else
                            wrFifoEna <= '0';
                        end if;
                    when x"1" =>    -- 2 bits
                        if cntr(2 downto 0) = b"111" then
                            wrFifoEna <= dataRdy;
                        else
                            wrFifoEna <= '0';
                        end if;
                    when x"2" =>    -- 4 bits
                        if cntr(1 downto 0) = b"11" then
                            wrFifoEna <= dataRdy;
                        else
                            wrFifoEna <= '0';
                        end if;
                    when x"3" =>    -- 8 bits
                        if cntr(0) = '1' then
                            wrFifoEna <= dataRdy;
                        else
                            wrFifoEna <= '0';
                        end if;
                    when x"4" =>    -- 16 bits
                        wrFifoEna <= dataRdy;
                    when x"F" =>    -- Test mode
                        wrFifoEna <= dataRdy;
                    when others =>  -- default to 2 bits
                        if cntr(2 downto 0) = b"111" then
                            wrFifoEna <= dataRdy;
                        else
                            wrFifoEna <= '0';
                        end if;
                end case;
            else
                wrFifoEna <= '0';
            end if;
        end if;

    end process;
-------------------------------------------------------------------------------
-- select the number of bits to record
    selIn : process(wrClk)
        --variable dataMux : std_logic_vector(15 downto 0);
    begin
        if rising_edge(wrClk) then
            --dataMux := data_in when ? else ("1010" & cntr);
            if (dataRdy = '1') then
                case(numBits)is
                    when x"0" =>    -- shift 1 bit in
                        data <= data_in(15) & data(15 downto 1);
                    when x"1" =>    -- shift 2 bits in
                        data <= data_in(15 downto 14) & data(15 downto 2);
                    when x"2" =>    -- shift 4 bits in
                        data <= data_in(15 downto 12) & data(15 downto 4);
                    when x"3" =>    -- shift 8 bits in
                        data <= data_in(15 downto 8) & data(15 downto 8);
                    when x"4" =>    -- shift 16 bits in
                        data <= data_in;
                    when x"F" =>    -- test data
                        data <= "1010" & cntr;
                    when others =>
                        -- default to 2 bits
                        data <= data_in(15 downto 14) & data(15 downto 2);
                end case;
            end if;
        end if;
    end process selIn;

 fifo_input <= data(7 downto 0) & data(15 downto 8); -- to match tge swap
-- do you really want to do this? ^
-- fifo_input <= data;
-------------------------------------------------------------------------------

vdifFF : VDIF_fifo
    port map(
        rst         =>  ffreset,    --: in std_logic;
        din         =>  fifo_input, --: in std_logic_vector(15 downto 0);
        wr_clk      =>  wrClk,      --: in std_logic;
        wr_en       =>  wrFifoEna,  --: in std_logic;
        rd_clk      =>  rdClk,      --: in std_logic; -- sys_clk
        rd_en       =>  rdFifoEna,  --: in std_logic;

        dout        =>  data_out,   --: out std_logic_vector(63 downto 0);
        full        =>  full,       --: out std_logic;
        empty       =>  open,       --: out std_logic;
        prog_empty  =>  prog_full   --: out std_logic
   );

-------------------------------------------------------------------------------

end behavioral;
