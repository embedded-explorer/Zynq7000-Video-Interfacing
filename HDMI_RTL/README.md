<h2 align="center">3-Bit VGA Interface</h2>

This is a simple project to control VGA monitor using Pynq Z2 board using verilog. This project makes use of HP 19ka monitor, optimal resolution supported by this monitor is 1366 x 768 at 60 Hz. The verilog source code includes logic to display 8 colour strip on the monitor.

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

Pixel Clock = 1500 x 800 x 60 = 72 MHz

Here each component (R, G, B) is 1 bit wide hence only 8 different colours are possible.

![3-Bit Colour Code](cc.png)

The Connection between the Board and VGA connector is as shown below.

![Schematic](schematic.png)

Reference</br>
https://www.fpga4fun.com/PongGame.html/
