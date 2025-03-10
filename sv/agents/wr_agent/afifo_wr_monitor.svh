`ifndef AFIFO_WR_MONITOR_SVH
`define AFIFO_WR_MONITOR_SVH

class afifo_wr_monitor extends uvm_monitor;
  `uvm_component_utils(afifo_wr_monitor)
  
  virtual afifo_wr_monitor_bfm bfm;
  uvm_analysis_port #(afifo_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual afifo_wr_monitor_bfm)::get(this, "", "wr_mon_bfm", bfm))
      `uvm_fatal("CFG", "BFM not found")
  endfunction

  task run_phase(uvm_phase phase);
    fork
      bfm.monitor_write();
      process_transactions();
    join
  endtask

  task process_transactions();
    forever begin
      @(bfm.trans_observed);
      report_transaction();
    end
  endtask

  function void report_transaction();
    afifo_txn tr = afifo_txn::type_id::create("tr");
    tr.wdata = bfm.observed_wdata;
    `uvm_info("MON", $sformatf("Observed write: 0x%0h", tr.wdata), UVM_MEDIUM)
    ap.write(tr);   
  endfunction

endclass
`endif
