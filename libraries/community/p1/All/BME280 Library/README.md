# BME280 Library

By: Michael Burmeister

Language: C

Created: Apr 15, 2018

Modified: May 1, 2019

This is a library written in C that commuicates with the BME280 sensor from Adafruits.

The library uses i2c to communicate with the sensor and provides Temperature, Humidity, and Barametric pressure.

This sensor requires a lot of math to built the data for these sensors and doing this in integer math is complicated.

The library also has a define to use floating point as well.

enjoy

Mike

Updated code so that if the sensor is not found the code would not hang.  Added documentation for functions.
