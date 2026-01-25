module direct_sampling_sdr(clock,reset_n, frequency,wav_in, wav_out,coeff_we,coeff_in,coeff_w_addr);
	input clock;
	input reset_n;
	input [26:0] frequency;
	input signed[13:0]wav_in;
	output signed [15:0] wav_out;
	input coeff_we;
	input signed[15:0]coeff_in;
	input [7:0]coeff_w_addr;
	wire signed[13:0]nco_sinout;
	wire signed[13:0]nco_cosout;
	wire signed[27:0]input_mul_sin;
	wire signed[27:0]input_mul_cos;
	wire signed[13:0]i_downconverted,q_downconverted;
	wire signed[17:0]i_decimated_16,q_decimated_16;
	//wire signed[21:0]i_decimated_256,q_decimated_256;
	wire signed[17:0]temp;
	
	wire timing_16clk,timing_256clk,timing_2560clk;
	
	nco #(27,14) nco_inst(clock,frequency,nco_sinout,nco_cosout);
	assign input_mul_sin = wav_in*nco_sinout;
	assign input_mul_cos = wav_in*nco_cosout;
	assign i_downconverted = input_mul_sin>>13;
	assign q_downconverted = input_mul_cos>>13;
	
	timing_generator tg(clock,reset_n,timing_16clk,timing_256clk,timing_2560clk);
	
	cic_decimator cic_downconv_i(clock,timing_16clk,i_downconverted,i_decimated_16);
	cic_decimator cic_downconv_q(clock,timing_16clk,q_downconverted,q_decimated_16);
	
	assign temp=(i_decimated_16+q_decimated_16)>>2;
	fir_decimator fir_d(clock,reset_n,temp[17:2],wav_out,timing_256clk,timing_2560clk,coeff_we,coeff_in,coeff_w_addr);

endmodule