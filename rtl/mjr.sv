`ifndef MJR
`define MJR
module mjr #(parameter p_width=1)
						(
							input [p_width-1:0] dataInput1, dataInput2, dataInput3,
							output logic errorInChannel1, errorInChannel2, errorInChannel3, errorInData,
							output logic [p_width-1:0] dataOutput,
							output logic [p_width-1:0] errorVector
						);
						
logic [p_width-1:0] error_ch1, error_ch2, error_ch3;


assign errorInChannel1 = | (error_ch1);
assign errorInChannel2 = | (error_ch2);
assign errorInChannel3 = | (error_ch3);
assign errorInData = | (errorVector); 

generate
genvar  i;
for (i=0; i<p_width; i=i+1)
	begin
		assign 	errorVector[i] = error_ch1[i] | error_ch2[i] | error_ch3[i]; 
		assign dataOutput[i]=(dataInput1[i] & dataInput2[i]) 
								| (dataInput1[i] & dataInput3[i])
								| (dataInput2[i] & dataInput3[i]); 
		assign error_ch1[i] = ((!dataInput1[i]) & (dataInput2[i]) & (dataInput3[i])) | ((dataInput1[i]) &  (!dataInput2[i]) & (!dataInput3[i]));
		assign error_ch2[i] = ((dataInput1[i]) & (!dataInput2[i]) & (dataInput3[i])) | ((!dataInput1[i]) & (dataInput2[i]) & (!dataInput3[i])) ; 
		assign error_ch3[i] = ((dataInput1[i]) & (dataInput2[i]) & (!dataInput3[i])) | ((!dataInput1[i]) & (!dataInput2[i]) & (dataInput3[i])) ;
	end
endgenerate


endmodule
`endif





