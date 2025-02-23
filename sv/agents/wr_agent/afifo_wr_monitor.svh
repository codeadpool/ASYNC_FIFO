`ifndef AFIFO_WR_MONITOR_SVH
`define AFIFO_WR_MONITOR_SVH

class afifo_wr_monitor extends uvm_monitor;
  
  virtual afifo_wr_monitor_bfm m_bfm;
  uvm_analysis_port #(afifo_txn) ap;

  `uvm_component_utils(afifo_wr_monitor)

  function new(string name = "afifo_wr_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual afifo_wr_monitor_bfm)::get(this, "", "wr_mon_bfm", m_bfm))
      `uvm_fatal("afifo_wr_monitor", "Failed to get BFM")
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_bfm.set_proxy(this);
  endfunction : connect_phase

  extern task run_phase(uvm_phase phase);

  function void write(afifo_txn tr);
    ap.write(tr);
  endfunction
endclass

task afifo_wr_monitor::run_phase(uvm_phase phase);
  m_bfm.monitor_write(); 
endtask

`endif
