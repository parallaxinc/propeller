# C Pin Driver

By: Ryan Stark, Stark Informatics LLC

Language: C

Created: Oct 13, 2012

Modified: July 8, 2013

Provides a list of functions for quick and easy manipulation of general purpose IO pins in C.

Version 1.0

Original Release

Single Pin Manipulation

Version 1.1

Improves documentation

Version 2.0

Adds ability to manipulate arrays of pins

Version 2.1

Adds Pre-Processor statements allowing including of either Pins.h or Pins.c and prevents multiple declarations

Version 2.2

Fixes bug in void pinOutLow(PIN\_MASK \* msk)

Please note, this is relatively untested. Please email me any bugs you may find!

Includes functions to:

*   Set Pin(s) Direction
*   Set Pin(s) Status(High/Low)
*   Set Direction and Status(Sets pin(s) direction as output, then sets high/low status)
*   Read Pin(s) Input
*   Set Direction and Read Input(Sets direction as input, then reads)
*   Read Pin(s) Configuration(In/Out, High/Low)
