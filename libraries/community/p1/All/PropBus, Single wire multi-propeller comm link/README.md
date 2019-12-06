# PropBus, Single wire multi-propeller comm link

By: Mike Christle

Language: Assembly

Created: Jul 1, 2014

Modified: July 30, 2014

between two or more Propeller chips. This interface is very 
loosely based on the MIL-STD-1553 interface. One chip becomes the
Bus Controller (BC) and all others are Remote Terminals (RT).
The interface uses a single wire, bi-directional bus. The data
is transferred using Manchester encoding at a 1MBit data rate.
All data consist of 16 bit words.
