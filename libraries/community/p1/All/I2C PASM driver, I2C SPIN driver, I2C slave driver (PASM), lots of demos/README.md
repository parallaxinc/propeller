# I2C PASM driver, I2C SPIN driver, I2C slave driver (PASM), lots of demos.

By: Chris Gadd

Language: Spin, Assembly

Created: Jul 27, 2013

Modified: March 16, 2019

Includes Spin-based and PASM-based open-drain and push-pull drivers, with methods for reading and writing any number of bytes, words, and longs in big-endian or little-endian format.  All drivers tested with the 24LC256 EEPROM, DS1307 real time clock, MMA7455L 3-axis accelerometer, L3G4200D gyroscope module, MS5607 altimeter module, and BMP085 pressure sensor.  Includes a demo programs for each.

Also includes a polling routine that displays the device address and name of everything on the I2C bus.

Also includes a slave object that runs in a PASM cog with a Spin handler, and provides 32 byte-sized registers for a master running on another device to write to and read from.  Tested okay up to 1Mbps (max speed of my PASM push-pull object).  Includes demo for the slave object.

Newly added multi-master object that can share the bus with other masters, provided of course that the other masters also allow sharing.
