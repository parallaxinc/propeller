# Shift Register Object

By: microcontrolled

Language: Spin

Created: Apr 16, 2013

Modified: April 18, 2013

This is an object to read input shift registers. It has been tested to work with the TI SN74HC165 shift register, but should work with any that have a latch (SH/LD), CLK, CLK inhibit _(CLKINH)_, and a serial out. On the TI you will define the serial in pin as the "Qh" pin on the pinout.

Note that this will not work with output shift registers.
