DAT
  cog         long  0               'cog flag/id

  rx_pin      long  0               '4 contiguous longs
  tx_pin      long  0
  rxtx_mode   long  0
  bit_ticks   long  0
  txregAddr   long  0
  rxregAddr   long  0
     
  txreg1      word  0               '8 contiguous words                       
  txreg2      word  0
  txreg3      word  0
  txreg4      word  0
  txreg5      word  0
  txreg6      word  0
  txreg7      word  0
  txreg8      word  0

  rxreg1      word  0               '8 contiguous words
  rxreg2      word  0
  rxreg3      word  0
  rxreg4      word  0
  rxreg5      word  0
  rxreg6      word  0
  rxreg7      word  0
  rxreg8      word  0

CON
  REG_IS_EMPTY = $ffff
 
PUB start(rxpin, txpin, mode, baudrate ) : okay
{{
  Must only be called from main program
  Start serial driver - starts a cog
  returns false if no cog available

  mode bit 0 = invert rx
  mode bit 1 = invert tx
  mode bit 2 = open-drain/source tx
  mode bit 3 = ignore tx echo on rx
}}
  stop

  rx_pin      := rxpin
  tx_pin      := txpin
  rxtx_mode   := mode

  wordfill(@txreg1,REG_IS_EMPTY,8)
  wordfill(@rxreg1,REG_IS_EMPTY,8)
 
  bit_ticks   := clkfreq / baudrate

  txregAddr := @txreg1
  rxregAddr := @rxreg1
  
  okay := cog := cognew(@entry, @rx_pin) + 1


PUB stop
{{
  Must only be called from main program
  Stop serial driver - frees a cog
}}
  if cog
    cogstop(cog~ - 1)

PUB AddressOfRxregn( chan ): address
  address := @rxreg1 + chan + chan - 2

PUB AddressOfTxregn( chan ): address
  address := @txreg1 + chan + chan - 2  
    
' In all of the following public methods, it is assumed that the
' parameter "channel" has a value from 1 to 8.  It is up to caller to
' ensure that this is so.

PUB writeStringToUARTn( channel, strByteAddress ) | i,char
  i := 0
  repeat while (char := byte[strByteAddress][i++]) <> 0
    writeByteToUARTn( channel, char )

PUB writeLineToUARTn( channel, strByteAddress )
  writeStringToUARTn( channel, strByteAddress )
  writeByteToUARTn( channel, 13 )  ' CR
     
PUB charAvailUARTn( channel ) : yesno
  yesno := word[@rxreg1][--channel] <> REG_IS_EMPTY

PUB getByteFromUARTn( channel ) : rxvalue | rxregnAddress
  rxregnAddress := @rxreg1 + ((--channel) << 1 )
  rxvalue := word[rxregnAddress]
  word[rxregnAddress] := REG_IS_EMPTY  

PUB writeByteToUARTn( channel, byteValue ) | txregnAddress
  txregnAddress := @txreg1 + ((--channel) << 1)
  repeat until word[txregnAddress] == REG_IS_EMPTY
  word[txregnAddress] := byteValue
  
PUB readByteFromUARTn( channel ) : rxValue | rxregnAddress
  rxregnAddress := @rxreg1 + ((--channel) << 1)
  repeat while word[rxregnAddress] == REG_IS_EMPTY
  rxValue := word[rxregnAddress]
  word[rxregnAddress] := REG_IS_EMPTY
  
DAT

'**********************************************
'* Assembly language multi-port serial driver *
'**********************************************

                        org     0

entry                   mov     t1,par            'get structure address

                        ' Move parameters from Hub memory space to our cog memory space
                        
                        rdlong  t2,t1             'get rx_pin number
                        mov     rxmask,#1
                        shl     rxmask,t2         'converted pin# to a bit mask

                        add     t1,#4             'get tx_pin number
                        rdlong  t2,t1
                        mov     txmask,#1
                        shl     txmask,t2         'converted pin# to a bit mask

                        add     t1,#4             'get rxtx_mode
                        rdlong  rxtxmode,t1

                        add     t1,#4             'get bit_ticks
                        rdlong  bitticks,t1

                        add     t1,#4
                        rdlong  txregAddr,t1      'get txregAddress

                        add     t1,#4
                        rdlong  rxregAddr,t1      'get rxregAddress

                        ' Zero head and tail indexes for the rcv buffers.  This shows that
                        ' they are empty.  Since rxtail[0..7] follows rxhead[0..7], this can be
                        ' done by zeroing rxhead[0..15]

                        movd    :target1,#rxhead
                        mov     loopCnt,#16
                            
