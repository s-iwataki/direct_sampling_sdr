/* CIC decimator*/

module cic_decimator(clock, out_sample,in_signal,out_signal);
	parameter IN_SIGNAL_BITWIDTH = 14, OUT_SIGNAL_BITWIDTH = 46;
	input clock;
	input out_sample;
	input signed [IN_SIGNAL_BITWIDTH-1:0] in_signal;
	output signed [OUT_SIGNAL_BITWIDTH-1:0] out_signal;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_1st;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_2nd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_3rd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_4th;
	wire signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_1st;
	wire signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_2nd;
	wire signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_3rd;
	wire signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_4th;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_1st;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_2nd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_3rd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_4th;
	assign differential_stg_1st=integral_stg_4th-delay_stg_1st;
	assign differential_stg_2nd=differential_stg_1st-delay_stg_2nd;
	assign differential_stg_3rd=differential_stg_2nd-delay_stg_3rd;
	assign differential_stg_4th=differential_stg_3rd-delay_stg_4th;
	assign out_signal=differential_stg_4th;
	
	always @ (posedge clock) begin
		integral_stg_1st<=integral_stg_1st+in_signal;
		integral_stg_2nd<=integral_stg_2nd+integral_stg_1st;
		integral_stg_3rd<=integral_stg_3rd+integral_stg_2nd;
		integral_stg_4th<=integral_stg_4th+integral_stg_3rd;
		if(out_sample) begin
			delay_stg_1st<=integral_stg_4th;
			delay_stg_2nd<=differential_stg_1st;
			delay_stg_3rd<=differential_stg_2nd;
			delay_stg_4th<=differential_stg_3rd;
		end
	end
	
endmodule
			
		