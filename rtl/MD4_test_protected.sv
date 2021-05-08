
`ifndef MD4_TEST_PROTECTED
`define MD4_TEST_PROTECTED
//
//#define F(x, y, z)			((z) ^ ((x) & ((y) ^ (z))))
//#define G(x, y, z)			(((x) & ((y) | (z))) | ((y) & (z)))
//#define H(x, y, z)			((x) ^ (y) ^ (z))
//
//
//The MD4 transformation for all three rounds.
//
//#define STEP(f, a, b, c, d, x, s) \
//	(a) += f((b), (c), (d)) + (x); \
//	(a) = (((a) << (s)) | (((a) & 0xffffffff) >> (32 - (s))));
//

module md4_F
    #(
        parameter p_width=32
        )
    (
        input   [p_width-1:0]   inp_x,
        input   [p_width-1:0]   inp_y,
        input   [p_width-1:0]   inp_z,
        output logic [p_width-1:0]   outp
        );

assign outp = ((inp_z) ^ ((inp_x) & ((inp_y) ^ (inp_z))));
endmodule: md4_F

module md4_G
    #(
        parameter p_width=32
        )
    (
        input   [p_width-1:0]   inp_x,
        input   [p_width-1:0]   inp_y,
        input   [p_width-1:0]   inp_z,
        output logic [p_width-1:0]   outp
        );
assign outp = (((inp_x) & ((inp_y) | (inp_z))) | ((inp_y) & (inp_z)));
endmodule: md4_G

module md4_H
    #(
        parameter p_width=32
        )
    (
        input   [p_width-1:0]   inp_x,
        input   [p_width-1:0]   inp_y,
        input   [p_width-1:0]   inp_z,
        output logic [p_width-1:0]   outp
        );

assign outp = ((inp_x) ^ (inp_y) ^ (inp_z));
endmodule: md4_H



module md4_shift
    #(
        parameter p_width=32,
        parameter p_shift=3
        )
    (
        input   [p_width-1:0]   inp_a,
        output logic [p_width-1:0]   outp
        );

//assign outp = (((inp_a) << (p_shift)) | (((inp_a) & 0xffffffff) >> (32 - (p_shift))));
assign outp[p_width-1:p_shift] = inp_a[p_width-p_shift-1:0];
assign outp[p_shift-1:0] = inp_a[p_width-1:p_width-p_shift];
endmodule: md4_shift


module md4_step
    #(
        parameter p_width=32,
        parameter p_function_nmb = 0, // 0- F, 1-G, 2-H
        parameter p_shift = 3
        //parameter p_x = 32'h12345678
        )
    (
        input clk,
        input rstN,
        input [p_width-1:0] inp_a,
        input [p_width-1:0] inp_b,
        input [p_width-1:0] inp_c,
        input [p_width-1:0] inp_d,
        input [p_width-1:0] inp_px,
        output logic [p_width-1:0]   outp_a,     /**/
        output logic [p_width-1:0]   outp_b,     /*TODO: add copy data from input */
        output logic [p_width-1:0]   outp_c,     /*TODO: add copy data from input */
        output logic [p_width-1:0]   outp_d      /*TODO: add copy data from input */
        );

wire [p_width-1:0] stage1_result;
wire [p_width-1:0] stage2_result;
wire [p_width-1:0] intermediate_stage_result;
wire [p_width-1:0] intermediate_stage_result_sync;

wire [p_width-1:0] inp_b_after_stage1;
wire [p_width-1:0] inp_c_after_stage1;
wire [p_width-1:0] inp_d_after_stage1;

generate
    if (p_function_nmb == 0)
        begin
            md4_F
                #(
                    .p_width(p_width)
                    )
            stage1
                (
                    .inp_x(inp_b),
                    .inp_y(inp_c),
                    .inp_z(inp_d),
                    .outp(stage1_result)
                    );
                
        end
    else if (p_function_nmb == 1)
        begin
            md4_G
                #(
                    .p_width(p_width)
                    )
            stage1
                (
                    .inp_x(inp_b),
                    .inp_y(inp_c),
                    .inp_z(inp_d),
                    .outp(stage1_result)
                    );
        end
    else //p_function_nmb == 2
        begin
            md4_H
                #(
                    .p_width(p_width)
                    )
            stage1
                (
                    .inp_x(inp_b),
                    .inp_y(inp_c),
                    .inp_z(inp_d),
                    .outp(stage1_result)
                    );
        end
