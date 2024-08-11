/*
 * Public domain
 */

`default_nettype none

module tt_um_top(
`ifdef VERILATOR
  // Extra signals for web simulator
  output wire        audio_en , // Audio Enabled. Set to false to enable video rendering
  output wire [15:0] audio_out, // Audio sample output
  output wire [31:0] clk_hz,    // clk frequency in Hz. Output consumed by simulator to adjust sampling rate (when to consume audio_out)
`endif

  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);


// ------------------------------
// Audio signals
wire audio_pdm;
wire [7:0] audio_sample;

// Assign IO
assign uo_out = 8'b00000000;
assign uio_out = {audio_pdm, 7'b0000000};
assign uio_oe = 8'b10000000;
wire _unused_ok = &{ena, ui_in, uio_in};

`ifdef VERILATOR
  // assign clk_hz = 48000 * 21; // Close enough to 1MHz, but integer factor of 48kHz
  assign clk_hz = 1000000;
  // assign audio_en = 1'b1;
  assign audio_en = 1'b0;
  assign audio_out = {audio_sample, 8'b0};
`endif

pdm #(.N(8)) pdm_gen(
  .clk(clk),
  .rst_n(rst_n),
  .pdm_in(audio_sample),
  .pdm_out(audio_pdm)
);

// ------------------------------

  wire [11:0] voice1;
  wire [11:0] pulse1;
  wire [ 7:0] control1;
  wire [15:0] freq1;
  wire [ 7:0] att_dec;
  wire [ 7:0] sus_rel;

`ifdef VERILATOR
  reg [24:0] counter;
  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  assign freq1 = 16'h1234;
  assign pulse1 = 12'b010000000000;
  wire gate1 = counter[17:0] < (1 << 16);
  assign control1 = {7'b0001000, gate1};
  assign att_dec = 8'h29;
  assign sus_rel = 8'h79;
`else

  // All control signals are dynamic
  assign freq1 = {uio_in, uio_in};
  assign pulse1 = {uio_in[3:0], uio_in};
  assign control1 = ui_in;
  assign att_dec = uio_in;
  assign sus_rel = ui_in;

`endif

  wire msb;
  wire _unused_ok_msb = msb;

  voice #()
      Voice1(
          .clk_1MHz(clk),
          .reset(~rst_n),
          .frequency(freq1),
          .pulsewidth(pulse1),
          .control(control1),
          .Att_dec(att_dec),
          .Sus_Rel(sus_rel),
          .PA_MSB_in(),
          .PA_MSB_out(msb),
          .voice(voice1)
      );
    assign audio_sample = voice1 >> 4;
  
endmodule
