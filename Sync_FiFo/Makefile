# Makefile for running the sync FIFO testbench in PowerShell

.PHONY: all clean build sim wave

all: clean build sim wave

clean:
	powershell -NoProfile -Command "Remove-Item -Path .\\*.vcd, .\\*.vvp -Force -ErrorAction SilentlyContinue"

build:
	powershell -NoProfile -Command "iverilog -o sync_fifo.vvp *.sv"

sim:
	powershell -NoProfile -Command "vvp .\sync_fifo.vvp"

wave:
	powershell -NoProfile -Command "gtkwave.exe .\tb_sync_fifo.vcd"
