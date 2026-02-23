`include "defines.v"

//------------------------------------------------------------------------
// hazard unit
//------------------------------------------------------------------------

module ysyx_25110270_hazard_unit
(
    input   wire                                    I_rs1_re,
    input   wire                                    I_rs2_re,
    input   wire                                    I_csr_re,

    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs1_raddr,      //读寄存器1地址
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs2_raddr,
    input   wire    [11:0                       ]   I_csr_raddr,

    input   wire                                    I_ex_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_ex_rd_waddr,

    input   wire                                    I_ls_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_ls_rd_waddr,

    input   wire                                    I_wb_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_wb_rd_waddr,

    input   wire                                    I_ex_csr_we,
    input   wire    [11:0                       ]   I_ex_csr_waddr,

    input   wire                                    I_ls_csr_we,
    input   wire    [11:0                       ]   I_ls_csr_waddr,

    input   wire                                    I_wb_csr_we,
    input   wire    [11:0                       ]   I_wb_csr_waddr,

    input   wire                                    I_bru_taken,

    output  wire                                    O_stallreq
);

    reg stallreq_rs1, stallreq_rs2, stallreq_csr;
    always @(*) begin
        if(I_rs1_re & I_rs1_raddr != 0) begin
            if(I_wb_rd_we & (I_wb_rd_waddr == I_rs1_raddr)) begin
                stallreq_rs1 = 1'b1;
            end else if(I_ls_rd_we & (I_ls_rd_waddr == I_rs1_raddr)) begin
                stallreq_rs1 = 1'b1;
            end else if(I_ex_rd_we & (I_ex_rd_waddr == I_rs1_raddr)) begin
                stallreq_rs1 = 1'b1;
            end else begin
                stallreq_rs1 = 1'b0;
            end
        end else begin
            stallreq_rs1 = 1'b0;
        end
    end

    always @(*) begin
        if(I_rs2_re & I_rs2_raddr != 0) begin
            if(I_wb_rd_we & (I_wb_rd_waddr == I_rs2_raddr)) begin
                stallreq_rs2 = 1'b1;
            end else if(I_ls_rd_we & (I_ls_rd_waddr == I_rs2_raddr)) begin
                stallreq_rs2 = 1'b1;
            end else if(I_ex_rd_we & (I_ex_rd_waddr == I_rs2_raddr)) begin
                stallreq_rs2 = 1'b1;
            end else begin
                stallreq_rs2 = 1'b0;
            end
        end else begin
            stallreq_rs2 = 1'b0;
        end
    end

    always @(*) begin
        if(I_csr_re) begin
            if(I_wb_csr_we & (I_wb_csr_waddr == I_csr_raddr)) begin
                stallreq_csr = 1'b1;
            end else if(I_ls_csr_we & (I_ls_csr_waddr == I_csr_raddr)) begin
                stallreq_csr = 1'b1;
            end else if(I_ex_csr_we & (I_ex_csr_waddr == I_csr_raddr)) begin
                stallreq_csr = 1'b1;
            end else begin
                stallreq_csr = 1'b0;
            end
        end else begin
            stallreq_csr = 1'b0;
        end
    end

    // wire stallreq_rs1 = (I_rs1_re & I_rs1_raddr != 0) ? 
    //                     (I_wb_rd_we & (I_wb_rd_waddr == I_rs1_raddr)) ? 1'b1 :
    //                     (I_ls_rd_we & (I_ls_rd_waddr == I_rs1_raddr)) ? 1'b1 :
    //                     (I_ex_rd_we & (I_ex_rd_waddr == I_rs1_raddr)) ? 1'b1 : 1'b0 :
    //                     1'b0;

    // wire stallreq_rs2 = (I_rs2_re & I_rs2_raddr != 0) ? 
    //                     (I_wb_rd_we & (I_wb_rd_waddr == I_rs2_raddr)) ? 1'b1 :
    //                     (I_ls_rd_we & (I_ls_rd_waddr == I_rs2_raddr)) ? 1'b1 :
    //                     (I_ex_rd_we & (I_ex_rd_waddr == I_rs2_raddr)) ? 1'b1 : 1'b0 :
    //                     1'b0;

    // wire stallreq_csr = (I_csr_re) ? 
    //                     (I_wb_csr_we & (I_wb_csr_waddr == I_csr_raddr)) ? 1'b1 :
    //                     (I_ls_csr_we & (I_ls_csr_waddr == I_csr_raddr)) ? 1'b1 :
    //                     (I_ex_csr_we & (I_ex_csr_waddr == I_csr_raddr)) ? 1'b1 : 1'b0 :
    //                     1'b0;

    assign O_stallreq = (stallreq_rs1 | stallreq_rs2 | stallreq_csr) & ~I_bru_taken;

endmodule
