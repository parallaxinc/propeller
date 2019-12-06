# Frequency Synthesis/PWM X31

![freqsynththumb.jpg](freqsynththumb.jpg)

By: Brandon Nimon

Language: Spin, Assembly

Created: Apr 9, 2013

Modified: April 9, 2013

Frequency Synthesis/PWM X31:  
This program grants the ability to output up to 31 frequencies at once using the resources of only a single cog. With a clock speed of 80MHz, output can stably reach as high as 320KHz. If more than one output is used (the main purpose of this program), the maximum frequencies depend on the amount and combination of frequencies. To approximate: Max-Hz = 4000 \* MHz / channels.

Changing the duty parameter allows programmers to alter the high to low ratio of the frequencies being outputted (PWM). The value is the percentage of high time. A duty of 1% - 99% is supported.

If an output is not needed, just enter -1 for the pin, 0 for the frequency, or 0 for the duty.
