''***************************
''*   Heartbeat Demo V1.0   *
''*  Author: Peter Quello   *
''*  Started: 12 JUL 2006   *
''***************************

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  led      = 23
VAR
  long  stack[5]
OBJ
  heart :       "heartbeat"
PUB Start
  cognew(Start_Heart, stack)
PRI Start_Heart
  heart.run(led)