# Single cog GPS receiver / parser / converter

By: Chris Gadd

Language: Spin, Assembly

Created: Apr 19, 2019

Modified: May 20, 2019

Uses a single cog to read NMEA messages from a GPS receiver (GGA and RMC messages currently supported), parses the messages to extract time, date, latitude, longitude, altitude, course, and speed and reformats into readable ASCII strings.  Also presents latitude, longitude, altitude, course, and speed as binary values.

Includes demo routine with a GPS message generator.
