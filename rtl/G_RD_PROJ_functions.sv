`ifndef G_RD_PROJ_FUNCTIONS
`define G_RD_PROJ_FUNCTIONS

package G_RD_PROJ_functions;
		
//Computes log2 function of int argument and returns int result
function automatic int log2 (int arg);
bit [$bits(int)-1:0] argBitwise;
begin
  argBitwise=arg;
  for(int i=$bits(int)-1;i>=0;i--)
    begin
      if(argBitwise[i]==1) return(i+1);
    end
end
endfunction: log2

function automatic int ECC_bitsQnty(int m);
   //int tmp = 1;
    for (int i=1; i<32; i++)
        begin
            if ((2**i)>=m+i+1)
                begin
                    return i;
                end
        end
endfunction


	
endpackage: G_RD_PROJ_functions

`endif //G_RD_PROJ_FUNCTIONS
