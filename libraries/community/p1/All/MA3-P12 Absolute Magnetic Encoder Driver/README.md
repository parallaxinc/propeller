# MA3-P12 Absolute Magnetic Encoder Driver

By: Aleks

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

This driver is used for the implementation of the MA3-P12 Absolute Magnetic Encoder as offered by US Digital. In theory, the MA3-P10 is also capable of being driven with this code, as long as it is the version that uses PWM to signal the absolute shaft location. Still in revision mode, the code does work. The only thing even resembling a problem is the fact that it does not return the exact resolution of the product, 0 - 4096, but instead returns a resolution of approximately 20 - 4150. I will update the driver upon revision, but for now it is more than sufficient for operation.
