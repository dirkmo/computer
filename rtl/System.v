module System(
    input        i_clk,
    input        i_reset,

    output       o_hsync,
    output       o_vsync,
    output       o_pixel,

    input        i_uart_rx,
    output       o_uart_tx
);

wire [15:0] master_addr;
wire [ 7:0] master_idat;
wire [ 7:0] master_odat;
wire        master_we;
wire        master_cs;
wire        master_ack;

wire [ 1:0] vgaslave_addr;
wire [ 7:0] vgaslave_idat;
wire [ 7:0] vgaslave_odat;
wire        vgaslave_we;
reg         vgaslave_cs;

wire        uartslave_addr;
wire [ 7:0] uartslave_idat;
wire [ 7:0] uartslave_odat;
wire        uartslave_we;
reg         uartslave_cs;
wire        uart_int;
wire        uart_oreset;

wire        cpu_int = 1'b0;
wire        cpu_nmi = 1'b0;


MasterShell master(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_dat(master_idat),
    .o_dat(master_odat),
    .o_addr(master_addr),
    .o_cs(master_cs),
    .o_we(master_we),
    .i_ack(master_ack),

    .i_vgaslave_dat(vgaslave_idat),
    .o_vgaslave_dat(vgaslave_odat),
    .i_vgaslave_addr(vgaslave_addr),
    .i_vgaslave_cs(vgaslave_cs),
    .i_vgaslave_we(vgaslave_we),
    .o_hsync(o_hsync),
    .o_vsync(o_vsync),
    .o_pixel(o_pixel),

    .i_uartslave_dat(uartslave_idat),
    .o_uartslave_dat(uartslave_odat),
    .i_uartslave_addr(uartslave_addr),
    .o_uartslave_ack(uartslave_addr),
    .i_uartslave_we(uartslave_we),
    .i_uartslave_cs(uartslave_cs),
    .o_uart_int(uart_int),
    .i_uart_rx(i_uart_rx),
    .o_uart_tx(o_uart_tx),
    .o_uart_reset(uart_oreset),

    .i_int(cpu_int),
    .i_nmi(cpu_nmi)
);


wire [15:0] mem_addr;
wire [7:0] mem_odat;
reg  mem_cs;

Memory #(.DEPTH(16), .WIDTH(8), .INITFILE("test.mem")) mem(
    .i_clk(i_clk),
    .i_addr(master_addr),
    .i_dat(master_odat),
    .o_dat(mem_odat),
    .i_cs(mem_cs),
    .i_we(master_we)
);


// memory map
// 0x0000 .. 0xf9ff memory
// 0xe000 .. 0xefff memory (vga font)
// 0xf000 .. 0xf95f memory (vga screen)
//           0xfa00 uart status
//           0xfa01 uart rx/tx
//           0xfa10 vga base addresses
//           0xfa11 vga cursor character index
//           0xfa12 vga cursor address low byte [7:0]
//           0xfa13 vga cursor address high byte [11:8]

// slave selects
always @(*)
begin
    if (master_addr >= 16'hfa00 && master_addr < 16'hfa10) begin
        mem_cs       = 0;
        uartslave_cs = 1;
        vgaslave_cs  = 0;
    end else if (master_addr >= 16'hfa10 && master_addr < 16'hfa20) begin
        mem_cs       = 0;
        uartslave_cs = 0;
        vgaslave_cs  = 1;
    end else begin
        mem_cs       = 1;
        uartslave_cs = 0;
        vgaslave_cs  = 0;
    end
end

assign master_idat =  vgaslave_cs ? vgaslave_odat :
                     uartslave_cs ? uartslave_odat :
                                    mem_odat;

assign master_ack  =  vgaslave_cs ? 1'b1 :
                     uartslave_cs ? 1'b1 :
                           mem_cs ? 1'b1 :
                                    1'b0;

endmodule
