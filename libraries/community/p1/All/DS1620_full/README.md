# DS1620_full

By: BR

Language: Spin

Created: Apr 5, 2013

Modified: April 5, 2013

A full-featured DS1620 thermostat chip driver. Supports degF and degC. Temperatures are returned scaled by 10X (i.e., a reading of 770F is 77.0F).

Features include: 

*   A simple/minimal serial-terminal-based demo
*   Convience of high level helper functions
*   A function to provide low-level (register) access & control
*   A "stop" function that returns the 1620 to standalone mode
*   Smaller code size
*   A simple/convenient demo method for programming and testing the thermostat functions

This object is based on the work of Jon and Greg:  
_http://obex.parallax.com/objects/41/  
http://obex.parallax.com/objects/752/_
