`timescale 1ns/1ns

module Data_Mem(clk, Data_in, data_add, en_write, data_out);

    parameter MEM_WIDTH = 65534;

    input clk, en_write;
    input [31:0] data_add, Data_in;
    output reg [31:0] data_out;

    reg [31:0] Mem [MEM_WIDTH-1:0];

    integer i;

    initial 
        $readmemb("data_mem.txt", Mem, 0, MEM_WIDTH-1);
        

    always@(negedge clk)
    begin

        if(en_write)
            Mem[data_add] <= Data_in;
        else
            data_out <= Mem[data_add];

     //   $writememb("data_mem.txt", Mem);
    end


endmodule