module tb_top();
  import uvm_pkg::*;
  import afifo_tb_pkg::*;
  
  reg wclk, rclk;
  
  localparam DATA_WIDTH = 32;
  localparam ADDR_WIDTH = 3;
  localparam real WR_CLK_MHZ 	= 100.0;
  localparam real RD_CLK_MHZ 	= 50.0;

  // Clock generators
  clkgen #(
    .FREQ_MHZ(WR_CLK_MHZ),
      .JITTER_PERCENT(1.0)
  ) wclk_gen (
      .clk    (wclk)
  );

  clkgen #(
      .FREQ_MHZ(RD_CLK_MHZ),
      .JITTER_PERCENT(1.0)
  ) rclk_gen (
      .clk    (rclk)
  );

  afifo_wr_driver_bfm  #(
    .DATA_WIDTH(afifo_tb_pkg::DATA_WIDTH)
  ) wr_drv_bfm (
    .wrst_n (dut.wrst_n),
    .winc   (dut.winc),
    .wdata  (dut.wdata),
    .wclk   (wclk),
    .wfull  (dut.wfull)
  );

  afifo_wr_monitor_bfm #(
    .DATA_WIDTH(afifo_tb_pkg::DATA_WIDTH)
  ) wr_mon_bfm (
    .wclk   (dut.wclk),
    .wrst_n (dut.wrst_n),
    .winc   (dut.winc),
    .wfull  (dut.wfull),
    .wdata  (dut.wdata)
  );

  afifo_rd_driver_bfm #(
    .DATA_WIDTH(afifo_tb_pkg::DATA_WIDTH)
  ) rd_drv_bfm (
    .rrst_n (dut.rrst_n),
    .rinc   (dut.rinc),
    .rdata  (dut.rdata),
    .rclk   (rclk),
    .rempty (dut.rempty)
  );

  afifo_rd_monitor_bfm #(
    .DATA_WIDTH(afifo_tb_pkg::DATA_WIDTH)
  ) rd_mon_bfm (
    .rclk   (dut.rclk),
    .rrst_n (dut.rrst_n),
    .rinc   (dut.rinc),
    .rempty (dut.rempty),
    .rdata  (dut.rdata)
  );

  afifo #(
    .DSIZE(afifo_tb_pkg::DATA_WIDTH),
    .ASIZE(afifo_tb_pkg::ADDR_WIDTH)
  ) dut (
    .wclk   (wclk),
    .rclk   (rclk),
    .wrst_n (wr_drv_bfm.wrst_n),
    .rrst_n (rd_drv_bfm.rrst_n),
    .winc   (wr_drv_bfm.winc),
    .rinc   (rd_drv_bfm.rinc),
    .wdata  (wr_drv_bfm.wdata),
    .rdata  (rd_mon_bfm.rdata),
    .wfull  (wr_mon_bfm.wfull),
    .rempty (rd_mon_bfm.rempty)
  );

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_top);
  end

  initial begin
    uvm_root::get().set_report_verbosity_level_hier(UVM_MEDIUM);
    uvm_config_db#(int)::set(null, "*", "max_depth", 1<<ADDR_WIDTH);
    
    uvm_config_db#(virtual afifo_wr_driver_bfm #(DATA_WIDTH))::set(null, "*", "wr_drv_bfm", wr_drv_bfm);
    uvm_config_db#(virtual afifo_wr_monitor_bfm#(DATA_WIDTH))::set(null, "*", "wr_mon_bfm", wr_mon_bfm);
    
    uvm_config_db#(virtual afifo_rd_driver_bfm) ::set(null, "*", "rd_drv_bfm", rd_drv_bfm);
    uvm_config_db#(virtual afifo_rd_monitor_bfm)::set(null, "*", "rd_mon_bfm", rd_mon_bfm);
    
//     run_test("sanity_check_test");
//     run_test("full_coverage_test");
//     run_test("error_test");
    run_test("stress_test");
  end
endmodule

