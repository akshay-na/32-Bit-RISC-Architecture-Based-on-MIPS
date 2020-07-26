`timescale 1ns/1ns

module Adder(add_a, add_b, add_out);

    input [31:0] add_a, add_b;
    wire [32:0] w;
    output [31:0] add_out;  
    genvar i;

    assign w[0] = 0;

    generate 
        for(i=0;i<32;i=i+1)
        begin: adder
            FA FA_inst(add_a[i], add_b[i], w[i], w[i+1], add_out[i]);
        end
    endgenerate

endmodule 

module FA(input a, input b,input cin, output cout, output s);

    assign {cout,s} = a+b+cin;
	 
endmodule 