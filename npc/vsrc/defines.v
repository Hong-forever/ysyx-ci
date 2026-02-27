`timescale 1ns / 1ps
//------------------------------------------------------------------------
// VERILOG MACRO
//------------------------------------------------------------------------
`define DPIC
`define PERF
`define DEBUG
// `define SOC //no verilog macro define here, define it in Makefile

//------------------------------------------------------------------------
// CLOCK
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// INSTRUCTION FIELD DEFINITIONS (BIT RANGE)
//------------------------------------------------------------------------
`define ysyx_25110270_RV32_OP  6:0    // Opcode field (7 bits)
`define ysyx_25110270_RV32_RD  10:7   // Destination register field (4 bits)
`define ysyx_25110270_RV32_F3  14:12  // Function 3 field (3 bits)
`define ysyx_25110270_RV32_RS1 18:15  // Source register 1 field (4 bits)
`define ysyx_25110270_RV32_RS2 23:20  // Source register 2 field (4 bits)
`define ysyx_25110270_RV32_F7  31:25  // Function 7 field (7 bits)

//------------------------------------------------------------------------
// FIELD WIDTH DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_RV32_OP_WIDTH   7   // Opcode field width
`define ysyx_25110270_RV32_RD_WIDTH   4   // Destination register field width
`define ysyx_25110270_RV32_RS1_WIDTH  4   // Source register 1 field width
`define ysyx_25110270_RV32_RS2_WIDTH  4   // Source register 2 field width
`define ysyx_25110270_RV32_F3_WIDTH   3   // funct3 field width
`define ysyx_25110270_RV32_F7_WIDTH   7   // funct7 field width

//------------------------------------------------------------------------
// rv32i load type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV32I_OP_TYPE_IL 7'b0000011
`define ysyx_25110270_RV32I_F3_LB      3'b000
`define ysyx_25110270_RV32I_F3_LH      3'b001
`define ysyx_25110270_RV32I_F3_LW      3'b010
`define ysyx_25110270_RV32I_F3_LBU     3'b100
`define ysyx_25110270_RV32I_F3_LHU     3'b101

//------------------------------------------------------------------------
// rv32i I type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV32I_OP_TYPE_I 7'b0010011
`define ysyx_25110270_RV32I_F3_ADDI   3'b000
`define ysyx_25110270_RV32I_F3_SLLI   3'b001
`define ysyx_25110270_RV32I_F3_SLTI   3'b010
`define ysyx_25110270_RV32I_F3_SLTIU  3'b011
`define ysyx_25110270_RV32I_F3_XORI   3'b100
`define ysyx_25110270_RV32I_F3_SRI    3'b101
`define ysyx_25110270_RV32I_F3_ORI    3'b110
`define ysyx_25110270_RV32I_F3_ANDI   3'b111

//------------------------------------------------------------------------
// rv32i U type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV32I_OP_AUIPC  7'b0010111
`define ysyx_25110270_RV32I_OP_LUI    7'b0110111

//------------------------------------------------------------------------
// rv32i S type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV32I_OP_TYPE_S 7'b0100011
`define ysyx_25110270_RV32I_F3_SB     3'b000
`define ysyx_25110270_RV32I_F3_SH     3'b001
`define ysyx_25110270_RV32I_F3_SW     3'b010

// rv32i/rv32m R/M type inst
`define ysyx_25110270_RV32IM_OP_TYPE_R 7'b0110011

`define ysyx_25110270_RV32I_F3_ADD_SUB 3'b000
`define ysyx_25110270_RV32I_F3_SLL     3'b001
`define ysyx_25110270_RV32I_F3_SLT     3'b010
`define ysyx_25110270_RV32I_F3_SLTU    3'b011
`define ysyx_25110270_RV32I_F3_XOR     3'b100
`define ysyx_25110270_RV32I_F3_SR      3'b101
`define ysyx_25110270_RV32I_F3_OR      3'b110
`define ysyx_25110270_RV32I_F3_AND     3'b111

`define ysyx_25110270_RV32I_F7_R1    7'b0000000
`define ysyx_25110270_RV32I_F7_R2    7'b0100000

//------------------------------------------------------------------------
// rv32i B type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV32I_OP_TYPE_B 7'b1100011
`define ysyx_25110270_RV32I_F3_BEQ    3'b000
`define ysyx_25110270_RV32I_F3_BNE    3'b001
`define ysyx_25110270_RV32I_F3_BLT    3'b100
`define ysyx_25110270_RV32I_F3_BGE    3'b101
`define ysyx_25110270_RV32I_F3_BLTU   3'b110
`define ysyx_25110270_RV32I_F3_BGEU   3'b111

//------------------------------------------------------------------------
// rv32i J type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV32I_OP_JALR   7'b1100111
`define ysyx_25110270_RV32I_OP_JAL    7'b1101111

//------------------------------------------------------------------------
// rv32 Except type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV_MRET       32'h30200073
`define ysyx_25110270_RV_ECALL      32'h00000073
`define ysyx_25110270_RV_EBREAK     32'h00100073

`define ysyx_25110270_RV_FENCE_I    32'h0000100F

//------------------------------------------------------------------------
// rv32zicsr CSR type inst
//------------------------------------------------------------------------
`define ysyx_25110270_RV_OP_CSR    7'b1110011
`define ysyx_25110270_RV_F3_CSRRW  3'b001
`define ysyx_25110270_RV_F3_CSRRS  3'b010
`define ysyx_25110270_RV_F3_CSRRC  3'b011
`define ysyx_25110270_RV_F3_CSRRWI 3'b101
`define ysyx_25110270_RV_F3_CSRRSI 3'b110
`define ysyx_25110270_RV_F3_CSRRCI 3'b111

