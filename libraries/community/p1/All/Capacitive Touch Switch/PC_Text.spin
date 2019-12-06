''*****************************
''*  PC Text 40x13 v0.2       *
''*****************************
'' Replaces TV_Text.spin if you wish to use the PCs as Monitor instead of a TV.
'' Needs PropTerminal.exe on PC to receive the characters over the (USB-)serial link.
'  made by Andy Schenk
 
CON

  TXPIN      = 30           'customize if necessary
  BAUDRATE   = 115200
  STARTDELAY = 2            'seconds (0=Off)

VAR

  long  flag, cog
  
  long  tx_head                  '5 contiguous longs  for SerialDriver
  long  tx_tail
  long  tx_pin
  long  bit_ticks
  long  buffer_ptr
                     
  byte  tx_buffer[512]           'txbuffer  


PUB start(basepin) : okay

'' Start serial - starts a cog
'' returns false if no cog available

  flag := 0
  
  stop
  if STARTDELAY
    waitcnt(clkfreq * STARTDELAY + cnt)

  longfill(@tx_head, 0, 2)
  tx_pin := TXPIN
  bit_ticks := clkfreq / BAUDRATE
  buffer_ptr := @tx_buffer
  okay := cog := cognew(@entry, @tx_head) + 1


PUB stop

'' Stop terminal - frees a cog

  if cog
    cogstop(cog~ - 1)
  longfill(@tx_head, 0, 2)


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
''     $08 = backspace
''     $09 = tab (8 spaces per)
''     $0A = set X position (X follows)
''     $0B = set Y position (Y follows)
''     $0C = set color (color follows)
''     $0D = return
''  others = printable characters

  print(c)


PUB setcolors(colorptr) | i, fore, back

'' Override default color palette in real driver
'' not used here


PRI print(c)

'' Send byte (may wait for room in buffer)

  repeat until (tx_tail <> (tx_head + 1) & $1FF)
  tx_buffer[tx_head] := c
  tx_head := (tx_head + 1) & $1FF


DAT

'***********************************
'* Assembly language serial driver *
'***********************************

                        org
'
'
' Entry
'
entry                   mov     t1,par                'get structure address
                        add     t1,#2 << 2            'skip past heads and tails

                        rdlong  t2,t1                 'get tx_pin
                        mov     txmask,#1
                        shl     txmask,t2
                        or      outa,txmask           'idle = 1
                        or      dira,txmask           'Pin30 = output

                        add     t1,#4                 'get bit_ticks
                        rdlong  bittime,t1

                        add     t1,#4                 'get buffer_ptr
                        rdlong  txbuff,t1

transmit                mov     t1,par                'check for head <> tail
                        rdlong  t2,t1
                        add     t1,#1 << 2
                        rdlong  t3,t1
                        cmp     t2,t3           wz
        if_z            jmp     #transmit

sendloop                add     t3,txbuff             'get byte and inc tail
                        rdbyte  txdata,t3
                        sub     t3,txbuff
                        add     t3,#1
                        and     t3,#$1FF
                        wrlong  t3,t1
                        
                        mov     txcnt,#10
                        or      txdata,#$100          'add stoppbit
                        shl     txdata,#1             'add startbit
                        mov     dtime,cnt
                        add     dtime,bittime

sendbit                 shr     txdata,#1    wc       'test LSB
                        mov     t2,outa
              if_nc     andn    t2,txmask             'bit=0  or
              if_c      or      t2,txmask             'bit=1
                        mov     outa,t2
                        waitcnt dtime,bittime         'wait 1 bit
                        djnz    txcnt,#sendbit        '10 times
               
                        waitcnt dtime,bittime         '2 stopbits

                        jmp     #transmit             'done,wait for next

'
' Uninitialized data
'
t1                      res     1
t2                      res     1
t3                      res     1
dtime                   res     1
bittime                 res     1
txmask                  res     1
txdata                  res     1
txcnt                   res     1
txbuff                  res     1