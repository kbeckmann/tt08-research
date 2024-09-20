`default_nettype none

module mul_bit_serial #(
    parameter integer WIDTH = 16
) (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    output wire [WIDTH*2-1:0] output_result,
    output reg output_valid
);

    reg [WIDTH-1:0] b_reg;
    reg [WIDTH*2-1:0] partial_product;
    reg [$clog2(WIDTH):0] bit_counter;
    reg multiplying;
    wire [WIDTH*2-1:0] sum;
    wire cout;
    assign output_result = partial_product;


    wire [WIDTH*2-1:0] a_add = partial_product;
    wire [WIDTH*2-1:0] b_add = a << bit_counter;
    rca #(.WIDTH(WIDTH*2)) rca_inst (
        .A(a_add),
        .B(b_add),
        .Cin(1'b0),
        .Sum(sum),
        .Cout(cout)
    );


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            b_reg <= 0;
            partial_product <= 0;
            bit_counter <= 0;
            multiplying <= 1'b0;
            output_valid <= 1'b0;
        end else begin
            if (start && !multiplying) begin
                b_reg <= b;
                partial_product <= 0;
                bit_counter <= 0;
                multiplying <= 1'b1;
                output_valid <= 1'b0;
            end else if (multiplying) begin
                if (b_reg[0]) begin
                    // partial_product <= partial_product + (a << bit_counter);
                    partial_product <= sum;
                end
                b_reg <= b_reg >> 1;
                bit_counter <= bit_counter + 1;

                if (bit_counter == WIDTH) begin
                    multiplying <= 1'b0;
                    output_valid <= 1'b1;
                end
            end else begin
                output_valid <= 1'b0;
            end
        end
    end

endmodule