module Memory(
    i_clk,
    i_addr,
    i_dat,
    o_dat,
    i_cs,
    i_we
);

parameter
    DEPTH=16,
    WIDTH=8,
    INITFILE=0;

input i_clk;
input i_cs;
input i_we;
input      [DEPTH-1:0] i_addr;
input      [WIDTH-1:0] i_dat;
output reg [WIDTH-1:0] o_dat;


reg [WIDTH-1:0] mem[0:2**DEPTH-1];

always @(posedge i_clk)
    o_dat <= mem[i_addr];

always @(posedge i_clk)
    if (i_cs && i_we)
        mem[i_addr] <= i_dat;

initial begin
    if (INITFILE != 0) begin
        $readmemh(INITFILE, mem, 0);
        $display("Using file %s", INITFILE);
    end
    $readmemh("font.mem", mem, 'he000); // TODO: Remove later
    // $readmemh("screen.mem", mem, 'hf000); // TODO: Remove later
end

endmodule