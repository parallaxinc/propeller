''************************************
''*  Full-Duplex Serial Driver v1.0  *
''*  (C) 2006 Parallax, Inc.         *
''************************************
''
'' Updated 15 MAR 06 : Increased buffers to 64 bytes


VAR

  long  cogon, cog

  long  rx_head                 '8 contiguous longs
  long  rx_tail
  long  tx_head
  long  tx_tail
  long  rx_pin
  long  tx_pin
  long  bit_ticks
  long  buffer_ptr
                     
  byte  rx_buffer[64]           'transmit and receive buffers
  byte  tx_buffer[64]
  
  
PUB start(rxpin, txpin, baudrate) : okay

'' Start serial driver - starts a cog
'' returns false if no cog available

  stop
  longfill(@rx_head, 0, 4)
  longmove(@rx_pin, @rxpin, 2)
  bit_ticks := clkfreq / baudrate
  buffer_ptr := @rx_buffer
  okay := cogon := (cog := cognew(@entry,@rx_head)) > 0


PUB stop

'' Stop keyboard driver - frees a cog

  if cogon~
    cogstop(cog)
  longfill(@rx_head, 0, 8)


PUB rxcheck : rxbyte

'' Check if byte received (never waits)
'' returns -1 if no byte, $00..$FF if byte

  rxbyte--
  if rx_tail <> rx_head
    rxbyte := rx_buffer[rx_tail]
    rx_tail := (rx_tail + 1) & $3F


PUB rx : rxbyte

'' Receive byte (may wait for byte)
'' returns $00..$FF

  repeat while (rxbyte := rxcheck) < 0


PUB tx(txbyte)

'' Send byte (may wait for room in buffer)

  repeat until (tx_tail <> (tx_head + 1) & $3F)
  tx_buffer[tx_head] := txbyte
  tx_head := (tx_head + 1) & $3F


PUB str(stringptr)

'' Send string

  repeat strsize(stringptr)
    tx(byte[stringptr++])
    

DAT

'***********************************
'* Assembly language serial driver *
'***********************************

                        org
'
'
' Entry
'
entry                   mov     t1,par                'get rx_pin
                        add     t1,#4 << 2
                        rdlong  t2,t1
                        mov     rxmask,#1
                        shl     rxmask,t2

                        add     t1,#4                 'get tx_pin
                        rdlong  t2,t1
                        mov     txmask,#1
                        shl     txmask,t2

                        add     t1,#4                 'get bit_ticks
                        rdlong  bitticks,t1

                        add     t1,#4                 'get buffer_ptr
                        rdlong  rxbuff,t1
                        mov     txbuff,rxbuff
                        add     txbuff,#64

                        or      outa,txmask           'init tx pin to high output
                        or      dira,txmask

                        mov     txcode,#transmit      'set initial receive code ptr
'
'
' Receive
'
receive                 jmpret  rxcode,txcode         'run transmit code, then return

                        test    rxmask,ina      wc    'wait for start bit
        if_c            jmp     #receive

                        mov     rxbits,#9             'ready to receive byte
                        mov     rxcnt,bitticks
                        shr     rxcnt,#1
                        add     rxcnt,cnt                          

:bit                    add     rxcnt,bitticks        'ready next bit period

:wait                   jmpret  rxcode,txcode         'run transmit code

                        mov     t1,rxcnt              'check if bit receive period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        test    rxmask,ina      wc    'get bit
                        rcr     rxdata,#1
                        djnz    rxbits,#:bit

                        shr     rxdata,#32-9          'justify and trim received byte
                        and     rxdata,#$FF

                        rdlong  t2,par                'save received byte and inc head
                        add     t2,rxbuff
                        wrbyte  rxdata,t2
                        sub     t2,rxbuff
                        add     t2,#1
                        and     t2,#$3F
                        wrlong  t2,par

                        jmp     #receive              'byte done, receive next byte
'
'
' Transmit
'
transmit                jmpret  txcode,rxcode         'run receive code, then return

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
                        and     t3,#$3F
                        wrlong  t3,t1

                        or      txdata,#$100          'ready byte to transmit
                        shl     txdata,#1
                        mov     txbits,#10
                        mov     txcnt,cnt

:bit                    test    txdata,#1       wc    'output bit
                        muxc    outa,txmask
                        add     txcnt,bitticks        'ready next cnt

:wait                   jmpret txcode,rxcode          'run receive code

                        mov     t1,txcnt              'check if bit transmit period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        shr     txdata,#1             'another bit to transmit?
                        djnz    txbits,#:bit

                        jmp     #transmit             'byte done, transmit next byte
'
'
' Uninitialized data
'
t1                      res     1
t2                      res     1
t3                      res     1

bitticks                res     1

rxmask                  res     1
rxbuff                  res     1
rxdata                  res     1
rxbits                  res     1
rxcnt                   res     1
rxcode                  res     1

txmask                  res     1
txbuff                  res     1
txdata                  res     1
txbits                  res     1
txcnt                   res     1
txcode                  res     1