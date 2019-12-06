# xTach - Tachometer - Frequency Counter - Pure spin

By: Mark Owen

Language: Spin

Created: Oct 17, 2014

Modified: October 18, 2014

Demonstrates usage of the xTach methods for determining the activity

  on an input pin:

        Pulse width in system clock ticks

        Pulse frequency in Hz (cycles per second)

        Pulses per minute

        Revolutions per minute

  Uses the Parallax Serial Terminal for output at 115,200 baud for output.

  Written as a means of circumventing jitter found to be present when using

  assembly language frequency counters for low frequency signals (in my case

  a belt driven aircraft propeller with 39 teeth per revolution on the main

  drive pully which runs at a maximum of 3600 revolutions per minute).

  Has been tested using a signal generator from 1Hz to 50kHz and found to be

  accurate to better than 98% over the range tested with the largest errors at

  frequencies less than 30Hz (2%).

Includes two source files in a single zip file:

  xTachTest.spin - the demonstration program

  xTach.spin       - the object module

Updated 2014-10-18 ti incorporate function for dealing with loss of signal.
