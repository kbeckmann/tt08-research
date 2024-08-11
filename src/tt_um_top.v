/*
* Copyright (c) 2024 Konrad Beckmann
* SPDX-License-Identifier: Apache-2.0
*/

// | Utilisation (%) | Wire length (um) |
// |-----------------|------------------|
// | 14.19           | 5015             |

`default_nettype none

module tt_um_top(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

wire [15:0] recip;
wire [8:0]  denom = {uio_in[0], ui_in};
wire        start = uio_in[1];

reg data_out;
wire _unused_ok = &{ui_in, uio_in, ena};
assign uo_out = recip[15:8];
assign uio_oe = 8'b11111111; // this is just for testing utilization
assign uio_out = recip[7:0];

// module recip16 (
//   input clk,
//   input start,
//   input [8:0] denom,
//   output [15:0] recip
// );

recip16 recip16_uut (
  .clk(clk),
  .start(start),
  .denom(denom),
  .recip(recip)
);


endmodule

