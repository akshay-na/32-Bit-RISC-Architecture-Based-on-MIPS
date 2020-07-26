`timescale 1ns/1ns

module MUX3_to_1_32bit (mux_in1, mux_in2, mux_in3, mux_out, select);

    parameter bit_width = 32;

    input [bit_width-1:0] mux_in1,mux_in2, mux_in3;
    output reg  [bit_width-1:0] mux_out;
    input [1:0] select;

    always@(*)
    begin
        case(select)
            2'b00: mux_out <= mux_in1;
            2'b01: mux_out <= mux_in2;
            2'b10: mux_out <= mux_in3;
            default: mux_out <= 32'bz;
        endcase
    end

endmodule 