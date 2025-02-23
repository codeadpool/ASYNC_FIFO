`ifndef AFIFO_WR_AGENT_CFG_SVH
`define AFIFO_WR_AGENT_CFG_SVH

class afifo_wr_agent_cfg extends uvm_object;
  `uvm_object_utils(afifo_wr_agent_cfg)
 
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  // Transaction timing control
  rand int min_wr_delay = 0;  // Minimum delay between writes
  rand int max_wr_delay = 5;  // Maximum delay between writes
  
  // Delay constraints
  constraint valid_wr_delay {
    min_wr_delay >= 0;
    max_wr_delay >= min_wr_delay;
  }

  function new(string name = "afifo_wr_agent_cfg");
    super.new(name);
  endfunction

//   function void check_config();
//     if (vif == null)
//       `uvm_fatal("CFG_ERR", $sformatf("[%s] Write interface not set!", this.get_name()))
//   endfunction
endclass

`endif
