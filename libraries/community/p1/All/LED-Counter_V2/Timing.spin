'' *****************************
'' *  Timing                   *
'' *  (C) 2006 Parallax, Inc.  *
'' *****************************
'' 
'' This object provides time-delay and time-synchronization functions.


CON
  
  _10us = 1_000_000 /        10                         ' Divisor for 10 us
  _1ms  = 1_000_000 /     1_000                         ' Divisor for 1 ms
  _1s   = 1_000_000 / 1_000_000                         ' Divisor for 1 s
  _clkmode = XTAL1 + pll16x
  _xinfreq = 5_000_000

  CLK_FREQ = ((_clkmode-xtal1)>>6)*_xinfreq
  uS_10 = CLK_FREQ / 100_000

VAR

  long delay
  long syncpoint
  long clkcycles


PUB pause10us(period)  | t

'' Pause execution for period (in units of 10 us)
 
  clkcycles := ((clkfreq / _10us * period) - 4296) #> 381    ' Calculate 10 us time unit
  waitcnt(clkcycles + cnt)                                   ' Wait for designated time
  't := cnt
  'repeat period
    'waitcnt( t += uS_10)

PUB pause1ms(period)

'' Pause execution for period (in units of 1 ms).

  clkcycles := ((clkfreq / _1ms * period) - 4296) #> 381     ' Calculate 1 ms time unit
  waitcnt(clkcycles + cnt)                                   ' Wait for designated time
  

PUB pause1s(period)

'' Pause execution for period (in units of 1 sec).

  clkcycles := ((clkfreq / _1s * period) - 4296) #> 381      ' Calculate 1 s time unit
  waitcnt(clkcycles + cnt)                                   ' Wait for designated time

  
PUB marksync10us(period)

  delay := (clkfreq / _10us * period) #> 381                 ' Calculate 10 us time unit 
  syncpoint := cnt

  
PUB waitsync
 
  waitcnt(syncpoint += delay)

      