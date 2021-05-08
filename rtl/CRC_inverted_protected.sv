
`ifndef CRC_INVERTED_PROTECTED
`define CRC_INVERTED_PROTECTED
`include "D:/Projects/disser/G_RD_PROJ_functions.sv"
module CRC_inverted_protected
    #(
        parameter p_width=8,
        parameter p_polynom=8'h31,
        parameter p_sync = 1,
        parameter p_FPGA_CELL_big = 0  // 0 - if FPGA cell doesnt apply full function,  1 - for one cell at function 
     )
    (
        input                           clk,
        input                           rstN,
        input [p_width-1:0]             prev_data,
        input                           prev_sign,
        input                           curr_data_bit,
        output logic [p_width-1:0]      next_data,
        output logic                    next_sign
     );
genvar j;

// -------------------------------
`ifdef REG_PROTECTION_HAMMING

import G_RD_PROJ_functions::*;
localparam p_ecc_reg_len = p_width+1+ECC_bitsQnty(p_width+1);
localparam p_zeroWordDetection = 0;
wire    [p_width-1:0]           next_data_wire;
wire                            next_sign_wire;
wire    [p_width:0]             data_to_coder; 
wire    [p_width:0]             data_from_decoder;
wire    [p_ecc_reg_len:0]     coded_data;
logic   [p_ecc_reg_len:0]     register;

