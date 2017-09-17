---
layout: default
title: Instruction Actions | RISCV Multi Cycle
---

This page shows concisely the side effects of every instruction in the RV32UI
subset which the core implements.

----

Instruction | Action  
------------|----------------------------------------------------
 [ ] ADDI   | rd <- rs + signextend(s12)
 [ ] SLTI   | rd <- rs < signextend(s12) ? 1 : 0
 [ ] ANDI   | rd <- rs & signextend(s12)
 [ ] ORI    | rd <- rs \| signextend(s12)
 [ ] XORI   | rd <- rs ^ signextend(s12)
 [ ] LUI    | rd[31:12] <- u20, rd[11:0]  <- 0
 [ ] AUIPC  | rd[31:12] <- PC + u20, rd[11:0]  <- 0
 [ ] ADD    | rd <- rs1 + rs2
 [ ] SUB    | rd <- rs1 - rs2
 [ ] AND    | rd <- rs1 & rs2
 [ ] OR     | rd <- rs1 \| rs2
 [ ] XOR    | rd <- rs1 ^ rs2
 [ ] SLTU   | rd <- rs1 < rs2
 [ ] SLL    | rd <- rs1 <<  rs2
 [ ] SRL    | rd <- rs1 >>  rs2
 [ ] SRA    | rd <- rs1 >>> rs2
 [ ] JAL    | rd <- PC + 4, PC <- PC + s20
 [ ] JALR   | rd <- PC + 4, PC <- rs1 + s12
 [ ] BEQ    | PC <- rs1 == rs2 ? PC+s12 : PC+4
 [ ] BNE    | PC <- rs1 != rs2 ? PC+s12 : PC+4
 [ ] BLT    | PC <- rs1 <  rs2 ? PC+s12 : PC+4
 [ ] BGT    | PC <- rs1 >  rs2 ? PC+s12 : PC+4
 [ ] LOAD   | rd <- mem[rs1+s12]
 [ ] STORE  | mem[rs1+s12] <- rs2
 [ ] CSRRW  | tmp     <- rs1, rs1     <- CSR[rd], CSR[rd] <- tmp
 [ ] CSRRS  | tmp     <- rs1, rs1     <- CSR[rd], CSR[rd] <- CSR[rd] \| tmp
 [ ] CSRRC  | tmp     <- rs1, rs1     <- CSR[rd], CSR[rd] <- CSR[rd] & ~tmp

