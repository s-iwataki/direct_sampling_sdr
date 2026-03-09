module i2s_timing_generator (
    input clock,
    input reset_n,
    
    // I2S interface
    output reg i2s_bit_clk,
    output reg i2s_ws
);
// clockは122.88MHz、I2Sbit clockは16bit 48kHz stereoで1.536MHz(80分周)、word selectは48kHzなので、bit clockはclockの40分周、word selectはclockの2560分周となる。
//dutyは50%で、word selectはcounter_128が127のときにcounter_10をインクリメントし、counter_10が9のときにword selectをトグルする。
    reg[7:0] counter_128;//128分周用
	reg[3:0] counter_10;//1280分周用
    reg[6:0] counter_40;

    always@ (posedge clock) begin
        if (!reset_n) begin
            i2s_bit_clk <= 0;
            i2s_ws <= 0;
            counter_128 <= 0;
            counter_10 <= 0;
            counter_40 <= 0;
        end else begin
            counter_128 <= counter_128 + 1;
            counter_40 <= counter_40 + 1;
            if (counter_40 == 39) begin
                counter_40 <= 0;
                i2s_bit_clk <= ~i2s_bit_clk; // Toggle bit clock every 40 counts of counter_40, frequency is clock/80=122.88/80=1.536MHz
            end
            if (counter_128 == 8'b11111111) begin
                counter_128 <= 0;
                if (counter_10 == 9) begin
                    counter_10 <= 0;
                    i2s_ws <= ~i2s_ws; // Toggle word select every 10 counts of counter_10
                end else begin
                    counter_10 <= counter_10 + 1;
                end
            end
        end
    end
endmodule