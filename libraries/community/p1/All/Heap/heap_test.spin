{{
**********************************************
* Heap object test program (spin stamp)      *
* @version 1.0 Jan 2, 2008                   *
* @author Peter Verkaik (verkaik6@zonnet.nl) *
**********************************************
}}


CON
  
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

  HEAPSIZE = 1024

  
OBJ
  debug: "MultiCogSerialDebug"  'debugport serial driver
  mem:   "heap"                 'dynamic memory control

  
VAR
  long atnStack[10]        'stack for monitoring ATN pin
  byte debugSemID          'lock to be used by debug
  byte heapArray[HEAPSIZE] 'byte array to serve as heap
  word block1,block2
  
  
PUB main
  'get lock for debug
  debugSemID := locknew
  'start debug
  case debugPort
    1: debug.start(propRX,propTX,0,9600,debugSemID)
    2: debug.start(stampSIN,stampSOUT,0,9600,debugSemID)
  waitcnt(clkfreq + cnt) 'wait 1 second

  'send welcome message
  debug.cprintf(string("Spin Stamp Heap test program\r"),0,false)
  'monitor ATN pin (optional)
  if debugPort == 2
    cognew(atnReset,atnStack)

  'test heap
  mem.create(@heapArray,HEAPSIZE)
  debug.cprintf(string("HEAPADDR is 0x%04x\r"),@heapArray,false)
  debug.cprintf(string("HEAPSIZE is %d bytes\r"),HEAPSIZE,false)
  debug.cprintf(string("available after create is %d (should be HEAPSIZE-6)\r"),mem.available,false)
  block1 := mem.allocate(55)
  debug.cprintf(string("available after allocate 55 bytes is %d (should be HEAPSIZE-6-55-4)\r"),mem.available,false)
  debug.cprintf(string("BLK1ADDR is 0x%04x (should be HEAPADDR+4)\r"),block1,false)
  debug.cprintf(string("BLK1SIZE is %d bytes (should be 55)\r"),mem.length(block1),false)
  if mem.integrity 'should be OK
    debug.cprintf(string("heap integrity OK\r"),0,false)
  else
    debug.cprintf(string("heap integrity lost\r"),0,false)
  block2 := mem.allocate(763)
  debug.cprintf(string("available after allocate 763 bytes is %d (should be HEAPSIZE-6-55-4-763-4)\r"),mem.available,false) 'should be HEAPSIZE - 5*2 - 4*2 - 56 - 2*2
  debug.cprintf(string("BLK2ADDR is 0x%04x (should be HEAPADDR+4+55+4)\r"),block2,false)
  debug.cprintf(string("BLK2SIZE is %d bytes (should be 763)\r"),mem.length(block2),false)
  if mem.integrity  'should be OK
    debug.cprintf(string("heap integrity OK\r"),0,false)
  else
    debug.cprintf(string("heap integrity lost\r"),0,false)
  mem.free(block1)
  debug.cprintf(string("available after freeing block 1 is %d bytes (should be no change)\r"),mem.available,false) 'should be HEAPSIZE - 5*2 - 4*2 - 56 - 2*2
  if mem.integrity  'should be OK
    debug.cprintf(string("heap integrity OK\r"),0,false)
  else
    debug.cprintf(string("heap integrity lost\r"),0,false)
  mem.free(block2)
  debug.cprintf(string("available after freeing block 2 is %d bytes (should be HEAPSIZE-6)\r"),mem.available,false) 'should be HEAPSIZE - 5*2 - 4*2 - 56 - 2*2
  if mem.integrity  'should be OK
    debug.cprintf(string("heap integrity OK\r"),0,false)
  else
    debug.cprintf(string("heap integrity lost\r"),0,false)
    
  'application starts here
  repeat


PUB atnReset
  repeat 'loop endlessly
    if (debugPort == 2) AND (INA[stampATN] == 1)
      reboot

      