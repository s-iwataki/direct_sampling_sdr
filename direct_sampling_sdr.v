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
	wire signed[45:0]i_decimated,q_decimated;
	wire signed[15:0]i_decimated_2560,q_decimated_2560;
	wire signed[17:0]temp;
	
	wire timing_16clk,timing_256clk,timing_2560clk;
	
	nco #(27,14) nco_inst(clock,frequency,nco_sinout,nco_cosout);
	assign input_mul_sin = wav_in*nco_sinout;
	assign input_mul_cos = wav_in*nco_cosout;
	assign i_downconverted = input_mul_sin>>13;
	assign q_downconverted = input_mul_cos>>13;
	
	timing_generator tg(clock,reset_n,timing_16clk,timing_256clk,timing_2560clk);
	
	cic_decimator cic_downconv_i(clock,timing_256clk,i_downconverted,i_decimated);
	cic_decimator cic_downconv_q(clock,timing_256clk,q_downconverted,q_decimated);
	
	fir_decimator fir_d_i(clock,reset_n,i_decimated[45:30],i_decimated_2560,timing_256clk,timing_2560clk,coeff_we,coeff_in,coeff_w_addr);
	fir_decimator fir_d_q(clock,reset_n,q_decimated[45:30],q_decimated_2560,timing_256clk,timing_2560clk,coeff_we,coeff_in,coeff_w_addr);
	assign wav_out=(i_decimated_2560+q_decimated_2560)>>2;

endmodule