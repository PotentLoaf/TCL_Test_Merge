`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2023 10:40:28 AM
// Design Name: 
// Module Name: prime_tb
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


module prime_tb(

);

    reg [63:0] accuracy;
    reg [31:0] potential_prime;
    reg prime_reset, clk, rand_reset;
    wire finish, prime;

    initial begin
    potential_prime = 32'd3;
    accuracy = 64'd5;

    clk = 1'b0;

    prime_reset = 1'b1;
    rand_reset = 1'b1;

    #10
    prime_reset = 1'b0;
    rand_reset = 1'b0;
    end
    
    always
    begin
    clk = ~clk;
    #5;
    end


    wire [126:0] seed_in1 = {{7{16'haaaa}},15'haaa3};
    wire [126:0] seed_in2 = {{7{16'haaaa}},15'h3244};

    wire [15:0] rand_out1;
    wire [15:0] rand_out2;

    always @ (posedge finish) begin
    potential_prime <= {rand_out1, rand_out2[15:1], 1'b1};
    prime_reset <= 1'b1;

    end
    always @ (negedge (finish)) begin
    prime_reset <= 1'b0;
    end

    rand127 rand1(
    .rand_out(rand_out1),
    .seed_in (seed_in1),
    .state_in(4'd0),
    .clock_in(clk),
    .reset_in(rand_reset)
    );

    rand127 rand2(
    .rand_out(rand_out2),
    .seed_in (seed_in2),
    .state_in(4'd0),
    .clock_in(clk),
    .reset_in(rand_reset)
    );


    miller_rabin prime_gen(
    .start_number(potential_prime),
    .accuracy(accuracy),
    .clk(clk),
    .reset(prime_reset),
    .prime(prime),
    .finish(finish)
    );
endmodule
