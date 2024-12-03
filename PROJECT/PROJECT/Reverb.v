// Reverb 模块定义（Schroeder 混响）
module Reverb(
    input clk,
    input reset,
    input signed [15:0] din,
    output signed [15:0] dout
);
    // 实例化 5 个 CombFilter
    wire signed [15:0] comb_out0;
    wire signed [15:0] comb_out1;
    wire signed [15:0] comb_out2;
    wire signed [15:0] comb_out3;
    wire signed [15:0] comb_out4;
    
    CombFilter #(.DELAY(3000),  .FEEDBACK(16'sd22937)) comb0 (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dout(comb_out0)
    );
    
    CombFilter #(.DELAY(5000),  .FEEDBACK(16'sd22937)) comb1 (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dout(comb_out1)
    );
    
    CombFilter #(.DELAY(7000),  .FEEDBACK(16'sd22937)) comb2 (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dout(comb_out2)
    );
    
    CombFilter #(.DELAY(9000),  .FEEDBACK(16'sd22937)) comb3 (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dout(comb_out3)
    );
    
    CombFilter #(.DELAY(11000), .FEEDBACK(16'sd22937)) comb4 (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dout(comb_out4)
    );
    
    // 合并所有 CombFilter 的输出
    wire signed [16:0] comb_sum;
    assign comb_sum = comb_out0 + comb_out1 + comb_out2 + comb_out3 + comb_out4;
    
    // 简单缩放以防溢出
    assign dout = comb_sum >>> 3; // 相当于除以 8

endmodule