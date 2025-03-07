`include "uvm_macros.svh"
package afifo_env_pkg;
	import uvm_pkg::*;
	parameter DATA_WIDTH = 32;
	import afifo_txn_pkg::*;
	import afifo_wr_agent_pkg::*;
	import afifo_rd_agent_pkg::*;
	`include "afifo_coverage.svh"
	`include "afifo_scoreboard.svh"
	`include "afifo_env.svh"
endpackage
