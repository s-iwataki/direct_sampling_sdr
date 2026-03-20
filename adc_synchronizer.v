module adc_synchornizer (
    input sysclock,
    input adc_clock,
    input reset_n,
    input signed [13:0] adc_data_in,
    output reg signed [13:0] adc_data_out
);
    reg adc_read_en;
    wire [2:0] fifo_rdusedw;
    wire [13:0] fifo_q;

    adc_sync_fifo adc_fifo (
        .data(adc_data_in),
        .rdclk(sysclock),
        .rdreq(adc_read_en), // Always read from FIFO
        .wrclk(adc_clock),
        .wrreq(1'b1), // Always write to FIFO
        .q(fifo_q),
        .rdusedw(fifo_rdusedw),
        .wrfull()
    );
    // Simple control logic to read from FIFO when data is available
    //sysclock and adc_clock is same frequency but phase is different, so we can just check if there are enough samples in FIFO to read without underflow.
    always @(posedge sysclock) begin
        if (!reset_n) begin
            adc_read_en <= 1'b0;
            adc_data_out <= 14'b0;
        end else begin
            if (fifo_rdusedw[2]) begin//half full, there are at least 4 samples in FIFO, safe to read
                adc_read_en <= 1'b1;
            end
            if(adc_read_en) begin
                adc_data_out <= fifo_q;
            end else begin
                adc_data_out <= adc_data_out; // Hold the last value if not reading new data
            end
        end
    end

endmodule