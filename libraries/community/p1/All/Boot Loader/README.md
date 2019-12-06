# Boot Loader

By: Matthew Cornelisse (propmodule.com)

Language: Spin

Created: Jun 29, 2009

Modified: May 2, 2013

Small program that sits on eeprom allowing for code update through sd card attached to pins p0-p3

requirements:

*   512kbit EEPROM instead of normal 256kbit
*   SD or uSD card reader on p0-p3
*   sd or uSD card to store your program

how it works:

when the program first starts up it looks to see if there is an sd card with code.bin on it. If not present it will load whatever code is stored in top half of eeprom. If the file is found then the code is copied to the top half of eeprom. deletes the update code file and then starts the code.

Run Time:

*   New code present: ~17sec until code starts
*   No new code present: ~0.5 sec until code starts

Advantages:

*   Code can always be updated through sd card even if bad transfer
*   Can program many systems from 1 sd card
*   No programmer needed once initial bootloader is loaded.

Was designed mainly for propmod-us\_sd and propmod-us\_ps\_sd but can be used by anyone.
