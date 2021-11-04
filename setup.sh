#!/bin/bash

mkdir -p import/vga import/uart import/cpu

wget -c -P import/uart https://raw.githubusercontent.com/dirkmo/uartmaster/main/rtl/uart_rx.v
wget -c -P import/uart https://raw.githubusercontent.com/dirkmo/uartmaster/main/rtl/uart_tx.v
wget -c -P import/uart https://raw.githubusercontent.com/dirkmo/uartmaster/main/rtl/UartMasterSlave.v
wget -c -P import/uart https://raw.githubusercontent.com/dirkmo/uartmaster/main/rtl/fifo.v
wget -c -P import/uart https://raw.githubusercontent.com/dirkmo/uartmaster/main/rtl/UartProtocol.v

wget -c -P import/vga https://raw.githubusercontent.com/dirkmo/monovgatext/main/rtl/MonoVgaText.v
wget -c -P import/vga https://raw.githubusercontent.com/dirkmo/monovgatext/main/sim/IBM_VGA_8x16.c
wget -c -P import/vga https://raw.githubusercontent.com/dirkmo/monovgatext/main/sim/IBM_VGA_8x16.h


FILES=(regfile.v abh.v microcode.hex ctl.v abl.v cpu.v alu.v microcode.v)
for f in ${FILES[*]}
do
    wget -c -P import/cpu https://raw.githubusercontent.com/Arlet/verilog-65C02/main/generic/$f
    gsed -i '1i /* verilator lint_off PINMISSING */\n/* verilator lint_off WIDTH */\n/* verilator lint_off CASEOVERLAP */\n/* verilator lint_off CASEINCOMPLETE */' import/cpu/$f
done
