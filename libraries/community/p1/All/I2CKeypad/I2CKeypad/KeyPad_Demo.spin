{{
   SEE I2cKeyPad object for keypad/MCP23008 schematic
}}

CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq               ' system freq as a constant
  MS_001   = CLK_FREQ / 1_000                                   ' ticks in 1ms
  US_001   = CLK_FREQ / 1_000_000                               ' ticks in 1us 

'pin assignments
  interrupt     = 0           'MCP23008 INT pin to propeller
  i2cSCL        = 1 
  i2cSDA        = 2 

  MCP23008_Addr = %0100_0000
  bSize = 5            'circular buffer size plus 1 (keep one slot open)  
  
VAR
  long useser           ' USB serial connection detected T/F
  long debugsw          ' control output to Parallax Terminal    

  byte keychar

  byte timeout          'seconds for auto-off
  
  long Stack[37]  

  byte kBuff[bSize]     'Circular buffer, keep one slot open
  byte SaveBuff[bSize]
  byte head, tail

OBJ
  KeyPad         : "I2CKeyPad"
  Debug          : "FullDuplexSerial"
       
pub Start | keytime, keysw
  timeout := 5          'time allowed before clearing key buffer

'  dira[interrupt] ~     'set interrupt pin to input
  dira[16..23] ~~       'set QS LEDS to outputs
    
  useser := false
  if ina[31] == 1                      ' RX (pin 31) is high if USB is connected
    Debug.start(31, 30, 0, 115200)      ' ignore tx echo on rx
    useser := true                     ' Debug serial connection is active
    debugsw := true
  else
    outa[30] := 0                      ' Force Propeller Tx line LOW if USB not connected

  waitcnt(clkfreq / 2 + cnt)
  if debugsw == true
    Debug.str(string(16,"Start",13)) ' CLS, disp msg

  KeyPad.Init(MCP23008_Addr, i2cSDA, i2cSCL, false, interrupt, @keychar) 'do NOT drive SCL - using pullups

  keychar := 0
  keysw := false
  repeat
    if keychar <> 0
      KEYtime := cnt                           'set start time when a key is pressed
      keysw := true
'     DisplayChar(keychar)                          ' uses LEDs on Quickstart board to indicate key pressed
      WriteBuff(keychar)        
      keychar := 0
      CopyBuff(@SaveBuff)
    waitcnt(MS_001 * 5 + cnt)
    if keysw == true
      if (cnt - KEYtime) > (timeout * clkfreq)       ' if timeout secs passed ?
'       outa[16..23] := 0                            ' turn off QuickStart LEDs
        keysw := false
        ClearBuff
        
PUB WriteBuff(keybyte)
'add element to circular buffer 
  kBuff[tail] := keybyte
  tail := (tail + 1) // bSize
  if tail == head
    head := (head + 1) // bSize

  if debugsw == true
    debug.tx(keybyte) 
    debug.str(String(" head,tail "))
    debug.dec(head)
    debug.tx(",")
    debug.dec(tail)
    debug.str(String(" count "))
    debug.dec(BuffCnt)
    if IsFull
      debug.str(String(" Full "))
    debug.tx(13)

PUB ReadBuff
'destructive read of buffer
  if IsEmpty
    return
  repeat
'    debug.tx(kBuff[head])
    head :=(head + 1) // bSize
  until head == tail
'  debug.tx(13)

PUB MoveBuff(buffaddr) | idx, tmp
'clears source buffer during copy
  bytefill(buffaddr,0,bSize)
  if IsEmpty
    return
  idx := 0  
  repeat
    byte [buffaddr][idx++] := kBuff[head]
    head :=(head + 1) // bSize
  until head == tail

  if debugsw == false
    return
  debug.str(string("Buffer: "))  
  repeat idx from 0 to bSize - 1
    tmp := byte [buffaddr][idx]
    if tmp == 0
      debug.tx(13)
      quit                 
    debug.tx(tmp)

PUB CopyBuff(buffaddr) | idx, tmp, hd
'does not clear source buffer during copy
  bytefill(buffaddr,0,bSize)
  if IsEmpty
    return
  idx := 0
  hd := head
  repeat
    byte [buffaddr][idx++] := kBuff[hd]
    hd :=(hd + 1) // bSize
  until hd == tail

  if debugsw == false
    return
  debug.str(string("Buffer: "))  
  repeat idx from 0 to bSize - 1
    tmp := byte [buffaddr][idx]
    if tmp == 0
      debug.tx(13)
      quit                 
    debug.tx(tmp)

PUB IsEmpty : result
'return true if buffer is empty
  if tail == head
    result := true
  else
    result:= false

PUB IsFull : result
'return true if buffer is full
  result := (tail + 1) // bSize == head

PUB BuffCnt : result | tmp
'return number of elements in buffer
  tmp := tail
  if tmp < head
    tmp += bSize
  result := tmp - head
        
PUB CLearBuff
  tail := head
  if debugsw == true
    debug.str(string("Buffer cleared",13))

PRI DisplayChar(dispchar)
'indicate key pressed on Quickstart board LEDS
    
  outa[16..23] := 0
  case dispchar
    "1" :
      outa[16] := 1
    "2" :
      outa[17] := 1
    "3" :
      outa[18] := 1
    "A" :
      OUTA[17..16] := %11
    "4" :
      outa[19] := 1
    "5" :
      outa[20] := 1
    "6" :
      outa[21] := 1
    "B" :
      outa[18..17] := %11
    "7" :
      outa[22] := 1
    "8" :
      outa[23] := 1
    "9" :
      outa[16] := 1
      outa[23] := 1
    "C" :
      OUTA[19..18] := %11
    "*" :
      OUTA[18..16] := %111
    "0" :
      OUTA[23..16] := %1111_1111
    "#" :
      OUTA[23..21] := %111
    "D" :
      OUTA[20..19] := %11