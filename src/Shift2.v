`timescale 1ns/1ns

module Shift2 (Data_in, Data_out);

    input [31:0] Data_in;
    output reg [31:0] Data_out;

    always@(Data_in)
        Data_out <= Data_in << 2;

endmodule