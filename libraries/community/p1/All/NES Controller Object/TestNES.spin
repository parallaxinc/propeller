{{ Nitendo Controller Object test program
  Version:  2.0
  Date: 25 Aug 2006
  Author: John Abshier
  Support:  Propeller forum http://forums.parallax.com
  Revision history:  Version 1.0 supports only NES
                     Version 2.0 supports NES and SuperNES        }}
  
Con
  LATCH = 1
  DATA  = 0
  CLK   = 2
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
{   latch       0 0
    clk         0 0
                0 0
    data        0 0   power
    gnd         0             }
OBJ
  tv  : "TV_Text"
  NES : "NES"
VAR
  long buttons
PUB Main  | type', st, end
  tv.start(12)
  type := NES.Init(LATCH, DATA, CLK)
  if type == NES#NES
    tv.str(string("NES"))
  elseif type == NES#SuperNES
    tv.str(string("SuperNES"))
  else
    tv.str(string("Controller not found"))
    abort  
  waitcnt(5 * CLKFREQ + cnt)
  repeat
'    st := cnt
    buttons := NES.Buttons
'    end := cnt - st
    tv.out($00)
    tv.dec(buttons)
    tv.out($09)
    tv.bin(buttons,16)
    if NES.BtnPressed(NES#UP)
      tv.str(string("  UP"))
    if NES.BtnPressed(NES#LEFT & NES#A)
      tv.str(string("  Left - A"))
    if NES.BtnPressed(NES#LEFT & NES#B)
      tv.str(string("  Left - B"))
    if NES.BtnPressed(NES#LEFT & NES#START)
      tv.str(string("  Left - START"))
    if NES.BtnPressed(NES#A & NES#B)
      tv.str(string("  A - B"))
    waitcnt(CLKFREQ + cnt)