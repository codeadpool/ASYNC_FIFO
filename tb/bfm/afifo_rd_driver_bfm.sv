`ifndef AFIFO_RD_DRIVER_BFM_SV
`define AFIFO_RD_DRIVER_BFM_SV

interface afifo_rd_driver_bfm #(
  parameter int DATA_WIDTH = afifo_tb_pkg::DATA_WIDTH
)(
  input  logic rclk,
  input  logic rempty,
  input logic [DATA_WIDTH-1:0] rdata,
  output logic rinc,
  output logic rrst_n
);

  import afifo_txn_pkg::*;
  import afifo_tb_pkg::*;

  task automatic do_reset();
    rrst_n <= 1'b0;
    rinc <= '0;
    repeat(2) @(posedge rclk);
    rrst_n <= 1'b1;
  endtask

  task automatic do_read(
    output logic [DATA_WIDTH-1:0] dout,
    input  error_t                err_type,
    output rd_status_t            rd_status,
    output int unsigned           retry_count
  );
    retry_count = 0;

    // Error injection handling
    if(err_type == UNDERFLOW) begin
      rinc <= 1'b1;
      @(posedge rclk);
      dout = rdata;
      rinc <= 1'b0;
      rd_status = RD_UNDERFLOW;
      return;
    end

    // Normal read operation
    do begin
      if(rempty) begin
        retry_count++;
        @(posedge rclk);
      end
    end while(rempty && retry_count < afifo_tb_pkg::MAX_EMPTY_RETRY);

    if(rempty) begin
      rd_status = RD_TIMEOUT;
      dout = 'x;
      return;
    end

    rinc <= 1'b1;
    @(posedge rclk);
    dout = rdata;
    rinc <= 1'b0;
    rd_status = RD_OK;
  endtask

endinterface
`endif
