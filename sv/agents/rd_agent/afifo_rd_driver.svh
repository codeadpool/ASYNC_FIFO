`ifndef AFIFO_RD_DRIVER_SVH
`define AFIFO_RD_DRIVER_SVH

class afifo_rd_driver extends uvm_driver #(afifo_txn);
  `uvm_component_utils(afifo_rd_driver)
  
  virtual afifo_rd_driver_bfm bfm;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual afifo_rd_driver_bfm)::get(this, "", "rd_drv_bfm", bfm))
      `uvm_fatal("CFG", "BFM not found")
  endfunction

  task run_phase(uvm_phase phase);
    afifo_tb_pkg::rd_status_t rd_status;
    int unsigned retry_count;
    logic [afifo_tb_pkg::DATA_WIDTH-1:0] rd_data;
    
    bfm.do_reset();
    
    forever begin
      seq_item_port.get_next_item(req);
      bfm.do_read(rd_data, req.err_type, rd_status, retry_count);
      handle_transaction(req, rd_data, rd_status, retry_count);
      seq_item_port.item_done();
    end
  endtask

  function void handle_transaction(
    afifo_txn txn,
    logic [31:0] data,
    afifo_tb_pkg::rd_status_t rd_status,
    int unsigned retry_count
  );
    txn.rdata = data;
    
    case(rd_status)
      afifo_tb_pkg::RD_OK: begin
        if(retry_count > 0)
		  `uvm_info("RD_DRV", $sformatf("Success after %0d retries: Read 0x%0h", retry_count, data), UVM_MEDIUM)
          else
          `uvm_info("RD_DRV", $sformatf("Read data: 0x%0h", data), UVM_MEDIUM)
      end
      afifo_tb_pkg::RD_UNDERFLOW:
        `uvm_info("RD_DRV/UFLOW", $sformatf("Underflow injected: 0x%0h", data), UVM_MEDIUM)
      afifo_tb_pkg::RD_TIMEOUT:
        `uvm_error("RD_DRV/TMOUT", $sformatf("Timeout after %0d retries", retry_count))
    endcase
  endfunction
endclass
            
`endif
