`ifndef AFIFO_WR_MONITOR_BFM_SV
`define AFIFO_WR_MONITOR_BFM_SV

interface afifo_wr_monitor_bfm#(
  parameter DATA_WIDTH =32,
  parameter ADDR_WIDTH =8
  )(afifo_wr_if.mon_port bus);
  
  import afifo_wr_agent_pkg::*;
  afifo_wr_monitor proxy; // back-pointer to the HVL Monitor

  function void set_proxy (afifo_wr_monitor p);
    proxy =p; 
  endfunction

  task monitor_write();
    forever begin
      @(posedge bus.wclk);
      if(bus.winc && !bus.wfull)begin
        afifo_txn tr;
        tr =afifo_txn::type_id::create("tr");
        tr.wdata =bus.wdata;
        proxy.write(tr);
      end
    end 
  endtask
endinterface
`endif
