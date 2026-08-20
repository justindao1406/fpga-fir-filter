## 125 MHz clock
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -period 8.000 -name sysclk -waveform {0.000 4.000} [get_ports sysclk]

## Reset button: BTN0
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports reset_button]

## Status LEDs
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports led_pass]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports led_fail]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports led_done]

## Asynchronous manual reset
set_false_path -from [get_ports reset_button]

## Asynchronous visual outputs
set_false_path -to [get_ports {led_pass led_fail led_done}]