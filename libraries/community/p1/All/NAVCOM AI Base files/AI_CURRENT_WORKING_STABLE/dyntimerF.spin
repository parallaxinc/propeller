'' This object provides time delay and time synchronization functions.


CON

        _clkmode                = xtal1 + pll16x
        _xinfreq                = 5_000_000                                                                                       

CON
  
  _10us = 1_000_000 /        10                         ' Divisor for 10 us
  _1ms  = 1_000_000 /     1_000                         ' Divisor for 1 ms
  _1s   = 1_000_000 / 1_000_000                         ' Divisor for 1 s


VAR

  long delay10us
  long syncpoint10us

PUB markSIF(SIValue)
  delay10us := (clkfreq / _10us * SIvalue) #> 381                 ' Calculate 10 us time unit and saves it 
  syncpoint10us := cnt

PUB waitSIF(fudge)                                                 ' waits until we "hit" that. WARNING: this will lock up for a full clock cycle if missed!
   waitcnt(syncpoint10us += (delay10us + fudge))
