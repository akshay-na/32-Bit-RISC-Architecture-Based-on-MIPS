`timescale 1ns/1ns

module Rom (q, a);

    input [6:0] a;
    output [31:0] q;

    reg [31:0] mem [127:0];

    initial $readmemh("data.hex", mem, 0, 127);
    assign q=mem[a];

endmodule