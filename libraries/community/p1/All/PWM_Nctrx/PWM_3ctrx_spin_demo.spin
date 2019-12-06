{{
File: PWM_3ctrx_spin_demo.spin
by Tracy Allen, 22 Aug 2010
revised for bettery handling of high frequencies 10 Nov 2015

Generates conventional pwm with constant frequency & variable duty cycle
using three cog counters to provide 0-100% on one pin and its complement on the second pin.
The advange of this is that the PWM can operate at a certain setting on its own without a program loop.
Also, the frequency and phase resolution extends to higher frequencies.

The first two counters operate at the same desired frequency but overlap phase.
The Propeller hardware ORs together the two counter outputs to drive the shared pin.
That overlap results in 50% to 100% duty cycle.
The third counter acts as an inverter to give the 50% to 0% complement on a second pin.
A pin swapping scheme keeps the full 0% to 100% and 100% to 0% on the complementary output pins.
There are two active cogs.  The original spin cog uses its ctra and ctrb for the overlapping counters.
In this demo it spawns a second cog and starts a counter in that cog to act as the inverter.
The inverter could be made from any spare cog counter as part of a larger project.

Operation is autonomous, without program intervention, once running at the selected
frequency and duty cycle.  A program intervention is only necessary when changing the parameters.
}}

CON

  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000
  
VAR
   long testfreq, testpercent, pwmstack[10]
   long cog
   byte pwmpin,idx , pwxpin , pwypin, pwxold, command

OBJ
  pst : "parallax serial terminal"

PUB PwmDemo | myPin, myFrequency, myWidth, ticks, tocks
  pst.start(9600)
  waitcnt(clkfreq/10+cnt)

  pst.Str(string(13,"enter pin (0 to 27): "))
  myPin := pst.decIn
  repeat
    pst.Str(string(13,"enter frequency Hz (1 to 500_000): "))
    myFrequency := pst.decIn
    pst.Str(string(13,"enter % high (0 to 100): "))
    myWidth := pst.decIn
    PWMctrx3(myPin,myFrequency,myWidth)
    pst.Str(string(13,"Press space bar to enter new values"))
    repeat until pst.charIn == 32


PUB PWMctrx3(pin,frequency,percent)  ' entry with frequency in Hz
  frequency := fraction(frequency,clkfreq,32)  ' calculate angular frequency
  frqa := frqb := 0
  if percent<50                      ' this is the pin swapping logic...
    pwxpin := pin+1
    pwypin := pin
  else      ' percent >=50           ' ..keeps the 0-100% and its complement
    pwxpin := pin
    pwypin := pin+1
  if pwxpin<>pwxold
    start_pwmInverter
    pwxold := pwxpin 
  percent := 50 - percent            ' adjust for duty cycle, no phsx offset at 50%
  dira[pwxpin]~~                  ' pin is PWM output, pin+1 is helper
  dira[pwypin]~                  ' funny, can't do this here, have to do it in pwinverter??
  ctrb := ctra := %00100 << 26 + pwxpin  ' %0_00100_000_00000000_000000_000_000000  + pwxpin   ' NCO mode counter a & b
  phsb := phsa + (42949673*percent)+(frequency*400)       ' one percent phase lag is 42949672 counts, execution of frqb=value command takes 400 ticks.
  frqa := frequency
  frqb := frequency                 ' same frequency both channels
  ' note that the counter output on pin is the inclusive OR of the two individual outputs

    
PRI start_pwminverter
' spawn cog for inverter, see note, this will usually be tacked onto another cog's code
' in order to utilize a spare cog counter.
  if Cog
    cogstop(Cog~ - 1) 'Stop previously launched cog
  Cog := cognew(pwminverter, @pwmstack) + 1
 

PRI pwminverter
  dira[pwypin]~~     ' remember each cog has its own direction registers!
  dira[pwxpin]~
  ctra := constant(%01001 << 26) + (pwypin << 9) + pwxpin  ' %0_01001_000_00000000_000000_000_000000 + (pwypin<<9) + pwxpin
  repeat
    
PRI fraction (y, x, b) : f                      ' calculate f = y/x * 2^b
' b is number of bits
' enter with y,x: {x > y, x < 2^31, y <= 2^31}
' exit with f: f/(2^b) =<  y/x =< (f+1) / (2^b)
' that is, f / 2^b is the closest appoximation to the original fraction for that b.
  repeat b
    y <<= 1
    f <<= 1
    if y => x    '
      y -= x
      f++


 

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
