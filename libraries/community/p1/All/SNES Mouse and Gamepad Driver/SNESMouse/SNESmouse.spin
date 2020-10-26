''***************************************
''*  SNES Mouse + Gamepad Driver v1.0   *
''*  Author: Ada Gottensträter          * 
''*  See end of file for terms of use.  *
''***************************************

' v1.0 - 24 Oct 2020 - original version                                 

VAR

long clk,lch,dat0,dat1 ' pins
long _padstate
long hightime,lowtime
long par_x,par_y,oldx,oldy,par_buttons      

word _devices
byte speed_target,_mouseport,cog

long pollstack[32] ' very tight!

PUB start(clkpin,lchpin,data0pin,data1pin,poll_freq,speed)

'' Start mouse/gamepad driver
'' 
''
''   clkpin   = SNES clock signal
''   lchpin   = SNES latch signal
''   data0pin = SNES Player 1 input
''   data1pin = SNES Player 2 input
''
''   NOTE: this probably won't work if you are not level-shifting these signals from/to 5V...
''    
''   poll_freq = frequency to poll the mouse at - pass zero to start in manual polling mode, 60 +/- 10 otherwise
''   speed     = desired mouse speed. 0 to 2
''     

  stop

  clk := clkpin
  lch := lchpin
  dat0 := data0pin
  dat1 := data1pin

  speed_target := speed
  _padstate~

  hightime := (clkfreq / constant(1_789_773 / 7)) #> 381
  lowtime := (clkfreq / constant(1_789_773 / 7))  #> 381

  ifnot poll_freq
    result := cog := 255
    initio 
  else
    result := cog := cognew(poll_loop(clkfreq/poll_freq),@pollstack) + 1


PUB stop | tmp
  case cog
    1..8: cogstop(cog-1)
    255:
      DIRA[clk]~  
      DIRA[lch]~   
  cog~

PUB poll
'' When in manual polling mode, call this at regular intervals (i.e. VBLANK)

  if cog == 255
    _poll

CON
  SNES_R      = %1000_0000_0000
  SNES_L      = %0100_0000_0000
  SNES_X      = %0010_0000_0000
  SNES_A      = %0001_0000_0000
  SNES_RIGHT  = %0000_1000_0000
  SNES_LEFT   = %0000_0100_0000
  SNES_DOWN   = %0000_0010_0000
  SNES_UP     = %0000_0001_0000
  SNES_START  = %0000_0000_1000
  SNES_SELECT = %0000_0000_0100
  SNES_Y      = %0000_0000_0010
  SNES_B      = %0000_0000_0001

PUB padstate
'' Get gamepad state
  return _padstate

PUB present : type

'' Check if mouse present - valid ~2s after start
'' returns mouse type:
''
''   3 = five-button scrollwheel mouse
''   2 = three-button scrollwheel mouse
''   1 = two-button or three-button mouse
''   0 = no mouse connected

  if _mouseport
    type := 1

PUB mouseport

'' Get controller port to which the mouse is connected:
''
''   0 = no mouse
''   1 = Mouse on Player 1
''   2 = Mouse on Player 2

return _mouseport

CON
#0,DEVICE_NONE,DEVICE_NESPAD,DEVICE_SNESPAD,DEVICE_MOUSE
PUB devices

'' Get connected devices.
'' One byte per port, so use .byte[]
''
'' 0 = nothing/unknown
'' 1 = NES pad
'' 2 = SNES pad
'' 3 = SNES Mouse
  return _devices

CON
#0,BUTTON_LEFT,BUTTON_RIGHT
PUB button(b) : state

'' Get the state of a particular button
'' returns t|f

  state := -(par_buttons >> b & 1)


PUB buttons : states

'' Get the states of all buttons
'' returns buttons:
''
''   bit1 = right button
''   bit0 = left button

  states := par_buttons


PUB abs_x : x

'' Get absolute-x

  x := par_x


PUB abs_y : y

'' Get absolute-y

  y := par_y


PUB abs_z : z
'' Get absolute-z (scrollwheel)
PUB delta_reset

