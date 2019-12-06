# Txx - Fast Serial Transmitter for PASM and Spin

By: Jac Goudsmit

Language: Spin, Assembly

Created: Jan 23, 2018

Modified: January 27, 2018

The TXX module is a fast (up to 8 megabits per second) RS-232 (TTL) compatible serial output generator that was written to be used from PASM as well as Spin. It only transmits, it doesn't receive and it doesn't do flow control.

It's controlled by a single command longword, which tells the PASM code where to read data, how much to read, how to interpret the data and how to output the data.

Unlike other serial communications modules available here on OBEX and elsewhere, all processing is done in PASM, not in Spin. That means that it's easy for PASM code to use the serial output too, and not just to send single characters or buffers, but also to generate unsigned or signed decimal, hexadecimal or binary numbers. The module also has a hex dump mode that generates a convenient dump of any hub memory area, which should be useful for debugging.

This was originally based on "tx.spin" by Barry Meaker (http://obex.parallax.com/object/619) but there's probably no recognizable code from that module visible anymore. Nevertheless, thanks Barry!
