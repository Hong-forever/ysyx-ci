`include "defines.v"

//------------------------------------------------------------------------
// 取指单元
//------------------------------------------------------------------------

module ifetch
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        I_bru_taken,        //跳转指令
    input   wire    [`InstAddrBus   ]   I_bru_target,

    input   wire                        I_ready,

    input   wire                        I_flush,            // 指令冲刷
    input   wire    [`InstAddrBus   ]   I_flush_addr,       // 冲刷跳转地址

    output  wire    [`InstBus       ]   O_inst,
    output  wire    [`InstAddrBus   ]   O_inst_addr,
    output  wire                        O_valid,

    //to bus
    output  wire                        ibus_awvalid,
    input   wire                        ibus_awready,
    output  wire    [`InstAddrBus   ]   ibus_awaddr,

    output  wire                        ibus_wvalid,
    input   wire                        ibus_wready,
    output  wire    [`InstBus       ]   ibus_wdata,
    output  wire    [`DBUS_MASK-1:0 ]   ibus_wstrb,

    input   wire                        ibus_bvalid,
    output  wire                        ibus_bready,
    input   wire    [`AXI_RESP_BUS  ]   ibus_bresp,

    output  wire                        ibus_arvalid,
    input   wire                        ibus_arready,
    output  wire    [`InstAddrBus   ]   ibus_araddr,

    input   wire                        ibus_rvalid,
    output  wire                        ibus_rready,
    input   wire    [`InstBus       ]   ibus_rdata,
    input   wire    [`AXI_RESP_BUS  ]   ibus_rresp
);

    //------------------------------------------------------------------------
    // 变量定义
    //------------------------------------------------------------------------

    parameter IDLE = 0;
    parameter MEM = 1;
    parameter EXE = 2;
    reg [1:0] state, nstate;

    reg inst_arvalid;

    reg [`InstAddrBus] pc;
    wire [`InstAddrBus] pc_plus4;
    wire [`InstAddrBus] npc;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end
    wire inst_arvalid_next = (state == IDLE && ~ibus_arready) || (state == EXE && I_ready);

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_arvalid <= 1'b0;
        end else begin
            inst_arvalid <= inst_arvalid_next;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    nstate = ibus_arready ? MEM : IDLE;
                end
                MEM: begin
                    nstate = ibus_rvalid ? EXE : MEM;
                end
                EXE: begin
                    nstate = I_ready ? IDLE : EXE;
                end
                default: begin
                    nstate = IDLE;
                end 
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc <= `RomAddrBase;
        end else if(state == EXE) begin
            pc <= npc;
        end
    end

    reg [`InstBus] inst;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst <= `Zero;
        end else if(ibus_rvalid) begin
            inst <= ibus_rdata;
        end
    end

    reg inst_rready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst_rready <= 1'b1;
        end else if(ibus_rvalid) begin
            inst_rready <= 1'b0;
        end else begin
            inst_rready <= 1'b1;
        end
    end

    assign npc = I_flush        ? I_flush_addr    :
                 I_bru_taken    ? I_bru_target    :
                 I_ready        ? pc_plus4        :
                 pc;
    
    assign pc_plus4 = pc + 32'h4;

    assign O_inst = inst;
    assign O_inst_addr = pc;
    assign O_valid = I_ready & state == EXE;
    
    assign ibus_awvalid = 1'b0;
    assign ibus_awaddr = `Zero;

    assign ibus_wvalid = 1'b0;
    assign ibus_wdata = `Zero;
    assign ibus_wstrb = 4'b0000;

    assign ibus_bready = 1'b0;

    assign ibus_araddr = pc;

    assign ibus_rready = inst_rready;

`ifndef LFSR
    assign ibus_arvalid = inst_arvalid;
`else
    reg arvalid_r;
    wire [`RAMDOM_WIDTH-1:0] irandom;
    reg [`RAMDOM_WIDTH-1:0] irandom_r;
    reg req_flag;
    always @(posedge clk) begin
        if(!rst_n) begin
            arvalid_r <= 1'b0;
            irandom_r <= 0;
            req_flag <= 1'b0;
        end else if(req_flag) begin
            irandom_r <= irandom_r - 1;
            if(irandom_r == 0) begin
                arvalid_r <= 1'b1;
                req_flag <= 1'b0;
            end
        end else if(state == IDLE && inst_arvalid && !arvalid_r) begin
            arvalid_r <= 1'b0;
            irandom_r <= irandom;
            req_flag <= 1'b1;
        end else if(ibus_arvalid && ibus_arready) begin
            arvalid_r <= 1'b0;
        end
    end

    assign ibus_arvalid = arvalid_r;

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (`SEED1                     ),
        .O_random               (irandom                    )
    );
`endif


endmodule
