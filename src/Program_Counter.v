`timescale 1ns/1ns

module Program_Counter (clk, rst, PCWrite, PCNext, PCResult);

	input       [31:0]  PCNext;
	input               rst, clk, PCWrite;

	output reg  [31:0]  PCResult;

	initial 
		PCResult <= -1;

    always @(posedge clk)
    begin
    	if (rst == 1)
    		PCResult = 32'b0;

    	else
			PCResult = PCNext;


		$monitor("PC=%h",PCResult);
    end

endmodule