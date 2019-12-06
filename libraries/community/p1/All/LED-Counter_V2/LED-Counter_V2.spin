{{
''***********************************************
''*  Program LED-Counter_V2.spin
''*  Author: Jon Titus 06-11-2015
''*  Copyright 2015
''*
''*  Program Dependencies:
''*     LM74 Demo Rev 1.spin (this program)
''*       |-> Timing.spin
''*''*
''*  Released under Apache 2 license
''*  A simple binary counter used to test the LEDs
''*  as a first experiment for new Propeller users.
''***********************************************
}}

CON
        _clkmode = xtal1 + pll16x   'Use crystal 1 and PLL with 16x setting
        _xinfreq = 5_000_000        '5 MHz crystal frequency

VAR
  byte LEDCounter                   'Variable for LED counter 
   
OBJ
        MyDelays : "Timing"         'Use objects in Timing.spin
          
PUB Start                           'Start program here
  DIRA[23..16] := %11111111
  repeat                            'Unconditional repeat loop
    OUTA[23..16] := LEDCounter      'Display counter value
    MyDelays.pause1s(1)             'A 1-second delay
    LEDCounter := LEDCounter + 1    'add 1 to the count
                                    'Loop ends here
  '----------end of LED-Counter_V2.spin---------- 
    

  


      
        