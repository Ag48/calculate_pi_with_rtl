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

    `TEST_CASE("test1_division") begin
      int q_exp;
      int r_exp;
      for (int dividend = 1; dividend < 2**8; dividend++) begin
        for (int divisor = 1; divisor < 2**8; divisor++) begin
          dividend_in = dividend;
          divisor_in = divisor;
          start = 'b1;
          @(posedge clk);
          start = 'b0;
          @(posedge done);
          q_exp = dividend / divisor;
          r_exp = dividend % divisor;
          $display("[%0t] %0d/%0d = %0d ... %0d (exp: %0d ... %0d)", $time, dividend, divisor, quotient_out, remainder_out, q_exp, r_exp);
          `CHECK_EQUAL(quotient_out, q_exp);
          `CHECK_EQUAL(remainder_out, r_exp);
          @(posedge clk);
          #(L_CLK_PERIOD/2);
          `CHECK_EQUAL(done, 'b0);
        end
      end
    end

  end
  // `WATCHDOG(100ms);

  initial begin: gen_clk
    clk = 'b0;
    forever #(L_CLK_PERIOD/2) clk = ~clk;
  end

  div_32 DUT (.*);

endmodule