:target1                mov     0-0,#0            'mov rxhead++,#0
                        add     :target1,DEST_INC
                        djnz    loopCnt,#:target1                             

                        test    rxtxmode,#%100 wz 'if_nz = open drain Tx
                        test    rxtxmode,#%010 wc 'if_c = inverted output

      
        if_z_ne_c       or      outa,txmask
        if_z            or      dira,txmask

                        mov     txcode,#transmit   'initialize ping-pong multitasking
                        mov     frxcode,#fillRxregs'initialize fill rxregs thread

                        ' When rxstate = 1, we are waiting for a prefix byte
                        mov     rxstate,#1
                        mov     nextQueue,#0      'initialize pointer used by fillRxregs code
                        mov     txregIndex,#0


' Receive =====================================================================

receive                 jmpret  rxcode,txcode     'run a chunk of transmit code, then return

                        cmp     txState,#0     wz
        if_z            jmpret  rxcode,frxcode    'run a chunk of fillRxregs code
                        
                        test    rxtxmode,#%001 wz 'wait for start bit on rx pin
                        test    rxmask,ina     wc
        if_z_eq_c       jmp     #receive

                        mov     rxbits,#9         'ready to receive byte
                        mov     rxcnt,bitticks
                        shr     rxcnt,#1          'half a bit tick
                        add     rxcnt,cnt         '+ the current clock             

:bit                    add     rxcnt,bitticks    'calc middle of next bit time (drift free)

:wait                   jmpret  rxcode,txcode     'run a chunk of transmit code, then return

                        mov     r1,rxcnt          'check if bit receive period done
                        sub     r1,cnt
                        cmps    r1,#0          wc 'check if at or beyond middle-of-bit time
        if_nc           jmp     #:wait

                        test    rxmask,ina     wc 'receive bit on rx pin into carry
                        rcr     rxdata,#1         'shift carry into receiver
                        djnz    rxbits,#:bit      'go get another bit till done

                        test    rxtxmode,#%001 wz 'find out if rx is inverted
        if_z_ne_c       jmp     #receive           'abort if no stop bit

                        shr     rxdata,#32-9      'justify and trim received byte
                        and     rxdata,#$FF
        if_nz           xor     rxdata,#$FF       'if rx inverted, invert byte

                        cmp     rxstate,#1     wz
        if_nz           jmp     #addToQueue

                        ' This point is reached whenever rxstate = 0.  We will process
                        ' the prefix byte (should be the character 1 through 8) to get
                        ' ready to store the next byte in the proper queue.

                        mov     rcvQueueIndex,rxdata
                        sub     rcvQueueIndex,#$31
                        and     rcvQueueIndex,#7  'force queue index into 0..7 range
                        mov     rxstate,#2
                        
                        jmp     #receive          'go get the next byte
                                                            
                        'When this point is reached, we have received a complete byte.
                        'Add it to the appropriate rcv queue

addToQueue              mov     rxstate,#1
                        mov     r1,#rxhead
                        add     r1,rcvQueueIndex
                        movs    :target0,r1
                        movd    :target2,r1
                        movd    :target3,r1
                        
:target0                mov     r2,0-0             'source is rxhead[rcvQueueIndex]
                        mov     r1,rcvQueueIndex
                        shl     r1,#5
                        add     r1,#rxbuff
                        shl     r1,#2              'convert to byte pointer
                        add     r1,r2
                        mov     bytePtr,r1
                        mov     byteIO,rxdata
                        
                        call    #doStoreByte
:target2                add     0-0,#1            'dest is rxhead[rcvQueueIndex]
:target3                and     0-0,#$7F          'dest is rxhead[rcvQueueIndex]

                        jmp     #receive          'byte done, receive next byte

