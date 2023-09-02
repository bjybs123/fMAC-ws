`timescale 1ns/1ps

module bfp_multiplier #(
    parameter GRPSIZE = 16,
    parameter BFPEXPSIZE = 8,
    parameter BFPMANSIZE = 3+1,
    parameter MULBFPMANSIZE = (BFPMANSIZE-1)*2
) (
    input [BFPEXPSIZE-1:0] i_op1_E,
    input [BFPMANSIZE-1:0] i_op1_M [0:GRPSIZE-1],
    input [BFPEXPSIZE-1:0] i_op2_E,
    input [BFPMANSIZE-1:0] i_op2_M [0:GRPSIZE-1],
    output logic o_rslt_sign [0:GRPSIZE-1],
    output logic [(BFPEXPSIZE+1)-1:0] o_rslt_exp,
    output logic [MULBFPMANSIZE-1:0] o_rslt_man [0:GRPSIZE-1]
    );

    /* add exponent of two groups */
    always_comb begin
        o_rslt_exp = i_op1_E + i_op2_E;
    end

    /* multiply mantissa */
    genvar mul;
    generate
        for(mul=0; mul<GRPSIZE; mul=mul+1) begin
            always @ (*) begin
                o_rslt_sign[mul] = i_op1_M[mul][BFPMANSIZE-1] ^ i_op2_M[mul][BFPMANSIZE-1];
                o_rslt_man[mul] = i_op1_M[mul][BFPMANSIZE-2:0] * o_op2_M[mul][BFPMANSIZE-2:0];
            end
        end
    endgenerate


endmodule