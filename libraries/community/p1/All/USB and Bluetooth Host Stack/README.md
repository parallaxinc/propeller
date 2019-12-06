# USB and Bluetooth Host Stack

By: Micah Dowty

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: May 20, 2013

This is a simple USB and Bluetooth protocol stack. It implements a full-speed (12 Mb/s) USB host by bit-banging, so it requires no external hardware to interface USB devices to a Propeller.

Version 1.0 includes support for FTDI Serial, Mass Storage, and Bluetooth devices.

The Bluetooth support lets you use a cheap USB Bluetooth adapter to add wireless communications to your Propeller. Supports the Serial Port Protocol.

Advanced users can also write their own drivers for new USB or Bluetooth devices using lower-level APIs.

Demo video: http://micah.navi.cx/2010/07/propeller-bluetooth-stack-demo/

Forum thread: http://forums.parallax.com/forums/default.aspx?f=25&m=440787
