/* CIC decimator*/

module cic_decimator(clock, out_sample,in_signal,out_signal);
	parameter IN_SIGNAL_BITWIDTH = 14, OUT_SIGNAL_BITWIDTH = 18;
	input clock;
	input out_sample;
	input signed [IN_SIGNAL_BITWIDTH-1:0] in_signal;
	output signed [OUT_SIGNAL_BITWIDTH-1:0] out_signal;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] in_delay;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] out_delay;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] sampled_sum;
	wire signed [OUT_SIGNAL_BITWIDTH-1:0] in_integral;
	assign in_integral = in_signal+in_delay;
	assign out_signal = sampled_sum-out_delay;
	
	always @ (posedge clock) begin
		in_delay <= in_integral;
		if(out_sample) begin
			sampled_sum <= in_integral;
			out_delay <= sampled_sum;
		end
	end
	
endmodule
			
		