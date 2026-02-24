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

    output  wire                        O_device_skip,

    //to bus
    output  wire                        dbus_awvalid,
    input   wire                        dbus_awready,
    output  wire    [`MemAddrBus    ]   dbus_awaddr,

    output  wire                        dbus_wvalid,
    input   wire                        dbus_wready,
    output  wire    [`MemDataBus    ]   dbus_wdata,
    output  wire    [`DBUS_MASK-1:0 ]   dbus_wstrb,

    input   wire                        dbus_bvalid,
    output  wire                        dbus_bready,
    input   wire    [`AXI_RESP_BUS  ]   dbus_bresp,

    output  wire                        dbus_arvalid,
    input   wire                        dbus_arready,
    output  wire    [`MemAddrBus    ]   dbus_araddr,

    input   wire                        dbus_rvalid,
    output  wire                        dbus_rready,
    input   wire    [`MemDataBus    ]   dbus_rdata,
    input   wire    [`AXI_RESP_BUS  ]   dbus_rresp
);

    //------------------------------------------------------------------------
    // 存取结果
    //------------------------------------------------------------------------
    reg [`MemDataBus] rdata;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata <= 0;
        end else if(dbus_rvalid) begin
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
        wdata = `Zero;
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
        end else if(I_ls_valid & (dbus_arready | dbus_awready)) begin
            valid <= 1'b0;
        end
    end

    parameter IDLE = 0;
    parameter MEM  = 1;
    parameter WB   = 2;

    reg data_avalid;
    reg [1:0] state, nstate;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    wire ls_req = I_ls_valid & valid;
    wire data_avalid_next = (state == IDLE && ls_req && !(dbus_awready | dbus_arready));

    always @(posedge clk) begin
        if(!rst_n) begin
            data_avalid <= 1'b0;
        end else begin
            data_avalid <= data_avalid_next;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    nstate = data_avalid & (dbus_awready | dbus_arready) ? MEM : IDLE;
                end
                MEM: begin
                    nstate = (dbus_bvalid | dbus_rvalid) ? WB : MEM;
                end
                WB: begin
                    nstate = IDLE;
                end
                default: begin
                    nstate = IDLE;
                end
            endcase
        end
    end

    reg data_bready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_bready <= 1'b1;
        end else if(dbus_bvalid) begin
            data_bready <= 1'b0;
        end else begin
            data_bready <= 1'b1;
        end
    end

    reg data_rready;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_rready <= 1'b1;
        end else if(dbus_rvalid) begin
            data_rready <= 1'b0;
        end else begin
            data_rready <= 1'b1;
        end
    end

    reg stallreq_mem;
    always @(posedge clk) begin
        if(!rst_n) begin
            stallreq_mem <= 1'b0;
        end else begin
            if((dbus_bvalid && dbus_bready) || (dbus_rvalid && dbus_rready) || state == WB) begin
                stallreq_mem <= 1'b0;
            end else if(ls_req || state == MEM) begin
                stallreq_mem <= 1'b1;
            end
        end
    end

    wire stallreq_ls_req = ls_req;
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

    assign O_ready = I_ready & ~stallreq;
    assign O_valid = O_ready;

    assign O_device_skip = I_ls_valid & (((I_memory_addr & ~32'h3) == `SERIAL_MMIO) | ((I_memory_addr & ~32'h7) == `RTC_MMIO));

    assign dbus_awaddr = I_memory_addr;

    assign dbus_wdata = wdata;
    assign dbus_wstrb = data_mask;

    assign dbus_bready = data_bready;

    assign dbus_araddr = I_memory_addr;

    assign dbus_rready = data_rready;

`ifndef LFSR
    assign dbus_awvalid = data_avalid & I_ls_type[`ls_diff_width-1];
    assign dbus_wvalid = data_avalid & I_ls_type[`ls_diff_width-1];
    assign dbus_arvalid = data_avalid & ~I_ls_type[`ls_diff_width-1];
`else
    reg avalid_r;
    wire [`RAMDOM_WIDTH-1:0] drandom;
    reg [`RAMDOM_WIDTH-1:0] drandom_r;
    reg req_flag;
    always @(posedge clk) begin
        if(!rst_n) begin
            avalid_r <= 1'b0;
            drandom_r <= 0;
            req_flag <= 1'b0;
        end else if(req_flag) begin
            drandom_r <= drandom_r - 1;
            if(drandom_r == 0) begin
                avalid_r <= 1'b1;
                req_flag <= 1'b0;
            end
        end else if(state == IDLE && data_avalid && !avalid_r) begin
            avalid_r <= 1'b0;
            drandom_r <= drandom;
            req_flag <= 1'b1;
        end else if((dbus_awvalid && dbus_awready) || (dbus_arvalid && dbus_arready)) begin
            avalid_r <= 1'b0;
        end
    end

    assign dbus_awvalid = avalid_r & I_ls_type[`ls_diff_width-1];
    assign dbus_wvalid = avalid_r & I_ls_type[`ls_diff_width-1];
    assign dbus_arvalid = avalid_r & ~I_ls_type[`ls_diff_width-1];

    lfsr #(
        .WIDTH                  (`RAMDOM_WIDTH              )      
    ) ilfsr_inst
    (
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .I_seed                 (`SEED2                     ),
        .O_random               (drandom                    )
    );
`endif


endmodule