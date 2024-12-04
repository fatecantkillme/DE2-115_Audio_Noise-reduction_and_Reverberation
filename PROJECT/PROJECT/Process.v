module Process (
    CLK,
    RST,
    ADC_STBR, ADC_STBL,
    readdata,
    writedata,
    address,
    PRO
);
input wire CLK;
input wire RST;
input wire ADC_STBR, ADC_STBL;
input wire [15:0] readdata;
output wire [15:0] writedata;
inout wire [19:0] address;
input wire PRO;



endmodule