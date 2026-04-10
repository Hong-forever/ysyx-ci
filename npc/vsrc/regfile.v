`include "defines.v"

//------------------------------------------------------------------------
// 通用寄存器
//------------------------------------------------------------------------

module ysyx_25110270_regfile
(
    input   wire                                    clk,
    input   wire                                    rst,

    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs1_raddr,      //读寄存器1地址
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs2_raddr,      //读寄存器2地址

    output  wire    [31:0                       ]   O_rs1_rdata,     //输出寄存器1数据
    output  wire    [31:0                       ]   O_rs2_rdata,     //输出寄存器2数据

`ifdef ysyx_25110270_DPIC
    output  wire    [31:0                       ]   O_gpr0,           // for dpi
    output  wire    [31:0                       ]   O_gpr1,
    output  wire    [31:0                       ]   O_gpr2,
    output  wire    [31:0                       ]   O_gpr3,
    output  wire    [31:0                       ]   O_gpr4,
    output  wire    [31:0                       ]   O_gpr5,
    output  wire    [31:0                       ]   O_gpr6,
    output  wire    [31:0                       ]   O_gpr7,
    output  wire    [31:0                       ]   O_gpr8,
    output  wire    [31:0                       ]   O_gpr9,
    output  wire    [31:0                       ]   O_gpr10,
    output  wire    [31:0                       ]   O_gpr11,
    output  wire    [31:0                       ]   O_gpr12,
    output  wire    [31:0                       ]   O_gpr13,
    output  wire    [31:0                       ]   O_gpr14,
    output  wire    [31:0                       ]   O_gpr15,
    output  wire    [31:0                       ]   O_gpr16,
    output  wire    [31:0                       ]   O_gpr17,
    output  wire    [31:0                       ]   O_gpr18,
    output  wire    [31:0                       ]   O_gpr19,
    output  wire    [31:0                       ]   O_gpr20,
    output  wire    [31:0                       ]   O_gpr21,
    output  wire    [31:0                       ]   O_gpr22,
    output  wire    [31:0                       ]   O_gpr23,
    output  wire    [31:0                       ]   O_gpr24,
    output  wire    [31:0                       ]   O_gpr25,
    output  wire    [31:0                       ]   O_gpr26,
    output  wire    [31:0                       ]   O_gpr27,
    output  wire    [31:0                       ]   O_gpr28,
    output  wire    [31:0                       ]   O_gpr29,
    output  wire    [31:0                       ]   O_gpr30,
    output  wire    [31:0                       ]   O_gpr31,

`endif

`ifdef __ICARUS__
    output  wire    [31:0                       ]   gpr10,            // for
`endif

    input   wire                                    I_rd_we,         //写寄存器标志
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,      //写寄存器地址
    input   wire    [31:0                       ]   I_rd_wdata      //写寄存器数据
);


    reg [31:0] regs[1:`ysyx_25110270_RegNum-1];   //寄存器组

    // integer i;
    //写寄存器
    always @(posedge clk) begin
        // if(rst) begin
        //     for(i = 1; i < `ysyx_25110270_RegNum; i = i + 1) begin
        //         regs[i] <= 0;
        //     end
        // end else begin
        if(I_rd_we && (I_rd_waddr != 0)) begin
            regs[I_rd_waddr] <= I_rd_wdata;
        end
        // end
    end

    reg [31:0] rs1_rdata, rs2_rdata;
    always @(*) begin
        if(I_rs1_raddr == 0) begin
            rs1_rdata = 0;
        end else if(I_rd_we && I_rd_waddr == I_rs1_raddr) begin
            rs1_rdata = I_rd_wdata;
        end else begin
            rs1_rdata = regs[I_rs1_raddr];
        end
    end

    always @(*) begin
        if(I_rs2_raddr == 0) begin
            rs2_rdata = 0;
        end else if(I_rd_we && I_rd_waddr == I_rs2_raddr) begin
            rs2_rdata = I_rd_wdata;
        end else begin
            rs2_rdata = regs[I_rs2_raddr];
        end
    end

    //读寄存器
    assign O_rs1_rdata = rs1_rdata;
    assign O_rs2_rdata = rs2_rdata;

