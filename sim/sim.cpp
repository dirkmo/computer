#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

#include "verilated.h"
#include "verilator/Vtop.h"

using namespace std;

#define FONT_BASE   0x0000
#define SCREEN_BASE 0x1000


VerilatedVcdC *pTrace = NULL;
Vtop *pCore;

// note: little endian: lsb first
uint8_t mem[0x10000]; 

void tick() {
    tickcount += ts;
    if ((tickcount % (ts*2)) == 0) {
        pCore->i_clk = !pCore->i_clk;
    }
    pCore->eval();
    if(pTrace) pTrace->dump(static_cast<vluint64_t>(tickcount));
}

void reset() {
    pCore->i_reset = 1;
    for ( int i = 0; i < 10; i++) {
        tick();
    }
    pCore->i_reset = 0;
}

void initialize_mem(void) {
    // nmi
    mem[0xfffa] = 0x00;
    mem[0xfffb] = 0x00;
    // reset
    mem[0xfffc] = 0x00;
    mem[0xfffd] = 0x00;
    // irq/brk
    mem[0xfffe] = 0x00;
    mem[0xffff] = 0x00;

    memset(mem, 0, sizeof(mem));
    memcpy(&mem[FONT_BASE], &IBM_VGA_8x16[0], sizeof(IBM_VGA_8x16));
    strcpy((char*)&mem[SCREEN_BASE], "Hello, World!");
}

void handle(Vtop *pCore) {
    if (pCore->o_ram_cs) {
        if (pCore->o_ram_we) {
            mem[pCore->o_ram_addr16] = pCore->o_ram_dat16 & 0xff;
        }
    }
    pCore->i_ram_dat16 = mem[pCore->o_ram_addr16];
}

int main(int argc, char *argv[]) {
    atexit(exit_callback);
    // signal(SIGINT, sig_handler);
    Verilated::traceEverOn(true);
    pCore = new Vtop();
    opentrace("trace.vcd");
    if (pTrace) {
        pTrace->close();
        delete pTrace;
    }
    return 0;
}