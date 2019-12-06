{
**********************************************
* TableHeap object test program (spin stamp) *
* @version 1.0 Dec 17, 2007                  *
* @author Peter Verkaik (verkaik6@zonnet.nl) *
**********************************************
}


CON
  'application version number
  major = 0
  minor = 0
  build = 0
  
  'clock settings for spin stamp
  _clkmode = xtal1+pll8x
  _xinfreq = 10_000_000
  
  debugPort = 2 '0=none, 1=propeller TX/RX, 2=spin stamp SOUT/SIN/ATN
  
  '//Spin stamp debug pin assignments
  stampSOUT = 16 'serial out (pin 1 of spin stamp)
  stampSIN  = 17 'serial in  (pin 2 of spin stamp)
  stampATN  = 18 'digital in (pin 3 of spin stamp, when activated, do reboot)

  '//Propeller system pin assignments
  propSCL = 28 'external eeprom SCL
  propSDA = 29 'external eeprom SDA
  propTX  = 30 'programming output
  propRX  = 31 'programming input

  
OBJ
  debug: "MultiCogSerialDebug"  'debugport serial driver

  
VAR
  long prog2Stack[50]      'stack for JustAnotherProgram
  long atnStack[4]         'stack for monitoring ATN pin
  byte debugSemID          'lock to be used by debug
  
  
PUB main
  'get lock for debug
  debugSemID := locknew
  'start debug
  case debugPort
    1: debug.start(propRX,propTX,0,9600,debugSemID)
    2: debug.start(stampSIN,stampSOUT,0,9600,debugSemID)
  waitcnt(clkfreq + cnt) 'wait 1 second
  'monitor ATN pin (optional)
  if debugPort == 2
    cognew(atnReset,@atnStack)
  cognew(JustAnotherProgram,@prog2Stack)
  'send welcome message
  debug.cprintf(string("Spin Stamp Application version "),0,true) 'start of compound message
  debug.cprintf(string("%d."),major,true)
  debug.cprintf(string("%d."),minor,true)
  debug.cprintf(string("%d\r"),build,false) 'last of compound message
  debug.cprintf(string("Second line of main program\r"),0,false)
  waitcnt(clkfreq/10 + cnt) 'wait 0.1 second
  debug.cprintf(string("Last line of main program\r"),0,false)
    
  'application starts here
  repeat


PUB JustAnotherProgram
  debug.cprintf(string("Line %d of 2nd program\r"),1,false)
  debug.cprintf(string("Line %d of 2nd program\r"),2,false)
  debug.cprintf(string("Compound message line %d "),3,true)
  debug.cprintf(string("of 2nd program\r"),0,false)
  debug.cprintf(string("Line %d of 2nd program\r"),4,false)
  debug.cprintf(string("Line %d of 2nd program\r"),5,false)
  debug.cprintf(string("Line %d of 2nd program\r"),6,false)
  repeat

  
PUB atnReset
  repeat 'loop endlessly
    if (INA[stampATN] == 1)
      reboot

      