`include "defines.v"

//------------------------------------------------------------------------
// 写回单元
//------------------------------------------------------------------------

module ysyx_25110270_wbu
(
    input   wire                                    clk,
    input   wire                                    rst,

`ifdef ysyx_25110270_DPIC
    input   wire    [31:0                       ]   I_inst,
    input   wire    [31:0                       ]   I_inst_addr,
`endif

`ifdef __ICARUS__
    input   wire    [31:0                       ]   I_inst,
    input   wire    [31:0                       ]   I_inst_addr,
`endif
    
    input   wire                                    I_valid,

    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs1_raddr,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rs2_raddr,
    output  wire    [31:0                       ]   O_rs1_rdata,
    output  wire    [31:0                       ]   O_rs2_rdata,
    input   wire    [`ysyx_25110270_CsrMapBus   ]   I_csr_raddr,
    output  wire    [31:0                       ]   O_csr_rdata,

    input   wire                                    I_rd_we,
    input   wire    [`ysyx_25110270_RegAddrBus  ]   I_rd_waddr,
    input   wire    [31:0                       ]   I_rd_wdata,

    input   wire                                    I_csr_valid,
    input   wire    [`ysyx_25110270_CsrMapBus   ]   I_csr_waddr,
    input   wire    [31:0                       ]   I_csr_wdata,

    output  wire    [63:0                       ]   O_mtime,

    input   wire    [`ysyx_25110270_ExceptBus   ]   I_except,
    input   wire    [31:0                       ]   I_except_addr,

`ifdef ysyx_25110270_DPIC
    input   wire    [31:0                       ]   I_if_addr,
    input   wire    [31:0                       ]   I_dec_addr,
    input   wire    [31:0                       ]   I_ex_addr,

    input   wire                                    I_device_skip,
`endif
    output  wire                                    O_flush,
    output  wire    [31:0                       ]   O_flush_addr
);

`ifdef ysyx_25110270_DPIC
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
`endif

`ifdef __ICARUS__
    // icarus仿真时输出gpr10的值，方便调试
    wire [31:0] gpr10;
`endif

    reg valid_r;
    always @(posedge clk) begin
        if(rst) begin
            valid_r <= 1'b0;
        end else begin
            valid_r <= I_valid;
        end
    end

    ysyx_25110270_regfile u_regfile
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_rs1_raddr            (I_rs1_raddr                ),
        .I_rs2_raddr            (I_rs2_raddr                ),

        .O_rs1_rdata            (O_rs1_rdata                ),
        .O_rs2_rdata            (O_rs2_rdata                ),

`ifdef ysyx_25110270_DPIC
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
        .O_gpr31                (gpr31                      ),
`endif

`ifdef __ICARUS__
        .gpr10                  (gpr10                      ), 
`endif

        .I_rd_we                (I_rd_we                    ),
        .I_rd_waddr             (I_rd_waddr                 ),
        .I_rd_wdata             (I_rd_wdata                 )
    );

    ysyx_25110270_csr u_csr
    (
        .clk                    (clk                        ),
        .rst                    (rst                        ),

        .I_raddr                (I_csr_raddr                ),
        .O_rdata                (O_csr_rdata                ),

        .I_we                   (I_csr_valid                ),
        .I_waddr                (I_csr_waddr                ),
        .I_wdata                (I_csr_wdata                ),

        .I_valid                (valid_r                    ),  
        .I_except               (I_except                   ),
        .I_except_addr          (I_except_addr              ),


        .O_flush                (O_flush                    ),
        .O_flush_addr           (O_flush_addr               ),

`ifdef ysyx_25110270_DPIC
        .O_csr_mtvec            (csr_mtvec                  ), //mtvec寄存器
        .O_csr_mepc             (csr_mepc                   ), //mepc寄存器
        .O_csr_mstatus          (csr_mstatus                ), //mstatus寄存器
        .O_csr_mcause           (csr_mcause                 ), //mcause寄存器
        .O_csr_mcyclel          (csr_mcyclel                ), //mcycle寄存器
        .O_csr_mcycleh          (csr_mcycleh                ), //mcycle寄存器
        .O_csr_mvendorid        (csr_mvendorid              ), //mvendorid寄存器
        .O_csr_marchid          (csr_marchid                ), //marchid寄存器
`endif

        .O_mtime                (O_mtime                    )
    );

`ifdef __ICARUS__
    initial begin
        $display("VERILOG enabled ICARUS! Reset vector: 0x%h", `ysyx_25110270_RESET_VECTOR);
    end
`endif

`ifdef ysyx_25110270_DPIC
    ////////////////////// DPI-C //////////////////////


    `ifdef ysyx_25110270_SOC
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
        input int gpr16, input int gpr17, input int gpr18, input int gpr19,
        input int gpr20, input int gpr21, input int gpr22, input int gpr23,
        input int gpr24, input int gpr25, input int gpr26, input int gpr27,
        input int gpr28, input int gpr29, input int gpr30, input int gpr31,

        input int mepc, input int mtvec, input int mstatus,
        input int mcause, input int mcyclel, input int mcycleh, 
        input int mvendorid, input int marchid
    );

    reg [31:0] inst_r1;
    reg [31:0] inst_addr_r1;
    reg [31:0] pc;
    reg skip_r;
    always @(posedge clk) begin
        if(rst) begin
            inst_r1         <= 0;
            inst_addr_r1    <= 0;
            pc              <= 0;
            skip_r          <= 1'b0;
        end else begin
            inst_r1         <= I_inst;
            inst_addr_r1    <= I_inst_addr;
            pc              <= O_flush ? O_flush_addr :
                               (I_ex_addr == 0 ? 
                               (I_dec_addr == 0 ? I_if_addr : I_dec_addr) 
                               : I_ex_addr);
            skip_r          <= I_device_skip;
        end
    end

    always @(posedge clk) begin
        if(valid_r && (|inst_r1) && (|inst_addr_r1)) begin
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

        if(inst_r1 == `ysyx_25110270_RV_EBREAK) begin
            trap(gpr10, inst_addr_r1); // a0
        end

    end
`endif

`ifdef __ICARUS__

    reg [31:0] inst_r1, inst_addr_r1;
    always @(posedge clk) begin
        if(rst) begin
            inst_r1 <= 0;
            inst_addr_r1 <= 0;
        end else begin
            inst_r1 <= I_inst;
            inst_addr_r1 <= I_inst_addr;
        end
    end

    wire is_ebreak = inst_r1 == `ysyx_25110270_RV_EBREAK;

    always @(posedge clk) begin
        if(is_ebreak) begin
            if(gpr10 == 0) begin
                $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
                $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
                $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
                $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
                $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
                $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                $display("Finish at PC = 0x%08x", inst_addr_r1);
            end else begin
                $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                $display("Finish at PC = 0x%08x", inst_addr_r1);
            end
            $finish;
        end
    end
`endif

`ifdef ysyx_25110270_DEBUG
    always @(posedge clk) begin
        if(valid_r & inst_r1 == 0 && inst_addr_r1 != 0) begin
            $error("Error: inst is 0 at addr %h!", inst_addr_r1);
            $finish;
        end
    end
`endif

`ifdef ysyx_25110270_PERF

    import "DPI-C" function void wb_inst_cycle_cal(input int pc, input int inst);

    always @(posedge clk) begin
        if(valid_r && (|inst_r1) && (|inst_addr_r1)) begin
            wb_inst_cycle_cal(inst_addr_r1, inst_r1);
        end
    end

`endif

endmodule