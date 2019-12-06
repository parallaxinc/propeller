# MMBE

By: Aleks

Language: Spin

Created: Apr 11, 2013

Modified: April 11, 2013

This is a driver for the Motor Mind B Enhanced motor controller that was developed during the process of me learning the Spin programming language by tearing apart the Simple\_Serial.spin program. It is thus, not entirely my own work, as I did a bit of copy/pasting from Simple\_Serial.spin, but it is still an effective driver. Please read the README.txt before delving into it.

_\*\*note -> requires FullDuplexSerial.spin (not included)_

**\*\*\*| Revision History |\*\*\***  
~8-28-2008  
The driver has been modified to implement the FullDuplexSerial.spin driver instead of Simple\_Serial.spin. The getstatus command has been modified to work more efficiently, and checkdir and setdir have been added to work with the motor direction.
