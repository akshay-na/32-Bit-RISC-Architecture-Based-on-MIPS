`timescale 1ns/1ns

module ID_EX_Reg (clk, rst, Reg_Write_D, MemToReg_D, Mem_Write_D, ALU_Con_D,
                 ALU_Src_D, Reg_Dest_D, RegA_D, RegB_D, Signlmm_D, Rs_D, Rt_D, Rd_D,
                 Reg_Write_E, MemToReg_E, Mem_Write_E, ALU_Con_E, ALU_Src_E,
                 Reg_Dest_E, RegA_E, RegB_E, Signlmm_E, Rs_E, Rt_E, Rd_E, Shamt_D, Shamt_E);

    input clk,rst;
    input Reg_Write_D, MemToReg_D, Mem_Write_D;
    input ALU_Src_D, Reg_Dest_D;
    input [5:0] ALU_Con_D;
    input [4:0] Rs_D, Rt_D, Rd_D, Shamt_D;
    input [31:0] RegA_D, RegB_D, Signlmm_D;

    output reg Reg_Write_E, MemToReg_E, Mem_Write_E;
    output reg ALU_Src_E, Reg_Dest_E;
    output reg [5:0] ALU_Con_E;
    output reg [4:0] Rs_E, Rt_E, Rd_E, Shamt_E;
    output reg [31:0] RegA_E, RegB_E, Signlmm_E;


    always@(posedge clk)
    begin
        if(rst)
            begin
                Reg_Write_E <= 1'b0;
                MemToReg_E <= 1'b0;
                Mem_Write_E <= 1'b0;
                ALU_Src_E <= 1'b0;
                Reg_Dest_E <= 1'b0;
                ALU_Con_E <= 2'b0;
                RegA_E <= 32'b0;
                RegB_E <= 32'b0;
                Signlmm_E <= 32'b0;
                Rs_E <= 5'b0;
                Rt_E <= 5'b0;
                Rd_E <= 5'b0;
            end

            else
            begin
                Reg_Write_E <= Reg_Write_D;
                MemToReg_E <= MemToReg_D;
                Mem_Write_E <= Mem_Write_D;
                ALU_Src_E <= ALU_Src_D;
                Reg_Dest_E <= Reg_Dest_D;
                ALU_Con_E <= ALU_Con_D;
                RegA_E <= RegA_D;
                RegB_E <= RegB_D;
                Signlmm_E <= Signlmm_D;
                Rs_E <= Rs_D;
                Rt_E <= Rt_D;
                Rd_E <= Rd_D;
            end
        end
endmodule