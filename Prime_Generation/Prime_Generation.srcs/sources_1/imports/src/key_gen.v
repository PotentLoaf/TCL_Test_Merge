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
localparam WORDSIZE = 32;

module key_gen(
    input clk, reset
);



    reg [WORDSIZE-1:0] accuracy, potential_prime;
    reg [WORDSIZE-1:0] key1, key2;
    reg [WORDSIZE-1:0] nextkey1, nextkey2; 
    reg [31:0] potential_prime;
    reg prime_reset, rand_reset;
    wire finish, prime, oneprime, bothprimes;

    wire [126:0] seed_in1 = {{7{16'haaaa}},15'haaa3};
    wire [126:0] seed_in2 = {{7{16'haaaa}},15'h3244};

    wire [15:0] rand_out1;
    wire [15:0] rand_out2;

    always @ (posedge clk) begin
        // reset miller rabin module and rand127 module
        if (reset) begin
            prime_reset = 1'b1;
            rand_reset = 1'b1;
        end else begin
            prime_reset = 1'b0;
            rand_reset = 1'b0;
        end

        // if prime checking is done, insert new prime
        if (finish) begin
            if (prime) begin
                if (~oneprime && ~bothprimes) begin
                    key1 <= potential_prime;
                end else if (oneprime && ~bothprimes) begin
                    key2 <= potential_prime;
                end
            end
            potential_prime <= {rand_out1, rand_out2[15:1], 1'b1};
            prime_reset <= 1'b1;
        end

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
