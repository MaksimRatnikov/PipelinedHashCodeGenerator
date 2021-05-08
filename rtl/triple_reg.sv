module triple_register 
        #(
        parameter p_width=8
        )

    (
        input                       clk,
        input                       rstN,
        input  [p_width-1:0]        inpdata_1,
                                    inpdata_2,
                                    inpdata_3,
        output logic [p_width-1:0]  outp_data_1,
                                    outp_data_2,
                                    outp_data_3
        );

logic   [p_width-1:0]     register_1, register_2, register_3;
  ////pragma attribute register_1 dont_touch true
  ////pragma attribute register_2 dont_touch true
  ////pragma attribute register_3 dont_touch true

assign outp_data_1 = register_1;
assign outp_data_2 = register_2;
assign outp_data_3 = register_3;

always_ff @ (posedge clk)
    if (!rstN)
        begin
            register_1 <= '0;
            register_2 <= '1;
            //register_3 <= '0;
        end
    else
        begin
            register_1 <= inpdata_1;
            register_2 <= inpdata_2;
            register_3 <= inpdata_3;
        end
endmodule




module triple_register_we
        #(
        parameter p_width=8
        )

    (
        input                       clk,
        input                       rstN,
        input                       we,
        input  [p_width-1:0]        inpdata_1,
                                    inpdata_2,
                                    inpdata_3,
        output logic [p_width-1:0]  outp_data_1,
                                    outp_data_2,
                                    outp_data_3
        );

logic   [p_width-1:0]     register_1, register_2, register_3;
  ////pragma attribute register_1 dont_touch true
  ////pragma attribute register_2 dont_touch true
  ////pragma attribute register_3 dont_touch true

assign outp_data_1 = register_1;
assign outp_data_2 = register_2;
assign outp_data_3 = register_3;

always_ff @ (posedge clk)
    if (!rstN)
        begin
            register_1 <= '0;
            register_2 <= '1;
            //register_3 <= '0;
        end
    else
        begin
            register_1 <= inpdata_1;
            register_2 <= inpdata_2;
            register_3 <= inpdata_3;
        end
endmodule