endgenerate


`ifndef MD4_DOUBLE_STEP
assign intermediate_stage_result_sync= stage1_result ;
assign intermediate_stage_result = intermediate_stage_result_sync + inp_px + inp_a;
assign inp_b_after_stage1 = inp_b;
assign inp_c_after_stage1 = inp_c;
assign inp_d_after_stage1 = inp_d;
`else // use MD4_DOUBLE_STEP
 universal_reg #(p_width) REG1
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(stage1_result),             
        .WE(1'b1),                   
        .outp_data(intermediate_stage_result_sync)      
        );
    intermediate_stage_result = intermediate_stage_result_sync + inp_px + inp_a; /* !!!!! added +inp_a*/

    universal_reg #(p_width) REG1_b
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_b),             
        .WE(1'b1),                   
        .outp_data(inp_b_after_stage1)      
        );
    universal_reg #(p_width) REG1_c
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_c),             
        .WE(1'b1),                   
        .outp_data(inp_c_after_stage1)      
        );
    universal_reg #(p_width) REG1_d
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_d),             
        .WE(1'b1),                   
        .outp_data(inp_d_after_stage1)      
        );
`endif //MD4_DOUBLE_STEP

md4_shift #(
    .p_width(p_width),
    .p_shift(p_shift)
    ) 
    stage2 
    (
        .inp_a(intermediate_stage_result),
        .outp(stage2_result)
        );

`ifndef USE_UNPROTECTED_PART
universal_reg #(p_width) REG2 
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(stage2_result),             
        .WE(1'b1),                   
        .outp_data(outp_a)      
        );

universal_reg #(p_width) REG2_b
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_b_after_stage1),             
        .WE(1'b1),                   
        .outp_data(outp_b)      
        );

universal_reg #(p_width) REG2_c 
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_c_after_stage1),             
        .WE(1'b1),                   
        .outp_data(outp_c)      
        );

universal_reg #(p_width) REG2_d 
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_d_after_stage1),             
        .WE(1'b1),                   
        .outp_data(outp_d)      
        );

`else

universal_reg #(.p_width(p_width)) REG2 
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(stage2_result),             
        .WE(1'b1),                   
        .outp_data(outp_a)      
        );

universal_reg_mix #(.p_width(p_width), .p_width_protected(16)) REG2_b
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_b_after_stage1),             
        .WE(1'b1),                   
        .outp_data(outp_b)      
        );

universal_reg_mix #(.p_width(p_width), .p_width_protected(4)) REG2_c 
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_c_after_stage1),             
        .WE(1'b1),                   
        .outp_data(outp_c)      
        );

universal_reg_mix #(.p_width(p_width), .p_width_protected(1)) REG2_d 
    (
        .clk(clk),                  
        .rstN(rstN),                 
        .inp_data(inp_d_after_stage1),             
        .WE(1'b1),                   
        .outp_data(outp_d)      
        );
`endif // USE UNPROTECTED
endmodule: md4_step
                      

module md4_pipe
    #( 
        parameter p_inp_data_len = 32,
        parameter p_width = 32
        )
    (
        input                           clk,
        input                           rstN,
        input [p_inp_data_len-1:0]      inp_data,
        output logic [p_width*4-1:0]    outp_data
        );
  
logic [31:0] x_arr_0[3];
wire  [31:0] x_arr_1[3];
wire  [31:0] x_arr_2[3];
wire  [31:0] x_arr_3[3];

wire  [31:0] x_arr_4[3];
wire  [31:0] x_arr_5[3];
wire  [31:0] x_arr_6[3];
wire  [31:0] x_arr_7[3];

wire  [31:0] x_arr_8 [3];
wire  [31:0] x_arr_9 [3];
wire  [31:0] x_arr_10[3];
wire  [31:0] x_arr_11[3];

wire  [31:0] x_arr_12[3];
wire  [31:0] x_arr_13[3];
wire  [31:0] x_arr_14[3];
logic [31:0] x_arr_15[3];

