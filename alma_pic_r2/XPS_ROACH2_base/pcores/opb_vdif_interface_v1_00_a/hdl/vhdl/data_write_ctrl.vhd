-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;
-------------------------------------------------------

--  This component produces a write enable signal for the data fifo.  We need one write enable per octet, since the fifo is 64-bits
--  wide. Write enable pulses start at with the first 1PPS after the RunFm signal goes high.  They are modulated by nchan.  For example 
--  when nchan = 5 (32 channels) the write enable is always high once it starts.  For nchan = 0, (1 channel) it is high every 32
--  clocks and the first one has to hold off until the first octet has been formed by the channel_demux.

-- Check Grs constantly
-- The write enable signal goes active at the first PPS_PIC after RunFm goes high


-- # $Id: data_write_ctrl.vhd,v 1.3 2013/04/29 14:41:24 nlasso Exp $ 

entity data_write_ctrl is
   port(

   --Grs is the general reset; initialize while = 1; from uP_interface
   Grs    : in std_logic;

   --Start transmitting frames at the next 1PPS (Grs needs to be zero)
   RunFm    : in std_logic; --from uP_interface

   --125 MHz clock, from timing_generator
   C125   : in std_logic;

   --high for one clock at the beginning of each frame
   FrameSync : in std_logic;  --from timing generator
   
   --high for one clock before PPS_PIC
   PPS_PIC_Adv : in std_logic;  --from timing generator   

   --log base 2 of number of IF channels to format (32 = 5; 16 = 4, etc.)
   nchan   : in std_logic_vector(4 downto 0); -- from uP_interface

   --write enable to data FIFO
   d_wr_en : out std_logic
   );
end data_write_ctrl;

architecture arch of data_write_ctrl is

    signal  RunFM_Z1_sig  : std_logic := '0';                        -- to detect rising edge of RunFM
    signal  d_wr_en_sig   : std_logic := '0';                        -- to allow a pipeline delay of the write enable   
    signal  startReq_sig  : std_logic := '0';                        -- to log a start request
    signal  stopReq_sig   : std_logic := '0';                        -- to log a stop request   
    signal  stopped_sig   : std_logic := '0';                        -- to indicate stopped state  
    signal  running_sig   : std_logic := '0';                        -- to indicate running state
    signal  nchan_sig     : std_logic_vector (4 downto 0) := "00101";-- to latch the state of nchan 
    signal  data_ctr_sig  : std_logic_vector (4 downto 0) := "00000";-- used to determine when to pulse d_wr_en
    
  begin
      
  process(Grs,C125)  
	begin
	  if(Grs = '1') then  --asynchronous reset
	    d_wr_en_sig <= '0';
	    d_wr_en     <= '0';
	    stopReq_sig <= '0';
	    stopped_sig <= '1';
	    running_sig <= '0';
	  else
	    if(rising_edge(C125)) then
	    
	      RunFM_Z1_sig  <= RunFM;       --to detect rising edge
	      d_wr_en       <= d_wr_en_sig; --delays output by one clock to match the data
	      
	      if stopped_sig = '1' then   --stay reset if stopped_sig is low
		      d_wr_en_sig <= '0';
		    end if;
		    
		    if (runFM = '1') AND (RunFM_Z1_sig = '0') then --detect rising edge of RunFM
		      startReq_sig <= '1';                         --go to the start request state
		      stopped_sig  <= '0';
		    end if;
		    
		    if (startReq_sig = '1') AND (PPS_PIC_Adv = '1') then  --start with the 1PPS
		      nchan_sig <= nchan;        --capture the state of nchan
		      startReq_sig   <= '0'; 
		      running_sig    <= '1';     --move to the running state  
		      data_ctr_sig   <= "00000";
		      
		      if nchan = "00101" then    --only this case needs to write on the next clock
		        d_wr_en_sig <= '1';
		      end if;
		      
		    end if;
		    
		    if  (running_sig = '1') then      
            data_ctr_sig <= data_ctr_sig + 1;
            case (nchan_sig) is                  --handle the various nchan cases
            
              when "00000" =>
                if(data_ctr_sig = "11110") then
                  d_wr_en_sig <= '1';
                end if;
                if(data_ctr_sig = "11111") then
                  data_ctr_sig  <= "00000";
                  d_wr_en_sig   <= '0';
                end if;
            
              when "00001" =>
                if(data_ctr_sig = "01110") then
                  d_wr_en_sig <= '1';
                end if;
                if(data_ctr_sig = "01111") then
                  data_ctr_sig  <= "00000";
                  d_wr_en_sig   <= '0';
                end if;
                            
              when "00010" =>
                if(data_ctr_sig = "00110") then
                  d_wr_en_sig <= '1';
                end if;
                if(data_ctr_sig = "00111") then
                  data_ctr_sig  <= "00000";
                  d_wr_en_sig   <= '0';
                end if;
                            
              when "00011" =>
                if(data_ctr_sig = "00010") then
                  d_wr_en <= '1';
                end if;
                if(data_ctr_sig = "00011") then
                  data_ctr_sig  <= "00000";
                  d_wr_en_sig   <= '0';
                end if;
                            
              when "00100" =>
                if(data_ctr_sig = "00000") then
                  d_wr_en_sig <= '1';
                end if;
                if(data_ctr_sig = "00001") then
                  data_ctr_sig  <= "00000";
                  d_wr_en_sig   <= '0';
                end if;
                              
              when "00101" =>
                if(data_ctr_sig = "00000") then
                  d_wr_en_sig <= '1';
                end if;
                if(data_ctr_sig = "00000") then
                  data_ctr_sig  <= "00000";
                  --d_wr_en_sig       <= '0'; always 1 in this mode
                end if;
                
              when others => null;
            end case;
          end if;
    		    
		    if (running_sig = '1') AND (RunFM_Z1_sig = '0') then  --stop when runFM goes low
		      stopReq_sig <= '1';
		    end if;
		    
		    if (stopReq_sig = '1')  and (FrameSync = '1') then  --dont stop until the next frameSync
		      stopReq_sig   <= '0';	        
		      stopped_sig   <= '1';
		      running_sig   <= '0';
		      d_wr_en_sig   <= '0';
		      data_ctr_sig  <= "00000";
		    end if;
		      
		  end if;  --rising edge of C125
		    
	  end if; --Grs = 1
  end process;
end arch;

      
   
