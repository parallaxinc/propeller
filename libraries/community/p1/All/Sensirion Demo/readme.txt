Sensirion Demo v1.0
July 13, 2006

SensirionDemo
-------------
- displays the Sensirion SHT-11 sensor values and calculated values
- using the equations from the Sensirion SHT1x/SHT7x datasheet
- calculates dewpoint according to Sensirion application note
- displays data using vga-text or tv_text

Sensirion
---------
- contains routines to interface with the SHT-11

FloatString
-----------
- modified to add FloatToFormat routine
- FloatToString(single, width, numberOfDecimals)
- e.g. FloatToFormat(pi, 5, 2) would return the string " 3.14"
       FloatToFormat(0,  6, 1) would return the string "   0.0"
- see example of use in SensirionDemo
  

