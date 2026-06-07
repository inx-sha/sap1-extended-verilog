// mar.v — Memory Address Register (unchanged)
module mar (
    input        clk,
    input        Lm,
    input  [7:0] bus_in,
    output [3:0] addr_out
);
    reg [3:0] mar_reg;

    always @(posedge clk) begin
        if (Lm) mar_reg <= bus_in[3:0];
    end

    assign addr_out = mar_reg;
endmodule
