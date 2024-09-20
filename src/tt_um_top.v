/*
* Copyright (c) 2024 Konrad Beckmann
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg output_valid;
  wire data_out;
  wire _unused_ok = &{uio_in, ena};
  assign uo_out  = {6'b000000, output_valid, data_out};
  assign uio_oe  = 8'b00000000;
  assign uio_out = 8'b00000000;

  // 32-bit shift register
  reg [31:0] shift_register;
  wire shift_in = ui_in[0];
  wire input_valid = ui_in[1];
  reg prev_input_valid;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_register   <= 32'b0;
      prev_input_valid <= 1'b0;
    end else begin
      prev_input_valid <= input_valid;
      if (input_valid) begin
        shift_register <= {shift_register[30:0], shift_in};
      end
    end
  end

  // Instantiate mul_inferred module
  wire [31:0] mul_result;
  wire mul_valid;

  // Start when input_valid goes from high to low
  wire start = prev_input_valid && !input_valid;

  mul_bit_serial #(
      .WIDTH(16)
  ) multiplier (
      .clk(clk),
      .rst_n(rst_n),
      .start(start),
      .a(shift_register[31:16]),
      .b(shift_register[15:0]),
      .output_result(mul_result),
      .output_valid(mul_valid)
  );

  // Output logic
  reg [31:0] output_shift_reg;
  reg [4:0] output_counter;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      output_shift_reg <= 32'b0;
      output_valid <= 1'b0;
      output_counter <= 5'b0;
    end else if (mul_valid) begin
      output_shift_reg <= mul_result;
      output_valid <= 1'b1;
      output_counter <= 5'd31;
    end else if (output_counter > 0) begin
      output_shift_reg <= {output_shift_reg[30:0], 1'b0};
      output_counter   <= output_counter - 1;
    end else begin
      output_valid <= 1'b0;
    end
  end

  assign data_out  = output_shift_reg[31];
  assign uo_out[1] = output_valid;


endmodule

