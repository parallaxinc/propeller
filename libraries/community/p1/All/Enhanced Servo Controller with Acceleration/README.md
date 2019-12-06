# Enhanced Servo Controller with Acceleration

By: Diego Pontones

Language: Spin

Created: Apr 5, 2013

Modified: April 5, 2013

This object allows the control of up to 14 standard servos.

It requires 1 cog.

2 cogs required for Accelerated/Decelerated Moves.

This object is based on the Servos for PE Kit.spin but incorporates many new features like:

**a) Three different type of movements: Immediate, Gradual and Accelerated/Decelerated**

Immediate Moves: One or more servos are moved to the new positions as fast as they allow it.

Gradual Moves: One or more servos are moved to the new positions in a predetermined number of pulses.

Accelerated/Decelerated Moves: One or more servos are moved to the new position using the sine function

to achieve a gradual acceleration at the beginning of the move and a gradual deceleration at the end of

the move. Please note that if Accelerated/Decelerated moves are used an additional cog is required to

run the Float32 object used for the sin function.

All movements are executed during a certain number of pulses, where 50 pulses equal one second.

**b) Option to send pulses while in holding position.**

When a movement is completed there is the option to keep sending pulses to hold the servo in the

last position or to stop sending pulses.

Sending hold pulses helps keep the servo firmly in position (useful for robotic arms or walking robots) but

increases the power consumption. Not sending hold pulses leaves the servo idle so power consumption is

reduced, this is normally used for servos that do not require a high holding torque.

**c) Servos can be moved individually or in combined moves.**

All parameters, like type of movement, number of pulses and optional holding pulse can be set

individually for each servo so very complex movements can be executed. For example different movement

durations can be set for each servo or some servos can be moved many times while other servos are still

completing a long move.
