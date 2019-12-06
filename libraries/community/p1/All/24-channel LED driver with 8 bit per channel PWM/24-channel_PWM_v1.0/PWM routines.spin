{{┌──────────────────────────────────────────┐
  │ Wrapper for PWM routines                 │
  │ Version 1.0  2014-03-28                  │
  │ Author: Alex Hajnal (AKH)                │
  │ Copyright (c) 2014 Alexander Hajnal      │
  │ See end of file for terms of use.        │
  └──────────────────────────────────────────┘

}}
OBJ
  LED_PWM   : "24-channel PWM"  ' 24 channel, pulse width modulated LED driver with 8 bits of intensity per channel
  PWM_DEMO  : "PWM demo"        ' Standalone demo of the PWM LED driver
  I2C_PWM   : "I2C PWM"         ' PWM LED driver running as an I2C slave
  I2C_slave : "I2C slave v1.0a" ' I2C slave object written in PASM (original by Chris Gadd, bug fixes by AKH)
  ' "raspberry_pi_i2c_pwm.pl"   ' I2C master example (written in Perl) for use with "I2C PWM"
DAT

PUB blank

DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
