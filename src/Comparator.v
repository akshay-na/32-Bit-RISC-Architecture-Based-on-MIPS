`timescale 1ns/1ns

module Comparator (comp_in1, comp_in2, comp_out);

    input [31:0] comp_in1, comp_in2;
    output reg comp_out;

    always@(*)
    begin

        if(comp_in1 == comp_in2)
            comp_out <= 1'b1;
        else
            comp_out <= 1'b0;
    end

endmodule