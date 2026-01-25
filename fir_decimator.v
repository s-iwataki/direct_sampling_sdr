/*fir decimator*/

module fir_decimator(clock,reset_n,signal_in,signal_out,input_sample_clk,decimation_clk,coeff_we,coeff_in,coeff_w_addr);
	parameter SIGNAL_BITWIDTH = 16, NMAX_TAPS =256;
	input clock,reset_n,input_sample_clk,decimation_clk,coeff_we;
	input signed [SIGNAL_BITWIDTH-1:0] signal_in,coeff_in;
	input [7:0]coeff_w_addr;
	output signed [SIGNAL_BITWIDTH-1:0] signal_out;
	reg signed [SIGNAL_BITWIDTH-1:0] signal_mem [0:NMAX_TAPS-1];
	reg signed [SIGNAL_BITWIDTH-1:0] tap_coeffs [0:NMAX_TAPS-1];
	reg signed [SIGNAL_BITWIDTH-1:0] signal_mem_out;
	reg signed [SIGNAL_BITWIDTH-1:0] tap_coeffs_out;
	reg [7:0] tap_address_counter;
	reg [7:0] sigmem_addr_counter;
	reg [7:0] sigmem_read_addr;
	reg signed [2*SIGNAL_BITWIDTH-1:0] fir_accumlator;
	reg signed [2*SIGNAL_BITWIDTH-1:0] mult_result;
	reg signed [SIGNAL_BITWIDTH-1:0] output_sampler;
	wire[7:0] signal_mem_read_addr;
	assign signal_mem_read_addr=sigmem_addr_counter-tap_address_counter;
	assign signal_out=output_sampler;
	
	always @(posedge clock) begin
		if(!reset_n) begin
			tap_address_counter<=0;
			sigmem_addr_counter<=0;
			fir_accumlator<=0;
			output_sampler<=0;
		end else begin
			tap_address_counter<=tap_address_counter+1;
			sigmem_read_addr<=signal_mem_read_addr;
			signal_mem_out<=signal_mem[sigmem_read_addr];
			tap_coeffs_out<=tap_coeffs[tap_address_counter];
			mult_result<=signal_mem_out*tap_coeffs_out;
			if(input_sample_clk) begin
				sigmem_addr_counter<=sigmem_addr_counter+1;
				signal_mem[sigmem_addr_counter]<=signal_in;
				fir_accumlator<= mult_result;
			end else begin
				fir_accumlator<= mult_result+fir_accumlator;
			end
			if(decimation_clk) begin
				output_sampler<=fir_accumlator[2*SIGNAL_BITWIDTH-1:SIGNAL_BITWIDTH];
			end
			if(coeff_we)begin
				tap_coeffs[coeff_w_addr]<=coeff_in;
			end
			
		end
	end

endmodule