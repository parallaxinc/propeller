{{ 
     L298MotorsPwm.spin
     Tom Doyle
     25 Feb 2007

     Starts a cog to maintain a PWM signal to the L298 chip
     The control pins on the L298 are controlled by the forward and reverse procedures
     Speed is controlled by the update procedure

     In normal use it is not necessary to call any of these procedures directly as
     they are called by the SetMotor.spin object
}} 

CON

 _clkmode = xtal1 + pll16x
 _xinfreq = 5_000_000
 

VAR

  long duty, period, pPin, dirM, I1pin, I2Pin   ' par access
  
  byte cog

PUB start(EnPin, In1Pin, In2Pin, pulsesPerCycle) : success

    ' EnPin - L298 Enable Pin
    ' In1Pin - L298 Input 1 Pin
    ' In2Pin - L298 Input 2 Pin
    ' pulsesPerCycle - pulses per PWM cycle = clkfreq/pwmfreq

    pPin   := EnPin
    I1pin  := In1Pin
    I2pin  := In2Pin

    duty   := 0
    period := pulsesPerCycle
    
    reverse                                           ' initialize dirM
    success   := cog := cognew(@entry, @duty)


PUB stop
{{ set esc PWM pin to off
   stop cog }}
   
    waitpeq(0, |< pPin, 0)
    dira[pPin] := 0  
    if cog > 0
      cogstop(cog)

PUB forward

    dirM := !0

Pub reverse

    dirM := 0


PUB update(dutyPercent)

    duty := period * dutyPercent / 100

    
DAT

entry                   movi   ctra,#%00100_000
                        movd   ctra,#0

                        mov     addr, par
                        add     addr, #8        ' L298 Enable (PWM) pin number
                        rdword  _Enpin, addr    ' stored in _EnPin
                        movs    ctra,_Enpin

                        mov     temp, #1
                        shl     temp,_Enpin      ' L298 Enable (PWM) pin
                        or      dira, temp       ' make an output

                        mov     addr, par        
                        add     addr, #16        ' L298 In1 pin
                        rdlong  _In1Pin, addr    ' stored in _In1Pin
                        mov     temp, #1
                        shl     temp,_In1pin     ' L298 In1 pin
                        or      dira, temp       ' make an output

                        mov     addr, par        
                        add     addr, #20        ' L298 In2 pin
                        rdlong  _In2Pin, addr    ' stored in _In2Pin
                        mov     temp, #1
                        shl     temp,_In2pin     ' L298 In2 pin
                        or      dira, temp       ' make an output


                        mov     frqa,#1

                        mov     addr, par
                        add     addr, #4         ' pulses per pwm cycle
                        rdlong  _cntadd, addr                        
                        mov     cntacc,cnt
                        add     cntacc,_cntadd                       

:loop                   waitcnt cntacc,_cntadd

                        mov     tempDir, outa

                        mov     addr, par             
                        add     addr, #12          ' dirM
                        rdlong  _dirM, addr        ' store in _dirM

                        mov     tempDir, outa
                        
                        mov     temp, #1
                        shl     temp,_In1Pin       ' L298 In1
                        test     _dirM, 1 WZ       ' check if direction = 1
                        muxz    tempDir, temp         ' set Input 1                        

                        mov     temp, #1
                        shl     temp,_In2Pin       ' L298 In2
                        test     _dirM, 1  WZ      ' check if direction = 1                        
                        muxnz   tempDir, temp      ' set Input 2

                        mov     outa, tempDir
                                  
                        rdlong  _duty,par
                        mov     temp, par       
                        add     temp, #1        
                        rdlong  _duty, temp     
                        neg     phsa,_duty
                        jmp     #:loop

_dirM                   res     1    ' motor direction 0 or 1
_In1Pin                 res     1    ' L298 Input 1 Pin
_In2Pin                 res     1    ' L298 Input 2 Pin
tempDir                 res     1    ' temp direction
cntacc                  res     1
_duty                   res     1
_cntadd                 res     1
_Enpin                  res     1     ' L298 Enable Pin
addr                    res     1
temp                    res     1