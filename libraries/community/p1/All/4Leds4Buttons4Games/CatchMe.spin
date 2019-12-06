{{

  See the cicuit in readme.spin
  
  An LED will light at random. Quicly click the buttom that correspond to it.
  You are allowed 5 seconds at the beginning of the game, but this will go down gradually to 1 second.
  The game restarts if you hit the wrong button, or don't hit the right button within the allowed time.
  
}}
CON
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x 

OBJ
  leds:   "4LEDS"
  sw:     "4Switches"
  func:    "FunLib"
                      
pub main | i, j, input
    sw.pins(20,23)
    leds.pins(7,4)  
   
   repeat 
      j := 0
      repeat 
        i := 1 << func.getRandomSeq(0,3)
        leds.show (i)
        sw.waitTimed((5000-j) #> 1000)
        j := j + 300
          input := sw.binaryValue
          if input == 0 or input <> i
             leds.config(20,4)
             leds.side2side
             quit
      