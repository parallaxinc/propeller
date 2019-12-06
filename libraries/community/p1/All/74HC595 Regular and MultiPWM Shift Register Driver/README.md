# 74HC595 Regular and MultiPWM Shift Register Driver

By: Dennis Ferron

Language: Assembly

Created: Mar 28, 2009

Modified: June 17, 2013

Easily control several 74HC595 shift registers in series. Now includes a variation which leaves out the PWM feature and instead supports up to 100 chips! Still also includes the multi-PWM driver, which allows you to set PWM frequency and duty cycle for any or all of 32 outputs. The PWM driver remembers whether you've set an output to PWM or a steady high or low value, and manages the PWM outputs for you automatically. Also includes the version 1.0 Simple\_74HC595 object for those who just want to understand how to shift data out to the 74HC595 chip.

If you downloaded the version 2.0 or 2.1 driver, you should download and replace it with the new version 2.2 driver, which has some bugs fixed; see the release notes at the top of the 74HC595\_MultiPWM.spin file for detailed information.
