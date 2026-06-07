// instruction_register.v
module instruction_register (
    input        clk,
    input        clr,
    input        Li,
    input        Ei,
    input  [7:0] bus_in,
    output [3:0] opcode,
    output [7:0] bus_out
);
    reg [7:0] ir;

    always @(posedge clk or posedge clr) begin
        if (clr)     ir <= 8'h00;
        else if (Li) ir <= bus_in;
    end

    assign opcode  = ir[7:4];
    assign bus_out = {4'b0000, ir[3:0]};
endmodule
