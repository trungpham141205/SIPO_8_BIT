`timescale 1ns/1ps


module flipflopD (
    input  logic clk,
    input  logic rstn,
    input  logic d,
    output logic q
);

    logic timing_notifier;


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            q <= 1'b0;
        else
            q <= d;
    end


    specify

        specparam T_CLK_Q_RISE = 1.5,
                  T_CLK_Q_FALL = 1.5,

                  T_RESET_Q    = 1.0,

                  T_SETUP_D    = 2.0,
                  T_HOLD_D     = 1.0,

                  T_RECOVERY   = 2.0,
                  T_REMOVAL    = 1.0;

        (posedge clk => (q +: d)) = (
            T_CLK_Q_RISE,
            T_CLK_Q_FALL
        );

        (negedge rstn => (q +: 1'b0)) = (
            T_RESET_Q,
            T_RESET_Q
        );

        $setuphold(
            posedge clk &&& rstn,
            posedge d,
            T_SETUP_D,
            T_HOLD_D,
            timing_notifier
        );

        $setuphold(
            posedge clk &&& rstn,
            negedge d,
            T_SETUP_D,
            T_HOLD_D,
            timing_notifier
        );

        $recrem(
            posedge rstn,
            posedge clk,
            T_RECOVERY,
            T_REMOVAL,
            timing_notifier
        );

    endspecify

endmodule
