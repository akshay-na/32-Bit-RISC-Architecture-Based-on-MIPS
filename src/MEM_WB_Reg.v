`timescale 1ns/1ns

module MEM_WB_Reg (clk, rst, Reg_Write_M, MemToReg_M, Mem_Read_Data_M,
                    ALU_Out_M, Write_Reg_M, Reg_Write_W, MemToReg_W,
                    Mem_Read_Data_W, ALU_Out_W, Write_Reg_W);

    input clk,rst;
    input Reg_Write_M, MemToReg_M;
    input [4:0] Write_Reg_M;
    input [31:0] ALU_Out_M, Mem_Read_Data_M;

    output reg Reg_Write_W, MemToReg_W;
    output reg [4:0] Write_Reg_W;
    output reg [31:0] ALU_Out_W, Mem_Read_Data_W;

    always@(rst)
        if(rst)
        begin
            Reg_Write_W <= 1'bz;
            MemToReg_W = 1'bz;
            Mem_Read_Data_W <= 32'bz;
            Write_Reg_W <= 5'bz;
            ALU_Out_W <= 32'bz;
        end

    always@(posedge clk)
    begin
        Reg_Write_W <= Reg_Write_M;
        MemToReg_W <= MemToReg_M;
        Mem_Read_Data_W <= Mem_Read_Data_M;
        Write_Reg_W <= Write_Reg_M;
        ALU_Out_W <= ALU_Out_M;
    end

endmodule