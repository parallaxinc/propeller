# PAM-7Q Driver GPS spin

By: Tom Crawford

Language: Spin

Created: Jun 3, 2016

Modified: August 11, 2017

The original upload (2016) had at least two major problems:

1\. It did not read and parse an RMC sentence every second (because it got busy doing GGA and/or GSV sentences).  This results in the time not being updated every second.  The new version still has this problem.

2\. Much worse, it reported incorrect fractional minutes of latitude and longitude.  This is because it assumed the GPS sentence contained exactly four digits of fraction.  Not so for the PAM-7Q RMC sentence which contains five digits.  This resulted in my program returning the fraction as ten times the actual value. I patched this by detecting the five digits and rounding and dividing by ten.  I think I know now one reason why people used floating point.

This is a spin receiver for the PAM-7Q GPS.  A dedicated cog constantly monitors the PAM serial out pin and updates a number of variables accordingly.  Time, Date, Day of Week, Latitude, Logitude, Altitude, Speed and Course, and Satellites in View.  A Demo method is included to demonstrate how to fetch and display the variables.  This is all in integer arithmetic.  This uses RMC, GGA (altitude), and GSV (satellites in view) sentences.
