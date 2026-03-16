module direct_sampling_sdr(clock,reset_n,wav_in, wav_out,i2s_ws_out,i2s_clk_out,i2s_dataout,i2s_datain,spi_cs_n,spi_clk,spi_datain);
	input clock;
	input reset_n;
	input signed[13:0]wav_in;
	output reg signed [13:0] wav_out;
	input spi_clk,spi_cs_n,spi_datain,i2s_datain;
	output i2s_ws_out,i2s_clk_out,i2s_dataout;


	//NCO wires
	wire [26:0]frequency;
	wire signed[13:0]nco_sinout;
	wire signed[13:0]nco_cosout;
	//RX path wires
	wire signed[27:0]input_mul_sin;
	wire signed[27:0]input_mul_cos;
	wire signed[13:0]i_downconverted,q_downconverted;
	wire signed[45:0]i_decimated,q_decimated;
	wire signed[15:0]i_decimated_2560,q_decimated_2560;
	//TX path wires
	wire signed [15:0]tx_i_signal,tx_q_signal;
	wire signed [15:0]tx_i_fir_interpolated,tx_q_fir_interpolated;
	wire signed [45:0]tx_i_cic_interpolated,tx_q_cic_interpolated;
	wire signed[27:0]tx_mul_sin;
	wire signed[27:0]tx_mul_cos;
	wire tx_sample_available;

	//RX fir decimator control wires
	wire rx_fir_i_data_we,rx_fir_q_data_we;
	//TX fir interpolator control wires
	wire tx_fir_i_data_we,tx_fir_q_data_we;
	//coeff data and address wires for both RX and TX FIR filters.
	wire [7:0]coeff_w_addr;
	wire signed [15:0]coeff_in;

	wire rx_reset_n,tx_reset_n;
	wire [15:0]rx_gain;

	//i2s interface wires
	wire i2s_ws,i2s_clk;
	assign i2s_ws_out = i2s_ws;
	assign i2s_clk_out = i2s_clk;
	//timing generator wires
	wire timing_16clk,timing_256clk,timing_2560clk;

	//spi interface wires
	wire spi_data_en;
	wire [7:0]spi_data_out;
	
	nco #(27,14) nco_inst(clock,frequency,nco_sinout,nco_cosout);
	assign input_mul_sin = wav_in*nco_sinout;
	assign input_mul_cos = wav_in*nco_cosout;
	assign i_downconverted = input_mul_sin>>13;
	assign q_downconverted = input_mul_cos>>13;
	
	timing_generator tg(clock,reset_n,timing_16clk,timing_256clk,timing_2560clk);
	
	cic_decimator cic_downconv_i(clock,timing_256clk,i_downconverted,i_decimated);
	cic_decimator cic_downconv_q(clock,timing_256clk,q_downconverted,q_decimated);
	
	fir_decimator fir_d_i(clock,reset_n,i_decimated[45:30],i_decimated_2560,timing_256clk,timing_2560clk,rx_fir_i_data_we,coeff_in,coeff_w_addr);
	fir_decimator fir_d_q(clock,reset_n,q_decimated[45:30],q_decimated_2560,timing_256clk,timing_2560clk,rx_fir_q_data_we,coeff_in,coeff_w_addr);
	
	i2s_timing_generator i2s_tg(clock,reset_n,i2s_clk,i2s_ws);
	i2s_interface i2s_if(clock,reset_n,i2s_clk,i2s_ws,i2s_dataout,i2s_datain,tx_i_signal,tx_q_signal,tx_sample_available,i_decimated_2560,q_decimated_2560,timing_2560clk);

	spi_interface spi_if(clock,reset_n,spi_clk,spi_datain,spi_cs_n,spi_data_out,spi_data_en);
	control_registers ctrl_reg(clock,reset_n,spi_cs_n,spi_data_out,spi_data_en,coeff_in,coeff_w_addr,tx_fir_i_data_we,tx_fir_q_data_we,rx_fir_i_data_we,rx_fir_q_data_we,rx_gain,rx_reset_n,tx_reset_n,frequency);

	fir_interpolator fir_i_i(clock,reset_n,tx_i_signal,tx_i_fir_interpolated,timing_256clk,tx_sample_available,tx_fir_i_data_we,coeff_in,coeff_w_addr);
	fir_interpolator fir_i_q(clock,reset_n,tx_q_signal,tx_q_fir_interpolated,timing_256clk,tx_sample_available,tx_fir_q_data_we,coeff_in,coeff_w_addr);

	cic_interpolator cic_i_i(clock,timing_256clk,tx_i_fir_interpolated,tx_i_cic_interpolated);
	cic_interpolator cic_i_q(clock,timing_256clk,tx_q_fir_interpolated,tx_q_cic_interpolated);

	assign tx_mul_sin = tx_i_cic_interpolated[45:32]*nco_sinout;
	assign tx_mul_cos = tx_q_cic_interpolated[45:32]*nco_cosout;
	always @(posedge clock) begin
		wav_out<=(tx_mul_sin+tx_mul_cos)>>13;
	end

endmodule