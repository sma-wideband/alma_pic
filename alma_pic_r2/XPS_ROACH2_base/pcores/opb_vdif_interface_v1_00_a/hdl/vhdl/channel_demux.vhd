-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

--This entity packs the sum data according to the number of channels to be recorded
--See the ICD with computing for cool graphics showing the details and comments in the
--code below for additional details

entity channel_demux is
 port(

   --data to format from data interface (real sum or test data)
   sum_di    :  in std_logic_vector(63 downto 0);

   --data out of channel_demux to FIFO
   sum_ch_demux : out std_logic_vector(63 downto 0);

   --log base 2 of number of IF channels to format (32 = 5; 16 = 4, etc.)
   nchan   : in std_logic_vector(4 downto 0); -- from uP_interface

   --high for one clock at the beginning of each frame
   FrameSync : in std_logic;  --from timing generator

   --125 MHz clock, from timing_generator
   C125   : in std_logic;

   --Grs is the general reset; initialize while = 1; from uP_interface
   Grs    : in std_logic;

   --Start transmitting frames at the next 1PPS (Grs needs to be zero)
   RunFm  : in std_logic --from uP_interface
);
end channel_demux;

architecture arch of channel_demux is

   signal nchan_sig   : std_logic_vector(4 downto 0); -- to lock in nchan value at start of frame
   signal dcStateCtr       : std_logic_vector(3 downto 0);  --for debugging
   signal sum_ch_demux_sig : std_logic_vector(63 downto 0);
   signal data_cntr_sig    : std_logic_vector(15 downto 0) := X"0000";
   signal data_limit_sig   : std_logic_vector(15 downto 0) := X"0000";   

   type data_cntr_state is
   (
      dc_reset,      --here during reset
      dc_wait_Run_hi,--here after reset, wait for RunFm to go high
      dc_wait_FS_lo, --here after RunFm goes high, waiting for FrameSync to be lo
      dc_wait_FS_hi, --here waiting for FrameSync to go high
      dc_run,        --here after FrameSync goes high and RunFm is high
      dc_stopping,   --here after RunFm goes low, waiting for FrameSync to go pulse
      dc_stopped     --here after FrameSync goes high
   );
   signal dcState : data_cntr_state;

   begin
   
      sum_ch_demux <= sum_ch_demux_sig; --route signal to output

      cntr_proc: process(C125)  --to get correct write rate and phase
      variable nchan_var : std_logic_vector(4 downto 0); -- to lock in nchan value at start of frame
      begin
        if(Grs = '1') then
          data_cntr_sig <= X"0000";
          dcState <= dc_reset;
          dcStateCtr <= X"0";
        else
          if rising_edge(C125) then  --incorporate state machine for correct sequencing
             case(dcState) is
                when dc_reset =>                   --we have come out of reset
                   data_cntr_sig <= X"0000";       --do this again in case we never get a reset
                   if(RunFm = '0') then            --wait for RunFM to go hi 
                      dcState <= dc_wait_Run_hi;
                      dcStateCtr <= X"1";                        
                   else                            --if it's already hi, go wait on FrameSync to be low
                      if(FrameSync = '0') then     --if Frame Sync is lo, wait for it to go hi
                         dcState <= dc_wait_FS_hi;
                         dcStateCtr <= X"3";
                      else 
                         dcState <= dc_wait_FS_lo;  --if FrameSync is hi, go wait for it to go lo (then hi)
                         dcStateCtr <= X"2";
                      end if;
                   end if;          

                when dc_wait_Run_hi =>              --we are now waiting for runFm to go hi
                   if(RunFm = '1') then          
                      if(FrameSync = '0') then      --now we wait for FrameSync to go hi
                         dcState <= dc_wait_FS_hi;
                         dcStateCtr <= X"3";
                      else                          --if it goes high with FrameSync is high, wait for the next FrameSync
                         dcState <= dc_wait_FS_lo;  
                         dcStateCtr <= X"2";
                      end if;
                   end if;
                   
                when dc_wait_FS_lo =>               --we are waiting for Frame Sync to go lo
                   if(FrameSync = '0') then 
                      dcState <= dc_wait_FS_hi;     --when it happens we go wait for Frame Sync to go hi
                      dcStateCtr <= X"3";                        
                   end if;
                   
                when dc_wait_FS_hi =>               --we are waiting for Frame Sync to go hi
                   if(FrameSync = '1') then         --when it happens we go to the run state 
                      dcState <= dc_run;
                      dcStateCtr <= X"4";
                      nchan_var := nchan;           --lock in the value of nchan and data_limit 
                      case(nchan) is
                        when "00101" => data_limit_sig <= b"0000_0011_1110_0111"; --1000 pieces of 64-bit data/frame
                        when "00100" => data_limit_sig <= b"0000_0111_1100_1111"; --2000 pieces of 64-bit data/frame
                        when "00011" => data_limit_sig <= b"0000_1111_1001_1111"; --4000 pieces of 64-bit data/frame
                        when "00010" => data_limit_sig <= b"0001_1111_0011_1111"; --8000 pieces of 64-bit data/frame
                        when "00001" => data_limit_sig <= b"0011_1110_0111_1111"; --16000 pieces of 64-bit data/frame
                        when "00000" => data_limit_sig <= b"0111_1100_1111_1111"; --32000 pieces of 64-bit data/frame
                        when others  => data_limit_sig <= b"0000_0000_0000_0011"; --3, for test purposes
                      end case;
                      case(nchan_var) is
                         when("00101") =>                 --and start collating the data
                            sum_ch_demux_sig <= sum_di;

                         when("00100") =>                 --and start collating the data
                            sum_ch_demux_sig(63 downto 32) <= sum_di(31 downto 0);        --lower 16 channels to high half
                            sum_ch_demux_sig(31 downto 0)  <= sum_ch_demux_sig(63 downto 32); --high half to low half
                            
                         when("00011") =>                 --and start collating the data
                            sum_ch_demux_sig(63 downto 48) <= sum_di(15 downto 0);        --lower 8 channels to high quarter
                            sum_ch_demux_sig(47 downto 0)  <= sum_ch_demux_sig(63 downto 16); --rest just shifts down
                            
                         when("00010") =>                 --and start collating the data
                            sum_ch_demux_sig(63 downto 56) <= sum_di(7 downto 0);        --lower 4 channels to high eighth
                            sum_ch_demux_sig(47 downto 0)  <= sum_ch_demux_sig(63 downto 16); --rest just shifts down   
                            
                         when("00001") =>                 --and start collating the data
                            sum_ch_demux_sig(63 downto 60) <= sum_di(3 downto 0);        --lower 2 channels to high 16th
                            sum_ch_demux_sig(59 downto 0)  <= sum_ch_demux_sig(63 downto 4); --rest just shifts down       
                            
                         when("00000") =>                 --and start collating the data
                            sum_ch_demux_sig(63 downto 62) <= sum_di(1 downto 0);        --lower 1 channel to high 32nd
                            sum_ch_demux_sig(61 downto 0)  <= sum_ch_demux_sig(63 downto 2); --rest just shifts 

                         when others =>
                            sum_ch_demux_sig <= X"0000000000000000";
                      end case;                      
                   end if;
                   
                when dc_run =>
                   if((data_cntr_sig = data_limit_sig) AND (runFM = '0')) then --stop after end of frame
                     dcState <= dc_wait_Run_hi;
                      dcStateCtr <= X"3"; 
                   end if;
                   
                   if(data_cntr_sig = data_limit_sig) then
                     data_cntr_sig <= X"0000";
                   else
                     data_cntr_sig <= data_cntr_sig + '1';
                   end if;

                   case(nchan_var) is
                     when("00101") =>                 --and start collating the data
                        sum_ch_demux_sig <= sum_di;

                     when("00100") =>                 --and start collating the data
                        sum_ch_demux_sig(63 downto 32) <= sum_di(31 downto 0);        --top 16 channels to high half
                        sum_ch_demux_sig(31 downto 0)  <= sum_ch_demux_sig(63 downto 32); --high half to low half

                     when("00011") =>                 --and start collating the data
                        sum_ch_demux_sig(63 downto 48) <= sum_di(15 downto 0);        --lower 8 channels to high quarter
                        sum_ch_demux_sig(47 downto 0)  <= sum_ch_demux_sig(63 downto 16); --rest just shifts down
                    
                     when("00010") =>                 --and start collating the data
                        sum_ch_demux_sig(63 downto 56) <= sum_di(7 downto 0);        --lower 4 channels to high eighth
                        sum_ch_demux_sig(47 downto 0)  <= sum_ch_demux_sig(63 downto 16); --rest just shifts down                         
                    
                     when("00001") =>                 --and start collating the data
                        sum_ch_demux_sig(63 downto 60) <= sum_di(3 downto 0);        --lower 2 channels to high 16th
                        sum_ch_demux_sig(59 downto 0)  <= sum_ch_demux_sig(63 downto 4); --rest just shifts down                          

                     when("00000") =>                 --and start collating the data
                        sum_ch_demux_sig(63 downto 62) <= sum_di(1 downto 0);        --lower 1 channel to high 32nd
                        sum_ch_demux_sig(61 downto 0)  <= sum_ch_demux_sig(63 downto 2); --rest just shifts
                        
                     when others =>
                        sum_ch_demux_sig <= X"0000000000000000";
                  end case; 
                  
                when others =>
                   dcState <= dc_reset;
                   dcStateCtr <= X"0";                     
             end case;
          end if;
       end if;
       nchan_sig <= nchan_var;  --for debug
      end process cntr_proc;



   end arch;

      
   
