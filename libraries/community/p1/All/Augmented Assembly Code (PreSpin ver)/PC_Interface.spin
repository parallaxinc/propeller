''********************************
''*  PC-Interface Driver v0.3.0  *
''********************************
'' Interface to a connected PC to emulate Keyboard, Mouse and Text-Display.
'' Needs PropTerminal.exe on PC to communicate over the (USB-)serial link.
'' This version needs only 1 Object and 1 Cog, but does not replace the
'' Keyboard/Mouse/TV_Text.spin directly.
'' Contains also the SimpleDraw functions.
'  made by Andy Schenk

CON
  BAUDRATE    =  115200       'customize if necessary
  SERINVERSE  =  0            'RX+TX pins
  MSY_INVERS  =  0            'Mouse Y direction
  STARTDELAY  =  2            'seconds (0=off)
 
VAR

  long  cog, skey, kstat
  long  col, row, color, flag
  long  mousex, mousey

  long  rx_head                 '9 contiguous longs  for SerialDriver
  long  rx_tail
  long  tx_head
  long  tx_tail
  long  tx_pin
  long  rx_pin
  long  rx_mode
  long  bit_ticks
  long  buffer_ptr

  long  oldx, oldy, oldz        'must be followed by parameters (10 contiguous longs)

  long  par_x                   'absolute x     read-only       (7 contiguous longs)
  long  par_y                   'absolute y     read-only
  long  par_z                   'absolute z     read-only
  long  par_buttons             'button states  read-only
  long  par_present             'mouse present  read-only
                                                        
  byte  rx_buffer[16]           'receive buffer (4 longs)
  byte  tx_buffer[256]          'txbuffer (64 longs) 


PUB start(rxpin, txpin) : okay

'' Start SerialDriver
'' returns false if no cog available
''
  par_buttons := 0
  flag := 0
  
  stop
  if STARTDELAY
    waitcnt(clkfreq*STARTDELAY + cnt)
  
  longfill(@rx_head, 0, 4)
  tx_pin := txpin
  rx_pin := rxpin
  rx_mode := SERINVERSE
  bit_ticks := clkfreq / BAUDRATE
  buffer_ptr := @rx_buffer
  okay := cog := cognew(@entry, @rx_head) + 1


PUB stop

'' Stop SerialDriver - frees a cog

  if cog
    cogstop(cog~ - 1)
  longfill(@rx_head, 0, 6)


' -- Mouse --

PUB present : type

'' Check if interface present
'' returns mouse type: 1 = two-button or three-button mouse
''

  type := 1     'two-button or three-button mouse


PUB button(b) : state

'' Get the state of a particular button
'' returns t|f

  state := -(par_buttons >> b & 1)


PUB buttons : states

'' Get the states of all buttons
'' returns buttons:
''
''   bit2 = center/scrollwheel button  (not yet implemented)
''   bit1 = right button
''   bit0 = left button

  states := par_buttons & $0F


PUB abs_x : x

'' Get absolute-x

  x := par_x + (par_buttons>>5 & 1)


PUB abs_y : y

'' Get absolute-y

  y := par_y + (par_buttons>>4 & 1)
  if MSY_INVERS
    y := 230-y 


PUB abs_z : z

'' Get absolute-z (scrollwheel)

  z := par_z


PUB delta_reset

'' Reset deltas

  oldx := par_x
  oldy := par_y
  oldz := par_z


PUB delta_x : x | newx

'' Get delta-x

  newx := par_x
  x := newx - oldx
  oldx := newx


PUB delta_y : y | newy

'' Get delta-y

  newy := par_y
  y := newy - oldy
  oldy := newy
  if MSY_INVERS
    y := 0-y 


PUB delta_z : z | newz

'' Get delta-z (scrollwheel)

  newz := par_z
  z := newz - oldz
  oldz := newz


' -- Keyboard --

PUB key : keycode

'' Get key (never waits)
'' returns key (0 if buffer empty)
'  (lowest Level)

  skey := rxcheck
  if skey < 0
    keycode := 0
  else
    case skey
      $01: keycode := 0             'shift
           kstat |= $100
      $02: keycode := 0             'ctrl
           kstat |= $200
      3:   kstat &= !$100           'shift off
      4:   kstat &= !$200           'ctrl off
      $DB: keycode := $D9 + kstat   'F12->F10  fix problems with F10
      other:  keycode := skey + kstat


PUB getkey : keycode

'' Get next key (may wait for keypress)
'' returns key

  repeat until (keycode := key)


