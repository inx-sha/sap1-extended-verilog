# SAP-1 Extended CPU — Verilog HDL

An extended implementation of the **SAP-1 (Simple As Possible)** 8-bit computer in Verilog HDL, built and simulated on **Xilinx Vivado 2018.2**.

Originally introduced by Malvino & Brown in *Digital Computer Electronics*, the SAP-1 is extended here to support all four arithmetic operations: **ADD, SUB, MUL, DIV**.

**Author:** Inshaf Ahamed  
**Institution:** PAF-IAST, BS Computer Engineering  
**Course:** Computer Architecture & Organization (CAO)

---

## Instruction Set Architecture

| Opcode | Mnemonic | Operation                  | Notes                        |
|--------|----------|----------------------------|------------------------------|
| `0000` | LDA addr | A ← RAM[addr]              | Load accumulator             |
| `0001` | ADD addr | A ← A + RAM[addr]          | Addition                     |
| `0010` | SUB addr | A ← A − RAM[addr]          | Subtraction                  |
| `0011` | MUL addr | A ← (A × RAM[addr])[7:0]   | Multiply, lower 8 bits only  |
| `0100` | DIV addr | A ← A ÷ RAM[addr]          | Integer divide; 0xFF if ÷0   |
| `1110` | OUT      | Output ← A                 | Latch to output register     |
| `1111` | HLT      | Stop                       | Gates off the clock          |

---

## Architecture

All modules communicate over a shared **8-bit W-bus**. The controller generates a 6-step fetch-decode-execute sequence per instruction.

```
┌─────────────────────────────────────────┐
│              8-bit W-BUS                │
└──┬────┬────┬────┬────┬────┬─────────────┘
   │    │    │    │    │    │
  RAM  MAR   IR  ACC  ALU  OUT
              │
          Controller
         (6-step FSM)
```

### Key design decisions

- **OR-MUX bus** replaces tri-state (`8'bz`) for Vivado XSim compatibility. The controller guarantees mutual exclusion so OR == select.
- **2-bit `su` signal** in the ALU selects between all four operations (was 1-bit ADD/SUB only in the original SAP-1).
- **16-bit intermediate wire** for multiplication avoids part-select-on-expression syntax errors in Verilog.
- **Divide-by-zero** returns `0xFF` and asserts a `div_zero` flag rather than causing undefined behaviour.

---

## File Structure

```
sap1-extended-verilog/
├── src/
│   ├── alu.v                  # Extended ALU: ADD/SUB/MUL/DIV
│   ├── controller.v           # 6-step FSM, 2-bit su, MUL/DIV opcodes
│   ├── program_counter.v      # 4-bit synchronous counter
│   ├── mar.v                  # Memory Address Register
│   ├── ram.v                  # 16×8 ROM, pre-loaded test program
│   ├── instruction_register.v # IR with opcode/operand split
│   ├── registers.v            # Accumulator, B Register, Output Register
│   └── sap1_top.v             # Top-level integration + OR-MUX bus
├── sim/
│   └── sap1_tb.v              # Behavioral testbench
└── README.md
```

---

## Test Program

Loaded into RAM to exercise all four arithmetic instructions:

| Address | Assembly  | Operation         | Result |
|---------|-----------|-------------------|--------|
| 0x0     | LDA 9     | A ← 20            | A = 20 |
| 0x1     | ADD 10    | A ← 20 + 5        | A = 25 |
| 0x2     | SUB 11    | A ← 25 − 3        | A = 22 |
| 0x3     | MUL 12    | A ← 22 × 4        | A = 88 |
| 0x4     | DIV 13    | A ← 88 ÷ 8        | A = 11 |
| 0x5     | OUT       | Output ← 11       |        |
| 0x6     | HLT       | Clock halted      |        |

**Expected `out_data` after simulation: `0x0B` (11 decimal)**

---

## How to Run

1. Open Vivado → Create Project → RTL Project
2. Add all files under `src/` as **Design Sources**
3. Add `sim/sap1_tb.v` as a **Simulation Source**
4. Set `sap1_top` as top module; `sap1_tb` as simulation top
5. Run **Behavioral Simulation**
6. Expected console output:
```
Final out_data = 11 (0xb)
Expected       = 11  (0x0b)
div_zero flag  = 0
PASS ✓
```

---

## Limitations

- MUL keeps only the **lower 8 bits** — products above 255 overflow silently
- DIV is **integer division** (no remainder)
- No jump instructions — loops are not possible in this ISA
- 16-byte RAM limits program size to ~7 instructions + data

---

## Tools

- Xilinx Vivado 2018.2
- XSim Behavioral Simulator
- Verilog HDL (IEEE 1364-2005)
- Target board: Digilent Basys3 (Artix-7)
