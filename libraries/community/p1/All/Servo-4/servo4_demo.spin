{{ Demonstration of the use of the servo4 object

  08/29/2006 - Bob Belleville first version from scratch

}}

CON

  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

OBJ
  SERVO : "Servo4"

PUB go | unit0

  servo.start(1000,0,1250,1,1500,2,1000,3)
  unit0 := 1
  repeat
    servo.move_to(3,2000,50)    'move two at once
    servo.move_to(1,1500,10)
    servo.wait(3)               'wait on the longest motion
    servo.move_to(3,1000,25)
    servo.wait(3)
    servo.move_to(1,800,20)
    servo.wait(1)               'move one at a time
    if unit0                    'cycle unit 0 on and off
      servo.move_to(0,0,0)      'unit 0 no signal
      unit0~
    else
      servo.move_to(0,1000,0)
      unit0~~