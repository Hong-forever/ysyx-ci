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
    output  wire                        O_ibus_req,
    output  wire                        O_ibus_we,
    output  wire    [`InstAddrBus   ]   O_ibus_addr,
    output  wire    [`InstBus       ]   O_ibus_data,
    output  wire    [`DBUS_MASK-1:0 ]   O_ibus_mask,
    input   wire    [`InstBus       ]   I_ibus_data

);

    //------------------------------------------------------------------------
    // 变量定义
    //------------------------------------------------------------------------
    wire [`InstAddrBus] npc;
    wire [`InstAddrBus] pc_plus4;

    wire [`InstBus] ibus_data;

    // 取指PC
    reg [`InstAddrBus] pc;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc <= `RomAddrBase;
        end else begin
            pc <= npc;
        end
    end

    assign npc = I_flush        ? I_flush_addr    :
                 I_bru_taken    ? I_bru_target    :
                 I_ready        ? pc_plus4        :
                 pc;

    assign pc_plus4 = pc + 32'h4;

    assign O_inst = I_ibus_data | ibus_data;
    assign O_inst_addr = pc;
    assign O_valid = I_ready;
    

    assign O_ibus_req = rst_n & O_valid;
    assign O_ibus_we = `False;
    assign O_ibus_addr = pc;
    assign O_ibus_data = `ZeroWord;
    assign O_ibus_mask = 4'b1111;

    rom #(
        .DATA_WIDTH     (32                     ),
        .ADDR_WIDTH     (32                     ),
        .ROM_DEPTH      (256                    )
    ) irom_inst
    (
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),

        .ce_i           (O_ibus_req               ),
        .addr_i         (O_ibus_addr              ),
        .data_o         (ibus_data             )
    );


endmodule
