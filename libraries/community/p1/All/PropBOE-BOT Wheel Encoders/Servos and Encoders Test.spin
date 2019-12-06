{{PropBOE Wheel Encoders Test
}}


CON
'Change to set the pins used on the PropBOE-BOT
  LeftServo    = 18
  RightServo   = 19
  LeftEncoder  = 1
  RightEncoder = 0
  
VAR

   
OBJ
  system : "Propeller Board of Education"               ' PropBOE configuration tools
  servo  : "PropBOE Servos"                             ' Servo control object
  pst    : "Parallax Serial Terminal Plus"
  time   : "Timing"                                    ' Timing convenience methods
  Wheels : "PropBOE Wheel Encoders"                     'Read routines for Wheel Encoders                        
PUB Go
'Set the Clock Speed
  System.clock(80_000_000)
'Start the Wheel Encoder
  Wheels.Start(RightEncoder,LeftEncoder)
'Start the Servos  
  servo.Set(LeftServo, 20)                                
  servo.Set(RightServo, -20)
'Report the results
  repeat 50
    pst.clear
    pst.str(string("Right:"))
    pst.dec(Wheels.ReadRight)
    pst.NewLine
    pst.str(string("Left: "))
    pst.dec(Wheels.ReadLeft)
    time.pause(500)
'Test the Reset Method
  Wheels.Reset
  pst.clear
  pst.str(string("Reset Sent"))
  pst.NewLine
  pst.str(string("Right:"))
  pst.dec(Wheels.ReadRight)
  pst.NewLine
  pst.str(string("Left: "))
  pst.dec(Wheels.ReadLeft)
  time.pause(3000)
'Report the results                                  
  repeat 50
    pst.clear
    pst.str(string("Right:"))
    pst.dec(Wheels.ReadRight)
    pst.NewLine
    pst.str(string("Left: "))
    pst.dec(Wheels.ReadLeft)
    time.pause(500)