PUB newkey : keycode

'' Clear buffer and get new key (always waits for keypress)
'' returns key

  repeat while rxcheck => 0
  keycode := getkey


PUB gotkey : truefalse

'' Check if any key in buffer
'' returns t|f

  truefalse := rx_tail <> rx_head


PUB clearkeys

'' Clear key buffer

  repeat while rxcheck => 0


PRI rxcheck : rxbyte

' Check if byte received (never waits)
' returns -1 if no byte received, $00..$FF if byte

  rxbyte--
  if rx_tail <> rx_head
    rxbyte := rx_buffer[rx_tail]
    rx_tail := (rx_tail + 1) & $F


' -- Display --

PUB str(stringptr)

'' Print a zero-terminated string

  repeat strsize(stringptr)
    out(byte[stringptr++])


PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    out("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      out(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      out("0")
    i /= 10


PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    out((value <-= 1) & 1 + "0")


PUB out(c) | i, k

'' Output a character
''
''     $00 = clear screen
''     $01 = home
''     $05 = Grafik (mode,x,y follows)
''     $08 = backspace
''     $09 = tab (8 spaces per)
''     $0A = set X position (X follows)
''     $0B = set Y position (Y follows)
''     $0C = set color (color follows)
''     $0D = return
''  others = printable characters

  print(c)


PRI print(c)

'' Send byte (may wait for room in buffer)

  repeat until (tx_tail <> (tx_head + 1) & $0FF)
  tx_buffer[tx_head] := c
  tx_head := (tx_head + 1) & $0FF


' -- SimpleDraw --

PUB cls

'' Clear screen (to black)

  print(0)


PUB plot(gx, gy)

'' Plot a point at gx,gy

  graf(1,gx,gy)


PUB drawto(gx, gy)

'' Draw a line from last point to gx,gy

  graf(2,gx,gy)


PUB box(gx, gy, gw, gh)

'' Draw a box at gx,gy with width gw and height gh

  graf(0,gx,gy)
  graf(3,gx+gw,gy+gh)


PUB clrbox(gx, gy, gw, gh)

'' Clear the the area from gx,gy with width gw and height gh

  graf(0,gx,gy)
  graf(4,gx+gw,gy+gh)


PUB invbox(gx, gy, gw, gh)

'' Invert the area from gx,gy width gw and height gh (exor mode)

  graf(0,gx,gy)
  graf(5,gx+gw,gy+gh)


PUB rbox(gx, gy, gw, gh)

'' Draw a rounded box at gx,gy with width gw and height gh

  graf(0,gx,gy)
  graf(8,gx+gw,gy+gh)


PUB circle(gx, gy, gr)

'' Draws a Circle at gx,gy with radius gr

  graf(0,gx-gr,gy)
  graf(7,gx,gy)


PUB showpointer(gx, gy)

'' draw a mouse pointer at point gx,gy (exor mode)

  graf(6,gx,gy)
  mousex := gx
  mousey := gy


PUB hidepointer

'' hide the mouse pointer at last position (exor mode)

  graf(6,mousex,mousey)


PRI  graf(gcmd,xp,yp)

' cmd = 0:at 1:point 2:line 3:box 4:cbox 5:xbox 6:pntr 7:circle 8:rbox

  out(5)                        'grafic
  out(gcmd+(xp&1)<<5+(yp&1)<<4) 'mode + x/y LSBit
  out(xp>>1)
  out(yp>>1)


PUB locate(gx, gy)

'' set drawing position for characters
'' will be quantized to 40x13 raster

  out(10)
  out(gx/8)
  out(11)
  out(gy/17)


PUB setcol(c)

'' set drawing color 0..7

  print(12)
  print(c)


DAT

'***********************************
'* Assembly language serial driver *  full duplex with mouse decoding
'***********************************

                        org
'
' Entry
'
entry                   mov     t1,par                'get structure address
                        add     t1,#4 << 2            'skip past heads and tails

                        rdlong  t2,t1                 'get tx_pin
                        mov     txmask,#1
                        shl     txmask,t2

                        add     t1,#4
                        rdlong  t2,t1                 'get rx_pin
                        mov     rxmask,#1
                        shl     rxmask,t2

                        add     t1,#4                 'get rx_mode
                        rdlong  rxtxmode,t1

                        add     t1,#4                 'get bit_ticks
                        rdlong  bitticks,t1

                        add     t1,#4                 'get buffer_ptr
                        rdlong  rxbuff,t1
                        mov     txbuff,rxbuff
                        add     txbuff,#16

                        add     t1,#6 << 2            'set par_y pointer
                        mov     pz,t1
                        mov     pb,t1

                        test    rxtxmode,#%100  wz    'init tx pin according to mode
                        test    rxtxmode,#%010  wc
        if_z_ne_c       or      outa,txmask
        if_z            or      dira,txmask

                        mov     txcode,#transmit      'initialize ping-pong multitasking
'
' Receive
'
receive                 jmpret  rxcode,txcode         'run a chunk of transmit code, then return

                        test    rxtxmode,#%001  wz    'wait for start bit on rx pin
                        test    rxmask,ina      wc
        if_z_eq_c       jmp     #receive

                        mov     rxbits,#9             'ready to receive byte
                        mov     rxcnt,bitticks
                        shr     rxcnt,#1
                        add     rxcnt,cnt                          

:bit                    add     rxcnt,bitticks        'ready next bit period

:wait                   jmpret  rxcode,txcode         'run a chuck of transmit code, then return
                        mov     t1,rxcnt              'check if bit receive period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        test    rxmask,ina      wc    'receive bit on rx pin
                        rcr     rxdata,#1
                        djnz    rxbits,#:bit

                        shr     rxdata,#32-9          'justify and trim received byte
                        and     rxdata,#$FF
                        test    rxtxmode,#%001  wz    'if rx inverted, invert byte
        if_nz           xor     rxdata,#$FF

                        cmp     pb,pz          wz     'mouse receiving?
        if_nz           jmp     #getMsPar
                        
                        cmp     rxdata,#5      wz     'new mouse Event?
        if_nz           jmp     #toRxBuff             'no: write in buffer

                        add     pb,#1 << 2            'start receiving  pointer to par_button
                        jmp     #receive
                        
getMsPar                cmp     pb,pz         wz,wc
        if_a            mov     cmd,rxdata
        if_a            and     cmd,#$80
        if_b            shl     rxdata,#1             'x,y *2
                        tjnz    cmd,#nomouse
                        wrlong  rxdata,pb             'write par
nomouse
        if_a            sub     pb,#4 << 2            'pointer from par_button to par_x
                        add     pb,#1 << 2            'pointer to next par until par_z
                        jmp     #receive
        
toRxBuff                rdlong  t2,par                'save received byte and inc head
                        add     t2,rxbuff
                        wrbyte  rxdata,t2
                        sub     t2,rxbuff
                        add     t2,#1
                        and     t2,#$0F
                        wrlong  t2,par
                        jmp     #receive
'
' Transmit
'
transmit                jmpret  txcode,rxcode         'run a chunk of receive code, then return
                        
                        mov     t1,par                'check for head <> tail
                        add     t1,#2 << 2
                        rdlong  t2,t1
                        add     t1,#1 << 2
                        rdlong  t3,t1
                        cmp     t2,t3           wz
        if_z            jmp     #transmit

                        add     t3,txbuff             'get byte and inc tail
                        rdbyte  txdata,t3
                        sub     t3,txbuff
                        add     t3,#1
                        and     t3,#$0FF
                        wrlong  t3,t1

                        or      txdata,#$100          'ready byte to transmit
                        shl     txdata,#2
                        or      txdata,#1
                        mov     txbits,#11
                        mov     txcnt,cnt

:bit                    test    rxtxmode,#%100  wz    'output bit on tx pin according to mode
                        test    rxtxmode,#%010  wc
        if_z_and_c      xor     txdata,#1
                        shr     txdata,#1       wc
        if_z            muxc    outa,txmask        
        if_nz           muxnc   dira,txmask
                        add     txcnt,bitticks        'ready next cnt

:wait                   jmpret  txcode,rxcode         'run a chunk of receive code, then return

                        mov     t1,txcnt              'check if bit transmit period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        djnz    txbits,#:bit          'another bit to transmit?

                        jmp     #transmit             'byte done, transmit next byte

'
' Uninitialized data
'
t1                      res     1
t2                      res     1
t3                      res     1
pz                      res     1
pb                      res     1

rxtxmode                res     1
bitticks                res     1

rxmask                  res     1
rxbuff                  res     1
rxdata                  res     1
rxbits                  res     1
rxcnt                   res     1
rxcode                  res     1
cmd                     res     1

txmask                  res     1
txdata                  res     1
txbuff                  res     1
txbits                  res     1
txcnt                   res     1
txcode                  res     1

  