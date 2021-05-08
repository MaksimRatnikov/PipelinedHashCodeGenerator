
module register 
    #(
        parameter p_dataSize=1
     )
    (   
        input clk,
        input rstN,
        input WE,
        input [p_dataSize-1:0] inputData,
        output logic [p_dataSize-1:0] outputData

        );


logic  [p_dataSize-1:0]   data_register;
assign outputData = data_register;

always_ff @ (posedge clk)
    if (!rstN)
        begin
            data_register <='0;
        end
    else
        begin
            if (WE)
                begin
                    data_register<=inputData;
                end
            else
                begin
                    data_register<=data_register;
                end
        end
endmodule
