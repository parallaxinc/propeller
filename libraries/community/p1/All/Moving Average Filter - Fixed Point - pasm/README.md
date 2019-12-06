# Moving Average Filter - Fixed Point - pasm

By: BR

Language: Spin, Assembly

Created: Apr 11, 2013

Modified: April 11, 2013

Moving average filter, implemented in PASM, with recursion. Starts a cog which continuously polls a memory location looking for a data value. Max filter bandwidth ~1M samples/sec @ 80 MHz, max filter kernel length is 400. This filter can be daisy-chained to produce triangular and Gaussian filter kernels.

V1.1: fixed small bug in the way that a null value is evaluated.
