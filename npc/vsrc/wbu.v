`include "defines.v"

//------------------------------------------------------------------------
// 写回单元
//------------------------------------------------------------------------

module wbu
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,
    input   wire    [`InstAddrBus   ]   I_inst_addr,
    
    output  wire                        O_ready,

    // regfile
    input   wire    [`RegAddrBus    ]   I_rs1_raddr,
    input   wire    [`RegAddrBus    ]   I_rs2_raddr,
    output  wire    [`RegDataBus    ]   O_rs1_rdata,
    output  wire    [`RegDataBus    ]   O_rs2_rdata,

    input   wire                        I_rd_we,
    input   wire    [`RegAddrBus    ]   I_rd_waddr,
    input   wire    [`RegDataBus    ]   I_rd_wdata,

    // csr reg
    input   wire    [`CSRAddrBus    ]   I_csr_raddr,
    output  wire    [`CSRDataBus    ]   O_csr_rdata,

    input   wire                        I_csr_we,
    input   wire    [`CSRAddrBus    ]   I_csr_waddr,
    input   wire    [`CSRDataBus    ]   I_csr_wdata,

    input   wire    [`Except_Bus    ]   I_except,
    input   wire    [`InstAddrBus   ]   I_except_addr,

    input   wire    [`InstAddrBus   ]   I_next_inst_addr,

    output  wire                        O_flush,
    output  wire    [`InstAddrBus   ]   O_flush_addr,

    input   wire    [`InstAddrBus   ]   I_if_addr,
    input   wire    [`InstAddrBus   ]   I_dec_addr,
    input   wire    [`InstAddrBus   ]   I_ex_addr,
    input   wire    [`InstAddrBus   ]   I_ls_addr,

    input   wire                        I_device_skip
);
    // registers for DPI
    wire [`RegDataBus] gpr0, gpr1, gpr2, gpr3, gpr4, gpr5, gpr6, gpr7, gpr8, gpr9, gpr10, gpr11, gpr12, gpr13, gpr14, gpr15, gpr16, gpr17, gpr18, gpr19, gpr20, gpr21, gpr22, gpr23, gpr24, gpr25, gpr26, gpr27, gpr28, gpr29, gpr30, gpr31;   //寄存器组

    // csr reg output for dpi
    wire [`CSRDataBus] csr_mtvec;
    wire [`CSRDataBus] csr_mepc;
    wire [`CSRDataBus] csr_mstatus;
    wire [`CSRDataBus] csr_mcause;
    wire [`CSRDataBus] csr_mcyclel;
    wire [`CSRDataBus] csr_mcycleh;
    wire [`CSRDataBus] csr_mvendorid;
    wire [`CSRDataBus] csr_marchid;

    regfile u_regfile
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_inst                 (I_inst                     ),
        .I_inst_addr            (I_inst_addr                ),

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
        .O_gpr15                (gpr15                      ),
        .O_gpr16                (gpr16                      ),
        .O_gpr17                (gpr17                      ),
        .O_gpr18                (gpr18                      ),
        .O_gpr19                (gpr19                      ),
        .O_gpr20                (gpr20                      ),
        .O_gpr21                (gpr21                      ),
        .O_gpr22                (gpr22                      ),
        .O_gpr23                (gpr23                      ),
        .O_gpr24                (gpr24                      ),
        .O_gpr25                (gpr25                      ),
        .O_gpr26                (gpr26                      ),
        .O_gpr27                (gpr27                      ),
        .O_gpr28                (gpr28                      ),
        .O_gpr29                (gpr29                      ),
        .O_gpr30                (gpr30                      ),
        .O_gpr31                (gpr31                      )
    );

    csr_reg u_csr_reg
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),

        .I_raddr                (I_csr_raddr                ),
        .O_rdata                (O_csr_rdata                ),

        .I_we                   (I_csr_we                   ),
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

    assign O_ready = 1'b1;

`ifdef DPIC
    ////////////////////// DPI-C //////////////////////

    import "DPI-C" function void trap(input int reg_data, input int halt_pc);

    import "DPI-C" function void cpu_value(input int diff_skip, input int valid, input int inst, input int inst_addr, input int pc, 
        input int gpr0, input int gpr1, input int gpr2, input int gpr3, 
        input int gpr4, input int gpr5, input int gpr6, input int gpr7, 
        input int gpr8, input int gpr9, input int gpr10, input int gpr11, 
        input int gpr12, input int gpr13, input int gpr14, input int gpr15, 
        input int gpr16, input int gpr17, input int gpr18, input int gpr19, 
        input int gpr20, input int gpr21, input int gpr22, input int gpr23,
        input int gpr24, input int gpr25, input int gpr26, input int gpr27, 
        input int gpr28, input int gpr29, input int gpr30, input int gpr31,

        input int mepc, input int mtvec, input int mstatus, 
        input int mcause, input int mcyclel, input int mcycleh, 
        input int mvendorid, input int marchid
    );

    reg [`InstBus] inst_r1, inst_r2;
    reg [`InstAddrBus] inst_addr_r1, inst_addr_r2;
    reg [`InstAddrBus] pc;
    reg skip_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst_r1         <= `Zero;
            inst_addr_r1    <= `Zero;
            inst_r2         <= `Zero;
            inst_addr_r2    <= `Zero;
            pc              <= `Zero;
            skip_r          <= 1'b0;
        end else begin
            inst_r1         <= I_inst;
            inst_addr_r1    <= I_inst_addr;
            inst_r2         <= inst_r1;
            inst_addr_r2    <= inst_addr_r1;
            pc              <= O_flush ? O_flush_addr :
                               (I_ls_addr == `Zero ? 
                               (I_ex_addr == `Zero ? 
                               (I_dec_addr == `Zero ? I_if_addr : I_dec_addr) 
                               : I_ex_addr) 
                               : I_ls_addr);
            skip_r          <= I_device_skip;
        end
    end

    always @(*) begin

        if((inst_r1 != `Zero && inst_addr_r1 != `Zero) && (inst_r2 != inst_r1 || inst_addr_r2 != inst_addr_r1) ) begin
            cpu_value
            (
                skip_r, 1, inst_r1, inst_addr_r1, pc, 
                gpr0, gpr1, gpr2, gpr3, gpr4, gpr5, gpr6, gpr7,
                gpr8, gpr9, gpr10, gpr11, gpr12, gpr13, gpr14, gpr15,
                gpr16, gpr17, gpr18, gpr19, gpr20, gpr21, gpr22, gpr23,
                gpr24, gpr25, gpr26, gpr27, gpr28, gpr29, gpr30, gpr31,

                csr_mepc, csr_mtvec, csr_mstatus, 
                csr_mcause, csr_mcyclel, csr_mcycleh,
                csr_mvendorid, csr_marchid
            );
        end

        if(inst_r1 == `RV_EBREAK) begin
            trap(gpr10, inst_addr_r1); // a0
        end

    end
`endif

endmodule