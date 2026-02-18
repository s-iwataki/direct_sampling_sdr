`define TX_FIR_I_ADDRESS 0
`define TX_FIR_I_DATA_L 1
`define TX_FIR_I_DATA_H 2
`define TX_FIR_Q_ADDRESS 3
`define TX_FIR_Q_DATA_L 4
`define TX_FIR_Q_DATA_H 5
`define RX_FIR_I_ADDRESS 6
`define RX_FIR_I_DATA_L 7
`define RX_FIR_I_DATA_H 8
`define RX_FIR_Q_ADDRESS 9
`define RX_FIR_Q_DATA_L 10
`define RX_FIR_Q_DATA_H 11
`define RX_GAIN_L 12
`define RX_GAIN_H 13
`define N_CONTROL_REGISTERS 14

`define STATE_WAIT_REG_ADDRESS 0
`define STATE_TX_FIR_I_CTRL 1
`define STATE_TX_FIR_Q_CTRL 2
`define STATE_RX_FIR_I_CTRL 3
`define STATE_RX_FIR_Q_CTRL 4
`define STATE_RX_GAIN_CTRL 5

`define STATE_FIR_CTRL_WAIT_ADDRESS 0
`define STATE_FIR_CTRL_WAIT_DATAL 1
`define STATE_FIR_CTRL_WAIT_DATAH 2
`define STATE_FIR_WRITE_DATA 3

module control_registers(
	clock, 
	reset_n, 
	cs_n,
	spi_data_in, 
	spi_data_en,
	spi_address_in,
	spi_address_en,
	fir_data_out,
	fir_address_out,
	tx_fir_i_data_we,
	tx_fir_q_data_we,
	rx_fir_i_data_we,
	rx_fir_q_data_we,
	rx_gain_out,
	rx_reset_n,
	tx_reset_n);
	
	input clock, reset_n,spi_data_en, cs_n;
	input [7:0] spi_data_in, spi_address_in;
	output signed [15:0] fir_data_out;
	output [7:0] fir_address_out;
	output [15:0] rx_gain_out;
	output rx_reset_n,tx_reset_n;
	
	reg [7:0] registers[0:N_CONTROL_REGISTERS-1];
	reg [2:0]state;
	reg[1:0]fir_substate;
	reg[3:0] reg_address;
	
	integer i;
	
	always @(posedge clock) begin
		if(!reset_n) begin
			for(i=0;i<N_CONTROL_REGISTER;i=i+1) begin
				registers[i]<=0;
			end
			state<=0;
			fir_substate<=0;
			reg_address<=0;
		end else begin
			case (state)
				`STATE_WAIT_REG_ADDRESS: begin
				;
					end
				`STATE_TX_FIR_I_CTRL: ;
				`STATE_TX_FIR_Q_CTRL: ;
				`STATE_RX_FIR_I_CTRL: ;
				`STATE_RX_FIR_Q_CTRL: ;
				`STATE_RX_GAIN_CTRL: ;
			endcase
		end
	end
	
	
	
endmodule
	