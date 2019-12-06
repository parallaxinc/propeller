{{ date_time_ts.spin

  Bob Belleville

  2007/03/29 - essentially from scratch
          30 - ts_bump, maxm, adj
  2007/04/18 - extract to a single object
          19 - cleanup, test, and complete

  Historically personal computers have used a single
  32 bit integer to count the total seconds from a
  beginning time or epoch and to have routines to
  convert to/from calendar notation.  Time values
  can be easily compared.  Adding or subtracting
  intervals up to many days is easy.  (Although
  adding a month is harder.)

  Various epochs have been used.  Unix used Jan 1, 1970
  and MS-DOS used Jan 1, 1980.  The range of dates
  that can be represented is limited to 2^31 seconds
  for signed arithmetic (as in this implementation.)
  This a bit more than 68 years.

  Astronomers use a so called Julian Day to measure
  calendar time.  It is simply a count of days since
  a base year a long time ago.

  (Note: The term Julian Date is used to represent
  the day number in a given year and is often seen
  in date codes on food and other items.  This is
  not what we use here.)

  Julian Day number 0 was at noon GMT January 1, 4713 BC.
  As I write this the value is 2_454_209.

  This is big number and of little interest to most
  users.  Unix for example subtracts 2_440_588 from the
  JDN to get a 'Epoch Day.'
  
  Multiply the Epoch Day number by 86_400 (the number
  of seconds in a day) and add the number of elapse
  seconds in the current day since midnight and you
  have the current date and time coded in a long.

  Here is a worked example of the use of this object:

  May 2007 has two full moons.  The second is called
  a blue moon.  This definition of a blue moon is an
  error introduced by Sky and Telescope Magazine a
  long time ago which they will never undo.

  (http://en.wikipedia.org/wiki/Blue_moon)

  May 2, 2007 at  3:09 hours (am)
     31, 2007 at 18:04 hours (6:04pm) are both full
  moons.  These are Pacific Daylight time.

  (http://www.griffithobs.org/skyfiles/skymoonphases2007.html)

  jd := toJD(2007,5,2)
    will return 2_454_223
  spd := toSPD(3,9,0)
    will return 11_340
  using the unix epoch (check using http://www.csgnetwork.com/unixds2timecalc.html)
  
    2_454_223 - 2_440_588 -> 13_635 days x 86400 -> 1_178_064_000 + 11_340 -> 1_178_075_340
  so
  tv1 := toETV(2007,5,2,3,9,0)
    will return 1_178_075_340
  and
  tv2 := toETV(2007,5,31,18,4,0)
    will return 1_180_634_640

  The mean period from full moon to full moon is called the
  synodic month and is 29.530_588_853 days (Jean Meeus 1991)

  This is 2_551_443 seconds.  tv1 + 2_551_443 -> 1_180_626_783

  so
  date := dateETV( 1_180_626_783 )
  will return
    date>>16      -> 2007
    date>>8 & $FF -> 5
    date & $FF    -> 31

  and
  time := timeETV( 1_180_626_783 )
    time>>16      -> 15
    time>>8 & $FF -> 53
    time & $FF    -> 3

  which means that the mean moon is about 2 hours earlier
  than the true full moon.

  This shows how the methods are used and provides a test
  case.

  The advantages of this object are:

        Only 79 longs and no data used.
         
        Like other PC date/time systems.
         
        Easy to compute strange intervals.
         
        Easy and very fast to update and compare
        values.
         
        Only 4 bytes to store a full date/time.
         
  The disadvantages are:

        Somewhat complex conversion to and from ordinary
        human calendar values.
         
        Short span of valid years --- about 68 from epoch
        chosen.

  Timing:
  
        The pair of routines dateETV and timeETV take
        460 microseconds to execute.

        The routine toETV takes 270 microseconds to
        convert a calendar date and time to a long.
                 
}}

CON

        _eunix  = 2_440_588     'Julian Day (+0.5) of Jan 1, 1970 the unix epoch
        _edos   = 2_444_240     'Julian Day (+0.5) of Jan 1, 1980 the ms-dos epoch
        _eprop  = 2_451_545     'Julian Day (+0.5) of Jan 1, 2000 the Propeller epoch?

        _epoch  = _eunix        'take your choice
        
PUB toJD(y,m,d) | jd, lc

{  Henry F. Fliegel and Thomas C. Van Flandern

     jd = ( 1461 * ( y + 4800 + ( m - 14 ) / 12 ) ) / 4 +
          ( 367 * ( m - 2 - 12 * ( ( m - 14 ) / 12 ) ) ) / 12 -
          ( 3 * ( ( y + 4900 + ( m - 14 ) / 12 ) / 100 ) ) / 4 +
          d - 32075
          
     converts calendar year, month and day to a Julian Day number
}

  lc~
  if m =< 2
    lc := -1
  return (1461*(y+4800+lc))/4+(367*(m-2-12*lc))/12-(3*((y+4900+lc)/100))/4+d-32075

PUB toSPD(h,m,s)

''  convert hour, minute and second to seconds per day
''  0..86399

  return h*3600 + m*60 + s

PUB timeETV(etv) | spd, h, m

''  return the time of a epoch time variable as three bytes
''  in a long H:M:S

  spd := etv // 86400
  h   := spd / 3600
  spd -= h*3600
  m   := spd / 60
  spd -= m*60
  return h<<16 | m<<8 | spd  

PUB dateETV(etv)

''  return the date of a epoch time variable as a word and
''  two bytes Y/M/D

  return toCal((etv/86400) + _epoch)
  
PUB toETV(y,mo,d,h,m,s) : n

''  create a epoch time value for the given date and time

  return ( (toJD(y,mo,d) - _epoch) * 86400 ) + toSPD(h,m,s)
  
PUB toCal(jd) | l, n, i, j, d, m, y

{  Henry F. Fliegel and Thomas C. Van Flandern

        l = jd + 68569
        n = ( 4 * l ) / 146097
        l = l - ( 146097 * n + 3 ) / 4
        i = ( 4000 * ( l + 1 ) ) / 1461001
        l = l - ( 1461 * i ) / 4 + 31
        j = ( 80 * l ) / 2447
        d = l - ( 2447 * j ) / 80
        l = j / 11
        m = j + 2 - ( 12 * l )
        y = 100 * ( n - 49 ) + i + l

   converts a Julian Day Number to year, month and day
}
                         
  l := jd + 68569
  n := ( 4 * l ) / 146097
  l := l - ( 146097 * n + 3 ) / 4
  i := ( 4000 * ( l + 1 ) ) / 1461001
  l := l - ( 1461 * i ) / 4 + 31
  j := ( 80 * l ) / 2447
  d := l - ( 2447 * j ) / 80
  l := j / 11
  m := j + 2 - ( 12 * l )
  y := 100 * ( n - 49 ) + i + l
  
  return y<<16 | m<<8 | d 
        
  