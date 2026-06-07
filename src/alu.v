// alu.v — Extended ALU: Add, Subtract, Multiply, Divide
// su[1:0]: 00=Add, 01=Subtract, 10=Multiply, 11=Divide
module alu (
    input  [1:0] su,       // operation select (2-bit now)
    input        Eu,       // enable output onto W-bus
    input  [7:0] a_in,
    input  [7:0] b_in,
    output [7:0] bus_out,
    output       div_zero  // division-by-zero flag
);
    reg  [7:0]  result;
    reg         dz;
    wire [15:0] mul_full = a_in * b_in;  // full 16-bit product

    always @(*) begin
        result = 8'h00;
        dz     = 0;
        case (su)
            2'b00: result = a_in + b_in;        // ADD
            2'b01: result = a_in - b_in;        // SUB
            2'b10: result = mul_full[7:0];      // MUL (lower 8 bits)
            2'b11: begin                        // DIV
                if (b_in == 8'h00) begin
                    result = 8'hFF;
                    dz     = 1;
                end else begin
                    result = a_in / b_in;
                end
            end
        endcase
    end

    assign bus_out  = result;
    assign div_zero = dz;
endmodule
