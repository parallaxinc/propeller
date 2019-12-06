'' *******************
'' *  PC_Debug_Test  *
'' *******************


CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000                             ' external xtal is 5 MHz

  CR            = 13
  FF            = 12
  LF            = 10
  Space         = " "

  
OBJ

  debug : "pc_debug"


PUB main | idx

  debug.start(460_800)                                  ' start terminal
  debug.str(string(FF, "Debug Test", CR, LF, LF))       ' print string

  repeat 
    debug.hex(idx, 2)
    debug.out(Space)
    if ((++idx // 16) == 0)
      debug.crlf
  until (idx == $100)

  debug.crlf
  debug.dec(-1)
  debug.crlf
  debug.ibin(-1, 32)
  debug.crlf
  debug.ihex(-1, 8)
  debug.stop                                            ' shutdown debug (uart) cog

