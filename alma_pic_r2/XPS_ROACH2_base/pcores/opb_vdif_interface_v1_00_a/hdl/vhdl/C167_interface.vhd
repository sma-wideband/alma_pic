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
       uclk     			: in std_logic; 											-- processor clock		   
		   read_write   	: in std_logic; 											-- read and write selection, read_write='1' => read, '0' => write
		   ctrl_data			: in std_logic; 											-- control data selector, ctr_data='1' => control, '0' => data 		   
		   c167_data_I		: in std_logic_vector (7 downto 0);		-- bus connection with the c167, bidirectional		   
		   c167_data_O		: out std_logic_vector (7 downto 0); 	-- bus connection with the c167, bidirectional
		   data_from_cpu	: out std_logic_vector (7 downto 0);	-- data_from_CPU, must be used together with C167_WR_EN(X) being 0<=X<=31		   
		   data_to_cpu		: in std_logic_vector (7 downto 0);		-- data_to_CPU, must be used together with C167_RR_EN(X) being 0<=X<=31		   
	     C167_WE          : out std_logic;                    -- new write enable signal
	     C167_ADDR        : out std_logic_vector(7 downto 0); -- new address bus	   
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



data_to_CPU_transfer: process(C167_clk_sig,read_write) is				-- process for loading data into the local bus.
begin
	if C167_clk_sig='0' and read_write='1' then
		c167_data_O <= data_to_cpu;
	else 
		c167_data_O <= "00000000";													-- prevent over-drive the c167 bus.
	end if;	
end process data_to_CPU_transfer; 

data_from_cpu <= c167_data_I;

--new bus signals
C167_ADDR <= ctrl_reg;
C167_WE   <= read_write OR ctrl_data; --WE can only go low when ctrl_data is low


end comportamental;
