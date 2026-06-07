// sap1_top.v — Top-level, extended SAP-1 with ADD/SUB/MUL/DIV
// OR-MUX bus (Vivado XSim compatible — no tri-state)
module sap1_top (
    input        clk,
    input        clr,
    output [7:0] out_data,
    output       div_zero   // high when a divide-by-zero is attempted
);
    // ── Control signals ────────────────────────────────────────
    wire        HLT, Lm, CE, Li, Ei;
    wire        La, Ea, Lb, Lo, Cp, Ep, Eu;
    wire [1:0]  su;                   // 2-bit ALU mode

    // ── Gated clock ────────────────────────────────────────────
    wire gated_clk = clk & ~HLT;

    // ── Internal buses / wires ─────────────────────────────────
    wire [3:0] mar_addr, opcode;
    wire [7:0] a_to_alu, b_to_alu;
    wire [7:0] pc_bus, ram_bus, ir_bus, acc_bus, alu_bus;

    // ── OR-MUX W-bus ───────────────────────────────────────────
    // Controller guarantees mutual exclusion — at most one enable
    // is asserted per clock step, so OR == select.
    wire [7:0] w_bus = (Ep ? pc_bus  : 8'h00)
                     | (CE ? ram_bus  : 8'h00)
                     | (Ei ? ir_bus   : 8'h00)
                     | (Ea ? acc_bus  : 8'h00)
                     | (Eu ? alu_bus  : 8'h00);

    // ── Module instantiations ──────────────────────────────────
    program_counter u_pc (
        .clk(gated_clk), .clr(clr),
        .Cp(Cp), .Ep(Ep),
        .pc_out(),        // not used externally
        .bus_out(pc_bus)
    );

    mar u_mar (
        .clk(gated_clk),
        .Lm(Lm), .bus_in(w_bus),
        .addr_out(mar_addr)
    );

    ram u_ram (
        .CE(CE),
        .addr(mar_addr),
        .bus_out(ram_bus)
    );

    instruction_register u_ir (
        .clk(gated_clk), .clr(clr),
        .Li(Li), .Ei(Ei),
        .bus_in(w_bus),
        .opcode(opcode),
        .bus_out(ir_bus)
    );

    accumulator u_acc (
        .clk(gated_clk), .clr(clr),
        .La(La), .Ea(Ea),
        .bus_in(w_bus),
        .a_out(a_to_alu),
        .bus_out(acc_bus)
    );

    b_register u_b (
        .clk(gated_clk), .clr(clr),
        .Lb(Lb), .bus_in(w_bus),
        .b_out(b_to_alu)
    );

    alu u_alu (
        .su(su), .Eu(Eu),
        .a_in(a_to_alu), .b_in(b_to_alu),
        .bus_out(alu_bus),
        .div_zero(div_zero)
    );

    output_register u_out (
        .clk(gated_clk), .clr(clr),
        .Lo(Lo), .bus_in(w_bus),
        .out_data(out_data)
    );

    controller u_ctrl (
        .clk(gated_clk), .clr(clr),
        .opcode(opcode),
        .HLT(HLT), .Lm(Lm), .CE(CE), .Li(Li), .Ei(Ei),
        .La(La),   .Ea(Ea), .Lb(Lb), .Lo(Lo),
        .Cp(Cp),   .Ep(Ep), .su(su), .Eu(Eu)
    );
endmodule
