`timescale 1ns/1ns

module EX_MEM_Reg (clk, rst, Reg_Write_E, MemToReg_E, Mem_Write_E, ALU_Out_E,
                    Write_Data_E, Write_Reg_E, Reg_Write_M, MemToReg_M, Mem_Write_M,
                    ALU_Out_M, Write_Data_M, Write_Reg_M);

    input clk,rst;
    input Reg_Write_E, MemToReg_E, Mem_Write_E;
    input [31:0] ALU_Out_E, Write_Data_E;
    input [4:0] Write_Reg_E;

    output reg Reg_Write_M, MemToReg_M, Mem_Write_M;
    output reg [31:0] ALU_Out_M, Write_Data_M;
    output reg [4:0] Write_Reg_M;

    always@(posedge clk)
    begin
        if(rst)
        begin
            Reg_Write_M <= 1'bz;
            MemToReg_M <= 1'bz;
            Mem_Write_M <= 1'bz;
            ALU_Out_M <= 32'bz;
            Write_Data_M <= 32'bz;
            Write_Reg_M <= 5'bz;
        end    
    
        else
        begin
            Reg_Write_M <= Reg_Write_E;
            MemToReg_M <= MemToReg_E;
            Mem_Write_M <= Mem_Write_E;
            ALU_Out_M <= ALU_Out_E;
            Write_Data_M <= Write_Data_E;
            Write_Reg_M <= Write_Reg_E;
        end
    end


endmodule