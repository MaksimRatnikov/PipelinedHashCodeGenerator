module CRC_test_vrf();
localparam p_width = 8;
localparam p_inp_data = 8'b00110000;
parameter p_inp_data_len  = 8;
logic clk;
logic rstN;
logic [p_width-1:0] data;
int cnt=0;
int cnt2=0;
initial
    begin
        clk = 0;
        rstN = 0;
    end

always 
    begin
        #5;
        clk=~clk;
    end
always @ (posedge clk)
    begin
        if (cnt<10)
            begin
                cnt = cnt +1;
                rstN=0;
            end
        else
            begin
                rstN=1;
                cnt2 = cnt2+1;
            end
		
    end


CRC_test    #(.p_len(128), .p_width(p_width), .p_polynom(8'h31), .p_inp_data_len(p_inp_data_len),   .p_FPGA_CELL_big(1) )
     CRC
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(p_inp_data),
        .outp_data(data)
     );




endmodule
