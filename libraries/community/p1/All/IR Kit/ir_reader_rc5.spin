{{ ir_reader_rc5.spin

  Bob Belleville

  This object receives input from an IR remote which
  uses the Phillips rc5(x) format and places valid
  keycodes into a FiFo buffer.

  A document for this format was here (early 2007):
    http://www.sbprojects.com/knowledge/ir/rc5.htm

  Keycodes can then be removed and used in an application.
  This buffer is sized below by the _qsize CON.  Unless the
  application goes off for a very long time without calling
  fifo_get, 8 or 16 bytes is more than enough.

  A single cog is used to watch for input.  A cog, a pin,
  and a single lock bit must be available for this object
  to function.

  basic use is to:
    import this object
    init(pin, 0 or deviceID, repeatDelay, markRepeat)
    key := fifo_get
    if key == -1
      there isn't any new key
    else
      use key to do some thing

  see ir_reader_demo.spin for one example

  to modify for another kind of remote protocol:
    replace get_code/and perhaps get_pair
    
  see readme.pdf for more documentaton

  2007/03/04 - derived ir_reader_nec.spin

}}
 
CON

        _bit    = 142_240       'bit time at 80MHz
        _bit4   =  35_560       '1/4 bit time
        _rc5    = true          'adjust key code for rc5 if true else rc5x

        _qsize  = 8             'must be a power of 2 (2,4,8,16,32,64,128,256 only)
        _qsm1   = _qsize-1      'mask 

VAR

        long    lastvalid       'last valid code
        word    deviceID        'valid input device or
                                '  zero for any
                                '  get using ir_view for example
        long    lastcnt         'CNT at end last valid char
        byte    repeatlag       'ignore this many before
                                '  putting repeats in queue
        byte    repeatmark      'set high bit of repeated keycodes
                                '  if requested                                
        byte    irpin           'which pin to use

                                'fifo for key codes                                
        byte    lock            'hub lock index
        byte    head            'head (put) index for fifo
        byte    tail            'tail (get) index for fifo
        byte    fifo[_qsize]    'buffer itself

        long    stack[20]       'for input cog
        
PUB init(pin, device, repeatdelay, markrepeat) | cog
{{
  pin         - port A input pin where IR receiver module is wired
  device      - 16 bit valid device code or 0 for any NEC device
  repeatdelay - number of repeated input codes to skip before
                adding last valid code to queue
  markrepeat  - true to set high bit of repeated key codes else
                not modified                

  returns cog number if running or -1 if failed              
}}
  irpin     := pin
  deviceID  := device
  repeatlag := repeatdelay
  if markrepeat
    repeatmark := $80
  else
    repeatmark~
  lastcnt := cnt                'used to find repeat codes
  dira[irpin]~                  'input from pin (0 clear = input)
  lock      := locknew          '!must have 1 lock available
  if lock == -1
    return -1
  fifo_flush                    'setup fifo
  lastvalid := $F000_000        'no last valid code
  cog := cognew(receive_ir,@stack)
  if cog == -1                  '!must have 1 cog available
    lockret(lock)               'clean up since cannot be used
    return -1
  return cog                    'all ok - off we go
  
PRI receive_ir | code, repeated
{{
  enqueue all valid keycodes
}}
  repeat
    code := get_code
                                'code is a repeat
    if code == $8000_0000 and lastvalid <> $F000_000
      repeated++
      if repeated > repeatlag   'copy to queue after lag
        fifo_put((lastvalid>>16 & $FF) | repeatmark )
    else
      if deviceID               'accept only one device
        if deviceID <> code & $FFFF
          lastvalid := $F000_000
          next                  'some other remote
      fifo_put(code>>16 & $FF)  'to buffer
      repeated~
      lastvalid := code

PRI get_code | time, code  
{
  wait for and return the next valid ir code
  return (in hex) either 0TKKDDDD new code
                  or     80000000 repeat
  where DDDD is the 16 bit device ID
        KK   is the 8  bit key code
        T    is the toggle bit
             T bit is the same for repeated codes
             and toggles with each new button press                  
}
  repeat
    code~                       'shift bits to code
    waitpeq(0,|<irpin,0)        'wait for a start burst
    time := cnt + _bit4          'center on second half bit cell
    repeat 14                   'rc5 or rc5x
      waitcnt( time += _bit )   'wait one bit time
      code <<= 1                'msb sent first
      if not ina[irpin]         'low is a 1 bit
        code |= 1
    code := (code & $1000)<<12 | (code & $7F)<<16 | (code & $F8)>>7
    if lastvalid <> $F000_000 and lastvalid & $1_00_0000 == code & $1_00_0000
      return $8000_0000
    if _rc5                     'adjust to 6 bit key code
                                '  rc5x is 7 bit
      code := code & $FF00_FFFF | (code & $FF_0000)>>1
    return code
  

PUB get_lastvalid
''  return lastvalid keycode (may be 0 if not valid)
''  has format KKDDDD (key code & device code)
  return lastvalid
    
PUB fifo_flush
{{
  empty or initialize ir remote input
  first in first out queue
}}
  repeat while lockset(lock)
  head~
  tail~
  lockclr(lock)

PUB fifo_put(code) | len
{{
  if space is available insert code at head of
  fifo and return true
  else return false

  (left public but be careful this is usually
   only called by the input cog)
}}
  repeat while lockset(lock)
  len := head-tail              'needed to correct for 255->0
                                'tail could be at say 254 diff
                                'is neg and not the correct
                                'number of bytes in the queue
  if len < 0
    len += 256
  if len => _qsize
    lockclr(lock)
    return false
  fifo[head++ & _qsm1] := code
  lockclr(lock)
  return true

PUB fifo_get | code
{{
  return next available code
  or -1 if fifo empty
}}
  repeat while lockset(lock)
  if head == tail
    lockclr(lock)
    return -1
  code := fifo[tail++ & _qsm1]
  lockclr(lock)
  return code

PUB fifo_get_lastvalid
''  return lastvalid long to see device gode
  return lastvalid

PUB fifo_debug | ht
''  return fifo head and tail indexes in a long
  repeat while lockset(lock)
  ht := head<<16 | tail
  lockclr(lock)
  return ht