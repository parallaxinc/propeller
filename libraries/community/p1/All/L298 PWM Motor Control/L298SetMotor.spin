{{
     L298SetMotor.spin
     Tom Doyle
     25 Feb 2007

     Control of a DC motor with the L298 motor control chip.
     The L298 chip does not use the traditional PWM, Direction and Brake control lines.
     It uses what it refers to as the Enable line for PWM input and two lines refered to
     as InX and InY for direction, coast and brake functions. The chip contains two controllers
     and is readily available in a kit (L298 Compact Motor Driver) for less
     than $20. The only deal better than this I have found is the Propeller Proto Board.
     
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
     
}}

CON

  _clkmode      =  xtal1 + pll16x                        ' use crystal x 16  (5 x 16 = 80 Mhz)
  _xinfreq      =  5_000_000

  _lcdPin       =     0                                  ' Parallax 4x20 LCD Serial Line

  ' ESC Values
  _escForward  =      1                                  ' forward direction
  _escReverse  =      0                                  ' reverse direction

  
OBJ

  pwm[2]  : "L298MotorPwm"                                    ' Motor PWM object     


VAR

  long  Stack[50]
 
  WORD  dutyCycleOld                          ' previous duty cycle value for ramp calculations
  WORD  directionOld                          ' previous directon value for reverse control
  BYTE  motorCog                              ' cog ID for setMotor
  WORD  escFreq                               ' ESC Frequency
  BYTE  pwmIndex                              ' pwm.spin index


PUB init(EnPin, In1, In2, Freq, pIndex) | pulsesPerCycle

{{
    initialize electronic speed control
    start pwm object in a new cog
}}

    escFreq := Freq
    pwmIndex := pIndex
    dutyCycleOld := 0
    directionOld := _escForward
    pulsesPerCycle := clkfreq / escFreq
    pwm[pwmIndex].start(EnPin, In1, In2, pulsesPerCycle )
    pwm[pwmIndex].reverse     
    motorCog := 0


PUB setMotor(duty, Direction, delayPerStep) : success

    ' return value is cog 0-8 where 0 is no cog

    REPEAT        
    WHILE motorCog > 0  ' wait for end of previous operation

    success := (motorCog := cognew(csetMotor(duty, Direction, delayPerStep, @dutyCycleOld, @directionOld), @Stack) + 1)


PRI csetMotor(duty, Direction, delayPerStep, adrDCold, adrDirOld) | tempFreq, tempDuty, lDutyCycleOld, lDirectionOld

    
  lDutyCycleOld := word[adrDCold]
  lDirectionOld := word[adrDirOld]


  IF (Direction <> lDirectionOld) AND (lDutyCycleOld > 0) ' stop motor before reversing   
  
    REPEAT
    
      lDutyCycleOld :=  lDutyCycleOld - 1
      
      tempFreq := escFreq
      tempDuty := lDutyCycleOld

      pwm[pwmIndex].update(tempDuty)
      
      waitcnt(((CLKFREQ/1000) * delayPerStep) + cnt)
      
    WHILE  lDutyCycleOld > 0

  if Direction == _escForward
    pwm[pwmIndex].forward

  if Direction == _escReverse
    pwm[pwmIndex].reverse

  lDirectionOld := Direction

  REPEAT  
    tempFreq := 1000  

    IF lDutyCycleOld <  duty   
      lDutyCycleOld :=  lDutyCycleOld + 1

    IF lDutyCycleOld >  duty  
      lDutyCycleOld :=  lDutyCycleOld - 1
     
    tempDuty := lDutyCycleOld

    pwm[pwmIndex].update(tempDuty)

    waitcnt(((CLKFREQ/1000) * delayPerStep) + cnt)
    
  WHILE  lDutyCycleOld <> duty

  lDutyCycleOld := duty
  
  word[adrDCold] := lDutyCycleOld
  word[adrDirold] := lDirectionOld

  cogstop(motorCog~ - 1)  ' stop cog and update cog variable

    