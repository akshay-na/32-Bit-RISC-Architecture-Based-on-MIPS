`timescale 1ns/1ns

module Instruction_Memory(inst_add, inst);

    input wire [31:0] inst_add;
    output wire [31:0] inst;

    reg [31:0] mem [255:0];

    initial
        $readmemb("instructions_bin.txt", mem, 0, 255);

       assign inst = mem[inst_add[7:0]];

endmodule 