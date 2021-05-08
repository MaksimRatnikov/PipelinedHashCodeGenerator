`ifndef MJR_REGISTER
`define MJR_REGISTER

`include "D:/Projects/disser/mjr.sv"


module mjr_register 
    #(
        parameter p_dataSize=1
     )
    (
        input clk,
        input rstN,
        input WE,
        input [p_dataSize-1:0] inputData_1, inputData_2, inputData_3,
        output logic [p_dataSize-1:0] outputData,
      // output logic uncorrectableError,
        output logic correctableError
     );

logic [p_dataSize-1:0] register_1, register_2, register_3;
wire [p_dataSize-1:0]  outpData;

assign outputData =  outpData;

mjr #(.p_width(p_dataSize))   MJR (
                                        .dataInput1(register_1), 
                                        .dataInput2(register_2), 
                                        .dataInput3(register_3),
                                        .errorInData(correctableError),
                                        .errorInChannel1(), 
                                        .errorInChannel2(), 
                                        .errorInChannel3(),
                                        .errorVector(),
                                        .dataOutput(outpData)


    );

always_ff @ (posedge clk)
    if (!rstN)
        begin
            register_1<='0;
            register_2<='0;
            register_3<='0;
        end
    else
        begin
            if (!WE)
                begin: rewrite_reg
                    register_1<=outpData;
                    register_2<=outpData;
                    register_3<=outpData;
                end: rewrite_reg
            else
                begin: write_reg
                    register_1<=inputData_1;
                    register_2<=inputData_2;
                    register_3<=inputData_3;
                end: write_reg


        end

endmodule



`endif // MJR_REGISTER
