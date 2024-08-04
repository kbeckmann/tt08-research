/*
* Copyright (c) 2024 Konrad Beckmann
* SPDX-License-Identifier: Apache-2.0
*/

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

reg data_out;
wire _unused_ok = &{ui_in, uio_in, ena};
assign uo_out = {7'b0000000, data_out};
assign uio_oe = 8'b00000000;
assign uio_out = 8'b00000000;

always @(posedge clk) begin
  if (~rst_n) begin
    data_out <= 1'b0;
  end else begin
    data_out <= ~data_out;
  end
end

endmodule

