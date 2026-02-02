`include "defines.v"

//------------------------------------------------------------------------
// 前递单元
//------------------------------------------------------------------------

module ysyx_25110270_fwd_unit
(
    input   wire                        I_rs1_re,
    input   wire                        I_rs2_re,
    input   wire                        I_csr_re,

    input   wire    [`RegAddrBus    ]   I_rs1_raddr,
    input   wire    [`RegAddrBus    ]   I_rs2_raddr,
    input   wire    [`CSRAddrBus    ]   I_csr_raddr,

    input   wire                        I_ls_rd_we,
    input   wire    [`RegAddrBus    ]   I_ls_rd_waddr,

    input   wire                        I_wb_rd_we,
    input   wire    [`RegAddrBus    ]   I_wb_rd_waddr,

    input   wire                        I_ls_csr_we,
    input   wire    [`CSRAddrBus    ]   I_ls_csr_waddr,

    input   wire                        I_wb_csr_we,
    input   wire    [`CSRAddrBus    ]   I_wb_csr_waddr,


    output  wire    [`FWDSrc_sel_width-1:0] O_FWDCtrl_rs1,
    output  wire    [`FWDSrc_sel_width-1:0] O_FWDCtrl_rs2,
    output  wire    [`FWDSrc_sel_width-1:0] O_FWDCtrl_csr
);

    assign O_FWDCtrl_rs1 = (I_rs1_re & I_rs1_raddr != 0)? 
                            (I_ls_rd_we & (I_ls_rd_waddr == I_rs1_raddr))? `FWDSrc_ls :
                            (I_wb_rd_we & (I_wb_rd_waddr == I_rs1_raddr))? `FWDSrc_wb :
                            `FWDSrc_nfw : 0;

    assign O_FWDCtrl_rs2 = (I_rs2_re & I_rs2_raddr != 0)? 
                            (I_ls_rd_we & (I_ls_rd_waddr == I_rs2_raddr))? `FWDSrc_ls :
                            (I_wb_rd_we & (I_wb_rd_waddr == I_rs2_raddr))? `FWDSrc_wb :
                            `FWDSrc_nfw : 0;

    assign O_FWDCtrl_csr = (I_csr_re)? 
                            (I_ls_csr_we & (I_ls_csr_waddr == I_csr_raddr))? `FWDSrc_ls :
                            (I_wb_csr_we & (I_wb_csr_waddr == I_csr_raddr))? `FWDSrc_wb :
                            `FWDSrc_nfw : 0;


endmodule

//------------------------------------------------------------------------
// fwd load stall
//------------------------------------------------------------------------

module ysyx_25110270_fwd_load_stall
(
    input   wire                        I_ex_ls_valid,
    input   wire                        I_ex_ls_load,
    input   wire    [`RegAddrBus    ]   I_ex_rd_waddr,

    input   wire                        I_dec_rs1_re,
    input   wire    [`RegAddrBus    ]   I_dec_rs1_raddr,
    input   wire                        I_dec_rs2_re,
    input   wire    [`RegAddrBus    ]   I_dec_rs2_raddr,

    input   wire                        I_bru_taken,

    output  wire                        O_stallreq
);

    wire stallreq_ex1_dec1 = ((I_dec_rs1_re & (I_ex_rd_waddr == I_dec_rs1_raddr))  | 
                            (I_dec_rs2_re & (I_ex_rd_waddr == I_dec_rs2_raddr))) & 
                            ((I_ex_ls_valid & I_ex_ls_load) & ~I_bru_taken);


    assign O_stallreq = stallreq_ex1_dec1;

endmodule
