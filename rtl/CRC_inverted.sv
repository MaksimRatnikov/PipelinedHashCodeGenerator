module CRC_inverted
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
endmodule
