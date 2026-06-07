// controller.v — Extended 6-step sequencer
// New opcodes: 0011=MUL, 0100=DIV
// su is now 2-bit to select all four ALU operations
module controller (
    input        clk,
    input        clr,
    input  [3:0] opcode,
    output reg        HLT,
    output reg        Lm, CE, Li, Ei,
    output reg        La, Ea, Lb, Lo, Cp, Ep,
    output reg [1:0]  su,   // 2-bit ALU mode
    output reg        Eu
);
    reg [2:0] step;

    // Sequential: step counter
    always @(posedge clk or posedge clr) begin
        if (clr)
            step <= 3'd0;
        else if (HLT)
            step <= step;      // freeze on halt
        else if (step == 3'd5)
            step <= 3'd0;
        else
            step <= step + 1;
    end

    // Combinational: control word decoder
    always @(*) begin
        // default all signals off
        {HLT, Lm, CE, Li, Ei, La, Ea, Lb, Lo, Cp, Ep} = 11'b0;
        su  = 2'b00;
        Eu  = 0;

        case (step)
            // ── Fetch cycle (same for every instruction) ──────────────
            3'd0: begin Ep = 1; Lm = 1; end            // T1: MAR <- PC
            3'd1: begin Cp = 1; end                     // T2: PC++
            3'd2: begin CE = 1; Li = 1; end             // T3: IR <- RAM[MAR]

            // ── Execute cycles ────────────────────────────────────────
            3'd3, 3'd4, 3'd5: begin
                case (opcode)
                    4'b0000: begin // LDA  — load accumulator
                        if (step==3'd3) begin Ei=1; Lm=1; end
                        if (step==3'd4) begin CE=1; La=1; end
                    end

                    4'b0001: begin // ADD  — A <- A + RAM[addr]
                        if (step==3'd3) begin Ei=1; Lm=1; end
                        if (step==3'd4) begin CE=1; Lb=1; end
                        if (step==3'd5) begin Eu=1; La=1; su=2'b00; end
                    end

                    4'b0010: begin // SUB  — A <- A - RAM[addr]
                        if (step==3'd3) begin Ei=1; Lm=1; end
                        if (step==3'd4) begin CE=1; Lb=1; end
                        if (step==3'd5) begin Eu=1; La=1; su=2'b01; end
                    end

                    4'b0011: begin // MUL  — A <- A * RAM[addr]  (lower 8 bits)
                        if (step==3'd3) begin Ei=1; Lm=1; end
                        if (step==3'd4) begin CE=1; Lb=1; end
                        if (step==3'd5) begin Eu=1; La=1; su=2'b10; end
                    end

                    4'b0100: begin // DIV  — A <- A / RAM[addr]  (integer)
                        if (step==3'd3) begin Ei=1; Lm=1; end
                        if (step==3'd4) begin CE=1; Lb=1; end
                        if (step==3'd5) begin Eu=1; La=1; su=2'b11; end
                    end

                    4'b1110: begin // OUT  — Output <- A
                        if (step==3'd3) begin Ea=1; Lo=1; end
                    end

                    4'b1111: HLT = 1; // HLT

                    default: ; // NOP — do nothing
                endcase
            end
        endcase
    end
endmodule
