`ifndef AFIFO_RD_MONITOR_SVH
`define AFIFO_RD_MONITOR_SVH

class afifo_rd_monitor extends uvm_monitor;
  `uvm_component_utils(afifo_rd_monitor)
  
  virtual afifo_rd_monitor_bfm bfm;
  uvm_analysis_port #(afifo_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual afifo_rd_monitor_bfm)::get(this, "", "rd_mon_bfm", bfm))
      `uvm_fatal("CFG", "BFM not found")
  endfunction

  task run_phase(uvm_phase phase);
    fork
      bfm.monitor_read();
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
    tr.rdata = bfm.observed_rdata;
    tr.op_type = READ;  //excplicitly set 
    `uvm_info("MON", $sformatf("Observed read: 0x%0h", tr.rdata), UVM_MEDIUM)
    ap.write(tr);
  endfunction

endclass
`endif