wire [p_width-1:0] var_a[49];
wire [p_width-1:0] var_b[49];
wire [p_width-1:0] var_c[49];
wire [p_width-1:0] var_d[49];


assign var_a[0] = 32'h67452301;
assign var_b[0] = 32'hefcdab89;
assign var_c[0] = 32'h98badcfe;
assign var_d[0] = 32'h10325476;
  

assign x_arr_1 [0][31:1]= '0; 
assign x_arr_2 [0]= '0; 
assign x_arr_3 [0]= '0; 
        
assign x_arr_4 [0]= '0; 
assign x_arr_5 [0]= '0; 
assign x_arr_6 [0]= '0; 
assign x_arr_7 [0]= '0; 

assign x_arr_8  [0]= '0; 
assign x_arr_9  [0]= '0; 
assign x_arr_10 [0]= '0;
assign x_arr_11 [0]= '0;

assign x_arr_12 [0]= '0;
assign x_arr_13 [0]= '0;
assign x_arr_14 [0]= '0;

assign   x_arr_0[0][p_inp_data_len-1:0] = inp_data[p_inp_data_len-1:0];
//assign   x_arr_0[0][p_inp_data_len-1] = 1'b1;
assign   x_arr_1[0][0] = 1'b1;
//assign   x_arr_0[0][31:p_inp_data_len] = '0;
assign   x_arr_15[0] = p_inp_data_len;


assign x_arr_0 [1] = x_arr_0 [0] + 32'h5a827999;
assign x_arr_1 [1] = x_arr_1 [0] + 32'h5a827999;
assign x_arr_2 [1] = x_arr_2 [0] + 32'h5a827999;
assign x_arr_3 [1] = x_arr_3 [0] + 32'h5a827999;
                             
assign x_arr_4 [1] = x_arr_4 [0] + 32'h5a827999;
assign x_arr_5 [1] = x_arr_5 [0] + 32'h5a827999;
assign x_arr_6 [1] = x_arr_6 [0] + 32'h5a827999;
assign x_arr_7 [1] = x_arr_7 [0] + 32'h5a827999;
                             
assign x_arr_8 [1] = x_arr_8 [0] + 32'h5a827999;
assign x_arr_9 [1] = x_arr_9 [0] + 32'h5a827999;
assign x_arr_10[1] = x_arr_10[0] + 32'h5a827999;
assign x_arr_11[1] = x_arr_11[0] + 32'h5a827999;
                             
assign x_arr_12[1] = x_arr_12[0] + 32'h5a827999;
assign x_arr_13[1] = x_arr_13[0] + 32'h5a827999;
assign x_arr_14[1] = x_arr_14[0] + 32'h5a827999;
assign x_arr_15[1] = x_arr_15[0] + 32'h5a827999;

assign x_arr_0 [2] = x_arr_0 [0] + 32'h6ed9eba1;
assign x_arr_1 [2] = x_arr_1 [0] + 32'h6ed9eba1;
assign x_arr_2 [2] = x_arr_2 [0] + 32'h6ed9eba1;
assign x_arr_3 [2] = x_arr_3 [0] + 32'h6ed9eba1;
                             
assign x_arr_4 [2] = x_arr_4 [0] + 32'h6ed9eba1;
assign x_arr_5 [2] = x_arr_5 [0] + 32'h6ed9eba1;
assign x_arr_6 [2] = x_arr_6 [0] + 32'h6ed9eba1;
assign x_arr_7 [2] = x_arr_7 [0] + 32'h6ed9eba1;
                             
assign x_arr_8 [2] = x_arr_8 [0] + 32'h6ed9eba1;
assign x_arr_9 [2] = x_arr_9 [0] + 32'h6ed9eba1;
assign x_arr_10[2] = x_arr_10[0] + 32'h6ed9eba1;
assign x_arr_11[2] = x_arr_11[0] + 32'h6ed9eba1;
                             
assign x_arr_12[2] = x_arr_12[0] + 32'h6ed9eba1;
assign x_arr_13[2] = x_arr_13[0] + 32'h6ed9eba1;
assign x_arr_14[2] = x_arr_14[0] + 32'h6ed9eba1;
assign x_arr_15[2] = x_arr_15[0] + 32'h6ed9eba1;


