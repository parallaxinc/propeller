# 24-channel LED driver with 8 bit per channel PWM

By: Alex Hajnal

Language: Spin, Assembly

Created: Mar 28, 2014

Modified: April 3, 2014

**Pulse width modulated LED driver with 24-channels, 8 bits (256 levels) of intensity per channel.**

The driver runs in a single cog (2 cogs if using the I2C slave interface) and uses successive approximation at high frequency to provide flicker-free output.

The driver uses a very simple API: The driver continuously reads intensity values for each channel from a user-supplied 24 byte array.  To set a channel's intensity simply write a byte to the appropriate entry in the array.

Sample code is included both for standalone use and for remote control over I2C.

Example circuits are included for controlling 12V RBG LED modules such as the Ikea Dioder.

This module is hard-coded to output on pins 0 through 23.

**Release history:**

2014-03-28

v1.0

‚Ä¢ Initial release

2014-03-30

v1.1

‚Ä¢ Various bug fixes and other updates to low-level driver ("24-channel PWM.spin")

‚Ä¢ Documentation clean-up and corrections

**Latest version is 24-channel PWM v1.1.zip which contains important bug fixes.**
