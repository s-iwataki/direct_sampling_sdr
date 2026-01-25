/* CIC decimator with input enable*/

module cic_decimator_with_input_sample(clock, input_enable,out_sample,in_signal,out_signal);
	parameter IN_SIGNAL_BITWIDTH = 18, OUT_SIGNAL_BITWIDTH = 22;
	input clock;
	input input_enable;
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
		if(input_enable) begin
			in_delay <= in_integral;
		end
		if(out_sample) begin
			sampled_sum <= in_integral;
			out_delay <= sampled_sum;
		end
	end
endmodule	
			
		