' fillRxregs ==================================================================
                        
                        'The following routine scans all of the rcv queues.  For any that are
                        'non-empty AND the corresponding hub rxregn is empty, a byte is removed from
                        'the queue and written to hub rxregn
                        
fillRxregs              jmpret  frxcode,rxcode    'run a chunk of receive code and return
 
                        add     nextQueue,#1      'update nextQueue circularly
                        and     nextQueue,#7

                        mov     f1,#rxtail
                        add     f1,nextQueue
                        movs    :target1,f1
                        movd    :target3,f1
                        movd    :target4,f1
                        
                        mov     f1,#rxhead
                        add     f1,nextQueue
                        movs    :target2,f1
                        

                        'Check whether rxtail[nextQueue] = rxhead[nextQueue].  If so
                        'there are no characters queued up, so just exit.
                        
:target1                mov     f3,0-0            'source is rxtail[nextQueue]
:target2                cmp     f3,0-0         wz 'source is rxhead[nextQueue]
              if_z      jmp     #fillRxregs       'if rxhead = rxtail, queue is empty

                        jmpret  frxcode,rxcode    'run a chunk of receive code and return       

                        'Check whether rxregn is = EMPTY.  If it's not, the user has
                        'not removed the previous character, so just exit

                        mov     f4,rxregAddr
                        add     f4,nextQueue
                        add     f4,nextQueue      'f4 points to rxregn (hub)
                        
                        rdword  f1,f4
                        cmp     f1,EMPTY       wz
              if_nz     jmp     #fillRxregs

                        jmpret  frxcode,rxcode    'run a chunk of receive code and return

                        'If this point is reached, rxreg (in hub) is empty, so we
                        'will move a byte from the queue to rxregn

                        mov     f1,nextQueue
                        shl     f1,#5             'f1 contails 32 * nextQueue
                        add     f1,#rxbuff        'f1 now points to start of buffer
                        shl     f1,#2             'convert to byte pointer
                        
                        'at this point, f3 = contents of rxtail[nextQueue]
                        add     f3,f1             'now f3 points to byte in queue
                        mov     bytePtr,f3

                        call    #doReadByte
                        wrword  byteIO,f4
                        
:target3                add     0-0,#1            'dest is rxtail[nextQueue]
:target4                and     0-0,#$7F          'dest is rxtail[nextQueue]
                        
                        jmp     #fillRxregs                        

' Transmit ====================================================================

transmit                jmpret  txcode,rxcode     'run a chunk of receive code, then return

                        ' Address txregn
                        mov     t1,txregAddr
                        add     t1,txregIndex
                        add     t1,txregIndex     't1 now points to txregn in Hub

                        ' Calculate prefix byte ('1'...'8') for the channel being examined
                        mov     txdata,#$31       'move prefix byte to transmit into txdata
                        add     txdata,txregIndex 'adjust prefix byte to n ('1'...'8')

                        ' Update txregIndex circularly to point to next txreg
                        add     txregIndex,#1
                        and     txregIndex,#7
                        
                        rdword  t2,t1             't2 now contains txregn value
                        cmp     t2,EMPTY     wz   'check for txregn EMPTY
                        
        if_z            jmp     #transmit

                        ' If this point is reached, a txreg was found not equal to EMPTY
                        ' First we send the prefix byte used by the MultiPort Serial Terminal to
                        ' de-multiplex the byte stream
                        mov     txState,#1        'state == 1 : prefix byte in progress    
                        wrword  EMPTY,t1          'set rxreg to EMPTY (in hub memory)

:sendtxdata             jmpret  txcode,rxcode     'run a chunk of receive code, then return
                        or      txdata,#$100      'or in a stop bit
                        shl     txdata,#2
                        or      txdata,#1         'or in a idle line state and a start bit
                        mov     txbits,#11
                        mov     txcnt,cnt         'initialize txcnt to current time

:bit                    test    rxtxmode,#%100 wz 'output bit on tx pin according to mode
                        test    rxtxmode,#%010 wc
        if_z_and_c      xor     txdata,#1
                        shr     txdata,#1      wc
        if_z            muxc    outa,txmask        
        if_nz           muxnc   dira,txmask
                        add     txcnt,bitticks    'ready next cnt (drift free)

