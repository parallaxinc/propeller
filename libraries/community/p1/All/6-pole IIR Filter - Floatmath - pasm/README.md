# 6-pole IIR Filter - Floatmath - pasm

By: BR

Language: Spin, Assembly

Created: Nov 6, 2010

Modified: June 17, 2013

Infinite Impulse Response (IIR) Recursive filter, implemented in PASM with floatmath. Starts a cog which continuously polls a memory location looking for a data value. The design objective for this filter was to make a reasonably high performance IIR filter with the greatest possible bandwidth in a single cog. Typical filter bandwith (using ALL filter coefficients) is 4.8K samples/sec @ 80 MHz. No filter synthesis methods are provided with this object (beyond a few demo filter kernels)--it is up to the user to roll their own coefficients. The filter is set up to facilitate easy chaining of filters if desired.

See also:

http://forums.parallax.com/showthread.php?t=118111
