`ifndef AFIFO_WR_DRIVER_BFM_SV
`define AFIFO_WR_DRIVER_BFM_SV

interface afifo_wr_driver_bfm #(
  parameter int DATA_WIDTH = afifo_tb_pkg::DATA_WIDTH
)(
  input  logic wclk,
  output logic wrst_n,
  input  logic wfull,
  output logic winc,
  output logic [DATA_WIDTH-1:0] wdata
);
  import afifo_txn_pkg::*;
  import afifo_tb_pkg::*;

  task automatic do_write(
    input  logic [DATA_WIDTH-1:0] data_in,
    input  error_t                err_type,
    output wr_status_t         	  wr_status,
    output int unsigned           retry_count
  );
    retry_count = 0;
    
    // Error injection
    if (err_type == OVERFLOW) begin
      winc  <= 1'b1;
      wdata <= data_in;  
      @(posedge wclk);
      winc  <= 1'b0;
      wr_status = WR_OVERFLOW;
      return;
    end

    // Normal write
    do begin
      if(wfull) begin
        retry_count++;
        @(posedge wclk);
      end
    end while(wfull && retry_count < afifo_tb_pkg::MAX_FULL_RETRY);

    if(wfull) begin
      wr_status = WR_TIMEOUT;
      return;
    end

    winc  <= 1'b1;
    wdata <= data_in;  
    @(posedge wclk);
    winc  <= 1'b0;
    wr_status = WR_OK;
  endtask

  task automatic do_reset();
    wrst_n <= 1'b0;
    winc   <= 'b0;
    repeat (4) @(posedge wclk);
    wrst_n <= 1'b1;
  endtask
endinterface
`endif