/* Round 1 */
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(3)) 
            STEP_R1_0 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[0]), .inp_b(var_b[0]), .inp_c(var_c[0]), .inp_d(var_d[0]), .inp_px(x_arr_0[0]), 
           .outp_a(var_a[1]), .outp_b(var_b[1]), .outp_c(var_c[1]), .outp_d(var_d[1]) );

md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(7))
            STEP_R1_1 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[1]), .inp_b(var_a[1]), .inp_c(var_b[1]), .inp_d(var_c[1]), .inp_px(x_arr_1[0]), 
           .outp_a(var_a[2]), .outp_b(var_b[2]), .outp_c(var_c[2]), .outp_d(var_d[2]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(11))
            STEP_R1_2 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[2]), .inp_b(var_d[2]), .inp_c(var_a[2]), .inp_d(var_b[2]), .inp_px(x_arr_2[0]), 
           .outp_a(var_a[3]), .outp_b(var_b[3]), .outp_c(var_c[3]), .outp_d(var_d[3]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(19))
            STEP_R1_3 
          (.clk(clk), .rstN(rstN),
           .inp_a(var_b[3]), .inp_b(var_c[3]), .inp_c(var_d[3]), .inp_d(var_a[3]), .inp_px(x_arr_3[0]),  
           .outp_a(var_a[4]), .outp_b(var_b[4]), .outp_c(var_c[4]), .outp_d(var_d[4]) );

md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(3))
            STEP_R1_4 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[4]), .inp_b(var_b[4]), .inp_c(var_c[4]), .inp_d(var_d[4]), .inp_px(x_arr_4[0]), 
           .outp_a(var_a[5]), .outp_b(var_b[5]), .outp_c(var_c[5]), .outp_d(var_d[5]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(7))
            STEP_R1_5 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[5]), .inp_b(var_a[5]), .inp_c(var_b[5]), .inp_d(var_c[5]), .inp_px(x_arr_5[0]), 
           .outp_a(var_a[6]), .outp_b(var_b[6]), .outp_c(var_c[6]), .outp_d(var_d[6]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(11))
            STEP_R1_6 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[6]), .inp_b(var_d[6]), .inp_c(var_a[6]), .inp_d(var_b[6]), .inp_px(x_arr_6[0]), 
           .outp_a(var_a[7]), .outp_b(var_b[7]), .outp_c(var_c[7]), .outp_d(var_d[7]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(19))
            STEP_R1_7 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[7]), .inp_b(var_c[7]), .inp_c(var_d[7]), .inp_d(var_a[7]), .inp_px(x_arr_7[0]),  
           .outp_a(var_a[8]), .outp_b(var_b[8]), .outp_c(var_c[8]), .outp_d(var_d[8]) );

md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(3))
            STEP_R1_8 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[8]), .inp_b(var_b[8]), .inp_c(var_c[8]), .inp_d(var_d[8]), .inp_px(x_arr_8[0]), 
           .outp_a(var_a[9]), .outp_b(var_b[9]), .outp_c(var_c[9]), .outp_d(var_d[9]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(7))
            STEP_R1_9 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[9]), .inp_b(var_a[9]), .inp_c(var_b[9]), .inp_d(var_c[9]), .inp_px(x_arr_9[0]), 
           .outp_a(var_a[10]), .outp_b(var_b[10]), .outp_c(var_c[10]), .outp_d(var_d[10]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(11))
            STEP_R1_10 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[10]), .inp_b(var_d[10]), .inp_c(var_a[10]), .inp_d(var_b[10]), .inp_px(x_arr_10[0]), 
           .outp_a(var_a[11]), .outp_b(var_b[11]), .outp_c(var_c[11]), .outp_d(var_d[11]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(19))
            STEP_R1_11 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[11]), .inp_b(var_c[11]), .inp_c(var_d[11]), .inp_d(var_a[11]), .inp_px(x_arr_11[0]),  
           .outp_a(var_a[12]), .outp_b(var_b[12]), .outp_c(var_c[12]), .outp_d(var_d[12]) );

