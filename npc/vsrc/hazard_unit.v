`include "defines.v"

//------------------------------------------------------------------------
// hazard unit
//------------------------------------------------------------------------

module ysyx_25110270_hazard_unit
(
    input   wire                                    I_rs1_re,
    input   wire                                    I_rs2_re,

    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs1_raddr,      //读寄存器1地址
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs2_raddr,

    input   wire                                    I_ex_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_ex_rd_waddr,

    input   wire                                    I_ls_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_ls_rd_waddr,

    input   wire                                    I_csr_valid,
    input   wire    [`ysyx_25110270_CsrMapBus   ]   I_csr_raddr,

    input   wire                                    I_ex_csr_valid,
    input   wire    [`ysyx_25110270_CsrMapBus   ]   I_ex_csr_waddr,

    input   wire                                    I_ls_csr_valid,
    input   wire    [`ysyx_25110270_CsrMapBus   ]   I_ls_csr_waddr,

    input   wire                                    I_ex_ld_valid,
    input   wire                                    I_bru_taken,

    output  wire    [1:0                        ]   O_fwd_ctrl_rs1,
    output  wire    [1:0                        ]   O_fwd_ctrl_rs2,
    output  wire    [1:0                        ]   O_fwd_ctrl_csr,
    output  wire                                    O_stallreq
);

    wire ex_same_addr_rs1 = I_ex_rd_waddr == I_rs1_raddr;
    wire ls_same_addr_rs1 = I_ls_rd_waddr == I_rs1_raddr;

    wire ex_same_addr_rs2 = I_ex_rd_waddr == I_rs2_raddr;
    wire ls_same_addr_rs2 = I_ls_rd_waddr == I_rs2_raddr;

    wire ex_same_addr_csr = I_ex_csr_waddr == I_csr_raddr;
    wire ls_same_addr_csr = I_ls_csr_waddr == I_csr_raddr;

    wire use_ex_data_rs1 = I_ex_rd_we & ex_same_addr_rs1;
    wire use_ls_data_rs1 = I_ls_rd_we & ls_same_addr_rs1;

    wire use_ex_data_rs2 = I_ex_rd_we & ex_same_addr_rs2;
    wire use_ls_data_rs2 = I_ls_rd_we & ls_same_addr_rs2;

    wire use_ex_data_csr = I_ex_csr_valid & ex_same_addr_csr;
    wire use_ls_data_csr = I_ls_csr_valid & ls_same_addr_csr;


    // reg [1:0] fwd_ctrl_rs1, fwd_ctrl_rs2, fwd_ctrl_csr;

    // always @(*) begin
    //     if(I_rs1_re & I_rs1_raddr != 0) begin
    //         if(use_ex_data_rs1) begin
    //             fwd_ctrl_rs1 = `ysyx_25110270_FWDSRC_EX;
    //         end else if(use_ls_data_rs1) begin
    //             fwd_ctrl_rs1 = `ysyx_25110270_FWDSRC_LS;
    //         end else begin
    //             fwd_ctrl_rs1 = `ysyx_25110270_FWDSRC_NFW;
    //         end
    //     end else begin
    //         fwd_ctrl_rs1 = `ysyx_25110270_FWDSRC_NOP;
    //     end
    // end

    // always @(*) begin
    //     if(I_rs2_re & I_rs2_raddr != 0) begin
    //         if(use_ex_data_rs2) begin
    //             fwd_ctrl_rs2 = `ysyx_25110270_FWDSRC_EX;
    //         end else if(use_ls_data_rs2) begin
    //             fwd_ctrl_rs2 = `ysyx_25110270_FWDSRC_LS;
    //         end else begin
    //             fwd_ctrl_rs2 = `ysyx_25110270_FWDSRC_NFW;
    //         end
    //     end else begin
    //         fwd_ctrl_rs2 = `ysyx_25110270_FWDSRC_NOP;
    //     end
    // end

    // always @(*) begin
    //     if(I_csr_valid) begin
    //         if(use_ex_data_csr) begin
    //             fwd_ctrl_csr = `ysyx_25110270_FWDSRC_EX;
    //         end else if(use_ls_data_csr) begin
    //             fwd_ctrl_csr = `ysyx_25110270_FWDSRC_LS;
    //         end else begin
    //             fwd_ctrl_csr = `ysyx_25110270_FWDSRC_NFW;
    //         end
    //     end else begin
    //         fwd_ctrl_csr = `ysyx_25110270_FWDSRC_NOP;
    //     end
    // end

    wire stallreq = ((I_rs1_re & ex_same_addr_rs1) | (I_rs2_re & ex_same_addr_rs2)) & (I_ex_ld_valid & ~I_bru_taken);

    wire [1:0] fwd_ctrl_rs1 = (I_rs1_re & I_rs1_raddr != 0) ? 
                        (use_ls_data_rs1) ? `ysyx_25110270_FWDSRC_LS :
                        (use_ex_data_rs1) ? `ysyx_25110270_FWDSRC_EX : `ysyx_25110270_FWDSRC_NFW :
                        `ysyx_25110270_FWDSRC_NOP;

    wire [1:0] fwd_ctrl_rs2 = (I_rs2_re & I_rs2_raddr != 0) ? 
                        (use_ls_data_rs2) ? `ysyx_25110270_FWDSRC_LS :
                        (use_ex_data_rs2) ? `ysyx_25110270_FWDSRC_EX : `ysyx_25110270_FWDSRC_NFW :
                        `ysyx_25110270_FWDSRC_NOP;

    wire [1:0] fwd_ctrl_csr = (I_csr_valid) ? 
                        (use_ls_data_csr) ? `ysyx_25110270_FWDSRC_LS :
                        (use_ex_data_csr) ? `ysyx_25110270_FWDSRC_EX : `ysyx_25110270_FWDSRC_NFW :
                        `ysyx_25110270_FWDSRC_NOP;

    assign O_fwd_ctrl_rs1 = fwd_ctrl_rs1;
    assign O_fwd_ctrl_rs2 = fwd_ctrl_rs2;
    assign O_fwd_ctrl_csr = fwd_ctrl_csr;
    assign O_stallreq = stallreq;

endmodule
