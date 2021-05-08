
`ifndef UNIVERSAL_REG_MIX_SV
`define UNIVERSAL_REG_MIX_SV


//`define REG_PROTECTION_HAMMING
//`define REG_PROTECTION_MJR
module  universal_reg_mix
    #(
        parameter p_width=32,        
        parameter p_width_protected=1
        )
    (
        input               clk,
        input               rstN,
        input [p_width-1:0] inp_data,
        input               WE,
        output logic [p_width-1:0] outp_data
        );

parameter p_HAMM_zeroWordDetection=1;


parameter p_width_unprotected = p_width - p_width_protected;

wire [p_width_protected-1:0] inp_protected;
wire [p_width_unprotected-1:0] inp_unprotected;

wire [p_width_protected-1:0] outp_protected;
wire [p_width_unprotected-1:0] outp_unprotected;

assign inp_protected[p_width_protected-1:0] = inp_data[p_width_protected-1:0];
assign inp_unprotected[p_width_unprotected-1:0] = inp_data[p_width-1:p_width_protected];

assign outp_data[p_width_protected-1:0]       = outp_protected[p_width_protected-1:0];
assign outp_data[p_width-1:p_width_protected] = outp_unprotected[p_width_unprotected-1:0];

// PROTECTED PART
`ifdef REG_PROTECTION_HAMMING
hamming_register #(.p_dataSize(p_width_protected), .p_zeroWordDetection(1)) REG_HAMM
        (
            .clk(clk),
            .rstN(rstN),
            .WE(WE),
            .inputData(inp_protected),
            .outputData(outp_protected),
            .uncorrectableError(),
            .correctableError()
            );
`else
    `ifdef REG_PROTECTION_MJR
    ////pragma attribute REG__MJR dont___touch true
    mjr_register #(.p_dataSize(p_width_protected)) REG_MJR
    (
        .clk(clk),
        .rstN(rstN),
        .WE(WE),
        .inputData_1(inp_protected), 
        .inputData_2(inp_protected), 
        .inputData_3(inp_protected),
        .outputData(outp_protected),
        .correctableError()
     );
    `else
        register #(.p_dataSize(p_width_protected)) REG_SIMPLE
        (
            .clk(clk),
            .rstN(rstN),
            .WE(WE),
            .inputData(inp_protected),
            .outputData(outp_protected)
            );
    `endif
`endif


// UNPROTECTED PART
register #(.p_dataSize(p_width_unprotected)) REG_UNPROTECTED
        (
            .clk(clk),
            .rstN(rstN),
            .WE(WE),
            .inputData(inp_unprotected),
            .outputData(outp_unprotected)
            );
endmodule

`endif //UNIVERSAL_REG_SV
