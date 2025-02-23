module tb_top();
  import uvm_pkg::*;

  localparam DATA_WIDTH = 32;
  localparam ADDR_WIDTH = 8;
  localparam FIFO_DEPTH = 8;

  reg wclk, rclk;
  reg wrst_n, rrst_n;
  reg winc, rinc;
  reg [DATA_WIDTH - 1:0] wdata, rdata;
  reg wfull, rempty;

  localparam real wr_freq_mhz = 100.0;
  localparam real rd_freq_mhz = 75.0;

  afifo_wr_if#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) wr_if (.wclk(wclk), .wrst_n(wrst_n));
  afifo_rd_if#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rd_if (.rclk(rclk), .rrst_n(rrst_n));

  afifo_wr_driver_bfm  #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) wr_drv_bfm(wr_if);
  afifo_wr_monitor_bfm #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) wr_mon_bfm(wr_if);

  // Clock generation
  clkgen #(.FREQ_MHZ(wr_freq_mhz), .JITTER_PERCENT(1.0)) wclk_gen (.clk(wclk));
  clkgen #(.FREQ_MHZ(rd_freq_mhz), .JITTER_PERCENT(1.0)) rclk_gen (.clk(rclk));

  afifo #(
    .DSIZE(DATA_WIDTH),
    .ASIZE(ADDR_WIDTH)
  ) dut (
    .wclk(wclk),
    .rclk(rclk),
    .wrst_n(wrst_n),
    .rrst_n(rrst_n),
    .winc(winc),
    .rinc(rinc),
    .wdata(wdata),
    .rdata(rdata),
    .wfull(wfull),
    .rempty(rempty)
  );

  initial begin
    uvm_config_db#(int)::set(null, "*", "FIFO_DEPTH", FIFO_DEPTH);
    uvm_config_db#(virtual afifo_wr_if)::set(null, "*", "wr_vif", wr_if);
    uvm_config_db#(virtual afifo_rd_if)::set(null, "*", "rd_vif", rd_if);
    uvm_config_db#(virtual afifo_wr_driver_bfm)::set(null, "*", "wr_drv_bfm", wr_drv_bfm);
    uvm_config_db#(virtual afifo_wr_monitor_bfm)::set(null, "*", "wr_mon_bfm", wr_mon_bfm);
    
    run_test();
  end
endmodule
