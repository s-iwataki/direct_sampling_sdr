/* CIC interpolator*/

module cic_interpolator(clock, in_sample,in_signal,out_signal);
	parameter IN_SIGNAL_BITWIDTH = 16, OUT_SIGNAL_BITWIDTH = 48;
	input clock;
	input in_sample;
	input signed [IN_SIGNAL_BITWIDTH-1:0] in_signal;
	output reg signed [OUT_SIGNAL_BITWIDTH-1:0] out_signal;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_1st;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_2nd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_3rd;
	reg signed [OUT_SIGNAL_BITWIDTH-1:0] integral_stg_4th;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] differential_stg_1st;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] differential_stg_2nd;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] differential_stg_3rd;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] differential_stg_4th;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] delay_stg_1st;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] delay_stg_2nd;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] delay_stg_3rd;
	reg signed [IN_SIGNAL_BITWIDTH-1:0] delay_stg_4th;
	reg timing_1st_stg,timing_2nd_stg,timing_3rd_stg,timing_4th_stg;
	wire signed [IN_SIGNAL_BITWIDTH-1:0] zero_inserted_signal;
    assign zero_inserted_signal=timing_4th_stg? differential_stg_4th: 0;//If in_sample is low, feed 0 to integrator stages to create interpolated samples.
	
	always @ (posedge clock) begin
		integral_stg_1st<=integral_stg_1st+zero_inserted_signal;
		integral_stg_2nd<=integral_stg_2nd+integral_stg_1st;
		integral_stg_3rd<=integral_stg_3rd+integral_stg_2nd;
		integral_stg_4th<=integral_stg_4th+integral_stg_3rd;
        out_signal<=integral_stg_4th;
		timing_1st_stg<=in_sample;
		timing_2nd_stg<=timing_1st_stg;
		timing_3rd_stg<=timing_2nd_stg;
		timing_4th_stg<=timing_3rd_stg;
		if(in_sample) begin
			delay_stg_1st<=in_signal;
			differential_stg_1st<=in_signal-delay_stg_1st;
		end
		if(timing_1st_stg) begin
			delay_stg_2nd<=differential_stg_1st;
			differential_stg_2nd<=differential_stg_1st-delay_stg_2nd;
		end
		if(timing_2nd_stg) begin
			delay_stg_3rd<=differential_stg_2nd;
			differential_stg_3rd<=differential_stg_2nd-delay_stg_3rd;
		end
		if(timing_3rd_stg) begin
			delay_stg_4th<=differential_stg_3rd;
			differential_stg_4th<=differential_stg_3rd-delay_stg_4th;
		end
	end
	
endmodule
			
		