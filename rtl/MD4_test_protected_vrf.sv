
module MD4_test_protected_vrf();

parameter p_inp_data_len = 32;
parameter p_width = 32;

logic clk;
logic rstN;

logic [p_inp_data_len-1:0]  inp_data;
logic [p_width*4-1:0]       outp_data;

md4_pipe
    #( 
        .p_inp_data_len(p_inp_data_len),
        .p_width(p_width)
        )
        DUT
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data),
        .outp_data(outp_data)
        );
initial
    begin
        clk=1'b0;
        rstN=1'b0;
        inp_data[p_width-1      :0]         = 32'h12345678;
       // inp_data[p_width*2-1    :p_width]   = 32'h12121212;
       // inp_data[p_width*3-1    :p_width*2] = 32'h34343434;
       // inp_data[p_width*4-1    :p_width*3] = 32'h56565656;
        #100ns;
        rstN=1'b1;
    end

always
    #5 clk=~clk;



endmodule: MD4_test_protected_vrf
