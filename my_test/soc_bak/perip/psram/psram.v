module psram(
    input sck,
    input ce_n,
    inout [3:0] dio
);
    reg [31:0] data_out;
    reg [31:0] data_in;
    reg [7:0] cmd_in;
    reg [23:0] addr_in;
    reg [7:0] counter;

    reg qpi_mode;

    wire read = cmd_in == 8'heb;
    wire write = cmd_in == 8'h38;

    initial begin
        qpi_mode = 1'b0;
    end

    always @(posedge sck) begin
        if(counter == 8'd7 && {cmd_in[6:0], dio[0]} == 8'h35) begin
            qpi_mode <= 1'b1;
        end else if(counter == 8'd7 && {cmd_in[6:0], dio[0]} == 8'hf5) begin
            qpi_mode <= 1'b0;
        end
    end

    always @(posedge sck or posedge ce_n) begin
        if(ce_n) begin
            counter <= 8'b0;
        end else begin
            counter <= counter + 1;
        end
    end

import "DPI-C" function void psram_write(input int addr, input int data, input int len);

    always @(posedge sck or posedge ce_n) begin
        if(ce_n) begin
            cmd_in <= 8'b0;
            data_in <= 32'b0;
            addr_in <= 24'b0;
        end else if(qpi_mode) begin
            if(counter <= 8'h1) begin
                cmd_in <= {cmd_in[3:0], dio};
            end else if(read || write) begin
                if(counter <= 8'd7) begin
                    addr_in <= {addr_in[19:0], dio};
                end
                if(write && counter > 8'd7 && counter <= 8'd15) begin
                    if(counter <= 8'd9) begin
                        data_in <= {data_in[27:0], dio};
                        if(counter == 9) psram_write(addr_in, {data_in[27:0], dio}, 1);
                    end else if (counter <= 8'd11) begin
                        data_in <= {data_in[27:8], dio, data_in[7:0]};
                        if(counter == 11) psram_write(addr_in, {data_in[27:8], dio, data_in[7:0]}, 2);
                    end else if(counter<=8'd13) begin
                        data_in <= {data_in[27:16], dio, data_in[15:0]};
                    end else if(counter<=8'd15) begin
                        data_in <= {data_in[27:24], dio, data_in[23:0]};
                        if(counter == 15) psram_write(addr_in, {data_in[27:24], dio, data_in[23:0]}, 4);
                    end
                end
            end else begin
                $error("Error command %x, not ebh", cmd_in);
            end
        end else begin
            if(counter <= 8'h7) begin
                cmd_in <= {cmd_in[6:0], dio[0]};
            end else if(read || write) begin
                if(counter <= 8'd13) begin
                    addr_in <= {addr_in[19:0], dio};
                end
                if(write && counter > 8'd13 && counter <= 8'd21) begin
                    if(counter <= 8'd15) begin
                        data_in <= {data_in[27:0], dio};
                        if(counter == 15) psram_write(addr_in, {data_in[27:0], dio}, 1);
                    end else if (counter <= 8'd17) begin
                        data_in <= {data_in[27:8], dio, data_in[7:0]};
                        if(counter == 17) psram_write(addr_in, {data_in[27:8], dio, data_in[7:0]}, 2);
                    end else if(counter<=8'd19) begin
                        data_in <= {data_in[27:16], dio, data_in[15:0]};
                    end else if(counter<=8'd21) begin
                        data_in <= {data_in[27:24], dio, data_in[23:0]};
                        if(counter == 21) psram_write(addr_in, {data_in[27:24], dio, data_in[23:0]}, 4);
                    end
                end
            end else begin
                $error("Error command %x, not ebh", cmd_in);
            end
        end
    end

import "DPI-C" function void psram_read(input int addr, output int data);


    wire [1:0] byte_addr_qpi = {(counter-8'd14)>>1}[1:0];
    wire [1:0] byte_addr_spi = {(counter-8'd20)>>1}[1:0];

    always @(posedge sck or posedge ce_n) begin
        if(ce_n) begin
            data_out <= 32'b0;
        end else if(qpi_mode && read && counter == 8'd14) begin
            psram_read(addr_in | {22'b0, byte_addr_qpi}, data_out);
        end else if(!qpi_mode && read && counter == 8'd20) begin
            psram_read(addr_in | {22'b0, byte_addr_spi}, data_out);
        end
    end


    assign dio = ce_n ? 4'bz : 
                 qpi_mode ? 
                 counter == 8'd15 ? data_out[7:4]   :
                 counter == 8'd16 ? data_out[3:0]   :
                 counter == 8'd17 ? data_out[15:12] :
                 counter == 8'd18 ? data_out[11:8]  :
                 counter == 8'd19 ? data_out[23:20] :
                 counter == 8'd20 ? data_out[19:16] :
                 counter == 8'd21 ? data_out[31:28] :
                 counter == 8'd22 ? data_out[27:24] : 4'bz 
                 :
                 counter == 8'd21 ? data_out[7:4]   :
                 counter == 8'd22 ? data_out[3:0]   :
                 counter == 8'd23 ? data_out[15:12] :
                 counter == 8'd24 ? data_out[11:8]  :
                 counter == 8'd25 ? data_out[23:20] :
                 counter == 8'd26 ? data_out[19:16] :
                 counter == 8'd27 ? data_out[31:28] :
                 counter == 8'd28 ? data_out[27:24] : 4'bz;

//   assign dio = 4'bz; 

endmodule
