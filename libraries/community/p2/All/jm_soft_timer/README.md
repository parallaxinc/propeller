# Soft Timer

By: Jon "JonnyMac" McPhalen

Language: Spin2, PASM2

Created: 30-NOV-2020

Category: sensor

Description:
This object demonstrates an advanced feature of Spin2: the installation of an ISR (interrupt service routine) into the Spin2 interpreter cog. This allows the programmer to create and install "background" code without consuming an entire cog for the process.

This timer object runs up to 100 hours before rolling over (to 0) with a resolution of 1/100th seconds. Object methods allow the timer to be reset and stopped, reset and auto run, put on hold, or allowed to free run. Interface methods give access to the timer as a whole, or to the various registers. A string method is included to simply output to displays like terminals and LCDs.

License: MIT (see end of source code)
