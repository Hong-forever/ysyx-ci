`timescale 1ns / 1ps
`default_nettype none
//------------------------------------------------------------------------
// VERILOG MACRO
//------------------------------------------------------------------------
`define DPIC
`define PERF
`define DEBUG
// `define LFSR
// `define SOC //no verilog macro define here, define it in Makefile

`define RAMDOM_WIDTH 8

`define SEED1 8'd0
`define SEED2 8'd0
`define SEED3 8'd0
`define SEED4 8'd0

//------------------------------------------------------------------------
// CLOCK
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// CONSTANT DEFINITIONS
//------------------------------------------------------------------------
`define True 1'b1
`define False 1'b0
`define Enable 1'b1
`define Disable 1'b0

//------------------------------------------------------------------------
// INSTRUCTION FIELD DEFINITIONS (BIT RANGE)
//------------------------------------------------------------------------
`define RV32_OP  6:0    // Opcode field (7 bits)
`define RV32_RD  10:7   // Destination register field (4 bits)
`define RV32_F3  14:12  // Function 3 field (3 bits)
`define RV32_RS1 18:15  // Source register 1 field (4 bits)
`define RV32_RS2 23:20  // Source register 2 field (4 bits)
`define RV32_F7  31:25  // Function 7 field (7 bits)

//------------------------------------------------------------------------
// FIELD WIDTH DEFINITIONS
//------------------------------------------------------------------------
`define RV32_OP_WIDTH   7   // Opcode field width
`define RV32_RD_WIDTH   4   // Destination register field width
`define RV32_RS1_WIDTH  4   // Source register 1 field width
`define RV32_RS2_WIDTH  4   // Source register 2 field width
`define RV32_F3_WIDTH   3   // funct3 field width
`define RV32_F7_WIDTH   7   // funct7 field width

//------------------------------------------------------------------------
// rv32i load type inst
//------------------------------------------------------------------------
`define RV32I_OP_TYPE_IL 7'b0000011
`define RV32I_F3_LB      3'b000
`define RV32I_F3_LH      3'b001
`define RV32I_F3_LW      3'b010
`define RV32I_F3_LBU     3'b100
`define RV32I_F3_LHU     3'b101

//------------------------------------------------------------------------
// rv32i I type inst
//------------------------------------------------------------------------
`define RV32I_OP_TYPE_I 7'b0010011
`define RV32I_F3_ADDI   3'b000
`define RV32I_F3_SLLI   3'b001
`define RV32I_F3_SLTI   3'b010
`define RV32I_F3_SLTIU  3'b011
`define RV32I_F3_XORI   3'b100
`define RV32I_F3_SRI    3'b101
`define RV32I_F3_ORI    3'b110
`define RV32I_F3_ANDI   3'b111

//------------------------------------------------------------------------
// rv32i U type inst
//------------------------------------------------------------------------
`define RV32I_OP_AUIPC  7'b0010111
`define RV32I_OP_LUI    7'b0110111

//------------------------------------------------------------------------
// rv32i S type inst
//------------------------------------------------------------------------
`define RV32I_OP_TYPE_S 7'b0100011
`define RV32I_F3_SB     3'b000
`define RV32I_F3_SH     3'b001
`define RV32I_F3_SW     3'b010

// rv32i/rv32m R/M type inst
`define RV32IM_OP_TYPE_R 7'b0110011

`define RV32I_F3_ADD_SUB 3'b000
`define RV32I_F3_SLL    3'b001
`define RV32I_F3_SLT    3'b010
`define RV32I_F3_SLTU   3'b011
`define RV32I_F3_XOR    3'b100
`define RV32I_F3_SR     3'b101
`define RV32I_F3_OR     3'b110
`define RV32I_F3_AND    3'b111

`define RV32I_F7_R1    7'b0000000
`define RV32I_F7_R2    7'b0100000

//------------------------------------------------------------------------
// rv32i B type inst
//------------------------------------------------------------------------
`define RV32I_OP_TYPE_B 7'b1100011
`define RV32I_F3_BEQ    3'b000
`define RV32I_F3_BNE    3'b001
`define RV32I_F3_BLT    3'b100
`define RV32I_F3_BGE    3'b101
`define RV32I_F3_BLTU   3'b110
`define RV32I_F3_BGEU   3'b111

