module calc_decimal #(
  parameter P_WIDTH = 16
)(
  input logic clk,
  input logic rst_n,

  input logic start,
  input logic [P_WIDTH-1:0] numerator_in,
  input logic [P_WIDTH-1:0] denominator_in,

  output logic done,
  output logic [P_WIDTH-1:0] decimal_out
  );

  logic [31:0] quotient_out;

  assign  decimal_out = quotient_out[P_WIDTH-1:0];

  div_32 div_32 (
    .dividend_in({numerator_in, 16'b0}),
    .divisor_in({16'b0, denominator_in}),
    .quotient_out(quotient_out),
    .remainder_out(),
    .*
  );
endmodule

