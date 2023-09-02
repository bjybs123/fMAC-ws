`timescale 1ns/1ps

module fp_generator #(
    parameter GRPSIZE = 16,
    parameter BFPEXPSIZE = 8,
    parameter BFPMANSIZE = 3+1,
    parameter MULBFPMANSIZE = (BFPMANSIZE-1)*2,
    parameter LEVELS = $clog2(GRPSIZE)
) (
    input i_sign,
    input [(BFPEXPSIZE+1)-1:0] i_exp,
    input [(MULBFPMANSIZE+LEVELS)-1:0] i_man,
    output  o_fp_sign,
    output [8-1:0] o_fp_exp,
    output [23-1:0] o_fp_man
    );

    /* making implicit leading 1 and check for exponent overflow and underflow */
    always @ (*) begin
        if(i_man[(MULBFPMANSIZE+LEVELS)-1] == 1'b1) begin
            if((i_exp + 3) > 9'b0_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                fp_exp = i_exp + 3;
                fp_man[23] = i_sign[1];
                fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 1;
                fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-2] == 1'b1) begin
            if((i_exp + 2) > 9'b0_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                fp_exp = i_exp + 2;
                fp_man[23] = i_sign[1];
                fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 2;
                fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-3] == 1'b1) begin
            if((i_exp + 1) > 9'b0_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                fp_exp = i_exp + 1;
                fp_man[23] = i_sign[1];
                fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 3;
                fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-4] == 1'b1) begin
            if(i_exp > 9'b0_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                fp_exp = i_exp;
                fp_man[23] = i_sign[1];
                fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 4;
                fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-5] == 1'b1) begin
            if(({1'b1, i_exp} - 1) > 10'b10_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                if(({1'b1, i_exp} - 1) < 10'b10_0000_0000) begin
                    fp_exp = 8'b0000_0000;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << i_exp;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
                else begin
                    fp_exp = i_exp - 1;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 5;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-6] == 1'b1) begin
            if(({1'b1, i_exp} - 2) > 10'b10_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                if(({1'b1, i_exp} - 2) < 10'b10_0000_0000) begin
                    fp_exp = 8'b0000_0000;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << i_exp;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
                else begin
                    fp_exp = i_exp - 2;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 6;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-7] == 1'b1) begin
            if(({1'b1, i_exp} - 3) > 10'b10_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                if(({1'b1, i_exp} - 3) < 10'b10_0000_0000) begin
                    fp_exp = 8'b0000_0000;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << i_exp;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
                else begin
                    fp_exp = i_exp - 3;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 7;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-8] == 1'b1) begin
            if(({1'b1, i_exp} - 4) > 10'b10_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                if(({1'b1, i_exp} - 4) < 10'b10_0000_0000) begin
                    fp_exp = 8'b0000_0000;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << i_exp;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
                else begin
                    fp_exp = i_exp - 4;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 8;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-9] == 1'b1) begin
            if(({1'b1, i_exp} - 5) > 10'b10_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                if(({1'b1, i_exp} - 5) < 10'b10_0000_0000) begin
                    fp_exp = 8'b0000_0000;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << i_exp;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
                else begin
                    fp_exp = i_exp - 5;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 9;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;     
                end
            end
        end
        else if(i_man[(MULBFPMANSIZE+LEVELS)-10] == 1'b1) begin
            if(({1'b1, i_exp} - 6) > 10'b10_1111_1110) begin
                fp_exp = 8'b1111_1111;
                fp_man = 0;
            end
            else begin
                if(({1'b1, i_exp} - 6) < 10'b10_0000_0000) begin
                    fp_exp = 8'b0000_0000;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << i_exp;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;
                end
                else begin
                    fp_exp = i_exp - 6;
                    fp_man[23] = i_sign[1];
                    fp_man[22:22-(MULBFPMANSIZE+LEVELS)+1] = i_man << 10;
                    fp_man[22-(MULBFPMANSIZE+LEVELS):0] = 0;     
                end
            end
        end
        else begin
            fp_exp = 8'b0000_0000;
            fp_man[23] = i_sign[1];
            fp_man[22:0] = 0;
        end
    end

    assign o_fp = {fp_man[23], fp_exp, fp_man[22:0]};

endmodule