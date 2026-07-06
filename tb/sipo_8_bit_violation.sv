
`timescale 1ns/1ps

module sipo8bit_tb_violation;

    logic       clk;
    logic       rstn;
    logic       serial_in;
    logic [7:0] parallel_out;

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

    initial begin
        $monitor(
            "Time=%0t clk=%b rstn=%b serial_in=%b parallel_out=%b",
            $time,
            clk,
            rstn,
            serial_in,
            parallel_out
        );
    end

    initial begin

        $dumpfile("sipo8bit_violation.vcd");
        $dumpvars(0, sipo8bit_tb_violation);

        $timeformat(-9, 3, " ns", 10);

        rstn      = 1'b0;
        serial_in = 1'b0;

        $display("================================================");
        $display("        SIPO 8-BIT TIMING VIOLATION TEST");
        $display("================================================");

        #2;

        $display(
            "[RESET] parallel_out=%b",
            parallel_out
        );

        @(negedge clk);
        rstn = 1'b1;

        @(posedge clk);
        #2;

        @(negedge clk);

        #4;
        serial_in = 1'b1;

        $display(
            "[V01 SETUP-D] serial_in changed at %0t",
            $time
        );

        @(posedge clk);
        #2;

        @(negedge clk);
        serial_in = 1'b0;

        @(posedge clk);

        #0.5;
        serial_in = 1'b1;

        $display(
            "[V02 HOLD-D] serial_in changed at %0t",
            $time
        );

        #2;

        @(negedge clk);

        serial_in = 1'b0;
        rstn      = 1'b0;

        $display(
            "[RESET] rstn asserted at %0t",
            $time
        );

        #2;

        @(negedge clk);

        #4;
        rstn = 1'b1;

        $display(
            "[V03 RECOVERY] rstn released at %0t",
            $time
        );

        @(posedge clk);
        #2;

        @(negedge clk);
        rstn = 1'b0;

        $display(
            "[RESET] rstn asserted again at %0t",
            $time
        );

        @(posedge clk);

        #0.5;
        rstn = 1'b1;

        $display(
            "[V04 REMOVAL] rstn released at %0t",
            $time
        );

        @(posedge clk);
        #2;

        $display("Expected timing reports:");
        $display("1. serial_in setup violation at FF0");
        $display("2. serial_in hold violation at FF0");
        $display("3. rstn recovery violation at all flip-flops");
        $display("4. rstn removal violation at all flip-flops");
        $display("================================================");

        #5;
        $finish;
    end

endmodule

