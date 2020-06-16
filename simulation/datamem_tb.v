`timescale 1ns/1ps

`include "Data_Mem.v"

module datamem_tb ();

	reg clk, en_write;
    reg [31:0] data_add, Data_in;

    wire [31:0] data_out;

    Data_Mem tb(clk, Data_in, data_add, en_write, data_out);

    initial
    begin 
    	clk = 1'b0;
    repeat(5000) #5 clk	= ~clk;
    end

    initial
    begin
    	#10 data_add = 32'd4;
    	#10 data_add = 32'd2;
    	#10 en_write = 1'b1;
    	#10 data_add = 32'd10;
    	#10 Data_in = 32'd500;
    	#10 en_write = 1'b0;
    	#10 data_add = 32'd10;
    end



endmodule