md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(3))
            STEP_R1_12 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[12]), .inp_b(var_b[12]), .inp_c(var_c[12]), .inp_d(var_d[12]), .inp_px(x_arr_12[0]), 
           .outp_a(var_a[13]), .outp_b(var_b[13]), .outp_c(var_c[13]), .outp_d(var_d[13]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(7))
            STEP_R1_13 
          (.clk(clk), .rstN(rstN), 
            .inp_a(var_d[13]), .inp_b(var_a[13]), .inp_c(var_b[13]), .inp_d(var_c[13]), .inp_px(x_arr_13[0]), 
           .outp_a(var_a[14]), .outp_b(var_b[14]), .outp_c(var_c[14]), .outp_d(var_d[14]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(11))
            STEP_R1_14 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[14]), .inp_b(var_d[14]), .inp_c(var_a[14]), .inp_d(var_b[14]), .inp_px(x_arr_14[0]), 
           .outp_a(var_a[15]), .outp_b(var_b[15]), .outp_c(var_c[15]), .outp_d(var_d[15]) );
md4_step #(.p_width(32),.p_function_nmb(0), .p_shift(19))
            STEP_R1_15 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[15]), .inp_b(var_c[15]), .inp_c(var_d[15]), .inp_d(var_a[15]), .inp_px(x_arr_15[0]),  
           .outp_a(var_a[16]), .outp_b(var_b[16]), .outp_c(var_c[16]), .outp_d(var_d[16]) );


/* Round 2 */
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(3)) 
            STEP_R2_0 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[16]), .inp_b(var_b[16]), .inp_c(var_c[16]), .inp_d(var_d[16]), .inp_px(x_arr_0[1]), 
           .outp_a(var_a[17]), .outp_b(var_b[17]), .outp_c(var_c[17]), .outp_d(var_d[17]) );

md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(5))
            STEP_R2_1 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[17]), .inp_b(var_a[17]), .inp_c(var_b[17]), .inp_d(var_c[17]), .inp_px(x_arr_4[1]), 
           .outp_a(var_a[18]), .outp_b(var_b[18]), .outp_c(var_c[18]), .outp_d(var_d[18]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(9))
            STEP_R2_2 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[18]), .inp_b(var_d[18]), .inp_c(var_a[18]), .inp_d(var_b[18]), .inp_px(x_arr_8[1]), 
           .outp_a(var_a[19]), .outp_b(var_b[19]), .outp_c(var_c[19]), .outp_d(var_d[19]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(13))
            STEP_R2_3 
          (.clk(clk), .rstN(rstN),
           .inp_a(var_b[19]), .inp_b(var_c[19]), .inp_c(var_d[19]), .inp_d(var_a[19]), .inp_px(x_arr_12[1]),  
           .outp_a(var_a[20]), .outp_b(var_b[20]), .outp_c(var_c[20]), .outp_d(var_d[20]) );

md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(3))
            STEP_R2_4 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[20]), .inp_b(var_b[20]), .inp_c(var_c[20]), .inp_d(var_d[20]), .inp_px(x_arr_1[1]), 
           .outp_a(var_a[21]), .outp_b(var_b[21]), .outp_c(var_c[21]), .outp_d(var_d[21]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(5))
            STEP_R2_5 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[21]), .inp_b(var_a[21]), .inp_c(var_b[21]), .inp_d(var_c[21]), .inp_px(x_arr_5[1]), 
           .outp_a(var_a[22]), .outp_b(var_b[22]), .outp_c(var_c[22]), .outp_d(var_d[22]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(9))
            STEP_R2_6 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[22]), .inp_b(var_d[22]), .inp_c(var_a[22]), .inp_d(var_b[22]), .inp_px(x_arr_9[1]), 
           .outp_a(var_a[23]), .outp_b(var_b[23]), .outp_c(var_c[23]), .outp_d(var_d[23]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(13))
            STEP_R2_7 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[23]), .inp_b(var_c[23]), .inp_c(var_d[23]), .inp_d(var_a[23]), .inp_px(x_arr_13[1]),  
           .outp_a(var_a[24]), .outp_b(var_b[24]), .outp_c(var_c[24]), .outp_d(var_d[24]) );

