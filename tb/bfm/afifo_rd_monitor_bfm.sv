`ifndef AFIFO_RD_MONITOR_BFM_SV
`define AFIFO_RD_MONITOR_BFM_SV

interface afifo_rd_monitor_bfm#(
  parameter DATA_WIDTH =32,
  parameter ADDR_WIDTH =8
  )(afifo_rd_if.mon_port bus);
  
  import afifo_txn_pkg::*;
  import afifo_rd_agent_pkg::*;
  afifo_rd_monitor proxy; //back-pointer to the HVL Monitor
  // pulling isn't effective than pushing :0, pushing data to monitor-proxy

  // instead of using new(); we are passing the reference cause of flexibitly
  // if we use new() it tightly couples with the bfm 
  // and this method is SYNTHESIZABLE
  function void set_proxy (afifo_rd_monitor p);
    proxy =p; 
  endfunction

  task monitor_read();
    forever begin
      @(posedge bus.rclk);
      if(bus.rinc)begin
        afifo_txn tr;
        tr =afifo_txn::type_id::create("tr");
        tr.rdata =bus.rdata;
        proxy.write(tr);
      end
    end
  endtask 
endinterface

`endif
