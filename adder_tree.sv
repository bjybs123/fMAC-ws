`timescale 1ns/1ps

module adder_tree #(
    parameter GRPSIZE = 16,
    parameter BFPEXPSIZE = 8,
    parameter BFPMANSIZE = 3+1,
    parameter MULBFPMANSIZE = (BFPMANSIZE-1)*2,
    parameter LEVELS = $clog2(GRPSIZE)
) (
    input i_sign [0:GRPSIZE-1],
    input [MULBFPMANSIZE-1:0] i_man [0:GRPSIZE-1],
    output logic o_sign,
    output logic [(MULBFPMANSIZE+LEVELS)-1:0] o_man
    );

    logic tmp_rslt_sign [1:GRPSIZE-1];
    logic [(MULBFPMANSIZE+LEVELS)-1:0] tmp_rslt_man [1:GRPSIZE-1];      //10-bit

    /* adder tree */
    genvar lv, add;
    generate
        for(lv=LEVELS-1; lv>=0; lv=lv-1) begin : level
            for(add=0; add<2**lv; add=add+1) begin : add_man
                always_comb begin
                    /* For the first level of the adder tree, fetch operands from mul_rslt. */
                    if(lv == LEVELS-1) begin
                        /* a + (-b) */
                        if(i_sign[add*2] == 0 && i_sign[add*2+1] == 1) begin  
                            /* |a| >= |b| */
                            if(i_man[add*2] >= i_man[add*2+1]) begin
                                /* tmp_rslt = a - b */                                                              
                                tmp_rslt_sign[2**lv+add] = 0;                                                                                            
                                tmp_rslt_man[2**lv+add] = i_man[add*2] - i_man[add*2+1];
                            end
                            /* |a| < |b| */
                            else begin
                                /* tmp_rslt = -(b - a) */                                                                                                  
                                tmp_rslt_sign[2**lv+add] = 1;                                                                                           
                                tmp_rslt_man[2**lv+add] = i_man[add*2+1] - i_man[add*2];
                            end
                        end
                        /* (-a) + b */
                        else if(i_sign[add*2] == 1 && i_sign[add*2+1] == 0) begin  
                            /* |a| >= |b| */                                                     
                            if(i_man[add*2] >= i_man[add*2+1]) begin      
                                /* tmp_rslt = -(a - b) */                                                        
                                tmp_rslt_sign[2**lv+add] = 1;                                                                                            
                                tmp_rslt_man[2**lv+add] = i_man[add*2] - i_man[add*2+1];
                            end
                            /* |a| < |b| */
                            else begin   
                                /* tmp_rslt = b - a */                                                                                                                                    
                                tmp_rslt_sign[2**lv+add] = 0;                                                                                           
                                tmp_rslt_man[2**lv+add] = i_man[add*2+1] - i_man[add*2];
                            end
                        end
                        /* a + b or (-a) + (-b) */
                        else begin
                            /* tmp_rslt = +-(a + b) */
                            tmp_rslt_sign[2**lv+add] = i_sign[add*2];                                                             
                            tmp_rslt_man[2**lv+add] = i_man[add*2] + i_man[add*2+1];
                        end
                    end
                    /* For the rest of the level, fetch operands from the previous level of the tree. tmp_rslt[level] = tmp_rslt[prev_level] + tmp_rslt[prev_level+1]*/
                    else begin
                        /* a + (-b) */
                        if(tmp_rslt_sign[2**(lv+1)+add*2] == 0 && tmp_rslt_sign[2**(lv+1)+add*2+1] == 1) begin    
                            /* |a| >= |b| */                                     
                            if(tmp_rslt_man[2**(lv+1)+add*2] >= tmp_rslt_man[2**(lv+1)+add*2+1]) begin    
                                /* tmp_rslt = a - b */                                        
                                tmp_rslt_sign[2**lv+add] = 0;                                                                        
                                tmp_rslt_man[2**lv+add] = tmp_rslt_man[2**(lv+1)+add*2] - tmp_rslt_man[2**(lv+1)+add*2+1];
                            end
                            /* |a| < |b| */
                            else begin      
                                /* tmp_rslt = -(b - a) */                                                                                                             
                                tmp_rslt_sign[2**lv+add] = 1;                                                                        
                                tmp_rslt_man[2**lv+add] = tmp_rslt_man[2**(lv+1)+add*2+1] - tmp_rslt_man[2**(lv+1)+add*2];
                            end
                        end
                        /* (-a) + b */
                        else if(tmp_rslt_sign[2**(lv+1)+add*2] == 1 && tmp_rslt_sign[2**(lv+1)+add*2+1] == 0) begin 
                            /* |a| >= |b| */                                   
                            if(tmp_rslt_man[2**(lv+1)+add*2] >= tmp_rslt_man[2**(lv+1)+add*2+1]) begin
                                /* tmp_rslt = -(a - b) */                                           
                                tmp_rslt_sign[2**lv+add] = 1;                                                                        
                                tmp_rslt_man[2**lv+add] = tmp_rslt_man[2**(lv+1)+add*2] - tmp_rslt_man[2**(lv+1)+add*2+1];
                            end
                            /* |a| < |b| */
                            else begin     
                                /* tmp_rslt = b - a */                                                                                                              
                                tmp_rslt_sign[2**lv+add] = 0;                                                                        
                                tmp_rslt_man[2**lv+add] = tmp_rslt_man[2**(lv+1)+add*2+1] - tmp_rslt_man[2**(lv+1)+add*2];
                            end
                        end
                        /* a + b or (-a) + (-b) */
                        else begin
                            /* tmp_rslt = +-(a + b) */
                            tmp_rslt_sign[2**lv+add] = tmp_rslt_sign[2**(lv+1)+add*2];                                          
                            tmp_rslt_man[2**lv+add] = tmp_rslt_man[2**(lv+1)+add*2] + tmp_rslt_man[2**(lv+1)+add*2+1];
                        end
                    end
                end
            end
        end
    endgenerate

    assign o_sign = tmp_rslt_sign[1];
    assign o_man = tmp_rslt_man[1];

endmodule