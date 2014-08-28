-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;
-------------------------------------------------------

-- # $Id: header_write_control.vhd,v 1.4 2014/04/03 16:51:20 rlacasse Exp $

--  This component produces a write enable signal for the data fifo.  We need one write enable per octet, since the fifo is 64-bits
--  wide. Write enable pulses start at with the first 1PPS after the Run signal goes high.  They are modulated by nchan.  For example 
--  when nchan = 5 (32 channels) the write enable is always high once it starts.  For nchan = 0, (1 channel) it is high every 32
--  clocks and the first one has to hold off until the first octet has been formed by the channel_demux.

-- Check Grs constantly
-- Once a "Run" signal arrives the system transmits a whole frame independently of the state of the run signal.
-- A channel change while transmitting a frame produces a reset.

-- # $Id: header_write_control.vhd,v 1.4 2014/04/03 16:51:20 rlacasse Exp $ 

entity header_write_control is
   port(

   --Grs is the general reset; initialize while = 1; from uP_interface
   Grs    	: in std_logic;

   --Start transmitting frames at the next 1PPS (Grs needs to be zero)
   RunFm  	: in std_logic; --from uP_interface

   --125 MHz clock, from timing_generator
   C125   	: in std_logic;
 
   --high for one clock at the beginning of each frame
   FrameSync 	: in std_logic;  --from timing generator

   --internally generated 1PPS from timing_generator
   PPS_PIC_Adv   	: in std_logic;

   --control of the header mux
   Hdr_sel 	: out std_logic_vector(2 downto 0);

   --header write control pulse
   h_wr_en    	: out std_logic;
   
   --initial packet serial number from uP interface
   PSN_init     : in std_logic_vector(63 downto 0);
   
   --incrementing packet serial number to data collator
   PSN          : out std_logic_vector(63 downto 0)   
   );
end header_write_control;

architecture arch of header_write_control is

  signal Hdr_sel_sig    : std_logic_vector(2 downto 0) := "000";
  signal startReq_sig   : std_logic := '0';
  signal running_sig    : std_logic := '0';  
  signal stopReq_sig    : std_logic := '0';
  signal StateCtr_sig   : std_logic_vector( 3 downto 0) := "0000";
  signal PSN_ctr_sig    : std_logic_vector(63 downto 0) := X"0000_0000_0000_0000";
  
  begin
  
    Hdr_sel <=  Hdr_sel_sig;  --drive output port      
    PSN     <=  PSN_ctr_sig;  --drive output port
    
    stateMach: process(Grs,C125)  
	    begin
	      
	    if(Grs = '1') then
	      StateCtr_sig <= "0000";
	      h_wr_en <= '0';             -- disable writing
	      Hdr_sel_sig <= "101";				-- Non used channel of the mux
	      PSN_ctr_sig <= X"0000_0000_0000_0000";
	    else
	      if(rising_edge(C125)) then
	        case (stateCtr_sig) is
	          when "0000" =>                                    --wait for Grs low and RunFM high
	            if((RunFm = '1') and (PPS_PIC_Adv = '0')) then
	              stateCtr_sig <= "0001";
	              Hdr_sel_sig <= "101";
	              h_wr_en     <= '0';
	              PSN_ctr_sig <= PSN_init;
	            elsif ((RunFm = '1') and (PPS_PIC_Adv = '1')) then  --case where RunFM and PPS_PIC_adv go high simultaneously
	              stateCtr_sig    <= "0010";
	              Hdr_sel_sig     <= "101";
	              h_wr_en         <= '0';
	              PSN_ctr_sig <= PSN_init;
	            else
                Hdr_sel_sig <= "101";
	              h_wr_en     <= '0';
	              PSN_ctr_sig <= PSN_init;
	            end if;
	          when "0001" =>                                    --wait for PPS_PIC_Adv high
	            if(PPS_PIC_Adv = '1') then
	              stateCtr_sig    <= "0010";
	              Hdr_sel_sig     <= "101";
	              h_wr_en         <= '0';
	            end if;
	          when "0010" =>                                    -- wait for header signals to settle
	              stateCtr_sig    <= "0011";                    
	              Hdr_sel_sig     <= "000";
	              h_wr_en         <= '1';
	              PSN_ctr_sig     <= PSN_init;
	          when "0011" =>                                    --start clocking header into fifo
	              stateCtr_sig    <= "0100";
	              Hdr_sel_sig     <= "001";
	              h_wr_en         <= '1';
	          when "0100" => 
	              stateCtr_sig    <= "0101";
	              Hdr_sel_sig     <= "010";
	              h_wr_en         <= '1';
	           when "0101" => 
	              stateCtr_sig    <= "0110";
	              Hdr_sel_sig     <= "011";
	              h_wr_en         <= '1';
	          when "0110" => 
	              stateCtr_sig    <= "0111";                
	              Hdr_sel_sig     <= "100";
	              h_wr_en         <= '1';
	          when "0111" => 
	              stateCtr_sig    <= "1000";                    --last one
	              Hdr_sel_sig     <= "101";
	              h_wr_en         <= '0';
	              PSN_ctr_sig     <= PSN_ctr_sig + '1';         --increment PSN after each frame
	          when "1000" => 
	            if((FrameSync = '1') and (RunFm = '1')) then	  --wait for Frame Sync and check
	              stateCtr_sig    <= "0011";                    --  RunFm
	              Hdr_sel_sig     <= "000";
	              h_wr_en         <= '1';
	            else if (RunFm = '0') then
	              stateCtr_sig    <= "0000";
	              Hdr_sel_sig     <= "101";
	              h_wr_en         <= '0';            
	              end if;
	            end if;
	          when others => 
	              stateCtr_sig    <= "0000";
	              Hdr_sel_sig     <= "101";
	              h_wr_en         <= '0';            
	        end case;
	      end if;   --if rising_edge
		  end if;     --if Grs

    end process;
end arch;

      
   
