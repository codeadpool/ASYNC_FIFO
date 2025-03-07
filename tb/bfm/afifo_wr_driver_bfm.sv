`ifndef AFIFO_WR_DRIVER_BFM_SV
`define AFIFO_WR_DRIVER_BFM_SV

interface afifo_wr_driver_bfm#(
  parameter DATA_WIDTH = afifo_tb_pkg::DATA_WIDTH,
  parameter ADDR_WIDTH = afifo_tb_pkg::ADDR_WIDTH
)(afifo_wr_if.drv_port bus);
  
  import afifo_txn_pkg::*;
  import afifo_wr_agent_pkg::*;
  
  localparam MAX_FULL_RETRY = 10;
  // Typedefs and local parameters
  typedef int unsigned retry_count_t;
  afifo_wr_driver proxy;
  
  function set_proxy(afifo_wr_driver p);
    proxy = p; 
  endfunction

  function bit is_full();
    return bus.wfull;
  endfunction

  task do_write(input [DATA_WIDTH-1:0] write_data, 
               input bit              err_inject,
               input error_t          err_type);
    retry_count_t retry_count = 0;
    
    // Error injection handling
    if (err_inject && err_type == OVERFLOW) begin
      proxy.notify_overflow_attempt(write_data);
      bus.winc  <= 1'b1;
      bus.wdata <= write_data;
      @(posedge bus.wclk);
      bus.winc  <= 1'b0;
      return;
    end

    // Normal write operation
    do begin
      if(bus.wfull) begin
        proxy.notify_full(write_data, retry_count);
        retry_count++;
        @(posedge bus.wclk);
      end
    end while(bus.wfull && retry_count < MAX_FULL_RETRY);

    // Post-retry handling
    if(bus.wfull) begin
      proxy.notify_write_timeout(write_data, retry_count);
      return;
    end

    // Successful write
    bus.winc  <= 1'b1;
    bus.wdata <= write_data;
    @(posedge bus.wclk);
    bus.winc  <= 1'b0;
    proxy.notify_write_success(write_data);
  endtask

  task do_reset();
    bus.wrst_n <= 1'b0;
    bus.winc   <= 'b0;
    repeat (4) @(posedge bus.wclk);
    bus.wrst_n <= 1'b1;
    proxy.notify_reset_done();
  endtask

endinterface
`endif
