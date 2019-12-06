# L298 PWM Motor Control

By: Thomas Doyle

Language: Spin, Assembly

Created: Apr 10, 2013

Modified: April 10, 2013

The L298 chip is used for direction and PWM motor speed control. The objects have been tested using two motors. A dedicated cog is used to maintain the PWM stream. Speed and direction changes are ramped to maintain smooth operation. If a change in direction is called for while the motor is running the motor speed will ramp down to zero before the direction change is carried out.
