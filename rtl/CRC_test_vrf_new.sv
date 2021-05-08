module CRC_test_vrf();
localparam p_width = 8;
localparam p_inp_data = 8'b00110000;
parameter p_inp_data_len  = 8;
logic clk;
logic rstN;
logic [p_width-1:0] inp_data;
logic [p_width-1:0] data;
int cnt=0;
initial
    begin
        clk = 0;
        rstN = 0;
        inp_data = 0;
        $display("Reset enable");
        repeat (10) @(posedge clk);
        $display("Reset disable");
        rstN=1;
        @(posedge clk);
        $display("Set intp data: 0x%h", p_inp_data);
        inp_data = p_inp_data;
        repeat (64) @(posedge clk);
        $display("Outp data: 0x%h", data);
        $display("Set intp data: 0x%h", ~p_inp_data);
        inp_data = ~p_inp_data;
        repeat (128) @(posedge clk);
        $display("Outp data: 0x%h", data);
    end

always 
    begin
        #5;
        clk=~clk;
    end
always @ (posedge clk)
    begin
        cnt = cnt +1;   
    end


CRC_test    #(.p_len(32), .p_width(p_width), .p_polynom(8'h31), .p_inp_data_len(p_inp_data_len),   .p_FPGA_CELL_big(1) )
     CRC
    (
        .clk(clk),
        .rstN(rstN),
        .inp_data(inp_data),
        .outp_data(data)
     );




endmodule
