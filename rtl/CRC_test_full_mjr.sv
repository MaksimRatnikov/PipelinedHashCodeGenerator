module CRC_test_full_mjr
#(
        parameter p_len=300,
        parameter p_width = 8,           // polynom and registers width
        parameter p_polynom=8'h31,     
        parameter p_inp_data_len = 8,   // if inp_data_len == 1  - CRC use  default input constant
        parameter p_curr_data_len = 8,  // real input width (for cinstant or input pin data)
        parameter p_FPGA_CELL_big = 1  // 0 - if FPGA cell doesnt apply full function,  1 - for one cell at function 
     )
    (
        input                           clk,
        input                           rstN,
        input [p_inp_data_len-1:0]      inp_data_1,
        input [p_inp_data_len-1:0]      inp_data_2,
        input [p_inp_data_len-1:0]      inp_data_3,
        output logic [p_width-1:0]      outp_data
     );



wire  [p_width-1:0]      outp_data_1, outp_data_2, outp_data_3 ;
CRC_test #(
            .p_len(p_len),
            .p_width(p_width),
            .p_polynom(p_polynom),
            .p_inp_data_len(p_inp_data_len),
            .p_curr_data_len(p_curr_data_len),
            .p_FPGA_CELL_big(p_FPGA_CELL_big)
            ) CRC_1 
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data_1),
        .outp_data(outp_data_1)
        );
CRC_test #(
            .p_len(p_len),
            .p_width(p_width),
            .p_polynom(p_polynom),
            .p_inp_data_len(p_inp_data_len),
            .p_curr_data_len(p_curr_data_len),
            .p_FPGA_CELL_big(p_FPGA_CELL_big)
            ) CRC_2 
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data_2),
        .outp_data(outp_data_2)
        );
CRC_test #(
            .p_len(p_len),
            .p_width(p_width),
            .p_polynom(p_polynom),
            .p_inp_data_len(p_inp_data_len),
            .p_curr_data_len(p_curr_data_len),
            .p_FPGA_CELL_big(p_FPGA_CELL_big)
            ) CRC_3 
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data_3),
        .outp_data(outp_data_3)
        );


mjr #(.p_width(p_width+1))   MJR (
                                        .dataInput1(outp_data_1), 
                                        .dataInput2(outp_data_2), 
                                        .dataInput3(outp_data_3),
                                        .errorInData(correctableError),
                                        .errorInChannel1(), 
                                        .errorInChannel2(), 
                                        .errorInChannel3(),
                                        .errorVector(),
                                        .dataOutput(outp_data)


    );
/*
module CRC_test     
    #(
        parameter p_len=3,
        parameter p_width = 8,           // polynom and registers width
        parameter p_polynom=8'h31,     
        parameter p_inp_data_len = 1,   // if inp_data_len == 1  - CRC use  default input constant
        parameter p_curr_data_len = 8,  // real input width (for cinstant or input pin data)
        parameter p_FPGA_CELL_big = 1  // 0 - if FPGA cell doesnt apply full function,  1 - for one cell at function 
     )
    (
        input                           clk,
        input                           rstN,
        input [p_inp_data_len-1:0]      inp_data,
        output logic [p_width-1:0]      outp_data
     );
    */
endmodule
