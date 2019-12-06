{{

┌──────────────────────────────────────────┐
│ MDB_RealTimeClock_001.spin
│ Author: Mathew Boorman,

 Loosley Based on
 Mathew Brown's RealTimeClock.spin V1.01
 Merged with Bob Belleville's date_time_ts.spin for
 date calculations.

 Copyright (c) 2008 Mathew Brown, Mathew Boorman
 See end of file for terms of use.
└──────────────────────────────────────────┘

Lightweight real time clock object.

Callable from any cog, uses shared memory to store variables.
Uses system clock, and a few words of memory. No counters, no COG's.

Bases time/date on the system clock, relies on
being polled at least twice per clock rollover
period. (50 seconds @ 80MHz.)
Repeat one of the calls, e.g. Poll MUST be called frequently enough
or time WILL be LOST.  That is the price for not using dedicated resources.


TODO:
1. Object also NEEDS a ChangeClock method that allows for accurate changes
of the CPU clock.  This is allows the CNT to be read and calculated just before
the clock changes.  Without this a clock change just after a Poll would interpret
all the counts with the wrong CLKFRQ.

2. Define a way of working with subsecond accuracy.  Catalina's 1000'th of a second approach
might be the best.

This clock uses date_time_epoch for date calulcations and includes days in month/leap year day corrections.

See forum thread here for any updates/feedback.
http://forums.parallax.com/forums/default.aspx?f=25&m=363419&g=365213#m365213

------------------------------------------------------
Revision 0.01 changes:-
------------------------------------------------------
}}

                                         
DAT ' shared memory instead of VAR's
    ' Downside is slightly bigger/slower code. Upside is can be used from many Objects.

  ' tracks the time, taking into account clock rollovers
  gLastTime             long 0

  ' time of last Cnt value Used to detect rollover
  gLastCnt              long 0

  gLockId               byte $FF

CON
   UsaDateFormat = false

OBJ
   dte : "date_time_epoch"

Pub Init
  gLockId := LockNew
  ' just dont fail!

{{
   Just read the clock value.

   You need to poll Poll to make this value tick!
}}

PUB Now : out
  return gLastTime

PUB SetETV(y,mo,d,h,m,s)

  Set(dte.toETV(y,mo,d,h,m,s))

PUB Set(newTime)
{
  Set/Initialise the clock.
  If you don't set it, expect time to start from epoch!
  Date is in Seconds.  If you can get it accurate, set it ON
  the second! (ie when user hits 'select')
}


  repeat until not LockSet(gLockId)
    ' empty loop!

  ' set the CNT offset noting its a signed counter
  gLastCnt := CNT + $7f_ff_ff_ff + CLKFREQ
  gLastTime := newTime

  LockClr(gLockId)


PUB ChangeSystemClockMode(newClockThingy)
{
  RTC safe way to change the system clock frequency
  Needs to lock the RTC counters.
  TODO!
}
  repeat until not LockSet(gLockId)
    ' empty loop!

  ' needs to (rescale) gCntOffset to reflect the NEW CLKFREQ
  ' then do the actual change.

  LockClr(gLockId)


PUB Poll: secondChange |nowCnt, secs
{{
  Main Timekeeping method.. Ensure is called frequently

  Returns true if the second has rolled over, so callers can know to redraw screens
  if required.

  Note locking is used to ensure it is safe to call from more than 1 cog.

   Subsecond component is not stored.  The CNT offset is stored when Set is called,
   and is used to adjust CNT to get the subsecond time component.  This offset will
   also be adjusted as required when CLKFREQ is changed.

}}
  nowCnt := CNT

  repeat until not LockSet(gLockId)
    ' empty loop!

  ' Note divide free mechanism... generally expect
  ' to loop at MOST once!
  ' As Bonus 2's complement subtraction handles
  ' rollover soo easy!
  secs := 0

  repeat until (nowCnt - gLastCnt) => CLKFREQ
         secs += 1
         gLastCnt += CLKFREQ

  gLastTime += secs
  LockClr(gLockId)

  return secs <> 0


PUB DateString(ts): StrPtr | ymd 'Returns pointer, to string date,either as UK/USA format
'Has method dependency 'ReadTimeReg' & 'IntAscii'   

  StrPtr := String("??/??/20??")                        'Return string

  ymd := dte.dateETV(ts)

  If UsaDateFormat
    'TRUE .... USA format date string
    IntAscii(StrPtr,    (ymd>>8) & $F)     ' Month
    IntAscii(StrPtr+3,       ymd & $F)      ' Day

  else
    
    'FALSE .... UK format date string
    IntAscii(StrPtr,          ymd & $F)      ' Month
    IntAscii(StrPtr+3,    (ymd>>8) & $F )     ' Day

  IntAscii(StrPtr+8,      ymd > 16)       ' Year (2 digit, 20yy)


PUB TimeString(ts): StrPtr | hhmmss
' Returns pointer, to string time
' UMMM is this in the stack???? SHORT lived ptr!!!!
  StrPtr := String("??:??:??")

  hhmmss := dte.timeETV(ts)

  IntAscii(StrPtr,    hhmmss >> 16)       ' HH
  IntAscii(StrPtr+3, (hhmmss >>  8) & $FF)' MM
  IntAscii(StrPtr+6, (hhmmss      ) & $FF)' SS


PUB DurationString(dur): StrPtr | i
' Returns pointer, to string time
' UMMM is this in the stack???? SHORT lived ptr!!!!
' i.e. use immediately, do NOT pass to another routine!
  StrPtr := String("  0:??")

  repeat i from 5 to 4
    byte[StrPtr][i] := (dur//10) +"0"
    dur /= 10
  repeat while dur > 0 AND i => 0
    byte[StrPtr][--i] := (dur//10) +"0"
    dur /= 10


PRI IntAscii(Pointer,Number) 'Low level conversion of integer 00-99, to two ASCII chars...

  byte[Pointer][0] := (Number/10) +"0"                  'First character is tens (division by 10, + ASCII offset)
  byte[Pointer][1] := (Number//10) +"0"                 'Second character is units (modulus 10 + ASCII offset)



{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}

