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
    output  wire                        ibus_reqValid,
    input   wire                        ibus_reqReady,
    input   wire                        ibus_respValid,
    output  wire                        ibus_respReady,
    output  wire                        ibus_we,
    output  wire    [`InstAddrBus   ]   ibus_addr,
    input   wire    [`InstBus       ]   ibus_rdata,
    output  wire    [`InstBus       ]   ibus_wdata,
    output  wire    [`DBUS_MASK-1:0 ]   ibus_mask

);

    //------------------------------------------------------------------------
    // 变量定义
    //------------------------------------------------------------------------

    parameter IDLE = 0;
    parameter MEM = 1;
    parameter EXE = 2;
    reg [1:0] state, nstate;

    reg inst_reqValid;

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

    always @(*) begin
        if(!rst_n) begin
            inst_reqValid = 1'b0;
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    inst_reqValid = 1'b1;
                    nstate = ibus_reqReady ? MEM : IDLE;
                end
                MEM: begin
                    inst_reqValid = 1'b0;
                    nstate = ibus_respValid ? EXE : MEM;
                end
                EXE: begin
                    inst_reqValid = 1'b0;
                    nstate = I_ready ? IDLE : EXE;
                end
                default: begin
                    inst_reqValid = 1'b0;
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
            inst <= `ZeroWord;
        end else if(ibus_respValid) begin
            inst <= ibus_rdata;
        end
    end

    reg inst_respReady;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst_respReady <= 1'b0;
        end else if(ibus_respValid) begin
            inst_respReady <= 1'b1;
        end else begin
            inst_respReady <= 1'b0;
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
    

    assign ibus_reqValid = inst_reqValid;
    assign ibus_respReady = inst_respReady;
    assign ibus_we = `False;
    assign ibus_addr = pc;
    assign ibus_wdata = `ZeroWord;
    assign ibus_mask = 4'b1111;


endmodule
