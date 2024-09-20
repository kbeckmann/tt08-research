/*
* Copyright (c) 2024 Konrad Beckmann
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module mul_inferred #(
    parameter integer WIDTH = 16
) (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    output reg [WIDTH*2-1:0] output_result,
    output reg output_valid
);

  wire [WIDTH*2-1:0] output_result_next = a * b;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      output_result <= 0;
      output_valid  <= 1'b0;
    end else if (start) begin
      output_result <= output_result_next;
      output_valid  <= 1'b1;
    end else begin
      output_valid <= 1'b0;
    end
  end

endmodule
