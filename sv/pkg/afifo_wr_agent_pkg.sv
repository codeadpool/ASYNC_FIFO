    `include "uvm_macros.svh"
package afifo_wr_agent_pkg;
	import uvm_pkg::*;
	import afifo_txn_pkg::*;
	import afifo_typedefs_pkg::*;

  `include "afifo_wr_agent_cfg.svh"
  `include "afifo_wr_driver.svh"
  `include "afifo_wr_monitor.svh"
  `include "afifo_wr_agent.svh"
endpackage
