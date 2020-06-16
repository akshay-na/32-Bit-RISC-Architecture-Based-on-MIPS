`timescale 1ns/1ns

module Adder_Subtractor_Module(clk, rst, add_a, add_b, add_result);

	input [31:0] add_a;
	input [31:0] add_b;
	output [31:0] add_result;
	
	input clk, rst;
	reg [3:0] state;
	
	parameter		unpack 			= 4'd0,
					special_case	= 4'd1,
					align			= 4'd2,
					add_0			= 4'd3,
					add_1			= 4'd4,
					normalize_1		= 4'd5,
					normalize_2		= 4'd6,
					round			= 4'd7,
					pack			= 4'd8;

				
	reg [31:0] a,b,z;
	reg [26:0] a_m,b_m;
	reg [23:0] z_m;
	reg [9:0] a_e, b_e, z_e;
	reg a_s, b_s, z_s;
	reg [27:0] sum;			
	reg guard, round_bit, sticky;

	initial state <= unpack;
	
	always@(add_a or add_b)
	begin
	
		if(rst)
		begin
			state <= unpack;
			z <= 32'b0;
			a <= 32'b0;
			b <= 32'b0;
		end
		
		else
		begin
			case(state)
				
				//Unpacking of inputs and separation of Sign, Exponent and Mantessa bits;
				unpack:
				begin

					a <= add_a;
					b <= add_b;

					a_m <= {a[22:0],3'b0};
					b_m <= {b[22:0],3'b0};
					a_e <= a[30:23] - 127;
					b_e <= b[30:23] - 127;
					a_s <= a[31];
					b_s <= b[31];
					state <= special_case;
				end
				
				//Special Cases such as Operation with NaN, inf and Zero;
				special_case:
				begin
					//If a is Nan or b is NaN return NaN;
					if((a_e == 128 && a_m!= 0) || (b_e == 128 && b_m!= 0))
					begin
						z[31] <= 1;
						z[30:23] <= 255;
						z[22] <= 1;
						z[21:0] <= 0;
						state <= pack;
					end	
					
					//If a is inf return inf;
					else if (a_e == 128)
					begin
						z[31] <= a_s;
						z[30:23] <= 255;
						z[22:0] <= 0;
					end
					
					//If a is inf and signs don't match return NaN;
					if ((b_e == 128) && (a_s != b_s)) 
					begin
						z[31] <= b_s;
						z[30:23] <= 255;
						z[22] <= 1;
						z[21:0] <= 0;
						state <= pack;
					end
					
					//If b is inf return inf;
					else if (b_e == 128) 
					begin
						z[31] <= b_s;
						z[30:23] <= 255;
						z[22:0] <= 0;
						state <= pack;
					end
					
					//If a is zero return b;
					else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(b_e) == -127) && (b_m == 0))) 
					begin
						z[31] <= a_s & b_s;
						z[30:23] <= b_e[7:0] + 127;
						z[22:0] <= b_m[26:3];
						state <= pack;
					end
					
					//If a is zero return b;
					else if (($signed(a_e) == -127) && (a_m == 0))
					begin
						z[31] <= b_s;
						z[30:23] <= b_e[7:0] + 127;
						z[22:0] <= b_m[26:3];
						state <= pack;
					end
					
					//If b is zero return a;
					else if (($signed(b_e) == -127) && (b_m == 0))
					begin
						z[31] <= a_s;
						z[30:23] <= a_e[7:0] + 127;
						z[22:0] <= a_m[26:3];
						state <= pack;
					end
					
					//Denormalised Number;
					else 
					begin
						if ($signed(a_e) == -127)
							a_e <= -126;
							
						else
							a_m[26] <= 1;
					end
					
					//Denormalised Number;
					if ($signed(b_e) == -127)
						b_e <= -126;
					else 
						b_m[26] <= 1;
				
					state <= align;
				end
				
				//Alignment if Input if exponents of the inputs are diffrent;
				align:
				begin
					if($signed(a_e) > $signed(b_e))
					begin	
						b_e <= b_e + 1;
						b_m <= b_m >> 1;
						b_m[0] <= b_m[0] | b_m[1];
					end
					
					else if($signed(a_e) < $signed(b_e))
					begin	
						a_e <= a_e + 1;
						a_m <= a_m >> 1;
						a_m[0] <= a_m[0] | a_m[1];
					end
					
					else
						state <= add_0;
						
				end
				
				//Adding of Mantessa, where exponents are equal;
				add_0:
				begin
					z_e <= a_e;
					
					if(a_s == b_s)
					begin
						z_s <= a_s;
						sum <= a_m + b_m;
					end

					else 
					begin
						if(a_m >= b_m)
						begin
							sum <= a_m - b_m;
							z_s <= a_s;
						end

						else
						begin
							sum <= b_m - a_m;
							z_s <= b_s;
						end
					end

					state <= add_1;
				end

				add_1:
				begin
					
					if(sum[27])
					begin
						z_m <= sum[27:4];
						guard <= sum[3];
						sticky <= sum[3] | sum[0];
					end

					else
					begin
						z_m <= sum[27:3];
						guard <= sum[2];
						round_bit <= sum[1];
						sticky <= sum[0];
					end

					state <= normalize_1;
				end
				
				//Normalization of result to the form (-1)^Sign 1.Mantessa * 2^Exponent;
				normalize_1:
				begin

					if(z_m[23] == 0 && $signed(z_e) > -126) 
					begin
						z_e <= z_e - 1;
						z_m <= z_m << 1;
						z_m <= guard;
						guard <= round_bit;
						round_bit <= 0;
					end

					else
						state <= normalize_2;
					
				end

				normalize_2:
				begin
					if ($signed(z_e) < -126)
					begin
						z_e <= z_e + 1;
						z_m <= z_m >> 1;
						guard <= z_m[0];
						round_bit <= guard;
						sticky <= sticky | round_bit;	
					end

					else
						state <= round;

				end
				
				//Rounding of Z with gurad, round_bit and sticky;
				round:
				begin
					if (guard && (round_bit | sticky | z_m[0]))
					begin
						z_m <= z_m + 1;
						if(z_m == 24'hffffff)
							z_e <= z_e + 1;

					end
					state <= pack;

				end
				
				//Final packing of the register z if special cases or error accurs;
				pack:
				begin
					z[22:0] <= z_m[22:0];
					z[30:23] <= z_e[7:0] + 127;
					z[31] <= z_s;
					if ($signed(z_e) == -126 && z_m[23] == 0) 
						z[30:23] <= 0;
					if ($signed(z_e) == -126 && z_m[23:0] == 0)
						z[31] <= 1'b0;	//Fix sign bug: -a + a = +0;

					//If overflow occurs, return inf;
					if($signed(z_e) > 127)
					begin
						z[22:0] <= 0;
						z[30:23] <= 255;
						z[31] <= z_s;
					end	

					state <= unpack;
				end
				
		 	endcase
		end
	    
	end

	//Assigning Reg z to the output of the module	
	assign add_result[31:0] = z[31:0]; 

endmodule	