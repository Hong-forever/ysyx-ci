`include "defines.v"

//------------------------------------------------------------------------
// 通用寄存器
//------------------------------------------------------------------------

module regfile
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,               //指令内容
    input   wire    [`InstAddrBus   ]   I_inst_addr,

    input   wire    [`RegAddrBus    ]   I_rs1_raddr,      //读寄存器1地址
    input   wire    [`RegAddrBus    ]   I_rs2_raddr,      //读寄存器2地址

    output  wire    [`RegDataBus    ]   O_rs1_rdata,     //输出寄存器1数据
    output  wire    [`RegDataBus    ]   O_rs2_rdata,     //输出寄存器2数据

    input   wire                        I_rd_we,         //写寄存器标志
    input   wire    [`RegAddrBus    ]   I_rd_waddr,      //写寄存器地址
    input   wire    [`RegDataBus    ]   I_rd_wdata,      //写寄存器数据

    output  wire    [`RegDataBus    ]   O_gpr0,           // for dpi
    output  wire    [`RegDataBus    ]   O_gpr1,
    output  wire    [`RegDataBus    ]   O_gpr2,
    output  wire    [`RegDataBus    ]   O_gpr3,
    output  wire    [`RegDataBus    ]   O_gpr4,
    output  wire    [`RegDataBus    ]   O_gpr5,
    output  wire    [`RegDataBus    ]   O_gpr6,
    output  wire    [`RegDataBus    ]   O_gpr7,
    output  wire    [`RegDataBus    ]   O_gpr8,
    output  wire    [`RegDataBus    ]   O_gpr9,
    output  wire    [`RegDataBus    ]   O_gpr10,
    output  wire    [`RegDataBus    ]   O_gpr11,
    output  wire    [`RegDataBus    ]   O_gpr12,
    output  wire    [`RegDataBus    ]   O_gpr13,
    output  wire    [`RegDataBus    ]   O_gpr14,
    output  wire    [`RegDataBus    ]   O_gpr15,
    output  wire    [`RegDataBus    ]   O_gpr16,
    output  wire    [`RegDataBus    ]   O_gpr17,
    output  wire    [`RegDataBus    ]   O_gpr18,
    output  wire    [`RegDataBus    ]   O_gpr19,
    output  wire    [`RegDataBus    ]   O_gpr20,
    output  wire    [`RegDataBus    ]   O_gpr21,
    output  wire    [`RegDataBus    ]   O_gpr22,
    output  wire    [`RegDataBus    ]   O_gpr23,
    output  wire    [`RegDataBus    ]   O_gpr24,
    output  wire    [`RegDataBus    ]   O_gpr25,
    output  wire    [`RegDataBus    ]   O_gpr26,
    output  wire    [`RegDataBus    ]   O_gpr27,
    output  wire    [`RegDataBus    ]   O_gpr28,
    output  wire    [`RegDataBus    ]   O_gpr29,
    output  wire    [`RegDataBus    ]   O_gpr30,
    output  wire    [`RegDataBus    ]   O_gpr31
);

    reg [`RegDataBus] regs[1:`RegNum-1];   //寄存器组

    integer i;
    //写寄存器
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 1; i < `RegNum; i = i + 1) begin
                regs[i] <= `Zero;
            end
        end else begin
            if((I_rd_we == `Enable) && (I_rd_waddr != `Zero)) begin
                regs[I_rd_waddr] <= I_rd_wdata;
            end
        end
    end

    //读寄存器
    assign O_rs1_rdata = 
                I_rs1_raddr == `Zero ? `Zero :
                (I_rd_we && I_rd_waddr == I_rs1_raddr) ? I_rd_wdata : regs[I_rs1_raddr];

    assign O_rs2_rdata = 
                I_rs2_raddr == `Zero ? `Zero :
                (I_rd_we && I_rd_waddr == I_rs2_raddr) ? I_rd_wdata : regs[I_rs2_raddr];

    //for debug
    wire [`RegDataBus] ra_x1   = regs[1];
    wire [`RegDataBus] sp_x2   = regs[2];
    wire [`RegDataBus] gp_x3   = regs[3];
    wire [`RegDataBus] tp_x4   = regs[4];
    wire [`RegDataBus] t0_x5   = regs[5];
    wire [`RegDataBus] t1_x6   = regs[6];
    wire [`RegDataBus] t2_x7   = regs[7];
    wire [`RegDataBus] s0_x8   = regs[8];
    wire [`RegDataBus] fp_x8   = regs[8];
    wire [`RegDataBus] s1_x9   = regs[9];
    wire [`RegDataBus] a0_x10  = regs[10];
    wire [`RegDataBus] a1_x11  = regs[11];
    wire [`RegDataBus] a2_x12  = regs[12];
    wire [`RegDataBus] a3_x13  = regs[13];
    wire [`RegDataBus] a4_x14  = regs[14];
    wire [`RegDataBus] a5_x15  = regs[15];
    wire [`RegDataBus] a6_x16  = regs[16];
    wire [`RegDataBus] a7_x17  = regs[17];
    wire [`RegDataBus] s2_x18  = regs[18];
    wire [`RegDataBus] s3_x19  = regs[19];
    wire [`RegDataBus] s4_x20  = regs[20];
    wire [`RegDataBus] s5_x21  = regs[21];
    wire [`RegDataBus] s6_x22  = regs[22];
    wire [`RegDataBus] s7_x23  = regs[23];
    wire [`RegDataBus] s8_x24  = regs[24];
    wire [`RegDataBus] s9_x25  = regs[25];
    wire [`RegDataBus] s10_x26 = regs[26];
    wire [`RegDataBus] s11_x27 = regs[27];
    wire [`RegDataBus] t3_x28  = regs[28];
    wire [`RegDataBus] t4_x29  = regs[29];
    wire [`RegDataBus] t5_x30  = regs[30];
    wire [`RegDataBus] t6_x31  = regs[31];

    assign O_gpr0  = `Zero;
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

endmodule //regfile
