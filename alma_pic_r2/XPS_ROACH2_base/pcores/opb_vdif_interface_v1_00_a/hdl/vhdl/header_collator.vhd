-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
-------------------------------------------------------

--This entity packs the sum data according to the number of channels to be recorded
--See the ICD with computing for cool graphics showing the details and comments in the
--code below for additional details
-- # $Id: header_collator.vhd,v 1.5 2014/07/13 14:39:49 asaez Exp $

entity header_collator is
 port(
	 -- timing reference signals 
	 C125        : in std_logic; 	
	 TE			 : in std_logic; 	
		
   --data from which to form header
     --packet serial number from data_write_ctrl
     PSN         : in std_logic_vector(63 downto 0); 

     --bad frame indicator bit from microprocessor
     badFrame    : in std_logic; 

     --time info from timing generator
     SFRE        : in std_logic_vector(29 downto 0); --seconds from ref. epoch
     FrameNum    : in std_logic_vector(23 downto 0); --data frame number

     --data from microprocessor interface
     refEpoch : in std_logic_vector(5 downto 0);
     nchan : in std_logic_vector(4 downto 0);
     frameLength : in std_logic_vector(23 downto 0);
     threadID    : in std_logic_vector(9 downto 0);
     stationID   : in std_logic_vector(15 downto 0);
     magicWord   : in std_logic_vector(23 downto 0);
     statusWord0 : in std_logic_vector(31 downto 0); 
     statusWord1 : in std_logic_vector(31 downto 0); 
     statusWord2 : in std_logic_vector(31 downto 0); 
     statusWord3 : in std_logic_vector(31 downto 0); 
     statusWord4 : in std_logic_vector(31 downto 0); 
     statusWord5 : in std_logic_vector(31 downto 0); 
     statusWord6 : in std_logic_vector(31 downto 0); 
     statusWord7 : in std_logic_vector(31 downto 0); 

      
   --data output of collator to header_fifo
     coll_out    : out std_logic_vector(63 downto 0);

   --control of the header mux from data_write_control
     hdr_sel     : in std_logic_vector(2 downto 0);
	 
   --data output of collator to C167
     coll_out_c167    : out std_logic_vector(7 downto 0);   
   --control of the header mux from C167
     hdr_sel_c167     : in std_logic_vector(5 downto 0)   
	 
	 
);
end header_collator;

