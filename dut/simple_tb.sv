`timescale 1ns/1ps

module afifo_tb;
    parameter DSIZE = 8;
    parameter ASIZE = 4;
    parameter DEPTH = 1 << ASIZE;
    
    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg [DSIZE-1:0] wdata;
    reg winc, rinc;
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;
    
    integer write_count = 0;
    integer read_count = 0;
    integer error_count = 0;

    // Instantiate DUT
    afifo #(DSIZE, ASIZE) dut (
        .rdata(rdata),
        .wfull(wfull),
        .rempty(rempty),
        .wdata(wdata),
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rinc(rinc),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // Clock generation
    always #5 wclk = ~wclk;  // 100 MHz write clock
    always #10 rclk = ~rclk; // 50 MHz read clock

    // Main test sequence
    initial begin
        $dumpfile("afifo_tb.vcd");
        $dumpvars(0, afifo_tb);
        
        initialize();
        reset();
        
        test_full_empty();
        test_simultaneous();
        test_random();
        
        $display("\nTest Complete!");
        $display("Errors detected: %0d", error_count);
        $finish;
    end

    task initialize;
        begin
            wclk = 0;
            rclk = 0;
            wdata = 0;
            winc = 0;
            rinc = 0;
            wrst_n = 1;
            rrst_n = 1;
        end
    endtask

    task reset;
        begin
            $display("\nApplying reset...");
            wrst_n = 0;
            rrst_n = 0;
            repeat(2) @(negedge wclk);
            wrst_n = 1;
            rrst_n = 1;
            @(negedge wclk);
        end
    endtask

    task test_full_empty;
        begin
            $display("\nTest 1: Write until full -> read until empty");
            
            // Write to full
            while (!wfull) begin
                @(negedge wclk);
                winc = 1;
                wdata = $random;
                write_count++;
            end
            @(negedge wclk);
            winc = 0;
            $display("FIFO full reached. Wrote %0d items", write_count);
            
            // Read until empty
            while (!rempty) begin
                @(negedge rclk);
                rinc = 1;
                read_count++;
            end
            @(negedge rclk);
            rinc = 0;
            $display("FIFO empty reached. Read %0d items", read_count);
            
            if (write_count != read_count) begin
                error_count++;
                $display("Error: Write/Read count mismatch!");
            end
        end
    endtask

    task test_simultaneous;
        begin
            $display("\nTest 2: Simultaneous read/write");
            write_count = 0;
            read_count = 0;
            
            fork
                // Writer
                begin
                    repeat(20) begin
                        @(negedge wclk);
                        winc = !wfull;
                        wdata = $random;
                        if (winc) write_count++;
                    end
                    winc = 0;
                end
                
                // Reader
                begin
                    repeat(20) begin
                        @(negedge rclk);
                        rinc = !rempty;
                        if (rinc) read_count++;
                    end
                    rinc = 0;
                end
            join
            
            $display("Simultaneous ops completed. Wrote %0d, Read %0d", 
                    write_count, read_count);
        end
    endtask

    task test_random;
        begin
            $display("\nTest 3: Random operations");
            write_count = 0;
            read_count = 0;
            
            fork
                // Random writer
                begin
                    repeat(50) begin
                        @(negedge wclk);
                        winc = ($random % 2) && !wfull;
                        wdata = $random;
                        if (winc) write_count++;
                    end
                end
                
                // Random reader
                begin
                    repeat(50) begin
                        @(negedge rclk);
                        rinc = ($random % 2) && !rempty;
                        if (rinc) read_count++;
                    end
                end
                
                // Data checker
                begin
                    forever begin
                        @(posedge rclk);
                        if (rinc && !rempty) begin
                            if (rdata !== dut.fifomem.mem[dut.rptr_empty.rbin[ASIZE-1:0]]) begin
                                error_count++;
                                $display("Error: Expected %h, Got %h @ %t",
                                        dut.fifomem.mem[dut.rptr_empty.rbin[ASIZE-1:0]], 
                                        rdata, $time);
                            end
                        end
                    end
                end
            join_any
            disable fork;
            
            $display("Random ops completed. Wrote %0d, Read %0d", 
                    write_count, read_count);
        end
    endtask
endmodule
