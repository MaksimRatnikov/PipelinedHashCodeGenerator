

module MD4_test_protected_mjr 
    #( 
        parameter p_inp_data_len = 32,
        parameter p_width = 32
        )
    (
        input                           clk,
        input                           rstN,
        input [p_inp_data_len-1:0]      inp_data_1,
        input [p_inp_data_len-1:0]      inp_data_2,
        input [p_inp_data_len-1:0]      inp_data_3,
        output logic                    correctableError,
        output logic [p_width*4-1:0]    outp_data
        );
parameter p_outp_width=p_width*4;
logic [p_outp_width-1:0]    outp_data_1;
logic [p_outp_width-1:0]    outp_data_2;
logic [p_outp_width-1:0]    outp_data_3;


md4_pipe
    #( 
        .p_inp_data_len(p_inp_data_len),
        .p_width(p_width)
        )
        MD4_pipe1
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data_1),
        .outp_data(outp_data_1)
        );

md4_pipe
    #( 
        .p_inp_data_len(p_inp_data_len),
        .p_width(p_width)
        )
        MD4_pipe2
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data_2),
        .outp_data(outp_data_2)
        );

md4_pipe
    #( 
        .p_inp_data_len(p_inp_data_len),
        .p_width(p_width)
        )
        MD4_pipe3
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data_3),
        .outp_data(outp_data_3)
        );

mjr #(.p_width(p_outp_width))   MJR (
                                        .dataInput1(outp_data_1), 
                                        .dataInput2(outp_data_2), 
                                        .dataInput3(outp_data_3),
                                        .errorInData(correctableError),
                                        .errorInChannel1(), 
                                        .errorInChannel2(), 
                                        .errorInChannel3(),
                                        .errorVector(),
                                        .dataOutput(outp_data));
endmodule: MD4_test_protected_mjr
