'' "Wavy Lights" demo for PWMx8. Works with LEDs on Propeller Demo Board.

CON

  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  base_pin      = 16

VAR

  word  value

OBJ

  pwm: "PWMx8"

PUB start | i, duty

' Program to demonstrate the pwm_x8 object.

  pwm.start(base_pin, %1111_1111, 23000)        'Setup for PWM output on pins A16 - A23 at 23KHz.
  repeat
    repeat value from 0 to 511            
      repeat i from 0 to 7
        duty := ((value + (i << 6)) & 511)
        if duty > 255
          duty := 511 - duty
        pwm.duty(base_pin + i, duties[duty]) 

DAT

' These duty values are weighted to provide a better visual response when driving LEDs.

duties  byte      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        byte      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
        byte      0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1
        byte      1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3
        byte      4,  4,  4,  4,  4,  5,  5,  5,  5,  5,  6,  6,  6,  7,  7,  7
        byte      7,  8,  8,  8,  9,  9,  9, 10, 10, 10, 11, 11, 11, 12, 12, 13
        byte     13, 14, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 21
        byte     21, 22, 22, 23, 24, 24, 25, 25, 26, 27, 27, 28, 29, 30, 30, 31
        byte     32, 33, 33, 34, 35, 36, 37, 37, 38, 39, 40, 41, 42, 43, 44, 44
        byte     45, 46, 47, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 59, 60, 61
        byte     62, 64, 65, 66, 67, 69, 70, 71, 72, 74, 75, 76, 78, 79, 81, 82
        byte     83, 85, 86, 88, 89, 91, 92, 94, 95, 97, 98,100,102,103,105,107
        byte    108,110,112,114,115,117,119,121,123,124,126,128,130,132,134,136
        byte    138,140,142,144,146,148,150,152,154,157,159,161,163,165,168,170
        byte    172,175,177,179,182,184,187,189,192,194,197,199,202,204,207,209
        byte    212,215,217,220,223,226,228,231,234,237,240,243,246,249,252,255

  
       