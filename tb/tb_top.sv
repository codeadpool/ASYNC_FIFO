
module tb_top();
  import uvm_pkg::*;
  
  import afifo_tb_pkg::*;
  import afifo_wr_agent_pkg::*;
  import afifo_rd_agent_pkg::*;
  
  reg wclk, rclk;
 
  localparam real wr_freq_mhz 	= 100.0;
  localparam real rd_freq_mhz 	= 50.0;
  
  afifo_wr_agent_cfg wr_agent_cfg;
  afifo_rd_agent_cfg rd_agent_cfg;

  afifo_wr_if#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) wr_if ();
  afifo_rd_if#(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rd_if ();
  
//   afifo_wr_driver_bfm  #(DATA_WIDTH, ADDR_WIDTH) wr_drv_bfm();
  typedef virtual afifo_wr_driver_bfm #(DATA_WIDTH, ADDR_WIDTH) wr_drv_bfm_t;
  wr_drv_bfm_t wr_drv_bfm;
  
  afifo_wr_monitor_bfm #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) wr_mon_bfm(wr_if);
//   typedef virtual afifo_wr_monitor_bmf #(DATA_WIDTH, ADDR_WIDTH) wr_mon_bfm_t;
  
  afifo_rd_driver_bfm  #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rd_drv_bfm(rd_if);
  afifo_rd_monitor_bfm #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) rd_mon_bfm(rd_if);
  
  // Clock generation
  clkgen #(.FREQ_MHZ(wr_freq_mhz), .JITTER_PERCENT(1.0)) wclk_gen (.clk(wclk));
  clkgen #(.FREQ_MHZ(rd_freq_mhz), .JITTER_PERCENT(1.0)) rclk_gen (.clk(rclk));
  
  assign wr_if.wclk = wclk;
  assign rd_if.rclk = rclk;

  afifo #(
    .DSIZE      (DATA_WIDTH),
    .ASIZE 	    (ADDR_WIDTH)
    ) dut (

    .wclk       (wr_if.wclk),
    .rclk       (rd_if.rclk),

    .wrst_n     (wr_if.wrst_n),
    .rrst_n     (rd_if.rrst_n),

    .winc       (wr_if.winc),
    .rinc       (rd_if.rinc),

    .wdata      (wr_if.wdata),
    .rdata      (rd_if.rdata),

    .wfull      (wr_if.wfull),
    .rempty     (rd_if.rempty)
  );
  
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_top);
  end

  initial begin
    uvm_root::get().set_report_verbosity_level_hier(UVM_MEDIUM);
    // Config set
    wr_drv_bfm = wr_if;
    uvm_config_db#(int)::set(null, "*", "max_depth", 1<<ADDR_WIDTH);

    wr_agent_cfg = afifo_wr_agent_cfg::type_id::create("wr_agent_cfg");
    wr_agent_cfg.DATA_WIDTH = DATA_WIDTH;
    wr_agent_cfg.ADDR_WIDTH = ADDR_WIDTH;
    rd_agent_cfg = afifo_rd_agent_cfg::type_id::create("rd_agent_cfg");
    rd_agent_cfg.DATA_WIDTH = DATA_WIDTH;
    rd_agent_cfg.ADDR_WIDTH = ADDR_WIDTH;
    uvm_config_db#(afifo_wr_agent_cfg)::set(null, "*", "wr_agent_cfg", wr_agent_cfg);
    uvm_config_db#(afifo_rd_agent_cfg)::set(null, "*", "rd_agent_cfg", rd_agent_cfg);

    uvm_config_db#(virtual afifo_wr_if#(DATA_WIDTH, ADDR_WIDTH))::set(null, "*", "wr_vif", wr_if);
    uvm_config_db#(virtual afifo_rd_if#(DATA_WIDTH, ADDR_WIDTH))::set(null, "*", "rd_vif", rd_if);
    
    uvm_config_db#(virtual afifo_wr_driver_bfm#(DATA_WIDTH, ADDR_WIDTH))::set(null, "*", "wr_drv_bfm", wr_drv_bfm);
    uvm_config_db#(virtual afifo_wr_monitor_bfm#(DATA_WIDTH, ADDR_WIDTH))::set(null, "*", "wr_mon_bfm", wr_mon_bfm);
    
    uvm_config_db#(virtual afifo_rd_driver_bfm)::set(null, "*", "rd_drv_bfm", rd_drv_bfm);
    uvm_config_db#(virtual afifo_rd_monitor_bfm)::set(null, "*", "rd_mon_bfm", rd_mon_bfm);
    
//     run_test("full_coverage_test");
    run_test("error_test");
  end
endmodule
