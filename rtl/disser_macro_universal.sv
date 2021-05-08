
`ifndef DISSER_MACRO
`define DISSER_MACRO


//`define PROJECT_PATH


`define MJR_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
universal_reg #(.p_dataSize(len)) name``_mjr (.clk(clk_sign), .rstN(rstN_sign), .WE(name``_WE), .inputData_1(name``_inpReg), .inputData_2(name``_inpReg), .inputData_3(name``_inpReg), .outputData(name``_out),.correctableError());\
function void name``_write(logic [len-1:0] data);\
    name``_inpReg = data;\
    name``_WE = 1'b1;\
endfunction : name``_write\
function void name``_reset();\
    name``_inpReg = '0;\
    name``_WE = '0;\
endfunction : name``_reset\
function void name``_releaseWE();\
    name``_WE = '0;\
endfunction : name``_releaseWE




`define SIMPLE_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
universal_reg #(.p_dataSize(len)) name``_sr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out));\
function void name``_write(logic [len-1:0] data);\
    name``_inpReg = data;\
    name``_WE = 1'b1;\
endfunction : name``_write\
function void name``_reset();\
    name``_inpReg = '0;\
    name``_WE = '0;\
endfunction : name``_reset\
function void name``_releaseWE();\
    name``_WE = '0;\
endfunction : name``_releaseWE
`endif //DISSER_MACRO
