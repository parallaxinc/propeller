# Basic I2C Driver

By: Michael Green

Language: Spin

Created: Apr 4, 2013

Modified: April 4, 2013

This is a simple Spin I2C driver intended mostly for accessing I2C serial EEPROMs like the boot EEPROM. There are low level routines included that can be used to access other I2C devices, but the specific routines to do so would have to be written by the user. See "i2cObjectv2" for an object with specific routines.

Version 1.3 includes logic to support non-memory devices. See comments.
