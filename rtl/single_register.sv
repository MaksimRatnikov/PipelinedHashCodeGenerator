
module single_register 
        #(
        parameter p_width=8
        )

    (
        input                       clk,
        input                       rstN,
        input  [p_width-1:0]        inpdata,
        output logic [p_width-1:0]  outp_data
                );

logic   [p_width-1:0]     register;
  ////pragma attribute register dont_touch true
////pragma attribute inpdata dont_touch true
////pragma attribute outp_data dont_touch true

assign outp_data = register;

always_ff @ (posedge clk)
    if (!rstN)
        begin
            register <= '0;
        end
    else
        begin
            register <= inpdata;            
        end
endmodule
