' HB-25 motor controller object   By CJ
' v1.4                                                            (optional)
'                                      first                        second
' propeller        1KΩ                 HB-25                        HB-25
'    pin ────────────────────  W ────────────────────────────── W
'                 not connected  R                  not connected R
'    GND ──────────────────────  B ────────────────────────────── B
'(propeller ground)              J present                        J removed
'                               +12-power supply for motors      +12-power supply for motors
'                               GND-ground(motor power supply)   GND-ground(motor power supply)
'                                M1-motor terminal───┳──┐_        M1-motor terminal───┳──┐_ ←poor drawing of motor
'                                M2-motor terminal───┻──┘         M2-motor terminal───┻──┘
'
'         IMPORTANT: M1 should be connected to one terminal on the motor you are using, :IMPORTANT
'         IMPORTANT: M2 should be connected to the other terminal on the same motor     :IMPORTANT
'
' New: changed launch procedure for auto cog so that no extra step is required once configured
'
var
  long hb_stack[20]              'stack space for auto refresh cog
  long motor1, motor2            'raw pulsewidth holders
  byte pin, mode, cog, state     'configuration bytes


pub config(pin1, mode1, state1)  'pin, 0-single 1-dual, 0-manual 1-auto refresh, returns ID of refresh cog

  if (not state) and state1   'clears cog influence when transitioning from manual state to auto state
    dira[pin1]~
    outa[pin1]~
    
  pin  := pin1             'set internal
  mode := mode1            'configuration
  state := state1          'variables
  
  if not state         'get cog ready to pulse and kill any auto cog
    stop
    dira[pin]~~
    outa[pin]~

  if state                  'setup and launch refresh cog in auto mode
    if not motor1           'set motor1 pulsewidth if not set
      set_motor1(1500)
    if not motor2           'set motor2 pulsewidth if not set
      set_motor2(1500)
    if not cog              'launch refresh cog if not already running
      cog := cognew(refresh_cog, @hb_stack) + 1

  return cog - 1          'returns cog running refresh code, returns -1 if no refresh cog running

pub set_motor1(pulse1)  'set first HB-25

  pulse1 #>= 1000            'limit pulses to valid values
  pulse1 <#= 2000

  motor1 := ((pulse1 * (clkfreq / 1_000_000)) - 1200) #> 381  'produces pulse widths in clock cycles - spin overhead

pub set_motor2(pulse2) 'set second HB-25(ignored in single mode)

  pulse2 #>= 1000            'limit pulses to valid values    
  pulse2 <#= 2000

  motor2 := ((pulse2 * (clkfreq / 1_000_000)) - 1200 ) #> 381 'produces pulse widths in clock cycles - spin overhead      

pub pulse_motors    'send pulse(s) to HB-25(s)

  outa[pin]~~              'pulse for                                              
  waitcnt(motor1 + cnt)    'first HB-25                                                
  outa[pin]~                                                                           
  if mode                    'only send second pulse if set to dual mode               
    waitcnt(clkfreq / 500 + cnt) 'wait 2 ms                                            
    outa[pin]~~                 'pulse for                                             
    waitcnt(motor2 + cnt)       'second HB-25                                          
    outa[pin]~                                                                         
  waitcnt(clkfreq / 200 + cnt) 'speed zone (wait for holdoff period)        

pri stop         'stops a cog that was previously launched for auto refresh

  if cog
    cogstop(cog~ - 1)
    
pri refresh_cog    'method that is launched into a cog to handle automatic refreshing of the HB-25

  dira[pin]~~
  outa[pin]~   'may be redundant for a freshly launched cog
  repeat
    pulse_motors
    waitcnt(clkfreq / 50 + cnt)
                            