`include "defines.v"

//------------------------------------------------------------------------
// CSR寄存器
//------------------------------------------------------------------------

module csr_reg
(
    input   wire                        clk,
    input   wire                        rst,

    input   wire    [`CSRAddrBus    ]   I_raddr,
    output  wire    [`CSRDataBus    ]   O_rdata,

    input   wire                        I_we,
    input   wire    [`CSRAddrBus    ]   I_waddr,
    input   wire    [`CSRDataBus    ]   I_wdata,

    input   wire    [`INT_BUS       ]   I_int,

    input   wire    [`Except_Bus    ]   I_except,
    input   wire    [`InstAddrBus   ]   I_except_addr,

    input   wire    [`InstAddrBus   ]   I_next_addr,

    output  wire                        O_flush,
    output  wire    [`InstAddrBus   ]   O_flush_addr,

    output  wire    [`CSRDataBus    ]   O_csr_mtvec,        //mtvec寄存器
    output  wire    [`CSRDataBus    ]   O_csr_mepc,         //mepc寄存器
    output  wire    [`CSRDataBus    ]   O_csr_mstatus,      //mstatus寄存器
    output  wire    [`CSRDataBus    ]   O_csr_mcause,       //mcause寄存器
    output  wire    [`DoubleCSRDataBus] O_csr_mcycle,       //mcycle寄存器
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

    reg ext_int_valid;
    reg [`INT_BUS] int_r;
    reg [`InstAddrBus] ext_int_addr;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ext_int_valid <= 1'b0;
            int_r <= `INT_NONE;
            ext_int_addr <= `ZeroWord;
        end else if(I_next_addr != `ZeroWord) begin
            ext_int_valid <= `Enable;
            ext_int_addr <= I_next_addr;
            int_r <= `INT_NONE;
        end else begin
            ext_int_valid = `Disable;
            ext_int_addr = `ZeroWord;
            int_r <= I_int;
        end
    end

    wire global_int_enable = mstatus[3]; //MIE位

    // wire except_sync = is_ecall | is_ebreak;
    wire except_sync = is_ecall; // for ysyx
    wire except_async = ext_int_valid & ((|I_int) | (|int_r)) & global_int_enable; 
    wire except_call = except_sync | except_async;
    wire except_ret = is_mret;
    

    `define YSYX_LOGO      32'h79737978 //ysyx的logo
    `define YSYX_STU_NUM   32'h25110270 //我的学号-25110270


    //cycle counter
    //复位撤销后就一直计数
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cycle <= {`ZeroWord, `ZeroWord};
        end else begin
            cycle <= cycle + 1'b1;
        end
    end

    // reg csr_timer_int;
    // always @(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         csr_timer_int <= `INT_DEASSERT;
    //     end else begin
    //         if(mtimecmp != {`ZeroWord, `ZeroWord} && cycle == mtimecmp) begin
    //             csr_timer_int <= `INT_ASSERT;
    //         end
    //     end
    // end

    //write reg
    //写寄存器操作
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mtvec <= `ZeroWord;
            mcause <= `ZeroWord;
            mepc <= `ZeroWord;
            mie <= `ZeroWord;
            mstatus <= `ZeroWord;
            mscratch <= `ZeroWord;
            mvendorid <= `YSYX_LOGO;
            marchid <= `YSYX_STU_NUM;
        end else begin
            if(except_async) begin
                mepc <= ext_int_addr;
                mcause <= 32'h80000004; //定时器中断
                mstatus <= {mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]} | 32'h1800; //MPIE->MIE, MIE清0
            end else if(except_sync) begin
                mepc <= I_except_addr;
                mcause <= is_ecall ? 32'd11 : 32'd3; //ecall=11, ebreak=3
                mstatus <= {mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]} | 32'h1800; //MPIE->MIE, MIE清0
            end else if(except_ret) begin
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
                default:            rdata1 = `ZeroWord;
            endcase
        end
    end


    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_rdata = rdata1;

    assign O_flush = except_call | except_ret;
    assign O_flush_addr =   except_call ? mtvec :
                            except_ret  ? mepc  : `ZeroWord;

    assign O_csr_mtvec = mtvec;
    assign O_csr_mepc = mepc;
    assign O_csr_mstatus = mstatus;
    assign O_csr_mcause = mcause;
    assign O_csr_mcycle = cycle;
    assign O_csr_mvendorid = mvendorid;
    assign O_csr_marchid = marchid;


endmodule
