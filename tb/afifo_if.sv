`ifndef FIFO_INTERFACES_SV
`define FIFO_INTERFACES_SV

// Write Interface
interface afifo_wr_if #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8
)(
  input wclk,
  input wrst_n
);
  logic winc;
  logic wfull;
  logic [DATA_WIDTH-1:0] wdata;

  modport mon_port (
    input wclk,
    input wrst_n,
    input winc,
    input wdata,
    input wfull
  );

  modport drv_port (
    input wclk,
    input wrst_n,
    input wfull,
    output winc,
    output wdata
  );
endinterface

// Read Interface
interface afifo_rd_if #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8
)(
  input rclk,
  input rrst_n
);
  logic rinc;
  logic rempty;
  logic [DATA_WIDTH-1:0] rdata;

  modport mon_port (
    input rclk,
    input rrst_n,
    input rinc,
    input rdata,
    input rempty
  );

  modport drv_port (
    input rclk,
    input rrst_n,
    input rempty,
    input rdata,
    output rinc
  );
endinterface

`endif
