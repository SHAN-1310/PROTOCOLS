module spi_master (
    input        clk,
    input        reset,
    input        start,
    input [7:0]  tx_data,
    input        miso,

    output reg   sclk,
    output reg   mosi,
    output reg   cs,
    output reg [7:0] rx_data,
    output reg   busy,
    output reg   done
);

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;
    reg [3:0] bit_count;
    reg [7:0] clk_count;

    parameter CLK_DIV = 25;

    always @(posedge clk) begin

        if (reset) begin
            sclk      <= 1'b0;
            mosi      <= 1'b0;
            cs        <= 1'b1;
            rx_data   <= 8'b0;
            tx_shift  <= 8'b0;
            rx_shift  <= 8'b0;
            bit_count <= 4'd0;
            clk_count <= 8'd0;
            busy      <= 1'b0;
            done      <= 1'b0;
        end

        else begin

            done <= 1'b0;

            if (!busy) begin

                sclk <= 1'b0;
                cs   <= 1'b1;

                if (start) begin
                    busy      <= 1'b1;
                    cs        <= 1'b0;
                    tx_shift  <= tx_data;
                    rx_shift  <= 8'b0;
                    bit_count <= 4'd0;
                    clk_count <= 8'd0;
                    mosi      <= tx_data[7];
                end
            end

            else begin

                if (clk_count == CLK_DIV-1) begin

                    clk_count <= 8'd0;

                    if (sclk == 1'b0) begin
                        sclk <= 1'b1;
                        rx_shift <= {rx_shift[6:0], miso};
                    end

                    else begin
                        sclk <= 1'b0;

                        if (bit_count == 4'd7) begin
                            busy    <= 1'b0;
                            cs      <= 1'b1;
                            done    <= 1'b1;
                            rx_data <= rx_shift;
                            mosi    <= 1'b0;
                        end

                        else begin
                            bit_count <= bit_count + 1'b1;
                            tx_shift  <= {tx_shift[6:0], 1'b0};
                            mosi      <= tx_shift[6];
                        end
                    end
                end

                else begin
                    clk_count <= clk_count + 1'b1;
                end
            end
        end
    end

endmodule
