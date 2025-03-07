`ifndef AFIFO_WR_MONITOR_BFM_SV
`define AFIFO_WR_MONITOR_BFM_SV

interface afifo_wr_monitor_bfm#(
  parameter DATA_WIDTH = afifo_tb_pkg::DATA_WIDTH,
  parameter ADDR_WIDTH = afifo_tb_pkg::ADDR_WIDTH
  )(afifo_wr_if.mon_port bus);
  
  import afifo_txn_pkg::*;
  import afifo_wr_agent_pkg::*;
  afifo_wr_monitor proxy; // back-pointer to the HVL Monitor

  function void set_proxy (afifo_wr_monitor p);
    proxy =p; 
  endfunction

  task monitor_write();
    forever begin
      @(posedge bus.wclk);
      if(bus.winc)begin
        afifo_txn tr;
        tr =afifo_txn::type_id::create("tr");
        tr.wdata =bus.wdata;
        proxy.write(tr);
      end
    end 
  endtask
endinterface
`endif

