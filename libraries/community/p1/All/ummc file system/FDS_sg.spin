{{ FDS_sg.spin

  From FullDuplexSerial.spin

  Bob Belleville

  2007/03/13 - begin modifications
  2007/03/14 - functional

  FullDuplexSerial is essentially byte oriented.  When
  communicating with high speed devices the buffers
  will fill and data will be lost.  At high baud rates
  spin programs are not fast enough to fill or clear the
  buffers.

  This modification is built to support communication
  with the Rogue Robotics ummc SD flash card reader/
  writer.  Perhaps other devices will also find this
  design useful.

  'sg' indicates scatter-gather. The serial transmitter
  here is designed to take a string of n bytes and send
  them as quickly as possible.  Strings from
  the calling program don't have to be moved before
  transmission --- gather.  The receiver is designed
  to place bytes into the calling program's buffer
  directly also eliminating a move --- scatter.

  The ummc protocol always has the form:

  command_string cr [write data if required] response_string ">"

  So one or two gathers and a scatter.  It doesn't look
  like full duplex is needed, however the ummc can begin
  transmitting its reply before the stop bit of the cr
  is complete.  Thus the receiver must be already on.

}}  

''************************************
''*  Full-Duplex Serial Driver v1.1  *
''*  (C) 2006 Parallax, Inc.         *
''************************************


VAR

  long  cog                     'cog flag/id

                                'struct of 11 contiguous longs 
  long  rx_state                'rxnew rxbusy
  long  tx_state                'txnew txbusy
  
  long  addr_rx_cnt             'address of count of rcv'd bytes
  long  rx_max                  'max bytes to prevent overflow
  long  rx_ptr                  'address next free byte in buffer
  
  long  tx_cnt                  'count of bytes to send
  long  tx_ptr                  'address of first byte to send
  
  long  rx_pin                  'pin masks
  long  tx_pin
  long  rxtx_mode               'how to manage the i/o pins
  long  bit_ticks               'baud rate in ticks


PUB start(rxpin, txpin, mode, baudrate) : okay

'' Start serial driver - starts a cog
'' returns false if no cog available
''
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx

  stop
  'longfill(@rx_state,0,2)                       'idle both (done by stop)
  longmove(@rx_pin, @rxpin, 3)                  'snarf up params
  bit_ticks := clkfreq / baudrate               'compute rate
  okay := cog := cognew(@entry, @rx_state) + 1  'pass struct as PAR


PUB stop

'' Stop serial driver - frees a cog

  if cog
    cogstop(cog~ - 1)
  longfill(@rx_state,0,2)


PUB get(addr_cnt, max_cnt, addr_buff)

'' Start the receiver

  longmove(@addr_rx_cnt,@addr_cnt,3)    'copy params
  long[addr_cnt]~                       'none yet rcv'd
  rx_state := 2                         'enable receiver - new task
  
    
PUB get_stop

'' idle the receiver

  rx_state~
  

PUB put(n, addr_ptr)

'' transmit n bytes from addr_ptr

  repeat while tx_state                 'spin until tx free
  longmove(@tx_cnt,@n,2)                'copy params
  tx_state := 1                         'enable transmit - new task
  
PUB tx_status

'' returns state of tx busy bit

  return tx_state

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
                        add     t1,#7 << 2            'skip to pins

                        rdlong  t2,t1                 'get rx_pin
                        mov     rxmask,#1
                        shl     rxmask,t2

                        add     t1,#1 << 2            'get tx_pin
                        rdlong  t2,t1
                        mov     txmask,#1
                        shl     txmask,t2

                        add     t1,#1 << 2            'get rxtx_mode
                        rdlong  rxtxmode,t1

                        add     t1,#1 << 2            'get bit_ticks
                        rdlong  bitticks,t1

                        test    rxtxmode,#%100  wz    'init tx pin according to mode
                        test    rxtxmode,#%010  wc
        if_z_ne_c       or      outa,txmask
        if_z            or      dira,txmask

                        mov     txcode,#transmit      'initialize ping-pong multitasking
'
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

                        rdlong  t2,par                  'rx state
                        cmp     t2,#1           wz,wc   '2 - new task
                                                        '1 - storing bytes
                                                        '0 - off
        if_c            jmp     #receive                'idle
        if_z            jmp     #:store

                        mov     t1,par                  'initial setup
                        mov     t2,#1                   'go to storing state
                        wrlong  t2,t1
                        add     t1,#2 << 2              'addr cnt
                        rdlong  rxacnt,t1
                        add     t1,#1 << 2              'max bytes
                        rdlong  rxmax,t1
                        add     t1,#1 << 2              'byte pointer
                        rdlong  rxptr,t1
                        mov     rxccnt,#0               'cog memory count
                        
:store               '   jmpret  rxcode,txcode         'run a chuck of transmit code, then return

                        cmp     rxccnt,rxmax    wc
        if_nc           jmp     #receive                'no room
                        wrbyte  rxdata,rxptr            'store and bump ptr
                        add     rxptr,#1
                        add     rxccnt,#1               'bump local count
                        rdlong  t2,rxacnt               'tell user too
                        add     t2,#1
                        wrlong  t2,rxacnt
                        jmp     #receive              'byte done, receive next byte
'
'
' Transmit
'
transmit                jmpret  txcode,rxcode         'run a chunk of receive code, then return

                        mov     t1,par
                        add     t1,#1 << 2              'point to tx_status
                        rdlong  t2,t1
                        test    t2,#1           wz
        if_z            jmp     #transmit               'nothing new
                        add     t1,#4 << 2
                        rdlong  txbc,t1                 'get byte count
                        add     t1,#1 << 2
                        rdlong  txptr,t1                'address of input
                        
:getnext                jmpret  txcode,rxcode         'run a chunk of receive code, then return
                        
                        rdbyte  txdata,txptr            'get byte and bump ptr
                        add     txptr,#1
                        
                        or      txdata,#$100          'ready byte to transmit
{                        
                        shl     txdata,#2               'precedes byte with stop bit
                        or      txdata,#1               '  don't know why
                        mov     txbits,#11
}                        
                        shl     txdata,#1               '8 bit + stop and start only
                        mov     txbits,#10
                        
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

                        djnz    txbc,#:getnext          'another byte to send?
                        
                        mov     t1,par
                        add     t1,#1 << 2              'point to tx_status
                        mov     t2,#0
                        wrlong  t2,t1                   'report done
                        jmp     #transmit             'byte done, transmit next byte
'
'
' Uninitialized data
'
t1            res     1         'working regs
t2            res     1

rxtxmode      res     1         'i/o mode
bitticks      res     1         'for bit rate

rxmask        res     1         'pin mask rx
rxdata        res     1         'rx data read
rxbits        res     1         'bit count during bit build up
rxcnt         res     1         'bit timer
rxcode        res     1         'address for ping-pong
rxacnt        res     1         'address in user space of rx byte count
rxccnt        res     1         'byte count in cog
rxmax         res     1         'max buffer size
rxptr         res     1         'pointer in user space of next free buff cell

txmask        res     1         'pin mask tx
txdata        res     1         'byte being sent
txbits        res     1         'bit count for byte transmit
txcnt         res     1         'bit timer
txcode        res     1         'address for ping-pong
txbc          res     1         'tx byte count
txptr         res     1         'address in user buffer of next byte to send