//------------------------------------------------------------------------
// GENERAL PURPOSE REGISTER DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_RegNum 16        // reg num
`define ysyx_25110270_RegAddrWidth $clog2(`ysyx_25110270_RegNum)
`define ysyx_25110270_RegAddrBus `ysyx_25110270_RegAddrWidth-1:0

//------------------------------------------------------------------------
// CSR REGISTER DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_CsrNum 16
`define ysyx_25110270_CsrMapWidth $clog2(`ysyx_25110270_CsrNum)
`define ysyx_25110270_CsrMapBus `ysyx_25110270_CsrMapWidth-1:0

`define ysyx_25110270_CSR_MSTATUS           12'h300     // Machine Status Register
`define ysyx_25110270_CSR_MIE               12'h304     // Machine Interrupt Enable Registers
`define ysyx_25110270_CSR_MTVEC             12'h305     // Machine Trap-Vector Base-Address Register
`define ysyx_25110270_CSR_MEPC              12'h341     // Machine Exception Program Counter
`define ysyx_25110270_CSR_MCAUSE            12'h342     // Machine Cause Register
`define ysyx_25110270_CSR_CYCLE             12'hc00     // Lower 32 bits of Cycle counter
`define ysyx_25110270_CSR_CYCLEH            12'hc80     // Upper 32 bits of Cycle counter
`define ysyx_25110270_CSR_MVENDORID         12'hf11     // Vendor ID
`define ysyx_25110270_CSR_MARCHID           12'hf12     // Architecture ID

`define ysyx_25110270_CSR_MAP_MSTATUS       0
`define ysyx_25110270_CSR_MAP_MIE           1
`define ysyx_25110270_CSR_MAP_MTVEC         2
`define ysyx_25110270_CSR_MAP_MEPC          3
`define ysyx_25110270_CSR_MAP_MCAUSE        4
`define ysyx_25110270_CSR_MAP_CYCLE         5
`define ysyx_25110270_CSR_MAP_CYCLEH        6
`define ysyx_25110270_CSR_MAP_MVENDORID     7
`define ysyx_25110270_CSR_MAP_MARCHID       8

//------------------------------------------------------------------------
// ALU SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_ALUSRCA_RS1     2'b01
`define ysyx_25110270_ALUSRCA_PC      2'b10
`define ysyx_25110270_ALUSRCA_0       2'b11

//------------------------------------------------------------------------
// ALU SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_ALUSRCB_RS2     2'b01
`define ysyx_25110270_ALUSRCB_IMM     2'b10
`define ysyx_25110270_ALUSRCB_4       2'b11

//------------------------------------------------------------------------
// AGU SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_AGUSRC_RS1      2'b01
`define ysyx_25110270_AGUSRC_PC       2'b10
`define ysyx_25110270_AGUSRC_0        2'b11

//------------------------------------------------------------------------
// CSR SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_CSRSRC_RS1      1'b0
`define ysyx_25110270_CSRSRC_IMM      1'b1

//------------------------------------------------------------------------
// FWD SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_FWDSRC_NOP      2'b00
`define ysyx_25110270_FWDSRC_NFW      2'b01
`define ysyx_25110270_FWDSRC_EX       2'b10
`define ysyx_25110270_FWDSRC_LS       2'b11

//------------------------------------------------------------------------
// EXCEPTION TYPE DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_ExceptWidth     3
`define ysyx_25110270_ExceptBus       `ysyx_25110270_ExceptWidth-1:0

`define ysyx_25110270_EXCPT_ECALL     0
`define ysyx_25110270_EXCPT_EBREAK    1
`define ysyx_25110270_EXCPT_MRET      2

//------------------------------------------------------------------------
// MEMORY DEFINITIONS
//------------------------------------------------------------------------
`define ysyx_25110270_CLINT_BASE    32'h0200_0000
`define ysyx_25110270_CLINT_SIZE    32'h0001_0000
`define ysyx_25110270_SERIAL_BASE   32'h1000_0000
`define ysyx_25110270_SERIAL_SIZE   32'h0000_1000
`define ysyx_25110270_SPI_BASE      32'h1000_1000
`define ysyx_25110270_SPI_SIZE      32'h0000_1000
`define ysyx_25110270_GPIO_BASE     32'h1000_2000
`define ysyx_25110270_GPIO_SIZE     32'h0000_0010
`define ysyx_25110270_PS2_BASE      32'h1001_1000
`define ysyx_25110270_PS2_SIZE      32'h0000_0008
`define ysyx_25110270_VGA_BASE      32'h2100_0000
`define ysyx_25110270_VGA_SIZE      32'h0020_0000
`define ysyx_25110270_CHIPL_BASE    32'hc000_0000
`define ysyx_25110270_CHIPL_SIZE    32'h4000_0000

`define ysyx_25110270_MromAddrBase  32'h2000_0000
`define ysyx_25110270_MromSize      32'h0001_0000
`define ysyx_25110270_SramAddrBase  32'h0f00_0000
`define ysyx_25110270_SramSize      32'h0100_0000
`define ysyx_25110270_FlashAddrBase 32'h3000_0000
`define ysyx_25110270_FlashSize     32'h1000_0000
`define ysyx_25110270_PsramAddrBase 32'h8000_0000
`define ysyx_25110270_PsramSize     32'h2000_0000
`define ysyx_25110270_SdramAddrBase 32'ha000_0000
`define ysyx_25110270_SdramSize     32'h2000_0000

`ifdef SOC
    `define ysyx_25110270_RESET_VECTOR  `ysyx_25110270_FlashAddrBase
`else
    `define ysyx_25110270_RESET_VECTOR  `ysyx_25110270_SdramAddrBase
`endif