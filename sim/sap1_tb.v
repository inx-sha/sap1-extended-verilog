// sap1_tb.v — Testbench for extended SAP-1 (ADD/SUB/MUL/DIV)
// Expected output: 11 (decimal)
// Trace: 20 + 5 = 25 → 25 - 3 = 22 → 22 * 4 = 88 → 88 / 8 = 11
`timescale 1ns/1ps

module sap1_tb;
    reg        clk;
    reg        clr;
    wire [7:0] out_data;
    wire       div_zero;

    // ── DUT ────────────────────────────────────────────────────
    sap1_top dut (
        .clk(clk),
        .clr(clr),
        .out_data(out_data),
        .div_zero(div_zero)
    );

    // ── 100 MHz clock ──────────────────────────────────────────
    initial clk = 0;
    always  #5 clk = ~clk;    // 10 ns period

    // ── Stimulus ───────────────────────────────────────────────
    initial begin
        clr = 1;
        #20;
        clr = 0;
        #5000;   // enough time for 7 instructions × 6 steps × 10 ns
        $display("─────────────────────────────────────────");
        $display("Final out_data = %0d (0x%0h)", out_data, out_data);
        $display("Expected       = 11  (0x0b)");
        $display("div_zero flag  = %0b", div_zero);
        if (out_data == 8'd11)
            $display("PASS ✓");
        else
            $display("FAIL ✗  — check waveform");
        $display("─────────────────────────────────────────");
        $finish;
    end

    // ── Per-cycle log ──────────────────────────────────────────
    always @(posedge clk)
        $display("t=%0t | out=%0d | div_zero=%0b", $time, out_data, div_zero);
endmodule
