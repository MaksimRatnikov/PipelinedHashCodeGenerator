
`ifndef G_HAMMINGENCODER
`define G_HAMMINGENCODER

`include "D:/Projects/disser/G_RD_PROJ_functions.sv"

module G_HammingEncoder
#
(
parameter p_dataSize=10
)
(
input [p_dataSize-1:0] dataIn,
output logic [p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize):0] dataOut
);

localparam p_eccBitsQnty=G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize);
localparam p_outputSize=p_dataSize+p_eccBitsQnty+1;

int dataBitsCntr;
bit [p_outputSize:0] mask;

always_comb
begin: main_proc
	dataBitsCntr=0;
	mask=1;
	dataOut='0;
    for(int i=1;i<p_outputSize;i++)
    begin: place_data_bits_in_output_vector
    	if((i&mask)==0) begin dataOut[i-1]=dataIn[dataBitsCntr]; dataBitsCntr++; end ///!!!!!!!!!!!!!!
        else mask<<=1;
    end: place_data_bits_in_output_vector
    
    mask=1;
    for(int i=0;i<p_eccBitsQnty;i++)
    begin: calculate_ecc_bits
    	for(int j=1;j<p_outputSize;j++)
    	begin
    		if(((mask&j)!=0)&&(mask!=j)) dataOut[mask-1]^=dataOut[j-1];
    	end
    	mask<<=1;
    end: calculate_ecc_bits
    
    dataOut[p_outputSize-1]=(^dataOut[p_outputSize-2:0]);
end: main_proc
	
endmodule: G_HammingEncoder

`endif //G_HAMMINGENCODER
