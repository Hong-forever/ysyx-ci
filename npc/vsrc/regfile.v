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

    input   wire                                    I_rd_we,         //写寄存器标志
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,      //写寄存器地址
    input   wire    [31:0                       ]   I_rd_wdata,      //写寄存器数据

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
    output  wire    [31:0                       ]   O_gpr15
);


    reg [31:0] regs[1:`ysyx_25110270_RegNum-1];   //寄存器组

    integer i;
    //写寄存器
    always @(posedge clk) begin
        if(rst) begin
            for(i = 1; i < `ysyx_25110270_RegNum; i = i + 1) begin
                regs[i] <= 0;
            end
        end else begin
            if(I_rd_we && (I_rd_waddr != 0)) begin
                regs[I_rd_waddr] <= I_rd_wdata;
            end
        end
    end

    //读寄存器
    assign O_rs1_rdata = 
                I_rs1_raddr == 0 ? 0 :
                // (I_rd_we && I_rd_waddr == I_rs1_raddr) ? I_rd_wdata : regs[I_rs1_raddr];
                regs[I_rs1_raddr];

    assign O_rs2_rdata = 
                I_rs2_raddr == 0 ? 0 :
                // (I_rd_we && I_rd_waddr == I_rs2_raddr) ? I_rd_wdata : regs[I_rs2_raddr];
                regs[I_rs2_raddr];

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

endmodule //regfile
