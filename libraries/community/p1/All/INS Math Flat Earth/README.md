# INS Math Flat Earth

By: I.Kövesdi

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

This application demonstrates a 400 Hz INS processor in flat, non-rotating Earth calculations. Strapdown 3D acceleration and 3D rate gyro readings or linear acceleration and angular velocity outputs from flight simulation algorithm (coming soon) are injected by the SPIN program into a uM-FPU V3.1 Floating Point Coprocessor which does the number crunching using quaternion algebra and NED navigation frame related equations. Calling user defined functions in the FPU, the navigation state update cycle time is less than 2.2 msec. The system can integrate in real time the body angular rates and the specific force data of a 6DOF strapdown IMU with 400 Hz data rate.

In this new version a comprehensive set of coordinate transformation utilities is included in the COMP\_INS\_MATH.fpu file.
