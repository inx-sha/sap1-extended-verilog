// program_counter.v — 4-bit Program Counter (unchanged)
module program_counter (
    input        clk,
    input        clr,   // async clear
    input        Cp,    // count pulse
    input        Ep,    // enable onto bus
    output [3:0] pc_out,
    output [7:0] bus_out
);
    reg [3:0] pc;

    always @(posedge clk or posedge clr) begin
        if (clr)      pc <= 4'b0000;
        else if (Cp)  pc <= pc + 1;
    end

    assign pc_out  = pc;
    assign bus_out = {4'b0000, pc};
endmodule
