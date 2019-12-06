{{
  See the circuit in readme.spin

  The program will pick two switches at random, can you guess which two these are.
  The leds will flash when you guess correct, and will sweep eft and right if you guess wrong
}}


CON
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x 
OBJ

  leds:   "4LEDS"
  sw:     "4Switches"
  func:    "FunLib"

pub main | rnd   , i

  sw.pins(20,23)
  leds.pins(7,4)

  repeat
    rnd := twoBits[func.getRandom(0,5)] 
    'leds.showTimed(rnd,30)   ' uncomment this line to cheat
    repeat 
      if getInput == rnd
         leds.config(20,10)
         leds.flash
         quit
      else
         leds.config(30,2) 
         leds.side2side
      leds.off

pri getInput | i1, i2
  sw.wait
  i1 := sw.BinaryValue
  leds.showTimed(i1, 30)
  sw.wait
  i2 :=  sw.BinaryValue
  leds.showTimed(i2, 30)
  return i1+i2
      
dat
twoBits  byte 3,5,6,9,10,12