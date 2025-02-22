module fifomem #(
    parameter DATASIZE = 8,  // Memory data width
    parameter ADDRSIZE = 4   // Address bits (depth = 2^ADDRSIZE)
)(
    output [DATASIZE-1:0] rdata,
    input  [DATASIZE-1:0] wdata,
    input  [ADDRSIZE-1:0] waddr,
    input  [ADDRSIZE-1:0] raddr,
    input  wclken, wfull, wclk
);
    localparam DEPTH = 1 << ADDRSIZE;
    reg [DATASIZE-1:0] mem [0:DEPTH-1];

    // Combinational read
    assign rdata = mem[raddr];

    // Registered write
    always @(posedge wclk)
        if (wclken && !wfull)
            mem[waddr] <= wdata;
endmodule
