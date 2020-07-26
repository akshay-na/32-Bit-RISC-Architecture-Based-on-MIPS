`timescale 1ns/1ns

module MUX2to1_w1(output y, input i0, i1, s);

  wire e0, e1;
  not ad4(sn, s);
  
  and ad2(e0, i0, sn);
  and ad1(e1, i1, s);
  
  or ad(y, e0, e1);
  
endmodule