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

        byte  ts[6]             'a time string
          
OBJ

  term  : "serial_terminal"
  dt    : "date_time_ts"


PUB start
  
  term.start(12)                'start the terminal
  
                                'allow time to get terminal
                                '  running
  repeat while term.getcnb == -1
    term.str(@msg0)
    waitcnt(40_000_000+cnt)     'message about 1/2 sec
                                'until keyboard
  
  term.str(@title)
  term.str(@msg1)

  term.str(string("2007/03/30 12:16:45"))
  nl
  showDT(@ts1)
  nl
  
  term.str(string("2100/02/28 23:59:59 (not a leap year)"))
  nl
  showDT(@ts2)
  bytemove(@ts, @ts2, 6)
  term.str(string("add one second"))
  nl
  dt.ts_bump(@ts,5,1,TRUE)
  showDT(@ts)
  nl
  
  term.str(string("2008/02/28 23:59:59 (a leap year)"))
  nl
  showDT(@ts3)
  bytemove(@ts, @ts3, 6)
  term.str(string("add one second"))
  nl
  dt.ts_bump(@ts,5,1,TRUE)
  showDT(@ts)
  nl
  
  term.str(string("2008/1/1 0 hours"))
  nl
  showDT(@ts4)
  bytemove(@ts, @ts4, 6)
  term.str(string("subtract one minute"))
  nl
  dt.ts_bump(@ts,4,0,TRUE)
  showDT(@ts)
  nl
  
  term.str(string("compare 1 to 2, 1 to 1, 2 to 1"))
  nl
  term.str(string("should be -1,0,1"))
  nl
  term.str(string("1: "))
  showDT(@ts1)
  term.str(string("2: "))
  showDT(@ts2)
  term.dec(dt.ts_compare(@ts1,@ts2))
  nl
  term.dec(dt.ts_compare(@ts1,@ts1))
  nl
  term.dec(dt.ts_compare(@ts2,@ts1))
  nl
  nl
  
  term.str(string("any key to run timing loop"))
  nl
  term.str(string("9 seconds to add 1 second to a time string 100K times"))
  nl
  term.getc
  repeat 100_000
    dt.ts_bump(@ts,5,1,TRUE)
  term.str(string("done"))
  nl
    
  repeat
  

PUB showDT(ats)

''  show a time string on the term

        term.dec(byte[ats++]+1900)
        term.out("/")
        term.dec(byte[ats++])
        term.out("/")
        term.dec(byte[ats++])
        sp
        term.dec(byte[ats++])
        term.out(":")
        term.dec(byte[ats++])
        term.out(":")
        term.dec(byte[ats])
        nl
        
PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)


DAT

title   byte    "date_time_ts_demo",13,10,0
msg0    byte    "any key to begin",13,10,0
msg1    byte    "running",13,10,0

ts1     byte    107, 3, 30, 12, 16, 45          '2007/03/30 12:16:45
ts2     byte    200, 2, 28, 23, 59, 59          '2100/02/28 23:59:59 (not a leap year)
ts3     byte    108, 2, 28, 23, 59, 59          '2008/02/28 23:59:59 (a leap year)
ts4     byte    108, 1,  1,  0,  0,  0          '2008/1/1 0 hours