architecture arch of header_collator is

    component bus_multiplexer
       port(
     statusWord0 : in std_logic_vector(31 downto 0); 
     statusWord1 : in std_logic_vector(31 downto 0); 
     statusWord2 : in std_logic_vector(31 downto 0); 
     statusWord3 : in std_logic_vector(31 downto 0); 
     statusWord4 : in std_logic_vector(31 downto 0); 
     statusWord5 : in std_logic_vector(31 downto 0); 
     statusWord6 : in std_logic_vector(31 downto 0); 
     statusWord7 : in std_logic_vector(31 downto 0); 
     sel         : in std_logic_vector(2 downto 0);
     output      : out std_logic_vector(31 downto 0); 
     clk         : in  std_logic
       );
    end component;

  --signal definitions
    --the output of the collator
      signal coll_out_sig: std_logic_vector(63 downto 0) := X"1000_2000_3000_0001";
	  signal coll_out_c167_sig: std_logic_vector(7 downto 0) := X"00";
      
    --the header words that are comprised of multiple quantities, as defined in the VDIF packet definition
      signal word0      : std_logic_vector(31 downto 0):= X"4000_0000";
      signal word1      : std_logic_vector(31 downto 0):= X"5000_0000";
      signal word2      : std_logic_vector(31 downto 0):= X"6000_0000";
      signal word3      : std_logic_vector(31 downto 0):= X"7000_0000";
      signal word4      : std_logic_vector(31 downto 0):= X"8000_0000";
      
      --long (64-bit) words comprised of pairs of the above words for sending to fifo
      signal lWord0      : std_logic_vector(63 downto 0);
      signal lWord1      : std_logic_vector(63 downto 0);
      signal lWord2      : std_logic_vector(63 downto 0);
      signal lWord3      : std_logic_vector(63 downto 0);
      signal lWord4      : std_logic_vector(63 downto 0);  

	  signal lWord0_register      : std_logic_vector(63 downto 0);
	  signal lWord1_register      : std_logic_vector(63 downto 0);
	  signal lWord2_register      : std_logic_vector(63 downto 0);
	  signal lWord3_register      : std_logic_vector(63 downto 0);
	  signal lWord4_register      : std_logic_vector(63 downto 0);
	  
	  signal TE_s		 : std_logic;
      signal statusWord          : std_logic_vector(31 downto 0):= X"4000_0000";
      signal sel_sig             : std_logic_vector(2 downto 0):= "000";

  begin


   bus_multiplexer_inst : bus_multiplexer
  port map (
	    statusWord0 => statusWord0,
	    statusWord1 => statusWord1,
	    statusWord2 => statusWord2,
	    statusWord3 => statusWord3,
	    statusWord4 => statusWord4,
	    statusWord5 => statusWord5,
	    statusWord6 => statusWord6,
	    statusWord7 => statusWord7,
	    sel         => sel_sig,
	    output      => statusWord,
	    clk         => C125
           );
    --selection of the status word to be sent

    sel_sig <= FrameNum(2 downto 0);

    --output of mux
    coll_out <= coll_out_sig;
	coll_out_c167 <= coll_out_c167_sig;
  
    --form 32-bit words from various pieces of info
    word0    <= badFrame & '0' & SFRE;
    word1    <= "00" & refEpoch & FrameNum;
    word2    <= "000" & nchan & frameLength;
    word3    <= "000001" & threadID & stationID;
    word4    <= X"02" & magicWord;
    --word5    <= statusWord;
    --word 6 and 7 are a repeat of the PSN
    
    --form 64-bit words from 32-bit words
    lWord0   <= PSN(7 downto 0) & PSN(15 downto 8) & PSN(23 downto 16) & PSN(31 downto 24) & PSN(39 downto 32) & PSN(47 downto 40) & PSN(55 downto 48) & PSN(63 downto 56);       
    lWord1   <= word0(7 downto 0) & word0(15 downto 8) & word0(23 downto 16) & word0(31 downto 24) & word1(7 downto 0) & word1(15 downto 8) & word1(23 downto 16) & word1(31 downto 24);
    lWord2   <= word2(7 downto 0) & word2(15 downto 8) & word2(23 downto 16) & word2(31 downto 24) & word3(7 downto 0) & word3(15 downto 8) & word3(23 downto 16) & word3(31 downto 24);
 lWord3   <= word4(7 downto 0) & word4(15 downto 8) & word4(23 downto 16) & word4(31 downto 24) & statusWord(7 downto 0) & statusWord(15 downto 8) & statusWord(23 downto 16) & statusWord(31 downto 24) ;
