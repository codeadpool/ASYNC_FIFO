module tb_top();
  import uvm_pkg::*;

  localparam DATA_WIDTH = 32;
  localparam ADDR_WIDTH = 8;
  localparam FIFO_DEPTH = 8;

  reg wclk, rclk;
  reg wrst_n, rrst_n;
  reg winc, rinc;
  reg [DATA_WIDTH -1:0] wdata, rdata;
  reg wfull, rempty;

  real wr_freq_mhz, rd_freq_mhz;

  afifo_wr_if wr_if (.clk(wclk), .rst_n(wrst_n));
  afifo_rd_if rd_if (.clk(rclk), .rst_n(rrst_n));

  // Clock generation
  clkgen #(.FREQ_MHZ(wr_freq_mhz), .JITTER_PERCENT(1.0)) wclk_gen (.clk(wclk));
  clkgen #(.FREQ_MHZ(rd_freq_mhz), .JITTER_PERCENT(1.0)) rclk_gen (.clk(rclk));

  afifo_dut #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
    ) dut (

    .wclk       (wclk),
    .rclk       (rclk),

    .wrst_n     (wrst_n),
    .rrst_n     (rrst_n),

    .winc       (winc),
    .rinc       (rinc),

    .wdata      (wdata),
    .rdata      (rdata),

    .wfull      (wfull),
    .rempty     (rempty)
  );

  initial begin
    wr_freq_mhz = 100.0;
    rd_freq_mhz = 75.0;

    uvm_config_db#(int)::set(null, "*", "FIFO_DEPTH", FIFO_DEPTH);

    uvm_config_db#(virtual afifo_wr_if)::set(null, "*", "wr_vif", wr_if);
    uvm_config_db#(virtual afifo_rd_if)::set(null, "*", "rd_vif", rd_if);
    
    run_test();
  end
endmodule
