#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

#include "verilated.h"
#include <verilated_vcd_c.h>

#include "VSystem.h"
#include "VSystem_System.h"
#include "VSystem_MasterShell.h"
#include "VSystem_MonoVgaText.h"

#include "IBM_VGA_8x16.h"
#include "vga.h"

using namespace std;

#define FONT_BASE   0xe000
#define SCREEN_BASE 0xf000

uint64_t tickcount = 0;
uint64_t ts = 1000;

VerilatedVcdC *pTrace = NULL;
VSystem *pCore;


void opentrace(const char *vcdname) {
    if (!pTrace) {
        pTrace = new VerilatedVcdC;
        pCore->trace(pTrace, 99);
        pTrace->open(vcdname);
    }
}

void tick() {
    tickcount += ts;
    if ((tickcount % (ts)) == 0) {
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

void handle(VSystem *pCore) {
}

int main(int argc, char *argv[]) {
    // atexit(exit_callback);
    // signal(SIGINT, sig_handler);
    Verilated::traceEverOn(true);
    pCore = new VSystem();

    if (argc > 1) {
        if( string(argv[1]) == "-t" ) {
            printf("Trace enabled\n");
            opentrace("trace.vcd");
        }
    }

    vga_init(
        pCore->System->master->vga0->HSIZE,
        pCore->System->master->vga0->HFP,
        pCore->System->master->vga0->HSYNC,
        pCore->System->master->vga0->HBP,
        pCore->System->master->vga0->VSIZE,
        pCore->System->master->vga0->VFP,
        pCore->System->master->vga0->VSYNC,
        pCore->System->master->vga0->VBP
    );

    reset();

    // pCore->System->master->vga0->__PVT__r_font_base = FONT_BASE >> 12;
    // pCore->System->master->vga0->__PVT__r_screen_base = SCREEN_BASE >> 12;

    int old_clk;
    while(1) {
        handle(pCore);
        tick();

        if (pCore->System->i_clk != old_clk) {
            if (pCore->System->i_clk) {
                int ret = vga_handle(pCore->o_pixel&1, !pCore->o_hsync, !pCore->o_vsync);
                if (ret == -1) {
                    printf("Exiting due to event\n");
                    break;
                }
            }
        }
        old_clk = pCore->System->i_clk;
        if (pTrace && (tickcount > 100000 * ts)) {
            printf("Time is up\n");
            break;
        }
    }

    vga_close();

    pCore->final();
    delete pCore;

    if (pTrace) {
        pTrace->close();
        delete pTrace;
    }
    return 0;
}