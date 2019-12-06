CON
   
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


obj
LED : "OLED-96-G1"




var
byte val, val2, val3, val4
byte array[8]


pub main'' Welcome to the quick OLED demo. Simply hook up the RX line on the display to Prop pin 0
waitcnt(Clkfreq/2 + cnt)''Give time for system to settle down
LED.start(31, 3, 115000)''Starts display

LED.choosecolor("g")''Chooses color orange

led.setfont(0)''Sets font to 5x7

led.placestring(0, 0, (string("Hello!")), 6)
Waitcnt(clkfreq + cnt)
led.erase

led.placestring(0, 0, (string("Watch me draw a box")), 19)
waitcnt(clkfreq * 2 + cnt)
led.erase
led.rectangle(10, 10, 40, 40)
waitcnt(clkfreq * 2 + cnt)
led.erase
led.placestring(0, 0, (string("Now, Watch me   draw a circle")), 30)
waitcnt(clkfreq * 2 + cnt)
led.erase
led.circle(30, 30, 20 )
waitcnt(clkfreq * 2 + cnt)
led.erase
LED.choosecolor("b")
led.setfont(2)
led.placestring(0, 0, (string("Cool huh?")), 9)


''New section for the new charerase command
waitcnt(clkfreq/100 + cnt)
led.setfont(0)
waitcnt(clkfreq * 2 + cnt)
led.erase
waitcnt(clkfreq/100 + cnt)
led.placestring(0, 0, (string("Watch the 'W'  ")), 15)
waitcnt(clkfreq/100 + cnt) 
led.placestring(0, 1, (string("get erased... ")), 15)
waitcnt(clkfreq * 2 + cnt)
led.erasechar(0,0)'' This command will erase the character at the given column and row
waitcnt(clkfreq + cnt)
led.placestring(0, 3, (string("See that? ")), 15) 