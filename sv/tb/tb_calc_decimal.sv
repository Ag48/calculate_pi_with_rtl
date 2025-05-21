`include "vunit_defines.svh"
`timescale 1ns/1ns

module tb_calc_decimal;

  parameter P_WIDTH_IN = 16;
  parameter P_WIDTH_OUT = 32;
  localparam L_CLK_PERIOD = 100;
  
  logic clk;
  logic rst_n;

  logic start;
  logic [P_WIDTH_IN-1:0] numerator_in;
  logic [P_WIDTH_IN-1:0] denominator_in;
  logic done;
  logic [P_WIDTH_IN-1:0] decimal_out;

  `TEST_SUITE begin: test_unit
    `TEST_CASE_SETUP begin: setup
      rst_n = 'b1;
      numerator_in = 'd0;
      denominator_in = 'd0;
      #(L_CLK_PERIOD/2) rst_n = 'b0;
      #(L_CLK_PERIOD/2) rst_n = 'b1;
    end

    `TEST_CASE("test0_init") begin
      `CHECK_EQUAL(decimal_out, 'h0);
    end

    `TEST_CASE("test1_validate_calulation_result") begin
      real result_decimal;
      bit [P_WIDTH_OUT-1:0] decimal_bin_exp;
      for (int numerator = 1; numerator < 2**8; numerator++) begin
        for (int denominator = 1; denominator < 2**8; denominator++ ) begin
          if (numerator >= denominator) continue;
          result_decimal = real'(numerator) / real'(denominator);
          decimal_bin_exp = f_calc_decimal(result_decimal);
          $display("[%0t] %0d / %0d = %f (dec in bin: %b)", 
            $time, numerator, denominator, result_decimal, decimal_bin_exp);
          numerator_in = numerator;
          denominator_in = denominator;
          start = 'b1;
          @(posedge clk);
          start = 'b0;
          @(posedge done);
          `CHECK_EQUAL(decimal_out, decimal_bin_exp[31:16]);
          @(posedge clk);
          #(L_CLK_PERIOD/2);
          `CHECK_EQUAL(done, 'b0);
        end
      end
    end

  end

  initial begin: gen_clk
    clk = 'b0;
    forever #(L_CLK_PERIOD/2) clk = ~clk;
  end

  calc_decimal DUT (.*);

  function automatic bit [P_WIDTH_OUT-1:0] f_calc_decimal(real decimal_in); 
    bit [P_WIDTH_OUT-1:0] result_bin;
    real decimal;

    decimal = decimal_in -  $floor(decimal_in); // 小数部のみ取り出す
    $display("  f_calc_decimal decimal_in (%0f) > decimal (%0f)", decimal_in, decimal);
    result_bin = 'h0;

    for (int i = 0; i < P_WIDTH_OUT; i++) begin
      decimal = decimal * 2;
      if (decimal >= 1) begin
        decimal = decimal - 1;
        result_bin[(P_WIDTH_OUT-1)-i] = 'b1;
      end else begin
        result_bin[(P_WIDTH_OUT-1)-i] = 'b0;
      end
      $display("  f_calc_decimal decimal (%0f)[%0d] decimal_bin (%b)", decimal, i, result_bin);  
      if (decimal == 0.0) begin
        $display("  f_calc_decimal break (decimal == 0.0)");
        break; // より下の桁は全て 0b が埋まっている
      end
    end

    $display("  f_calc_decimal result : decimal (%0f) > decimal_bin (32'b%b)", decimal_in, result_bin);  
    return result_bin;
  endfunction

endmodule
