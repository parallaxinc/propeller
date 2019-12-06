' Victor Speed Controller Test

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000 

  time = 1_000_000

OBJ

  motor : "Victor_Speed_Controller"

VAR

  long pulse

PUB up

  motor.start(1, 1, @pulse)
  pulse := 0
  
  repeat
    if pulse == 900
      down
    else
        pulse := pulse + 1
    waitcnt(time + cnt)

PUB down

pulse := 900
repeat
  if pulse == -900
    stop
  else
    pulse := pulse - 2
  waitcnt(time + cnt)

PUB stop

repeat
  if pulse == 0
    pulse := 0
  else
    pulse := pulse + 2
  waitcnt(time + cnt)
  