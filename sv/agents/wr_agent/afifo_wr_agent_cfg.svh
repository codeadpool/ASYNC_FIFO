class afifo_wr_agent_cfg extends uvm_object;
  `uvm_object_utils(afifo_wr_agent_cfg)
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  rand int min_wr_delay = 0;  // Minimum delay between writes
  rand int max_wr_delay = 5;  // Maximum delay between writes
  
  constraint valid_wr_delay {
    min_wr_delay >= 0;
    max_wr_delay >= min_wr_delay;
  }

  function new(string name = "afifo_wr_agent_cfg");
    super.new(name);
  endfunction
endclass