md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(3))
            STEP_R2_8 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[24]), .inp_b(var_b[24]), .inp_c(var_c[24]), .inp_d(var_d[24]), .inp_px(x_arr_2[1]), 
           .outp_a(var_a[25]), .outp_b(var_b[25]), .outp_c(var_c[25]), .outp_d(var_d[25]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(5))
            STEP_R2_9 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[25]), .inp_b(var_a[25]), .inp_c(var_b[25]), .inp_d(var_c[25]), .inp_px(x_arr_6[1]), 
           .outp_a(var_a[26]), .outp_b(var_b[26]), .outp_c(var_c[26]), .outp_d(var_d[26]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(9))
            STEP_R2_10 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[26]), .inp_b(var_d[26]), .inp_c(var_a[26]), .inp_d(var_b[26]), .inp_px(x_arr_10[1]), 
           .outp_a(var_a[27]), .outp_b(var_b[27]), .outp_c(var_c[27]), .outp_d(var_d[27]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(13))
            STEP_R2_11 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[27]), .inp_b(var_c[27]), .inp_c(var_d[27]), .inp_d(var_a[27]), .inp_px(x_arr_14[1]),  
           .outp_a(var_a[28]), .outp_b(var_b[28]), .outp_c(var_c[28]), .outp_d(var_d[28]) );

md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(3))
            STEP_R2_12 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[28]), .inp_b(var_b[28]), .inp_c(var_c[28]), .inp_d(var_d[28]), .inp_px(x_arr_3[1]), 
           .outp_a(var_a[29]), .outp_b(var_b[29]), .outp_c(var_c[29]), .outp_d(var_d[29]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(5))
            STEP_R2_13 
          (.clk(clk), .rstN(rstN), 
            .inp_a(var_d[29]), .inp_b(var_a[29]), .inp_c(var_b[29]), .inp_d(var_c[29]), .inp_px(x_arr_7[1]), 
           .outp_a(var_a[30]), .outp_b(var_b[30]), .outp_c(var_c[30]), .outp_d(var_d[30]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(9))
            STEP_R2_14 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[30]), .inp_b(var_d[30]), .inp_c(var_a[30]), .inp_d(var_b[30]), .inp_px(x_arr_11[1]), 
           .outp_a(var_a[31]), .outp_b(var_b[31]), .outp_c(var_c[31]), .outp_d(var_d[31]) );
md4_step #(.p_width(32),.p_function_nmb(1), .p_shift(13))
            STEP_R2_15 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[31]), .inp_b(var_c[31]), .inp_c(var_d[31]), .inp_d(var_a[31]), .inp_px(x_arr_15[1]),  
           .outp_a(var_a[32]), .outp_b(var_b[32]), .outp_c(var_c[32]), .outp_d(var_d[32]) );


/* Round 3 */
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(3)) 
            STEP_R3_0 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[32]), .inp_b(var_b[32]), .inp_c(var_c[32]), .inp_d(var_d[32]), .inp_px(x_arr_0[2]), 
           .outp_a(var_a[33]), .outp_b(var_b[33]), .outp_c(var_c[33]), .outp_d(var_d[33]) );

md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(5))
            STEP_R3_1 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[33]), .inp_b(var_a[33]), .inp_c(var_b[33]), .inp_d(var_c[33]), .inp_px(x_arr_4[2]), 
           .outp_a(var_a[34]), .outp_b(var_b[34]), .outp_c(var_c[34]), .outp_d(var_d[34]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(9))
            STEP_R3_2 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[34]), .inp_b(var_d[34]), .inp_c(var_a[34]), .inp_d(var_b[34]), .inp_px(x_arr_8[2]), 
           .outp_a(var_a[35]), .outp_b(var_b[35]), .outp_c(var_c[35]), .outp_d(var_d[35]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(13))
            STEP_R3_3 
          (.clk(clk), .rstN(rstN),
           .inp_a(var_b[35]), .inp_b(var_c[35]), .inp_c(var_d[35]), .inp_d(var_a[35]), .inp_px(x_arr_12[2]),  
           .outp_a(var_a[36]), .outp_b(var_b[36]), .outp_c(var_c[36]), .outp_d(var_d[36]) );

