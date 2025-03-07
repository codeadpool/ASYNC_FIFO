`ifndef AFIFO_WR_DRIVER_SVH
`define AFIFO_WR_DRIVER_SVH

class afifo_wr_driver extends uvm_driver #(afifo_txn);
  
//   virtual afifo_wr_driver_bfm bfm;
  wr_drv_bfm_t bfm;
  afifo_wr_agent_cfg m_agent_cfg;

  `uvm_component_utils(afifo_wr_driver)

  function new(string name = "afifo_wr_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual afifo_wr_driver_bfm)::get(this, "", "wr_drv_bfm", bfm))
      `uvm_fatal("WR_DRV/CFG_ERR", "Failed to get BFM")
      
    if (!uvm_config_db#(afifo_wr_agent_cfg)::get(this, "", "wr_agent_cfg", m_agent_cfg))
      `uvm_fatal(get_type_name(), "Couldn't retrieve WRITE AGENT CONFIG")
 
      bfm.set_proxy(this);
  endfunction : build_phase

  function void notify_reset_done();
    `uvm_info("WR_DRV/RST", $sformatf("FIFO Reset DONE from WRITE side"), UVM_MEDIUM)
  endfunction
  
  function void notify_overflow_attempt(bit [bfm.DATA_WIDTH-1:0] data);
    `uvm_info("WR_DRV/OVFL", $sformatf("Attempting overflow write with data 0x%0h", data), UVM_MEDIUM)
  endfunction

  function void notify_full(bit [bfm.DATA_WIDTH-1:0] data, int count);
    `uvm_info("WR_DRV/FULL", $sformatf("FIFO full, data=0x%0h, retry_attempt=%0d", data, count), UVM_MEDIUM)
  endfunction

  function void notify_write_timeout(bit [bfm.DATA_WIDTH-1:0] data, int count);
    `uvm_error("WR_DRV/TMOT", $sformatf("Write timeout 0x%0h after %0d retries", data, count))
  endfunction

  function void notify_write_success(bit [bfm.DATA_WIDTH-1:0] data);
    `uvm_info("WR_DRV/SUCC", $sformatf("Wrote data 0x%0h", data), UVM_HIGH)
  endfunction
  
  extern task run_phase(uvm_phase phase);
endclass

task afifo_wr_driver::run_phase (uvm_phase phase);
  bfm.do_reset();
  forever begin
  	seq_item_port.get_next_item(req);
    bfm.do_write(req.wdata, req.err_inject, req.err_type);
  	seq_item_port.item_done();
  end
endtask
`endif


