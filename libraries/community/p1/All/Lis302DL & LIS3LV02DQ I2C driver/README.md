# Lis302DL/LIS3LV02DQ I2C driver

By: Tim Moore

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

Driver for 3-axis accelerometer - LIS302DL/LIS3LV02DQ, using I2C. Simple driver that returns the X,Y and Z acceleration, no filtering applied.  
Updated to support LIS3LV02DQ as well as LIS302DL. Also fixed an issue with -ve acc not being sign extended correctly.
