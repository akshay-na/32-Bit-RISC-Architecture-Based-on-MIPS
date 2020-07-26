`timescale 1ns/1ns

module Float_Binary_coverter (clk,conv_a,conv_b,conv_result);

	//Function to grab sign bit;
	function set_sign;
		input [31:0] data;
		begin
			set_sign = data[31];
		end
	endfunction

	//Function to set the exponent Value;
	function [7:0] set_msb_index;
		input [31:0] data;
		reg [31:0] result;
		integer i;
		begin	
			result = -1;
			if(data[31] == 0)
			begin
				//Find the most significant 1 bit after the sign;
				for(i=31; i>= 0 && result == -1; i = i-1)
				begin
					if(data[i] == 1)
						result = i;
				end	
			end
			
			else if(data[31] == 1)
			begin
				for(i=0; i <= 31 && result == -1; i = i+1)
				begin
					if(data[i] == 1)
						result = i;
				end
			end
			
			if(result == -1) 
			begin
				result	=	0;
			end
			
			set_msb_index =	result;
		end
	endfunction
	
	
	//Function to convert RHS argument to fractional binary value;
	function [31:0] convert_rhs;
		input [31:0] data;
		reg [31:0] result;
		integer i, max;
		begin
			max = 0;
			
			//Find base 10 that is larger than out RHS;
			for( i =0; i < 10 && max == 0; i = i+1)
			begin
				if((10**i) > data)
					max = 10 ** i;
			end
		
			result = 32'b0;	
			
			//Use the multiple+push technique to generate a binary fractal number;
			for( i = 0; i <= 31; i = i+1)
			begin
				//Multiply the decimal number by 2;
				data = data*2;
				
				//Shift our binary fraction left each time;
				result = result << 1;
				
				//If dec result was greater than e.g. 100, we push a 1;
				if(data >= max)
				begin
					data = data - max;
					result = result | 1'b1;
				end
			    
				//Else we push 0
				else 
					result =result | 1'b0;
				
			end
			
			convert_rhs = result;
		end
	endfunction

	
	task convert;
		// Main program variables
		input [31:0] lhs; // Left had side of the decimal number.
		input [31:0] rhs; // Right hand side of the decimal number.
		output reg [31:0] res; // Resulting IEEE 754 value

		integer rhs_decimal; 
		integer left_msb_index;
		integer right_msb_index;
		integer lhs_mask; 
		integer rhs_mask;
		integer sign; 
		integer i;
		begin
        
			rhs_decimal = rhs;

			lhs_mask = 0;
			rhs_mask = 0; 
			sign = 0;

			if(lhs[31] == 1) begin 
				lhs = ~(lhs - 1);
				sign = 1'b1;
			end

			//Find most sigificant 1-bit on lhs
			left_msb_index = set_msb_index(lhs);

			//Convert rhs to binary fraction
			rhs = convert_rhs(rhs);
			
			//Find most significant 1-bit on rhs  
			right_msb_index = set_msb_index(rhs);

			if(lhs != 0)
			begin 
				//Set mask for lhs 
				for(i = 0; i < left_msb_index; i = i+1)
					lhs_mask[i] = 1'b1;
				
				//Mantessa
				res[22:0] = (lhs & lhs_mask) << (( 22 - left_msb_index) + 1);
				res[22:0] = res[22:0] | (rhs >> (left_msb_index + 9));

				//Set the last bit to 1 to round up 
				if(right_msb_index > 22) 
				begin 
					for(i = right_msb_index - 22; i >= 0; i = i-1)
						if(rhs[i] == 1)
							res[0] = 1;
				end 

				if(sign == 0)
					sign = set_sign(lhs);
				res[31] = sign;

				//Exponent
				res[30:23] = 127 + left_msb_index;
			//	$display("Converted: %0d\.%0d = %b", lhs, rhs_decimal, res);
				
			end
		end
    endtask
	
	
	//Main
	 input [31:0] conv_a; //Left side of decimal number;
	 input [31:0] conv_b; //Right side of decimal number;
	 output reg [31:0] conv_result; //Result in IEEE 754 format;
	 input clk;
	 
	 always@(posedge clk)
	 begin
		convert(conv_a,conv_b,conv_result);
	 end
	
endmodule			