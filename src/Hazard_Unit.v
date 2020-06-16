`timescale 1ns/1ns

module Hazard_Unit(Rs_D, Rt_D, MemtoReg_E, Rt_E, Rs_E, Write_Reg_E, Write_Reg_M, Reg_Write_E,
                    Reg_Write_M, Stall_F, Flush_E, Stall_D, Forward_AE, Forward_BE,
                    Forward_AD, Forward_BD, Reg_Write_W, Branch_D, MemtoReg_M);


    input [4:0] Rs_D, Rs_E, Rt_E, Rt_D, Write_Reg_E, Write_Reg_M;
    input Reg_Write_E, Reg_Write_M, MemtoReg_E, Reg_Write_W;
    input Branch_D, MemtoReg_M;

    output reg Stall_D, Stall_F;
    output reg Flush_E;
    output reg [1:0] Forward_AE, Forward_BE;
    output reg Forward_BD, Forward_AD;

    reg lwstall, branchstall;

    initial
    begin
        Stall_F = 1'b1;
        Stall_D = 1'b1;
        Forward_AE = 2'b00;
        Forward_BE = 2'b00;
        Forward_AD = 1'b1;
        Forward_BD = 1'b1; 

    end


    //Forwarding Unit
    always@(*)
    begin
    	//Forward around EX hazard
    	if(Reg_Write_M && (Write_Reg_M !=0) && (Write_Reg_M == Rs_E))
    		Forward_AE = 2'b10;

    	//Forward around MEM hazard
    	else if(Reg_Write_W && (Write_Reg_M !=0) && (Write_Reg_M == Rs_E))
    		Forward_AE = 2'b01;

    	else 
    		Forward_AE = 2'b00;
    end

    always@(*)
    begin
    	//Forward around EX hazard
    	if(Reg_Write_M && (Write_Reg_M !=0) && (Write_Reg_M == Rt_E))
    		Forward_BE = 2'b10;

    	//Forward around MEM hazard
    	else if(Reg_Write_W && (Write_Reg_M !=0) && (Write_Reg_M == Rt_E))
    		Forward_BE = 2'b01;

    	else 
    		Forward_BE = 2'b00;
    end

    always@(*)
    begin
    	Forward_AD = (Write_Reg_M !=0) && (Rs_D == Write_Reg_M) && Reg_Write_M;
        Forward_BD = (Write_Reg_M !=0) && (Rt_D == Write_Reg_M) && Reg_Write_M;
    end	


    //Hazard Stall unit
    always@(*)
    begin 
    	lwstall = ((Rs_D == Rt_E) || (Rt_D == Rt_E)) && MemtoReg_E;

    	branchstall =   Branch_D & (Reg_Write_E 
    					& ((Write_Reg_E == Rs_D) | (Write_Reg_E == Rt_D)) | MemtoReg_M 
    					& ((Write_Reg_M == Rs_D) | (Write_Reg_M == Rt_D)));

    	Stall_F = lwstall || branchstall;
    	Stall_D = lwstall || branchstall;
    	Flush_E = lwstall || branchstall;

    end


endmodule 