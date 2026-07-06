`timescale 1ns/1ps

module sipo8bit_tb_no_violation;

    logic       clk;
    logic       rstn;
    logic       serial_in;
    logic [7:0] parallel_out;

    logic [7:0] expected_parallel_out;

    integer pass_count;
    integer fail_count;

    //============================================================
    // DUT
    //============================================================
    sipo8bit dut (
        .clk          (clk),
        .rstn         (rstn),
        .serial_in    (serial_in),
        .parallel_out (parallel_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic check_output (
        input string      test_name,
        input logic [7:0] expected_value
    );
        begin
            if (parallel_out === expected_value) begin
                pass_count++;

                $display(
                    "[%s PASS] Time=%0t Expected=%b Actual=%b",
                    test_name,
                    $time,
                    expected_value,
                    parallel_out
                );
            end
            else begin
                fail_count++;

                $display(
                    "[%s FAIL] Time=%0t Expected=%b Actual=%b",
                    test_name,
                    $time,
                    expected_value,
                    parallel_out
                );
            end
        end
    endtask

    task automatic shift_bit_safe (
        input logic  bit_value,
        input string test_name
    );
        begin
            @(negedge clk);

            serial_in = bit_value;

            expected_parallel_out = {
                expected_parallel_out[6:0],
                bit_value
            };

            @(posedge clk);

            // Clock-to-Q = 1.5 ns.
            #2;

            check_output(
                test_name,
                expected_parallel_out
            );
        end
    endtask

    initial begin

        $dumpfile("sipo8bit_no_violation.vcd");
        $dumpvars(0, sipo8bit_tb_no_violation);

        $timeformat(-9, 3, " ns", 10);

        pass_count = 0;
        fail_count = 0;

        rstn      = 1'b0;
        serial_in = 1'b0;

        expected_parallel_out = 8'b0000_0000;

        $display("================================================");
        $display("       SIPO 8-BIT NO-VIOLATION TEST");
        $display("================================================");

        #2;

        check_output(
            "R01 INITIAL ASYNC RESET",
            8'b0000_0000
        );

        @(negedge clk);
        rstn = 1'b1;

        @(posedge clk);
        #2;

        check_output(
            "R02 SAFE RESET RELEASE",
            8'b0000_0000
        );

        shift_bit_safe(1'b1, "T01 SHIFT 1");
        shift_bit_safe(1'b0, "T02 SHIFT 0");
        shift_bit_safe(1'b1, "T03 SHIFT 1");
        shift_bit_safe(1'b1, "T04 SHIFT 1");
        shift_bit_safe(1'b0, "T05 SHIFT 0");
        shift_bit_safe(1'b0, "T06 SHIFT 0");
        shift_bit_safe(1'b1, "T07 SHIFT 1");
        shift_bit_safe(1'b0, "T08 SHIFT 0");

        check_output(
            "T09 FINAL PARALLEL OUTPUT",
            8'b1011_0010
        );

        @(negedge clk);
        #2;

        rstn = 1'b0;


        expected_parallel_out = 8'b0000_0000;

        check_output(
            "R03 ASYNC RESET DURING OPERATION",
            expected_parallel_out
        );

        @(negedge clk);
        rstn = 1'b1;

        @(posedge clk);
        #2;

        check_output(
            "R04 SECOND SAFE RESET RELEASE",
            8'b0000_0000
        );

        shift_bit_safe(
            1'b1,
            "T10 SHIFT AFTER RESET"
        );

        $display("================================================");
        $display("                TEST SUMMARY");
        $display("================================================");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILED");

        $display("================================================");

        #5;
        $finish;
    end

endmodule

