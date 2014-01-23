MODULE=opb_vdif_interface

VCC=ghdl
VSIM=ghdl
VWAVE=gtkwave
TB_DIR=./hdl
SRC_DIR=../hdl/vhdl
TB_OBJ=tb_$(MODULE)
VCD=tb_$(MODULE).vcd

all: build run

build: import make

import: unisim-obj93.cf xilinxcorelib-obj93.cf work-obj93.cf

unisim-obj93.cf: 
	$(VCC) -i --work=unisim $(XILINX)/vhdl/src/unisims/*.vhd
	$(VCC) -i --work=unisim $(XILINX)/vhdl/src/unisims/primitive/*.vhd

xilinxcorelib-obj93.cf:
	$(VCC) -i --work=xilinxcorelib $(XILINX)/vhdl/src/XilinxCoreLib/*.vhd

work-obj93.cf:
	$(VCC) -i --work=work $(SRC_DIR)/*.vhd
	$(VCC) -i --work=work $(TB_DIR)/*.vhd

make: $(TB_OBJ)

$(TB_OBJ): 
	$(VCC) -m -g -Punisim  -Pxilinxcorelib --warn-unused --ieee=synopsys -fexplicit $@

run: $(VCD)

$(VCD):
	$(VSIM) -r $(TB_OBJ) --vcd=$(VCD)

wave:
	$(VWAVE) $(VCD)

clean:
	rm -rf *.cf *.o $(TB_OBJ) $(VCD)
