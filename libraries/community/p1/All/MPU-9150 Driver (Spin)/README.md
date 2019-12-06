# MPU-9150 Driver (Spin)

By: Zack Lantz

Language: Spin

Created: Feb 18, 2014

Modified: February 18, 2014

This is a Spin port of the MPU-6050\_PASM driver with updates to support the AK8975 Magnetometer on the MPU-9150.  I have also included alternate start methods that allow the user to set the Accelerometer's G-Force and Gyro's Degrees per Second on boot.  The Magnetometer can be adjusted in the driver's .Spin, deafult setting = 0.3 (Typical).

I have included both my work file (MPU-9150\_Spin) and a basic driver (MPU-9150\_Spin\_Basic).  The Demo uses MPU-9150\_Spin\_Basic for its driver.

\*\*\* I am not a PASM programmer.  This driver would be 10x Faster if it were PASM.  If anyone would like to contribue, please feel free.
