`ifndef AFIFO_TEST_LIB_SVH
`define AFIFO_TEST_LIB_SVH

//--------------------------------------------------------------------------------
// Base Test Class
//--------------------------------------------------------------------------------
class afifo_base_test extends uvm_test;
    `uvm_component_utils(afifo_base_test)
    
    afifo_env env; 
    
    function new(string name = "afifo_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      
        env = afifo_env::type_id::create("env", this);
    endfunction
  
    function void end_of_elaboration_phase(uvm_phase phase);
    	uvm_root::get().print_topology();
    endfunction : end_of_elaboration_phase
  	
   	function void start_of_simulation_phase(uvm_phase phase);
     	`uvm_info(get_type_name(), {"start of simulation for ",get_full_name()}, UVM_MEDIUM);
  	endfunction : start_of_simulation_phase
  
    virtual task run_phase(uvm_phase phase);
      	uvm_objection obj = phase.get_objection();
      	obj.set_drain_time(this, 2000ns);
    endtask
endclass

//--------------------------------------------------------------------------------
// Sanity Check Test
// Verifies basic write followed by read operations
//--------------------------------------------------------------------------------
class sanity_check_test extends afifo_base_test;
    `uvm_component_utils(sanity_check_test)
    
    function new(string name = "sanity_check_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
      	begin
          sanity_check_vseq vseq;
          vseq = sanity_check_vseq::type_id::create("vseq");
          vseq.start(null);
      	end
      	phase.get_objection().set_drain_time(this, 2000ns);
        phase.drop_objection(this);
    endtask
endclass

//--------------------------------------------------------------------------------
// Stress Test
// Concurrent writes and reads to test throughput and race conditions
//--------------------------------------------------------------------------------
class stress_test extends afifo_base_test;
    `uvm_component_utils(stress_test)
    
    function new(string name = "stress_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
      	begin
        	stress_test_vseq vseq;
        	vseq = stress_test_vseq::type_id::create("vseq");
        	vseq.start(null);
        end
      	phase.get_objection().set_drain_time(this, 2000ns);
        phase.drop_objection(this);
    endtask
endclass

//--------------------------------------------------------------------------------
// Error Injection Test
// Forces overflow and underflow conditions to test error handling
//--------------------------------------------------------------------------------
class error_test extends afifo_base_test;
    `uvm_component_utils(error_test)
    
    function new(string name = "error_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
      	phase.raise_objection(this);
      	begin
        error_test_vseq vseq;
        vseq = error_test_vseq::type_id::create("vseq");
        vseq.start(null);
        end
      	phase.get_objection().set_drain_time(this, 2000ns);
        phase.drop_objection(this);
    endtask
endclass

//--------------------------------------------------------------------------------
// Full Coverage Test
// Combines corner cases, data patterns, and stress for comprehensive coverage
//--------------------------------------------------------------------------------
class full_coverage_test extends afifo_base_test;
    `uvm_component_utils(full_coverage_test)
    
    function new(string name = "full_coverage_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      begin
        full_coverage_vseq vseq;
        vseq = full_coverage_vseq::type_id::create("vseq");
        vseq.start(null);
      end
      phase.get_objection().set_drain_time(this, 2000ns);
      phase.drop_objection(this);
    endtask
endclass

`endif // AFIFO_TEST_LIB_SVH
