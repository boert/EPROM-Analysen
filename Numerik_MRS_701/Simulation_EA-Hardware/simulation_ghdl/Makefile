FILELIST+= ../rtl/DL175D.vhd
FILELIST+= ../rtl/V4028D.vhd
FILELIST+= ../rtl/mrs.vhd
FILELIST+= ../rtl_tb/*.vhd

TOP_TB = mrs_tb

all: run


analyze:
	ghdl -a --std=08 $(FILELIST)

compile: analyze
	ghdl -c --std=08 $(FILELIST)

elaborate: analyze
	ghdl -e --std=08 $(TOP_TB)

run: elaborate
	ghdl -r --std=08 $(TOP_TB) --vcd=wave.vcd


view: wave.vcd
	gtkwave wave.vcd --save=wave.gtkw
