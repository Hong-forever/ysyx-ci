`include "defines.v"

//------------------------------------------------------------------------
// 写回单元
//------------------------------------------------------------------------

module ysyx_25110270_wbu
(
    input   wire                                    clk,
    input   wire                                    rst_n,

    input   wire    [31:0                       ]   I_inst,
    input   wire    [31:0                       ]   I_inst_addr,
    
    input   wire                                    I_valid,

    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs1_raddr,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs2_raddr,
    output  wire    [31:0                       ]   O_rs1_rdata,
    output  wire    [31:0                       ]   O_rs2_rdata,
    input   wire    [11:0                       ]   I_csr_raddr,
    output  wire    [31:0                       ]   O_csr_rdata,

    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_rd_wdata,

    input   wire                                    I_csr_valid,
    input   wire    [11:0                       ]   I_csr_waddr,
    input   wire    [31:0                       ]   I_csr_wdata,

    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,
    input   wire    [31:0                       ]   I_except_addr,

    input   wire    [31:0                       ]   I_next_inst_addr,

    output  wire                                    O_flush,
    output  wire    [31:0                       ]   O_flush_addr,

    input   wire    [31:0                       ]   I_if_addr,
    input   wire    [31:0                       ]   I_dec_addr,
    input   wire    [31:0                       ]   I_ex_addr,
    input   wire    [31:0                       ]   I_ls_addr,

    input   wire                                    I_device_skip
);
    // registers for DPI
    wire [31:0] gpr0, gpr1, gpr2, gpr3, gpr4, gpr5, gpr6, gpr7, gpr8, gpr9, gpr10, gpr11, gpr12, gpr13, gpr14, gpr15, gpr16, gpr17, gpr18, gpr19, gpr20, gpr21, gpr22, gpr23, gpr24, gpr25, gpr26, gpr27, gpr28, gpr29, gpr30, gpr31;   //寄存器组

    // csr reg output for dpi
    wire [31:0] csr_mtvec;
    wire [31:0] csr_mepc;
    wire [31:0] csr_mstatus;
    wire [31:0] csr_mcause;
    wire [31:0] csr_mcyclel;
    wire [31:0] csr_mcycleh;
    wire [31:0] csr_mvendorid;
    wire [31:0] csr_marchid;

    ysyx_25110270_regfile u_regfile
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_rs1_raddr            (I_rs1_raddr                ),
        .I_rs2_raddr            (I_rs2_raddr                ),

        .O_rs1_rdata            (O_rs1_rdata                ),
        .O_rs2_rdata            (O_rs2_rdata                ),

        .I_rd_we                (I_rd_we                    ),
        .I_rd_waddr             (I_rd_waddr                 ),
        .I_rd_wdata             (I_rd_wdata                 ),

        .O_gpr0                 (gpr0                       ),
        .O_gpr1                 (gpr1                       ),
        .O_gpr2                 (gpr2                       ),
        .O_gpr3                 (gpr3                       ),
        .O_gpr4                 (gpr4                       ),
        .O_gpr5                 (gpr5                       ),
        .O_gpr6                 (gpr6                       ),
        .O_gpr7                 (gpr7                       ),
        .O_gpr8                 (gpr8                       ),
        .O_gpr9                 (gpr9                       ),
        .O_gpr10                (gpr10                      ),
        .O_gpr11                (gpr11                      ),
        .O_gpr12                (gpr12                      ),
        .O_gpr13                (gpr13                      ),
        .O_gpr14                (gpr14                      ),
        .O_gpr15                (gpr15                      )
    );

    ysyx_25110270_csr_reg u_csr_reg
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_raddr                (I_csr_raddr                ),
        .O_rdata                (O_csr_rdata                ),

        .I_we                   (I_csr_valid                ),
        .I_waddr                (I_csr_waddr                ),
        .I_wdata                (I_csr_wdata                ),

        .I_except               (I_except                   ),
        .I_except_addr          (I_except_addr              ),

        .I_next_inst_addr       (I_next_inst_addr           ),

        .O_flush                (O_flush                    ),
        .O_flush_addr           (O_flush_addr               ),

        .O_csr_mtvec            (csr_mtvec                  ), //mtvec寄存器
        .O_csr_mepc             (csr_mepc                   ), //mepc寄存器
        .O_csr_mstatus          (csr_mstatus                ), //mstatus寄存器
        .O_csr_mcause           (csr_mcause                 ), //mcause寄存器
        .O_csr_mcyclel          (csr_mcyclel                ), //mcycle寄存器
        .O_csr_mcycleh          (csr_mcycleh                ), //mcycle寄存器
        .O_csr_mvendorid        (csr_mvendorid              ), //mvendorid寄存器
        .O_csr_marchid          (csr_marchid                )  //marchid寄存器
    );


`ifdef DEBUG
    always @(posedge clk) begin
        if(valid_r & I_inst == 0 && I_inst_addr != 0) begin
            $error("Error: inst is 0 at addr %h!", I_inst_addr);
        end
    end
