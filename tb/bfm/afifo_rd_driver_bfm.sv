`ifndef AFIFO_RD_DRIVER_BFM_SV
`define AFIFO_RD_DRIVER_BFM_SV

interface afifo_rd_driver_bfm#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8,
  parameter MAX_EMPTY_RETRY = 10
)(afifo_rd_if.drv_port bus);

  import afifo_txn_pkg::*;
  import afifo_rd_agent_pkg::*;
  
  typedef int unsigned retry_count_t;
  afifo_rd_driver proxy;

  function set_proxy(afifo_rd_driver p);
    proxy = p; 
  endfunction

  task do_read(output logic [DATA_WIDTH-1:0] dout,
              input bit err_inject,
              input error_t err_type);
    retry_count_t retry_count = 0;
    
    // Handle underflow error injection
    if (err_inject && err_type == UNDERFLOW) begin
      proxy.notify_underflow_attempt();
      bus.rinc <= 1'b1;
      @(posedge bus.rclk);
      dout = bus.rdata;
      bus.rinc <= 1'b0;
      return;
    end

    // Normal read operation
    do begin
      if(bus.rempty) begin
        proxy.notify_empty();
        retry_count++;
        @(posedge bus.rclk);
      end
    end while(bus.rempty && retry_count < MAX_EMPTY_RETRY);

    if(bus.rempty) begin
      proxy.notify_read_timeout();
      dout = 'x;
      return;
    end

    // Successful read
    bus.rinc <= 1'b1;
    @(posedge bus.rclk);
    dout = bus.rdata;
    bus.rinc <= 1'b0;
  endtask

  task do_reset();
    bus.rrst_n <= 1'b0;
    bus.rinc <= 'b0;
    repeat(2) @(posedge bus.rclk);
    bus.rrst_n <= 1'b1;
  endtask

endinterface
`endif
