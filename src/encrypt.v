`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2023 01:20:46 PM
// Design Name: 
// Module Name: encrypt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module encrypt #(m_size = 5, lambda = 32, eta = 32, nu = 16)(
    input clk,
    input [eta-1 : 0] q_param,
    input [lambda-1 : 0] p_key,
    input [nu - 1 : 0] kappa_key,
    input [m_size-1: 0] m, //plaintext input - 32 bit
    output [((nu + nu >=  eta + lambda) ? nu + nu : eta + lambda) -1 : 0] c
    );
    localparam c_bound = (nu + nu >=  eta + lambda) ? nu + nu : eta + lambda;
    
    genvar i, j;
        
    reg rand_reset = 1'b1;
    wire [eta-1 : 0] r;
    wire [nu-1 : 0] s;
    
    always @ (posedge clk) begin
    
    end
    
    // create random noise numbers r and s
    generate 
        for (i=0; i < eta/16; i = i+1) begin
            rand127 rand1(
                .rand_out(r),
                .seed_in (seed_in & i),
                .state_in(4'd0),
                .clock_in(clk),
                .reset_in(rand_reset)
            );
        end
        
        for (i=0; i < nu/16; i = i+1) begin
            rand127 rand2(
                .rand_out(s[(i+1)*16 - 1 -: 16]),
                .seed_in (s & i),
                .state_in(4'd0),
                .clock_in(clk),
                .reset_in(rand_reset)
            );
        end
    endgenerate
    

    wire [(lambda+eta)-1:0] N_public_modulus;
    assign N_public_modulus = q_param*p_key;
    
    reg [c_bound-1 :0] m_enc, noise1, noise2;
    
    reg [eta-1 : 0] r_reg;
    reg [nu-1 : 0] s_reg;
    
    always @ (posedge clk) begin
        // limit size of r and s to q and kappa respectively
        r_reg <= r & q_param - 1;
        s_reg <= s & kappa_key - 1;
        
        noise1 <= (r*q_param)%N_public_modulus;
        noise2 <= (s*kappa_key)%N_public_modulus;
        
        m_enc <= (m + noise1 + noise2)%N_public_modulus;
        
    end
    
    assign c = m_enc;
    
    
endmodule
