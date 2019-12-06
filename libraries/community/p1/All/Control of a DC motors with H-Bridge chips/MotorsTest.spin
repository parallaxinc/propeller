{{
     MotorsTest.spin
     Tom Doyle
     20 Feb 2007

     PWM control of two DC motors controlled by LMD18201 H-Bridge speed control chips
     
     See SetMotor.spin for more information
}}


CON

  _clkmode      =  xtal1 + pll16x                        ' use crystal x 16  (5 x 16 = 80 Mhz)
  _xinfreq      =  5_000_000

  _lcdPin       =     0                                 ' Parallax 4x20 LCD Serial Line 

  ' Electronic Speed Control (ESC) 1
  _esc1Forward      =     1                              ' forward direction
  _esc1Reverse      =     0                              ' reverse direction
  _esc1delayPerStep =    80                              ' ms delay per % change in duty cycle
  _esc1Freq         =  1000                              ' ESC 1  PWM Frequency
  _esc1DirPin       =     7                              ' ESC 1  Direction Line (LMD18201 pin 3) 
  _esc1PwmPin       =     6                              ' ESC 1  PWM Line (LMD18201 pin 4)

  ' Electronic Speed Control (ESC) 2
  _esc2Forward      =     1                              ' forward direction
  _esc2Reverse      =     0                              ' reverse direction
  _esc2delayPerStep =    80                              ' ms delay per % change in duty cycle
  _esc2Freq         =  1000                              ' ESC 1  PWM Frequency
  _esc2DirPin       =     5                              ' ESC 1  Direction Line (LMD18201 pin 3) 
  _esc2PwmPin       =     4                              ' ESC 1  PWM Line (LMD18201 pin 4)


   

OBJ

  debug  : "debug_lcd"
  motor[2] : "SetMotor"


VAR

  ' Motor 1 
  BYTE  cog1

  
PUB main | dutyCycle1, direction1, delay1, dutyCycle2, direction2, delay2
 
    if debug.start(_lcdPin, 9600, 4)                         
      debug.cursor(0)                                    
      debug.backlight(1)                                  
      debug.cls
  

    motor[0].init(_esc1PwmPin, _esc1DirPin, _esc1Freq, 0)   ' initialize SetMotor.spin 0
    motor[1].init(_esc2PwmPin, _esc2DirPin, _esc2Freq, 1)   ' initialize SetMotor.spin 1
     
    repeat

    ' -----------------------------------
      ' Motor 1
      dutyCycle1 := 70
      direction1 :=  _esc1Forward
      delay1     := _esc1delayPerStep
      
      IF ( cog1 :=  (motor[0].setMotor(dutyCycle1, direction1, delay1)))
        displayMotor1( dutyCycle1, direction1, delay1)
      ELSE
        ' no cog is available
        quit

      ' Motor 2
      dutyCycle2 := 0
      direction2 :=  _esc2Reverse
      delay2     := _esc2delayPerStep
      
      IF ( cog1 :=  (motor[1].setMotor(dutyCycle2, direction2, delay2)))
        displayMotor2( dutyCycle2, direction2, delay2)
      ELSE
        ' no cog is available
        quit
         
     waitcnt((clkfreq/1000) * 7000 + cnt)
     
    ' -----------------------------------
      ' Motor 1
      dutyCycle1 := 0
      direction1 := _esc1Forward
      delay1 := _esc1delayPerStep
      
      IF ( cog1 :=  (motor[0].setMotor(dutyCycle1, direction1, delay1)))
        displayMotor1( dutyCycle1, direction1, delay1)
      ELSE
         ' no cog is available
        quit

      ' Motor 2
      dutyCycle2 := 70
      direction2 :=  _esc2Reverse
      delay2     := _esc2delayPerStep
      
      IF ( cog1 :=  (motor[1].setMotor(dutyCycle2, direction2, delay2)))
        displayMotor2( dutyCycle2, direction2, delay2)
      ELSE
        ' no cog is available
        quit
         
     waitcnt((clkfreq/1000) * 7000 + cnt)
             
    ' ------------------------------------
      ' Motor 1    
      dutyCycle1 := 70
      direction1 := _esc1Reverse
      delay1 := _esc1delayPerStep
      
      IF ( cog1 :=  (motor[0].setMotor(dutyCycle1, direction1, delay1)))
        displayMotor1( dutyCycle1, direction1, delay1)
      ELSE
        ' no cog is available
        quit

      ' Motor 2
      dutyCycle2 := 70
      direction2 :=  _esc2Forward
      delay2     := _esc2delayPerStep
      
      IF ( cog1 :=  (motor[1].setMotor(dutyCycle2, direction2, delay2)))
        displayMotor2( dutyCycle2, direction2, delay2)
      ELSE
        ' no cog is available
        quit
         
     waitcnt((clkfreq/1000) * 7000 + cnt)
    

    REPEAT  ' error

PUB  displayMotor1( dut1, dir1, del1)

        debug.clrln(0)
        debug.clrln(1)
        debug.gotoxy(0, 0)
        debug.str(string("Duty1 "))
        debug.dec(dut1)
        IF dir1 == _esc1Forward
          debug.str(string(" Forward"))
        ELSE
          debug.str(string(" Reverse"))          
        debug.gotoxy(0, 1)
        debug.str(string("Delay1 "))
        debug.dec(del1)


PUB  displayMotor2( dut2, dir2, del2)

        debug.clrln(2)
        debug.clrln(3)
        debug.gotoxy(0, 2)
        debug.str(string("Duty2 "))
        debug.dec(dut2)
        IF dir2 == _esc2Forward
          debug.str(string(" Forward"))
        ELSE
          debug.str(string(" Reverse"))          
        debug.gotoxy(0, 3)
        debug.str(string("Delay2 "))
        debug.dec(del2)
          



 