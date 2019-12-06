# tx.spin

By: Barry Meaker

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

tx.spin is a set of routines that allow the transmission of serial data. tx.spin is derived from FullDuplexSerial.spin. The benefit it has over the transmission routines in FullDuplexSerial.spin is that it is optimized for the transmission of a serial string. FullDuplexSerial.spin uses an assembly language routine to send a byte, and for strings it calls that routine repeatedly for each character in the string. For FullDuplexSerial.spin, each character in a string is transmitted with a multi-microsecond gap following it. tx.spin utilizes an assembly routine for the transmission of the string, which can transmit the characters within the string without dead-time.
