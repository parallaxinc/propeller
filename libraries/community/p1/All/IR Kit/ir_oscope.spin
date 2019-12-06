{{ ir_oscope.spin

  Bob Belleville

  This object receives input from an IR remote and produces
  a stream of "." and "0" on the tv_terminal to make a
  very rough check of prop connections and the ir remote.
  Using a "." instead of 1 makes the 0s stand out.
  
  see readme.pdf for more documentaton

  2007/02/27 - derived from showbit_demo.spin
               and tv_terminal_demo.spin

}}
 
CON

        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        irpin   = 0             'IR receiver module input pin
        
VAR


OBJ

        term    : "tv_terminal"


PUB start | code, repeated

  'start the tv terminal
  term.start(12)

  dira[irpin]~                      'input on p0 (0 clear)
  repeat
    if ina[irpin]                   'adjust for a different pin
      term.out(".")
    else
      term.out("0")  
