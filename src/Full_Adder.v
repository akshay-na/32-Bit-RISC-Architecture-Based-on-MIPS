`timescale 1ns/1ns

// Full Adder
module Full_Adder(output sum, cout, input a, b, cin);
  wire w0, w1, w2;
  
  xor  da(w0, a, b);
  xor  ba(sum, w0, cin);
  
  and cd(w1, w0, cin);
  and sd(w2, a, b);
  or ee(cout, w1, w2);
endmodule