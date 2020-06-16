`timescale 1ns/1ns

module MUX2_to_1_5bit (mux_in1, mux_in2, mux_out, select);

    parameter bit_width = 5;

    input [bit_width-1:0] mux_in1,mux_in2;
    output reg  [bit_width-1:0] mux_out;
    input select;

    always@(*)
    begin
        case(select)
            1'b0: mux_out <= mux_in1;
            1'b1: mux_out <= mux_in2;
            default: mux_out <= 5'bz;
        endcase
    end

endmodule 