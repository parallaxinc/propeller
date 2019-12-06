{{
     SetMotors.spin
     Tom Doyle
     20 Feb 2007

     Control of a DC motor with an H-Bridge electronic speed control (ESC) such as the LMD18201
     This should work with other H-Bridge chips that utilize direction and pwm control lines
     
     The init procedure initializes local varibles and starts a PWM loop in a new cog
     
     The setMotor procedure sets the duty cycle (0%-100%), direction and delay per % change in
     duty cycle. The delay per % change in duty cycle allows the motor speed to ramp up and down in
     a smooth manner. The amount of delay to use will depend on the characteristics of the motor
     and the load on the motor. This procedure is operating open loop which means that if the delay
     per % change in duty cycle is not long enough you can over run the motor. The procedure keeps
     track of the direction of the motor and will ramp the speed to 0 before changing direction.
     The setMotor procedure is run in a new cog which waits for any previous operation to quit before
     starting the new one. The setMotor cog is released after the new motor setting has been reached.
     The pwm loop will run constantly in its own cog to keep the motor running at the set duty cycle.

     If you want to watch the details of this object - comment out all the LCD lines in
     MotorsTest.spin. Use only one motor and un-comment the LCD lines in SetMotor.spin. It sure
     would be nice to have some conditional assembly directives.    
     
}}

CON

  _clkmode      =  xtal1 + pll16x                        ' use crystal x 16  (5 x 16 = 80 Mhz)
  _xinfreq      =  5_000_000

  _lcdPin       =     0                                  ' Parallax 4x20 LCD Serial Line

  ' ESC Values
  _escForward  =      1                                  ' forward direction
  _escReverse  =      0                                  ' reverse direction

  
OBJ

  debug   : "debug_lcd"                                  ' Parallax 4x20 LCD for debugging
  pwm[2]  : "MotorPwm"                                    ' Motor PWM object     


VAR

  long  Stack[50]
 
  WORD  dutyCycleOld                          ' previous duty cycle value for ramp calculations
  WORD  directionOld                          ' previous directon value for reverse control
  BYTE  motorCog                              ' cog ID for setMotor
  WORD  escFreq                               ' ESC Frequency
  BYTE  pwmIndex                              ' pwm.spin index


PUB init(pwmPin, dirPin, Freq, pIndex) | pulsesPerCycle

{{
    initialize electronic speed control
    start pwm object in a new cog
}}

    escFreq := Freq
    pwmIndex := pIndex
    dutyCycleOld := 0
    directionOld := _escForward
    pulsesPerCycle := clkfreq / escFreq
    pwm[pwmIndex].start(pwmPin, dirPin, pulsesPerCycle )
    pwm[pwmIndex].reverse     
    motorCog := 0


PUB setMotor(duty, Direction, delayPerStep) : success

    ' return value is cog 0-8 where 0 is no cog

    REPEAT        
    WHILE motorCog > 0  ' wait for end of previous operation

    success := (motorCog := cognew(csetMotor(duty, Direction, delayPerStep, @dutyCycleOld, @directionOld), @Stack) + 1)


PRI csetMotor(duty, Direction, delayPerStep, adrDCold, adrDirOld) | tempFreq, tempDuty, lDutyCycleOld, lDirectionOld

{{ 
  if debug.start(_lcdPin, 9600, 4)                      
    debug.cursor(0)                                    
    debug.backlight(1)                                  
    debug.cls
    debug.gotoxy(0, 0)
    debug.str(string("Motor1 "))

  if Direction == _escForward
    debug.str(string("Forward "))
    debug.dec(duty)
    debug.str(string("  "))
  ELSE
    debug.str(string("Reverse "))
    debug.dec(duty)
    debug.str(string("  "))
}}
    
  lDutyCycleOld := word[adrDCold]
  lDirectionOld := word[adrDirOld]


  IF (Direction <> lDirectionOld) AND (lDutyCycleOld > 0) ' stop motor before reversing
{{
    debug.gotoxy(0, 1)
    debug.str(string("Reverse Stop: "))
}}    
  
    REPEAT
    
      lDutyCycleOld :=  lDutyCycleOld - 1
      
      tempFreq := escFreq
      tempDuty := lDutyCycleOld
      
{{
      debug.gotoxy(14, 1)
      debug.dec(tempDuty)
      debug.str(string("   "))
}}
      pwm[pwmIndex].update(tempDuty)
      
      waitcnt(((CLKFREQ/1000) * delayPerStep) + cnt)
      
    WHILE  lDutyCycleOld > 0
{{
  debug.gotoxy(0, 1)
  debug.str(string("                 "))
}}

  if Direction == _escForward
    pwm[pwmIndex].forward

  if Direction == _escReverse
    pwm[pwmIndex].reverse

  lDirectionOld := Direction

  REPEAT  
    tempFreq := 1000  

    IF lDutyCycleOld <  duty   
      lDutyCycleOld :=  lDutyCycleOld + 1
{{      
      debug.gotoxy(0, 1)
      debug.str(string("Accelerate: "))
}}

    IF lDutyCycleOld >  duty  
      lDutyCycleOld :=  lDutyCycleOld - 1
{{     
      debug.gotoxy(0, 1)
      debug.str(string("Decelerate: "))
}}     
    tempDuty := lDutyCycleOld
{{
    debug.dec(tempDuty)
    debug.str(string("  "))
}}
    pwm[pwmIndex].update(tempDuty)

    waitcnt(((CLKFREQ/1000) * delayPerStep) + cnt)
    
  WHILE  lDutyCycleOld <> duty

  lDutyCycleOld := duty
{{
  debug.gotoxy(0, 1)
  debug.str(string("                "))
  debug.gotoxy(0, 1)
  debug.str(string("Hold: "))
  debug.dec(duty)
  waitcnt(10_000 + cnt)   ' wait for LCD module
}}  
  word[adrDCold] := lDutyCycleOld
  word[adrDirold] := lDirectionOld

  cogstop(motorCog~ - 1)  ' stop cog and update cog variable

    