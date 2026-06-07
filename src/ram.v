// ram.v — 16 x 8-bit RAM
// ────────────────────────────────────────────────────────────────
// Test program: demonstrates ADD, SUB, MUL, DIV in sequence
//
//  Addr  Machine Code  Assembly    Operation
//  0x0   0000_1001     LDA  9      A <- 20
//  0x1   0001_1010     ADD  10     A <- 20 + 5  = 25
//  0x2   0010_1011     SUB  11     A <- 25 - 3  = 22
//  0x3   0011_1100     MUL  12     A <- 22 * 4  = 88
//  0x4   0100_1101     DIV  13     A <- 88 / 8  = 11
//  0x5   1110_0000     OUT         Output <- 11
//  0x6   1111_0000     HLT         Stop
//
//  Data:
//  0x9 = 20   (LDA operand)
//  0xA =  5   (ADD operand)
//  0xB =  3   (SUB operand)
//  0xC =  4   (MUL operand)
//  0xD =  8   (DIV operand)
//
//  Expected final output: 11 (0x0B)
// ────────────────────────────────────────────────────────────────
module ram (
    input        CE,
    input  [3:0] addr,
    output [7:0] bus_out
);
    reg [7:0] mem [0:15];

    initial begin
        // ── Program ────────────────────────────────────────────
        mem[0]  = 8'b0000_1001;   // LDA 9
        mem[1]  = 8'b0001_1010;   // ADD 10
        mem[2]  = 8'b0010_1011;   // SUB 11
        mem[3]  = 8'b0011_1100;   // MUL 12
        mem[4]  = 8'b0100_1101;   // DIV 13
        mem[5]  = 8'b1110_0000;   // OUT
        mem[6]  = 8'b1111_0000;   // HLT
        mem[7]  = 8'h00;
        mem[8]  = 8'h00;
        // ── Data ───────────────────────────────────────────────
        mem[9]  = 8'd20;          // 20  (LDA)
        mem[10] = 8'd5;           //  5  (ADD)
        mem[11] = 8'd3;           //  3  (SUB)
        mem[12] = 8'd4;           //  4  (MUL)
        mem[13] = 8'd8;           //  8  (DIV)
        mem[14] = 8'h00;
        mem[15] = 8'h00;
    end

    assign bus_out = mem[addr];
endmodule
