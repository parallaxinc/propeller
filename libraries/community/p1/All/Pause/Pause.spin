CON
  cntMin     = 400
VAR
  long ms
PUB Start
  ms    :=       clkfreq / 1_000
PUB Pause(dur) | clkCycles
  clkCycles := dur * ms-2300 #> cntMin               
  waitcnt( clkCycles + cnt )