'' Reset deltas

  oldx := par_x
  oldy := par_y


PUB delta_x : x | newx

'' Get delta-x

  newx := par_x
  x := newx - oldx
  oldx := newx


PUB delta_y : y | newy

'' Get delta-y

  newy := par_y
  y := newy - oldy
  oldy := newy


PUB delta_z

'' Get delta-z (scrollwheel)

PUB get_speed
return speed_target

PUB set_speed(s)
speed_target := s

PUB oreooreo

return @pollstack

PRI do_delay
  waitcnt(lowtime+hightime+cnt)
PRI poll_loop(interval) | ntime

  ntime := cnt
  initio
  repeat
    waitcnt(ntime += interval)
    _poll
PRI _poll | i,padtmp0,padtmp1,pads,speedflag,dev0,dev1

  ' First, poll 32 bits of data

  ' initialize
  padtmp0~
  padtmp1~   
  pads~
  dev0~
  dev1~     
  OUTA[clk]~~
  OUTA[lch]~
  do_delay
  OUTA[lch]~~  ' LATCH on
  do_delay
  OUTA[lch]~   ' LATCH off
  do_delay
  
  ' read 32 bits
  'testaaaa := padtmp0  
     
  repeat i from 0 to 31                                                                                                     
    padtmp0 |= INA[dat0] << i
    padtmp1 |= INA[dat1] << i                                                                                                    
    OUTA[clk]~
    waitcnt(lowtime+cnt)
    OUTA[clk]~~
    waitcnt(hightime+cnt)
    if i == 15
      do_delay ' extra delay on 16th bit (NESdev says some mice need this)

  OUTA[clk]~~
  
  ' Invert and reverse data
  !padtmp0
  !padtmp1

  i~    
  
  if     (padtmp0 & $FFFF_FF00) == $FFFF_FF00 ' Player 1 is NES controller
    dev0 := DEVICE_NESPAD
    pads.word[0] := padtmp0 & $FF
  elseif (padtmp0 & $FFFF_F000) == $FFFF_0000 ' Player 1 is SNES controller
    dev0 := DEVICE_SNESPAD
    pads.word[0] := padtmp0
  elseif (padtmp0 & $0000_F0FF) == $0000_8000 ' Player 1 is SNES mouse
    dev0 := DEVICE_MOUSE
    i := 1
    speedflag := handle_mouse(padtmp0)

  if     (padtmp1 & $FFFF_FF00) == $FFFF_FF00 ' Player 2 is NES controller
    dev1 := DEVICE_NESPAD
    pads.word[1] := padtmp1 & $FF
  elseif (padtmp1 & $FFFF_F000) == $FFFF_0000 ' Player 2 is SNES controller
    dev1 := DEVICE_SNESPAD
    pads.word[1] := padtmp1
  elseif (padtmp1 & $0000_F0FF) == $0000_8000 AND NOT i ' Player 2 is SNES mouse (and Player 1 isn't)
    dev1 := DEVICE_MOUSE
    i := 2
    speedflag := handle_mouse(padtmp1)

  if speedflag ' cycle mouse speed
    cycle_speed
    
    
  _devices := dev0 + (dev1<<8)
  _padstate := pads
  _mouseport := i

PRI handle_mouse(bits) | dx,dy

  dx := (bits.byte[3] >< 8)&$7F
  if    bits & |<24
    -dx

  dy := (bits.byte[2] >< 8)&$7F
  ifnot bits & |<16
    -dy

  par_x += dx
  par_y += dy

  par_buttons := (bits & $300)><10

  return speed_target <> (bits& $C00)><12

PRI initio

  DIRA[clk]~~
  DIRA[lch]~~
  cycle_speed

  
PRI cycle_speed
  '' cycle mouse speed
  OUTA[clk]~~
  OUTA[lch]~~ ' LATCH on
  waitcnt(lowtime+cnt)
  OUTA[clk]~     ' Clock pulse
  waitcnt(hightime+cnt)
  OUTA[clk]~~       
  OUTA[lch]~ ' LATCH off
  waitcnt(lowtime+cnt)


{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}