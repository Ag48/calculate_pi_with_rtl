`include "vunit_defines.svh"
`timescale 1ns/1ns

module tb_calc_pi;
  parameter P_PI_DECIMAL_IN_HEX = "243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89452821E638D01377BE546";
  localparam L_CLK_PERIOD = 100;

  logic clk;
  logic rst_n;

  logic start;
  logic [15:0] decimal_out;
  logic valid;
  logic done;

  `TEST_SUITE begin : test_suit
    `TEST_CASE_SETUP begin : setup
      rst_n = 'b1;
      start = 'b0;
      #(L_CLK_PERIOD/2) rst_n = 'b0;
      #(L_CLK_PERIOD/2) rst_n = 'b1;
    end

    `TEST_CASE("test0_init") begin
      `CHECK_EQUAL(decimal_out, 'h0);
      `CHECK_EQUAL(valid, 'b0);
      `CHECK_EQUAL(done, 'b0);
    end

  end

  initial begin : gen_clk
    clk = 'b0;
    forever #(L_CLK_PERIOD/2) clk = ~clk;
  end

  calc_pi DUT(.*);

endmodule