:wait                   jmpret  txcode,rxcode     'run a chunk of receive code, then return

                        mov     t1,txcnt          'check if bit transmit period done
                        sub     t1,cnt
                        cmps    t1,#0          wc 'check if at or beyond bit time
        if_nc           jmp     #:wait

                        djnz    txbits,#:bit      'another bit to transmit?

                        cmp     txState,#1     wz 'set z if we just finished prefix byte

                        ' The following three instructions are executed only if we arrived here
                        ' with state = 1
                        
        if_z            mov     txdata,t2         'load txdata with txregn value
        if_z            mov     txState,#2        'change to state 2
        if_z            jmp     #:sendtxdata      'go send the value byte

                        mov     txState,#0
                        jmp     #transmit         'Go look for next channel

EMPTY         long      $ffff   'Used to indicate that tx or rx register is empty
DEST_INC      long      1 << 9  'Used to increment the destination field of an instruction

doReadByte
        ' Calculate the cog register address and stuff it in "fetch" instruction
                        mov       regAddr,bytePtr
                        shr       regAddr,#2
                        movs      :fetch,regAddr

        ' Calculate byte index (0..3) and stuff it in "shift" instruction
                        mov       byteIndex,bytePtr
                        and       byteIndex,#3
                        shl       byteindex,#3
                        movs      :shift,byteIndex

        ' Fetch the register containing the desired byte
:fetch                  mov       byteIO,0-0

        ' Shift it to occupy low order 8 bits
:shift                  shr       byteIO,#0-0

        ' Mask off the high order bits
                        and       byteIO,#$ff
                        

doReadByte_ret          ret

              
doStoreByte
        ' Calculate the cog register address fixup instructions that need it
                        mov       regAddr,bytePtr
                        shr       regAddr,#2
                        movd      :ref1,regAddr
                        movd      :ref2,regAddr

        ' Calculate byte index (0..3)
                        mov       byteIndex,bytePtr
                        and       byteIndex,#3
                        shl       byteIndex,#3
                        movs      :shift1,byteIndex
                        movs      :shift2,byteIndex

                        
        ' Compose mask for removing old byte
                        mov       byteMask,#$ff
:shift1                 shl       byteMask,#0-0

        ' Copy byteIO to local variable and shift it into byte position
                        mov       myByteIO,byteIO
:shift2                 shl       myByteIO,#0-0

        ' Set previous byte to 0
:ref1                   andn      0-0,byteMask

        ' Add in the new byte
:ref2                   or        0-0,myByteIO

doStoreByte_ret         ret
                            
              
'============ Local variables for byte read/write routines  ============              
regAddr       res       1
byteIndex     res       1
byteMask      res       1
myByteIO      res       1

'============ Global variables for byte read/write routines ============
byteIO        res       1       ' Input for doStoreByte; Output for doReadByte
bytePtr       res       1       ' Pointer to cog byte location                  
'
'
' Uninitialized data
'
rxState       res       1
txState       res       1
txregIndex    res       1       'Iterates 0..7 to reference txreg1...txreg8

rxregAddress  res       1       'Starting address of rxregn array in Hub space (word array)
txregAddress  res       1       'Starting address of txregn array in Hub space (word array)


' Temps for transmit thread
t1                      res     1
t2                      res     1
t3                      res     1

' Temps for receive thread 
r1                      res     1
r2                      res     1
r3                      res     1
r4                      res     1
rcvQueueIndex           res     1
nextQueue               res     1
frxcode                 res     1

' Temps for fillRxregs
f1                      res     1
f2                      res     1
f3                      res     1
f4                      res     1

loopCnt                 res     1

rxtxmode                res     1
bitticks                res     1

rxmask                  res     1
rxdata                  res     1
rxbits                  res     1
rxcnt                   res     1
rxcode                  res     1

txmask                  res     1
txdata                  res     1
txbits                  res     1
txcnt                   res     1
txcode                  res     1

rxhead                  res     8               'Holds index into rcv buffer. 
rxtail                  res     8               'Holds index into rcv buffer.

rxbuff                  res     32*8            '8 buffers of 128 bytes each

                        fit