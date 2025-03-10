`include "uvm_macros.svh"

package afifo_txn_pkg;
import uvm_pkg::*;

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
    rand op_t     op_type;        // Operation type
    rand error_t  err_type;       // Error injection type
    rand bit      err_inject;     // Error enable
    
    rand bit [31:0] wdata;        // Write data
    bit [31:0]      rdata;        // Read data
    
    rand bit      rinc;           // Read enable
    rand bit      winc;           // Write enable
    bit           wfull;          // FIFO full status
    bit           rempty;         // FIFO empty status

    // Constraints for valid control signals
    constraint valid_controls {
        if (!err_inject) {
            (op_type == WRITE) -> winc == 1;
            (op_type == READ)  -> rinc == 1;
        }
    }

    constraint error_constraints {
        err_inject dist {0 :/ 90, 1 :/ 10};
        if (!err_inject) soft err_type == NORMAL;
    }

    // UVM automation
    `uvm_object_utils_begin(afifo_txn)
        `uvm_field_enum(op_t, op_type, UVM_ALL_ON)
        `uvm_field_enum(error_t, err_type, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(winc, UVM_ALL_ON)
        `uvm_field_int(rinc, UVM_ALL_ON)
        `uvm_field_int(wfull, UVM_ALL_ON)
        `uvm_field_int(rempty, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "afifo_txn");
        super.new(name);
    endfunction

    // Compare critical fields
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        afifo_txn rhs_;
        return $cast(rhs_, rhs) && 
               (op_type === rhs_.op_type) &&
               (wdata   === rhs_.wdata) &&
               (rdata   === rhs_.rdata);
    endfunction

    // Error injection logic
    function void post_randomize();
        if (err_inject) begin
            case(err_type)
                OVERFLOW:       winc = 1'b1;  // Force write when full
                UNDERFLOW:      rinc = 1'b1;  // Force read when empty
                DATA_CORRUPTION: wdata ^= 32'hFFFF_FFFF;
            endcase
        end
    endfunction

    // Clear status indicators
    function void clear_status();
        wfull  = 0;
        rempty = 0;
    endfunction

    // Transaction summary
    function string convert2string();
        return $sformatf("%s: %s | winc=%b, rinc=%b | wfull=%b, rempty=%b | WDATA=0x%08h RDATA=0x%08h",
                        err_type.name(),
                        op_type.name(),
                        winc, rinc,
                        wfull, rempty,
                        wdata, rdata);
    endfunction
endclass

endpackage
