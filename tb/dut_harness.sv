`ifndef DUT_HARNESS_SV
`define DUT_HARNESS_SV

interface afifo_harness#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8
  );

  afifo_wr_if#(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) wr_if(  
      .wclk   (afifo.wclk),
      .wrst_n (afifo.wrst_n),
      .winc   (afifo.winc),
      .wfull  (afifo.wfull),
      .wdata  (afifo.wdata)
    );

  afifo_rd_if#(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  )  rd_if(
      .rclk   (afifo.rclk),
      .rrst_n (afifo.rrst_n),
      .rinc   (afifo.rinc),
      .rempty (afifo.rempty),
      .rdata  (afifo.rdata)
    );

  function void set_wr_if (string path);
    uvm_config_db#(afifo_wr_if)::set(null, path, "wr_vif", wr_if); 
  endfunction
  
  function void set_rd_if (string path);
    uvm_config_db#(afifo_rd_if)::set(null, path, "rd_vif", rd_if); 
  endfunction
endinterface

bind afifo afifo_harness harness();

`endif
