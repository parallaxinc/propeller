{{
************
*  Timing  *
************

This object provides time delay and time synchronization functions.
}}

CON
  
  _10us = 1_000_000 /        10                   'Divisor for 10 us
  _1ms  = 1_000_000 /     1_000                   'Divisor for 1 ms
  _1s   = 1_000_000 / 1_000_000                   'Divisor for 1 s


VAR
  long Delay
  long SyncPoint
  long ClkCycles
  

PUB Pause10us(Period) 
{{Pause execution for Period (in units of 10 us).}}

  ClkCycles := ((clkfreq / _10us * Period) - 4296) #> 381    'Calculate 10 us time unit
  waitcnt(ClkCycles + cnt)                                   'Wait for designated time


PUB Pause1ms(Period) 
{{Pause execution for Period (in units of 1 ms).}}

  ClkCycles := ((clkfreq / _1ms * Period) - 4296) #> 381     'Calculate 1 ms time unit
  waitcnt(ClkCycles + cnt)                                   'Wait for designated time
  

PUB Pause1s(Period) 
{{Pause execution for Period (in units of 1 s).}}

  ClkCycles := ((clkfreq / _1s * Period) - 4296) #> 381      'Calculate 1 s time unit
  waitcnt(ClkCycles + cnt)                                   'Wait for designated time

  
PUB MarkSync10us(Period)
  Delay := (clkfreq / _10us * Period) #> 381                 'Calculate 10 us time unit 
  SyncPoint := cnt

  
PUB WaitSync  
  waitcnt(SyncPoint += Delay)     