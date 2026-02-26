`include "defines.v"

//------------------------------------------------------------------------
// CSR寄存器
//------------------------------------------------------------------------

module ysyx_25110270_csr_reg
(
    input   wire                                    clk,
    input   wire                                    rst,

    input   wire    [11:0                       ]   I_raddr,
    output  wire    [31:0                       ]   O_rdata,

    input   wire                                    I_we,
    input   wire    [11:0                       ]   I_waddr,
    input   wire    [31:0                       ]   I_wdata,

    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,
    input   wire    [31:0                       ]   I_except_addr,

    input   wire    [31:0                       ]   I_next_inst_addr,

    output  wire                                    O_flush,
    output  wire    [31:0                       ]   O_flush_addr,

    output  wire    [31:0                       ]   O_csr_mtvec,        //mtvec寄存器
    output  wire    [31:0                       ]   O_csr_mepc,         //mepc寄存器
    output  wire    [31:0                       ]   O_csr_mstatus,      //mstatus寄存器
    output  wire    [31:0                       ]   O_csr_mcause,       //mcause寄存器
    output  wire    [31:0                       ]   O_csr_mcyclel,       //mcycle寄存器
    output  wire    [31:0                       ]   O_csr_mcycleh,       //mcycle寄存器
    output  wire    [31:0                       ]   O_csr_mvendorid,      //mvendorid寄存器
    output  wire    [31:0                       ]   O_csr_marchid         //marchid寄存器
);

    reg [31:0] mstatus;
    reg [31:0] mie;
    reg [31:0] mtvec;
    reg [31:0] mepc;
    reg [31:0] mcause;
    reg [63:0] cycle;

    wire is_ecall  = I_except[`ysyx_25110270_EXCPT_ECALL];
    wire is_ebreak = I_except[`ysyx_25110270_EXCPT_EBREAK];
    wire is_mret   = I_except[`ysyx_25110270_EXCPT_MRET];
    wire is_fence_i = I_except[`ysyx_25110270_EXCPT_FENCE_I];

    // wire except_sync = is_ecall | is_ebreak;
    wire except_sync = is_ecall; // for ysyx
    wire except_call = except_sync;
    wire except_mret = is_mret;
    wire except_fence_i = is_fence_i;

    wire [31:0] fence_next_inst_addr = I_next_inst_addr; // for ysyx, fence_i指令执行完后下一条指令的地址

    reg e_sync_r, e_mret_r;
    always @(posedge clk) begin
        if(rst) begin
            e_sync_r <= 1'b0;
            e_mret_r <= 1'b0;
        end else begin
            e_sync_r <= except_sync;
            e_mret_r <= except_mret;
        end
    end
    
    wire [31:0] mvendorid;
    wire [31:0] marchid;

    parameter YSYX_LOGO      = 32'h79737978; //ysyx的logo
    parameter YSYX_STU_NUM   = 32'h25110270; //我的学号-25110270

    assign mvendorid = YSYX_LOGO;
    assign marchid = YSYX_STU_NUM;

    //cycle counter
    //复位撤销后就一直计数
    always @(posedge clk) begin
        if(rst) begin
            cycle <= 0;
        end else begin
            cycle <= cycle + 1'b1;
        end
    end

    //write reg
    //写寄存器操作
    always @(posedge clk) begin
        if(rst) begin
            mtvec <= 0;
            mcause <= 0;
            mepc <= 0;
            mie <= 0;
            mstatus <= 0;
        end else begin
            if(except_sync & ~e_sync_r) begin
                mepc <= I_except_addr;
                mcause <= is_ecall ? 32'd11 : 32'd3; //ecall=11, ebreak=3
                mstatus <= {mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]} | 32'h1800; //MPIE->MIE, MIE清0
            end else if(except_mret & ~e_mret_r) begin
                mstatus <= {mstatus[31:8], 1'b1, mstatus[6:4], mstatus[7], mstatus[2:0]} & ~32'h1800; //MIE<-MPIE
            end else begin    
                if(I_we) begin
                    case(I_waddr)
                        `ysyx_25110270_CSR_MSTATUS:  mstatus     <= I_wdata;
                        `ysyx_25110270_CSR_MIE:      mie         <= I_wdata;
                        `ysyx_25110270_CSR_MTVEC:    mtvec       <= I_wdata;
                        `ysyx_25110270_CSR_MEPC:     mepc        <= I_wdata;
                        `ysyx_25110270_CSR_MCAUSE:   mcause      <= I_wdata;
                        default: begin end
                    endcase
                end
            end
        end
    end


    //read reg
    //idu模块读CSR寄存器
    reg [31:0] rdata;
    always @(*) begin
        if(I_we && I_raddr == I_waddr) begin
            rdata = I_wdata;
        end else begin
            case(I_raddr)
                `ysyx_25110270_CSR_MSTATUS:   rdata = mstatus;
                `ysyx_25110270_CSR_MIE:       rdata = mie;
                `ysyx_25110270_CSR_MTVEC:     rdata = mtvec;
                `ysyx_25110270_CSR_MEPC:      rdata = mepc;
                `ysyx_25110270_CSR_MCAUSE:    rdata = mcause;
                `ysyx_25110270_CSR_CYCLE:     rdata = cycle[31:0];
                `ysyx_25110270_CSR_CYCLEH:    rdata = cycle[63:32];
                `ysyx_25110270_CSR_MVENDORID: rdata = mvendorid;
                `ysyx_25110270_CSR_MARCHID:   rdata = marchid;
                default:                      rdata = 0;
            endcase
        end
    end


    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_rdata = rdata;

    assign O_flush = except_call | except_mret | except_fence_i;
    assign O_flush_addr =   except_call ? mtvec :
                            except_mret ? mepc  :
                            fence_next_inst_addr;


    assign O_csr_mtvec = mtvec;
    assign O_csr_mepc = mepc;
    assign O_csr_mstatus = mstatus;
    assign O_csr_mcause = mcause;
    assign O_csr_mcyclel = cycle[31:0];
    assign O_csr_mcycleh = cycle[63:32];
    assign O_csr_mvendorid = mvendorid;
    assign O_csr_marchid = marchid;


endmodule
