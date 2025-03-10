`ifndef AFIFO_WR_DRIVER_SVH
`define AFIFO_WR_DRIVER_SVH

class afifo_wr_driver extends uvm_driver #(afifo_txn);
  `uvm_component_utils(afifo_wr_driver)
  
  virtual afifo_wr_driver_bfm bfm;
//   wr_drv_bfm_t bfm;
  afifo_wr_agent_cfg m_cfg;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual afifo_wr_driver_bfm)::get(this, "", "wr_drv_bfm", bfm))
      `uvm_fatal("CFG", "BFM not found")
      if(!uvm_config_db#(afifo_wr_agent_cfg)::get(this, "", "wr_agent_cfg", m_cfg))
      `uvm_fatal("CFG", "Agent config not found")
  endfunction

  task run_phase(uvm_phase phase);
    afifo_tb_pkg::wr_status_t wr_status;
    int unsigned   retry_count;
    bfm.do_reset();
    forever begin
      seq_item_port.get_next_item(req);
      bfm.do_write(req.wdata, req.err_type, wr_status, retry_count);
      handle_write_result(req.wdata, wr_status, retry_count);
      seq_item_port.item_done();
    end
  endtask   

  function void handle_write_result(
    logic [bfm.DATA_WIDTH-1:0] wdata,
    afifo_tb_pkg::wr_status_t  wr_status,
    int unsigned               retry_count
  );
    case (wr_status)
      WR_OK: begin
        if (retry_count > 0) begin
          `uvm_info("WR_DRV", $sformatf("Success after %0d retries: Wrote 0x%0h",
                    retry_count, wdata), UVM_MEDIUM)
        end else begin
          `uvm_info("WR_DRV", $sformatf("Wrote data: 0x%0h", wdata), UVM_MEDIUM)
        end
      end
      WR_OVERFLOW: 
        `uvm_info("WR_DRV/OVFL", $sformatf("Overflow injected: 0x%0h", wdata), UVM_MEDIUM)
      WR_TIMEOUT:
        `uvm_error("WR_DRV/TMOUT", $sformatf("Timeout after %0d retries on 0x%0h", retry_count, wdata))

    endcase
  endfunction
endclass
    
`endif


