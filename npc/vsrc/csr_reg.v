`include "defines.v"

//------------------------------------------------------------------------
// CSR寄存器
//------------------------------------------------------------------------

module csr_reg
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`CSRAddrBus    ]   I_raddr,
    output  wire    [`CSRDataBus    ]   O_rdata,

    input   wire                        I_we,
    input   wire    [`CSRAddrBus    ]   I_waddr,
    input   wire    [`CSRDataBus    ]   I_wdata,

    input   wire    [`Except_Bus    ]   I_except,
    input   wire    [`InstAddrBus   ]   I_except_addr,

    input   wire    [`InstAddrBus   ]   I_next_inst_addr,

    output  wire                        O_flush,
    output  wire    [`InstAddrBus   ]   O_flush_addr,

    output  wire    [`CSRDataBus    ]   O_csr_mtvec,        //mtvec寄存器
    output  wire    [`CSRDataBus    ]   O_csr_mepc,         //mepc寄存器
    output  wire    [`CSRDataBus    ]   O_csr_mstatus,      //mstatus寄存器
    output  wire    [`CSRDataBus    ]   O_csr_mcause,       //mcause寄存器
    output  wire    [`CSRDataBus]       O_csr_mcyclel,       //mcycle寄存器
    output  wire    [`CSRDataBus]       O_csr_mcycleh,       //mcycle寄存器
    output  wire    [`CSRDataBus    ]   O_csr_mvendorid,      //mvendorid寄存器
    output  wire    [`CSRDataBus    ]   O_csr_marchid         //marchid寄存器
);

    reg [`CSRDataBus] mstatus;
    reg [`CSRDataBus] mie;
    reg [`CSRDataBus] mtvec;
    reg [`CSRDataBus] mscratch;
    reg [`CSRDataBus] mepc;
    reg [`CSRDataBus] mcause;
    // reg [`DoubleCSRDataBus] mtimecmp;   //未定义地址，未实现
    reg [`DoubleCSRDataBus] cycle;

    reg [`CSRDataBus] mvendorid;
    reg [`CSRDataBus] marchid;

    wire is_ecall = I_except[`EXCPT_ECALL];
    wire is_ebreak = I_except[`EXCPT_EBREAK];
    wire is_mret  = I_except[`EXCPT_MRET];

    // wire except_sync = is_ecall | is_ebreak;
    wire except_sync = is_ecall; // for ysyx
    wire except_call = except_sync;
    wire except_mret = is_mret;

    reg e_sync_r, e_mret_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            e_sync_r <= 1'b0;
            e_mret_r <= 1'b0;
        end else begin
            e_sync_r <= except_sync;
            e_mret_r <= except_mret;
        end
    end
    

    `define YSYX_LOGO      32'h79737978 //ysyx的logo
    `define YSYX_STU_NUM   32'h25110270 //我的学号-25110270


    //cycle counter
    //复位撤销后就一直计数
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cycle <= `Zero;
        end else begin
            cycle <= cycle + 1'b1;
        end
    end

    //write reg
    //写寄存器操作
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mtvec <= `Zero;
            mcause <= `Zero;
            mepc <= `Zero;
            mie <= `Zero;
            mstatus <= `Zero;
            mscratch <= `Zero;
            mvendorid <= `YSYX_LOGO;
            marchid <= `YSYX_STU_NUM;
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
                        `CSR_Addr_MSTATUS:  mstatus     <= I_wdata;
                        `CSR_Addr_MIE:      mie         <= I_wdata;
                        `CSR_Addr_MTVEC:    mtvec       <= I_wdata;
                        `CSR_Addr_MSCRATCH: mscratch    <= I_wdata;
                        `CSR_Addr_MEPC:     mepc        <= I_wdata;
                        `CSR_Addr_MCAUSE:   mcause      <= I_wdata;
                        default: begin end
                    endcase
                end
            end
        end
    end


    //read reg
    //idu模块读CSR寄存器
    reg [`CSRDataBus]   rdata1;
    always @(*) begin
        if(I_we && I_raddr == I_waddr) begin
            rdata1 = I_wdata;
        end else begin
            case(I_raddr)
                `CSR_Addr_MSTATUS:  rdata1 = mstatus;
                `CSR_Addr_MIE:      rdata1 = mie;
                `CSR_Addr_MTVEC:    rdata1 = mtvec;
                `CSR_Addr_MSCRATCH: rdata1 = mscratch;
                `CSR_Addr_MEPC:     rdata1 = mepc;
                `CSR_Addr_MCAUSE:   rdata1 = mcause;
                `CSR_Addr_CYCLE:    rdata1 = cycle[31:0];
                `CSR_Addr_CYCLEH:   rdata1 = cycle[63:32];
                `CSR_Addr_MVENDORID:rdata1 = mvendorid;
                `CSR_Addr_MARCHID:  rdata1 = marchid;
                default:            rdata1 = `Zero;
            endcase
        end
    end


    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_rdata = rdata1;

    assign O_flush = except_call | except_mret;
    assign O_flush_addr =   except_call ? mtvec :
                            except_mret ? mepc  : `Zero;

    assign O_csr_mtvec = mtvec;
    assign O_csr_mepc = mepc;
    assign O_csr_mstatus = mstatus;
    assign O_csr_mcause = mcause;
    assign O_csr_mcyclel = cycle[31:0];
    assign O_csr_mcycleh = cycle[63:32];
    assign O_csr_mvendorid = mvendorid;
    assign O_csr_marchid = marchid;


endmodule
