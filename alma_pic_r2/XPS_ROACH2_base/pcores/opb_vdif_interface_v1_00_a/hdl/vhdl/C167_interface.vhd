-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use ieee.std_logic_arith.all;

-------------------------------------------------------
-- This component is used to  interact with the C167 processor.
-- $Id: C167_interface.vhd,v 1.5 2013/05/16 16:58:35 asaez Exp $
-- $Id: $
entity c167_interface is
	port(

		   uclk     				: in std_logic; 											-- processor clock		   
		   read_write     		: in std_logic; 											-- read and write selection, read_write='1' => read, '0' => write
		   ctrl_data				: in std_logic; 											-- control data selector, ctr_data='1' => control, '0' => data 		   
		   c167_data_I		: in std_logic_vector (7 downto 0); 			-- bus connection with the c167, bidirectional		   
		   c167_data_O		: out std_logic_vector (7 downto 0); 			-- bus connection with the c167, bidirectional
		   data_from_cpu			: out std_logic_vector (7 downto 0);				-- data_from_CPU, must be used together with C167_WR_EN(X) being 0<=X<=31		   
		   data_to_cpu				: in std_logic_vector (7 downto 0);					-- data_to_CPU, must be used together with C167_RR_EN(X) being 0<=X<=31		   
		   C167_RD_EN				: out std_logic_vector (31 downto 0);				-- Read enable signals, they must be individually connected to the tri-state controller associated to the desired signals
		   
		   C167_WR_EN				: out std_logic_vector (31 downto 0);				-- Write enable signals, they must be individually connected to the "clock enable" associated to the addressed register.
		   
		   C167_CLK					: out std_logic											-- C167 clock signal, the first 4 clocks were removed.
		   
	);
end c167_interface;

architecture comportamental of C167_interface is

component bufg
	port(
	i : in std_logic;
	o : out std_logic
	);
end component;

signal ctrl_reg : std_logic_vector(7 downto 0);											-- target select register
signal C167_clk_sig_pre: std_logic;
signal C167_clk_sig: std_logic;
signal counter: std_logic_vector(2 downto 0) := "000"; 									-- This counter is use for inhibiting the clock signal during the 4 first clock edges.
signal counter_enable : std_logic := '0';

begin

bufg_0 : bufg            --NOTE: probably want this bufg because it drives the clock to all registers; it does not want to simulate; comment out for simulation
	port map(
	i => C167_clk_sig_pre,
	o => C167_clk_sig
	);
	
--set up clocking; change when done with simulation to use bufg above
  C167_clk_sig_pre <= uclk;
--  C167_clk_sig     <= C167_clk_sig_pre;      ***remove comment for simulation
  C167_CLK <= C167_clk_sig;  


load_target_select_register: process(C167_clk_sig,ctrl_data) is				-- process for loading the control register
begin
if ctrl_data = '1' then
	if rising_edge(C167_clk_sig) then
		ctrl_reg <= c167_data_I;
	end if;
end if;	
end process load_target_select_register;

update_rd_wr_registers: process(ctrl_data,read_write,ctrl_reg) is						-- process for setting/clear the read and write enable signal
begin
if ctrl_data='0' and read_write='0' then
	case ctrl_reg(4 downto 0) is
		when "00000"  => C167_WR_EN <= X"0000_0001";
		when "00001"  => C167_WR_EN <= X"0000_0002";
		when "00010"  => C167_WR_EN <= X"0000_0004";
		when "00011"  => C167_WR_EN <= X"0000_0008";		
		when "00100"  => C167_WR_EN <= X"0000_0010";
		when "00101"  => C167_WR_EN <= X"0000_0020";
		when "00110"  => C167_WR_EN <= X"0000_0040";
		when "00111"  => C167_WR_EN <= X"0000_0080";				
		when "01000"  => C167_WR_EN <= X"0000_0100";
		when "01001"  => C167_WR_EN <= X"0000_0200";
		when "01010"  => C167_WR_EN <= X"0000_0400";
		when "01011"  => C167_WR_EN <= X"0000_0800";		
		when "01100"  => C167_WR_EN <= X"0000_1000";
		when "01101"  => C167_WR_EN <= X"0000_2000";
		when "01110"  => C167_WR_EN <= X"0000_4000";
		when "01111"  => C167_WR_EN <= X"0000_8000";						
		when "10000"  => C167_WR_EN <= X"0001_0000";
		when "10001"  => C167_WR_EN <= X"0002_0000";
		when "10010"  => C167_WR_EN <= X"0004_0000";
		when "10011"  => C167_WR_EN <= X"0008_0000";		
		when "10100"  => C167_WR_EN <= X"0010_0000";
		when "10101"  => C167_WR_EN <= X"0020_0000";
		when "10110"  => C167_WR_EN <= X"0040_0000";
		when "10111"  => C167_WR_EN <= X"0080_0000";				
		when "11000"  => C167_WR_EN <= X"0100_0000";
		when "11001"  => C167_WR_EN <= X"0200_0000";
		when "11010"  => C167_WR_EN <= X"0400_0000";
		when "11011"  => C167_WR_EN <= X"0800_0000";		
		when "11100"  => C167_WR_EN <= X"1000_0000";
		when "11101"  => C167_WR_EN <= X"2000_0000";
		when "11110"  => C167_WR_EN <= X"4000_0000";
		when "11111"  => C167_WR_EN <= X"8000_0000";	
		when others   => C167_WR_EN <= X"0000_0000";						
	end case;
