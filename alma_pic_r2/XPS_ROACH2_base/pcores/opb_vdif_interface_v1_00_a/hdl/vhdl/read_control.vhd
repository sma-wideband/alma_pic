-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;
-------------------------------------------------------

-- This component is used to control the reading of the data and write FIFOs.  The component can be viewed as a state machine.  While reset is high, it remains in a reset state.
-- Once reset goes low, it waits for run to go high.  Once run goes high, it waits for the next 1PPS rising edge.  Once this is received, it waits for prog_full from the data FIFO,
-- indicating there is a frame's worth of data available for formatting.  Once prog_full goes high, it effects the reading of 5 header words from the header_fifo.  After this  it
-- reads out a frame's worth of data from the data fifo.  The number of data words read depends on nchan as detailed in the table in Section 4.2.2.  Next it waits for prog_full to
-- go high again (it may already be high) to start transmitting the next frame.  The Run bit is checked at the conclusion of each frame and a clean stop is made at the end of the
-- current.  The Grs bit similarly should cause the current frame to end cleanly (correct number of words and EOF).  However the data in the frame may be garbage since the FIFO
-- reset input is asynchronous.  

-- The component's outputs include the read enables to both FIFOs, d_rd_en and h_rd_en as well as two control signals to the ten_GbE interface, To10GbeTxDataValid and To10GbeTxEOF.

-- # $Id: read_control.vhd,v 1.1 2013/10/03 12:29:48 nlasso Exp $ 

entity read_control is
   port(

      --Grs is the general reset; initialize while = 1; from uP_interface
      Grs    : in std_logic;

      --Start transmitting frames at the next 1PPS (Grs needs to be zero)
      RunFm    : in std_logic; --from uP_interface

      --internally generated 1PPS from timing_generator
      PPS_PIC   : in std_logic;

      --higher frequency clock for FIFO output, from timing_generator
      CFIFO  : in std_logic;

      --log base 2 of number of IF channels to format (32 = 5; 16 = 4, etc.)
      --the length of the data frame depends on this
      nchan   : in std_logic_vector(4 downto 0); -- from uP_interface

      --indicates > 1000 words available for frame
      prog_empty  : in std_logic;
      
      -- connect to FIFOs
      h_rd_en	: out std_logic;
      d_rd_en	: out std_logic;
      
      --data inputs from fifos
      h_fifo_out : in std_logic_vector(63 downto 0);  --from header fifo
      d_fifo_out : in std_logic_vector(63 downto 0);  --from data fifo
      
      --connect to ten_Gbe module
      To10GbeTxData       : out std_logic_vector(63 downto 0);  --data frame
      To10GbeTxDataValid  : out std_logic;
      To10GbeTxEOF        : out std_logic;
      
      --monitor point to verify capture of PPS_PIC
      PPS_read            : out std_logic
   );
end read_control;

