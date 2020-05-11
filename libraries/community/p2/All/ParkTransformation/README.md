# Park transformation

By: Nicolas Benezan (forum: ManAtWork)

Language: P2 assembly

Created: 09-May-2020

Category: math, motor control, snippets

Description:
The Park or d/q-transformation is useful when controlling AC motors or brushless servo motors. It transforms currents or voltages from a three phase system with stator reference into a rectangular coordinate system that is referenced to the rotor. The output can be treated as if the motor was a DC machine. After calculations (PID control) are done the values are transformed back to the three phase system using the inverse Park transformation. The results can then be output to a three phase power stage.
This is a small code snippet that demonstrates how the P2 CORDIC unit can be used for the Park transformation and its inverse. It uses 16 bit signed format for all current and voltage values. This should be sufficient for most applications. The CORDIC even could do full 32 bit resolution, only the scaling had to use 32 bit multiplication instead of the SCAS instructions. The angle (theta) has to be left adjusted.

License: MIT (see end of source code)
