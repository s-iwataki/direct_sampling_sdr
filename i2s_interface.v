module i2s_interface (
    input clock,
    input reset_n,
    
    // I2S interface
    input i2s_bit_clk,
    input i2s_ws,
    input i2s_sd_in,
    output reg i2s_sd_out,
    
    // Control signals
    output reg [15:0] i2s_rx_data_lch_out,
    output reg [15:0] i2s_rx_data_rch_out,
    output i2s_rx_data_valid,
    input [15:0] i2s_tx_data_lch_in,
    input [15:0] i2s_tx_data_rch_in,
    input i2s_tx_data_valid
);
reg [31:0] i2s_rx_shift_reg;//LR packed 16 bits each
reg [31:0] i2s_tx_shift_reg[0:1];//LR packed 16 bits each. dual buffer for holding next frame while transmitting current frame.
reg[31:0] i2s_tx_buffer;
reg i2s_tx_buffer_select;
reg [1:0]bit_clk_edge_detector;
reg [1:0] ws_edge_detector;

assign i2s_rx_data_valid = (bit_clk_edge_detector == 2'b10) && (ws_edge_detector == 2'b10); // Valid data on falling edge of bit clock when word select falls

always @(posedge clock) begin
    if(!reset_n) begin
        i2s_rx_shift_reg <= 0;
        i2s_rx_data_valid <= 0;
        i2s_tx_shift_reg[0] <= 0;
        i2s_tx_shift_reg[1] <= 0;
        i2s_tx_buffer_select <= 0;
        bit_clk_edge_detector <= 0;
        ws_edge_detector <= 0;
    end else begin
        // Edge detection for I2S bit clock and word select
        bit_clk_edge_detector <= {bit_clk_edge_detector[0], i2s_bit_clk};
        // I2S receive logic
        if (bit_clk_edge_detector == 2'b01) begin // Rising edge of bit clock
            ws_edge_detector <= {ws_edge_detector[0], i2s_ws};//WS sample on rising edge of bit clock, so detect WS edge on same clock edge
            i2s_rx_shift_reg <= {i2s_rx_shift_reg[30:0], i2s_sd_in}; // Shift in data
            if({ws_edge_detector[0], i2s_ws} == 2'b10) begin
                 if (!i2s_tx_buffer_select) begin
                    i2s_tx_shift_reg[1] <= i2s_tx_buffer; // Load new data into buffer
                    i2s_tx_buffer_select <= 1; // Select next buffer for transmission
                end else begin
                    i2s_tx_shift_reg[0] <= i2s_tx_buffer; // Load new data into current buffer if next buffer is still selected
                    i2s_tx_buffer_select <= 0; // Keep current buffer selected for transmission
                end 
            end

        end else if (bit_clk_edge_detector == 2'b10) begin // Falling edge of bit clock
            if (ws_edge_detector == 2'b10) begin // Fall edge of word select indicates new frame
                i2s_rx_data_lch_out <= i2s_rx_shift_reg[31:16]; // Output left channel data
                i2s_rx_data_rch_out <= i2s_rx_shift_reg[15:0]; // Output right channel data
            end
        //output data shift out on falling edge of bit clock to meet I2S timing requirements
            if (i2s_tx_buffer_select) begin
                i2s_sd_out <= i2s_tx_shift_reg[1][31]; // Output MSB of selected buffer
                i2s_tx_shift_reg[1] <= {i2s_tx_shift_reg[1][30:0], 1'b0}; // Shift left
            end else begin
                i2s_sd_out <= i2s_tx_shift_reg[0][31]; // Output MSB of current buffer
                i2s_tx_shift_reg[0] <= {i2s_tx_shift_reg[0][30:0], 1'b0}; // Shift left
            end
            
        end
        if(i2s_tx_data_valid)begin
            i2s_tx_buffer<= {i2s_tx_data_lch_in, i2s_tx_data_rch_in};
        end
       
        
    end
    
end

endmodule