# 4-pole IIR Filter - Fixed point math - pasm

By: BR

Language: Spin, Assembly

Created: Nov 6, 2010

Modified: June 17, 2013

Infinite Implulse Response (IIR) Recursive filter, implemented in pasm, with recursion. Starts a cog which continuously polls a memory location looking for a data value. The design objective for this filter was to make it as fast as possible. It is implemented using fixed point math in a single cog and is capable of 180K samples/sec @ 80 MHz with a simple high or low pass filter. This object also contains a set of filter synthesis methods to facilitate filter setup, though the user can also manually input filter coefficients if desired. The filter is also constructed to facilitate easy chaining of filters.

See also:

http://forums.parallax.com/showthread.php?t=118111
