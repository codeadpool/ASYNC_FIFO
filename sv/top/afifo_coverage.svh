`ifndef AFIFO_COVERAGE_SVH
`define AFIFO_COVERAGE_SVH

class afifo_coverage #(type T = afifo_txn) extends uvm_component;
    `uvm_component_param_utils(afifo_coverage#(T))
    T t;

    // Configuration and state tracking
    int max_depth;                        // Maximum FIFO depth from config
    bit [DATA_WIDTH-1:0] prev_wdata = 0;  // Last successful write data
    bit [DATA_WIDTH-1:0] prev_rdata = 0;  // Last successful read data
    op_t prev_txn_type;                   // Track consecutive operations

    // Covergroups
    covergroup cg_write with function sample(bit full, bit [DATA_WIDTH-1:0] wdata, int fill_level);
        cp_full: coverpoint full {
            bins full     = {1};
            bins not_full = {0};
        }
        cp_wdata: coverpoint wdata {
            bins all_0 = {0};
            bins all_1 = {{DATA_WIDTH{1'b1}}};
        }
        cp_fill_level: coverpoint fill_level {
            bins empty = {0};
          	bins mid   = {[max_depth-1:1]};
            bins full  = {max_depth};
        }
        cross_write_full_fill: cross cp_full, cp_fill_level;
    endgroup

    covergroup cg_read with function sample(bit empty, bit [DATA_WIDTH-1:0] rdata, int fill_level);
        cp_empty: coverpoint empty {
            bins empty     = {1};
            bins not_empty = {0};
        }
        cp_rdata: coverpoint rdata {
            bins all_0 = {0};
            bins all_1 = {{DATA_WIDTH{1'b1}}};
        }
        cp_fill_level: coverpoint fill_level {
            bins empty = {0};
          	bins mid   = {[max_depth-1:1]};
            bins full  = {max_depth};
        }
        cross_read_empty_fill: cross cp_empty, cp_fill_level;
    endgroup

    covergroup cg_fifo_transitions with function sample(int prev, int curr);
        cp_transitions: coverpoint (curr - prev) {
            bins incr      = {1};
            bins decr      = {-1};
            bins no_change = {0};
            illegal_bins invalid = default;
        }
        cp_state_trans: coverpoint (curr) {
            bins empty = {0};
            bins full  = {max_depth};
            bins mid   = default;
        }
    endgroup

    covergroup cg_consecutive_ops with function sample(op_t prev, op_t curr);
        cp_sequence: coverpoint (prev) {
            bins write_write = (WRITE => WRITE);
            bins write_read  = (WRITE => READ);
            bins read_write  = (READ => WRITE);
            bins read_read   = (READ => READ);
//             bins initial_op   = (NONE => WRITE), (NONE => READ);
        }
    endgroup

//     covergroup cg_data_transitions with function sample(bit [DATA_WIDTH-1:0] prev, bit [DATA_WIDTH-1:0] curr);
//         option.per_instance = 1;
//         option.comment     = "Bit-level and word-level data transitions";

//         // Bit-level transition coverage
//         foreach (curr[i]) begin: bit_cov
//             transition: coverpoint curr[i] {
//                 bins t0_1 = (0 => 1);
//                 bins t1_0 = (1 => 0);
//             }
//         end

//         // Word-level transition coverage
//         word_transition: coverpoint (curr - prev) {
//             bins no_change    = {0};
//             bins single_bit   = {1, -1};
//             bins multiple_bits = {[2:$], [-2:-$]};
//         }
//     endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_write            = new();
        cg_read             = new();
        cg_fifo_transitions = new();
        cg_consecutive_ops  = new();
//         cg_data_transitions = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      	if (!uvm_config_db#(int)::get(this, "", "max_depth", max_depth))
            `uvm_fatal("COV_CFG", "Failed to get FIFO depth")
    endfunction

    int prev_fifo_count = 0;

    function void sample(T t, int current_fill_level);
      	case (t.op_type)
            WRITE: begin
                if (!t.wfull && current_fill_level < max_depth) begin
//                     cg_data_transitions.sample(prev_wdata, t.wdata);
                    prev_wdata = t.wdata;
                end
              cg_write.sample(t.wfull, t.wdata, current_fill_level);
            end
            READ: begin
                if (!t.rempty && current_fill_level > 0) begin
//                     cg_data_transitions.sample(prev_rdata, t.rdata);
                    prev_rdata = t.rdata;
                end
              cg_read.sample(t.rempty, t.rdata, current_fill_level);
            end
        endcase

        // Track FIFO state transitions
        cg_fifo_transitions.sample(prev_fifo_count, current_fill_level);
        prev_fifo_count = current_fill_level;

        // Track operation sequences
      	cg_consecutive_ops.sample(prev_txn_type, t.op_type);
        prev_txn_type = t.op_type;
    endfunction
endclass

`endif
