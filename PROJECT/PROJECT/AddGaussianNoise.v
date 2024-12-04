module AddGaussianNoise (
    input wire CLK,                // Clock signal
    input wire RST,                // Reset signal
    input wire [15:0] audio_in,    // Input audio signal
    output reg [15:0] audio_out,   // Output audio signal with noise
    input wire [7:0] SNR            // Signal-to-Noise Ratio in dB
);

    // LFSR parameters
    reg [15:0] lfsr;
    wire feedback = lfsr[15] ^ lfsr[14] ^ lfsr[13] ^ lfsr[11];

    // Generate pseudo-random number
    always @(posedge CLK or negedge RST) begin
        if (!RST)
            lfsr <= 16'h1;
        else
            lfsr <= {lfsr[14:0], feedback};
    end

    // Convert pseudo-random number to noise value
    wire signed [15:0] noise;
    assign noise = (lfsr[15] ? -1 : 1) * (lfsr[14:0] >> 6); // Map to -512 to +511

    // Calculate noise gain based on SNR
    // SNR(dB) = 10 * log10(P_signal / P_noise)
    // P_noise = P_signal / (10^(SNR/10))
    // Simplified using a fixed ratio
    wire signed [15:0] scaled_noise;
    assign scaled_noise = noise * (1 << (SNR / 10));

    // Add noise to input signal
    always @(posedge CLK or negedge RST) begin
        if (!RST)
            audio_out <= 16'd0;
        else begin
            // Prevent overflow
            if ((audio_in + scaled_noise) > 16'd32767)
                audio_out <= 16'd32767;
            else if ((audio_in + scaled_noise) < -16'd32768)
                audio_out <= -16'd32768;
            else
                audio_out <= audio_in + scaled_noise;
        end
    end

endmodule