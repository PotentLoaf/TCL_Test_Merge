`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2023 02:54:25 PM
// Design Name: 
// Module Name: key_gen
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


module key_gen #(lambda = 32, eta = 32, nu = 16) (
    input clk, reset,
    output finish,
    output reg [eta-1 : 0] q_param,
    output reg [lambda-1 : 0] p_key,
    output reg [nu-1 : 0] kappa_key
);
    wire [2:0] done;
    reg rand_reset = 1'b1;
    assign done = {prime1, prime2, prime3};
    assign finish = (done == 3'b111) ? 1'b1 : 1'b0;

    always @ (posedge clk) begin
        if (reset) begin
            prime_reset1 <= 1'b1;
            prime_reset2 <= 1'b1;
            prime_reset3 <= 1'b1;
            rand_count_top1 <= 0;
            rand_count_top2 <= 0;
            rand_count_top3 <= 0;
        end
        if (finish) begin 
            q_param <= q;
            p_key <= p;
            kappa_key <= kappa;
        end
        if (rand_reset) begin
            rand_reset <= 1'b0;
        end
    end

    
    // instantiating 3 rands and 3 miller rabins to generate primes
    
    reg [lambda*2 -1:0] accuracy1; 
    reg [lambda-1:0] p;
    reg prime_reset1;
    wire finish1, prime1;
    reg [31:0] rand_count_top1 = 0;

    wire [126:0] seed_in1 = {{7{16'haaaa}},15'haaa3};

    wire [15:0] rand_out1;
    always @ (posedge clk) begin
        if (prime_reset1) begin
            if (rand_count_top1 < lambda/16) begin
                p[(rand_count_top1+1)*16-1 -: 16] <= rand_out1;
                rand_count_top1 <= rand_count_top1 + 1; 
            end else begin
                p[0] <= 1'b1;
                prime_reset1 <= 1'b0;
            end
        end
        if (finish1 & ~prime1) begin
            prime_reset1 <=1'b1;
            rand_count_top1 <= 0;
        end  
    end

    rand127 rand1(
    .rand_out(rand_out1),
    .seed_in (seed_in1),
    .state_in(4'd0),
    .clock_in(clk),
    .reset_in(rand_reset)
    );

    miller_rabin  #(.WORDSIZE(lambda)) prime_gen1 (
    .start_number(p),
    .accuracy(accuracy1),
    .clk(clk),
    .reset(prime_reset1),
    .prime(prime1),
    .finish(finish1)
    );
    
    reg [eta*2 -1:0] accuracy2; 
    reg [eta-1:0] q;
    reg prime_reset2;
    wire finish2, prime2;
    reg [31:0] rand_count_top2 = 0;

    wire [126:0] seed_in2 = {{7{16'h32ff}},15'h4323};

    wire [15:0] rand_out2;
    always @ (posedge clk) begin
        if (prime_reset2) begin
            if (rand_count_top2 < eta/16) begin
                q[(rand_count_top2+1)*16-1 -: 16] <= rand_out2;
                rand_count_top2 <= rand_count_top2 + 1;;
            end else begin
                q[0] <= 1'b1;
                prime_reset2 <= 1'b0;
            end
        end
        if (finish2 & ~prime2) begin
            prime_reset2 <=1'b1;
            rand_count_top2 <= 0;
        end  
    end

    rand127 rand2(
    .rand_out(rand_out2),
    .seed_in (seed_in2),
    .state_in(4'd0),
    .clock_in(clk),
    .reset_in(rand_reset)
    );

    miller_rabin  #(.WORDSIZE(eta)) prime_gen2 (
    .start_number(q),
    .accuracy(accuracy2),
    .clk(clk),
    .reset(prime_reset2),
    .prime(prime2),
    .finish(finish2)
    );
    
    reg [nu*2 -1:0] accuracy3; 
    reg [nu-1:0] kappa;
    reg prime_reset3;
    wire finish3, prime3;
    reg [31:0] rand_count_top3 = 0;

    wire [126:0] seed_in3 = {{7{16'h2399}},15'hbb31};

    wire [15:0] rand_out3;
    always @ (posedge clk) begin
        if (prime_reset3) begin
            if (rand_count_top3 < nu/16) begin
                kappa[(rand_count_top3+1)*16-1 -: 16] <= rand_out3;
                rand_count_top3 <= rand_count_top3 + 1;
            end else begin
                kappa[0] <= 1'b1;
                prime_reset3 <= 1'b0;
            end
        end
        if (finish3 & ~prime3) begin
            prime_reset3 <=1'b1;
            rand_count_top3 <= 0;
        end   
    end

    rand127 rand3(
    .rand_out(rand_out3),
    .seed_in (seed_in3),
    .state_in(4'd0),
    .clock_in(clk),
    .reset_in(rand_reset)
    );

    miller_rabin  #(.WORDSIZE(nu)) prime_gen3 (
    .start_number(kappa),
    .accuracy(accuracy3),
    .clk(clk),
    .reset(prime_reset3),
    .prime(prime3),
    .finish(finish3)
    );
    
    //
endmodule
