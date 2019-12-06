# Dual PWM motor driver in 1 cog

By: Kyle Love

Language: Spin

Created: Apr 5, 2013

Modified: April 5, 2013

This object reads in a integer value from 0 to 127 and outputs a PWM signal with a duty cycle proportional to the integer value 0 is 0V DC, 50 is high 50/127 of the time, 127 is 3.3V DC. It runs at 400Hz but both the range of integers and the frequency can be adjusted in the constant block. My first attempt at spin and the propeller so feedback would be great.
