# Bipolar Stepper motor driver

By: Perry Harrington

Language: Spin

Created: Apr 4, 2013

Modified: April 4, 2013

This is a bipolar stepper motor driver written in SPIN. It directly generates the commutation sequence for the stepper motor. It can be easily used with the PPDB to test stepper motors. It only controls one motor per object at this time. The commutation method is entirely array based, no logic operands are in the fast path.
