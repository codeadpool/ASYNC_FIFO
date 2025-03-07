`ifndef AFIFO_RD_MONITOR_SVH
`define AFIFO_RD_MONITOR_SVH

class afifo_rd_monitor extends uvm_monitor;
  
  virtual afifo_rd_monitor_bfm m_bfm;
  uvm_analysis_port #(afifo_txn) ap;
  
  `uvm_component_utils(afifo_rd_monitor)

  function new(string name = "afifo_rd_monitor", uvm_component parent);
    super.new(name, parent);

    ap =new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual afifo_rd_monitor_bfm)::get(this, "", "rd_mon_bfm", m_bfm))
      `uvm_fatal("RD_MON/BFM", "Failed to get BFM")
      
    m_bfm.set_proxy(this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    forever begin
    	m_bfm.monitor_read();
    end
  endtask
  
  function void write(afifo_txn tr);
    ap.write(tr); 
  endfunction
endclass

`endif
