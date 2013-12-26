-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

--This entity tests a bit stream against a 35-bit PRN data sequence, just like those used in many 
--other modules int he correlator.  It also measures statistics of a selected IF channel.
--A future enhancement could be a state machine that would measure all statistics with on command
--and store the data in RAM to be read out by the microprocessor.
--As of 2013-3-18, this code is considered checked-out and working.

entity sum_data_chk is
   port(
   --Grs is the general reset; a one causes various subsystems to go to initial state
   Grs      : in std_logic;

   --sum data, from data interface
   sum_in   : in std_logic_vector(63 downto 0);

   --which IF channel to test; bit 0 select MS/LS bit for PRN test
   chan     : in std_logic_vector(5 downto 0);

   --how long to measure statistics, in milliseconds, 127 msec max;
   stat_msec: in std_logic_vector(6 downto 0);

   --low causes PRN checker to stop, to save power
   prn_run  : in std_logic;

   --low causes statistic measurement to stop after the next 1-msec tic
   --rising edge causes a statistics measurement to start at the next 1-msec tic
   stat_start : in std_logic;

   --1-msec tic from timing generator (note 1_msec is an illegal VHDL name!)
   OneMsec     : in std_logic;

   --125 MHz clock
   C125        : in std_logic;

   --eight-bit PRN error count, available after 1 msec,
   --   saturates at 128 errors
   ecnt     : out std_logic_vector(7 downto 0);

  -- "plus 3" statistics count, 24 bits
  stat_p3: out std_logic_vector(23 downto 0);

  -- "plus 1" statistics count, 24 bits
  stat_p1: out std_logic_vector(23 downto 0);

  -- "minus 1" statistics count, 24 bits
  stat_m1: out std_logic_vector(23 downto 0);

  -- "minus 3" statistics count, 24 bits
  stat_m3: out std_logic_vector(23 downto 0);

  -- statistics measurement "done" indicator
  stat_rdy: out std_logic

   );
end sum_data_chk;

