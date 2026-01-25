/*timing generator */

module timing_generator(clock,reset_n,ck_div_by_16,ck_div_by_256,ck_div_by_2560);
	input clock,reset_n;
	output ck_div_by_16,ck_div_by_256,ck_div_by_2560;
	reg[7:0] counter_256;
	reg[3:0] counter_10;//2560分周用
	
	assign ck_div_by_16 = (counter_256&8'b00001111)==8'b00001111;
	assign ck_div_by_256 = counter_256==8'b11111111;
	assign ck_div_by_2560 = (counter_10==9)&&(ck_div_by_256);
	
	always @ (posedge clock) begin
		if (!reset_n) begin
			counter_256 <= 0;
			counter_10 <= 0;
		end else begin
			counter_256 <= counter_256+1;
			if(counter_10==9) begin
				counter_10 <= 0;
			end else if(counter_256 == 8'b11111111) begin
				counter_10 <= counter_10+1;
			end
		end
	end
endmodule
