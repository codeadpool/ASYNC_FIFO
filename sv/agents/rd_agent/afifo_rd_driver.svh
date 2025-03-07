`ifndef AFIFO_RD_DRIVER_SVH
`define AFIFO_RD_DRIVER_SVH

class afifo_rd_driver extends uvm_driver #(afifo_txn);
  virtual afifo_rd_driver_bfm bfm;
  `uvm_component_utils(afifo_rd_driver)

  function new(string name = "afifo_rd_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual afifo_rd_driver_bfm)::get(this, "", "rd_drv_bfm", bfm))
      `uvm_fatal("RD_DRV/CFG_ERR", "Failed to get BFM")
    bfm.set_proxy(this);
  endfunction

  task run_phase(uvm_phase phase);
    bfm.do_reset();
    `uvm_info("RD_DRV/RST", "FIFO Reset Done from READ Side", UVM_MEDIUM)
    forever begin
      afifo_txn txn;
      logic [bfm.DATA_WIDTH-1:0] rd_data;
      seq_item_port.get_next_item(txn);
      bfm.do_read(rd_data, txn.err_inject, txn.err_type);
      txn.rdata = rd_data;
      seq_item_port.item_done(txn);
    end
  endtask

  function void notify_empty();
    `uvm_info("EMPTY", "FIFO is empty", UVM_MEDIUM)
  endfunction

  function void notify_underflow_attempt();
    `uvm_info("UNDERFLOW", "Attempting read from empty FIFO", UVM_MEDIUM)
  endfunction

  function void notify_read_timeout();
    `uvm_error("TIMEOUT", "Read timeout: FIFO remained empty")
  endfunction
endclass
`endif
