`ifndef AFIFO_RD_MONITOR_BFM_SV
`define AFIFO_RD_MONITOR_BFM_SV

interface afifo_rd_monitor_bfm #(
  parameter int DATA_WIDTH = afifo_tb_pkg::DATA_WIDTH
)(
  input logic rclk, 
  input logic rrst_n,
  input logic rinc,
  input wire rempty,
  input wire [DATA_WIDTH-1:0] rdata
);
  
  import afifo_txn_pkg::*;

  event trans_observed;
  logic [DATA_WIDTH-1:0] observed_rdata;

  task monitor_read();
    forever begin
      @(posedge rclk iff rrst_n);
      if(rinc && !rempty) begin
        observed_rdata = rdata;
        ->trans_observed;
      end
      else if(rinc && rempty) begin
        observed_rdata = 'x;
        ->trans_observed;
      end
    end
  endtask

endinterface
`endif
