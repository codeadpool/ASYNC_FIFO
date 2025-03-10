//-----------------------------------------------------------------------------
// Base Sequence
//-----------------------------------------------------------------------------
class afifo_base_seq extends uvm_sequence #(afifo_txn);
    `uvm_object_utils(afifo_base_seq)
  
   	int max_depth; 
    int num_trans = 100;
    
    function new(string name = "afifo_base_seq");
        super.new(name);
    endfunction
    
    constraint reasonable_num_trans {
        num_trans inside {[50:1000]};
    }
  
    virtual task pre_body();
      uvm_phase phase = get_starting_phase();
      if (phase != null) begin
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Raised objection", UVM_MEDIUM)
      end
      
      //Sequences arenot components so can't use "THIS" as context in db call.
      if(!uvm_config_db#(int)::get(null, "", "max_depth", max_depth))
        `uvm_fatal("[SEQ/CFG_ERR]", "Couldn't retrieve MAX DEPTH from uvm_config_db")
    endtask

  	virtual task post_body();
      uvm_phase phase = get_starting_phase();
      if (phase != null) begin
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Dropped objection", UVM_MEDIUM)
      end
  	endtask
endclass

//-----------------------------------------------------------------------------
// Basic Operational Sequences
//-----------------------------------------------------------------------------
class simple_write_seq extends afifo_base_seq;
    `uvm_object_utils(simple_write_seq)
    
    function new(string name = "simple_write_seq");
        super.new(name);
    endfunction
    
    task body();
      `uvm_info("SEQ/START", "Starting Simple Write Sequence", UVM_MEDIUM) 

      for(int i = 0; i < num_trans; i++) begin
            req = afifo_txn::type_id::create("req");
           	start_item(req);
           	assert(req.randomize() with {
                op_type == WRITE;
                err_inject == 0;
            });
           	 `uvm_info("SEQ/PKT#", $sformatf("Pushing packet #%0d with Data: 0x%0h for %s", i, req.wdata, req.winc ? "WRITE" : "READ"), UVM_MEDIUM)
           finish_item(req);
        end
    endtask
endclass

class simple_read_seq extends afifo_base_seq;
    `uvm_object_utils(simple_read_seq)
    
    function new(string name = "simple_read_seq");
        super.new(name);
    endfunction
    
    task body();
      `uvm_info("SEQ/START", "Starting Simple Read Sequence", UVM_MEDIUM)
      
        for(int i = 0; i < num_trans; i++) begin
          	req = afifo_txn::type_id::create("req");
          	start_item(req);
          	assert(req.randomize() with {
                op_type == READ;
                err_inject == 0;
            });
          `uvm_info("SEQ/PKT", $sformatf("READ PKT #%0d ", i), UVM_MEDIUM) 
          finish_item(req);    	
        end
    endtask
endclass

//-----------------------------------------------------------------------------
// Corner Case Sequences
//-----------------------------------------------------------------------------
class fifo_full_seq extends afifo_base_seq;
    `uvm_object_utils(fifo_full_seq)
    
    function new(string name = "fifo_full_seq");
        super.new(name);
        num_trans = 1;
    endfunction
    
    task body();
        afifo_txn tx;
        // Write until full + 1 extra
      	for(int i = 0; i < num_trans+1; i++) begin
            tx = afifo_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize() with {
                op_type == WRITE;
                err_inject == 0;
            });
          	`uvm_info("SEQ/PKT#", $sformatf("Pushing packet #%0d with Data: 0x%0h for %s", i, tx.wdata, tx.winc ? "WRITE" : "READ"), UVM_MEDIUM)
            finish_item(tx);
        end
    endtask
endclass

class fifo_empty_seq extends afifo_base_seq;
    `uvm_object_utils(fifo_empty_seq)
    
    function new(string name = "fifo_empty_seq");
        super.new(name);
        num_trans = 1;  
    endfunction
    
    task body();
        afifo_txn tx;
        // Read until empty + 1 extra
      for(int i = 0; i < num_trans+1; i++) begin
            tx = afifo_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize() with {
                op_type == READ;
                err_inject == 0;
            });
        	`uvm_info("SEQ/PKT", $sformatf("READ PKT #%0d", i), UVM_MEDIUM) 
            finish_item(tx);
        end
    endtask
endclass

//-----------------------------------------------------------------------------
// Error Injection Sequences
//-----------------------------------------------------------------------------
class error_injection_seq extends afifo_base_seq;
    `uvm_object_utils(error_injection_seq)
    
    rand error_t err_target;
    
    function new(string name = "error_injection_seq");
        super.new(name);
    endfunction
    
    task body();
        afifo_txn tx;
        for(int i = 0; i < num_trans; i++) begin
            tx = afifo_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize() with {
                err_type == err_target;
                err_inject == 1;
            });
          `uvm_info("SEQ/PKT", $sformatf("Pushing Err_packet #%0d with Data: 0x%0h for %s", i, tx.wdata, tx.winc ? "WRITE" : "READ"), UVM_MEDIUM)
            finish_item(tx);
        end
    endtask
endclass

//-----------------------------------------------------------------------------
// Data Pattern Sequences
//-----------------------------------------------------------------------------
class walking_one_seq extends afifo_base_seq;
    `uvm_object_utils(walking_one_seq)
    
    function new(string name = "walking_one_seq");
        super.new(name);
    endfunction
    
    task body();
        afifo_txn tx;
        bit [31:0] walk_pattern = 32'h0000_0001;
        
      for(int i = 0; i < 32; i++) begin
            tx = afifo_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize() with {
                op_type == WRITE;
                wdata == walk_pattern;
                err_inject == 0;
            });
        	`uvm_info("SEQ/PKT", $sformatf("Pushing walking 1's packet #%0d with Data: 0x%0h", i, walk_pattern), UVM_MEDIUM)
            finish_item(tx);
            walk_pattern = walk_pattern << 1;
        end
    endtask
endclass
