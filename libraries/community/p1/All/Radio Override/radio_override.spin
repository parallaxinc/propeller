obj
servo      : "Servo32Simplified" ' any valid servo object here: can use the cogless 4-servo one if you want
con
RADIO = 1     ' Radio is always used (why?)
PROG = 2      ' Internal program is always used (effectively stops listening to the radio)
OVERRIDE = 3  ' Radio is used unless the radio signal is invalid: if it is, use internal (This is good for "courier" drones that cannot autotakeoff/autoland but can autocruise: default navcom ai hardware setting)
MIX = 4       ' Radio and internal are added together and averaged (this is good for "piloting aid" autopilots)
VAR

byte cog
byte active[32]

long uS
long pin
long synCnt

long pins_address
long pulsewidth_address

long outpins_address
long default_address

long ub
long lb

byte runmode
long stack[20]
long center

byte tv

byte numPins
con NEEDEDVALIDS = 3

PUB Start (np, inputpins_array_address, output_array_address, outputpins_array_address, input_array_address, upperbound, lowerbound)

  uS := clkfreq/1_000_000
  pulsewidth_address := output_array_address
  pins_address := inputpins_array_address
  outpins_address := outputpins_array_address
  default_address := input_array_address
  runmode := OVERRIDE
  ub := upperbound
  lb := lowerbound
  if (upperbound < lowerbound)
    lb := upperbound
    ub := lowerbound

  numPins := np
  center := (ub + lb) / 2
  
  Stop   'call the stop method to stop cogs tha may be already started
  cog := cognew(SoftwareMultiplexer, @stack) + 1

PUB Stop
      servo.stop
      if cog
        cogstop(cog~ -1)

pub mode(type)
    if (type > 0 and type < 5)
        runmode := type

pub set(p,v) ' this is just to let you manually set output pins that may not have input pins associated with it
    servo.set(p,v)
pri SoftwareMultiplexer | i
' init part
  i~
  repeat numPins
    dira[long[pins_address][i]]~
    long[pulsewidth_address][i] := long[default_address][i]                         
    active[i++] := false

  synCnt := clkfreq/4 + cnt
  i~
  repeat until synCnt =< cnt
      active[i] := active[i] | ina[long[pins_address][i]] & (long[pins_address][i] > -1) & (long[pins_address][i] < 32)
      if (++i => numPins)
          i~

  i~ ' some servo objects want preinit, so let's do that
  repeat numPins
      if active[i]
          servo.set(long[outpins_address[i]],long[default_address][i])
    
  servo.start

' loop part, can we do it in assembly? can this be optimized?
  repeat
    if (valid and (runmode <> PROG)) ' radio there? then send pulses as often as we receive them
      i~
      repeat numPins
       if active[i]
        pin := |< long[pins_address][i]
        'waitPEQ(0 , pin,0)                               'wait for low state - don't want to start counting when high
        waitPEQ(pin, pin,0)                           'wait for high
        SynCnt := cnt - 0
        if (runmode == MIX)    ' we're waiting for stuff to happen anyway: might as well set the servo again in case the mixer changed
           servo.set(long[outpins_address][i],(long[pulsewidth_address][i] - center + long[default_address][i]))
        else
           servo.set(long[outpins_address][i],long[pulsewidth_address][i])
        waitPEQ(0, pin,0)                               'wait for low state i.e. pulse ended
        SynCnt := cnt - SynCnt                           
        long[pulsewidth_address][i] := SynCnt/uS
        if (runmode == MIX)    ' now we're using the new receiver value, so use it right after!
           servo.set(long[outpins_address][i],(long[pulsewidth_address][i] - center + long[default_address][i++]))
        else
           servo.set(long[outpins_address][i],long[pulsewidth_address][i++])

    else ' no radio, so spotcheck instead and focus on updating the servos often
      i~
      repeat numPins
       if active[i]
        pin := long[pins_address][i]
        repeat
         ServoDecisionInv
        until ina[pin] == 1                           
        SynCnt := cnt - 0
        repeat
         ServoDecisionInv
        until ina[pin] == 0
        SynCnt := cnt - SynCnt                           
        long[pulsewidth_address][i++] := SynCnt/uS
    

pri ServoDecisionInv | i
    i~
    if (runmode == RADIO)
      repeat numPins
         servo.set(long[outpins_address][i],long[pulsewidth_address][i++])
    else
      repeat numPins
         servo.set(long[outpins_address][i],long[default_address][i++])
pub valid | i ' useful to see if a single-conversion radio is getting a usable signal
    i~
    repeat numPins
        if ((long[pulsewidth_address][i] < lb) | (long[pulsewidth_address][i++] > ub))
            tv~
            return 0
    if ++tv > 250
       tv := 250
    return tv > NEEDEDVALIDS

{
pri ServoDecisionVal | i
    i~
    if (runmode == RADIO or runmode == OVERRIDE)
      repeat numPins
         servo.set(long[outpins_address][i],long[pulsewidth_address][i++])
    else'if ((runmode == MIX))
      repeat numPins
         servo.set(long[outpins_address][i],(long[pulsewidth_address][i] - center + long[default_address][i++]))
'    else ' PROG will never show up so don't bother
'      repeat numPins
'         servo.set(long[outpins_address][i],long[default_address][i++])
}
{
pri ServoDecision(val) | i
    i~
    if (runmode == RADIO)
      repeat numPins
         servo.set(long[outpins_address][i],long[pulsewidth_address][i++])
    elseif ((runmode == OVERRIDE and val))
      repeat numPins
         servo.set(long[outpins_address][i],long[pulsewidth_address][i++])
    elseif ((runmode == MIX and val))
      repeat numPins
         servo.set(long[outpins_address][i],(long[pulsewidth_address][i] - center + long[default_address][i++]))
    else ' PROG
      repeat numPins
         servo.set(long[outpins_address][i],long[default_address][i++])
}        