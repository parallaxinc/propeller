#!/usr/bin/perl

# Simple program to generate a shifting rainbow effect on the LEDs when used 
# in conjuction with "I2C PWM.spin"

# Version 1.1 (2013-03-30)
# Copyright (c) 2014 Alexander Hajnal
# See end of file for terms of use

# This program is designed for use with the Raspberry Pi but should run on 
# any system that has a working copy of i2cset installed.

# It has been tested using a Raspberry Pi Model B running the Occidentalis 
# v0.2 Linux distribution with the i2c-tools package installed.  If you 
# do not have this package installed you can (on Debian-derived systems 
# such as Occidentalis) run "sudo apt-get install i2c-tools" (without the
# quotes) to install the package.  Note that you will probably also need to 
# be running a Linux kernel with the proper I2C support; the Occidentailis 
# kernel includes this however (AFAIK) the stock Raspian kernel does not.

# On the Raspberry Pi you can access the I2C bus via the P1 header.  The pins 
# on the P1 header are pin 3 (I2C1_SDA) and 5 (I2C1_SCL) as well as a ground 
# pin (one of pin 6, 9, 14, 20, or 25).  These should be connected to 
# "I2C SDA", "I2C SCL", and "I2C Ground" as indicated in "I2C PWM.spin"

# This program probably needs root permissions to run.  You can do this by 
# running "sudo ./raspberry_pi_i2c_pwm.pl" (without the quotes).

# Note that depending on the quality of your I2C bus wiring you may get a 
# number of "Error: Write failed" messages on the Raspberry Pi.  These 
# messages can be ignored during initial testing.

# Release history:
#
# 2014-03-28  v1.0  o Initial release
#
# 2014-03-30  v1.1  o Various bug fixes and other updates to low-level driver
#                     ("24-channel PWM.spin")
#                   o Minor code clean-up
#                   o Documentation clean-up and corrections

# Configuration variables:

# I2C address needs to match the one in "I2C PWM.spin"
$I2C_ADDRESS = '0x42'; # This needs to be a string, not a number

# I2C bus number

# For Raspberry Pi Model A:
#$I2C_BUS = 0; 
# For Raspberry Pi Model B:
$I2C_BUS = 1;

while (1) {
	for ( $a = 0; $a < ( 256 + 256 + 256 ); $a++ ) {
		$out = '';
		
		for ($off = 0; $off < 64*8; $off += 64) {
			$r = ( $a + $off       ) % (256 * 3);
			$b = ( $a + $off + 256 ) % (256 * 3);
			$g = ( $a + $off + 512 ) % (256 * 3);
			
			if ( ($r<0) || ($r > 511) ) {
				$r = 0;
			} else {
				$r = 255 - abs($r - 256);
				$r = 0 if ($r < 0);
			}
			
			if ( ($b<0) || ($b > 511) ) {
				$b = 0;
			} else {
				$b = 255 - abs($b - 256);
				$b = 0 if ($b < 0);
			}
			
			if ( ($g<0) || ($g > 511) ) {
				$g = 0;
			} else {
				$g = 255 - abs($g - 256);
				$g = 0 if ($g < 0);
			}
			
			$out .= "$r $b $g ";
		}
		
		`i2cset -y $I2C_BUS $I2C_ADDRESS 0 $out i`;
	}
}

# ,------------------------------------------------------------------------------------------------------------------------------.
# |                                                   TERMS OF USE: MIT License                                                  |
# |------------------------------------------------------------------------------------------------------------------------------|
# |Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    |
# |files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    |
# |modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software|
# |is furnished to do so, subject to the following conditions:                                                                   |
# |                                                                                                                              |
# |The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.|
# |                                                                                                                              |
# |THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          |
# |WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         |
# |COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   |
# |ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         |
# `------------------------------------------------------------------------------------------------------------------------------'
