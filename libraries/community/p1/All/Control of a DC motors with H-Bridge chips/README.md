# Control of a DC motors with H-Bridge chips

By: Thomas Doyle

Language: Spin, Assembly

Created: Apr 4, 2013

Modified: April 4, 2013

Control speed and direction of DC motors using H-Bridge chips such as the LMD18201

The setMotor procedure sets the duty cycle (0%-100%), direction and delay per % change in duty cycle. The delay per % change in duty cycle allows the motor speed to ramp up and down in a smooth manner. The amount of delay to use will depend on the characteristics of the motor and the load on the motor. This procedure is operating open loop which means that if the delay

per % change in duty cycle is not long enough you can over run the motor. The procedure keeps track of the direction of the motor and will ramp the speed to 0 before changing direction. The setMotor procedure is run in a new cog which waits for any previous operation to quit before starting the new one. The setMotor cog is released after the new motor setting has been reached. The pwm loop will run constantly in its own cog to keep the motor running at the set duty cycle. A test program is included that controls two motors.
