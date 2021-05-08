`ifndef DISSER_MACRO
`define DISSER_MACRO


`ifndef FORCE_REGISTER_PROTECTION
//macro that install register with hamming code based fault-tolerance method. 
//set _register name_, _register lenght_, _clock signal name_, _reset signal_ 
//then use functions [name]_reset, [name]_write, [name]_releaseWE, output signal - [name]_out
//`define HAMMING_REG(name,len,clk_sign,rstN_sign)\
`define HAMMING_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
hamming_register #(.p_dataSize(len)) name``_hr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out), .uncorrectableError(), .correctableError());\
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
//begin: name``_definition\
//end: name``_definition
//hamming_register #(.p_dataSize(len), .p_zeroWordDetection(0)) name``_hr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out), .uncorrectableError(), .correctableError());\








`define MJR_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
mjr_register #(.p_dataSize(len)) name``_mjr (.clk(clk_sign), .rstN(rstN_sign), .WE(name``_WE), .inputData_1(name``_inpReg), .inputData_2(name``_inpReg), .inputData_3(name``_inpReg), .outputData(name``_out),.correctableError());\
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
register #(.p_dataSize(len)) name``_sr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out));\
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

`else //FORCE_REGISTER_PROTECTION

`ifdef FORCE_HAMMING_REG

`define HAMMING_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
hamming_register #(.p_dataSize(len)) name``_hr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out), .uncorrectableError(), .correctableError());\
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

`define MJR_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
hamming_register #(.p_dataSize(len)) name``_hr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out), .uncorrectableError(), .correctableError());\
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
hamming_register #(.p_dataSize(len)) name``_hr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out), .uncorrectableError(), .correctableError());\
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
`endif //FORCE_HAMMING_REG

`ifdef FORCE_MJR_REG

`define HAMMING_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
mjr_register #(.p_dataSize(len)) name``_mjr (.clk(clk_sign), .rstN(rstN_sign), .WE(name``_WE), .inputData_1(name``_inpReg), .inputData_2(name``_inpReg), .inputData_3(name``_inpReg), .outputData(name``_out),.correctableError());\
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


`define MJR_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
mjr_register #(.p_dataSize(len)) name``_mjr (.clk(clk_sign), .rstN(rstN_sign), .WE(name``_WE), .inputData_1(name``_inpReg), .inputData_2(name``_inpReg), .inputData_3(name``_inpReg), .outputData(name``_out),.correctableError());\
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
mjr_register #(.p_dataSize(len)) name``_mjr (.clk(clk_sign), .rstN(rstN_sign), .WE(name``_WE), .inputData_1(name``_inpReg), .inputData_2(name``_inpReg), .inputData_3(name``_inpReg), .outputData(name``_out),.correctableError());\
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

`endif //FORCE_MJR_REG


`ifdef FORCE_SIMPLE_REG

`define HAMMING_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
register #(.p_dataSize(len)) name``_sr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out));\
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


`define MJR_REGISTER(name,len,clk_sign,rstN_sign)\
logic [len-1:0] name``_inpReg;\
logic name``_WE;\
wire [len-1:0] name``_out;\
register #(.p_dataSize(len)) name``_sr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out));\
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
register #(.p_dataSize(len)) name``_sr(.clk(clk_sign), .rstN(rstN_sign), .inputData(name``_inpReg), .WE(name``_WE), .outputData(name``_out));\
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

`endif //FORCE_SIMPLE_REG


`endif //FORCE_REGISTER_PROTECTION


`endif //DISSER_MACRO
