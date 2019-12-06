CON

  _clkmode      = xtal1 + pll8x  '<--------Change this line, as appropriate, for your setup.                        
  _xinfreq      = 10_000_000     '<--------Change this line, as appropriate, for your setup.

OBJ

  mdm   : "bell202_modem"

PUB  Start

  mdm.start_bp(0)                '<--------Change this line, as appropriate, for your setup.
  waitcnt(cnt + clkfreq / 2)
  repeat
    mdm.outstr(string("!Testing "))
    mdm.outstr(string("ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
    mdm.outstr(string(" de YOUR CALLSIGN", 13)) '<--------Add your callsign here for a radio.
