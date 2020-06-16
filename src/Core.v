`timescale 1ns/1ns

`include "Adder.v"
`include "Comparator.v"
`include "ALU_Module.v" 
`include "Control_Module.v"  
`include "Data_Mem.v"
`include "EX_MEM_Reg.v" 
//`include "Float_to_Binary_Converter_Module.v" // Need to integrate
`include "Hazard_Unit.v" 	
`include "ID_EX_Reg.v"
`include "IF_ID_Reg.v"
`include "Instruction_Memory.v" 
`include "MEM_WB_Reg.v"
`include "MUX2_to_1_5bit.v"
`include "MUX2_to_1_32bit.v"
`include "MUX3_to_1_32bit.v"
`include "Program_Counter.v"
`include "Register_File.v"
`include "Shift2.v"
`include "Sign_Extender.v"
`include "and1.v"
//`include "ROM.v"
//`include "RAM.v"


module Core (clk, rst);

    input clk, rst;

    // Instruction_Fetch_Stage   (IF_Stage_1) Wires:
    wire [31:0] PC_in, PC_out, PCPlus4_F;           //PC_Signal;
    wire [31:0] Instruction_F;                      // Instruction_Mem_Out
    wire Stall_F;                                   // Hazard_Signal

    // Instruction_Decode_stage  (ID_Stage_2) Wires;
    wire [31:0] PCBranch_D, PCPlus4_D, Signlmm_D, Shift_D;                   //PC,Shifter & SX_Signals
    wire [31:0] Instruction_D;                                               //Decoded_Instrucations
    wire [31:0] Reg_A_D, Reg_B_D;                                            //RF_read_Data 
    wire [31:0] Comp_A, Comp_B;                                              //Comparator_inputs
    wire [5:0]  ALU_Con_D; 
    wire [4:0]  Shamt_D;                                                  //Controller_Signal
    wire Equa_D, Reg_Write_D, MemToReg_D, Mem_Write_D, ALU_Src_D;            //Controller_Signals
    wire Reg_Dest_D, Branch_D, PCSrc_D;                                      //Controller_Signals
    wire Forward_A_D, Forward_B_D;                                           //Hazard_Signal

    // Execution_Stage   (EX_Stage_3) Wires:
    wire Reg_Write_E, MemToReg_E, Mem_Write_E, ALU_Src_E, Reg_Dest_E;       //Controller_Signals
    wire [5:0] ALU_Con_E;                                                   //Controller_Signal
    wire [4:0] Write_Reg_E, Shamt_E;                                                 //Write_Reg_Address
    wire [31:0] Reg_A_E, Reg_B_E;                                           //RF_read_Data 
    wire [31:0] Signlmm_E;                                                  //Sign_Extended_Signal
    wire [4:0] Rs_E, Rt_E;                                                  //Source & Target Reg Address 
    wire [31:0] Src_A_E, Src_B_E, Write_Data_E, ALU_Out_E;                  //ALU_Signals & SW_Data
    wire [1:0] Forward_A_E, Forward_B_E;                                    //Hazard_Signal

    // ID_EX_Reg Wire
    wire Flush;

    // Memory_Stage  (MEM_Stage_4) Wires:
    wire  Reg_Write_M, MemToReg_M, Mem_Write_M;                         //Controller_Signal
    wire [31:0] ALU_Out_M, Write_Data_M, Read_Data_M;                   //Data_Signals
    wire [4:0] Write_Reg_M;                                             //Data_Mem_Address

    // Write_Back_Stage  (WB_Stage_5) Wires:
    wire [4:0] Write_Reg_W;                                             //RF_Dest_Address to save result
    wire [31:0] Result_W, Read_Data_W, ALU_Out_W;                       //Data_Signals
    wire Reg_Write_W, MemToReg_W;                                       //Controller_signals 

    // Instruction_Fetch_Stage   (IF_Stage_1):
    MUX2_to_1_32bit mux_1(PCPlus4_F, PCBranch_D, PC_in, PCSrc_D);       
    Program_Counter PC(clk, rst, (Stall_F), PC_in, PC_out);
    Adder adder_pc(PC_out, 32'd1, PCPlus4_F);
    Instruction_Memory insmem(PC_out, Instruction_F);

    // IF_IF_Reg;
    wire Stall_D;
    IF_ID_Reg ifid_reg(clk, PCSrc_D, (Stall_D), Instruction_F, PCPlus4_F, Instruction_D, PCPlus4_D);
    
    // Instruction_Decode_stage  (ID_Stage_2);
    Register_File RF(clk, rst, Reg_Write_W, Instruction_D[25:21], Instruction_D[20:16],
                     Reg_A_D, Reg_B_D, Write_Reg_W, Result_W);
    MUX2_to_1_32bit mux_2(Reg_A_D, ALU_Out_M, Comp_A, Forward_A_D);
    MUX2_to_1_32bit mux_3(Reg_B_D, ALU_Out_M, Comp_B, Forward_B_D);
    Comparator comp1(Comp_A, Comp_B, Equa_D);
    Control_Module Control(Instruction_D[31:26], Instruction_D[5:0], Reg_Write_D,
                           MemToReg_D, Mem_Write_D, ALU_Con_D, ALU_Src_D, Reg_Dest_D, Branch_D, Instruction_D[10:6], Shamt_D); 
    and1 a1(Branch_D, Equa_D, PCSrc_D);
    Sign_Extender SE(Instruction_D[15:0], Signlmm_D);
    Shift2 S2(Signlmm_D, Shift_D);
    Adder adder_branch(Shift_D, PCPlus4_D, PCBranch_D);

    // ID_EX_Reg
    ID_EX_Reg idex_reg(clk, (~Flush), Reg_Write_D, MemToReg_D, Mem_Write_D, ALU_Con_D, ALU_Src_D,
                        Reg_Dest_D, Reg_A_D, Reg_B_D, Signlmm_D, Instruction_D[25:21], Instruction_D[20:16],
                        Instruction_D[15:11], Reg_Write_E, MemToReg_E, Mem_Write_E, ALU_Con_E, ALU_Src_E,
                        Reg_Dest_E, Reg_A_E, Reg_B_E, Signlmm_E, Rs_E, Rt_E, Rd_E, Shamt_D, Shamt_E);

    // Execution_Stage   (EX_Stage_3):
    MUX3_to_1_32bit mux_4(Reg_A_E, Result_W, ALU_Out_M, Src_A_E, Forward_A_E);
    MUX3_to_1_32bit mux_5(Reg_B_E, Result_W, ALU_Out_M, Write_Data_E, Forward_B_E);
    MUX2_to_1_32bit mux_6(B, Signlmm_E, Src_B_E, ALU_Src_E);
    ALU_Module ALU(clk, rst, ALU_Con_E, Src_A_E, Src_B_E, ALU_Out_E, Shamt_E);
    MUX2_to_1_5bit mux_7(Rt_E, Rd_E, Write_Reg_E, Reg_Dest_E);

    // EX_MEM_Reg
    EX_MEM_Reg exmem_reg(clk, rst, Reg_Write_E, MemToReg_E, Mem_Write_E, ALU_Out_E, Write_Data_E,
                        Write_Reg_E, Reg_Write_M, MemToReg_M, Mem_Write_M, ALU_Out_M, Write_Data_M,
                        Write_Reg_M);

    // Memory_Stage  (MEM_Stage_4):
    Data_Mem data_memory(clk, Write_Data_M, ALU_Out_M, Mem_Write_M, Read_Data_M);

    // MEM_WB_Reg
    MEM_WB_Reg memwb_reg(clk, rst, Reg_Write_M, MemToReg_M, Read_Data_M, ALU_Out_M, Write_Reg_M,
                        Reg_Write_W, MemToReg_W, Read_Data_W, ALU_Out_W, Write_Reg_W);

    // Write_Back_Stage  (WB_Stage_5):
    MUX2_to_1_32bit mux_8(ALU_Out_W, Read_Data_W, Result_W, MemToReg_W);

    // Hazard_Unit
    Hazard_Unit Hazard(Instruction_D[25:21], Instruction_D[20:16], MemToReg_E, Rt_E, Rs_E, Write_Reg_E, 
                        Write_Reg_M, Reg_Write_E, Reg_Write_M, Stall_F, Flush, Stall_D, Forward_A_E,
                        Forward_B_E, Forward_A_D, Forward_B_D, Reg_Write_W, Branch_D, MemToReg_M);

endmodule