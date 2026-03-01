`ifdef __ICARUS__

`timescale 1ns / 1ps
module top
(
    input         clock,
    input         reset
);

    //cpu core
    wire        cpu_awvalid;
    wire        cpu_awready;
    wire [31:0] cpu_awaddr;
    wire [3:0 ] cpu_awid;
    wire [7:0 ] cpu_awlen;
    wire [2:0 ] cpu_awsize;
    wire [1:0 ] cpu_awburst;
    wire        cpu_wvalid;
    wire        cpu_wready;
    wire [31:0] cpu_wdata;
    wire [3:0 ] cpu_wstrb;
    wire        cpu_wlast;
    wire        cpu_bvalid;
    wire        cpu_bready;
    wire [1:0]  cpu_bresp;
    wire [3:0 ] cpu_bid;
    wire        cpu_arvalid;
    wire        cpu_arready;
    wire [31:0] cpu_araddr;
    wire [3:0 ] cpu_arid;
    wire [7:0 ] cpu_arlen;
    wire [2:0 ] cpu_arsize;
    wire [1:0 ] cpu_arburst;
    wire        cpu_rvalid;
    wire        cpu_rready;
    wire [31:0] cpu_rdata;
    wire [1:0]  cpu_rresp;
    wire        cpu_rlast;
    wire [3:0 ] cpu_rid;

    wire        s0_awvalid;
    wire        s0_awready;
    wire [31:0] s0_awaddr;
    wire [3:0 ] s0_awid;
    wire [7:0 ] s0_awlen;
    wire [2:0 ] s0_awsize;
    wire [1:0 ] s0_awburst;
    wire        s0_wvalid;
    wire        s0_wready;
    wire [31:0] s0_wdata;
    wire [3:0 ] s0_wstrb;
    wire        s0_wlast;
    wire        s0_bvalid;
    wire        s0_bready;
    wire [1:0]  s0_bresp;
    wire [3:0 ] s0_bid;
    wire        s0_arvalid;
    wire        s0_arready;
    wire [31:0] s0_araddr;
    wire [3:0 ] s0_arid;
    wire [7:0 ] s0_arlen;
    wire [2:0 ] s0_arsize;
    wire [1:0 ] s0_arburst;
    wire        s0_rvalid;
    wire        s0_rready;
    wire [31:0] s0_rdata;
    wire [1:0]  s0_rresp;
    wire        s0_rlast;
    wire [3:0 ] s0_rid;

    wire        s1_awvalid;
    wire        s1_awready;
    wire [31:0] s1_awaddr;
    wire [3:0 ] s1_awid;
    wire [7:0 ] s1_awlen;
    wire [2:0 ] s1_awsize;
    wire [1:0 ] s1_awburst;
    wire        s1_wvalid;
    wire        s1_wready;
    wire [31:0] s1_wdata;
    wire [3:0 ] s1_wstrb;
    wire        s1_wlast;
    wire        s1_bvalid;
    wire        s1_bready;
    wire [1:0]  s1_bresp;
    wire [3:0 ] s1_bid;
    wire        s1_arvalid;
    wire        s1_arready;
    wire [31:0] s1_araddr;
    wire [3:0 ] s1_arid;
    wire [7:0 ] s1_arlen;
    wire [2:0 ] s1_arsize;
    wire [1:0 ] s1_arburst;
    wire        s1_rvalid;
    wire        s1_rready;
    wire [31:0] s1_rdata;
    wire [1:0]  s1_rresp;
    wire        s1_rlast;
    wire [3:0 ] s1_rid;

    ysyx_25110270 ysyx_25110270(
        .clock(clock),
        .reset(reset),
        .io_interrupt(1'b0),
        .io_master_awvalid(cpu_awvalid),
        .io_master_awready(cpu_awready),
        .io_master_awid(cpu_awid),
        .io_master_awaddr(cpu_awaddr),
        .io_master_awlen(cpu_awlen),
        .io_master_awsize(cpu_awsize),
        .io_master_awburst(cpu_awburst),
        .io_master_wvalid(cpu_wvalid),
        .io_master_wready(cpu_wready),
        .io_master_wdata(cpu_wdata),
        .io_master_wstrb(cpu_wstrb),
        .io_master_wlast(cpu_wlast),
        .io_master_bvalid(cpu_bvalid),
        .io_master_bready(cpu_bready),
        .io_master_bid(cpu_bid),
        .io_master_bresp(cpu_bresp),
        .io_master_arvalid(cpu_arvalid),
        .io_master_arready(cpu_arready),
        .io_master_arid(cpu_arid),
        .io_master_araddr(cpu_araddr),
        .io_master_arlen(cpu_arlen),
        .io_master_arsize(cpu_arsize),
        .io_master_arburst(cpu_arburst),
        .io_master_rvalid(cpu_rvalid),
        .io_master_rready(cpu_rready),
        .io_master_rid(cpu_rid),
        .io_master_rdata(cpu_rdata),
        .io_master_rresp(cpu_rresp),
        .io_master_rlast(cpu_rlast),

        .io_slave_awvalid(1'b0),
        .io_slave_awready(),
        .io_slave_awaddr(32'b0),
        .io_slave_awid(4'b0),
        .io_slave_awlen(8'b0),
        .io_slave_awsize(3'b0),
        .io_slave_awburst(2'b0),
        .io_slave_wvalid(1'b0),
        .io_slave_wready(),
        .io_slave_wdata(32'b0),
        .io_slave_wstrb(4'b0),
        .io_slave_wlast(1'b0),
        .io_slave_bvalid(),
        .io_slave_bready(1'b0),
        .io_slave_bresp(),
        .io_slave_bid(),
        .io_slave_arvalid(1'b0),
        .io_slave_arready(),
        .io_slave_araddr(32'b0),
        .io_slave_arid(4'b0),
        .io_slave_arlen(8'b0),
        .io_slave_arsize(3'b0),
        .io_slave_arburst(2'b0),
        .io_slave_rvalid(),
        .io_slave_rready(1'b0),
        .io_slave_rid(),
        .io_slave_rdata(),
        .io_slave_rresp(),
        .io_slave_rlast()
    );


    mem
    #(
        .MEM_DEPTH(32'h0800_0000/4)
    ) mem_test
    (
        .clk(clock),
        .rst(reset),
        .awvalid_i(s0_awvalid),
        .awready_o(s0_awready),
        .awaddr_i(s0_awaddr),
        .awid_i(s0_awid),
        .awlen_i(s0_awlen),
        .awsize_i(s0_awsize),
        .awburst_i(s0_awburst),
        .wvalid_i(s0_wvalid),
        .wready_o(s0_wready),
        .wdata_i(s0_wdata),
        .wstrb_i(s0_wstrb),
        .wlast_i(s0_wlast),
        .bvalid_o(s0_bvalid),
        .bready_i(s0_bready),
        .bresp_o(s0_bresp),
        .bid_o(s0_bid),
        .arvalid_i(s0_arvalid),
        .arready_o(s0_arready),
        .araddr_i(s0_araddr),
        .arid_i(s0_arid),
        .arlen_i(s0_arlen),
        .arsize_i(s0_arsize),
        .arburst_i(s0_arburst),
        .rvalid_o(s0_rvalid),
        .rready_i(s0_rready),
        .rdata_o(s0_rdata),
        .rresp_o(s0_rresp),
        .rlast_o(s0_rlast),
        .rid_o(s0_rid)
    );

    uart uart_test(
        .clk(clock),
        .rst(reset),
        .awvalid_i(s1_awvalid),
        .awready_o(s1_awready),
        .awaddr_i(s1_awaddr),
        .awid_i(s1_awid),
        .awlen_i(s1_awlen),
        .awsize_i(s1_awsize),
        .awburst_i(s1_awburst),
        .wvalid_i(s1_wvalid),
        .wready_o(s1_wready),
        .wdata_i(s1_wdata),
        .wstrb_i(s1_wstrb),
        .wlast_i(s1_wlast),
        .bvalid_o(s1_bvalid),
        .bready_i(s1_bready),
        .bresp_o(s1_bresp),
        .bid_o(s1_bid),
        .arvalid_i(s1_arvalid),
        .arready_o(s1_arready),
        .araddr_i(s1_araddr),
        .arid_i(s1_arid),
        .arlen_i(s1_arlen),
        .arsize_i(s1_arsize),
        .arburst_i(s1_arburst),
        .rvalid_o(s1_rvalid),
        .rready_i(s1_rready),
        .rdata_o(s1_rdata),
        .rresp_o(s1_rresp),
        .rlast_o(s1_rlast),
        .rid_o(s1_rid)
    );


    ysyx_25110270_xbar
    #(
        .S0_BASE(32'h8000_0000),
        .S0_SIZE(32'h0800_0000)
    ) xbar_test
    (
        .clk(clock),
        .rst(reset),

        .S_arvalid(cpu_arvalid),
        .S_arready(cpu_arready),
        .S_arid(cpu_arid),
        .S_araddr(cpu_araddr),
        .S_arlen(cpu_arlen),
        .S_arsize(cpu_arsize),
        .S_arburst(cpu_arburst),
        .S_rready(cpu_rready),
        .S_rvalid(cpu_rvalid),
        .S_rid(cpu_rid),
        .S_rdata(cpu_rdata),
        .S_rresp(cpu_rresp),
        .S_rlast(cpu_rlast),
        .S_awvalid(cpu_awvalid),
        .S_awready(cpu_awready),
        .S_awid(cpu_awid),
        .S_awaddr(cpu_awaddr),
        .S_awlen(cpu_awlen),
        .S_awsize(cpu_awsize),
        .S_awburst(cpu_awburst),
        .S_wvalid(cpu_wvalid),
        .S_wready(cpu_wready),
        .S_wdata(cpu_wdata),
        .S_wstrb(cpu_wstrb),
        .S_wlast(cpu_wlast),
        .S_bready(cpu_bready),
        .S_bvalid(cpu_bvalid),
        .S_bid(cpu_bid),
        .S_bresp(cpu_bresp),

        .M0_awvalid(s0_awvalid),
        .M0_awready(s0_awready),
        .M0_awid(s0_awid),
        .M0_awaddr(s0_awaddr),
        .M0_awlen(s0_awlen),
        .M0_awsize(s0_awsize),
        .M0_awburst(s0_awburst),
        .M0_wvalid(s0_wvalid),
        .M0_wready(s0_wready),
        .M0_wdata(s0_wdata),
        .M0_wstrb(s0_wstrb),
        .M0_wlast(s0_wlast),
        .M0_bvalid(s0_bvalid),
        .M0_bready(s0_bready),
        .M0_bresp(s0_bresp),
        .M0_bid(s0_bid),
        .M0_arvalid(s0_arvalid),
        .M0_arready(s0_arready),
        .M0_arid(s0_arid),
        .M0_araddr(s0_araddr),
        .M0_arlen(s0_arlen),
        .M0_arsize(s0_arsize),
        .M0_arburst(s0_arburst),
        .M0_rvalid(s0_rvalid),
        .M0_rready(s0_rready),
        .M0_rid(s0_rid),
        .M0_rdata(s0_rdata),
        .M0_rresp(s0_rresp),
        .M0_rlast(s0_rlast),

        .M1_awvalid(s1_awvalid),
        .M1_awready(s1_awready),
        .M1_awid(s1_awid),
        .M1_awaddr(s1_awaddr),
        .M1_awlen(s1_awlen),
        .M1_awsize(s1_awsize),
        .M1_awburst(s1_awburst),
        .M1_wvalid(s1_wvalid),
        .M1_wready(s1_wready),
        .M1_wdata(s1_wdata),
        .M1_wstrb(s1_wstrb),
        .M1_wlast(s1_wlast),
        .M1_bvalid(s1_bvalid),
        .M1_bready(s1_bready),
        .M1_bresp(s1_bresp),
        .M1_bid(s1_bid),
        .M1_arvalid(s1_arvalid),
        .M1_arready(s1_arready),
        .M1_arid(s1_arid),
        .M1_araddr(s1_araddr),
        .M1_arlen(s1_arlen),
        .M1_arsize(s1_arsize),
        .M1_arburst(s1_arburst),
        .M1_rvalid(s1_rvalid),
        .M1_rready(s1_rready),
        .M1_rid(s1_rid),
        .M1_rdata(s1_rdata),
        .M1_rresp(s1_rresp),
        .M1_rlast(s1_rlast)
    );

endmodule

`endif