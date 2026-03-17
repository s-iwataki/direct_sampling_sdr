/* CIC decimator*/

module cic_decimator(clock, out_sample,in_signal,out_signal,out_sample_available);
	parameter IN_SIGNAL_BITWIDTH = 14, OUT_SIGNAL_BITWIDTH = 46;
	input clock;
	input out_sample;
	input signed [IN_SIGNAL_BITWIDTH-1:0] in_signal;
	output signed [OUT_SIGNAL_BITWIDTH-1:0] out_signal;
	output out_sample_available;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_1st;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_2nd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_3rd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_4th;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_1st;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_2nd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_3rd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] differential_stg_4th;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_1st;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_2nd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_3rd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] delay_stg_4th;
	reg timing_1st_stg,timing_2nd_stg,timing_3rd_stg,timing_4th_stg;
	assign out_signal=differential_stg_4th;
	assign out_sample_available=timing_4th_stg;
	
	always @ (posedge clock) begin
		integral_stg_1st<=integral_stg_1st+in_signal;
		integral_stg_2nd<=integral_stg_2nd+integral_stg_1st;
		integral_stg_3rd<=integral_stg_3rd+integral_stg_2nd;
		integral_stg_4th<=integral_stg_4th+integral_stg_3rd;
		timing_1st_stg<=out_sample;
		timing_2nd_stg<=timing_1st_stg;
		timing_3rd_stg<=timing_2nd_stg;
		timing_4th_stg<=timing_3rd_stg;
		if(out_sample) begin
			delay_stg_1st<=integral_stg_4th;
			differential_stg_1st<=integral_stg_4th-delay_stg_1st;
		end
		if(timing_1st_stg)begin
			delay_stg_2nd<=differential_stg_1st;
			differential_stg_2nd<=differential_stg_1st-delay_stg_2nd;
		end
		if(timing_2nd_stg)begin
			delay_stg_3rd<=differential_stg_2nd;
			differential_stg_3rd<=differential_stg_2nd-delay_stg_3rd;
		end
		if(timing_3rd_stg)begin
			delay_stg_4th<=differential_stg_3rd;
			differential_stg_4th<=differential_stg_3rd-delay_stg_4th;
		end
	end
	
endmodule
			
		