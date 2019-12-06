CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  Delay = 300_000

OBJ
  Motor: "stepper"

PUB Main

  Motor.Start(0,Motor#HighTorq)
  repeat
    if INA[4] == 0
      Motor.StepDir(0)
    if INA[5] ==0
      Motor.StepDir(1)
    waitcnt(Delay + cnt)

