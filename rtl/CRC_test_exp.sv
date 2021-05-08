module CRC_test     
    #(
        parameter p_len=128,
        parameter p_width = 8,           // polynom and registers width
        parameter p_polynom=8'h31,     
        parameter p_inp_data_len = 8,   // if inp_data_len == 1  - CRC use  default input constant
        parameter p_curr_data_len = 8,  // real input width (for cinstant or input pin data)
        parameter p_FPGA_CELL_big = 1  // 0 - if FPGA cell doesnt apply full function,  1 - for one cell at function 
     )
    (
        input                           clk,
        input                           rstN,
        input [p_inp_data_len-1:0]      inp_data,
        output logic [p_width-1:0]      outp_data
     );

wire [p_width-1:0]  data [p_len-1];
wire                sign [p_len-1];

//localparam p_default_data_len = 8;
genvar i;
generate
/*if (p_inp_data_len==1)
    begin
    end
else
    begin
    end*/
//j=0;
wire [p_curr_data_len-1:0] inp_data_wire = (p_inp_data_len == 1)? (8'b00110000) : (inp_data[p_inp_data_len-1:0]);
for (i=0; i<p_len; i=i+1)
    begin
        if ( i == 0)
            begin
                CRC_inverted #(.p_width(p_width), .p_polynom(p_polynom), .p_FPGA_CELL_big(p_FPGA_CELL_big) ) 
                            CRC (
                                .clk(clk),
                                .rstN(rstN),
                                .prev_data(128'd0),
                                .prev_sign('0),
                                //.curr_data_bit(inp_data_wire[i%p_default_data_len]),
                                .curr_data_bit(inp_data_wire[i%p_curr_data_len]),
                                .next_data(data[i]),
                                .next_sign(sign[i])
                            );
            end
        else
            begin
                if (i != p_len-1)
                    begin
                        CRC_inverted #(.p_width(p_width), .p_polynom(p_polynom), .p_FPGA_CELL_big(p_FPGA_CELL_big) ) 
                            CRC (
                                .clk(clk),
                                .rstN(rstN),
                                .prev_data(data[i-1]),
                                .prev_sign(sign[i-1]),
                                //.curr_data_bit(inp_data_wire[i%p_default_data_len]),
                                .curr_data_bit(inp_data_wire[i%p_curr_data_len]),
                                .next_data(data[i]),
                                .next_sign(sign[i])
                            );
                    end
                else
                    begin
                        CRC_inverted #(.p_width(p_width), .p_polynom(p_polynom), .p_FPGA_CELL_big(p_FPGA_CELL_big) ) 
                            CRC (
                                .clk(clk),
                                .rstN(rstN),
                                .prev_data(data[i-1]),
                                .prev_sign(sign[i-1]),
                                //.curr_data_bit(inp_data_wire[i%p_default_data_len]),
                                .curr_data_bit(inp_data_wire[i%p_curr_data_len]),
                                .next_data(outp_data),
                                .next_sign()
                            );
                    end
            end

    end

endgenerate

endmodule