-- the order below seems right to Rich, but not to Geoff.  The order above is what Geoff wants
--    lWord3   <= statusWord(7 downto 0) & statusWord(15 downto 8) & statusWord(23 downto 16)  & statusWord(31 downto 24) & word4(7 downto 0) & word4(15 downto 8) & word4(23 downto 16) & word4(31 downto 24);
    lWord4   <= PSN(7 downto 0) & PSN(15 downto 8) & PSN(23 downto 16) & PSN(31 downto 24) & PSN(39 downto 32) & PSN(47 downto 40) & PSN(55 downto 48) & PSN(63 downto 56);
    
    mux: process(Hdr_sel, lWord0, lWord1, lWord2, lWord3, lWord4)
    begin
        case Hdr_sel is                 -- data selection signals
      	  when "000"  => coll_out_sig <= lWord0;
        	when "001"  => coll_out_sig <= lWord1;     
        	when "010"  => coll_out_sig <= lWord2;
        	when "011"  => coll_out_sig <= lWord3;
        	when "100"  => coll_out_sig <= lWord4;
        	when others => coll_out_sig <= X"0000_0000_0000_0000";
       end case;
    end process;
	
	
	process(C125,TE)
	begin
		if (rising_edge(C125)) then			
			TE_s <= TE; 
		end if;
    end process;	
	
	
	capture_upon_te_rising_edge: process(C125)
	begin
		if (rising_edge(C125)) then			
			if TE='1' and TE_s='0' then
				lWord0_register <= PSN;
				lWord1_register <= word1 & word0;
				lWord2_register <= word3 & word2;
				lWord3_register <= statusWord & word4;
				lWord4_register <= PSN;
			 end if;	
		end if;				
	end process;
	
	mux_c167: process(Hdr_sel_c167,lWord0,lWord1,lWord2,lWord3,lWord4)
	begin
		case Hdr_sel_c167 is
			when "000000" => coll_out_c167_sig <= lWord0_register(7 downto 0);		-- 0
			when "000001" => coll_out_c167_sig <= lWord0_register(15 downto 8);		-- 1
			when "000010" => coll_out_c167_sig <= lWord0_register(23 downto 16);	-- 2
			when "000011" => coll_out_c167_sig <= lWord0_register(31 downto 24);	-- 3
			when "000100" => coll_out_c167_sig <= lWord0_register(39 downto 32);	-- 4
			when "000101" => coll_out_c167_sig <= lWord0_register(47 downto 40);	-- 5
			when "000110" => coll_out_c167_sig <= lWord0_register(55 downto 48);	-- 6
			when "000111" => coll_out_c167_sig <= lWord0_register(63 downto 56);	-- 7
			when "001000" => coll_out_c167_sig <= lWord1_register(7 downto 0);		-- 0
			when "001001" => coll_out_c167_sig <= lWord1_register(15 downto 8);		-- 1
			when "001010" => coll_out_c167_sig <= lWord1_register(23 downto 16);	-- 2
			when "001011" => coll_out_c167_sig <= lWord1_register(31 downto 24);	-- 3
			when "001100" => coll_out_c167_sig <= lWord1_register(39 downto 32);	-- 4
			when "001101" => coll_out_c167_sig <= lWord1_register(47 downto 40);	-- 5
			when "001110" => coll_out_c167_sig <= lWord1_register(55 downto 48);	-- 6
			when "001111" => coll_out_c167_sig <= lWord1_register(63 downto 56);	-- 7			
			when "010000" => coll_out_c167_sig <= lWord2_register(7 downto 0);		-- 0
			when "010001" => coll_out_c167_sig <= lWord2_register(15 downto 8);		-- 1
			when "010010" => coll_out_c167_sig <= lWord2_register(23 downto 16);	-- 2
			when "010011" => coll_out_c167_sig <= lWord2_register(31 downto 24);	-- 3
			when "010100" => coll_out_c167_sig <= lWord2_register(39 downto 32);	-- 4
			when "010101" => coll_out_c167_sig <= lWord2_register(47 downto 40);	-- 5
			when "010110" => coll_out_c167_sig <= lWord2_register(55 downto 48);	-- 6
			when "010111" => coll_out_c167_sig <= lWord2_register(63 downto 56);	-- 7
			when "011000" => coll_out_c167_sig <= lWord3_register(7 downto 0);		-- 0
			when "011001" => coll_out_c167_sig <= lWord3_register(15 downto 8);		-- 1
			when "011010" => coll_out_c167_sig <= lWord3_register(23 downto 16);	-- 2
			when "011011" => coll_out_c167_sig <= lWord3_register(31 downto 24);	-- 3
			when "011100" => coll_out_c167_sig <= lWord3_register(39 downto 32);	-- 4
			when "011101" => coll_out_c167_sig <= lWord3_register(47 downto 40);	-- 5
			when "011110" => coll_out_c167_sig <= lWord3_register(55 downto 48);	-- 6
			when "011111" => coll_out_c167_sig <= lWord3_register(63 downto 56);	-- 7			
			when "100000" => coll_out_c167_sig <= lWord4_register(7 downto 0);		-- 0
			when "100001" => coll_out_c167_sig <= lWord4_register(15 downto 8);		-- 1
			when "100010" => coll_out_c167_sig <= lWord4_register(23 downto 16);	-- 2
			when "100011" => coll_out_c167_sig <= lWord4_register(31 downto 24);	-- 3
			when "100100" => coll_out_c167_sig <= lWord4_register(39 downto 32);	-- 4
			when "100101" => coll_out_c167_sig <= lWord4_register(47 downto 40);	-- 5
			when "100110" => coll_out_c167_sig <= lWord4_register(55 downto 48);	-- 6
			when "100111" => coll_out_c167_sig <= lWord4_register(63 downto 56);	-- 7
			when others => coll_out_c167_sig   <= X"00";
		end case;	
	end process;

  end arch;

      
   
