// define this macro to enable fast behavior simulation
// for flash by skipping SPI transfers
// `define FAST_FLASH

module spi_top_apb #(
    parameter flash_addr_start = 32'h30000000,
    parameter flash_addr_end   = 32'h3fffffff,
    parameter spi_ss_num       = 8
)(
    input         clock,
    input         reset,
    input  [31:0] in_paddr,
    input         in_psel,
    input         in_penable,
    input  [2:0]  in_pprot,
    input         in_pwrite,
    input  [31:0] in_pwdata,
    input  [3:0]  in_pstrb,
    output        in_pready,
    output [31:0] in_prdata,
    output        in_pslverr,

    output                  spi_sck,
    output [spi_ss_num-1:0] spi_ss,
    output                  spi_mosi,
    input                   spi_miso,
    output                  spi_irq_out
);

`ifdef FAST_FLASH

    wire [31:0] data;
    parameter invalid_cmd = 8'h0;
    flash_cmd flash_cmd_i(
        .clock(clock),
        .valid(in_psel && !in_penable),
        .cmd(in_pwrite ? invalid_cmd : 8'h03),
        .addr({8'b0, in_paddr[23:2], 2'b0}),
        .data(data)
    );
    assign spi_sck    = 1'b0;
    assign spi_ss     = 8'b0;
    assign spi_mosi   = 1'b1;
    assign spi_irq_out= 1'b0;
    assign in_pslverr = 1'b0;
    assign in_pready  = in_penable && in_psel && !in_pwrite;
    assign in_prdata  = data[31:0];

`else

    parameter IDLE = 0;
    parameter SPI = 1;
    parameter XIP_DIVIDER = 2;
    parameter XIP_SLAVE_SELECT = 3;
    parameter XIP_CTRL_SET = 4;
    parameter XIP_CMD_ADDR = 5;
    parameter XIP_TRAN_START = 6;
    parameter XIP_TRAN_WAIT = 7;
    parameter XIP_READ_DATA = 8;

    reg [4:0] addr;
    reg sel;
    reg we;
    reg enable;
    reg [3:0] strb;
    reg [31:0] wdata;
    wire [31:0] rdata;
    wire ready;

    assign in_prdata = ((state == SPI) & ready)         ? rdata : 
                       (state == XIP_READ_DATA & ready) ? 
                       {rdata[7:0], rdata[15:8], rdata[23:16], rdata[31:24]} : 32'h0;
    assign in_pready = ((state == SPI) & ready) |
                        (state == XIP_READ_DATA & ready);


    reg [3:0] state, nstate;
    always @(posedge clock) begin
        if(reset) begin
            state <= IDLE;
        end else begin
            state <= nstate;
        end
    end

    always @(*) begin
        if(reset) begin
            addr = 0;
            sel = 0;
            we = 0;
            enable = 0;
            strb = 0;
            wdata = 0;
            nstate = IDLE;
        end else begin
            case(state)
                IDLE: begin
                    addr = 0;
                    sel = 0;
                    we = 0;
                    enable = 0;
                    strb = 0;
                    wdata = 0;
                    if(in_psel && in_penable) begin
                        nstate = (in_paddr[31:28] == 4'h3) ? XIP_DIVIDER : SPI;
                        if(nstate == XIP_DIVIDER) begin
                            if(in_pwrite) begin
                                $error("XIP access should be read-only");
                                nstate = IDLE;
                            end
                        end
                    end else begin
                        nstate = IDLE;
                    end
                end
                SPI: begin
                    addr = in_paddr[4:0];
                    sel = in_psel;
                    we = in_pwrite;
                    enable = in_penable;
                    strb = in_pstrb;
                    wdata = in_pwdata;
                    if(ready) begin
                        nstate = IDLE;
                    end else begin
                        nstate = SPI;
                    end
                end
                XIP_DIVIDER: begin
                    addr = 5'h14;
                    sel = 1;
                    we = 1;
                    enable = 1;
                    strb = 4'b1111;
                    wdata = 32'h4; //divisor set to 4
                    if(ready) begin
                        nstate = XIP_SLAVE_SELECT;
                    end else begin
                        nstate = XIP_DIVIDER;
                    end
                end
                XIP_SLAVE_SELECT: begin
                    addr = 5'h18;
                    sel = 1;
                    we = 1;
                    enable = 1;
                    strb = 4'b1111;
                    wdata = 32'h1; //select slave 0
                    if(ready) begin
                        nstate = XIP_CTRL_SET;
                    end else begin
                        nstate = XIP_SLAVE_SELECT;
                    end
                end
                XIP_CTRL_SET: begin
                    addr = 5'h10;
                    sel = 1;
                    we = 1;
                    enable = 1;
                    strb = 4'b1111;
                    wdata = 32'h3440; // ass, len64, tx_neg, busy=0, ie
                    if(ready) begin
                        nstate = XIP_CMD_ADDR;
                    end else begin
                        nstate = XIP_CTRL_SET;
                    end
                end
                XIP_CMD_ADDR: begin
                    addr = 5'h04;
                    sel = 1;
                    we = 1;
                    enable = 1;
                    strb = 4'b1111;
                    wdata = {8'h03, in_paddr[23:0]};
                    if(ready) begin
                        nstate = XIP_TRAN_START;
                    end else begin
                        nstate = XIP_CMD_ADDR;
                    end
                end
                XIP_TRAN_START: begin
                    addr = 5'h10;
                    sel = 1;
                    we = 1;
                    enable = 1;
                    strb = 4'b1111;
                    wdata = 32'h3540; // go busy
                    if(ready) begin
                        nstate = XIP_TRAN_WAIT;
                    end else begin
                        nstate = XIP_TRAN_START;
                    end
                end
                XIP_TRAN_WAIT: begin
                    addr = 5'h00;
                    sel = 0;
                    we = 0;
                    enable = 0;
                    strb = 4'b0000;
                    wdata = 32'h0; 
                    if(spi_irq_out) begin
                        nstate = XIP_READ_DATA;
                    end else begin
                        nstate = XIP_TRAN_WAIT;
                    end
                end
                XIP_READ_DATA: begin
                    addr = 5'h00;
                    sel = 1;
                    we = 0;
                    enable = 1;
                    strb = 4'b1111;
                    wdata = 32'h0;
                    if(ready) begin
                        nstate = IDLE;
                    end else begin
                        nstate = XIP_READ_DATA;
                    end
                end
                default: begin
                    addr = 0;
                    sel = 0;
                    we = 0;
                    enable = 0;
                    strb = 0;
                    wdata = 0;
                    nstate = IDLE;
                end
            endcase
        end
    end


    spi_top u0_spi_top (
        .wb_clk_i(clock),
        .wb_rst_i(reset),
        .wb_adr_i(addr),
        .wb_dat_i(wdata),
        .wb_dat_o(rdata),
        .wb_sel_i(strb),
        .wb_we_i (we),
        .wb_stb_i(sel),
        .wb_cyc_i(enable),
        .wb_ack_o(ready),
        .wb_err_o(in_pslverr),
        .wb_int_o(spi_irq_out),

        .ss_pad_o(spi_ss),
        .sclk_pad_o(spi_sck),
        .mosi_pad_o(spi_mosi),
        .miso_pad_i(spi_miso)
    );

`endif // FAST_FLASH

endmodule
