`timescale 1ns/1ns

module MUX2to1_w4(output [3:0] y, input [3:0] i0, i1, input s);

  wire [3:0] e0, e1;
  not ad13(sn, s);
  
  and ad1(e0[0], i0[0], sn);
  and ad2(e0[1], i0[1], sn);
  and ad3(e0[2], i0[2], sn);
  and ad4(e0[3], i0[3], sn);
      
  and ad5(e1[0], i1[0], s);
  and ad6(e1[1], i1[1], s);
  and ad7(e1[2], i1[2], s);
  and ad8(e1[3], i1[3], s);
  
  or ad9(y[0], e0[0], e1[0]);
  or ad10(y[1], e0[1], e1[1]);
  or ad11(y[2], e0[2], e1[2]);
  or ad12(y[3], e0[3], e1[3]);
  
endmodule