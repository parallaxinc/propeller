# Maidenhead with Distance and Bearing

By: W1AUV

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

Maidenhead, a shorthand for latitude and longitude, is used by Amateur Radio operators (hams) for use in identifying a location. For some contests, VHF, UHF+, Maidenhead is used as a required part of the exchange. For microwave contests, Maidenhead is used as a required part of the exchange and also to compute your heading to another station. Aiming is important at these frequencies and must be within a couple degrees or better depending on the frequency and the antenna used.

Maidenhead is calculated using latitude and longitude which is usually obtained from a map or from a GPS system output (usually NMEA serial data). Some GPS systems don't provide a direct display of Maidenhead and many hams are building their own GPS systems (used when locking local oscillators to GPS atomic clocks) using surplus GPS receivers. The functions contained here are intended to help the ham to convert NMEA serial data strings containing lat/lon (like $GPRMC) to Maidenhead. The computed Maidenhead can then be used as inputs to other included functions to compute distance and bearing to a target location.  
  
A test file is included.
