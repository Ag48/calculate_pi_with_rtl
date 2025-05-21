module calc_pi #(
  )(
  input logic clk,
  input logic rst_n,
  
  input logic start,
  output logic valid,
  output logic [15:0] decimal_out,
  output logic done
);

  assign valid = 'b0;
  assign decimal_out = 'h0;
  assign done = 'b0;

endmodule
