`timescale 1ns/1ns

module Control_Module(Op_Code, funct, Reg_Write_D, MemToReg_D, Mem_Write_D, ALUCon,
                        ALU_Src_D, Reg_Dest_D, Branch_D, Shamt_in, Shamt_D);

    input [5:0] Op_Code, funct;
    input [4:0] Shamt_in;
    output reg Reg_Write_D, MemToReg_D, Mem_Write_D, ALU_Src_D, Reg_Dest_D, Branch_D;
    output reg [5:0] ALUCon;
    output reg [4:0] Shamt_D;



    always@(Op_Code, funct, Shamt_in)
    begin
  /*      Reg_Write_D <= 1'bz;
        MemToReg_D <= 1'bz;
        Mem_Write_D <= 1'bz;
        ALU_Src_D <= 1'bz;
        Reg_Dest_D <= 1'bz;
        Branch_D <= 1'bz;
        ALUCon <= 4'bz; */

        // R-Type Ins
        if(Op_Code == 6'b0)
        begin                   //Check Hazard unit for Forward AE and BE
            ALUCon = funct;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b0;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'b0;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b1;
            Shamt_D = Shamt_in;
        end

        /* I-Type Ins*/

        //beq
        if(Op_Code == 6'd4)
        begin                   //Check Hazard unit for Forward AD and BD
            ALUCon = 6'dz;
            Reg_Write_D = 1'bz;
            MemToReg_D = 1'bz;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'bz;
            Branch_D = 1'b1;
            Reg_Dest_D = 1'bz;
            Shamt_D = 5'bz;
        end

    /*    //bne
        if(Op_Code == 6'd5)
        begin                   //Check Hazard unit for Forward AD and BD
            ALUCon = 6'bz;
            Reg_Write_D = 1'bz;
            MemToReg_D = 1'bz;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'bz;
            Branch_D = 1'b1;
            Reg_Dest_D = 1'bz;
            Shamt_D = 5'bz;
        end  */


        //addi
        if(Op_Code == 6'd8)
        begin                   //Check Hazard unit for Forward AE.
            ALUCon = 6'd0;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b0;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'b1;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b0;
            Shamt_D = 5'bz;
        end

        //andi
        if(Op_Code == 6'd12)
        begin                   //Check Hazard unit for Forward AE.
            ALUCon = 6'd6;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b0;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'b1;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b0;
            Shamt_D = 5'bz;
        end

        //ori
        if(Op_Code == 6'd13)
        begin                   //Check Hazard unit for Forward AE.
            ALUCon = 6'd7;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b0;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'b1;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b0;
            Shamt_D = 5'bz;
        end


        //slti
        if(Op_Code == 6'd10)
        begin                   //Check Hazard unit for Forward AE.
            ALUCon = 6'd9;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b0;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'b1;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b0;
            Shamt_D = 5'bz;
        end

/*        //lui
        if(Op_Code == 6'd10)
        begin                   //Check Hazard unit for Forward AE.
            ALUCon = 6'd15;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b0;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'b1;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b0;
            Shamt_D = 5'd16;
        end  */

        //lw
        if(Op_Code == 6'd35)
        begin                    //Check Hazard unit for Forward AD
            ALUCon = 6'd0;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b1;
            Mem_Write_D = 1'b0;
            ALU_Src_D = 1'b1;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b0;
            Shamt_D = 5'bz;
        end

        //sw
        if(Op_Code == 6'd43)
        begin                   
            ALUCon = 6'd0;
            Reg_Write_D = 1'b0;
            MemToReg_D = 1'bz;
            Mem_Write_D = 1'b1;
            ALU_Src_D = 1'b1;   //Check Hazard unit for Forward AD
            Branch_D = 1'b0;
            Reg_Dest_D = 1'bz;
            Shamt_D = 5'bz;
        end

        //xori
        if(Op_Code == 6'd14)
        begin                   //Check Hazard unit for Forward AE.
            ALUCon = 6'd8;
            Reg_Write_D = 1'b1;
            MemToReg_D = 1'b0;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'b1;
            Branch_D = 1'b0;
            Reg_Dest_D = 1'b0;
            Shamt_D = 5'bz;
        end


        // J-Type Ins
        
        //NOOP
        if(Op_Code == 6'd0)
        begin                   //Check Hazard unit for Forward AE.
            ALUCon = 6'dz;
            Reg_Write_D = 1'bz;
            MemToReg_D = 1'bz;
            Mem_Write_D = 1'bz;
            ALU_Src_D = 1'bz;
            Branch_D = 1'bz;
            Reg_Dest_D = 1'bz;
            Shamt_D = 5'bz;
        end

        if(Op_Code == 6'd64)
            #0.5 $finish;

    end


endmodule 