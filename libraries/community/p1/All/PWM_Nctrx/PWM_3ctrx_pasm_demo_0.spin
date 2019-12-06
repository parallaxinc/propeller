{{
File: PWM_3ctrx_pasm_demo.spin
by Tracy Allen, 22 Aug 2010
revised for pasm 10 Nov 2015

Generates conventional pwm with constant frequency & variable duty cycle
using three cog counters to provide 0-100% on one pin and its complement on the second pin.
The advange of this is that the PWM can operate at a certain setting on its own without a program loop.
Also, the frequency and phase resolution extends to higher frequencies.

The first two counters operate at the same frequency but overlap phase to give 50% to 100% duty cycle.
The Propeller hardware ORs together the two counter outputs to drive the shared pin.
The overlap results in 50% to 100% duty cycle.
The third counter acts as an inverter to give the 50% to 0% complement on another pin.
A pin swapping scheme keeps the full 0% to 100% and 100% to 0% on the complementary output pins.
There are two active cogs.  The original spin cog uses one of its counters as the inverter.
It spawns a pasm cog which sets up and starts the overlapping counters.

Operation is autonomous, without program intervention, once running at the selected
frequency and duty cycle.  A program intervention is only necessary when changing the parameters.
}}

CON

  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  MAX_PHASE_OFFSET = 256
  
VAR
  long cog
  long pw0pin, pw1pin, phaseStep, phaseOffset

OBJ
  pst : "parallax serial terminal"

PUB PwmDemo | myPin, myFrequency, myWidth, ticks, tocks
  pst.start(9600)
  waitcnt(clkfreq/10+cnt)

  pst.Str(string(13,"enter pin (0 to 27): "))
  myPin := pst.decIn
  repeat
    pst.Str(string(13,"enter frequency Hz: "))
    myFrequency := pst.decIn
    pst.Str(string(13,"enter high proportion /256 (0 to 256): "))
    myWidth := pst.decIn
    Start(myPin,myFrequency,myWidth)
    pst.Str(string(13,"started cog "))
    pst.dec(cog-1)
    pst.Str(string(13,"Press space bar to enter new values"))
    repeat until pst.charIn == 32

PUB Start(_pin, _frequency, _width) | pin
  pin := _pin
  phaseStep :=  fraction(_frequency,clkfreq,32) ' later will move this to pasm
  if _width<128                     ' this is the pin swapping logic...
    pw0pin := pin                  ' the pw0pin is the one that will be 0% to 50% high, using the inverter
    pw1pin := pin+1                    ' the pw1pin will be 100% to 50% high, using the main overlap of ctra and ctrb
  else      ' width >=128         ' ..keeps the 0-100% and its complement
    pw0pin := pin+1
    pw1pin := pin
  _width := 128 - _width
  phaseOffset := 16777216 * _width    ' express phase offset in percent
  StartInverter
  if cog
    cogstop(cog-1)
  cog := cognew(@FastPWM, @pw1pin) + 1

PRI StartInverter
  dira[pw1pin]~     ' remember each cog has its own direction registers!
  dira[pw0pin]~~
  ctra := constant(%01001 << 26) + (pw0pin << 9) + pw1pin  '

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

DAT
FastPWM
        mov frqa, #0
        mov frqb, #0
        mov t1,par
        rdlong pwmpin, t1
        add t1, #4
        rdlong f_step, t1
        add t1, #4
        rdlong p_offset, t1

        mov frqa, #0
        mov frqb, #0
        mov t1, #%00100
        shl t1, #26
        or  t1, pwmpin
        mov ctra, t1
        mov ctrb, t1
        mov t1, #1
        shl t1, pwmpin
        or  dira, t1
        mov phsa, #0
        mov t1, f_step
        shl t1, #2
        add t1, p_offset
        mov phsb, t1
        mov frqa, f_step
        mov frqb, f_step
hold    jmp #hold    ' keep counters alive in this cog.
' continue program development here for real time loop updates


pwmpin        res 1
p_offset      res 1
f_step        res 1
t1            res 1





 

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
