# Medium Frequency R2R Sine Wave Generator 1.25 Mhz

![SmallSine.jpg](SmallSine.jpg)

By: tubular

Language: Assembly

Created: Apr 11, 2013

Modified: April 11, 2013

This object generates a Medium Frequency Sine Wave into an R2R network using a "DDS precalculation" technique.

The cosine wave has N=16 steps, each step takes 4CLK for a max sine output of 1.25MHz@80MHz (1.56MHz@100MHz CLK)

The secret is to offset the steps by half a step in the time domain, eg for N=16, don't use 0,22.5,45 degrees but 11.25, 33.75, 56.25 degrees etc such that two successive samples near the peak have the same output value. Then instead of outputting the second identical sample, JMP to the start of the loop and repeat.  
The JMP and Output (MOV OUTA, SampleValue) both use 4 CLKs.
