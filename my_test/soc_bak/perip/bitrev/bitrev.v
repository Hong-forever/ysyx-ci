module bitrev (
    input  sck,
    input  ss,
    input  mosi,
    output reg miso
);
    reg [7:0] data;
    reg [3:0] rx_cnt, tx_cnt;
    reg flag;

    always @(posedge sck or posedge ss) begin
        if(ss) begin
            data <= 8'd0;
            rx_cnt <= 4'd0;
            flag <= 1'b0;
        end else if(rx_cnt < 4'd8) begin
            data <= {data[6:0], mosi};
            rx_cnt <= rx_cnt + 1;
            flag <= rx_cnt == 4'd7 ? 1'b1 : flag;
        end
    end

    always @(negedge sck or posedge ss) begin
        if(ss) begin
            miso <= 1'b1;
            tx_cnt <= 4'd0;
        end else if(flag && tx_cnt < 4'd8) begin
            miso <= data[tx_cnt[2:0]];
            tx_cnt <= tx_cnt + 1;
        end
    end


endmodule
