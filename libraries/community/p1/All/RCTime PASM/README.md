# RCTime PASM

![rcthumb.jpg](rcthumb.jpg)

By: Brandon Nimon

Language: Spin, Assembly

Created: Apr 16, 2013

Modified: April 16, 2013

An RC time object written in PASM with some special features.  
More accurate timing, and uses less power than the SPIN variety.

Another feature is the \*\_forever mode; this allows the controlling cog to receive continuous input of RC times.

Another unique feature which allows for more accurate RC times when other environmental variables may be affected: after the single RC time test, the pin is set in the opposite direction of the test. This stops current flow through the testing circuit. This is important in some testing (thermistors, for example) where continued current flow will alter the resistance value due to generated heat.

Finally, the standard single RCTIME has a built-in watchdog timer so the cog won't halt completely if a problem with the RC circuit occurs.

As a demo, a proximity "touch" sensor was setup. Only using a resistor, a metal plate, and the RCTime PASM object sensing the capacitance changes are easy!