md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(3))
            STEP_R3_4 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[36]), .inp_b(var_b[36]), .inp_c(var_c[36]), .inp_d(var_d[36]), .inp_px(x_arr_1[2]), 
           .outp_a(var_a[37]), .outp_b(var_b[37]), .outp_c(var_c[37]), .outp_d(var_d[37]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(5))
            STEP_R3_5 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[37]), .inp_b(var_a[37]), .inp_c(var_b[37]), .inp_d(var_c[37]), .inp_px(x_arr_5[2]), 
           .outp_a(var_a[38]), .outp_b(var_b[38]), .outp_c(var_c[38]), .outp_d(var_d[38]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(9))
            STEP_R3_6 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[38]), .inp_b(var_d[38]), .inp_c(var_a[38]), .inp_d(var_b[38]), .inp_px(x_arr_9[2]), 
           .outp_a(var_a[39]), .outp_b(var_b[39]), .outp_c(var_c[39]), .outp_d(var_d[39]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(13))
            STEP_R3_7 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[39]), .inp_b(var_c[39]), .inp_c(var_d[39]), .inp_d(var_a[39]), .inp_px(x_arr_13[2]),  
           .outp_a(var_a[40]), .outp_b(var_b[40]), .outp_c(var_c[40]), .outp_d(var_d[40]) );

md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(3))
            STEP_R3_8 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[40]), .inp_b(var_b[40]), .inp_c(var_c[40]), .inp_d(var_d[40]), .inp_px(x_arr_2[2]), 
           .outp_a(var_a[41]), .outp_b(var_b[41]), .outp_c(var_c[41]), .outp_d(var_d[41]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(5))
            STEP_R3_9 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_d[41]), .inp_b(var_a[41]), .inp_c(var_b[41]), .inp_d(var_c[41]), .inp_px(x_arr_6[2]), 
           .outp_a(var_a[42]), .outp_b(var_b[42]), .outp_c(var_c[42]), .outp_d(var_d[42]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(9))
            STEP_R3_10 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[42]), .inp_b(var_d[42]), .inp_c(var_a[42]), .inp_d(var_b[42]), .inp_px(x_arr_10[2]), 
           .outp_a(var_a[43]), .outp_b(var_b[43]), .outp_c(var_c[43]), .outp_d(var_d[43]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(13))
            STEP_R3_11 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[43]), .inp_b(var_c[43]), .inp_c(var_d[43]), .inp_d(var_a[43]), .inp_px(x_arr_14[2]),  
           .outp_a(var_a[44]), .outp_b(var_b[44]), .outp_c(var_c[44]), .outp_d(var_d[44]) );

md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(3))
            STEP_R3_12 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_a[44]), .inp_b(var_b[44]), .inp_c(var_c[44]), .inp_d(var_d[44]), .inp_px(x_arr_3[2]), 
           .outp_a(var_a[45]), .outp_b(var_b[45]), .outp_c(var_c[45]), .outp_d(var_d[45]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(5))
            STEP_R3_13 
          (.clk(clk), .rstN(rstN), 
            .inp_a(var_d[45]), .inp_b(var_a[45]), .inp_c(var_b[45]), .inp_d(var_c[45]), .inp_px(x_arr_7[2]), 
           .outp_a(var_a[46]), .outp_b(var_b[46]), .outp_c(var_c[46]), .outp_d(var_d[46]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(9))
            STEP_R3_14 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_c[46]), .inp_b(var_d[46]), .inp_c(var_a[46]), .inp_d(var_b[46]), .inp_px(x_arr_11[2]), 
           .outp_a(var_a[47]), .outp_b(var_b[47]), .outp_c(var_c[47]), .outp_d(var_d[47]) );
md4_step #(.p_width(32),.p_function_nmb(2), .p_shift(13))
            STEP_R3_15 
          (.clk(clk), .rstN(rstN), 
           .inp_a(var_b[47]), .inp_b(var_c[47]), .inp_c(var_d[47]), .inp_d(var_a[47]), .inp_px(x_arr_15[2]),  
           .outp_a(var_a[48]), .outp_b(var_b[48]), .outp_c(var_c[48]), .outp_d(var_d[48]) );

assign outp_data[p_width-1:0]           = var_a[48] + 32'h67452301;
assign outp_data[p_width*2-1:p_width]   = var_b[48] + 32'hefcdab89;
assign outp_data[p_width*3-1:p_width*2] = var_c[48] + 32'h98badcfe;
assign outp_data[p_width*4-1:p_width*3] = var_d[48] + 32'h10325476;
endmodule: md4_pipe

`endif //MD4_TEST_PROTECTED
