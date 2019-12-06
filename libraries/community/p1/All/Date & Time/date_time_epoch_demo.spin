{{ date_time_epoch_demo.spin

  Bob Belleville

  2007/04/19 - essentially from scratch

  Compile and run this as a top object file.

  Start a terminal emulator on the com port
  used by the Propeller Tool.  Set 8N1 and
  115200 baud.  Open the port and press any
  key when "any key to begin" is shown.

  here (2007) is a good free terminal for this kind of work:
  
  http://www.hw-group.com/products/hercules/index_en.html
  
}}
 
CON

                                'use 80MHz
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

                                  
VAR

          
OBJ

  term  : "serial_terminal"
  dt    : "date_time_epoch"


PUB start | tv, jd, spd, tv1, tv2, date, time
  
  term.start(12)                'start the terminal
  
                                'allow time to get terminal
                                '  running
  repeat while term.getcnb == -1
    term.str(@msg0)
    waitcnt(40_000_000+cnt)     'message about 1/2 sec
                                'until keyboard
  
  term.str(@title)
  term.str(@msg1)

  term.str(string("date/time at zero --- epoch"))
  nl
  showDT(0)
  term.str(string("date/time at end --- 2^31"))
  nl
  showDT($7FFF_FFFF)

  jd := dt.toJD(2007,5,2)
  term.str(string("_eunix should return 2_454_223"))
  nl
  term.dec(jd)
  nl
  
  spd := dt.toSPD(3,9,0)
  term.str(string("_eunix should return 11_340"))
  nl
  term.dec(spd)
  nl

  tv1 := dt.toETV(2007,5,2,3,9,0)
  term.str(string("_eunix should return 1_178_075_340 --- first full moon"))
  nl
  term.dec(tv1)
  nl
  showDT(tv1)
  
  tv2 := dt.toETV(2007,5,31,18,4,0)
  term.str(string("_eunix should return 1_180_634_640 --- second full moon"))
  nl
  term.dec(tv2)
  nl
  showDT(tv2)
  
  term.str(string("date/time of mean second full moon"))
  nl
  showDT(tv1 + 2_551_443)

  term.str(string("any key to run timing loop"))
  nl
  term.str(string("46 seconds to convert 100K time values to date/time"))
  nl
  term.getc
  repeat 100_000
    date := dt.dateETV(tv1)
    time := dt.timeETV(tv1)
    tv1++
  term.str(string("done"))
  nl
    
  term.str(string("any key to run timing loop"))
  nl
  term.str(string("27 seconds to convert 100K date/time to time values"))
  nl
  term.getc
  repeat 100_000
    tv1 := dt.toETV(2007,5,2,3,9,0)
  term.str(string("done"))
  nl
    
  repeat
  

PUB showDT(tv) | date, time

'' send the date and time to term

  date := dt.dateETV(tv)
  term.dec(date>>16)
  term.out("/")
  term.dec(date>>8 & $FF)
  term.out("/")
  term.dec(date & $FF)
  sp
  time := dt.timeETV(tv)
  term.dec(time>>16)
  term.out(":")
  term.dec(time>>8 & $FF)
  term.out(":")
  term.dec(time & $FF)
  nl
    
PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)


DAT

title   byte    "date_time_epoch_demo",13,10,0
msg0    byte    "any key to begin",13,10,0
msg1    byte    "running",13,10,0

