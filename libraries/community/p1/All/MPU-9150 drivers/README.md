# MPU-9150 drivers

By: Chris Gadd

Language: Spin, Assembly

Created: Oct 10, 2014

Modified: October 10, 2014

A couple objects for using the InvenSense MPU-9150 9 degree-of-freedom sensor.

The MPU9150 PASM demo archive contains a driver that continuously samples and writes values from the sensor, using a dedicated I2C bus.

The shared archive uses a separate I2C driver, intended for a sensor on an I2C bus with other devices.  The shared archive includes a Spin-based and a PASM-based I2C driver.
