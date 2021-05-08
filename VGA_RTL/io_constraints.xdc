set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
create_clock -period 8.000 -name clk -waveform {0.000 4.000} [get_ports clk]

set_property PACKAGE_PIN Y18 [get_ports vga_r]
set_property IOSTANDARD LVCMOS33 [get_ports vga_r]

set_property PACKAGE_PIN Y19 [get_ports vga_g]
set_property IOSTANDARD LVCMOS33 [get_ports vga_g]

set_property PACKAGE_PIN Y16 [get_ports vga_b]
set_property IOSTANDARD LVCMOS33 [get_ports vga_b]

set_property PACKAGE_PIN U18 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]

set_property PACKAGE_PIN U19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]
