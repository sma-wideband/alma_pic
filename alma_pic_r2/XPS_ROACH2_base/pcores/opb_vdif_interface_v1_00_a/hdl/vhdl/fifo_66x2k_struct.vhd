--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.49d
--  \   \         Application: netgen
--  /   /         Filename: fifo_66x2k_struct.vhd
-- /___/   /\     Timestamp: Wed Mar 19 15:08:47 2014
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /export/rlacasse/projects/data_formatter/fifo_66x2k_struct/tmp/_cg/fifo_66x2k_struct.ngc /export/rlacasse/projects/data_formatter/fifo_66x2k_struct/tmp/_cg/fifo_66x2k_struct.vhd 
-- Device	: 6vsx475tff1759-1
-- Input file	: /export/rlacasse/projects/data_formatter/fifo_66x2k_struct/tmp/_cg/fifo_66x2k_struct.ngc
-- Output file	: /export/rlacasse/projects/data_formatter/fifo_66x2k_struct/tmp/_cg/fifo_66x2k_struct.vhd
-- # of Entities	: 2
-- Design Name	: fifo_66x2k_struct
-- Xilinx	: /export/builds/Xilinx/14.4/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity reset_builtin is
  port (
    CLK : in STD_LOGIC := 'X'; 
    WR_CLK : in STD_LOGIC := 'X'; 
    RD_CLK : in STD_LOGIC := 'X'; 
    INT_CLK : in STD_LOGIC := 'X'; 
    RST : in STD_LOGIC := 'X'; 
    WR_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
    RD_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
    INT_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ) 
  );
end reset_builtin;

architecture STRUCTURE of reset_builtin is
  signal wr_rst_reg_3 : STD_LOGIC; 
  signal rd_rst_reg_15 : STD_LOGIC; 
  signal wr_rst_reg_GND_25_o_MUX_1_o : STD_LOGIC; 
  signal rd_rst_reg_GND_25_o_MUX_2_o : STD_LOGIC; 
  signal wr_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal power_on_wr_rst : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal rd_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal power_on_rd_rst : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal NlwRenamedSignal_WR_RST_I : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal NlwRenamedSig_OI_n0019 : STD_LOGIC_VECTOR ( 5 downto 5 ); 
begin
  WR_RST_I(1) <= NlwRenamedSignal_WR_RST_I(0);
  WR_RST_I(0) <= NlwRenamedSignal_WR_RST_I(0);
  INT_RST_I(1) <= NlwRenamedSig_OI_n0019(5);
  INT_RST_I(0) <= NlwRenamedSig_OI_n0019(5);
  XST_GND : GND
    port map (
      G => NlwRenamedSig_OI_n0019(5)
    );
  wr_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(1),
      Q => wr_rst_fb(0)
    );
  wr_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(2),
      Q => wr_rst_fb(1)
    );
  wr_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(3),
      Q => wr_rst_fb(2)
    );
  wr_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(4),
      Q => wr_rst_fb(3)
    );
  wr_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_reg_3,
      Q => wr_rst_fb(4)
    );
  power_on_wr_rst_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(1),
      Q => power_on_wr_rst(0)
    );
  power_on_wr_rst_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(2),
      Q => power_on_wr_rst(1)
    );
  power_on_wr_rst_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(3),
      Q => power_on_wr_rst(2)
    );
  power_on_wr_rst_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(4),
      Q => power_on_wr_rst(3)
    );
  power_on_wr_rst_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(5),
      Q => power_on_wr_rst(4)
    );
  power_on_wr_rst_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => NlwRenamedSig_OI_n0019(5),
      Q => power_on_wr_rst(5)
    );
  rd_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(1),
      Q => rd_rst_fb(0)
    );
  rd_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(2),
      Q => rd_rst_fb(1)
    );
  rd_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(3),
      Q => rd_rst_fb(2)
    );
  rd_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(4),
      Q => rd_rst_fb(3)
    );
  rd_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_reg_15,
      Q => rd_rst_fb(4)
    );
  power_on_rd_rst_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(1),
      Q => power_on_rd_rst(0)
    );
  power_on_rd_rst_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(2),
      Q => power_on_rd_rst(1)
    );
  power_on_rd_rst_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(3),
      Q => power_on_rd_rst(2)
    );
  power_on_rd_rst_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(4),
      Q => power_on_rd_rst(3)
    );
  power_on_rd_rst_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(5),
      Q => power_on_rd_rst(4)
    );
  power_on_rd_rst_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => NlwRenamedSig_OI_n0019(5),
      Q => power_on_rd_rst(5)
    );
  wr_rst_reg : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_reg_GND_25_o_MUX_1_o,
      PRE => RST,
      Q => wr_rst_reg_3
    );
  rd_rst_reg : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_reg_GND_25_o_MUX_2_o,
      PRE => RST,
      Q => rd_rst_reg_15
    );
  WR_RST_I_1_1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => wr_rst_reg_3,
      I1 => power_on_wr_rst(0),
      O => NlwRenamedSignal_WR_RST_I(0)
    );
  Mmux_wr_rst_reg_GND_25_o_MUX_1_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => wr_rst_fb(0),
      I1 => wr_rst_reg_3,
      O => wr_rst_reg_GND_25_o_MUX_1_o
    );
  Mmux_rd_rst_reg_GND_25_o_MUX_2_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => rd_rst_fb(0),
      I1 => rd_rst_reg_15,
      O => rd_rst_reg_GND_25_o_MUX_2_o
    );

