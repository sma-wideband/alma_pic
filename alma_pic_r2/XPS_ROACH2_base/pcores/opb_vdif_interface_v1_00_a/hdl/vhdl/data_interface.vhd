-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_BIT.ALL;
-------------------------------------------------------

-- This entity controls the payload to be added in the VDIF packet

-- # $Id: data_interface.vhd,v 1.6 2014/10/10 18:19:57 rlacasse Exp $

entity data_interface is
port(

   --***Data in and out, clock, general purpose control sigs***--
   --sum data from corr card via PIC buffers
   sum_data   : in std_logic_vector(63 downto 0); --sum data
   
   --clock from PIC
   C125       : in std_logic; --clock from timing generator

   --Grs is the general reset; a one causes various subsystems to go to initial state
   Grs    : in std_logic;

   --Grs_stat is the reset signal just for the statistics
   Grs_stat : in std_logic;

   --***I/O mainly for sum data checker***--
   --which IF channel to test; bit 0 select MS/LS bit for PRN test
   chan     : in std_logic_vector(5 downto 0);

   --how long to measure statistics, in milliseconds, 127 msec max; 
   stat_msec: in std_logic_vector(6 downto 0);

   --low causes PRN checker to stop, to save power
   prn_run  : in std_logic;

   --low causes statistic measurement to stop after the next 1-msec tic
   --rising edge causes a statistics measurement to start at the next 1-msec tic
   stat_start : in std_logic;

   --1-msec tic from timing generator
   OneMsec     : in std_logic;

   --eight-bit PRN error count, available after 1 msec,
   --   saturates at 128 errors
   ecnt        : out std_logic_vector(7 downto 0);
 
  -- "plus 3"statistics count, 24 bits
  stat_p3: out std_logic_vector(23 downto 0);

  -- "plus 1" statistics count, 24 bits
  stat_p1: out std_logic_vector(23 downto 0);

  -- "minus 1" statistics count, 24 bits
  stat_m1: out std_logic_vector(23 downto 0);

  -- "minus 3" statistics count, 24 bits
  stat_m3: out std_logic_vector(23 downto 0);

  -- goes low < 1msec after stat_start goes high; goes high when stats ready
  stat_rdy: out std_logic;

   --***I/O for test_data_gen_***--
   --000 = 64-bit PRN, 001 = counter, 010 = all zeroes, 011 = TBD, 100 = off
   td_sel  : in std_logic_vector(2 downto 0);

   --used to start the counter and PRN in sync with the frame; from timing gen
   frm_sync : in std_logic;

   --output data
   td_out      : out std_logic_vector(63 downto 0);

   ---**I/O for out_data_sel***--
   --a 0 selects normal data (default) and a 1 selects test data from micro_proc
   data_sel   : in std_logic;
   
   --sum data to formatter
   sum_di     : out std_logic_vector(63 downto 0);
   
   -- test points
   ditp0    : out std_logic;
   ditp1    : out std_logic;
   ditp2    : out std_logic  
);
end data_interface;

architecture comportamental of data_interface is

   --signal declarations
   signal sum_data_sig    : std_logic_vector(63 downto 0); --connected to sum_data
   signal sum_data_sig_Z1 : std_logic_vector(63 downto 0); --for registered sum_data
   signal td_sig       : std_logic_vector(63 downto 0); --test data
   signal ditp0_sig    : std_logic;  --test point   
   signal ditp1_sig    : std_logic;  --test point
   signal ditp2_sig    : std_logic;  --test point   
   signal sum_di_nor   : std_logic_vector(63 downto 0);  --sum data (or test data) before permutation

   --component declarations
   component sum_data_chk
      port(
         Grs        : in std_logic; --general reset
         sum_in     : in std_logic_vector(63 downto 0);  --sum data 
         chan       : in std_logic_vector(5 downto 0); --which of 64 inputs to test
         stat_msec  : in std_logic_vector(6 downto 0); --how long to measure stats
         prn_run    : in std_logic;  --1 to have PRN checker running
         stat_start : in std_logic;  --start/stop ctrl for statistics
         OneMsec    : in std_logic;  --1 msec tic
         C125       : in std_logic;  --125 MHz clock
         ecnt       : out std_logic_vector(7 downto 0); --PRN error count
         stat_p3    : out std_logic_vector(23 downto 0); --plus 3 statistics
         stat_p1    : out std_logic_vector(23 downto 0); --plus 1 statistics
         stat_m1    : out std_logic_vector(23 downto 0); --minus 1 statistics
         stat_m3    : out std_logic_vector(23 downto 0); --minus 3 statistics
         stat_rdy   : out std_logic;  -- statistics done indicator
         sdtp0      : out std_logic;  --test point   
         sdtp1      : out std_logic;  --test point
         sdtp2      : out std_logic  --test point
      );
   end component sum_data_chk;

   component test_data_gen
      port	(
   		   C125        : in std_logic; --125 MHz clock from correlator
   		   td_sel  : in std_logic_vector(2 downto 0); --data select
         frm_sync : in std_logic; --used to start the counter and PRN in sync with the frame; from timing gen
         Grs    : in std_logic;--Grs is the general reset
         td_out      : out std_logic_vector(63 downto 0) --output data
   	   );
   end component test_data_gen;   	

   component out_data_sel
      port(
         data_sel: in std_logic;  --0 for normal data and 1 for test data
         sum_in:	 in std_logic_vector(63 downto 0); --normal data from data_interface
         td_in:		 in std_logic_vector(63 downto 0); --test data from test_data_gen
         sum_di:	out std_logic_vector(63 downto 0)  --output data to formatter
      );
   end component out_data_sel;

begin

   --permute the sum or test data to be in the order the recorder wants and send to recorder
   sum_di <= sum_di_nor;
   
   --  Component instantiation.

   sum_data_chk_0: sum_data_chk
   port map(
      Grs        => Grs_stat,
      sum_in     => sum_data_sig_Z1,
      chan       => chan,
      stat_msec  => stat_msec,
      prn_run    => prn_run,
      stat_start => stat_start,
      OneMsec    => OneMsec,
      C125       => C125,
      ecnt       => ecnt,
      stat_p3    => stat_p3,
      stat_p1    => stat_p1,
      stat_m1    => stat_m1,
      stat_m3    => stat_m3,
      stat_rdy   => stat_rdy,
      sdtp0      => ditp0_sig,  
      sdtp1      => ditp1_sig,
      sdtp2      => ditp2_sig
   );

   test_data_gen_0: test_data_gen
   port	map(
   		C125     => C125,
   		td_sel   => td_sel,
      frm_sync => frm_sync,
      Grs      => Grs,
      td_out   => td_sig
   	);

   out_data_sel_0:  out_data_sel
   port map(
     data_sel  => data_sel,
     sum_in 	 => sum_data_sig_Z1,
     td_in		 => td_sig,
     sum_di	   => sum_di_nor
  );
  
   --signal connections
   sum_data_sig <= sum_data; 
   ditp0        <= ditp0_sig;
   ditp1        <= ditp1_sig;
   ditp2        <= ditp2_sig;    


   --processes
   process(C125)  --clock in the data
   begin
      if(rising_edge(C125)) then  
         sum_data_sig_Z1 <= sum_data_sig;
      end if;
   end process;

end comportamental; 