`ifdef ysyx_25110270_DPIC
    assign O_gpr0  = 0;
    assign O_gpr1  = regs[1];
    assign O_gpr2  = regs[2];
    assign O_gpr3  = regs[3];
    assign O_gpr4  = regs[4];
    assign O_gpr5  = regs[5];
    assign O_gpr6  = regs[6];
    assign O_gpr7  = regs[7];
    assign O_gpr8  = regs[8];
    assign O_gpr9  = regs[9];
    assign O_gpr10 = regs[10];
    assign O_gpr11 = regs[11];
    assign O_gpr12 = regs[12];
    assign O_gpr13 = regs[13];
    assign O_gpr14 = regs[14];
    assign O_gpr15 = regs[15];
    assign O_gpr16 = regs[16];
    assign O_gpr17 = regs[17];
    assign O_gpr18 = regs[18];
    assign O_gpr19 = regs[19];
    assign O_gpr20 = regs[20];
    assign O_gpr21 = regs[21];
    assign O_gpr22 = regs[22];
    assign O_gpr23 = regs[23];
    assign O_gpr24 = regs[24];
    assign O_gpr25 = regs[25];
    assign O_gpr26 = regs[26];
    assign O_gpr27 = regs[27];
    assign O_gpr28 = regs[28];
    assign O_gpr29 = regs[29];
    assign O_gpr30 = regs[30];
    assign O_gpr31 = regs[31];


    wire [31:0] gpr_x1_ra   = regs[1];
    wire [31:0] gpr_x2_sp   = regs[2];
    wire [31:0] gpr_x3_gp   = regs[3];
    wire [31:0] gpr_x4_tp   = regs[4];
    wire [31:0] gpr_x5_t0   = regs[5];
    wire [31:0] gpr_x6_t1   = regs[6];
    wire [31:0] gpr_x7_t2   = regs[7];
    wire [31:0] gpr_x8_s0   = regs[8];
    wire [31:0] gpr_x9_s1   = regs[9];
    wire [31:0] gpr_x10_a0  = regs[10];
    wire [31:0] gpr_x11_a1  = regs[11];
    wire [31:0] gpr_x12_a2  = regs[12];
    wire [31:0] gpr_x13_a3  = regs[13];
    wire [31:0] gpr_x14_a4  = regs[14];
    wire [31:0] gpr_x15_a5  = regs[15];
    wire [31:0] gpr_x16_a6  = regs[16];
    wire [31:0] gpr_x17_a7  = regs[17];
    wire [31:0] gpr_x18_s2  = regs[18];
    wire [31:0] gpr_x19_s3  = regs[19];
    wire [31:0] gpr_x20_s4  = regs[20];
    wire [31:0] gpr_x21_s5  = regs[21];
    wire [31:0] gpr_x22_s6  = regs[22];
    wire [31:0] gpr_x23_s7  = regs[23];
    wire [31:0] gpr_x24_s8  = regs[24];
    wire [31:0] gpr_x25_s9  = regs[25];
    wire [31:0] gpr_x26_s10 = regs[26];
    wire [31:0] gpr_x27_s11 = regs[27];
    wire [31:0] gpr_x28_t3  = regs[28];
    wire [31:0] gpr_x29_t4  = regs[29];
    wire [31:0] gpr_x30_t5  = regs[30];
    wire [31:0] gpr_x31_t6  = regs[31];


`endif

`ifdef __ICARUS__

    wire [31:0] gpr_x1_ra   = regs[1];
    wire [31:0] gpr_x2_sp   = regs[2];
    wire [31:0] gpr_x3_gp   = regs[3];
    wire [31:0] gpr_x4_tp   = regs[4];
    wire [31:0] gpr_x5_t0   = regs[5];
    wire [31:0] gpr_x6_t1   = regs[6];
    wire [31:0] gpr_x7_t2   = regs[7];
    wire [31:0] gpr_x8_s0   = regs[8];
    wire [31:0] gpr_x9_s1   = regs[9];
    wire [31:0] gpr_x10_a0  = regs[10];
    wire [31:0] gpr_x11_a1  = regs[11];
    wire [31:0] gpr_x12_a2  = regs[12];
    wire [31:0] gpr_x13_a3  = regs[13];
    wire [31:0] gpr_x14_a4  = regs[14];
    wire [31:0] gpr_x15_a5  = regs[15];
    wire [31:0] gpr_x16_a6  = regs[16];
    wire [31:0] gpr_x17_a7  = regs[17];
    wire [31:0] gpr_x18_s2  = regs[18];
    wire [31:0] gpr_x19_s3  = regs[19];
    wire [31:0] gpr_x20_s4  = regs[20];
    wire [31:0] gpr_x21_s5  = regs[21];
    wire [31:0] gpr_x22_s6  = regs[22];
    wire [31:0] gpr_x23_s7  = regs[23];
    wire [31:0] gpr_x24_s8  = regs[24];
    wire [31:0] gpr_x25_s9  = regs[25];
    wire [31:0] gpr_x26_s10 = regs[26];
    wire [31:0] gpr_x27_s11 = regs[27];
    wire [31:0] gpr_x28_t3  = regs[28];
    wire [31:0] gpr_x29_t4  = regs[29];
    wire [31:0] gpr_x30_t5  = regs[30];
    wire [31:0] gpr_x31_t6  = regs[31];

    assign gpr10 = regs[10];
`endif

endmodule //regfile