end STRUCTURE;

-- synthesis translate_on

-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity fifo_66x2k_struct is
  port (
    rst : in STD_LOGIC := 'X'; 
    wr_clk : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    rd_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    overflow : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    valid : out STD_LOGIC; 
    prog_empty : out STD_LOGIC; 
    din : in STD_LOGIC_VECTOR ( 65 downto 0 ); 
    dout : out STD_LOGIC_VECTOR ( 65 downto 0 ) 
  );
end fifo_66x2k_struct;

architecture STRUCTURE of fifo_66x2k_struct is
  component reset_builtin
    port (
      CLK : in STD_LOGIC := 'X'; 
      WR_CLK : in STD_LOGIC := 'X'; 
      RD_CLK : in STD_LOGIC := 'X'; 
      INT_CLK : in STD_LOGIC := 'X'; 
      RST : in STD_LOGIC := 'X'; 
      WR_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
      RD_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
      INT_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ) 
    );
  end component;
  signal N1 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_OVERFLOW_35 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_overflow_i : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_wr_ack_i : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe : STD_LOGIC_VECTOR ( 4 downto 1 ); 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp : STD_LOGIC_VECTOR ( 4 downto 1 ); 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful : STD_LOGIC_VECTOR ( 4 downto 1 ); 
begin
  overflow <= U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_OVERFLOW_35;
  XST_GND : GND
    port map (
      G => N1
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt : reset_builtin
    port map (
      CLK => N1,
      WR_CLK => wr_clk,
      RD_CLK => rd_clk,
      INT_CLK => N1,
      RST => rst,
      WR_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED,
      WR_RST_I(0) => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RD_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED,
      RD_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_0_UNCONNECTED,
      INT_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED,
      INT_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1 : FIFO36E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"03E7",
      ALMOST_FULL_OFFSET => X"0009",
      DATA_WIDTH => 18,
      DO_REG => 1,
      EN_ECC_READ => FALSE,
      EN_ECC_WRITE => FALSE,
      EN_SYN => FALSE,
      FIFO_MODE => "FIFO36",
      FIRST_WORD_FALL_THROUGH => TRUE,
      INIT => X"000000000000000000",
      SIM_DEVICE => "VIRTEX6",
      SRVAL => X"000000000000000000"
    )
    port map (
      ALMOSTEMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(4),
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED
,
      DBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(4),
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(4),
      INJECTDBITERR => N1,
      INJECTSBITERR => N1,
      RDCLK => rd_clk,
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp,
      RDERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED,
      REGCE => N1,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RSTREG => N1,
      SBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED,
      WRCLK => wr_clk,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_wr_ack_i,
      WRERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED,
      DI(63) => N1,
      DI(62) => N1,
      DI(61) => N1,
      DI(60) => N1,
      DI(59) => N1,
      DI(58) => N1,
      DI(57) => N1,
      DI(56) => N1,
      DI(55) => N1,
      DI(54) => N1,
      DI(53) => N1,
      DI(52) => N1,
      DI(51) => N1,
      DI(50) => N1,
      DI(49) => N1,
      DI(48) => N1,
      DI(47) => N1,
      DI(46) => N1,
      DI(45) => N1,
      DI(44) => N1,
      DI(43) => N1,
      DI(42) => N1,
      DI(41) => N1,
      DI(40) => N1,
      DI(39) => N1,
      DI(38) => N1,
      DI(37) => N1,
      DI(36) => N1,
      DI(35) => N1,
      DI(34) => N1,
      DI(33) => N1,
      DI(32) => N1,
      DI(31) => N1,
      DI(30) => N1,
      DI(29) => N1,
      DI(28) => N1,
      DI(27) => N1,
      DI(26) => N1,
      DI(25) => N1,
      DI(24) => N1,
      DI(23) => N1,
      DI(22) => N1,
      DI(21) => N1,
      DI(20) => N1,
      DI(19) => N1,
      DI(18) => N1,
      DI(17) => N1,
      DI(16) => N1,
      DI(15) => N1,
      DI(14) => N1,
      DI(13) => N1,
      DI(12) => N1,
      DI(11) => din(65),
      DI(10) => din(64),
      DI(9) => din(63),
      DI(8) => din(62),
      DI(7) => din(61),
      DI(6) => din(60),
      DI(5) => din(59),
      DI(4) => din(58),
      DI(3) => din(57),
      DI(2) => din(56),
      DI(1) => din(55),
      DI(0) => din(54),
      DIP(7) => N1,
      DIP(6) => N1,
      DIP(5) => N1,
      DIP(4) => N1,
      DIP(3) => N1,
      DIP(2) => N1,
      DIP(1) => N1,
      DIP(0) => N1,
      DO(63) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED,
      DO(62) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED,
      DO(61) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED,
      DO(60) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED,
      DO(59) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED,
      DO(58) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED,
      DO(57) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED,
      DO(56) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED,
      DO(55) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED,
      DO(54) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED,
      DO(53) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED,
      DO(52) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED,
      DO(51) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED,
      DO(50) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED,
      DO(49) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED,
      DO(48) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED,
      DO(47) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED,
      DO(46) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED,
      DO(45) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED,
      DO(44) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED,
      DO(43) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED,
      DO(42) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED,
      DO(41) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED,
      DO(40) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED,
      DO(39) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED,
      DO(38) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED,
      DO(37) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED,
      DO(36) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED,
      DO(35) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED,
      DO(34) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED,
      DO(33) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED,
      DO(32) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED,
      DO(31) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED,
      DO(30) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED,
      DO(29) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED,
      DO(28) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED,
      DO(27) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED,
      DO(26) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED,
      DO(25) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED,
      DO(24) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED,
      DO(23) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED,
      DO(22) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED,
      DO(21) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED,
      DO(20) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED,
      DO(19) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED,
      DO(18) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED,
      DO(17) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED,
      DO(16) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED,
      DO(15) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_15_UNCONNECTED,
      DO(14) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_14_UNCONNECTED,
      DO(13) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_13_UNCONNECTED,
      DO(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_12_UNCONNECTED,
      DO(11) => dout(65),
      DO(10) => dout(64),
      DO(9) => dout(63),
      DO(8) => dout(62),
      DO(7) => dout(61),
      DO(6) => dout(60),
      DO(5) => dout(59),
      DO(4) => dout(58),
      DO(3) => dout(57),
      DO(2) => dout(56),
      DO(1) => dout(55),
      DO(0) => dout(54),
      DOP(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED,
      DOP(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED,
      DOP(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED,
      DOP(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED,
      DOP(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED,
      DOP(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED,
      DOP(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_1_UNCONNECTED,
      DOP(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_0_UNCONNECTED,
      ECCPARITY(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED
,
      ECCPARITY(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED
,
      ECCPARITY(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED
,
      ECCPARITY(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED
,
      ECCPARITY(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED
,
      ECCPARITY(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED
,
      ECCPARITY(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED
,
      ECCPARITY(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED
,
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED
,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED
,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED
,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED
,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED
,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED
,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED
,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED
,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED
,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED
,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED
,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED
,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED
,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED
,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED
,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED
,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED
,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED
,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED
,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED
,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED
,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED
,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED
,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED
,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED
,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_4_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1 : FIFO36E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"03E7",
      ALMOST_FULL_OFFSET => X"0009",
      DATA_WIDTH => 18,
      DO_REG => 1,
      EN_ECC_READ => FALSE,
      EN_ECC_WRITE => FALSE,
      EN_SYN => FALSE,
      FIFO_MODE => "FIFO36",
      FIRST_WORD_FALL_THROUGH => TRUE,
      INIT => X"000000000000000000",
      SIM_DEVICE => "VIRTEX6",
      SRVAL => X"000000000000000000"
    )
    port map (
      ALMOSTEMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(3),
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED
,
      DBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(3),
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(3),
      INJECTDBITERR => N1,
      INJECTSBITERR => N1,
      RDCLK => rd_clk,
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp,
      RDERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED,
      REGCE => N1,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RSTREG => N1,
      SBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED,
      WRCLK => wr_clk,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_wr_ack_i,
      WRERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED,
      DI(63) => N1,
      DI(62) => N1,
      DI(61) => N1,
      DI(60) => N1,
      DI(59) => N1,
      DI(58) => N1,
      DI(57) => N1,
      DI(56) => N1,
      DI(55) => N1,
      DI(54) => N1,
      DI(53) => N1,
      DI(52) => N1,
      DI(51) => N1,
      DI(50) => N1,
      DI(49) => N1,
      DI(48) => N1,
      DI(47) => N1,
      DI(46) => N1,
      DI(45) => N1,
      DI(44) => N1,
      DI(43) => N1,
      DI(42) => N1,
      DI(41) => N1,
      DI(40) => N1,
      DI(39) => N1,
      DI(38) => N1,
      DI(37) => N1,
      DI(36) => N1,
      DI(35) => N1,
      DI(34) => N1,
      DI(33) => N1,
      DI(32) => N1,
      DI(31) => N1,
      DI(30) => N1,
      DI(29) => N1,
      DI(28) => N1,
      DI(27) => N1,
      DI(26) => N1,
      DI(25) => N1,
      DI(24) => N1,
      DI(23) => N1,
      DI(22) => N1,
      DI(21) => N1,
      DI(20) => N1,
      DI(19) => N1,
      DI(18) => N1,
      DI(17) => N1,
      DI(16) => N1,
      DI(15) => din(51),
      DI(14) => din(50),
      DI(13) => din(49),
      DI(12) => din(48),
      DI(11) => din(47),
      DI(10) => din(46),
      DI(9) => din(45),
      DI(8) => din(44),
      DI(7) => din(43),
      DI(6) => din(42),
      DI(5) => din(41),
      DI(4) => din(40),
      DI(3) => din(39),
      DI(2) => din(38),
      DI(1) => din(37),
      DI(0) => din(36),
      DIP(7) => N1,
      DIP(6) => N1,
      DIP(5) => N1,
      DIP(4) => N1,
      DIP(3) => N1,
      DIP(2) => N1,
      DIP(1) => din(53),
      DIP(0) => din(52),
      DO(63) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED,
      DO(62) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED,
      DO(61) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED,
      DO(60) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED,
      DO(59) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED,
      DO(58) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED,
      DO(57) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED,
      DO(56) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED,
      DO(55) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED,
      DO(54) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED,
      DO(53) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED,
      DO(52) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED,
      DO(51) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED,
      DO(50) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED,
      DO(49) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED,
      DO(48) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED,
      DO(47) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED,
      DO(46) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED,
      DO(45) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED,
      DO(44) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED,
      DO(43) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED,
      DO(42) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED,
      DO(41) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED,
      DO(40) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED,
      DO(39) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED,
      DO(38) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED,
      DO(37) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED,
      DO(36) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED,
      DO(35) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED,
      DO(34) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED,
      DO(33) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED,
      DO(32) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED,
      DO(31) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED,
      DO(30) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED,
      DO(29) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED,
      DO(28) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED,
      DO(27) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED,
      DO(26) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED,
      DO(25) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED,
      DO(24) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED,
      DO(23) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED,
      DO(22) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED,
      DO(21) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED,
      DO(20) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED,
      DO(19) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED,
      DO(18) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED,
      DO(17) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED,
      DO(16) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED,
      DO(15) => dout(51),
      DO(14) => dout(50),
      DO(13) => dout(49),
      DO(12) => dout(48),
      DO(11) => dout(47),
      DO(10) => dout(46),
      DO(9) => dout(45),
      DO(8) => dout(44),
      DO(7) => dout(43),
      DO(6) => dout(42),
      DO(5) => dout(41),
      DO(4) => dout(40),
      DO(3) => dout(39),
      DO(2) => dout(38),
      DO(1) => dout(37),
      DO(0) => dout(36),
      DOP(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED,
      DOP(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED,
      DOP(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED,
      DOP(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED,
      DOP(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED,
      DOP(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED,
      DOP(1) => dout(53),
      DOP(0) => dout(52),
      ECCPARITY(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED
,
      ECCPARITY(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED
,
      ECCPARITY(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED
,
      ECCPARITY(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED
,
      ECCPARITY(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED
,
      ECCPARITY(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED
,
      ECCPARITY(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED
,
      ECCPARITY(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED
,
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED
,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED
,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED
,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED
,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED
,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED
,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED
,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED
,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED
,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED
,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED
,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED
,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED
,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED
,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED
,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED
,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED
,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED
,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED
,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED
,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED
,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED
,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED
,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED
,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED
,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_3_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1 : FIFO36E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"03E7",
      ALMOST_FULL_OFFSET => X"0009",
      DATA_WIDTH => 18,
      DO_REG => 1,
      EN_ECC_READ => FALSE,
      EN_ECC_WRITE => FALSE,
      EN_SYN => FALSE,
      FIFO_MODE => "FIFO36",
      FIRST_WORD_FALL_THROUGH => TRUE,
      INIT => X"000000000000000000",
      SIM_DEVICE => "VIRTEX6",
      SRVAL => X"000000000000000000"
    )
    port map (
      ALMOSTEMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(2),
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED
,
      DBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(2),
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(2),
      INJECTDBITERR => N1,
      INJECTSBITERR => N1,
      RDCLK => rd_clk,
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp,
      RDERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED,
      REGCE => N1,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RSTREG => N1,
      SBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED,
      WRCLK => wr_clk,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_wr_ack_i,
      WRERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED,
      DI(63) => N1,
      DI(62) => N1,
      DI(61) => N1,
      DI(60) => N1,
      DI(59) => N1,
      DI(58) => N1,
      DI(57) => N1,
      DI(56) => N1,
      DI(55) => N1,
      DI(54) => N1,
      DI(53) => N1,
      DI(52) => N1,
      DI(51) => N1,
      DI(50) => N1,
      DI(49) => N1,
      DI(48) => N1,
      DI(47) => N1,
      DI(46) => N1,
      DI(45) => N1,
      DI(44) => N1,
      DI(43) => N1,
      DI(42) => N1,
      DI(41) => N1,
      DI(40) => N1,
      DI(39) => N1,
      DI(38) => N1,
      DI(37) => N1,
      DI(36) => N1,
      DI(35) => N1,
      DI(34) => N1,
      DI(33) => N1,
      DI(32) => N1,
      DI(31) => N1,
      DI(30) => N1,
      DI(29) => N1,
      DI(28) => N1,
      DI(27) => N1,
      DI(26) => N1,
      DI(25) => N1,
      DI(24) => N1,
      DI(23) => N1,
      DI(22) => N1,
      DI(21) => N1,
      DI(20) => N1,
      DI(19) => N1,
      DI(18) => N1,
      DI(17) => N1,
      DI(16) => N1,
      DI(15) => din(33),
      DI(14) => din(32),
      DI(13) => din(31),
      DI(12) => din(30),
      DI(11) => din(29),
      DI(10) => din(28),
      DI(9) => din(27),
      DI(8) => din(26),
      DI(7) => din(25),
      DI(6) => din(24),
      DI(5) => din(23),
      DI(4) => din(22),
      DI(3) => din(21),
      DI(2) => din(20),
      DI(1) => din(19),
      DI(0) => din(18),
      DIP(7) => N1,
      DIP(6) => N1,
      DIP(5) => N1,
      DIP(4) => N1,
      DIP(3) => N1,
      DIP(2) => N1,
      DIP(1) => din(35),
      DIP(0) => din(34),
      DO(63) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED,
      DO(62) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED,
      DO(61) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED,
      DO(60) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED,
      DO(59) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED,
      DO(58) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED,
      DO(57) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED,
      DO(56) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED,
      DO(55) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED,
      DO(54) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED,
      DO(53) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED,
      DO(52) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED,
      DO(51) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED,
      DO(50) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED,
      DO(49) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED,
      DO(48) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED,
      DO(47) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED,
      DO(46) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED,
      DO(45) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED,
      DO(44) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED,
      DO(43) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED,
      DO(42) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED,
      DO(41) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED,
      DO(40) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED,
      DO(39) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED,
      DO(38) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED,
      DO(37) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED,
      DO(36) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED,
      DO(35) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED,
      DO(34) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED,
      DO(33) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED,
      DO(32) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED,
      DO(31) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED,
      DO(30) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED,
      DO(29) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED,
      DO(28) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED,
      DO(27) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED,
      DO(26) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED,
      DO(25) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED,
      DO(24) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED,
      DO(23) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED,
      DO(22) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED,
      DO(21) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED,
      DO(20) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED,
      DO(19) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED,
      DO(18) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED,
      DO(17) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED,
      DO(16) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED,
      DO(15) => dout(33),
      DO(14) => dout(32),
      DO(13) => dout(31),
      DO(12) => dout(30),
      DO(11) => dout(29),
      DO(10) => dout(28),
      DO(9) => dout(27),
      DO(8) => dout(26),
      DO(7) => dout(25),
      DO(6) => dout(24),
      DO(5) => dout(23),
      DO(4) => dout(22),
      DO(3) => dout(21),
      DO(2) => dout(20),
      DO(1) => dout(19),
      DO(0) => dout(18),
      DOP(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED,
      DOP(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED,
      DOP(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED,
      DOP(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED,
      DOP(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED,
      DOP(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED,
      DOP(1) => dout(35),
      DOP(0) => dout(34),
      ECCPARITY(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED
,
      ECCPARITY(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED
,
      ECCPARITY(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED
,
      ECCPARITY(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED
,
      ECCPARITY(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED
,
      ECCPARITY(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED
,
      ECCPARITY(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED
,
      ECCPARITY(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED
,
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED
,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED
,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED
,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED
,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED
,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED
,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED
,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED
,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED
,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED
,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED
,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED
,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED
,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED
,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED
,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED
,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED
,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED
,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED
,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED
,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED
,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED
,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED
,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED
,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED
,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_2_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1 : FIFO36E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"03E7",
      ALMOST_FULL_OFFSET => X"0009",
      DATA_WIDTH => 18,
      DO_REG => 1,
      EN_ECC_READ => FALSE,
      EN_ECC_WRITE => FALSE,
      EN_SYN => FALSE,
      FIFO_MODE => "FIFO36",
      FIRST_WORD_FALL_THROUGH => TRUE,
      INIT => X"000000000000000000",
      SIM_DEVICE => "VIRTEX6",
      SRVAL => X"000000000000000000"
    )
    port map (
      ALMOSTEMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(1),
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTFULL_UNCONNECTED
,
      DBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(1),
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(1),
      INJECTDBITERR => N1,
      INJECTSBITERR => N1,
      RDCLK => rd_clk,
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp,
      RDERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED,
      REGCE => N1,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RSTREG => N1,
      SBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED,
      WRCLK => wr_clk,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_wr_ack_i,
      WRERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED,
      DI(63) => N1,
      DI(62) => N1,
      DI(61) => N1,
      DI(60) => N1,
      DI(59) => N1,
      DI(58) => N1,
      DI(57) => N1,
      DI(56) => N1,
      DI(55) => N1,
      DI(54) => N1,
      DI(53) => N1,
      DI(52) => N1,
      DI(51) => N1,
      DI(50) => N1,
      DI(49) => N1,
      DI(48) => N1,
      DI(47) => N1,
      DI(46) => N1,
      DI(45) => N1,
      DI(44) => N1,
      DI(43) => N1,
      DI(42) => N1,
      DI(41) => N1,
      DI(40) => N1,
      DI(39) => N1,
      DI(38) => N1,
      DI(37) => N1,
      DI(36) => N1,
      DI(35) => N1,
      DI(34) => N1,
      DI(33) => N1,
      DI(32) => N1,
      DI(31) => N1,
      DI(30) => N1,
      DI(29) => N1,
      DI(28) => N1,
      DI(27) => N1,
      DI(26) => N1,
      DI(25) => N1,
      DI(24) => N1,
      DI(23) => N1,
      DI(22) => N1,
      DI(21) => N1,
      DI(20) => N1,
      DI(19) => N1,
      DI(18) => N1,
      DI(17) => N1,
      DI(16) => N1,
      DI(15) => din(15),
      DI(14) => din(14),
      DI(13) => din(13),
      DI(12) => din(12),
      DI(11) => din(11),
      DI(10) => din(10),
      DI(9) => din(9),
      DI(8) => din(8),
      DI(7) => din(7),
      DI(6) => din(6),
      DI(5) => din(5),
      DI(4) => din(4),
      DI(3) => din(3),
      DI(2) => din(2),
      DI(1) => din(1),
      DI(0) => din(0),
      DIP(7) => N1,
      DIP(6) => N1,
      DIP(5) => N1,
      DIP(4) => N1,
      DIP(3) => N1,
      DIP(2) => N1,
      DIP(1) => din(17),
      DIP(0) => din(16),
      DO(63) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_63_UNCONNECTED,
      DO(62) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_62_UNCONNECTED,
      DO(61) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_61_UNCONNECTED,
      DO(60) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_60_UNCONNECTED,
      DO(59) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_59_UNCONNECTED,
      DO(58) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_58_UNCONNECTED,
      DO(57) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_57_UNCONNECTED,
      DO(56) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_56_UNCONNECTED,
      DO(55) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_55_UNCONNECTED,
      DO(54) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_54_UNCONNECTED,
      DO(53) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_53_UNCONNECTED,
      DO(52) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_52_UNCONNECTED,
      DO(51) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_51_UNCONNECTED,
      DO(50) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_50_UNCONNECTED,
      DO(49) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_49_UNCONNECTED,
      DO(48) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_48_UNCONNECTED,
      DO(47) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_47_UNCONNECTED,
      DO(46) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_46_UNCONNECTED,
      DO(45) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_45_UNCONNECTED,
      DO(44) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_44_UNCONNECTED,
      DO(43) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_43_UNCONNECTED,
      DO(42) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_42_UNCONNECTED,
      DO(41) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_41_UNCONNECTED,
      DO(40) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_40_UNCONNECTED,
      DO(39) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_39_UNCONNECTED,
      DO(38) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_38_UNCONNECTED,
      DO(37) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_37_UNCONNECTED,
      DO(36) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_36_UNCONNECTED,
      DO(35) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_35_UNCONNECTED,
      DO(34) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_34_UNCONNECTED,
      DO(33) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_33_UNCONNECTED,
      DO(32) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_32_UNCONNECTED,
      DO(31) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_31_UNCONNECTED,
      DO(30) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_30_UNCONNECTED,
      DO(29) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_29_UNCONNECTED,
      DO(28) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_28_UNCONNECTED,
      DO(27) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_27_UNCONNECTED,
      DO(26) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_26_UNCONNECTED,
      DO(25) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_25_UNCONNECTED,
      DO(24) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_24_UNCONNECTED,
      DO(23) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_23_UNCONNECTED,
      DO(22) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_22_UNCONNECTED,
      DO(21) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_21_UNCONNECTED,
      DO(20) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_20_UNCONNECTED,
      DO(19) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_19_UNCONNECTED,
      DO(18) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_18_UNCONNECTED,
      DO(17) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_17_UNCONNECTED,
      DO(16) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DO_16_UNCONNECTED,
      DO(15) => dout(15),
      DO(14) => dout(14),
      DO(13) => dout(13),
      DO(12) => dout(12),
      DO(11) => dout(11),
      DO(10) => dout(10),
      DO(9) => dout(9),
      DO(8) => dout(8),
      DO(7) => dout(7),
      DO(6) => dout(6),
      DO(5) => dout(5),
      DO(4) => dout(4),
      DO(3) => dout(3),
      DO(2) => dout(2),
      DO(1) => dout(1),
      DO(0) => dout(0),
      DOP(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_7_UNCONNECTED,
      DOP(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_6_UNCONNECTED,
      DOP(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_5_UNCONNECTED,
      DOP(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_4_UNCONNECTED,
      DOP(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_3_UNCONNECTED,
      DOP(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DOP_2_UNCONNECTED,
      DOP(1) => dout(17),
      DOP(0) => dout(16),
      ECCPARITY(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED
,
      ECCPARITY(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED
,
      ECCPARITY(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED
,
      ECCPARITY(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED
,
      ECCPARITY(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED
,
      ECCPARITY(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED
,
      ECCPARITY(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED
,
      ECCPARITY(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED
,
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED
,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED
,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED
,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED
,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED
,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED
,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED
,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED
,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED
,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED
,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED
,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED
,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED
,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED
,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED
,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED
,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED
,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED
,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED
,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED
,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED
,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED
,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED
,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED
,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED
,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_OVERFLOW : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => wr_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_overflow_i,
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_OVERFLOW_35
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_wr_ack_i1 : LUT5
    generic map(
      INIT => X"00000002"
    )
    port map (
      I0 => wr_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(2),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(1),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(4),
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(3),
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_wr_ack_i
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_out31 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(4),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(3),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(2),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_pe(1),
      O => prog_empty
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_out11 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(4),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(3),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(2),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(1),
      O => empty
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_out1 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(4),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(3),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(2),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(1),
      O => full
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_overflow_i1 : LUT5
    generic map(
      INIT => X"AAAAAAA8"
    )
    port map (
      I0 => wr_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(4),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(3),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(2),
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_ful(1),
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_overflow_i
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp1 : LUT5
    generic map(
      INIT => X"00000002"
    )
    port map (
      I0 => rd_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(4),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(3),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(2),
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(1),
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_VALID1 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(4),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(3),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(2),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_emp(1),
      O => valid
    );

end STRUCTURE;

-- synthesis translate_on
