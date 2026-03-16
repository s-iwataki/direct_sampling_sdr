module spi_interface (
    input clock,
    input reset_n,
    
    // SPI interface
    input spi_sck,
    input spi_mosi,
    input spi_cs_n,
    output reg [7:0] spi_data_out,
    output reg spi_data_en
    );

reg [7:0]spi_shift_reg;
reg [2:0]bit_count;
reg[1:0] sck_edge_detector;

always @(posedge clock) begin
    if (!reset_n) begin
        spi_data_out <= 8'b0;
        spi_data_en <= 0;
        bit_count <= 0;
        spi_shift_reg <= 8'b0;
    end else begin
        if(spi_cs_n) begin
            bit_count <= 0;
            spi_data_en <= 0;
        end  else if(spi_data_en) begin
            spi_data_en <= 0;
            bit_count <= 0;
        end else begin
            sck_edge_detector <= {sck_edge_detector[0], spi_sck};
            if (sck_edge_detector == 2'b01) begin
                spi_shift_reg <= {spi_shift_reg[6:0], spi_mosi};
                bit_count <= bit_count + 1;
                if (bit_count == 7) begin
                spi_data_out <= spi_shift_reg;
                spi_data_en <= 1;
                end
            end 
        end

    end
end

endmodule
