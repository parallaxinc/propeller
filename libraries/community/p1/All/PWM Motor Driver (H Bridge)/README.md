# PWM Motor Driver (H Bridge)

By: Rick Price

Language: Spin, Assembly

Created: Apr 12, 2013

Modified: April 12, 2013

Motor driver for H Bridge driven motors; for instance L298N based driver circuits, based on code by Jev Kuznetsov and the code from AN001 - propeller counters.

The output directions are set based on the duty cycle (-100%,0,100%), and the enable pin is pulsed to achieve PWM speed control.

When the duty cycle is set to zero, both sides of the H bridge are set to ground and the enable line is turned on.
