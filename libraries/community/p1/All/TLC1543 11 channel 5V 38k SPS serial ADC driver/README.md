# TLC1543 11 channel 5V 38k SPS serial ADC driver

By: Mark Owen

Language: Spin

Created: Sep 28, 2013

Modified: September 28, 2013

The TLC1543 is a 38k samples per second CMOS A/D converter built around a 10-bit switched-capacitor successive approximation A/D converter with a 14 channel multiplexer and a four bit serial interface (I/O CLOCK, chip select \[CS\], ADDRESS INPUT and DATA).

This software provides both synchronous (running in the callers COG) and asynchronous (running in a separate COG) methods for interfacing with the ADC.

ZIPped Files included:

BBTestsADC1543.spin - test/demonstration program for use on a Parallax P8X32A Quickstart with output to Parallax Serial Terminal

TLC1543ADC\_H.spin - constants

TLC1543ADC.spin - driver code
