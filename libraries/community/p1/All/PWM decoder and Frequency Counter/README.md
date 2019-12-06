# PWM decoder and Frequency Counter

By: Mike Lord

Language: Spin, Assembly

Created: Apr 12, 2013

Modified: April 12, 2013

File: \_FreqCount.spin

Frequency and duty cycle counter

Written by Michael J. Lord Electronic Design Service 2010-06-01  
650-219-6467 mike@electronicdesignservice.com  
drop me a note if you find this program usefull.

I wrote this for a client. It runs well on the demo board using the tv display

This program measures frequency and duty cycle of a square wave that is input into CountPin The practical range for the unit is 0 to 100 khz. At 1mhz the accuracy is not so good. This works well for any pulse width modulation decoding that is needed. It measures one cycle and reports the results back in the next cycle. In this way it reads every other cycle

This is usefull when needing to decode the meaning such as position of a pwm signal such as that sent to a servo.
