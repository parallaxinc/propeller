# RFID_Demo

![RFID_Tag.gif](RFID_Tag.gif)

By: Gavin Garner

Language: Spin

Created: Apr 16, 2013

Modified: April 16, 2013

This Spin program demonstrates how a Parallax RFID scanner can be interfaced with a Propeller chip. I've included comments that explain exactly how the 8-N-1 asynchronous serial protocol works and how it can be orchestrated directly by Spin code without having to call external objects. A serial, 4-line, Parallax LCD screen is used (by calling the Debug\_Lcd object from the default Propeller Library) to display an RFID tag's data codes and whether or not they match predetermined tag IDs. Extra lines of code could be added below the "Access Granted!" and "Access Denied" lines to open and close solenoid locks, set off alarms etc. in order to create a security system.
