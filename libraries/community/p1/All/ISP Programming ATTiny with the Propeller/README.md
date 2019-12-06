# ISP Programming ATTiny with the Propeller

By: Cluso99

Language: Spin

Created: Oct 16, 2011

Modified: May 2, 2013

Program the ATTiny84 with the Propeller chip using ISP (4 pins).  
 

The program can be easily modified for other ATTiny and similar parts. Currently the hex code must be placed into the object and the spin code modified to program the correct length. Feedback is provided by the FullDuplexSerial object and PST (Parallax Serial Terminal). Timing has not been tweeked so it is slowish.  
 

The code loaded into the ATTiny84 will flash a led connected to PortA bits 0 or 1.
