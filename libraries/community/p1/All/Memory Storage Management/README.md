# Memory Storage Management

![dbthumb_1.jpg](dbthumb_1.jpg)

By: Brandon Nimon

Language: Spin

Created: Aug 5, 2009

Modified: May 20, 2013

This object is designed to allow programmers (and/or end-users) to store values to EEPROM, referenced by name rather than just a number.

It is similar to a simple database system. The values can be stored in numerical byte, word, or long values. Strings, arrays, and stacks can also be stored to the EERPOM. All of the values are created, edited, and retrieved with a simple name.

All values can be edited and deleted. New in 2.0: deleted items' storage space can be reused, to reduce the wasted space.

This is great for storing user-created settings or values that need to be accessed at a later time with profile names or user entries. In the right hands, it can be used for just about any EEPROM application.

**NOTE**: a lightweight version of the object exists. It removes storing of strings, stacks, and arrays. It reduces the program size to about half of this object. 

**NOTES:**

*   Tables and values created by versions before 2.0 will be reset/erased when running this object for the first time.
*   This object supports and includes both the SPIN and PASM versions of I2C Drivers.
