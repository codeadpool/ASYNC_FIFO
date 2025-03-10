`ifndef AFIFO_WR_MONITOR_BFM_SV
`define AFIFO_WR_MONITOR_BFM_SV

interface afifo_wr_monitor_bfm #(
  parameter int DATA_WIDTH = afifo_tb_pkg::DATA_WIDTH
)(
  input logic wclk,
  input logic wrst_n,
  input logic winc,
  input wire wfull,
  input logic [DATA_WIDTH-1:0] wdata
);

  import afifo_tb_pkg::*;
  
  // Transaction observation event
  event trans_observed;
  logic [DATA_WIDTH-1:0] observed_wdata;

  task monitor_write();
    forever begin
      @(posedge wclk iff wrst_n);
      if(winc) begin
        observed_wdata = wdata;
        ->trans_observed;
      end
    end
  endtask

endinterface
`endif

