{{
    L298MotorsTest.spin
    Tom Doyle
    25 February 2007

    Hardware:
              ILM-216 2x16 LCD Display - Prop Pin 0 - 9600 Baud
              
              Speed Control 1          - Prop Pin 3   Input 1 (L298 In1 pin 5)
              Speed Control 1          - Prop Pin 4   Input 2 (L298 In2 pin 7) 
              Speed Control 1          - Prop Pin 5   Enable A (L298 EnA pin 6)

              Speed Control 2          - Prop Pin 8   Input 3 (L298 In3 pin 10)
              Speed Control 2          - Prop Pin 7   Input 4 (L298 In4 pin 12)
              Speed Control 2          - Prop Pin 6   Enable B (L298 EnB pin 11)
}}


CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000

    ' Electronic Speed Control (ESC) 1
  _esc1Forward      =     1                              ' forward direction
  _esc1Reverse      =     0                              ' reverse direction
  _esc1delayPerStep =    80                              ' ms delay per % change in duty cycle
  _esc1Freq         =   400                              ' ESC 1  PWM Frequency
  _esc1In1          =     3                              ' Input 1 (L298 In1 pin 5)
  _esc1In2          =     4                              ' Input 2 (L298 In2 pin 7) 
  _esc1EnA          =     5                              ' Enable A (L298 EnA pin 6)

  ' Electronic Speed Control (ESC) 2
  _esc2Forward      =     1                              ' forward direction
  _esc2Reverse      =     0                              ' reverse direction
  _esc2delayPerStep =    80                              ' ms delay per % change in duty cycle
  _esc2Freq         =   400                              ' ESC 2  PWM Frequency
  _esc2In3          =     8                              ' Input 3 (L298 In3 pin 10)
  _esc2In4          =     7                              ' Input 4 (L298 In4 pin 12) 
  _esc2EnB          =     6                              ' Enable B (L298 EnB pin 11)


OBJ

  motor[2] : "L298SetMotor"
  lcd      : "ILM-216_LCD"
  num      : "simple_numbers" 

VAR
   WORD pwServo1                            ' pulse 
   WORD pwServo2

  ' Motor 1 
  BYTE  cog1 

  
PUB main | dutyCycle1, direction1, delay1, dutyCycle2, direction2, delay2

  if lcd.start(0, 9600)                     ' lcd serial pin, baud
                                   
    lcd.cls                                 ' clear display
    lcd.backlight(1)                        ' backlight on
    lcd.cursorOff                           ' cursor off
    lcd.home                                ' home

  'servo.start(1500,1, 1500,2, 0,33, 0,33)    

  lcd.home
  lcd.str(string("Prop-Proto-1"))

  motor[0].init(_esc1EnA, _esc1In1, _esc1In2, _esc1Freq, 0)   ' initialize SetMotor.spin 0
  motor[1].init(_esc2EnB, _esc2In3, _esc2In4, _esc2Freq, 1)   ' initialize SetMotor.spin 1

  repeat

      ' -----------------------------------
      ' Motor 1
      dutyCycle1 := 100
      direction1 := _esc1Forward
      delay1     := _esc1delayPerStep
      
      IF ( cog1 :=  (motor[0].setMotor(dutyCycle1, direction1, delay1)))
        displayMotor1( dutyCycle1, direction1, delay1)
      ELSE
        ' no cog is available
        quit

      ' Motor 2
      dutyCycle2 := 100
      direction2 :=  _esc2Reverse
      delay2     := _esc2delayPerStep
      
      IF ( cog1 :=  (motor[1].setMotor(dutyCycle2, direction2, delay2)))
        displayMotor2( dutyCycle2, direction2, delay2)
      ELSE
        ' no cog is available
        quit
         
     waitcnt((clkfreq/1000) * 9000 + cnt)
     
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
      dutyCycle2 := 0
      direction2 :=  _esc2Forward
      delay2     := _esc2delayPerStep
      
      IF ( cog1 :=  (motor[1].setMotor(dutyCycle2, direction2, delay2)))
        displayMotor2( dutyCycle2, direction2, delay2)
      ELSE
        ' no cog is available
        quit
         
     waitcnt(((clkfreq/1000) * 6000) + cnt)

             
    ' ------------------------------------
      ' Motor 1    
      dutyCycle1 := 100
      direction1 := _esc1Reverse
      delay1 := _esc1delayPerStep
      
      IF ( cog1 :=  (motor[0].setMotor(dutyCycle1, direction1, delay1)))
        displayMotor1( dutyCycle1, direction1, delay1)
      ELSE
        ' no cog is available
        quit

      ' Motor 2
      dutyCycle2 := 100
      direction2 :=  _esc2Forward
      delay2     := _esc2delayPerStep
      
      IF ( cog1 :=  (motor[1].setMotor(dutyCycle2, direction2, delay2)))
        displayMotor2( dutyCycle2, direction2, delay2)
      ELSE
        ' no cog is available
        quit
         
     waitcnt((clkfreq/1000) * 9000 + cnt)
     

      ' ------------------------------------
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
      dutyCycle2 := 0
      direction2 :=  _esc2Forward
      delay2     := _esc2delayPerStep
      
      IF ( cog1 :=  (motor[1].setMotor(dutyCycle2, direction2, delay2)))
        displayMotor2( dutyCycle2, direction2, delay2)
      ELSE
        ' no cog is available
        quit
         
     waitcnt((clkfreq/1000) * 6000 + cnt)
 
    

  REPEAT  ' error

PUB  displayMotor1( dut1, dir1, del1)

        lcd.clrln(0)
        lcd.gotoxy(0, 0)
        lcd.str(string("1 "))
        lcd.str(num.dec(dut1))
        IF dir1 == _esc1Forward
          lcd.str(string(" Fwd "))
        ELSE
          lcd.str(string(" Rev "))
        lcd.str(string("Del "))
        lcd.str(num.dec(del1))



PUB  displayMotor2( dut2, dir2, del2)

        lcd.clrln(1)
        lcd.gotoxy(0, 1)
        lcd.str(string("2 "))
        lcd.str(num.dec(dut2))
        IF dir2 == _esc1Forward
          lcd.str(string(" Fwd "))
        ELSE
          lcd.str(string(" Rev "))
        lcd.str(string("Del "))
        lcd.str(num.dec(del2))

 
  