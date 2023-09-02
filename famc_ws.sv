module fmac_ws #(
    parameter GRPSIZE = 16,
    parameter FPEXPSIZE = 8,
    parameter FPMANSIZE = 23+1,
    parameter BFPEXPSIZE = 8,
    parameter BFPMANSIZE = 3+1
) (
    input                           i_clk, 
    input                           i_reset_n,
    input        [BFPEXPSIZE-1:0]   i_west_E,
    input        [BFPMANSIZE-1:0]   i_west_M [0:GRPSIZE-1],
    input        [BFPEXPSIZE-1:0]   i_south_E,
    input        [BFPMANSIZE-1:0]   i_south_M [0:GRPSIZE-1],
    input        [32-1:0]           i_prev_result,
    input                           i_pre_store,
    output logic [BFPEXPSIZE-1:0]   o_east_E,
    output logic [BFPMANSIZE-1:0]   o_east_M [0:GRPSIZE-1],
    output logic [32-1:0]           o_east_fp,
    output logic [BFPEXPSIZE-1:0]   o_north_E,
    output logic [BFPMANSIZE-1:0]   o_north_M [0:GRPSIZE-1],
    output logic [32-1:0]           o_north_fp,
    output logic [32-1:0]           o_result
    );

    parameter LEVELS = $clog2(GRPSIZE);
    parameter MULBFPMANSIZE = (BFPMANSIZE-1)*2;     // bfp mantissa width after multiplication

    /* Accumulator */
    logic [32-1:0] Acc;

    /* pre-stored Weight F/F */
    logic [BFPEXPSIZE-1:0] weight_E;
    logic [BFPMANSIZE-1:0] weight_M [0:GRPSIZE-1];

    /* selected multiplier operands */
    logic [BFPEXPSIZE-1:0] mul_op1_E;
    logic [BFPMANSIZE-1:0] mul_op1_M [0:GRPSIZE-1];
    logic [BFPEXPSIZE-1:0] mul_op2_E;
    logic [BFPMANSIZE-1:0] mul_op2_M [0:GRPSIZE-1];
    
    /* Multiplier operands selection signals */
    logic sel_op1;
    logic sel_op2;

    /* output selection signals */
    logic sel_east;
    logic sel_north;

    /* multiplication result */
    logic mul_rslt_sign [0:GRPSIZE-1];
    logic [(BFPEXPSIZE+1)-1:0] mul_rslt_exp;
    logic [MULBFPMANSIZE-1:0] mul_rslt_man [0:GRPSIZE-1];

    /* adder tree result */
    logic tmp_sign;
    logic [(MULBFPMANSIZE+LEVELS)-1:0] tmp_man;

    /* generated FP num */
    logic [32-1:0] fp;



    /* select multiplier operands */
    assign mul_op1_E = sel_op1 == 0 ? i_west_E : weight_E;
    assign mul_op2_E = sel_op2 == 0 ? i_south_E : weight_E;
    genvar op_idx;
    generate
        for(op_idx=0; op_idx<GRPSIZE; op_idx=op_idx+1) begin
            assign mul_op1_M[op_idx] = sel_op1 == 0 ? i_west_M : weight_M;
            assign mul_op2_M[op_idx] = sel_op2 == 0 ? i_south_M : weight_M;
        end
    endgenerate

    /* pre-store weight */
    always_ff @ (posedge i_clk or negedge i_reset_n) begin
        if(~i_reset_n) begin
            weight_E <= 0;
        end
        else begin
            if(i_pre_store) begin
                weight_E <= i_south_E;
            end
            else begin
                weight_E <= weight_E;   // Latch
            end
        end
    end
    genvar pre;
    generate 
        for(pre=0; pre<GRPSIZE; pre=pre+1) begin
            always_ff @ (posedge i_clk or negedge i_reset_n) begin
                if(~i_reset_n) begin
                    weight_M[pre] <= 0;
                end
                else begin
                    if(i_pre_store) begin
                        weight_M[pre] <= i_south_M[pre];
                    end
                    else begin
                        weight_M[pre] <= weight_M[pre]; // Latch
                    end
                end
            end
        end
    endgenerate

    /* multiply two BFP groups */
    bfp_multiplier bfp_mul(
        .i_op1_E(mul_op1_E), 
        .i_op1_M(mul_op1_M),
        .i_op2_E(mul_op2_E),
        .i_op2_M(mul_op2_M),
        .o_rslt_sign(mul_rslt_sign),
        .o_rslt_exp(mul_rslt_exp),
        .o_rslt_man(mul_rslt_man)
    );

    /* add each BFP  */
    adder_tree adder_tree(
        .i_sign(mul_rslt_sign),
        .i_man(mul_rslt_man),
        .o_sign(tmp_sign),
        .o_man(tmp_man)
    );

    /* mantissa alignment and fp generation */
    fp_generator fp_gen(
        .i_sign(tmp_sign),
        .i_exp(mul_rslt_exp),
        .i_man(tmp_man),
        .o_fp(fp)
    );






    /* select output */
    // assign o_north_E = sel_north == 0 ? i_south_E : mul_rslt;
    // assign o_east_E = sel_east == 0 ? i_west_E : mul_rslt;
    // genvar out_idx;
    // generate
    //     for(out_idx=0; out_idx<GRPSIZE; out_idx=out_idx+1) begin
    //         assign o_north_E[out_idx] = sel_north == 0 ? i_south_M[out_idx] : mul_rslt;
    //         assign o_east_E[out_idx] = sel_east == 0 ? i_west_M[out_idx] : mul_rslt;
    //     end
    // endgenerate





endmodule
