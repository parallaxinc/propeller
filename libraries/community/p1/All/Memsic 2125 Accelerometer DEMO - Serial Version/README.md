# Memsic 2125 Accelerometer DEMO - Serial Version

By: Parallax Inc

Language: Spin

Created: Jan 22, 2015

Modified: January 22, 2015

Written in Propeller Assembly uses a 'cordic' routine to convert x and y tilt information into polar coordinates. Output is RAW data, but can easily be resolved into acceleration (ro) and degrees (theta). Upon startup, the demo expects the accelerometer to be in a level position for an initial calibration leveling routine.

Revision History:

*       Version 1.0 - (07-31-2006) original release
*       Version 1.1 - (08-17-2008) modified code to return RAW x and y values
*       Version 1.2 - (12-18-2009) Added X and Y Tilt values
