{{ servo4.spin - manage up to 4 servos

   08/29/2006 - Bob Belleville
                functional version

   by changing 'ns' and 'start' 1..4 servos can be managed
   the smaller number uses less var space by 11 bytes/servo

   normal servos are driven from a prop pin through a 4.7k resister

   normal servos have 1500ms as the midpoint and a range of at least
   1000ms to 2000ms or perhaps more the variable 'ang' is this
   pulse width

   maintain_servos uses 1 cog to produce the drive signals
   at least one cog must be available to use this object

   with ns=4 each servo is processed once in 20ms but each
   unit is handled 5ms apart in a round of 4

   depending on the slew rate of the servo (and its load)
   wait(unit) many not actually mean the motion is complete

   servos use a lot of current when slewing the move_to command
   can reduce the current shock but when the system initializes
   all 4 servos may slew a considerable way all at once and
   produce a large current spike -- beware
                   
   not tested below 80mhz master clock
   
}}                
CON
  ns = 4
  
VAR
  word  servoAng[ns]            'current angle of servo
  byte  servoPin[ns]            'servo output pin (4.7K)
  long  servoDelta[ns]          'scaled slope of ramp
  word  servoTgt[ns]            'angle at end of ramp
  word  servoCycle[ns]          'ramp cycle count
  long  servoStk[12]            'spin stack in cog
  
PUB start(a0,p0,a1,p1,a2,p2,a3,p3)
'' specify a* in the angular range as an initial position
'' specify a* == 0 to produce no signal
'' p* are the output pins

  servoAng[0] := a0             'use zero to disable
  servoAng[1] := a1             'otherwise initial angle
  servoAng[2] := a2             'nominally 1500 is centered
  servoAng[3] := a3
  servoPin[0] := p0             'meaningless if disabled
  servoPin[1] := p1
  servoPin[2] := p2
  servoPin[3] := p3
  bytefill(@servoCycle,0,ns)    'initially stationary
  cognew(maintain_servos,@servoStk)
    
PUB move_to(unit,ang,cycles)
'' ramp unit to new ang in cycles number of 20ms periods
'' cycles is 1 to ... (word) 50 is 1 sec etc.
'' set ang to zero to turn off servo, old setting will
''   be used as the base ang if a new non-zero ang is given

  if ang == 0
    servoTgt[unit] := servoAng[unit] 'saves last position
    servoAng[unit]~             'turn off signal
    return                      'drive cog will ignore unit now
  if servoAng[unit] == 0        'turn back on
    servoAng[unit] := servoTgt[unit]
  servoTgt[unit]   := ang
  cycles #>= 1                  'bound input to >=1
  servoDelta[unit] := ((ang-servoAng[unit])<<8) / cycles
  servoCycle[unit] := cycles    'set last to sync drive cog
       
PUB is_busy(unit) : flag
'' return not zero if a movement ramp is running

  flag := servoCycle[unit]
  
PUB wait(unit)
'' wait until movement is complete on this unit

  repeat while servoCycle[unit]
      
PUB maintain_servos | w, i, s, p, pp
'' cog routine to maintain servo pulse and ramp from angle to angle

  'dira[5]~~
  p  := clkfreq/(50*ns)
  pp := clkfreq/1_000_000
  repeat i from 0 to constant(ns-1)  'set output on enabled pins
    if servoAng[i]
      dira[servoPin[i]]~~
  w := cnt                        'base of 20ms round
  repeat
    repeat i from 0 to constant(ns-1) 'set each servo 5ms apart
      'outa[5]~~                   '100usec this section (@80mhz)
      w += p                      '5 ms (but each pin sees 20 ms)
                                  'this section ramp from ang to ang
      if servoAng[i] and servoCycle[i]
        if servoCycle[i] == 1          'on last step of ramp
          servoAng[i] := servoTgt[i]   'make sure target is reached
        else
                                       'slope is scaled by 256 and may
                                       'be negative                 
          servoAng[i] := ((servoAng[i]<<8) + servoDelta[i]) >> 8
        servoCycle[i]--           'count down number to use in ramp
      s := servoAng[i]*pp         'pulse with for this servo
      'outa[5]~
      waitcnt(w)                  'wait on cnt to 20ms boundary
      if s                        'if enabled
        outa[servoPin[i]]~~       'set pin
        waitcnt(s+w)              'wait pulse width
        outa[servoPin[i]]~        'clear pin                
         