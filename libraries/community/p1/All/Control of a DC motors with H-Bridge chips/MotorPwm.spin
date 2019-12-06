{{ 
     MotorsPwm.spin
     Tom Doyle
     20 Feb 2007

     Starts a cog to maintain a PWM signal to the LMD18201 chip
     The direction control pin on the LMD18201 is controlled by the
     forward and reverse procedures
     Speed is controlled by the update procedure

     In normal use it is not necessary to call any of these procedures directly as
     they are called by the SetMotor.spin object
}} 

CON

 _clkmode = xtal1 + pll16x
 _xinfreq = 5_000_000
 

VAR

  long duty, period, pPin, dirM, dPin   ' par access
  
  byte cog

PUB start(pwmPin, dirPin, pulsesPerCycle) : success

    ' pwmPin - esc PWM control pin
    ' dirPin - esc Direction control pin
    ' pulsesPerCycle - pulses per PWM cycle = clkfreq/pwmfreq

    pPin   := pwmPin
    dPin   := 0              
    dPin   := dPin + |< dirPin
    duty   := 0
    period := pulsesPerCycle
    
    reverse   ' initialize dirM
    success   := cog := cognew(@entry, @duty)


PUB stop
{{ set esc PWM pin to off
   stop cog }}
   
    waitpeq(0, |< pPin, 0)
    dira[pPin] := 0  
    if cog > 0
      cogstop(cog)

PUB forward

    dirM := 0

Pub reverse

    dirM := dPin


PUB update(dutyPercent)

    duty := period * dutyPercent / 100

    
DAT

entry                   movi   ctra,#%00100_000
                        movd   ctra,#0

                        mov     addr, par
                        add     addr, #8        ' ESC pwm pin
                        rdword  _pin, addr
                        movs    ctra,_pin

                        mov     temp, #1
                        shl     temp,_pin
                        or      dira, temp

                        mov     addr, par        
                        add     addr, #16        ' ESC direction pin
                        rdlong  directPin, addr                            
                        or      dira, directPin

                        mov     frqa,#1

                        mov     addr, par
                        add     addr, #4         ' pulses per pwm cycle
                        rdlong  _cntadd, addr
                        
                        mov     cntacc,cnt
                        add     cntacc,_cntadd

:loop                   waitcnt cntacc,_cntadd
                        mov     tempDir, outa         
                        or      tempDir, directPin    
                        mov     addr, par             
                        add     addr, #12             ' direction
                        rdlong  direction, addr        
                        xor     tempDir, direction     
                        mov     outa,tempDir          
                        rdlong  _duty,par
                        mov     temp, par       
                        add     temp, #1        
                        rdlong  _duty, temp     
                        neg     phsa,_duty
                        jmp     #:loop

direction               res     1    ' ESC direction
directPin               res     1    ' ESC direction Pin
tempDir                 res     1    ' temp direction
cntacc                  res     1
_duty                   res     1
_cntadd                 res     1
_pin                    res     1
addr                    res     1
temp                    res     1