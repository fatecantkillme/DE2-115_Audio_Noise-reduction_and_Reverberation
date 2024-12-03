// CombFilter 模块定义
module CombFilter #(
    parameter DELAY = 3000,                  // 延迟长度
    parameter FEEDBACK = 16'sd22937          // 反馈系数 (0.7 * 32767)
)(
    input clk,
    input reset,
    input signed [15:0] din,
    output reg signed [15:0] dout
);
    // 计算地址宽度
    localparam ADDR_WIDTH = $clog2(DELAY);
    
    // 延迟缓冲区
    reg signed [15:0] buffer [0:DELAY-1];
    reg [ADDR_WIDTH-1:0] ptr;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            ptr <= 0;
            dout <= 0;
            // 假设 FPGA 的 Block RAM 在复位时自动清零
        end else begin
            dout <= buffer[ptr];
            buffer[ptr] <= din + ((buffer[ptr] * FEEDBACK) >>> 15);
            ptr <= (ptr + 1) % DELAY;
        end
    end
endmodule