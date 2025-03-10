`ifndef AFIFO_SCOREBOARD_SVH
`define AFIFO_SCOREBOARD_SVH

`uvm_analysis_imp_decl(_write)
`uvm_analysis_imp_decl(_read)

class afifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(afifo_scoreboard)

  uvm_analysis_imp_write #(afifo_txn, afifo_scoreboard) wr_imp;
  uvm_analysis_imp_read  #(afifo_txn, afifo_scoreboard) rd_imp;
  afifo_coverage #(afifo_txn) cov;

  // Storage & Config
  int max_fifo_depth;
  bit [DATA_WIDTH-1:0] write_queue[$]; 

  // Stats
  int num_writes        = 0;
  int num_reads         = 0;
  int num_matches       = 0;
  int num_mismatches    = 0;
  int num_overflows     = 0;
  int num_underflows    = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
    
    if (!uvm_config_db#(int)::get(this, "", "max_depth", max_fifo_depth))
      `uvm_fatal("SCB/CFG_ERR", "Failed to get FIFO depth")
    
    cov = afifo_coverage#(afifo_txn)::type_id::create("cov", this);
  endfunction

  function void write_write(afifo_txn tr);
    // Handle write transaction
    if (!tr.wfull) begin
      if (write_queue.size() >= max_fifo_depth) begin
        `uvm_error("SCB/WR_OVFL", $sformatf("Overflow: Attempted write to wfull FIFO. Data: 0x%0h", tr.wdata))
        num_overflows++;
      end
      else begin
        write_queue.push_back(tr.wdata);
        num_writes++;
        `uvm_info("SCB/WR_SUCC", $sformatf("Stored data: 0x%0h", tr.wdata), UVM_MEDIUM)
      end
    end
    else begin
     `uvm_error("SCB/WR_IGN", "Write attempt ignored (FIFO wfull)")
    end
    
    cov.sample(tr, write_queue.size());
  endfunction

  function void write_read(afifo_txn tr);
    // Handle read transaction
    if (!tr.rempty) begin
      num_reads++;
      if (write_queue.size() == 0) begin
        `uvm_error("SCB/UNDFL", $sformatf("Underflow: Read from empty FIFO. Got: 0x%0h", tr.rdata))
        num_underflows++;
      end
      else begin
        bit [DATA_WIDTH-1:0] expected = write_queue.pop_front();
        
        // Data width sanity check
        if ($bits(tr.rdata) != DATA_WIDTH) begin
          `uvm_error("SCB/WIDTH", $sformatf("Data width mismatch! Exp: %0d, Act: %0d",
            DATA_WIDTH, $bits(tr.rdata)))
        end
        
        if (tr.rdata !== expected) begin
          `uvm_error("SCB/MISMTCH", $sformatf("Data mismatch!\nExp: 0x%0h\nAct: 0x%0h", 
            expected, tr.rdata))
          num_mismatches++;
        end
        else begin
          `uvm_info("SCB/MATCH", $sformatf("Data match: 0x%0h", tr.rdata), UVM_MEDIUM)
          num_matches++;
        end
      end
    end
    else begin
      `uvm_info("SCB/RDIGN", "Read attempt ignored (FIFO empty)", UVM_MEDIUM)
    end
    
    cov.sample(tr, write_queue.size());
  endfunction
  
  function void report_phase(uvm_phase phase);
    string report = "\n\n--- ASYNC FIFO SCOREBOARD REPORT ---\n";
    report = {report, $sformatf("Total Writes:          %0d\n", num_writes)};
    report = {report, $sformatf("Total Reads:           %0d\n", num_reads)};
    report = {report, $sformatf("Successful Matches:    %0d\n", num_matches)};
    report = {report, $sformatf("Data Mismatches:       %0d\n", num_mismatches)};
    report = {report, $sformatf("FIFO Overflows:        %0d\n", num_overflows)};
    report = {report, $sformatf("FIFO Underflows:       %0d\n", num_underflows)};
    report = {report, "-----------------------------------\n"};
    `uvm_info("SCB/REPORT", report, UVM_LOW)
  endfunction
endclass

`endif
