`default_nettype none

module cpu_async(
    input             i_clk,
    input             i_reset,
    output reg [15:0] o_addr,
    input       [7:0] i_dat,
    output      [7:0] o_dat,
    output            o_we,
    input             i_int,
    input             i_nmi,
    input             i_ack,
    input             i_active
);

wire rdy = i_active && ~i_ack; // TODO: Falsch!

wire [15:0] ad;
always @(posedge i_clk)
    if (rdy)
        o_addr <= ad;

cpu cpu0( 
    .clk(i_clk),    // CPU clock
    .RST(i_reset),  // RST signal
    .AD(ad),        // address bus (combinatorial)
    .sync(),        // start of new instruction
    .DI(i_dat),     // data bus input
    .DO(o_dat),     // data bus output 
    .WE(o_we),      // write enable
    .IRQ(i_int),    // interrupt request
    .NMI(i_nmi),    // non-maskable interrupt request
    .RDY(rdy),      // Ready signal. Pauses CPU when RDY=0
    .debug(1'b0)    // debug for simulation
);

endmodule