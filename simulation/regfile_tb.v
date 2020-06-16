`timescale 1ns/1ns

`include "Register_File.v"

module regfile_tb ();

	reg clk,en_write, rst;
	reg [4:0] read_add2, read_add1, write_add;
    reg [31:0] write_data;

    wire [31:0] read_data1, read_data2;

     Register_File reg_sim(clk, rst, en_write, read_add1, read_add2, read_data1, read_data2, write_add, write_data);

    initial
    begin

    	#5 en_write = 1'b1;

    	write_add = 5'd10;
    	write_data = 32'd101;

    	#10 write_add = 5'd11;
    	write_data = 32'd200;

    	#50 en_write = 1'b0;
    	read_add1 = 5'd10;
    	read_add2 = 5'd11;

    	#50 rst = 1'b1;

    	$finish;

    end

   

endmodule