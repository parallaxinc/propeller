# 1Mbaud FullDuplexSerial (Fixed baud-rate)

By: David Sloan

Language: Spin, Assembly

Created: Jun 7, 2017

Modified: June 7, 2017

UART serial transceiver driver.  This object is capable of 1Mbuad communication speeds in a single cog with simultaneous transmit and receive.  Examples are provided for both spin and assembly control of the serial driver core.  This is a fixed buad rate UART module intended for use with 80 MHz clocked propeller chips.  If another clock frequency is chosen the baud rate with scale proportionally.
