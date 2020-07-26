`include "Core.v"

module core_tb ();
	
	reg clk, rst;
	
	Core core_sim(clk,rst); 

	initial
	begin
		clk = 1'b0;
		repeat (500000) #5 clk = ~clk; 
	end



endmodule