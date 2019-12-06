{{
  See the circuit in readme.spin

  Imagine the 4 leds arranged in a circle. When you click an LED, it toggles
  its state and the two LEDs around it. Can you make all the LEDs light up?
  And after you light them up, can you make them all turn off.
}}
CON
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x 

OBJ

  dbg:    "debug"
  leds:   "4LEDS"
  sw:     "4Switches"
  func:    "FunLib"
var
byte i1
byte i2

pub main | ledsState, in1
    dbg.init
    sw.pins(20,23)
    leds.pins(7,4)
    ledsState := 0
    repeat
       leds.show(ledsState)
       sw.wait
       in1 := sw.location
       ledsState := ledsState ^ toggle[in1]
       dbg.print3dec(in1, toggle[in1],0)
    
dat
toggle byte 11,7,14,13    