{
 File: PWM_traingle_ctrabeat.spin
 Author: Tracy Allen, 21-Aug-2010, 11-Apr-2016

-- Generates conventional PWM that increases and decreases linearly with time
-- Can be filtered to a triangle waveform
-- Uses 2 cog counters in NCO mode directed to the  same output pin, PWM cycle at the beat frequency
   No program loops required for basic operation, cog counters only.
-- Counters in a second cog can provide inverted output,
   and also a lower frequency square wave synchronized to the beat frequency
-- Operation can be viewed on an oscillosope, probes connected to
      pin     main output is PWM varying from 50% to 100% high at the selected frequency
      pin+1    inverse of pin, varies between 0% and 50%
      pin+2    low frequency square wave at that flip flops at the inflection points
-- The second cog is not needed unless you need the inverted signal and/or the beat frequency
   In an applicaton, the second set of cog counters can be patched into an existing cog that does not otherwise need its counter modules.
-- Also see http://obex.parallax.com/object/482, method to set fixed frequency and duty cycle PWM with counters.

}
CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  PIN_DEMO = 17
  FRQX_DEMO = 1073741  ' about 20kHz, frqx = frequency/clkfreq * 2^32
  FRQX_OFFSET_DEMO = 27   ' about 1/2 Hz @ clkfreq 80MHz
  
VAR
  long pwmcog, pwmstack[16]

OBJ

PUB demo
  if pwmcog
    cogstop (pwmcog-1)
  pwmcog := cognew(PWMinverter(PIN_DEMO,FRQX_OFFSET_DEMO),@pwmstack) + 1
  Triangle(PIN_DEMO, FRQX_DEMO, FRQX_OFFSET_DEMO)
  repeat

PUB Triangle(pin, frqx, offset)
  dira[pin]~~
  frqa := frqx
  frqb := frqx+offset
  ctra := %00100 << 26 + pin
  ctrb := %00100 << 26 + pin

PUB PWMinverter(pin,offset)
  dira[pin+1..pin+2]~~    ' new cog has to set the pins as outputs
  ctra := %01001 << 26 + ((pin+1)<<9) + pin ' %0_01001_000_00000000_000101_000_000000 +  wh3pin
  frqb := offset
  ctrb := %00100 << 26 + pin+2  ' %0_01001_000_00000000_000000_000_000000 + (pwypin<<9) + pwxpin
  repeat

