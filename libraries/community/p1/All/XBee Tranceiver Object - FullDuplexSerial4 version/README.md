# XBee Tranceiver Object - FullDuplexSerial4 version

By: Albert Emanuel Milani

Language: Spin

Created: Oct 1, 2014

Modified: November 24, 2015

A version of Martin Hebel's XBee Transceiver AT-API Object that uses pcFullDuplexSerial4FC512.spin instead of FullDuplexSerial.spin, allowing it to use a shared serial cog that does 4 UARTS instead of each serial port using up a whole cog.  The other three ports can be used for whatever you want, the same way you would normally use the other three ports of the four port serial object.  This is very helpful when you're running low on cogs - instead of needing multiple instances of FullDuplexSerial.spin, one for debug output, one for an XBee, and more for other peripherals, each using up a whole cog, you can have 4 separate serial ports done in one cog. 

This uses and comes with Duane Degn's 512 byte buffer version of Tim Moore's original 4 port serial driver.  Anything descended from Tim Moore's driver should work fine, but I've only tested it with Duane Degn's version.  Duane Degn also has a 128 byte rx buffer per port version, if you need the ram for other things.
