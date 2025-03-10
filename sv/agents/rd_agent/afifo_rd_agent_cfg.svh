`ifndef AFIFO_RD_AGENT_CFG_SVH
`define AFIFO_RD_AGENT_CFG_SVH

class afifo_rd_agent_cfg extends uvm_object;
  `uvm_object_utils(afifo_rd_agent_cfg)
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  function new(string name = "afifo_rd_agent_cfg");
    super.new(name);
  endfunction
endclass

`endif