`endif

`ifdef PERF
    reg valid_r, valid_r2;
    always @(posedge clk) begin
        if(!rst_n) begin
            valid_r <= 1'b0;
            valid_r2 <= 1'b0;
        end else begin
            valid_r <= I_valid;
            valid_r2 <= valid_r;
        end
    end
    
    import "DPI-C" function void wb_inst_cycle_cal(input int pc);

    always @(posedge clk) begin
        if(valid_r && (|I_inst) && (|I_inst_addr)) begin
            wb_inst_cycle_cal(I_inst_addr);
        end
    end

`endif

`ifdef DPIC
    ////////////////////// DPI-C //////////////////////

    `ifdef SOC
        initial begin
            $display("VERILOG enabled SOC! Reset vector: 0x%h", `ysyx_25110270_RESET_VECTOR);
        end
    `else 
        initial begin
            $display("VERILOG enabled NPC! Reset vector: 0x%h", `ysyx_25110270_RESET_VECTOR);
        end
    `endif

    import "DPI-C" function void trap(input int reg_data, input int halt_pc);

    import "DPI-C" function void cpu_value(input int diff_skip, input int valid, input int inst, input int inst_addr, input int pc, 
        input int gpr0, input int gpr1, input int gpr2, input int gpr3, 
        input int gpr4, input int gpr5, input int gpr6, input int gpr7, 
        input int gpr8, input int gpr9, input int gpr10, input int gpr11, 
        input int gpr12, input int gpr13, input int gpr14, input int gpr15,

        input int mepc, input int mtvec, input int mstatus, 
        input int mcause, input int mcyclel, input int mcycleh, 
        input int mvendorid, input int marchid
    );

    reg [31:0] inst_r1;
    reg [31:0] inst_addr_r1;
    reg [31:0] pc;
    reg skip_r;
    always @(posedge clk) begin
        if(!rst_n) begin
            inst_r1         <= 0;
            inst_addr_r1    <= 0;
            skip_r          <= 1'b0;
        end else begin
            inst_r1         <= I_inst;
            inst_addr_r1    <= I_inst_addr;
            skip_r          <= I_device_skip;
        end
    end

    always @(posedge clk) begin
        if(valid_r2) begin
            cpu_value
            (
                skip_r, 1, inst_r1, inst_addr_r1, I_if_addr, 
                gpr0, gpr1, gpr2, gpr3, gpr4, gpr5, gpr6, gpr7,
                gpr8, gpr9, gpr10, gpr11, gpr12, gpr13, gpr14, gpr15,

                csr_mepc, csr_mtvec, csr_mstatus, 
                csr_mcause, csr_mcyclel, csr_mcycleh,
                csr_mvendorid, csr_marchid
            );
        end

        if(inst_r1 == `ysyx_25110270_RV_EBREAK) begin
            trap(gpr10, inst_addr_r1); // a0
        end

    end
`endif

endmodule