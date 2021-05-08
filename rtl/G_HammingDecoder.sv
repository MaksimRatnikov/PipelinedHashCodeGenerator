
`ifndef G_HAMMINGDECODER
`define G_HAMMINGDECODER

`include "D:/Projects/disser/G_RD_PROJ_functions.sv"

module G_HammingDecoder
#(
//parameter p_dataSize=32,
parameter p_dataSize=10,
parameter p_zeroWordDetection=1
)
(
input [p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize):0] dataIn,
output logic [p_dataSize-1:0] dataOut,
output logic [p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize):0] dataOutWithECC,
output logic error,
output logic uncorrectable
);

localparam p_eccBitsQnty=G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize);
localparam p_inputSize=p_dataSize+p_eccBitsQnty+1; 

bit [p_dataSize+p_eccBitsQnty:0] dataTmp;
bit [p_eccBitsQnty-1:0] syndrome;
bit [p_inputSize:0] mask;
bit generalParity;
bit bcErr;
bit errEn;
int dataBitsCntr;

task MainProc();
begin
    dataTmp=dataIn;
    generalParity=(^dataIn);
    
 
    mask=1;
    for(int i=0;i<p_eccBitsQnty;i++)
    begin
        for(int j=1;j<p_inputSize;j++)
        begin
            if((mask&j)!=0) syndrome[i]^=dataTmp[j-1];
        end
        mask<<=1;
    end
    
    errEn=(|syndrome);
    
    uncorrectable=0;
    
    if(errEn==0)
    begin
        if(generalParity==1)
        begin
            error=1;
            bcErr=1;
        end
        else bcErr=0;
    end
    else
    begin
        error=1;
        if(generalParity==0) uncorrectable=1;
        else uncorrectable=0;
    end
    
     
    if(bcErr==1)
    begin: binary_control_bit_error
        dataBitsCntr=0;
        mask=1;
        
        for(int i=1;i<p_inputSize;i++)
        begin: place_data_bits_in_output_vector
            if((i&mask)==0) begin dataOut[dataBitsCntr]=dataIn[i-1]; dataBitsCntr++; end
            else mask<<=1;
        end: place_data_bits_in_output_vector
        
        dataOutWithECC=dataIn;
        dataOutWithECC[p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize)]=~dataIn[p_dataSize+G_RD_PROJ_functions::ECC_bitsQnty(p_dataSize)];
    end: binary_control_bit_error
    else
    begin
       if(uncorrectable==0)
        begin
            mask=1;
            dataBitsCntr=0;
            if(errEn==0)
            begin
                for(int i=1;i<p_inputSize;i++)
                begin: place_data_bits_in_output_vector
                    if((i&mask)==0) begin dataOut[dataBitsCntr]=dataIn[i-1]; dataBitsCntr++; end
                    else mask<<=1;
                end: place_data_bits_in_output_vector
                
                dataOutWithECC=dataIn;
            end
            else
            begin
                error=1;
                dataTmp=dataIn;
                dataTmp[syndrome-1]=~dataIn[syndrome-1];
                dataOutWithECC=dataTmp;
                for(int i=1;i<p_inputSize;i++)
                begin: place_data_bits_in_output_vector
                    if((i&mask)==0) begin dataOut[dataBitsCntr]=dataTmp[i-1]; dataBitsCntr++; end
                    else mask<<=1;
                end: place_data_bits_in_output_vector
            end
        end
        else
        begin
            dataOut='0;
            dataOutWithECC='0;
        end 
    end
end
endtask: MainProc

always_comb
begin: main_proc
	dataOut='0;
	mask=1;
	syndrome='0;
    errEn=0;
    error=0;
    bcErr=0;
    
    if(p_zeroWordDetection==1)
    begin
        if(dataIn=='0)
        begin
            dataOut='0;
            dataOutWithECC='0;
            error=1;
            uncorrectable=1;
        end
        else
        begin
            MainProc();
           
        end
    end
    else
    begin
        MainProc();
        
    end
    
end: main_proc
		
	
endmodule: G_HammingDecoder

`endif //G_HAMMINGDECODER

