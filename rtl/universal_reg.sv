`ifndef UNIVERSAL_REG_SV
`define UNIVERSAL_REG_SV


//`define REG_PROTECTION_HAMMING
//`define REG_PROTECTION_MJR

`ifndef USE_INIVERSAL_REG_WRAPPER
module  universal_reg
    #(
        parameter p_width=32        
        )
    (
        input               clk,
        input               rstN,
        input [p_width-1:0] inp_data,
        input               WE,
        output logic [p_width-1:0] outp_data
        );
`else
    module  universal_reg
    #(
        parameter p_dataSize=32        
        )
    (
        input               clk,
        input               rstN,
        input [p_dataSize-1:0] inputData,
        input               WE,
        output wire uncorrectableError,
        output wire correctableError,
        /*`ifdef REG_PROTECTION_HAMMING
        output wire uncorrectableError,
        output wire correctableError,
        `endif
        `ifdef REG_PROTECTION_MJR
        output wire correctableError,
        `endif*/
        output wire  [p_dataSize-1:0] outputData
        );
parameter p_width = p_dataSize;
wire [p_width-1:0] inp_data;
wire [p_width-1:0] outp_data;
assign outputData[p_width-1:0] = outp_data[p_width-1:0];
assign inp_data[p_width-1:0] = inputData[p_width-1:0];
//`ifdef REG_PROTECTION_HAMMING
assign uncorrectableError = 1'b0;
assign correctableError = 1'b0;
/*`endif
`ifdef REG_PROTECTION_MJR
assign correctableError = 1'b0;
`endif
*/
`endif //USE_INIVERSAL_REG_WRAPPER 

parameter p_HAMM_zeroWordDetection=1;

`ifdef REG_PROTECTION_HAMMING
hamming_register #(.p_dataSize(p_width), .p_zeroWordDetection(1)) REG_HAMM
        (
            .clk(clk),
            .rstN(rstN),
            .WE(WE),
            .inputData(inp_data),
            .outputData(outp_data),
            .uncorrectableError(),
            .correctableError()
            );
`else
    `ifdef REG_PROTECTION_MJR
    ////pragma attribute REG__MJR d_ont_touch true
    ////pragma attribute REG_MJR noopt true
    ////pragma attribute REG__MJR r_eserve_cell true
    mjr_register #(.p_dataSize(p_width)) REG_MJR
    (
        .clk(clk),
        .rstN(rstN),
        .WE(WE),
        .inputData_1(inp_data), 
        .inputData_2(inp_data), 
        .inputData_3(inp_data),
        .outputData(outp_data),
        .correctableError()
     );
    `else
        register #(.p_dataSize(p_width)) REG
        (
            .clk(clk),
            .rstN(rstN),
            .WE(WE),
            .inputData(inp_data),
            .outputData(outp_data)
            );
    `endif
`endif

endmodule

`endif //UNIVERSAL_REG_SV