elsif ctrl_data='0' and read_write='1' then	
   C167_WR_EN <= X"0000_0000";	
	case ctrl_reg(4 downto 0) is
		when "00000"  => C167_RD_EN <= X"0000_0001";
		when "00001"  => C167_RD_EN <= X"0000_0002";
		when "00010"  => C167_RD_EN <= X"0000_0004";
		when "00011"  => C167_RD_EN <= X"0000_0008";		
		when "00100"  => C167_RD_EN <= X"0000_0010";
		when "00101"  => C167_RD_EN <= X"0000_0020";
		when "00110"  => C167_RD_EN <= X"0000_0040";
		when "00111"  => C167_RD_EN <= X"0000_0080";				
		when "01000"  => C167_RD_EN <= X"0000_0100";
		when "01001"  => C167_RD_EN <= X"0000_0200";
		when "01010"  => C167_RD_EN <= X"0000_0400";
		when "01011"  => C167_RD_EN <= X"0000_0800";		
		when "01100"  => C167_RD_EN <= X"0000_1000";
		when "01101"  => C167_RD_EN <= X"0000_2000";
		when "01110"  => C167_RD_EN <= X"0000_4000";
		when "01111"  => C167_RD_EN <= X"0000_8000";						
		when "10000"  => C167_RD_EN <= X"0001_0000";
		when "10001"  => C167_RD_EN <= X"0002_0000";
		when "10010"  => C167_RD_EN <= X"0004_0000";
		when "10011"  => C167_RD_EN <= X"0008_0000";		
		when "10100"  => C167_RD_EN <= X"0010_0000";
		when "10101"  => C167_RD_EN <= X"0020_0000";
		when "10110"  => C167_RD_EN <= X"0040_0000";
		when "10111"  => C167_RD_EN <= X"0080_0000";				
		when "11000"  => C167_RD_EN <= X"0100_0000";
		when "11001"  => C167_RD_EN <= X"0200_0000";
		when "11010"  => C167_RD_EN <= X"0400_0000";
		when "11011"  => C167_RD_EN <= X"0800_0000";		
		when "11100"  => C167_RD_EN <= X"1000_0000";
		when "11101"  => C167_RD_EN <= X"2000_0000";
		when "11110"  => C167_RD_EN <= X"4000_0000";
		when "11111"  => C167_RD_EN <= X"8000_0000";	
		when others   => C167_RD_EN <= X"0000_0000";	
	end case;	
else
   C167_WR_EN <= X"0000_0000";									-- if no read or write are being happening, none of the write enable signals will be set.
	
end if;
end process update_rd_wr_registers;

data_to_CPU_transfer: process(C167_clk_sig,read_write) is				-- process for loading data into the local bus.
begin
	if C167_clk_sig='0' and read_write='1' then
		c167_data_O <= data_to_cpu;
	else 
		c167_data_O <= "00000000";													-- prevent over-drive the c167 bus.
	end if;	
end process data_to_CPU_transfer; 

data_from_cpu <= c167_data_I;

end comportamental;
