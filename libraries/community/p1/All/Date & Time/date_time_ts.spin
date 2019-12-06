{{ date_time_ts.spin

  Bob Belleville

  2007/03/29 - essentially from scratch
          30 - ts_bump, maxm, adj
  2007/04/18 - extract to a single object
          19 - cleanup, test, and complete        

  This object manages a six byte string as a time struct.

  The bytes are:
        0 - year-1900 (1900..2155 range)
        1 - month 1..12
        2 - day 1..28/29/30/31 as appropiate
        3 - hour of the day 0..23
        4 - minute of the hour 0..59
        5 - second of the minute 0..59

  These routines may be useful for running a clock.
  See date_time_epoch.spin for a somewhat more
  useful object.
  
  Two public routines are available:

  ts_bump(ats,slot,dir,cb)

  This method takes the address of the first byte of a
  time struct 'ats' and adds (dir=1) or subtracts (dir=0)
  one to the field given by slot.  If slot is 5 the
  seconds field is adjusted, 4 the minute, and so on to
  zero for the year.

  If cb is TRUE then the whole string is adjusted for
  any carries or borrows needed to correct the result.

  If cb is FALSE than no carry or borrow is carried out
  and each field can be modified independently.

  ts_compare(ats1,ats2)

  This method compairs two time structs report the result:
  
  return 1 if ats1 >  ats2
         0    ats1 == ats2
        -1    ats1 <  ats2

  The advantages of this object are:

        Only 85 longs of code and no variable space used.
         
        Results are ready to be displayed.
         
        Relatively quick.
         
        Adding a month is easy
         
        256 year span with all leap years accounted for.
         
  The disadvantages are:

        Difficult to add odd intervals such as 29.5 days
        or account for non-hour time zones.
         
        Six bytes used per time struct.
         
        Compare is slower than integer compare.

  Timing:

        Method ts_bump takes 90 microseconds to add 1
        second to a time string.
               
}}

PRI maxm(year,month,dir) : mx

'' Return the maximum number of days in the
'' current month if dir == 1 and the maximum
'' number of days in the previous month if
'' dir == 0
'' corrects for all leap years 1900..2155

  if dir == 0
    month--
                '      D   J   F   M   A   M   J   J   A   S   O   N   D
  mx := lookupz(month: 31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  if month == 2
    if (year & 3) == 0                  'ordinary leap years
      mx++
    if (year == 0) or (year == 200)     'special non leap years
      mx--

PRI adj(a,b,e,dir)
''  makes ts_bump much more compact
  if dir
    if byte[a] => b
      byte[a] := e
      return 1
    else
      byte[a]++
      return 0
  else
    if byte[a] =< e
      byte[a] := b
      return 1
    else
      byte[a]--
      return 0
        
PUB ts_bump(ats,slot,dir,cb) | mx

'' Add or subtract 1 from a time struct
'' ats is the address of a 6 byte date/time struct
'' slot is 0..5 for year .. sec
'' dir 1 to add 1 and 0 to subtract
'' Carry or borrow propagate by means
''   of recursion if cb is true

  case slot
    5, 4:                       'seconds and minutes
      if adj(ats+slot,59,0,dir) and cb
        ts_bump(ats,slot-1,dir,cb)
      
    3:                          'hours
      if adj(ats+3,23,0,dir) and cb
        ts_bump(ats,2,dir,cb)
      
    2:                          'day
      mx := maxm(byte[ats],byte[ats+1],dir)
      if adj(ats+2,mx,1,dir) and cb
        ts_bump(ats,1,dir,cb)
      
    1:                          'month
      if adj(ats+1,12,1,dir) and cb
        ts_bump(ats,0,dir,cb)
      
    0:                          'year (pin at ends of range
      if dir
        if byte[ats] < 255
          byte[ats]++
      else
        if byte[ats] > 0
          byte[ats]--

PUB ts_compare(ats1,ats2) | i

''  return 1 if ats1 >  ats2
''         0    ats1 == ats2
''        -1    ats1 <  ats2

  repeat i from 0 to 5
    if byte[ats1+i] > byte[ats2+i]
      return 1                   
    if byte[ats1+i] < byte[ats2+i]
      return -1
  return 0
