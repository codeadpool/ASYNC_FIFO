//==========================================================================================
// Base class
//==========================================================================================
class afifo_vseq_base extends uvm_sequence;
  `uvm_object_utils(afifo_vseq_base)
  
  uvm_sequencer#(afifo_txn) wr_seqr; // Write sequencer handle
  uvm_sequencer#(afifo_txn) rd_seqr; // Read sequencer handle
  int max_depth;

  function new(string name = "afifo_vseq_base");
    super.new(name);
  endfunction

  virtual task pre_body();
    // Fetch sequencers from config_db
    if (!uvm_config_db#(uvm_sequencer#(afifo_txn))::get(null, "*.vseq*", "wr_seqr", wr_seqr))
      `uvm_fatal("VSEQ/CFG_ERR", "Couldn't retrieve WR_SEQR from uvm_config_DB")
      if (!uvm_config_db#(uvm_sequencer#(afifo_txn))::get(null, "*.vseq*", "rd_seqr", rd_seqr))
        `uvm_fatal("VSEQ/CFG_ERR", "Couldln't retrieve RD_SEQR from uvm_config_dB")
      
    if(!uvm_config_db#(int)::get(null, "", "max_depth", max_depth))
      `uvm_fatal("VSEQ/CFG_ERR", "Couldn't retrieve MAX DEPTH from uvm_config_db")
  endtask
endclass

      
//==========================================================================================
// Sanity check
//==========================================================================================
class sanity_check_vseq extends afifo_vseq_base;
  `uvm_object_utils(sanity_check_vseq)
  
  function new(string name = "sanity_check_vseq");
    super.new(name);
  endfunction
  
  task body();
    simple_write_seq wr_seq;
    simple_read_seq rd_seq;
    `uvm_info("VSEQ/START", "Creating the Virtual Sequence", UVM_MEDIUM)
    
    // Fill half then read
    wr_seq = simple_write_seq::type_id::create("wr_seq");
    wr_seq.num_trans = max_depth/2;
    wr_seq.start(wr_seqr);

    rd_seq = simple_read_seq::type_id::create("rd_seq");
    rd_seq.num_trans = max_depth/2;
    rd_seq.start(rd_seqr); 
    
    `uvm_info("VSEQ/STOP", "Ending the Vritual Sequenece", UVM_MEDIUM)
  endtask
endclass 
            
class stress_test_vseq extends afifo_vseq_base;
  `uvm_object_utils(stress_test_vseq)
  
  function new(string name = "stress_test_vseq");
    super.new(name);
  endfunction
  
  task body();
    fork
      begin
        simple_write_seq wr_seq;
        
        wr_seq = simple_write_seq::type_id::create("wr_seq");
        wr_seq.num_trans = max_depth;
        wr_seq.start(wr_seqr);    
      end
      begin
        simple_read_seq rd_seq;
        
        rd_seq = simple_read_seq::type_id::create("rd_seq");
        rd_seq.num_trans = max_depth;
        rd_seq.start(rd_seqr);
      end
    join
  endtask
endclass
       
class error_test_vseq extends afifo_vseq_base;
  `uvm_object_utils(error_test_vseq)
  
  function new(string name = "error_test_vseq");
    super.new(name);
  endfunction
  
  task body();
    error_injection_seq overflow_seq;
    error_injection_seq underflow_seq;
    
    // Test overflow
    overflow_seq = error_injection_seq::type_id::create("overflow_seq");
    overflow_seq.num_trans = max_depth+5;
    overflow_seq.err_target = OVERFLOW;
    overflow_seq.start(wr_seqr);
    
    // Test underflow
    underflow_seq = error_injection_seq::type_id::create("underflow_seq");
    underflow_seq.num_trans = max_depth+10;
    underflow_seq.err_target = UNDERFLOW;
    underflow_seq.start(rd_seqr); 
  endtask
endclass
    
    
class full_coverage_vseq extends afifo_vseq_base;
  `uvm_object_utils(full_coverage_vseq)
  
  function new(string name = "full_coverage_vseq");
    super.new(name);
  endfunction
  
  task body();
    fifo_full_seq fseq;
    fifo_empty_seq eseq;
    walking_one_seq wseq;
    
    // Corner cases
    fseq = fifo_full_seq::type_id::create("fseq");
   	fseq.num_trans = max_depth;
    fseq.start(wr_seqr); 
    
    eseq = fifo_empty_seq::type_id::create("eseq");
    eseq.num_trans = max_depth;
    eseq.start(rd_seqr);
    
    wseq = walking_one_seq::type_id::create("wseq");
    wseq.num_trans = max_depth;
    wseq.start(wr_seqr); 
    
    // Data patterns
//     repeat(3) begin
//       stress_test_vseq stseq;
//       stseq = stress_test_vseq::type_id::create("stseq");
//       stseq.start(null); 
//     end
  endtask
endclass