//------------------------------------------------------------------------
// rv32i J type inst
//------------------------------------------------------------------------
`define RV32I_OP_JALR   7'b1100111
`define RV32I_OP_JAL    7'b1101111

//------------------------------------------------------------------------
// rv32 Debug type inst
//------------------------------------------------------------------------
`define RV_MRET       32'h30200073
`define RV_ECALL      32'h00000073
`define RV_EBREAK     32'h00100073

`define RV_FENCE_I    32'h0000100F

//------------------------------------------------------------------------
// rv32zicsr CSR type inst
//------------------------------------------------------------------------
`define RV_OP_CSR    7'b1110011
`define RV_F3_CSRRW  3'b001
`define RV_F3_CSRRS  3'b010
`define RV_F3_CSRRC  3'b011
`define RV_F3_CSRRWI 3'b101
`define RV_F3_CSRRSI 3'b110
`define RV_F3_CSRRCI 3'b111

//------------------------------------------------------------------------
// GENERAL PURPOSE REGISTER DEFINITIONS
//------------------------------------------------------------------------
`define RegNum 16        // reg num
`define RegDataWidth 32
`define RegAddrWidth $clog2(`RegNum)
`define RegAddrBus `RegAddrWidth-1:0
`define RegDataBus `RegDataWidth-1:0

`define DoubleRegDataBus `RegDataWidth*2-1:0
`define HRegDataBus `RegDataWidth*2-1:`RegDataWidth
`define LRegDataBus `RegDataWidth-1:0

//------------------------------------------------------------------------
// CSR REGISTER DEFINITIONS
//------------------------------------------------------------------------
`define CSRAddrWidth 12
`define CSRDataWidth 32
`define DoubleCSRDataWidth 64
`define CSRAddrBus `CSRAddrWidth-1:0
`define CSRDataBus `CSRDataWidth-1:0
`define DoubleCSRDataBus `DoubleCSRDataWidth-1:0
`define CSRNum 1024

`define CSR_Addr_FFLAGS     12'h001     // Floating-Point Accrued Exceptions
`define CSR_Addr_FRM        12'h002     // Floating-Point Dynamic Rounding Mode
`define CSR_Addr_FCSR       12'h003     // Floating-Point Control and Status Register
`define CSR_Addr_MSTATUS    12'h300     // Machine Status Register
`define CSR_Addr_MIE        12'h304     // Machine Interrupt Enable Registers
`define CSR_Addr_MTVEC      12'h305     // Machine Trap-Vector Base-Address Register
`define CSR_Addr_MSCRATCH   12'h340     // Machine Scratch Register
`define CSR_Addr_MEPC       12'h341     // Machine Exception Program Counter
`define CSR_Addr_MCAUSE     12'h342     // Machine Cause Register
`define CSR_Addr_CYCLE      12'hc00     // Lower 32 bits of Cycle counter
`define CSR_Addr_CYCLEH     12'hc80     // Upper 32 bits of Cycle counter
`define CSR_Addr_MVENDORID  12'hf11     // Vendor ID
`define CSR_Addr_MARCHID    12'hf12     // Architecture ID

//------------------------------------------------------------------------
// ALU CONTROL DEFINITIONS
//------------------------------------------------------------------------
`define ALUCTL_WIDTH    4
`define ALUCTL_ADD      4'b0001       // Add (signed)
`define ALUCTL_SUB      4'b0010       // Subtract (signed)
`define ALUCTL_SLL      4'b0011       // Shift Left Logical
`define ALUCTL_SLT      4'b0100       // Set on Less Than
`define ALUCTL_SLTU     4'b0101       // Set on Less Than (unsigned)
`define ALUCTL_XOR      4'b0110       // XOR
`define ALUCTL_SRL      4'b0111       // Shift Right Logical
`define ALUCTL_SRA      4'b1000       // Shift Right Arithmetic
`define ALUCTL_OR       4'b1001       // OR
`define ALUCTL_AND      4'b1010       // AND

//------------------------------------------------------------------------
// BRANCH AND JUMP CONTROL DEFINITIONS
//------------------------------------------------------------------------
`define BRUCTL_WIDTH    3
`define BRUCTL_JAL      3'b001
`define BRUCTL_BEQ      3'b010
`define BRUCTL_BNE      3'b011
`define BRUCTL_BLT      3'b100
`define BRUCTL_BGE      3'b101
`define BRUCTL_BLTU     3'b110
`define BRUCTL_BGEU     3'b111

//------------------------------------------------------------------------
// CSR CONTROL DEFINITIONS
//------------------------------------------------------------------------
`define CSRCTL_WIDTH    2
`define CSRCTL_WRI      2'b01
`define CSRCTL_SET      2'b10
`define CSRCTL_CLR      2'b11

//------------------------------------------------------------------------
// ALU SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define ALUSrcA_sel_width   2
`define ALUSrcA_rs1     2'b01
`define ALUSrcA_pc      2'b10
`define ALUSrcA_0       2'b11

//------------------------------------------------------------------------
// ALU SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define ALUSrcB_sel_width   2
`define ALUSrcB_rs2     2'b01
`define ALUSrcB_imm     2'b10
`define ALUSrcB_4       2'b11

//------------------------------------------------------------------------
// AGU SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define AGUSrc_sel_width    2
`define AGUSrc_rs1      2'b01
`define AGUSrc_pc       2'b10
`define AGUSrc_0        2'b11

//------------------------------------------------------------------------
// CSR SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define CSRSrc_sel_width    2
`define CSRSrc_rs1      2'b01
`define CSRSrc_imm      2'b10

//------------------------------------------------------------------------
// FWD SOURCE SELECTION DEFINITIONS
//------------------------------------------------------------------------
`define FWDSrc_sel_width    2
`define FWDSrc_nfw      2'b01
`define FWDSrc_ls       2'b10
`define FWDSrc_wb       2'b11

//------------------------------------------------------------------------
// STORE/LOAD TYPE DEFINITIONS
//------------------------------------------------------------------------
`define ls_diff_width   4
`define ls_diff_bus     `ls_diff_width-1:0
`define ls_lb           4'b0001
`define ls_lh           4'b0011
`define ls_lw           4'b0010
`define ls_lbu          4'b0110
`define ls_lhu          4'b0111
`define ls_sb           4'b1000
`define ls_sh           4'b1001
`define ls_sw           4'b1011

//------------------------------------------------------------------------
// EXCEPTION TYPE DEFINITIONS
//------------------------------------------------------------------------
`define ExceptWidth                 4
`define ExceptBus                   `ExceptWidth-1:0

`define EXCPT_ECALL                 0
`define EXCPT_EBREAK                1
`define EXCPT_MRET                  2
`define EXCPT_FENCE_I               3

//------------------------------------------------------------------------
// MEMORY DEFINITIONS
//------------------------------------------------------------------------
`define MemAddrWidth 32
`define MemDataWidth 32
`define MemDataBus `MemDataWidth-1:0
`define MemAddrBus `MemAddrWidth-1:0

`define InstWidth 32
`define InstAddrWidth 32
`define InstBus `InstWidth-1:0
`define InstAddrBus `InstAddrWidth-1:0

`define DBUS_MASK 4

`define CLINT_BASE    32'h0200_0000
`define CLINT_SIZE    32'h0001_0000
`define SERIAL_BASE   32'h1000_0000
`define SERIAL_SIZE   32'h0000_1000
`define SPI_BASE      32'h1000_1000
`define SPI_SIZE      32'h0000_1000
`define GPIO_BASE     32'h1000_2000
`define GPIO_SIZE     32'h0000_0010
`define PS2_BASE      32'h1001_1000
`define PS2_SIZE      32'h0000_0008
`define VGA_BASE      32'h2100_0000
`define VGA_SIZE      32'h0020_0000
`define CHIPL_BASE    32'hc000_0000
`define CHIPL_SIZE    32'h4000_0000

`define MromAddrBase  32'h2000_0000
`define MromSize      32'h0001_0000
`define SramAddrBase  32'h0f00_0000
`define SramSize      32'h0100_0000
`define FlashAddrBase 32'h3000_0000
`define FlashSize     32'h1000_0000
`define PsramAddrBase 32'h8000_0000
`define PsramSize     32'h2000_0000
`define SdramAddrBase 32'ha000_0000
`define SdramSize     32'h2000_0000

`ifdef SOC
    `define RESET_VECTOR  `FlashAddrBase
`else
    `define RESET_VECTOR  `SdramAddrBase
`endif