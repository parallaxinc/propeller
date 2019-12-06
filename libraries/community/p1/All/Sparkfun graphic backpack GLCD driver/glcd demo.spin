'' This demo just shows how the device works. Uncomment a line of code to preform the various functions

con
 _xinfreq = 5_000_000
 _clkmode = xtal1 + pll16X



obj

lcd: "Sparkfun 128x64 GLCD"

var



                         

pub main
lcd.start(31,4, 115_000)'' This must be the first display command
''lcd.playdemo
''lcd.drawbox(10, 10, 20, 20)
''lcd.eraseblock(10, 10, 20, 20)'' Must write data to the display first...
''Lcd.changeduty(0)'' off
''lcd.changeduty(100) '' fully on
''lcd.writestring(string("Hello, how are you?"))
''lcd.bin(200, 8)
''lcd.hex(100, 2)   
''lcd.dec(200)

 
  