`include "defines.v"

//------------------------------------------------------------------------
// 访存单元
//------------------------------------------------------------------------

module lsu
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`InstBus       ]   I_inst,             //指令内容
    input   wire    [`InstAddrBus   ]   I_inst_addr,

    input   wire                        I_valid,
    input   wire                        I_ready,
    output  wire                        O_ready,

    input   wire                        I_rd_we,
    input   wire    [`RegAddrBus    ]   I_rd_waddr,
    input   wire    [`RegDataBus    ]   I_rd_wdata,
    input   wire    [`MemAddrBus    ]   I_memory_addr,
    input   wire    [`MemDataBus    ]   I_store_data,
    input   wire                        I_ls_valid,
    input   wire    [`ls_diff_bus   ]   I_ls_type,
    input   wire                        I_csr_we,
    input   wire    [`CSRAddrBus    ]   I_csr_waddr,
    input   wire    [`CSRDataBus    ]   I_csr_wdata,
    input   wire    [`Except_Bus    ]   I_except,

    output  wire    [`InstBus       ]   O_inst,
    output  wire    [`InstAddrBus   ]   O_inst_addr,
    output  wire                        O_valid,

    output  wire                        O_rd_we,
    output  wire    [`RegAddrBus    ]   O_rd_waddr,
    output  wire    [`RegDataBus    ]   O_rd_wdata,
    output  wire                        O_csr_we,
    output  wire    [`CSRAddrBus    ]   O_csr_waddr,
    output  wire    [`CSRDataBus    ]   O_csr_wdata,
    output  wire    [`Except_Bus    ]   O_except,

    //to bus
    output  wire                        dbus_reqValid,
    input   wire                        dbus_reqReady,
    input   wire                        dbus_respValid,
    output  wire                        dbus_respReady,
    output  wire                        dbus_we,
    output  wire    [`MemAddrBus    ]   dbus_addr,
    input   wire    [`MemDataBus    ]   dbus_rdata,
    output  wire    [`MemDataBus    ]   dbus_wdata,
    output  wire    [`DBUS_MASK-1:0 ]   dbus_mask
);

    //------------------------------------------------------------------------
    // 存取结果
    //------------------------------------------------------------------------
    reg [`MemDataBus] rdata;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata <= 0;
        end else if(dbus_respValid) begin
            rdata <= dbus_rdata;
        end
    end

    wire [`MemDataBus] lb_00_res = {{24{rdata[7]}},  rdata[7:0]};
    wire [`MemDataBus] lb_01_res = {{24{rdata[15]}}, rdata[15:8]};
    wire [`MemDataBus] lb_10_res = {{24{rdata[23]}}, rdata[23:16]};
    wire [`MemDataBus] lb_11_res = {{24{rdata[31]}}, rdata[31:24]};

    wire [`MemDataBus] lh_00_res = {{16{rdata[15]}}, rdata[15:0]};
    wire [`MemDataBus] lh_10_res = {{16{rdata[31]}}, rdata[31:16]};

    wire [`MemDataBus] lw_res = rdata;

    wire [`MemDataBus] lbu_00_res = {{24{1'b0}}, rdata[7:0]};
    wire [`MemDataBus] lbu_01_res = {{24{1'b0}}, rdata[15:8]};
    wire [`MemDataBus] lbu_10_res = {{24{1'b0}}, rdata[23:16]};
    wire [`MemDataBus] lbu_11_res = {{24{1'b0}}, rdata[31:24]};

    wire [`MemDataBus] lhu_00_res = {{16{1'b0}}, rdata[15:0]};
    wire [`MemDataBus] lhu_10_res = {{16{1'b0}}, rdata[31:16]};

    wire [`MemDataBus] sb_00_res = {24'b0, I_store_data[7:0]};
    wire [`MemDataBus] sb_01_res = {16'b0, I_store_data[7:0], 8'b0};
    wire [`MemDataBus] sb_10_res = {8'b0, I_store_data[7:0], 16'b0};
    wire [`MemDataBus] sb_11_res = {I_store_data[7:0], 24'b0};

    wire [`MemDataBus] sh_00_res = {16'b0, I_store_data[15:0]};
    wire [`MemDataBus] sh_10_res = {I_store_data[15:0], 16'b0};

    wire [`MemDataBus] sw_res = I_store_data;

    // 地址明辨
    wire [1:0] memory_byte_addr = I_memory_addr[1:0];

    //------------------------------------------------------------------------
    // 访存逻辑
    //------------------------------------------------------------------------
    reg [`RegDataBus] rd_data;
    always @(*) begin
        rd_data = I_rd_wdata;
        case(I_ls_type)
            `ls_lb: begin
                case(memory_byte_addr)
                    2'b00: rd_data = lb_00_res;
                    2'b01: rd_data = lb_01_res;
                    2'b10: rd_data = lb_10_res;
                    2'b11: rd_data = lb_11_res;
                    default: begin end
                endcase
            end
            `ls_lh: begin
                case(memory_byte_addr[1])
                    1'b0: rd_data = lh_00_res;
                    1'b1: rd_data = lh_10_res;
                    default: begin end
                endcase
            end
            `ls_lw: begin
                rd_data = lw_res;
            end
            `ls_lbu: begin
                case(memory_byte_addr)
                    2'b00: rd_data = lbu_00_res;
                    2'b01: rd_data = lbu_01_res;
                    2'b10: rd_data = lbu_10_res;
                    2'b11: rd_data = lbu_11_res;
                    default: begin end
                endcase
            end
            `ls_lhu: begin
                case(memory_byte_addr[1])
                    1'b0: rd_data = lhu_00_res;
                    1'b1: rd_data = lhu_10_res;
                    default: begin end
                endcase
            end
            default: begin end
        endcase
    end

    //------------------------------------------------------------------------
    // 存储逻辑
    //------------------------------------------------------------------------
    reg [`MemDataBus] wdata;
    always @(*) begin
        wdata = `ZeroWord;
        case(I_ls_type)
            `ls_sb: begin
                case(memory_byte_addr)
                    2'b00: wdata = sb_00_res;
                    2'b01: wdata = sb_01_res;
                    2'b10: wdata = sb_10_res;
                    2'b11: wdata = sb_11_res;
                    default: begin end
                endcase
            end
            `ls_sh: begin
                case(memory_byte_addr[1])
                    1'b0: wdata = sh_00_res;
                    1'b1: wdata = sh_10_res;
                    default: begin end
                endcase
            end
            `ls_sw: begin
                wdata = sw_res;
            end
            default: begin end
        endcase
    end

    //------------------------------------------------------------------------
    // 字节选通
    //------------------------------------------------------------------------

    reg [`DBUS_MASK-1:0] data_mask;
    always @(*) begin
        data_mask = 'b0000;
        case(I_ls_type)
            `ls_lb, `ls_lbu, `ls_sb: begin
                case(memory_byte_addr)
                    2'b00: data_mask = 4'b0001;
                    2'b01: data_mask = 4'b0010;
                    2'b10: data_mask = 4'b0100;
                    2'b11: data_mask = 4'b1000;
                    default: begin end
                endcase
            end
            `ls_lh, `ls_lhu, `ls_sh: begin
                case(memory_byte_addr[1])
                    1'b0: data_mask = 4'b0011;
                    1'b1: data_mask = 4'b1100;
                    default: begin end
                endcase
            end
            `ls_lw, `ls_sw: begin
                data_mask = 4'b1111;
            end
            default: begin end
        endcase
    end

    reg valid;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid <= 1'b0;
        end else if(I_valid) begin
            valid <= 1'b1;
        end else if(I_ls_valid & dbus_reqReady) begin
            valid <= 1'b0;
        end
    end

    parameter IDLE = 0;
    parameter MEM  = 1;
    parameter WB   = 2;

    reg data_reqValid;
    reg [1:0] state, nstate;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            data_reqValid = 1'b0;
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    data_reqValid = I_ls_valid & valid;
                    nstate = I_ls_valid & dbus_reqReady ? MEM : IDLE;
                end
                MEM: begin
                    data_reqValid = 1'b0;
                    nstate = dbus_respValid ? WB : MEM;
                end
                WB: begin
                    data_reqValid = 1'b0;
                    nstate = IDLE;
                end
                default: begin
                    data_reqValid = 1'b0;
                    nstate = IDLE;
                end
            endcase
        end
    end

    reg data_respReady;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_respReady <= 1'b0;
        end else if(dbus_respValid) begin
            data_respReady <= 1'b1;
        end else begin
            data_respReady <= 1'b0;
        end
    end

    reg stallreq_mem;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            stallreq_mem <= 1'b0;
        end else begin
            if(data_reqValid || state == MEM) begin
                stallreq_mem <= 1'b1;
            end else if(dbus_reqReady || state == WB) begin
                stallreq_mem <= 1'b0;
            end
        end
    end

    wire stallreq_ls_req = data_reqValid;
    wire stallreq = stallreq_mem | stallreq_ls_req;


    //------------------------------------------------------------------------
    // 输出
    //------------------------------------------------------------------------
    assign O_inst = I_inst;
    assign O_inst_addr = I_inst_addr;
    assign O_rd_we = I_rd_we;
    assign O_rd_waddr = I_rd_waddr;
    assign O_rd_wdata = rd_data;

    assign O_csr_we = I_csr_we;
    assign O_csr_waddr = I_csr_waddr;
    assign O_csr_wdata = I_csr_wdata;

    assign O_except = I_except;

    assign dbus_reqValid = data_reqValid;
    assign dbus_respReady = data_respReady;
    assign dbus_we = I_ls_type[`ls_diff_width-1];
    assign dbus_addr = I_memory_addr;
    assign dbus_mask = data_mask;

    assign dbus_wdata = wdata;

    assign O_ready = I_ready & ~stallreq;
    assign O_valid = O_ready;

endmodule