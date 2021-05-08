`ifndef HAMMING_REGISTER_SV
`define HAMMING_REGISTER_SV

`include "D:/Projects/disser/G_RD_PROJ_functions.sv"


module hamming_register 
    #(
        parameter p_dataSize=5,
        parameter p_zeroWordDetection=0
     )
    (
        input clk,
        input rstN,
        input WE,
        input [p_dataSize-1:0] inputData,
        output logic [p_dataSize-1:0] outputData,
        output logic uncorrectableError,
        output logic correctableError
     );


logic [p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize):0] hammingValue;
wire [p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize):0] valueWithECCfromENCOD;
wire [p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize):0] valueWithECCfromDECOD;


G_HammingEncoder #(.p_dataSize(p_dataSize)) ENCOD
                                            (
                                                .dataIn(inputData),
                                                .dataOut(valueWithECCfromENCOD)
                                            );



G_HammingDecoder #(.p_dataSize(p_dataSize), .p_zeroWordDetection(p_zeroWordDetection)) DECOD
                                            (
                                                .dataIn(hammingValue),
                                                .dataOut(outputData),
                                                .dataOutWithECC(valueWithECCfromDECOD),
                                                .error(correctableError),
                                                .uncorrectable(uncorrectableError)
                                            );


always_ff @ (posedge clk)
    if (!rstN)
        begin
            hammingValue <= '0;
        end
    else
        begin
            if (!WE)
                begin
                    if (uncorrectableError==0)
                        begin 
                            hammingValue <= valueWithECCfromDECOD;
                        end
                    else
                        begin
                        end
                end
            else
                begin
                    hammingValue <= valueWithECCfromENCOD;
                end
        end


endmodule
`endif //HAMMING_REGISTER_SV