assign next_data_wire[p_width-1:1]  = (prev_sign == 1'b1)? (prev_data[p_width-2:0] ^ p_polynom[p_width-2:0]):(prev_data[p_width-2:0]);
assign next_data_wire[0]            = curr_data_bit;
assign next_sign_wire               = (prev_sign == 1'b1)? (prev_data[p_width-1] ^ p_polynom[p_width-1]):(prev_data[p_width-1]);
assign data_to_coder                = {next_sign_wire, next_data_wire};
assign next_sign                    = data_from_decoder[p_width];
assign next_data[p_width-1:0]       = data_from_decoder[p_width-1:0];
//pragma attribute register dont_touch true

G_HammingEncoder #(.p_dataSize(p_width+1)) ENCOD
                                            (
                                                .dataIn(data_to_coder),
                                                .dataOut(coded_data)
                                            );


G_HammingDecoder #(.p_dataSize(p_width+1), .p_zeroWordDetection(p_zeroWordDetection)) DECOD
                                            (
                                                .dataIn(register),
                                                .dataOut(data_from_decoder),
                                                .dataOutWithECC(),
                                                .error(),
                                                .uncorrectable()
                                            );
always_ff @ (posedge clk)
    if (!rstN)
        begin
            register <= '0;
        end
    else
        begin
            register <= coded_data;
        end
`endif  // REG_PROTECTION_HAMMING



`ifdef REG_PROTECTION_MJR
wire    [p_width-1:0]           next_data_wire;
wire                            next_sign_wire;
wire    [p_width:0]             data_to_coder; 
wire    [p_width:0]             data_from_decoder;

wire      [p_width:0]     register_1, register_2, register_3;
assign next_data_wire[p_width-1:1]  = (prev_sign == 1'b1)? (prev_data[p_width-2:0] ^ p_polynom[p_width-2:0]):(prev_data[p_width-2:0]);
assign next_data_wire[0]            = curr_data_bit;
assign next_sign_wire               = (prev_sign == 1'b1)? (prev_data[p_width-1] ^ p_polynom[p_width-1]):(prev_data[p_width-1]);
assign data_to_coder                = {next_sign_wire, next_data_wire};
assign next_sign                    = data_from_decoder[p_width];
assign next_data[p_width-1:0]       = data_from_decoder[p_width-1:0];


mjr #(.p_width(p_width+1))   MJR (
                                        .dataInput1(register_1), 
                                        .dataInput2(register_2), 
                                        .dataInput3(register_3),
                                        .errorInData(correctableError),
                                        .errorInChannel1(), 
                                        .errorInChannel2(), 
                                        .errorInChannel3(),
                                        .errorVector(),
                                        .dataOutput(data_from_decoder)


    );

triple_register # (.p_width(p_width+1))  T_REG
            (
                    .clk(clk),
                    .rstN(rstN),
                    .inpdata_1(data_to_coder),
                    .inpdata_2(data_to_coder),
                    .inpdata_3(data_to_coder),
                    .outp_data_1(register_1),
                    .outp_data_2(register_2),
                    .outp_data_3(register_3)
                );

`endif  // REG_PROTECTION_MJR






`ifndef REG_PROTECTION_HAMMING
`ifndef REG_PROTECTION_MJR
generate
if (p_sync == 1)
    begin: synced
        if (p_FPGA_CELL_big == 1)
            begin: big_cell
                always_ff @ (posedge clk)
                    if (!rstN)
                        begin
                            next_data   <= 'b0;
                            next_sign   <= 'b0;
                        end
                    else
                        begin
                            if (prev_sign == 1'b1)
                                begin
                                    next_data[p_width-1:1]  <= prev_data[p_width-2:0] ^ p_polynom[p_width-2:0];
                                    next_data[0]            <= curr_data_bit;
                                    next_sign               <= prev_data[p_width-1] ^ p_polynom[p_width-1]; 
                                end
                            else
                                begin
                                    next_data[p_width-1:1]  <= prev_data[p_width-2:0];
                                    next_data[0]            <= curr_data_bit;
                                    next_sign               <= prev_data[p_width-1];
                                end
                        end
           end: big_cell
        else
            begin: small_cell
                logic[p_width-1:0] tmp_val;
                logic[p_width-1:0] prev_data_saved;
                always_ff @ (posedge clk)
                    if (!rstN)
                        begin
                            next_data   <= 'b0;
                            next_sign   <= 'b0;
                            tmp_val     <= 'b0;
                        end
                    else
                        begin
                            for (int i=0; i<p_width; i=i+1)
                                begin
                                    tmp_val[i] <= prev_sign & p_polynom[i];
                                end
                            prev_data_saved         <= prev_data;
                            next_data [p_width-1:1] <= tmp_val[p_width-2:0] ^ prev_data_saved[p_width-2:0];
                            next_data [0]           <= curr_data_bit;
                            next_sign               <= tmp_val[p_width-1] ^ prev_data_saved[p_width-1];            
                        end
            end: small_cell
       end: synced
    else
        begin: asynced
            if (p_FPGA_CELL_big == 1)
                begin: big_cell
                    always_comb                   
                        begin
                            if (prev_sign == 1'b1)
                                begin
                                    next_data[p_width-1:1]  <= prev_data[p_width-2:0] ^ p_polynom[p_width-2:0];
                                    next_data[0]            <= curr_data_bit;
                                    next_sign               <= prev_data[p_width-1] ^ p_polynom[p_width-1]; 
                                end
                            else
                                begin
                                    next_data[p_width-1:1]  <= prev_data[p_width-2:0];
                                    next_data[0]            <= curr_data_bit;
                                    next_sign               <= prev_data[p_width-1];
                                end
                        end
               end: big_cell
            else
                begin: small_cell
                   
                    wire [p_width-1:0] tmp_val ;
                    for (j=0; j<p_width; j=j+1)
                        begin
                            assign tmp_val[j] = prev_sign & p_polynom[j];
                        end
                    wire [p_width-1:0] prev_data_saved = prev_data;
                    always_comb 
                         begin
                               
                                next_data [p_width-1:1] <= tmp_val[p_width-2:0] ^ prev_data_saved[p_width-2:0];
                                next_data [0]           <= curr_data_bit;
                                next_sign               <= tmp_val[p_width-1] ^ prev_data_saved[p_width-1];            
                            end
                end: small_cell
        end: asynced
endgenerate
`endif // REG_PROTECTION_MJR
`endif // REG_PROTECTION_HAMMING
endmodule

`endif //CRC_INVERTED_PROTECTED
