library ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use work.rdbe_pkg.vdifHdr;

entity vdif_formatter is
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
end entity vdif_formatter;

architecture behavioral of vdif_formatter is
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- module definition

-------------------------------------------------------------------------------
-- signal definition

    -- there are 5000 bytes or 625 words (40k bits) of data per packet
    constant PACKET_END : std_logic_vector(11 downto 0) := x"26F";
                              -- to_StdLogicVector(623);--625 * 8 = 5000
    -- stop the state machine loop 2 clocks early, then add one more End state
    
    -- definitions for vdif formatter state machine 
    type vdifStateType is
    (
        vdifResetSt,
        vdifWaitSt,
        vdifHdrSt,
        vdifDataSt,
        vdifDataEndSt
    ); -- Define the states of the formatter

    signal vdifState : vdifStateType;

    signal legacy   :   std_logic;
    signal HdrCntr  :   natural;
    signal DataCntr :   std_logic_vector(11 downto 0);
    

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
legacy <= Header(0)(62);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    -- Hdr array elements are 2 header words long (64 bits)   
    cntHdrs : process(clk, vdifState)
    begin
        if rising_edge(clk) then
            if (vdifState /= vdifHdrSt) then
                HdrCntr <= 0;
            else
                HdrCntr <= HdrCntr + 1;
            end if;
        end if;
    end process;
    
    
    -- count the number of data words written to fifo (625 in a packet)
    cntData : process(clk, vdifState)
    begin
        if rising_edge(clk) then
            if (vdifState /= vdifDataSt) then
                DataCntr <= (others => '0');
            else
                DataCntr <= DataCntr + 1;
            end if;
        end if;
    end process;

-------------------------------------------------------------------------------
-- Signals to the ten gigabit ethernet (kat_ten_gb_eth)    
    tgeReg  : process(clk, Header, FifoData)
        begin
            if rising_edge(clk) then
                case (vdifState) is
                    when vdifHdrSt => 
                        To10GbeTxData <= -- this is #$%*! up
                          std_logic_vector( Header(HdrCntr)(39 downto 32) ) &
                          std_logic_vector( Header(HdrCntr)(47 downto 40) ) &
                          std_logic_vector( Header(HdrCntr)(55 downto 48) ) &
                          std_logic_vector( Header(HdrCntr)(63 downto 56) )&
                          std_logic_vector( Header(HdrCntr)(7 downto 0) ) &
                          std_logic_vector( Header(HdrCntr)(15 downto 8) ) &
                          std_logic_vector( Header(HdrCntr)(23 downto 16) ) &
                          std_logic_vector( Header(HdrCntr)(31 downto 24) );
                        To10GbeTxDataValid <= '1';
                        To10GbeTxEOF <= '0';
                    
                    when vdifDataSt =>
                        To10GbeTxData <= FifoData;
                        To10GbeTxDataValid <= '1';
                        To10GbeTxEOF <= '0';
                    
                    when vdifDataEndSt =>
                        To10GbeTxData <= FifoData;
                        To10GbeTxDataValid <= '1';
                        To10GbeTxEOF <= '1';
                    
                    when others =>
                        To10GbeTxData <= (others => '0');
                        To10GbeTxDataValid <= '0';
                        To10GbeTxEOF <= '0';
                end case;
            end if;
        end process;

-------------------------------------------------------------------------------
-- states of the formatter    
    curStVdif : process(clk, Grs, MstrEna, DataCntr, HdrCntr)   
    begin
        if (Grs = '1')then
            vdifState <= vdifResetSt;
        elsif rising_edge(clk) then
            case(vdifState) is
                when vdifResetSt => -- put a wait between packets here? 
                        vdifState <= vdifWaitSt;
                    
                when vdifWaitSt =>  
                    if (MstrEna = '1') then
                        vdifState <= vdifHdrSt;
                    end if;

                when vdifHdrSt  =>
                    if ((legacy = '1') AND (HdrCntr < 1)) OR 
                       ((legacy = '0') AND (HdrCntr < 3)) then
                        vdifState   <= vdifHdrSt;
                    else
                        vdifState   <= vdifDataSt;
                    end if;

                when vdifDataSt => 
                    if (DataCntr < PACKET_END) then
                        vdifState <=  vdifDataSt;
                    else
                        vdifState <= vdifDataEndSt;
                    end if;

                when vdifDataEndSt =>   -- pulse To10GbeTxDataValid
                    vdifState <= vdifResetSt;

                when others => 
                    vdifState <= vdifResetSt;

            end case;
            end if;
    end process;

FifoEna <= '1' when (vdifState = vdifDataSt) OR (vdifState = vdifDataEndSt)
                else '0';
-------------------------------------------------------------------------------
    

end architecture;