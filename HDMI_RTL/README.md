<h2 align="center">HDMI Controller</h2>

This is a simple project to control HDMI Display using Pynq Z2 board with the help of verilog. This project makes use of HP 19ka monitor, optimal resolution supported by this monitor is 1366 x 768 at 60 Hz. The verilog source code includes logic to display 8 colour strip on the monitor. As this monitor has only VGA interface a HDMI to VGA converter is used to connect the monitor.

Timings for this resolution are as follows<br/>

<h3>Horizontal</h3>

* Active Pixels - 1366
* Total Pixels  - 1500
* Front Porch   - 14
* Sync Pulse    - 56
* Back Porch    - 64

<h3>Vertical</h3>

* Active Pixels - 768
* Total Pixels  - 800
* Front Porch   - 1
* Sync Pulse    - 3
* Back Porch    - 28

Pixel Clock = 1500 x 800 x 60 = 72 MHz</br>
TMDS Clock = 10 x Pixel Clock = 720 MHz

<h3>References</h3>

* https://forum.digikey.com/t/tmds-encoder-vhdl/12653
* https://www.fpga4fun.com/HDMI.html
