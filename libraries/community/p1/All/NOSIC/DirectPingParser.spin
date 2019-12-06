'
' This object reads four ping sensors and can do so either in its own cog or in shared mode.
'
' Any number of objects can reference this since you're allowed to only start one anyway. The extra cog will run/stop according to the most recent decision.


dat

cog long 0

dataddr long 0

scale long 1.0

tempvar long 0

frq long 0

PingStack long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
con

' actual sensor pins -- can we assume that the hardware doesn't change during execution? ;)
  TO_IN = 73_746                                                                
  TO_CM = 29_034

  TO_CM_FLOAT = float(1_000)/float(TO_CM)                                              
  TO_IN_FLOAT = float(1_000)/float(TO_IN)
  TO_M_FLOAT  = float(10)/float(TO_CM)                                        

con

  PIN_RF = p#PING_RF
  PIN_LF = p#PING_LF ' 18
  PIN_RB = p#PING_RB
  PIN_LB = p#PING_LB

obj
    p: "pinout" ' this ust be in EVERY antbot spin file, even if it's not used. Just in case.
    m:"DynamicMathLib" ' we're only using fmul and ffloat here, so this can easily be its own mini-method if need be
pub start(staddr) : okay
  dataddr := staddr
  stop    
  frq := clkfreq/1_000_000

  repeat 
    okay := cog := cognew(pingloop, @PingStack) + 1
  until okay

PUB stop
  if cog
    cogstop(cog~ - 1)

pub setscale(sc)
    scale := sc
  
con floatcm = 1_000.0 / 29_034.0
pri pingloop | cnt1, cnt2 

                              
m.forceslow

repeat
   cnt1 := cnt

   long[dataddr+00] := TicksF(PIN_LF)

   long[dataddr+04] := TicksF(PIN_RF)

   long[dataddr+08] := TicksF(PIN_LB)

   long[dataddr+12] := TicksF(PIN_RB)
                                                             

   cnt2 := cnt

   cnt2 -= cnt1
   cnt2 := ||cnt2
   cnt2 := cnt2 / frq
   cnt2 >>= 1
   tempvar := m.ffloat(cnt2)
   tempvar := m.fmul(0.001, tempvar)
   long[dataddr+16] := tempvar 

   'long[dataddr+16] := m.fmul(0.001,m.ffloat((||(cnt1 - cnt2) / (clkfreq / 1_000_000)) >> 1)) ' we don't get battery level, so instead, let's get a delta           

{   
PUB Ticks(Pin) : Microseconds | cnt1, cnt2
''Return Ping)))'s one-way ultrasonic travel time in microseconds
  if Pin < 0
    return 29_034_000                                                                               
  outa[Pin]~                                                                    ' Clear I/O Pin
  dira[Pin]~~                                                                   ' Make Pin Output
  outa[Pin]~~                                                                   ' Set I/O Pin
  outa[Pin]~                                                                    ' Clear I/O Pin (> 2 탎 pulse)
  dira[Pin]~                                                                    ' Make I/O Pin Input
  waitpne(0, |< Pin, 0)                                                         ' Wait For Pin To Go HIGH
  cnt1 := cnt                                                                   ' Store Current Counter Value
  waitpeq(0, |< Pin, 0)                                                         ' Wait For Pin To Go LOW 
  cnt2 := cnt                                                                   ' Store New Counter Value
  Microseconds := (||(cnt1 - cnt2) / (frq)) >> 1                ' Return Time in 탎
}

con
tc = 1200 ' at 80mhz: do autoscaling later

PingNotConnected = 999.0 ' allows antbot to run
PingTooFar = 900.0       ' allows antbot to run
PingBroken = -1.0          ' causes estop, as it well should!

PUB TicksF(Pin) : Microseconds | cnt1, cnt2, timeout
''Return Ping)))'s one-way ultrasonic travel time in microseconds
  timeout~
  if Pin < 0
    return PingNotConnected                                                                               
  outa[Pin]~                                                                    ' Clear I/O Pin
  dira[Pin]~~                                                                   ' Make Pin Output
  outa[Pin]~~                                                                   ' Set I/O Pin
  outa[Pin]~                                                                    ' Clear I/O Pin (> 2 탎 pulse)
  dira[Pin]~                                                                    ' Make I/O Pin Input

  repeat
    if ++timeout > tc
         return PingBroken    
  while ina[Pin] == 0

  cnt1 := cnt
  timeout~
  
  repeat
    if ++timeout > tc
         return PingTooFar   
  while ina[Pin] <> 0

  cnt2 := cnt
  timeout~
  

'  waitpne(0, |< Pin, 0)                                                         ' Wait For Pin To Go HIGH
'  cnt1 := cnt                                                                   ' Store Current Counter Value
'  waitpeq(0, |< Pin, 0)                                                         ' Wait For Pin To Go LOW 
'  cnt2 := cnt                                                                   ' Store New Counter Value

  Microseconds := (||(cnt1 - cnt2) / (frq)) >> 1                ' Return Time in 탎
  Microseconds := m.fmul(scale,m.ffloat(Microseconds))
  
  return m.fmul(floatcm,Microseconds)

  
                            