# Multiple Stepper Motor Controller

By: DDS

Language: Spin

Created: Apr 11, 2013

Modified: April 11, 2013

This is a simple multiple stepper motor controller

  
This demo program will allow you to control up to 16 stepper motors with one cog. It requires a step & direction type driver so each motor requires 2 output pins. There is no acceleration/deceleration implemented in this program, they just turn at the maximum rate as determined by the limitations of the motor and the spin execution time.

There is no synchronization of one motor to another. (Can't use this for a CNC machine). It just moves the motors in whatever direction is necessary to make the "MotorAtX" position variable equal to the "ValueX" process variable.

To move a motor, just set the "ValueX" with the number of stepper counts you want it to move to.  
This is an Absolute position, not a relative amount to change.

Assuming it is at "Zero", if you set the variable to 100, it will move to 100.  
Then if you want it to move to 300, it will spin an additional 200 counts since 300-100=200.  
If you want it to go back to "Zero", it would spin 300 counts in the opposite direction.

I/O pin usage is not important, but they must be one contiguous block of pins. The enable pin is up to you to implement if required.  
  
You might have to slow down both the step rate and the strobe width if your stepper motor or controller can't handle the speed.  
  
There are no limit switches used in this program.  
In this demo, I just turn the motors backwards to a physical stop to get a fixed reference point and consider it to be "Zero".
