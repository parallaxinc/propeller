# MultiPortUART with C# (windows) client

By: Bob Anderson

Language: Spin, Assembly

Created: Jan 13, 2008

Modified: May 2, 2013

This "object" is meant to be an aid in debugging the Propeller chip. There is often a need to see output from and supply input to multiple cogs during development.

The attached Spin and PASM code implement an 8 channel UART to allow easy serial input and output from up to 8 sources (cogs, for example) in the propeller chip. Only 2 pins are actually used by preceding each byte with a channel identifier byte. This multiplexing is kept transparent to the user by use of an associated Windows client that has 8 panels. The full duplex serial code that runs in a single cog has been tested to 115,200 baud.

There are 8, 128 byte receive buffers on the propeller side. Output is unbuffered on the propeller side, but the Windows client has a 4096 byte input buffer.

The output that is displayed in each panel of the Windows client can be directed to a file as well.

Each panel of the Windows client can perform formatting functions as well if the propeller sends formatting strings and values to be displayed enclosed in vertical bars. Thus, the full power of C# formatted output becomes available to the propeller. (Of course, you need to know how to format strings in C# :( )
