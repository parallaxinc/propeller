{{
   Comments:  
}}
CON
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x 

OBJ
  adc  : "mcp3208"

VAR
  
pub main  | level, pause, styleDuration, maxLedsOn, loopCount, leds
  init
  pause := 15 ' quarter a second
  styleDuration := 90
  maxLedsOn := 7
  loopCount :=0

  leds := 0
  dira[0..23]~~
  repeat
      loopCount++
      leds := (loopCount/styleDuration)//maxLedsOn
      level := getLevel
      if leds == 0
         outa[23..0] := fillAll(level)
      else      
        outa[23..0] := fillSome(leds,level)
      waitcnt(clkfreq/pause+cnt)


pri init |c,d,s
c := 25  'clock
d := 26  'data
s := 27  'cs
adc.start(d, c, s, %1111_1111)


'filles the param lsd with ones
pri fillAll(j) :i | z
  i := 0
  if j > 0
    repeat z from 1 to j   step 1
       i := i<<1
       i := i | %1

pri fillSome(count, level):i | z
  i:=0
  if level > 0
    i := fillAll(count)
    i <<= level
    
pri getLevel : maxLevel | i, level, sampleRate, numberOfSamples
    maxLevel := 0
    sampleRate := 20000
    numberOfSamples := 300
    repeat i from 1 to numberOfSamples
        lev := adc.in(0)
        if level > maxLevel
          maxLevel := level
        waitcnt(clkfreq/sampleRate + cnt)
    maxLevel := maxLevel /24  