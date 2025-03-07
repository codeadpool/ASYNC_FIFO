    `include "uvm_macros.svh"
package afifo_rd_agent_pkg;

    import uvm_pkg::*;
    import afifo_txn_pkg::*; 

	`include "afifo_rd_driver.svh"
	`include "afifo_rd_monitor.svh"	
	`include "afifo_rd_agent_cfg.svh"
	`include "afifo_rd_agent.svh"
endpackage
