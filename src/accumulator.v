module accumulator #(
    parameter ACC_WIDTH = 8,  // Parameter to define the bit width of the accumulator
    parameter ADD_WIDTH = 8   // Parameter to define the bit width of the value to be added
)(
    input wire clk,                        // Clock input
    input wire rst_n,                      // Active low reset
    input wire [ADD_WIDTH-1:0] add_value,  // Input value to be added to the accumulator
    output wire [ACC_WIDTH-1:0] data       // Output data (accumulator register)
);

    // Internal accumulator register
    reg [ACC_WIDTH-1:0] acc;

    wire [ACC_WIDTH-1:0] extended_add_value;
    assign extended_add_value = { {ACC_WIDTH-ADD_WIDTH{1'b0}}, add_value };

    // Always block triggered on the rising edge of the clock or the falling edge of the reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset: when rst_n is low, reset the accumulator to 0
            acc <= {ACC_WIDTH{1'b0}};
        end else begin
            // On the rising edge of the clock, add the input value to the accumulator
            acc <= acc + extended_add_value;
        end
    end

    // Assign the accumulator value to the output
    assign data = acc;

endmodule
