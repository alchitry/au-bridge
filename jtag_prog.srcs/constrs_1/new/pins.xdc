set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN K13 [get_ports {led[0]}]
set_property PACKAGE_PIN K12 [get_ports {led[1]}]
set_property PACKAGE_PIN L14 [get_ports {led[2]}]
set_property PACKAGE_PIN L13 [get_ports {led[3]}]
set_property PACKAGE_PIN M16 [get_ports {led[4]}]
set_property PACKAGE_PIN M14 [get_ports {led[5]}]
set_property PACKAGE_PIN M12 [get_ports {led[6]}]
set_property PACKAGE_PIN N16 [get_ports {led[7]}]


set_property IOSTANDARD LVCMOS33 [get_ports cs]
set_property PACKAGE_PIN L12 [get_ports cs]


set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports {sio[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sio[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sio[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sio[0]}]
set_property PACKAGE_PIN N14 [get_ports clk]


set_property PACKAGE_PIN J13 [get_ports {sio[0]}]
set_property PACKAGE_PIN J14 [get_ports {sio[1]}]
set_property PACKAGE_PIN K15 [get_ports {sio[2]}]
set_property PACKAGE_PIN K16 [get_ports {sio[3]}]
create_clock -period 200.000 -name DRCK_LED -waveform {0.000 100.000} [get_pins BSCANE2_LED_inst/DRCK]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]