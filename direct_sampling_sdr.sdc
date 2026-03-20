  create_clock -name sys_clk  -period 8.138 [get_ports clock]
  create_clock -name adc_sclk -period 8.138 [get_ports adc_clock]

  set_clock_groups -asynchronous -group { sys_clk } -group { adc_sclk }