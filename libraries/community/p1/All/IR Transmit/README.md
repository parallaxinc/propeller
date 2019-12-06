# IR Transmit

By: Thomas Doyle

Language: Spin

Created: Apr 1, 2013

Modified: April 10, 2013

Counter A is used to send Sony TV remote codes to an IR led _(Parallax #350-00017)_. The test program uses a Panasonic IR Receiver _(Parallax #350-00014)_ to receive and decode the signals. Thanks to the power of multiple cogs in the Propeller the receive object runs in its own cog waiting for a code to be received. When a code is received it is written into the IRcode variable and processed by the main program. The code is read by the receive object in a cog as it is transmitted by another cog.
