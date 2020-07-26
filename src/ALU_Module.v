`timescale 1ns/1ns

`include "Multiplier_Module.v"
`include "Adder_Subtractor_Module.v"
`include "Divider_Module.v"
`include "Carry_Select_Adder.v"
`include "Int_Divider.v"

module ALU_Module(clk, rst, ALU_Con, alu_a, alu_b, alu_out, Shamt);

    input [31:0] alu_a;
    input [31:0] alu_b;
    input [5:0] ALU_Con;
    input [4:0] Shamt;
    input clk,rst;

    output reg [31:0] alu_out;
    
	 
    wire [31:0] add_out,sub_out,mul_out,div_out, addi_out, divi_out;

    reg [31:0] a,b;
    reg [5:0] state;
    reg [4:0] shift_by;

    parameter   ADD     = 6'd0,
                SUB     = 6'd1,
                MUL     = 6'd2,
                DIV     = 6'd3,
                SLL     = 6'd4,
                SRL     = 6'd5,
                AND     = 6'd6,
                OR      = 6'd7,
                XOR     = 6'd8,
                SLT     = 6'd9,

                ADDF    = 6'd10,
                SUBF    = 6'd11,
                MULF    = 6'd12,
                DIVF    = 6'd13;
                

  //Floating Point Unit
    Adder_Subtractor_Module Adder(clk,rst,alu_a,alu_b,add_out);
    Adder_Subtractor_Module Subtracter(clk,rst,alu_a,(-alu_b),sub_out);
    Multiplier_Module Multiplier(clk,rst,alu_a,alu_b,mul_out);
    Divider_Module Divider(clk,rst,alu_a,alu_b,div_out);
 
    Carry_Select_Adder AdderI(addi_out, Carry_Flag, alu_a, alu_b);
    Int_Divider DividerI(alu_a, alu_b, divi_out);
 


    always@(*)
    begin

        a <= alu_a;
        b <= alu_b;
        state <= ALU_Con;
        shift_by <= Shamt;

        case (state)

            ADD:    alu_out <= addi_out;
            SUB:    alu_out <= a - b;
            MUL:    alu_out <= a * b;
            DIV:    alu_out <= divi_out;
            SLL:    alu_out <= (a << shift_by);
            SRL:    alu_out <= (a >> shift_by);
            AND:    alu_out <= a & b;
            OR:     alu_out <= a | b;
            XOR:    alu_out <= a ^ b;
            SLT:    alu_out <=  (a < b) ? 32'b00000000000000000000000000000001 : 32'b0; 

            ADDF:   alu_out <= add_out;
            SUBF:   alu_out <= sub_out;
            MULF:   alu_out <= mul_out;
            DIVF:   alu_out <= div_out;
            
            default: alu_out <= 32'bz;

        endcase 

    end

/*        assign alu_out = (ALU_Con == SUB) ? (alu_a - alu_b)                     : 32'bz;
        assign alu_out = (ALU_Con == MUL) ? (alu_a * alu_b)                     : 32'bz;
        assign alu_out = (ALU_Con == DIV) ? divi_out                            : 32'bz;
        assign alu_out = (ALU_Con == SLL) ? (alu_a << Shamt)                    : 32'bz;
        assign alu_out = (ALU_Con == SRL) ? (alu_a >> Shamt)                    : 32'bz;
        assign alu_out = (ALU_Con == AND) ? (alu_a & alu_b)                     : 32'bz;
        assign alu_out = (ALU_Con == OR)  ? (alu_a | alu_b)                     : 32'bz;
        assign alu_out = (ALU_Con == XOR) ? (alu_a ^ alu_b)                     : 32'bz;
        assign alu_out = (ALU_Con == SLT) ? ((alu_a < alu_b) ? 32'd1 : 32'b0)   : 32'bz;

        assign alu_out = (ALU_Con == ADDF) ? add_out                            : 32'bz;
        assign alu_out = (ALU_Con == SUBF) ? sub_out                            : 32'bz;
        assign alu_out = (ALU_Con == MULF) ? mul_out                            : 32'bz;
        assign alu_out = (ALU_Con == DIVF) ? div_out                            : 32'bz; */


endmodule