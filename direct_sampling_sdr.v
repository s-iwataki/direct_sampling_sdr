module direct_sampling_sdr(clock, frequency, wav_out);
	input clock;
	input [26:0] frequency;
	output [13:0] wav_out;
	wire [13:0]dummy;
	
	nco #(27,14) nco_inst(clock,frequency,wav_out,dummy);

endmodule