`ifndef AFIFO_TXN_SV
`define AFIFO_TXN_SV

typedef enum bit [1:0] {
  NORMAL,
  OVERFLOW,
  UNDERFLOW,
  DATA_CORRUPTION
} error_t;

typedef enum bit {
  WRITE,
  READ
} op_t;

class afifo_txn extends uvm_sequence_item;
    rand op_t              op_type;        // Operation type
    rand error_t           err_type;       // Error injection type
    rand bit               err_inject;     // Error injection control
  
    rand bit [31:0]        wdata;          // Write data
    bit [31:0]             rdata;          // Read data
  
    rand int               delay;          // Cycle delay between operations
    bit                    wfull;          // FIFO full status
    bit                    rempty;         // FIFO empty status
    time                   timestamp;      // Transaction timestamp
    int                    trans_id;       // Unique transaction ID
    bit                    status;         // 0 = fail, 1 = pass
  	bit 				           rinc;
  	bit 				           winc;

    // Control knobs
    rand bit simultaneous_ops;  // Allow simultaneous read/write
    rand bit back_pressure;     // Random back-pressure simulation

    // Constraints
    constraint valid_control {
        if (!simultaneous_ops) {
            if (op_type == WRITE) soft rinc == 0;
            if (op_type == READ)  soft winc == 0;
        }
    }

    constraint reasonable_delay {
        delay inside {[0:5]};
    }

    constraint error_constraints {
        err_inject dist {0 := 90, 1 := 10};
        if (!err_inject) soft err_type == NORMAL;
    }

    // UVM Field Macros
    `uvm_object_utils_begin(afifo_txn)
        `uvm_field_enum(op_t, op_type, UVM_ALL_ON)
        `uvm_field_enum(error_t, err_type, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(delay, UVM_ALL_ON)
        `uvm_field_int(wfull, UVM_ALL_ON)
        `uvm_field_int(rempty, UVM_ALL_ON)
        `uvm_field_int(trans_id, UVM_ALL_ON)
        `uvm_field_int(status, UVM_ALL_ON)
    `uvm_object_utils_end

    static int trans_count = 0;

    function new(string name = "afifo_txn");
        super.new(name);

        trans_id = trans_count++;
        timestamp = $time;
        status = 1;  // Default to pass
    endfunction

    // Copy function
    function void do_copy(uvm_object rhs);
        afifo_txn rhs_;
        if (!$cast(rhs_, rhs)) begin
            `uvm_fatal("CAST_FAIL", "Copy failed: wrong type")
        end
        op_type    = rhs_.op_type;
        err_type   = rhs_.err_type;
        wdata      = rhs_.wdata;
        rdata      = rhs_.rdata;
        delay      = rhs_.delay;
        wfull      = rhs_.wfull;
        rempty     = rhs_.rempty;
        trans_id   = rhs_.trans_id;
        status     = rhs_.status;
    endfunction

    // Compare function
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        afifo_txn rhs_;
        bit status = 1;
      	if (!$cast(rhs_, rhs)) return 0;
        
        status &= (op_type === rhs_.op_type);
        status &= (wdata   === rhs_.wdata);
        status &= (rdata   === rhs_.rdata);
        status &= (status  === rhs_.status);
        return status;
    endfunction

    // Pretty-print function
    function string convert2string();
        string s = $sformatf("Transaction ID: %0d\n", trans_id);
        s = $sformatf("%sOperation Type: %s\n", s, op_type.name());
        s = $sformatf("%sError Type: %s\n", s, err_type.name());
        s = $sformatf("%sWrite Data: 0x%0h\n", s, wdata);
        s = $sformatf("%sRead Data: 0x%0h\n", s, rdata);
        s = $sformatf("%sDelay: %0d cycles\n", s, delay);
        s = $sformatf("%sStatus: %s\n", s, status ? "PASS" : "FAIL");
        return s;
    endfunction

    // Post randomization for error injection
    function void post_randomize();
        if (err_inject) begin
            case(err_type)
                OVERFLOW:       inject_overflow();
                UNDERFLOW:      inject_underflow();
                DATA_CORRUPTION: inject_data_corruption();
            endcase
        end
    endfunction

    // Error injection methods
    local function void inject_overflow();
        wdata = $urandom_range(32'hFFFF_FFFF, 32'h0000_0000);
        winc = 1'b1;
        delay = 0;
    endfunction

    local function void inject_underflow();
        rinc = 1'b1;
        delay = 0;
    endfunction

    local function void inject_data_corruption();
        wdata[7:0] = $urandom();
    endfunction
endclass

`endif
