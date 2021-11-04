#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

#include "verilated.h"
#include <verilated_vcd_c.h>

#include "VMasterShell.h"
#include "IBM_VGA_8x16.h"

using namespace std;

#define FONT_BASE   0x0000
#define SCREEN_BASE 0x1000

uint64_t tickcount = 0;
uint64_t ts = 1000;

VerilatedVcdC *pTrace = NULL;
VMasterShell *pCore;

// note: little endian: lsb first
uint8_t mem[0x10000]; 

void opentrace(const char *vcdname) {
    if (!pTrace) {
        pTrace = new VerilatedVcdC;
        pCore->trace(pTrace, 99);
        pTrace->open(vcdname);
    }
}

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

void handle(VMasterShell *pCore) {
    if (pCore->o_cs) {
        if (pCore->o_we) {
            mem[pCore->o_addr] = pCore->o_dat & 0xff;
        }
    }
    pCore->i_dat = mem[pCore->o_addr];
}

int main(int argc, char *argv[]) {
    // atexit(exit_callback);
    // signal(SIGINT, sig_handler);
    Verilated::traceEverOn(true);
    pCore = new VMasterShell();

    if (argc > 1) {
        if( string(argv[1]) == "-t" ) {
            printf("Trace enabled\n");
            opentrace("trace.vcd");
        }
    }

    reset();

    while(tickcount < 100000 * ts) {
        handle(pCore);
        tick();
    }

    pCore->final();
    delete pCore;

    if (pTrace) {
        pTrace->close();
        delete pTrace;
    }
    return 0;
}