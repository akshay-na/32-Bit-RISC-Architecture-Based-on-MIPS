`timescale 1ns/1ns

module Sign_Extender (sign_in, sign_out);

    input [15:0] sign_in;
    output reg [31:0] sign_out;
    integer i;

    always@(sign_in)
        begin

            sign_out[15:0] = sign_in[15:0];

            for (i = 16 ; i < 32 ; i = i+1 ) 
                sign_out[i] = sign_in[15];
        end

endmodule