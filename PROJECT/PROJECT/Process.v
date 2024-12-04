module Process (
    CLK,
    RST,
    ADC_STBR, ADC_STBL,
    chipselect_n,
    write_n,
    read_n,
    readdata,
    writedata,
    address,
    PRO
);
input wire CLK;
input wire RST;
input wire ADC_STBR, ADC_STBL;
inout wire chipselect_n;
inout wire write_n;
inout wire read_n;
input wire [15:0] readdata;
output wire [15:0] writedata;
inout wire [19:0] address;
input wire PRO;



endmodule