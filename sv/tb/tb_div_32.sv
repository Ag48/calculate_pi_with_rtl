`include "vunit_defines.svh"
`timescale 1ns/1ns

module tb_div_32;

  parameter  P_WIDTH = 32;
  localparam L_CLK_PERIOD = 100;

  logic clk;
  logic rst_n;
  
  logic start;
  logic [P_WIDTH-1:0]     dividend_in;
  logic [P_WIDTH-1:0]     divisor_in;
  logic [P_WIDTH-1:0]     quotient_out;
  logic [P_WIDTH-1:0]     remainder_out;
  logic                 done;

  `TEST_SUITE begin: test_suit
    `TEST_CASE_SETUP begin: setup
      rst_n = 'b1;
      start = 'b0;
      dividend_in = 'h0;
      divisor_in = 'h0;
      #(L_CLK_PERIOD/2) rst_n = 'b0;
      #(L_CLK_PERIOD/2) rst_n = 'b1;
    end

    `TEST_CASE("test0_init") begin
      `CHECK_EQUAL(quotient_out, 'h0);
      `CHECK_EQUAL(remainder_out, 'h0);
      `CHECK_EQUAL(done, 'b0);
    end
  end

  initial begin: gen_clk
    clk = 'b0;
    forever #(L_CLK_PERIOD/2) clk = ~clk;
  end

  non_restoring_divider DUT (.*);

endmodule
