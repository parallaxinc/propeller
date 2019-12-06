# JDCogSerial

By: Carl Jacobs

Language: Spin, Assembly

Created: Apr 10, 2013

Modified: April 10, 2013

A full duplex serial that has \*ALL\* the buffer memory stored in the COG. The VAR footprint is tiny at only 6 longs. The buffer pointers are fully automatic, which allows easy access from assembly as well as sub-objects. The buffer sizes may be set at any number of bytes (in multiples of 4) to the total spare capacity of the COG (a bit over 1300 bytes). Only mode 0 is supported, with baud rates to above 345600 for a 80MHz clock.
