# Servo32 V9

By: Parallax Inc

Language: Spin

Created: Jan 22, 2015

Modified: January 22, 2015

Control up to 32 servos without external hardware.

History:

*   Version 1 - - initial concept
*   Version 2 - (03-08-2006) - Beta release
*   Version 3 - (11-04-2007) - Improved servo resolution to 1uS
*   Version 4 - (05-03-2009) - Ability to disable a servo channel and remove channel preset requirement
*   Version 5 - (05-11-2009) - Added servo speed ramping
*   Version 6 - (07-18-2009) - Fixed slight timing skew in ZoneLoop and fixed overhead timing latency in ZoneCore
*   Version 7 - (08-18-2009) - Fixed servo jitter in ramping function when servo reached it's target position.
*   Version 8 - (12-20-2010) - Added PUB method to retrieve servo position
*   Version 9 - (04-05-2013) - cnt rollover issue corrected with ZonePeriod by setting up Counter A and using the Phase accumulator instead of the cnt Note: This also eliminates the need to setup a 'NoGlitch' variable
