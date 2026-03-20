  create_clock -name sys_clk  -period 8.138 [get_ports clock]
  create_clock -name adc_sclk -period 8.138 [get_ports adc_clock]

  set_clock_groups -asynchronous -group { sys_clk } -group { adc_sclk }
  derive_clock_uncertainty
  set_output_delay -clock { sys_clk } -max 1.6 [get_ports wav_out*]
  set_output_delay -clock { sys_clk } -min 0.6 [get_ports wav_out*]
  set_input_delay -clock { adc_sclk } -max 5.64 [get_ports wav_in*]
  set_input_delay -clock { adc_sclk } -min 4.94 [get_ports wav_in*]
