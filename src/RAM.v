`timescale 1ns/1ns

module RAM (clk, rst, q, a, d, write_enable, read_enable);

    input clk,rst;
    input write_enable, read_enable;
    input [7:0] q,d;
    input [5:0] a;

    reg [7:0] qtemp;
    reg [7:0] mem [63:0];

    integer i;

    always@(posedge clk)
    begin
        if(rst)
            begin
                for(i=0; i < 64; i= i+1)
                mem[i] <= {(8){1'b0}};
            end 

        else if(write_enable == 1'b1)
            mem[a] <= d;
    end

    always@(*)
    begin
        if(read_enable == 1'b1)
            qtemp <= mem[a];
        else
            qtemp <= {(8){1'b0}};
    end

endmodule