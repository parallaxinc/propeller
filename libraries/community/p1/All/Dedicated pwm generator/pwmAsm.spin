{A simple pwm object based on code from AN001 - propeller counters
 Author: Jev Kuznetsov
 date  : 16 Oktober 2007

 usage

 OBJ
        pwm : pwmAsm

  ....

  pwm.start( Pin)               ' start pwm
  pwm.SetPeriod( period )       ' set pwm period in clock cycles
  pwm.SetDuty( duty)            ' set duty in %                               
  pwm.Stop

}
VAR
  long  cogon, cog       
  long sDuty                     ' order important (the variables are read from memory in this order)  
  long sPinOut 
  long sCtraVal
  long sPeriod
  

PUB Start( Pin) : okay
'start pwm on Pin @ 80 kHz
  longfill(@sDuty, 0, 4)       
  sDuty := 50                   ' default duty
  sPinOut := |< Pin   
  sCtraVal :=  %00100 << 26 + Pin
  sPeriod := 1000
  
  okay := cogon := (cog := cognew(@entry,@sDuty)) > 0    
  
PUB stop

'' Stop object - frees a cog

  if cogon~
    cogstop(cog)
  longfill(@sDuty, 0, 4) 

PUB SetPeriod(counts)
' set pwm period in clock cycles, frequency = (_clkfreq / period)
   sPeriod := counts


PUB SetDuty(counts)
   if (counts < 0)
     counts := 0
   if (counts > 100)
     counts := 100
   sDuty :=counts*sPeriod/100
DAT
'assembly cog which updates the PWM cycle on APIN
'for audio PWM, fundamental freq which must be out of auditory range (period < 50µS)
        org

entry   mov     t1,par                'get first parameter
        rdlong  value, t1
         
        add     t1,#4                 
        rdlong  pinOut, t1
        or      dira, pinOut         ' set pinOut to output      

        add     t1, #4
        rdlong  ctraval, t1
        mov ctra, ctraval              'establish counter A mode and APIN

        add     t1, #4
        rdlong  period, t1


        mov frqa, #1                   'set counter to increment 1 each cycle

        mov time, cnt                  'record current time
        add time, period               'establish next period

:loop   rdlong value, par              'get an up to date pulse width
        waitcnt time, period           'wait until next period
        neg phsa, value                'back up phsa so that it  trips "value" cycles from now
        jmp #:loop                     'loop for next cycle



period  res 1                    
time    res 1
value   res 1
t1      res 1
pinOut  res 1
ctraval res 1
  
