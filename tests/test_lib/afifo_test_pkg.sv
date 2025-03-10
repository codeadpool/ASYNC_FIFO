`include "uvm_macros.svh"
package afifo_test_pkg;
	import uvm_pkg::*;

	import afifo_txn_pkg::*;
	import afifo_wr_agent_pkg::*;
	import afifo_rd_agent_pkg::*;
	import afifo_env_pkg::*;

	`include "afifo_seq_lib.svh"
	`include "afifo_vseq_lib.svh"
	`include "afifo_test_lib.svh"
endpackage
