`timescale 1ns/1ns

module Multiplier_Module(clk,rst,mul_a,mul_b,out_prod);
    
    input [31:0] mul_a;
    input [31:0] mul_b;
    output [31:0] out_prod;

    input     clk;
    input     rst;

    reg       [3:0] state;
    parameter   unpack        = 4'd0,
                special_case  = 4'd1,
                normalise_a   = 4'd2,
                normalise_b   = 4'd3,
                multiply_0    = 4'd4,
                multiply_1    = 4'd5,
                normalise_1   = 4'd6,
                normalise_2   = 4'd7,
                round         = 4'd8,
                pack          = 4'd9;

    reg [31:0] a,b,z;
	reg [23:0] z_m,b_m,a_m;
	reg [9:0] a_e, b_e, z_e;
	reg a_s, b_s, z_s;
	reg [49:0] product;			
	reg guard, round_bit, sticky;
            
    
    always@(mul_a or mul_b)
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
            case (state)

                //Unpacking of inputs and separation of Sign, Exponent and Mantessa bits.
                unpack:
				begin

					a <= mul_a;
					b <= mul_b;

					a_m <= a[22:0];
					b_m <= b[22:0];
					a_e <= a[30:23] - 127;
					b_e <= b[30:23] - 127;
					a_s <= a[31];
					b_s <= b[31];
					state <= special_case;
				end
                
                //Special Cases such as Operation with NaN, inf and Zero.
                special_case:
                begin
                    //if a is NaN or b is NaN return NaN 
                    if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) 
                    begin
                        z[31] <= 1;
                        z[30:23] <= 255;
                        z[22] <= 1;
                        z[21:0] <= 0;
                        state <= pack;
                    end

                    //if a is inf return inf
                    else if (a_e == 128) 
                    begin
                        z[31] <= a_s ^ b_s;
                        z[30:23] <= 255;
                        z[22:0] <= 0;
            
                         //if b is zero return NaN
                        if (($signed(b_e) == -127) && (b_m == 0))
                        begin
                            z[31] <= 1;
                            z[30:23] <= 255;
                            z[22] <= 1;
                            z[21:0] <= 0;
                        end
                        state <= pack;
                    end
                    
                    //if b is inf return inf
                    else if (b_e == 128)
                    begin
                        
                        z[31] <= a_s ^ b_s;
                        z[30:23] <= 255;
                        z[22:0] <= 0;
                        
                        //if a is zero return NaN
                        if (($signed(a_e) == -127) && (a_m == 0)) 
                        begin
                            z[31] <= 1;
                            z[30:23] <= 255;
                            z[22] <= 1;
                            z[21:0] <= 0;
                        end
                        state <= pack;
                    end

                    //if a is zero return zero
                    else if (($signed(a_e) == -127) && (a_m == 0))
                     begin
                        z[31] <= a_s ^ b_s;
                        z[30:23] <= 0;
                        z[22:0] <= 0;
                        state <= pack;
                    end

                    //if b is zero return zero
                    else if (($signed(b_e) == -127) && (b_m == 0))
                    begin
                        z[31] <= a_s ^ b_s;
                        z[30:23] <= 0;
                        z[22:0] <= 0;
                        state <= pack;
                    end 
                    
                    //Denormalised Number
                    else 
                    begin
                        if ($signed(a_e) == -127)
                            a_e <= -126;
                        else
                            a_m[23] <= 1;
                        
                        //Denormalised Number
                        if ($signed(b_e) == -127)
                            b_e <= -126;
                        else 
                            b_m[23] <= 1;
                        
                        state <= normalise_a;
                     end
                end     

                //Normalization of result to the form (-1)^Sign 1.Mantessa * 2^Exponent.
                normalise_a:
                begin
                    if(a_m[23])
                        state <= normalise_b;
                    else
                    begin
                        a_m <= a_m << 1;
                        a_e <= a_e - 1;
                    end
                end

                normalise_b:
                begin
                    if(b_m[23])
                        state <= multiply_0;
                    else
                    begin
                        b_m <= b_m << 1;
                        b_e <= b_e - 1;
                    end
                end

                //Multipliing mantessa and adding exponent, where exponents are equal.
                multiply_0:
                begin
                    z_s <= a_s | b_s;
                    z_e <= a_e + b_e + 1;
                    product <= a_m * b_m * 4;
                    state <= multiply_1;
                end

                multiply_1:
                begin
                    z_m <= product[49:26];
                    guard <= product[25];
                    round_bit <= product[24];
                    sticky <= (product[23:0] != 0);
                    state <= normalise_1;
                end

                normalise_1:
                begin
                    if (z_m[23] == 0) 
                    begin
                        z_e <= z_e - 1;
                        z_m <= z_m << 1;
                        z_m[0] <= guard;
                        guard <= round_bit;
                        round_bit <= 0;
                    end

                    else
                        state <= normalise_2;
                end

                normalise_2:
                begin
                    if($signed(z_e) < -126)
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

                //Packing of z if there is no special cases or errors. 
                round:
                begin
                    if(guard && (round_bit | sticky | z_m[0]))
                    begin
                        z_m <= z_m + 1;
                        if(z_m == 24'hffffff)
                            z_e <= z_e + 1;
                    end

                    state<= pack;
                end

                pack:
                begin
                    z[22:0] <= z_m[22:0];
                    z[30:23] <= z_e[7:0] + 127;
                    z[31] <= z_s;
                    if($signed(z_e) == -126 && z_m[23] == 0)
                        z[30:23] <= 0;
                    
                    //If overflow occurs;
                    if($signed(z_e > 127))
                    begin
                        z[22:0] <= 0;
                        z[30:23] <= 255;
                        z[31] <= z_s;
                    end

                    state <= unpack;
                end

                default: state <= unpack;
                
            endcase
        end
    end

    assign out_prod[31:0] = z[31:0];
endmodule