{

This is the example code for the TAOSDriver. Pins are connected as follows:

0 = PinC = OUT
1 = PinD = LED
2 = PinE = S2
3 = PinF = S3

The method calls are as follows:

taos.getClear(PIN)
taos.getRed(PIN)
taos.getBlue(PIN)
taos.getGreen(PIN)

Where PIN is Pin 0 (OUT)

When running this code, open the Parallax Serial Terminal and set the Buad to 115200. You should see simillar:

Clear = 125
Red = 131
Blue = 512
Green = 142

}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
OBJ
  taos : "TAOSDriver"
  Ser : "Serial"

PUB main

Ser.start(31, 30, 0, 115200)

repeat
  ser.tx(16)    'Clear screen
  ser.str(string("Clear:"))    'Clear sensor readings.
  ser.dec(taos.getClear(0))
  ser.tx(13)
  ser.str(string("Red:"))      'Red sensor readings.
  ser.dec(taos.getRed(0))
  ser.tx(13)
  ser.str(string("Blue:"))     'Blue sensor readings.
  ser.dec(taos.getBlue(0))
  ser.tx(13)
  ser.str(string("Green:"))    'Green sensor readings.
  ser.dec(taos.getGreen(0))
  ser.tx(13)
  
  waitcnt(clkfreq/10 + cnt)