architecture arch of sum_data_chk is

   signal sum_in_ch   : std_logic_vector(1 downto 0);  -- 2 bits of selected channel
   signal sum_in_bit  : std_logic;                     -- one bit of selected channel
   signal sum_in_bit_Z1: std_logic;                    -- above delayed one clock
   signal chan_sel    : std_logic_vector(4 downto 0);  -- to select chan to monitor
   signal bit_sel     : std_logic;                     -- to select bit to monitor
   signal prg         : std_logic_vector(34 downto 0); -- pseudo-random data generator
   signal ctr_prg     : std_logic_vector(5 downto 0);  -- state counter for pseudo-random data gen
   signal init_ecnt   : std_logic;                     -- hold error counter at zero when high
   signal ecnt_ctr    : std_logic_vector(7 downto 0);  -- counter for prn errors   
   signal zero_pulse  : std_logic;                     -- high for one clock after long string of 0's
   signal stat_CE     : std_logic;                     -- count enable for statistics
   signal stat_ctr_p3 : std_logic_vector(23 downto 0);  --counter for +3 stats
   signal stat_ctr_p1 : std_logic_vector(23 downto 0);  --counter for +1 stats
   signal stat_ctr_m1 : std_logic_vector(23 downto 0);  --counter for -1 stats
   signal stat_ctr_m3 : std_logic_vector(23 downto 0);  --counter for -3 stats
   signal stat_indic  : std_logic_vector( 3 downto 0);  --to see what the state is during simulation
   signal intCtr      : std_logic_vector( 6 downto 0);
   signal stat_rdy_sig: std_logic;  --to drive status ready port


   type statStateCtr is   --state maching for statistics measurement
   (
      statWait,  --wait for stat_start to go high
      statArm, --from when stat_start goes high to OneMsec going high
      statTrig,--when armed, for one clock when OneMsec goes high
      statRun0,   --from statTriged, to expiration of run time
      statRun1,
      statFinish1, -- from expiration of run time to load of stats in output registers
      statFinish2 -- fromload of output registers to clearing of counters
   );
   signal statState: statStateCtr;

   begin
      
      bit_sel  <= chan(0);         --map select bits to input port "chan"
      chan_sel <= chan(5 downto 1);
      stat_rdy <= stat_rdy_sig;
      
      
      process(C125)  --32:2 mux, registered
      begin
         if(Grs = '1') then
            sum_in_ch <= "00";
         else
            if(rising_edge(C125)) then
               case chan_sel is                 -- control signals as a function of mode bits
                  when "00000" => sum_in_ch <= sum_in(1 downto 0);
                  when "00001" => sum_in_ch <= sum_in(3 downto 2);
                  when "00010" => sum_in_ch <= sum_in(5 downto 4);
                  when "00011" => sum_in_ch <= sum_in(7 downto 6);
                  when "00100" => sum_in_ch <= sum_in(9 downto 8);
                  when "00101" => sum_in_ch <= sum_in(11 downto 10);
                  when "00110" => sum_in_ch <= sum_in(13 downto 12);
                  when "00111" => sum_in_ch <= sum_in(15 downto 14);
                  when "01000" => sum_in_ch <= sum_in(17 downto 16);
                  when "01001" => sum_in_ch <= sum_in(19 downto 18);
                  when "01010" => sum_in_ch <= sum_in(21 downto 20);
                  when "01011" => sum_in_ch <= sum_in(23 downto 22);
                  when "01100" => sum_in_ch <= sum_in(25 downto 24);
                  when "01101" => sum_in_ch <= sum_in(27 downto 26);
                  when "01110" => sum_in_ch <= sum_in(29 downto 28);
                  when "01111" => sum_in_ch <= sum_in(31 downto 30);
                  when "10000" => sum_in_ch <= sum_in(33 downto 32);
                  when "10001" => sum_in_ch <= sum_in(35 downto 34);
                  when "10010" => sum_in_ch <= sum_in(37 downto 36);
                  when "10011" => sum_in_ch <= sum_in(39 downto 38);
                  when "10100" => sum_in_ch <= sum_in(41 downto 40);
                  when "10101" => sum_in_ch <= sum_in(43 downto 42);
                  when "10110" => sum_in_ch <= sum_in(45 downto 44);
                  when "10111" => sum_in_ch <= sum_in(47 downto 46);
                  when "11000" => sum_in_ch <= sum_in(49 downto 48);
                  when "11001" => sum_in_ch <= sum_in(51 downto 50);
                  when "11010" => sum_in_ch <= sum_in(53 downto 52);
                  when "11011" => sum_in_ch <= sum_in(55 downto 54);
                  when "11100" => sum_in_ch <= sum_in(57 downto 56);
                  when "11101" => sum_in_ch <= sum_in(59 downto 58);
                  when "11110" => sum_in_ch <= sum_in(61 downto 60);
                  when "11111" => sum_in_ch <= sum_in(63 downto 62);
                  when others  => sum_in_ch <= "00";
               end case;  
            end if;
         end if;
      end process;

      process(C125)  --2:1 mux, registered
      begin
         if(Grs = '1') then
            sum_in_bit <= '0';
         else
            if(rising_edge(C125)) then
               case bit_sel is                 -- control signals as a function of mode bits
                  when '0'    => sum_in_bit <= sum_in_ch(0);
                  when '1'    => sum_in_bit <= sum_in_ch(1);
                  when others => sum_in_bit <= sum_in_ch(1);
               end case;
            sum_in_bit_Z1 <= sum_in_bit;
            end if;
         end if;
      end process;

      process(C125)  --pseudo-random data generator, 35 bit, with initialize

         variable ctr_var : unsigned(5 downto 0) := "000000";

         begin
            if(prn_run = '1') then
                if(rising_edge(C125)) then
                   if(OneMsec = '1') then     --initialize for at least 35 clocks
                      ctr_var := "000000";
                      init_ecnt <= '1';
                      ecnt <= ecnt_ctr;      --update the output at the 1-msec tic
                   elsif(ctr_var < 60) then
                      ctr_var := ctr_var + 1;
                      init_ecnt <= '1';
                   else
                      init_ecnt <= '0';
                  end if;
               end if;
                  
               if(rising_edge(C125)) then
                  if(ctr_var < 60) then  --initialize generator if required
                     prg(34) <= sum_in_bit_Z1;
                     prg(33 downto 0) <= prg(34 downto 1);
                  else                   --run the PRG
                     prg(34) <= prg(2) XOR prg(0);
                     prg(33 downto 0) <= prg(34 downto 1);
                  end if;
               end if;
            else
               init_ecnt <= '0';
               prg(34 downto 0) <= "00000000000000000000000000000000000";
               ctr_var := "000000";
            end if;
           ctr_prg <= std_logic_vector(ctr_var);  --so we can see this in simulation
      end process;

      process(C125)  --detector for long string of zeros in input data
   
         variable zero_cnt_var : unsigned(15 downto 0) := X"0000";

         begin 
            if(rising_edge(C125)) then        
                                              
               if (sum_in_bit = '0') then             
                  zero_cnt_var := zero_cnt_var + 1;   
               else
                  zero_cnt_var := X"0000";
               end if;
               if (zero_cnt_var >= 32768) then  --use 4 for debug, 2^15 for synthesis
                  zero_cnt_var := X"0000";
                  zero_pulse <= '1';
               else
                  zero_pulse  <= '0';
               end if;
            end if;
      end process;

      process(C125)  --error detector and counter

         variable ecnt_var   : unsigned(7 downto 0) := "00000000";

         begin
            if(rising_edge(C125)) then  
               if(init_ecnt = '1') then
                  ecnt_var := "00000000";
               else  --count errors when generator and data differ or for long string of 0's
                  if((((prg(2) XOR prg(0)) XOR sum_in_bit_Z1) = '1') OR (zero_pulse = '1')) then 
                     ecnt_var :=  ecnt_var + 1;
                  end if;
                  if ecnt_var >= 99 then
                     ecnt_var := X"63";
                  end if;
               end if;
               ecnt_ctr <= std_logic_vector(ecnt_var);  --update the physical counter
            end if;
      end process;     

      process(c125, Grs) --statistics checker
         begin
            if(Grs = '1') then
               statState <= statWait;     --initialize everything
               stat_CE <= '0';
               stat_indic <= X"0";
               stat_ctr_p3 <= X"000000";
               stat_ctr_p1 <= X"000000";
               stat_ctr_m1 <= X"000000";
               stat_ctr_m3 <= X"000000";
               stat_p3     <= X"000000";  
               stat_p1     <= X"000000";
               stat_m1     <= X"000000";
               stat_m3     <= X"000000";
               stat_rdy_sig <= '0';
            else
               if(rising_edge(C125)) then
                  case(statState) is
                     when statWait =>
                        if stat_start = '0' then  --wait for stat_start signal from uP
                           statState <= statWait;
                        else
                           statState <= statArm;
                        end if;
                           stat_indic <= X"0";
                     when statArm =>
                        if(OneMsec = '1') then
                           statState <= statTrig;
                           intCtr   <= stat_msec;
                        end if;
                        stat_indic <= X"1";
                     when statTrig =>
                        stat_CE <= '1';
                        stat_rdy_sig <= '0';
                        intCtr <= intCtr - 1;
                        stat_indic <= X"2";
                        if ((intCtr = X"01") OR (intCtr = X"00")) then --note: handle bad input of '00' case
                           statState <= statRun0;  --final iteration
                        else
                           statState <= statRun1;  --get here when need at least 2 iterations
                        end if;
                        intCtr <= intCtr - 1;
                     when statRun1 =>
                        stat_indic <= X"3";
                        if (OneMsec = '1') then
                           intCtr <= intCtr - 1;
                           if(intCtr = X"01") then --now we have one more iteration
                              statState <= statRun0;
                           end if;
                        end if;
                     when statRun0 =>
                        stat_indic <= X"4";
                        if (OneMsec = '1') then   --last one msec iteration
                           statState <= statFinish1;
                        end if;
                     when statFinish1 =>
                        stat_indic <= X"5";    
                        stat_CE <= '0';                
                        stat_p3 <= stat_ctr_p3;  --put stats in output registers
                        stat_p1 <= stat_ctr_p1;
                        stat_m1 <= stat_ctr_m1;
                        stat_m3 <= stat_ctr_m3;
                        stat_rdy_sig <= '1';   
                        statState <= statFinish2;
                     when statFinish2 =>
                        stat_ctr_p3 <= X"000000";  --clear stat counters
                        stat_ctr_p1 <= X"000000";
                        stat_ctr_m1 <= X"000000";
                        stat_ctr_m3 <= X"000000"; 
                        stat_indic <= X"6";
                        statState <= statWait;       
                     when others =>
                        stat_indic <= X"7";
                        statState <= statWait;
                  end case;
                  if((sum_in_ch = "01") AND (stat_CE = '1')) then stat_ctr_p3 <= stat_ctr_p3 + 1; end if;
                  if((sum_in_ch = "00") AND (stat_CE = '1')) then stat_ctr_p1 <= stat_ctr_p1 + 1; end if;
                  if((sum_in_ch = "11") AND (stat_CE = '1')) then stat_ctr_m1 <= stat_ctr_m1 + 1; end if;
                  if((sum_in_ch = "10") AND (stat_CE = '1')) then stat_ctr_m3 <= stat_ctr_m3 + 1; end if;
               end if;  --rising edge of C125
            end if;     --if Grs = 1
      end process;

   end arch;

      
   
