# ==============================================
# Include UVM source directory
# ==============================================
+incdir+$UVM_HOME/src

# ==============================================
# Compile UVM base packages
# ==============================================
$UVM_HOME/src/uvm_pkg.sv
$UVM_HOME/src/uvm_macros.svh

# ==============================================
# DUT Files
# ==============================================
afifo_top.sv

# ==============================================
# Interface Files
# ==============================================
afifo_tb_pkg.sv
afifo_txn_pkg.sv

afifo_wr_driver_bfm.sv
afifo_wr_monitor_bfm.sv

afifo_rd_driver_bfm.sv
afifo_rd_monitor_bfm.sv

# ==============================================
# Package Files (Ordered by Dependency)
# ==============================================
afifo_wr_agent_pkg.sv
afifo_rd_agent_pkg.sv
afifo_env_pkg.sv
afifo_test_pkg.sv

# ==============================================
# Testbench Files
# ==============================================
clkgen.sv
tb_top.sv
