`timescale 1ns/1ns

module IF_ID_Reg (clk, clr, en, ins_in, PCPlus4_in, ins_out, PCPlus4_out);
    input clk,clr,en;
    input [31:0] ins_in, PCPlus4_in;

    output reg [31:0] ins_out, PCPlus4_out;

    always@(posedge clk)
    begin
        if(clr)
        begin
            ins_out <= 32'b0;
            PCPlus4_out <= 32'b0;
        end

        else if (en) 
        begin
            ins_out <= 32'bz;
            PCPlus4_out <= 32'bz;
        end

        else 
        begin
            ins_out <= ins_in;
            PCPlus4_out <= PCPlus4_in;
        end
    end
endmodule