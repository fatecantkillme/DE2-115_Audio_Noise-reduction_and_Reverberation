module Denoising(
    input wire CLK,                // Clock signal
    input wire RST,                // Reset signal
    input wire [15:0] audio_in,    // Input audio signal
    output reg [15:0] audio_out    // Output denoised audio signal
);

// Wires to connect submodules
wire [15:0] framed_audio;
wire [15:0] windowed_audio;
wire [31:0] fft_output;
wire [31:0] noise_est;
wire [31:0] gain;
wire [31:0] subtracted_fft;
wire [31:0] ifft_output;

// Instantiate Frame Blocking
FrameBlocking frame_block (
    .CLK(CLK),
    .RST(RST),
    .audio_in(audio_in),
    .framed_out(framed_audio)
);

// Instantiate Windowing
Windowing window (
    .CLK(CLK),
    .RST(RST),
    .framed_in(framed_audio),
    .windowed_out(windowed_audio)
);

// Instantiate FFT
FFT fft (
    .CLK(CLK),
    .RST(RST),
    .windowed_in(windowed_audio),
    .fft_out(fft_output)
);

// Instantiate Noise Estimation
NoiseEstimation noise_estimator (
    .CLK(CLK),
    .RST(RST),
    .fft_in(fft_output),
    .noise_out(noise_est)
);

// Instantiate Gain Calculation
GainCalculation gain_calc (
    .CLK(CLK),
    .RST(RST),
    .fft_in(fft_output),
    .noise_in(noise_est),
    .gain_out(gain)
);

// Instantiate Spectral Subtraction
SpectralSubtraction spec_sub (
    .CLK(CLK),
    .RST(RST),
    .fft_in(fft_output),
    .gain_in(gain),
    .fft_sub_out(subtracted_fft)
);

// Instantiate IFFT
IFFT ifft (
    .CLK(CLK),
    .RST(RST),
    .fft_in(subtracted_fft),
    .ifft_out(ifft_output)
);

// Instantiate Overlap-Add
OverlapAdd overlap_add (
    .CLK(CLK),
    .RST(RST),
    .ifft_in(ifft_output),
    .audio_out(audio_out)
);

endmodule