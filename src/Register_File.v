`timescale 1ns/1ns

/* Reg 0-7 normal register
   Reg 8-15 Floating register */


module Register_File(clk, rst, en_write, read_add1, read_add2, read_data1, read_data2, write_add, write_data);

    input en_write, clk, rst;
    input [4:0] read_add2, read_add1, write_add;
//  input [4:0] read_addf2, read_addf1, write_addf;
    input [31:0] write_data;
    output reg [31:0] read_data1, read_data2;
    

    //Register file storage
    reg [31:0] reg_mem [31:0];
//  reg [31:0] reg_memf [31:0];
    integer i;

    initial
        for (i=0;i<32;i=i+1)
            reg_mem[i] = 32'b0;

    //Read and write from register file 
    always@(negedge clk)
    begin

        if(rst == 1)
            for (i=0; i<32; i=i+1)
                reg_mem[i] = 32'b0;

        else
        begin
        
        //Address 1
        if(read_add1 == 0)
            read_data1 = 32'b0;
        
        else if((read_add1 == write_add) && en_write)
            read_data1 = write_data;

        else
            read_data1 = reg_mem[read_add1] [31:0];

        //Address 2
        if(read_add2 == 0)
            read_data2 = 32'b0;
        
        else if((read_add2 == write_add) && en_write)
            read_data2 = write_data;

        else
            read_data2  = reg_mem[read_add2] [31:0];

       //Write data
        if(en_write && write_add != 0)
            reg_mem[write_add] = write_data;

        end
    
    end
    
endmodule