// accumulator.v (unchanged)
module accumulator (
    input        clk,
    input        clr,
    input        La,
    input        Ea,
    input  [7:0] bus_in,
    output [7:0] a_out,
    output [7:0] bus_out
);
    reg [7:0] a;

    always @(posedge clk or posedge clr) begin
        if (clr)     a <= 8'h00;
        else if (La) a <= bus_in;
    end

    assign a_out   = a;
    assign bus_out = a;
endmodule

// ─────────────────────────────────────────────────────────────────────────────

// b_register.v (unchanged)
module b_register (
    input        clk,
    input        clr,
    input        Lb,
    input  [7:0] bus_in,
    output [7:0] b_out
);
    reg [7:0] b;

    always @(posedge clk or posedge clr) begin
        if (clr)     b <= 8'h00;
        else if (Lb) b <= bus_in;
    end

    assign b_out = b;
endmodule

// ─────────────────────────────────────────────────────────────────────────────

// output_register.v (unchanged)
module output_register (
    input        clk,
    input        clr,
    input        Lo,
    input  [7:0] bus_in,
    output [7:0] out_data
);
    reg [7:0] out_reg;

    always @(posedge clk or posedge clr) begin
        if (clr)     out_reg <= 8'h00;
        else if (Lo) out_reg <= bus_in;
    end

    assign out_data = out_reg;
endmodule
