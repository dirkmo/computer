`default_nettype none

module MasterShell(
    input             i_clk,
    input             i_reset,
    input      [7:0]  i_dat,
    output     [7:0]  o_dat,
    output    [15:0]  o_addr,
    output            o_cs,
    output            o_we,
    input             i_ack,

    // MonoVgaText
    input       [7:0] i_vgaslave_dat,
    output      [7:0] o_vgaslave_dat,
    input       [1:0] i_vgaslave_addr,
    input             i_vgaslave_cs,
    input             i_vgaslave_we,

    output            o_hsync,
    output            o_vsync,
    output            o_pixel,

    // uart
    input  [7:0] i_uartslave_dat,
    output [7:0] o_uartslave_dat,
    input        i_uartslave_addr,
    output       o_uartslave_ack,
    input        i_uartslave_we,
    input        i_uartslave_cs,
    
    output       o_uart_int,
    input        i_uart_rx,
    output       o_uart_tx,
    output       o_uart_reset,

    // cpu
    input        i_int,
    input        i_nmi
);

wire [15:0] o_vgamaster_addr;
wire vgamaster_cs;
wire vgamaster_access;

wire [7:0] o_uartmaster_dat;
wire [15:0] o_uartmaster_addr;
wire uartmaster_ack;
wire uartmaster_we;
wire uartmaster_cs;

reg r_vgamaster_active;
reg r_uartmaster_active;
reg r_cpumaster_active;

always @(posedge i_clk)
    if (vgamaster_access)
        r_vgamaster_active <= 1;
    else
        r_vgamaster_active <= 0;

MonoVgaText vga0(
    .i_clk(i_clk),
    .i_reset(i_reset),
    // vga bus master
    .o_vgaram_addr(o_vgamaster_addr),
    .i_vgaram_dat(i_dat),
    .o_vgaram_cs(vgamaster_cs),
    .o_vgaram_access(vgamaster_access),
    // vga bus slave
    .i_dat(i_vgaslave_dat),
    .o_dat(o_vgaslave_dat),
    .i_addr(i_vgaslave_addr[1:0]),
    .i_cs(i_vgaslave_cs),
    .i_we(i_vgaslave_we),
    .o_hsync(o_hsync),
    .o_vsync(o_vsync),
    .o_pixel(o_pixel)
);

UartMasterSlave #(.BAUDRATE(115200),.SYS_FREQ(25000000)) uart0(
    .i_clk(i_clk),
    .i_reset(i_reset),

    .i_master_data(i_dat),
    .o_master_data(o_uartmaster_dat),
    .o_master_addr(o_uartmaster_addr),
    .i_master_ack(uartmaster_ack),
    .o_master_we(uartmaster_we),
    .o_master_cs(uartmaster_cs),

    .i_slave_data(i_uartslave_dat),
    .o_slave_data(o_uartslave_dat),
    .i_slave_addr(i_uartslave_addr),
    .o_slave_ack(o_uartslave_ack),
    .i_slave_we(i_uartslave_we),
    .i_slave_cs(i_uartslave_cs),
    .o_int(o_uart_int),

    .i_uart_rx(i_uart_rx),
    .o_uart_tx(o_uart_tx),

    .o_reset(o_uart_reset)
);


wire [15:0] o_cpumaster_addr;
wire  [7:0] o_cpumaster_dat;
wire        o_cpumaster_we;
wire        i_cpu_ack;

cpu_async cpu0(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_addr(o_cpumaster_addr),
    .i_dat(i_dat),
    .o_dat(o_cpumaster_dat),
    .o_we(o_cpumaster_we),
    .i_int(i_int),
    .i_nmi(i_nmi),
    .i_ack(i_cpu_ack),
    .i_active(r_cpumaster_active)
);

// note: vgamaster never outputs data
assign          o_dat = r_uartmaster_active ? o_uartmaster_dat :
                         r_cpumaster_active ? o_cpumaster_dat : 0;

assign         o_addr =  r_vgamaster_active ? o_vgamaster_addr :
                        r_uartmaster_active ? o_uartmaster_addr :
                         r_cpumaster_active ? o_cpumaster_addr : 0;

assign           o_we =   r_vgamaster_active ? 1'b0 :
                         r_uartmaster_active ? uartmaster_we :
                          r_cpumaster_active ? o_cpumaster_we : 0;

assign           o_cs =   r_vgamaster_active ? vgamaster_cs : 
                         r_uartmaster_active ? uartmaster_cs :
                          r_cpumaster_active ? 1'b1 : 0;


assign i_cpu_ack      = r_cpumaster_active && i_ack;
assign uartmaster_ack = ~r_uartmaster_active && i_ack;

endmodule