architecture arch of read_control is

  signal   RunFM_Z1             : std_logic := '0';  --capture runFM with CFIFO
	signal   RunFM_Z2             : std_logic := '0';
	signal   RunFM_Z3             : std_logic := '0';	
	signal   PPS_PIC_Z1           : std_logic := '0';  --capture PPS_PIC with CFIFO
	signal   PPS_PIC_Z2           : std_logic := '0';
	signal   PPS_PIC_Z3           : std_logic := '0';
	signal   idle_sig             : std_logic := '1';	 --four states for frame control
	signal   startReq_sig         : std_logic := '0';	
	signal   wait_sig             : std_logic := '0';	
	signal   run_sig              : std_logic := '0';	
	signal   nchan_sig            : std_logic_vector(4 downto 0) := "00000";	--capture nchan when ready to start
	signal   counter1_sig         : std_logic_vector(15 downto 0) := X"0000";	--where we are in frame
	signal   muxed_data_sig       : std_logic_vector(63 downto 0);	          --combined data/header	
	signal   To10GbeTxDataValid_a : std_logic;	                              --advanced version of data valid
	signal   To10GbeTxEOF_a       : std_logic;	                              --advanced version of EOF
	signal   h_rd_en_sig          : std_logic;                                --to use a delayed version of h_rd_en
	signal   prog_full            : std_logic;                                --goes high when a full frame of data is available


		
  begin
  
    To10GbeTxData <= muxed_data_sig;  --drive the output data
    PPS_read      <= PPS_PIC_Z3;      --to drive a test point
    prog_full     <= NOT prog_empty;  --prog_empty goes low when more than the programmable threshold of data is available in the fifo
      
    ctrl_sigs: process(CFIFO)
	    variable counter1	      : unsigned(15 downto 0) := X"0000";  --to keep up with the amount of data read and transmitted

	    begin
      
	      if(Grs = '1') then              --asynchronous reset; making frame end cleanly on reset is not practical
	        h_rd_en             <= '0';
	        h_rd_en_sig         <= '0';
	        d_rd_en             <= '0';
	        To10GbeTxDataValid  <= '0';
	        To10GbeTxEOF        <= '0';
	        counter1            :=  X"0000" ;
	        idle_sig            <= '1';	        
	        startReq_sig        <= '0';
	        wait_sig            <= '0';
	        run_sig             <= '0';
	        counter1_sig        <= X"0000";
 	        muxed_data_sig      <= X"0000_0000_0000_0000";
	        
	      elsif rising_edge(CFIFO) then
	      
	        RunFM_Z1   <= RunFM;            --synchronize to CFIFO
	        RunFM_Z2   <= RunFM_Z1;
	        RunFM_Z3   <= RunFM_Z2;	        --for rising edge detection       
	        PPS_PIC_Z1 <= PPS_PIC;          --ditto
	        PPS_PIC_Z2 <= PPS_PIC_Z1;
	        PPS_PIC_Z3 <= PPS_PIC_Z2;
          To10GbeTxDataValid  <= To10GbeTxDataValid_a;  --need a delay of 1 to account for the pipeline from fifo to mux out
          To10GbeTxEOF        <= To10GbeTxEOF_a;

          if(idle_sig = '1' AND RunFM_Z2 = '1' AND RunFM_Z3 = '0') then  --RunFm went high; issue start request
            h_rd_en               <= '0';
            h_rd_en_sig           <= '0';
            d_rd_en               <= '0';
            To10GbeTxDataValid_a  <= '0';
            To10GbeTxEOF_a        <= '0';
  	        idle_sig              <= '0';
            startReq_sig          <= '1';  --go wait for PPS_PIC rising edge
            wait_sig              <= '0';
	          run_sig               <= '0';
          end if;
	            
	        if(startReq_sig = '1' AND PPS_PIC_Z2 = '1' AND PPS_PIC_Z3 = '0' ) then --PPS rising edge; nchan capture
            if(unsigned(nchan) < 6) then
              h_rd_en               <= '0';
              h_rd_en_sig           <= '0';
              d_rd_en               <= '0';
            	To10GbeTxDataValid_a  <= '0';
              To10GbeTxEOF_a        <= '0';
              nchan_sig             <= nchan;     --capture nchan at PPS rising edge
              idle_sig              <= '0';
              startReq_sig          <= '0';   
              wait_sig              <= '1';       --wait for prog_full to go high
              run_sig               <= '0';
            else                                  --invalid nchan; go to idle state 
              h_rd_en               <= '0';
              h_rd_en_sig           <= '0';
              d_rd_en               <= '0';
            	To10GbeTxDataValid_a  <= '0';
              To10GbeTxEOF_a        <= '0';
              nchan_sig             <= nchan;     
              idle_sig              <= '1';   
              startReq_sig          <= '0';   
              wait_sig              <= '0';       
              run_sig               <= '0'; 
            end if;           
          end if;       
          
          if(wait_sig = '1' AND prog_full = '1' AND unsigned(nchan) < 6) then --go transmit a frame
            h_rd_en               <= '0';
            h_rd_en_sig           <= '0';
            d_rd_en               <= '0';
            counter1              := X"0000";
            idle_sig              <= '0';
            startReq_sig          <= '0';   
            wait_sig              <= '0';
            run_sig               <= '1';            
          	To10GbeTxDataValid_a  <= '0';
            To10GbeTxEOF_a        <= '0';        
          end if;
              
	        if(run_sig = '1') then         --count transmitted data so we know when to quit
            counter1            := counter1  + 1;
	        end if;
	        
	        if(h_rd_en_sig = '1') then        --mux between header and data fifos
	          muxed_data_sig <= h_fifo_out;
	        else
	          muxed_data_sig <= d_fifo_out;
	        end if;
	          
	        --generate control signals as a function of where we are in the frame and nchan    
          if(counter1 >= 1 and counter1 <= 5) then
            h_rd_en               <= '1';		-- enable the reading of 5 header words (including PSN)
            h_rd_en_sig           <= '1';
            d_rd_en               <= '0';
         	  To10GbeTxDataValid_a  <= '1';
            To10GbeTxEOF_a        <= '0';

	        elsif(counter1 >= 6 and counter1 < 1010) then
            if(nchan = "00000" OR nchan = "00001") then
	            if (counter1 < 629) then  --transmit 624 octets
	              h_rd_en               <= '0';
	              h_rd_en_sig           <= '0';
	              d_rd_en               <= '1';
	              To10GbeTxDataValid_a  <= '1';
	              To10GbeTxEOF_a        <= '0';
	            elsif (counter1 = 630) then --transmit the last
	              h_rd_en               <= '0';
	              h_rd_en_sig           <= '0';
	              d_rd_en               <= '1';
	              To10GbeTxDataValid_a  <= '1';
	              To10GbeTxEOF_a        <= '1';
	            elsif (counter1 = 631) then
	              h_rd_en               <= '0';
	              h_rd_en_sig           <= '0';
	              d_rd_en               <= '0';
	              To10GbeTxDataValid_a  <= '0';
	              To10GbeTxEOF_a        <= '0';
	              if( RunFM_Z2 = '1') then  --continue with the next frame
	                idle_sig          <= '0';
	                startReq_sig      <= '0';
	                wait_sig          <= '1';
                  run_sig           <= '0';		              
	              else               --RunFm went low so go back to waiting for it to go high
	                idle_sig          <= '1';
	                startReq_sig      <= '0';
	                wait_sig          <= '0';
                  run_sig           <= '0';		              
	              end if;		            
	              counter1 := X"0000";
	            end if;
	          elsif (nchan = "00010" OR nchan = "00011" OR nchan = "00100" OR nchan = "00101") then
	            if (counter1 < 1004) then  --transmit 999 octets
	              h_rd_en               <= '0';
	              h_rd_en_sig           <= '0';
	              d_rd_en               <= '1';
	              To10GbeTxDataValid_a  <= '1';
	              To10GbeTxEOF_a        <= '0';
	            elsif (counter1 = 1005) then  --transmit last octet
	              h_rd_en               <= '0';
	              h_rd_en_sig           <= '0';
	              d_rd_en               <= '1';
	              To10GbeTxDataValid_a  <= '1';
	              To10GbeTxEOF_a        <='1';
	            elsif (counter1 = 1006) then
	              h_rd_en               <= '0';
	              h_rd_en_sig           <= '0';
	              d_rd_en               <= '0';
	              To10GbeTxDataValid_a  <= '0';
	              To10GbeTxEOF_a        <= '0';
	              if( RunFM_Z2 = '1') then  --continue with the next frame
	                idle_sig            <= '0';
	                startReq_sig        <= '0';
	                wait_sig            <= '1';
                  run_sig             <= '0';		              
	              else               --RunFm went low so go back to waiting for it to go high
	                idle_sig            <= '1';
	                startReq_sig        <= '0';
	                wait_sig            <= '0';
                  run_sig             <= '0';		              
	              end if;		            
	              counter1 := X"0000";
	            end if;
            else  --illegal nchan so go to idle state
		            h_rd_en               <= '0';
		            h_rd_en_sig           <= '0';
		            d_rd_en               <= '0';
		            To10GbeTxDataValid_a  <= '0';
		            To10GbeTxEOF_a        <= '0';
		            counter1              := X"0000";
                idle_sig              <= '1';
                startReq_sig          <= '0';
                wait_sig              <= '0';
                run_sig               <= '0';			            
            end if; --if nchan...
          end if;   --if counter1...
	    end if;       --if rising_edge
	    counter1_sig <= std_logic_vector(counter1);    --so we can follow it, one clock later, in ghdl
    end process ctrl_sigs;
    
end arch;

      
   
