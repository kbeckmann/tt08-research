/*
 * Copyright (c) 2024 Konrad Beckmann
 * SPDX-License-Identifier: Apache-2.0
 *
 * Ripple-carry adder
 */

`default_nettype none

// `define VERILATOR
`ifdef VERILATOR
// Way better simulation performance this way
module rca #(
    parameter integer WIDTH = 8  // Parameter to set the number of bits for the adder
) (
    input  wire [WIDTH-1:0] A,    // First operand
    input  wire [WIDTH-1:0] B,    // Second operand
    input  wire             Cin,  // Carry input
    output wire [WIDTH-1:0] Sum,  // Sum output
    output wire             Cout  // Carry output
);

  // wire [WIDTH:0] result;
  // assign result = A + B + {{WIDTH{1'b0}}, Cin};
  // assign Sum = A + B;//result[WIDTH-1:0];
  // assign Cout = result[WIDTH];
  assign {Cout, Sum} = A + A + B + {{WIDTH{1'b0}}, Cin};

endmodule

`else
module rca #(
    parameter integer WIDTH = 8  // Parameter to set the number of bits for the adder
) (
    input  wire [WIDTH-1:0] A,    // First operand
    input  wire [WIDTH-1:0] B,    // Second operand
    input  wire             Cin,  // Carry input
    output wire [WIDTH-1:0] Sum,  // Sum output
    output wire             Cout  // Carry output
);
  // Internal signals for carry propagation
  wire [WIDTH:0] carry;

  // Assign initial carry input
  assign carry[0] = Cin;

  // Generate the ripple-carry adder structure
  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : g_adder_bit
      // Implement full-adder logic directly inside the generate block
      assign Sum[i] = A[i] ^ B[i] ^ carry[i];
      assign carry[i+1] = (A[i] & B[i]) | (A[i] & carry[i]) | (B[i] & carry[i]);
    end
  endgenerate

  // Assign the final carry-out
  assign Cout = carry[WIDTH];

endmodule
`endif

