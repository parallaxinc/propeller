{{
Modified Tiny Basic for use with a Propeller Protoboard on a BoeBot chassis.
I2C and SPI driver initialization object derived from Propeller OS.

Copyright (c) 2009 Michael Green.  See end of file for terms of use.
}}

'' 2007-02-26 - Initial revisions for use with FemtoBasic
'' 2009-04-04 - spiDoStop modified per Cluso99 to turn off card

'' This portion is normally run only once during initialization and the driver remains
'' resident in a cog.  These routines can be used completely independently of the rest
'' of the Propeller OS.  See "OS_definitions" for a variety of constant definitions
'' used by these routines.  In particular, there are some data areas allocated in the
'' upper end of memory (from $7FFF down) and some of these locations are used by this
'' I/O driver on a continuous basis and must not be overlaid.

'' This object provides an I2C EEPROM read/write routine that can handle both 100KHz and
'' 400KHz bus speeds and EEPROM page sizes of 64, 128, or 256 bytes (or no paging/no delay
'' as with Ramtron serial RAM).  The SPIN interpreter can be started after reading, either
'' in the same COG used by these routines or in a free COG.  The control information is
'' passed in a 2 long parameter block whose address is defined in "OS_definitions".
'' The parameter block is updated when the operation is completed.  Note that these are shown
'' here as they appear in a long value rather than the order of the bytes in memory.

'' -------------------------------------------------------------------
'' |   cmd/status   |          I/O pin / device / address            |
'' -------------------------------------------------------------------
'' |           byte count           |          HUB address           |
'' -------------------------------------------------------------------

'' The EEPROM address is in the same format used by other routines with the I/O pin pair
'' in bits 21..19, the device address in bits 18..16, and the 64K address in bits 15..0.
'' Note that the I/O pin pair is the number of the SCL pin divided by 2.  The SDA pin is
'' always the next higher numbered pin.  The command code is in the low order bits of the
'' high order byte of the first long (see ioCmdMask).  This is always non-zero to indicate
'' that a command is to be performed by the COG routines.  When the command is finished,
'' this is set to zero.  The errorFlag bit is set to one if a NAK was read after a write
'' transfer.  This is the only error reported by these routines.  A read operation and
'' zero-length writes do involve several write transfers for addressing, but the data
'' read transfer has no error checking.  When the command is completed, the device address,
'' byte count, and HUB address are all updated to their values at that time.  For the
'' verify operation (ioVerifyCmd), an error is reported if the checksum is not zero and
'' the HUB address field is not incremented.  It may be used for some other checksum
'' reporting in the future.

'' The pins used for the boot EEPROM I2C bus (at least on Parallax's Demo Board) do not
'' have a pullup on SCL.  This requires that SCL be driven both high and low.  If the bus
'' used is on pins 28 and 29, SCL is actively driven at all times.

'' These EEPROM read/write routines do not provide for waiting for the write to complete
'' nor do they check for paged writes.  All bytes in a multi-byte write must lie within
'' a single EEPROM page since the EEPROM write address counter wraps around at a page
'' boundary.  Similarly, for multi-byte reads, all requested bytes must lie within the
'' same device since the sequential read counter wraps around at the device boundary.

'' Command codes are provided for devices with zero, one, or two address bytes following
'' the device selection byte.  As for all I2C devices, addressing is done using write
'' mode and the device is reselected in read mode after the last address byte.  In the
'' case of ioRead0Cmd, the device is initially selected in read mode.  For 8-bit addresses,
'' the device select code is taken from bits 15-8 of the address value.  For the case
'' without address bytes, the device select code is taken from bits 7-0 of the address value.
'' These device select codes must have their least significant bit set to zero (for write
'' mode) except in the case of ioRead0Cmd where it must be set to one for proper operation.

'' SPI data is handled a little differently.  For ioSpiInit, the 6 bit pin numbers for DO,
'' Clk, DI, and CS are given from MSB to LSB of the 24 bit address field of the command and
'' are used for all further I/O operations (until an ioSpiStop is done).

OBJ
  def : "BB_definitions"                               '' Propeller OS definitions

PUB start | cog                                        '' Start the I2C I/O driver
  cog := long[def#loaderCog]
  if cog > 0                                           ' Stop any previous copy
     cogstop(cog - 1)
  i2cDataSet1 := ((clkfreq / 10000) *  600) / 100000   ' Data setup time -  600ns (100KHz)
  i2cClkLow1  := ((clkfreq / 10000) * 4700) / 100000   ' Clock low time  - 4700ns (100KHz)
  i2cClkHigh1 := ((clkfreq / 10000) * 4000) / 100000   ' Clock high time - 4000ns (100KHz)
  i2cDataSet4 := ((clkfreq / 10000) *  250) / 100000   ' Data setup time -  250ns (400KHz)
  i2cClkLow4  := ((clkfreq / 10000) * 1300) / 100000   ' Clock low time  - 1300ns (400KHz)
  i2cClkHigh4 := ((clkfreq / 10000) * 1000) / 100000   ' Clock high time - 1000ns (400KHz)
  i2cPause    := (clkfreq / 1_000_000) * 1             ' Pause between checks for operations
  longfill(def#ioControl,0,2)
  cog := cognew(@i2cEntryPoint,def#ioControl) + 1      ' Start a new cog with the I/O driver,
  long[def#loaderCog] := cog                           '  save it for future reference,
  return cog > 0                                       '   and indicate success

DAT
                        org     0
i2cEntryPoint           mov     i2cTemp,i2cPause
                        add     i2cTemp,CNT             ' Wait 1us before checking
                        waitcnt i2cTemp,#0
i2cNewOpFetch           rdlong  i2cAddr,PAR             ' Fetch control information
                        mov     i2cCmd,i2cAddr
                        shr     i2cCmd,#24              ' Isolate command code
                        mov     Options,i2cCmd
                        and     i2cAddr,i2cAddrMask     ' Only need address at this point
                        and     i2cCmd,#def#ioCmdMask wz
                if_z    jmp     #i2cEntryPoint          ' Wait for a new operation
                        mov     i2cTemp,PAR
                        add     i2cTemp,#4              ' Now get 2nd long of packet
                        rdlong  i2cCount,i2cTemp
                        mov     i2cBufAdr,i2cCount      ' Byte count
                        rdlong  SaveClkFreq,#def#clkfreqVal
                        shr     i2cCount,#16            ' Save clock frequency and mode
                        and     i2cBufAdr,i2cWordMask   ' HUB RAM address of buffer
                        rdbyte  SaveClkMode,#def#clksetVal
                        movs    ShiftData,#0            ' Initialize for saving Preamble
                        mov     StoreLocal,initStore    '  on I2C and SPI reads
                        mov     Preamble+0,#0
                        mov     Preamble+1,#0
                        mov     Preamble+2,#0
                        mov     Preamble+3,#0
                        mov     CheckSum,#$EC           ' Adjust checksum for stack marker
                        test    Options,#def#ioNoStore wc
                        test    i2cCmd,#def#ioBootCmd wz
         if_nz_and_nc   mov     i2cTemp,i2cCmd          ' Stop the caller's COG unless
         if_nz_and_nc   and     i2cTemp,#%111           '  it's this one
         if_nz_and_nc   cogid   i2cCogId
         if_nz_and_nc   cmp     i2cCogId,i2cTemp   wz
         if_nz_and_nc   cogstop i2cTemp
                        test    i2cCmd,#def#ioSpiMask wz   ' Check for SPI commands
                if_nz   jmp     #spiEntryPoint
                        movs    :getAction,i2cCmd       ' Get command specific action
                        test    i2cCmd,#def#ioBootCmd wz ' bit sequence.  ioBootCmd is
                if_nz   movs    :getAction,#def#ioReadCmd ' treated as ioReadCmd here
                        add     :getAction,#ActionTbl
                        mov     i2cDataSet,i2cDataSet1
                        mov     i2cClkLow,i2cClkLow1
                        mov     i2cClkHigh,i2cClkHigh1
:getAction              mov     Action,0-0
                        test    Options,#def#ioLowSpeed wc ' Set bus speed based on option
                if_nc   mov     i2cDataSet,i2cDataSet4
                if_nc   mov     i2cClkLow,i2cClkLow4
                if_nc   mov     i2cClkHigh,i2cClkHigh4
                        mov     i2cTemp,i2cAddr
                        shr     i2cTemp,#18             ' Determine bit masks for
                        and     i2cTemp,#%11110         '  I/O pins for I2C bus
                        mov     i2cSCL,#1
                        shl     i2cSCL,i2cTemp
                        mov     i2cSDA,i2cSCL           ' SDA is next higher pin
                        shl     i2cSDA,#1
                        test    FirstCall,i2cSCL   wz   ' Is this our first call?
                        andn    FirstCall,i2cSCL        '  if so, do a reset
                if_nz   call    #i2cReset
                        call    #i2cStart               ' Do a start sequence
                        test    Action,#%000000001 wz
                if_z    jmp     #:skipAction0
                        mov     i2cData,i2cAddr         ' Construct a device select
                        shr     i2cData,#15             '  code for EEPROM write mode
                        and     i2cData,#%00001110      '   with 2 address bytes
                        or      i2cData,#%10100000
                        mov     i2cMask,#%10000000
                        call    #i2cWrite               ' Send device select code
                if_c    jmp     #:doStop                ' Failure if NAK received
:skipAction0            test    Action,#%000000010 wz
                if_z    jmp     #:skipAction1
                        mov     i2cData,i2cAddr         ' First address byte is most
                        shr     i2cData,#8              '  significant byte of address
                        mov     i2cMask,#%10000000
                        call    #i2cWrite               ' Send first address byte
                if_c    jmp     #:doStop                ' Failure if NAK received
:skipAction1            test    Action,#%000000100 wz
                if_z    jmp     #:skipAction2
                        mov     i2cData,i2cAddr         ' Second address byte is least
                        mov     i2cMask,#%10000000      '  significant byte of address
                        call    #i2cWrite               ' Send second address byte
                if_c    jmp     #:doStop                ' Failure if NAK received
:skipAction2            tjz     i2cCount,#:doStop       ' If byte count == 0, we're done
                        test    Action,#%000001000 wz
                if_nz   call    #i2cStart               ' Do a start sequence if readdressing
:doReadWrite            test    Action,#%000010000 wz
                if_nz   rdbyte  i2cData,i2cBufAdr       ' If writing, fetch the data value
                if_nz   add     i2cBufAdr,#1            '  and increment the hub address
                        test    Action,#%000100000 wz
                if_z    jmp     #:skipAction5
                        mov     i2cData,i2cAddr         ' If reading, construct a device select
                        shr     i2cData,#15             '  code for EEPROM read mode with
                        and     i2cData,#%00001110      '   2 address bytes
                        or      i2cData,#%10100001
:skipAction5            test    Action,#%001000000 wz
                if_z    jmp     #:skipAction6
                        mov     i2cData,i2cAddr         ' If reading using a single byte address
                        shr     i2cData,#8              '  construct a device select code for
                        or      i2cData,#%00000001      '   read mode given one for write mode
:skipAction6            test    Action,#%010000000 wz
                if_z    jmp     #:skipAction7
                        mov     i2cMask,#%10000000      ' Either readdress device for reading
                        call    #i2cWrite               '  or write a data value at this point
                if_c    jmp     #:doStop                ' Failure if NAK received
:skipAction7            test    Action,#%100000000 wz
                if_z    jmp     #:skipAction8
                        cmp     i2cCount,#2        wc   ' Carry true if this is the last byte
                        mov     i2cMask,#%10000000
                        mov     i2cData,#0
                        call    #i2cRead
                        call    #StoreData              ' Now force carry false to show success
                        or      i2cZero,#0      nr,wc
                        andn    Action,#%011100000      ' No readdressing on subsequent reads
:skipAction8            add     i2cAddr,#1
                        djnz    i2cCount,#:doReadWrite  ' Repeat for number of bytes requested
:doStop                 call    #i2cStop
                if_c    or      i2cAddr,errorFlag       ' Carry true indicates error
                        jmp     #checkEndIO

'' Low level I2C routines.  These are designed to work either with a standard I2C bus
'' (with pullups on both SCL and SDA) or the Propellor Demo Board (with a pullup only
'' on SDA).  Timing can be set by the caller to 100KHz or 400KHz.

'' Do I2C Reset Sequence.  Clock up to 9 cycles.  Look for SDA high while SCL
'' is high.  Device should respond to next Start Sequence.  Leave SCL high.

i2cReset                andn    dira,i2cSDA             ' Pullup drive SDA high
                        mov     i2cBitCnt,#9            ' Number of clock cycles
                        mov     i2cTime,i2cClkLow
                        add     i2cTime,cnt             ' Allow for minimum SCL low
:i2cResetClk            andn    outa,i2cSCL             ' Active drive SCL low
                        or      dira,i2cSCL            
                        waitcnt i2cTime,i2cClkHigh
                        test    i2cBootSCLm,i2cSCL wz   ' Check for boot I2C bus
              if_nz     or      outa,i2cSCL             ' Active drive SCL high
              if_nz     or      dira,i2cSCL
              if_z      andn    dira,i2cSCL             ' Pullup drive SCL high
                        waitcnt i2cTime,i2cClkLow       ' Allow minimum SCL high
                        test    i2cSDA,ina         wz   ' Stop if SDA is high
              if_z      djnz    i2cBitCnt,#:i2cResetClk ' Stop after 9 cycles
i2cReset_ret            ret                             ' Should be ready for Start      

'' Do I2C Start Sequence.  This assumes that SDA is a floating input and
'' SCL is also floating, but may have to be actively driven high and low.
'' The start sequence is where SDA goes from HIGH to LOW while SCL is HIGH.

i2cStart                andn    dira,i2cSDA             ' Pullup drive SDA high
                        andn    outa,i2cSDA             ' SDA set to drive low
                        mov     i2cTime,i2cClkLow
                        add     i2cTime,cnt             ' Allow for bus free time
                        waitcnt i2cTime,i2cClkHigh
                        test    i2cBootSCLm,i2cSCL wz   ' Check for boot I2C bus
              if_nz     or      outa,i2cSCL             ' Active drive SCL high
              if_nz     or      dira,i2cSCL
              if_z      andn    dira,i2cSCL             ' Pullup drive SCL high
                        waitcnt i2cTime,i2cClkHigh      ' Allow for start setup time
                        or      dira,i2cSDA             ' Active drive SDA low
                        waitcnt i2cTime,#0              ' Allow for start hold time
                        andn    outa,i2cSCL             ' Active drive SCL low
                        or      dira,i2cSCL
i2cStart_ret            ret                             

'' Do I2C Stop Sequence.  This assumes that SCL is low and SDA is indeterminant.
'' The stop sequence is where SDA goes from LOW to HIGH while SCL is HIGH.
'' i2cStart must have been called prior to calling this routine for initialization.
'' The state of the (c) flag is maintained so a write error can be reported.

i2cStop                 or      dira,i2cSDA             ' Active drive SDA low
                        mov     i2cTime,i2cClkLow
                        add     i2cTime,cnt             ' Wait for minimum clock low
                        waitcnt i2cTime,i2cClkLow
                        test    i2cBootSCLm,i2cSCL wz   ' Check for boot I2C bus
              if_nz     or      outa,i2cSCL             ' Active drive SCL high
              if_nz     or      dira,i2cSCL
              if_z      andn    dira,i2cSCL             ' Pullup drive SCL high
                        waitcnt i2cTime,i2cClkHigh      ' Wait for minimum setup time
                        andn    dira,i2cSDA             ' Pullup drive SDA high
                        waitcnt i2cTime,#0              ' Allow for bus free time
                        andn    dira,i2cSCL             ' Leave SCL and SDA high
i2cStop_ret             ret

'' Write I2C data.  This assumes that i2cStart has been called and that SCL is low,
'' SDA is indeterminant. The (c) flag will be set on exit from ACK/NAK with ACK == false
'' and NAK == true. Bytes are handled in "little-endian" order so these routines can be
'' used with words or longs although the bits are in msb..lsb order.

i2cWrite                mov     i2cBitCnt,#8
                        mov     i2cTime,i2cClkLow
                        add     i2cTime,cnt             ' Wait for minimum SCL low
:i2cWriteBit            waitcnt i2cTime,i2cDataSet
                        test    i2cData,i2cMask    wz
              if_z      or      dira,i2cSDA             ' Copy data bit to SDA
              if_nz     andn    dira,i2cSDA
                        waitcnt i2cTime,i2cClkHigh      ' Wait for minimum setup time
                        test    i2cBootSCLm,i2cSCL wz   ' Check for boot I2C bus
              if_nz     or      outa,i2cSCL             ' Active drive SCL high
              if_nz     or      dira,i2cSCL
              if_z      andn    dira,i2cSCL             ' Pullup drive SCL high
                        waitcnt i2cTime,i2cClkLow
                        andn    outa,i2cSCL             ' Active drive SCL low
                        or      dira,i2cSCL
                        ror     i2cMask,#1              ' Go do next bit if not done
                        djnz    i2cBitCnt,#:i2cWriteBit
                        andn    dira,i2cSDA             ' Switch SDA to input and
                        waitcnt i2cTime,i2cClkHigh      '  wait for minimum SCL low
                        test    i2cBootSCLm,i2cSCL wz   ' Check for boot I2C bus
              if_nz     or      outa,i2cSCL             ' Active drive SCL high
              if_nz     or      dira,i2cSCL
              if_z      andn    dira,i2cSCL             ' Pullup drive SCL high
                        waitcnt i2cTime,#0              ' Wait for minimum high time
                        test    i2cSDA,ina         wc   ' Sample SDA (ACK/NAK) then
                        andn    outa,i2cSCL             '  active drive SCL low
                        or      dira,i2cSCL
                        or      dira,i2cSDA             ' Leave SDA low
                        rol     i2cMask,#16             ' Prepare for multibyte write
i2cWrite_ret            ret

'' Read I2C data.  This assumes that i2cStart has been called and that SCL is low,
'' SDA is indeterminant.  ACK/NAK will be copied from the (c) flag on entry with
'' ACK == low and NAK == high.  Bytes are handled in "little-endian" order so these
'' routines can be used with words or longs although the bits are in msb..lsb order.

i2cRead                 mov     i2cBitCnt,#8
                        andn    dira,i2cSDA             ' Make sure SDA is set to input
                        mov     i2cTime,i2cClkLow
                        add     i2cTime,cnt             ' Wait for minimum SCL low
:i2cReadBit             waitcnt i2cTime,i2cClkHigh
                        test    i2cBootSCLm,i2cSCL wz   ' Check for boot I2C bus
              if_nz     or      outa,i2cSCL             ' Active drive SCL high
              if_nz     or      dira,i2cSCL
              if_z      andn    dira,i2cSCL             ' Pullup drive SCL high
                        waitcnt i2cTime,i2cClkLow       ' Wait for minimum clock high
                        test    i2cSDA,ina         wz   ' Sample SDA for data bits
                        andn    outa,i2cSCL             ' Active drive SCL low
                        or      dira,i2cSCL
              if_nz     or      i2cData,i2cMask         ' Accumulate data bits
              if_z      andn    i2cData,i2cMask
                        ror     i2cMask,#1              ' Shift the bit mask and
                        djnz    i2cBitCnt,#:i2cReadBit  '  continue until done
                        waitcnt i2cTime,i2cDataSet      ' Wait for end of SCL low
              if_c      andn    dira,i2cSDA             ' Copy the ACK/NAK bit to SDA
              if_nc     or      dira,i2cSDA
                        waitcnt i2cTime,i2cClkHigh      ' Wait for minimum setup time
                        test    i2cBootSCLm,i2cSCL wz   ' Check for boot I2C bus
              if_nz     or      outa,i2cSCL             ' Active drive SCL high
              if_nz     or      dira,i2cSCL
              if_z      andn    dira,i2cSCL             ' Pullup drive SCL high
                        waitcnt i2cTime,#0              ' Wait for minimum clock high
                        andn    outa,i2cSCL             ' Active drive SCL low
                        or      dira,i2cSCL
                        or      dira,i2cSDA             ' Leave SDA low
                        rol     i2cMask,#16             ' Prepare for multibyte read
i2cRead_ret             ret

'' SPI routines for Rokicki's SD card FAT file system driver

spiEntryPoint           test    i2cCmd,#def#ioBootCmd wc ' Check for boot
              if_c      jmp     #spiDoRead              '  (Treat like read)
                        cmp     i2cCmd,#def#ioSpiStop wc,wz
              if_c      jmp     #spiDoInit              ' Decode operation
              if_z      jmp     #spiDoStop
                        cmp     i2cCmd,#def#ioSpiWrite wc
              if_c      jmp     #spiDoRead
                        jmp     #spiDoWrite

'' Initialize SPI communications.  The pin numbers of the 4 I/O pins are
'' provided in the 24 bit address field of the control packet.  From MSB to
'' LSB, these are DO - Data Out, Clk - Clock, DI - Data In, CS - Card Select.

spiDoInit               movd    :moveIt,#spiMaskCS
                        mov     spiBlkCnt,#4
:makeMask               mov     i2cMask,#1
                        mov     i2cTemp,i2cAddr         ' Only use lower 5 bits of
                        and     i2cTemp,#%11111         '  6 bit shift count field
                        shl     i2cMask,i2cTemp
:moveIt                 mov     0-0,i2cMask             ' Store the bit mask for the pin
                        cmp     spiBlkCnt,#1       wz
              if_ne     or      outa,i2cMask            ' Make all pins high outputs
              if_ne     or      dira,i2cMask            '  except DO is an input since
              if_e      andn    dira,i2cMask            '   input/output is card relative
                        sub     :moveIt,incrDst
                        ror     i2cAddr,#6
                        djnz    spiBlkCnt,#:makeMask
                        rol     i2cAddr,#24             ' Leave i2cAddr unchanged
                        mov     i2cTime,cnt             ' Set up a 1 second timeout
                        mov     spiBlkCnt,spiInitCnt
:initRead               call    #spiRecvByte            ' Output a stream of 32K clocks
                        djnz    spiBlkCnt,#:initRead    '  in case SD card left in some
                        mov     spiOp,#0                '   undefined state
                        mov     spiParm,#0
                        call    #spiSendCmd             ' Send a reset command and deselect
                        or      outa,spiMaskCS          '  to get SD card into SPI mode
:waitIdle               mov     spiOp,#55
                        call    #spiSendCmd             ' APP_CMD (Application Specific)
                        mov     spiOp,#41
                        call    #spiSendCmd             ' SEND_OP_COND (Initialization)
                        or      outa,spiMaskCS
                        cmp     i2cData,#1         wz   ' Wait until response not In Idle
              if_e      jmp     #:waitIdle
                        tjz     i2cData,#i2cGoUpdate    ' Initialization complete
                        or      i2cAddr,errorFlag
                        jmp     #i2cGoUpdate            ' Could not initialize the card

'' Stop SPI communications.  Any previously used I/O pins are set to input mode and
'' the masks for the I/O pins are zeroed.  The card is clocked so it turns off.

spiDoStop               or      outa,spiMaskCS          ' Make sure /CS is high
                        call    #spiRecvByte            ' Put out a few clocks
                        call    #spiRecvByte            '  to turn off the card
                        andn    dira,spiMaskDO
                        andn    dira,spiMaskDI          ' Set all the card pins
                        andn    dira,spiMaskCS          '  to inputs so they can
                        andn    dira,spiMaskClk         '  be used for some other
                        mov     spiMaskDO,#0            '  purpose when the card
                        mov     spiMaskDI,#0            '  is removed.  All should
                        mov     spiMaskCS,#0            '  have pullups to +3.3V.
                        mov     spiMaskClk,#0
                        jmp     #i2cGoUpdate

'' Read one or more 512 byte blocks and store the specified number of bytes
'' into the HUB location given.  The block number is provided in the 24 bit
'' address field and incremented after every block is read.  Partial blocks are
'' allowed and any extra bytes read are discarded.

spiDoRead               mov     spiOp,#17               ' READ_SINGLE_BLOCK
:readRepeat             mov     i2cTime,cnt             ' Save start of timeout
                        mov     spiParm,i2cAddr
                        call    #spiSendCmd             ' Read from specified block
                        call    #spiResponse
                        mov     spiBlkCnt,spiBlkSize    ' Transfer a block at a time
:getRead                call    #spiRecvByte
                        tjz     i2cCount,#:skipStore    ' Check for count exhausted
                        call    #StoreData
                        sub     i2cCount,#1
:skipStore              djnz    spiBlkCnt,#:getRead     ' Are we done with the block?
                        call    #spiRecvByte
                        call    #spiRecvByte            ' Yes, finish with 16 clocks
                        add     i2cAddr,#1
                        or      outa,spiMaskCS          ' Increment address, deselect card
                        tjnz    i2cCount,#:readRepeat   '  and check for more blocks to do
checkEndIO              test    i2cCmd,#def#ioBootCmd wc
                 if_nc  jmp     #i2cGoUpdate            ' If not booting, we're done
                        test    i2cAddr,errorFlag  wc
                        and     CheckSum,#$FF      wz   ' If booting, no errors can occur
           if_z_and_nc  jmp     #nowBootSpin            '  and checksum must be zero
                        or      i2cAddr,errorFlag
                        test    Options,#def#ioNoStore wc
                 if_c   jmp     #i2cGoUpdate            ' Return error status if noStore

stopThisCOG             cogid   i2cCogId                ' If an unrecoverable error occurs,
                        cogstop i2cCogId                '  stop this cog
                      
'' Write one or more 512 byte blocks with the specified number of bytes from
'' the HUB location given.  The block number is provided in the 24 bit address
'' field and incremented after every block is written.  Partial blocks are
'' allowed and are padded with zeroes.

spiDoWrite              mov     spiOp,#24               ' WRITE_BLOCK
                        mov     i2cTime,cnt             ' Setup timeout
                        mov     spiParm,i2cAddr
                        call    #spiSendCmd             ' Write to specified block
                        mov     i2cData,#$FE            ' Ask to start data transfer
                        call    #spiSendByte
                        mov     spiBlkCnt,spiBlkSize    ' Transfer a block at a time
:putWrite               mov     i2cData,#0              '  padding with zeroes if needed
                        tjz     i2cCount,#:padWrite     ' Check for count exhausted
                        rdbyte  i2cData,i2cBufAdr       ' If not, get the next data byte
                        add     i2cBufAdr,#1
                        sub     i2cCount,#1
:padWrite               call    #spiSendByte
                        djnz    spiBlkCnt,#:putWrite    ' Are we done with the block?
                        call    #spiRecvByte
                        call    #spiRecvByte            ' Yes, finish with 16 clocks
                        call    #spiResponse
                        and     i2cData,#$1F            ' Check the response status
                        cmp     i2cData,#5         wz
              if_ne     or      i2cAddr,errorFlag       ' Must be Data Accepted
              if_ne     jmp     #i2cGoUpdate
                        movs    spiWaitData,#0          ' Wait until not busy
                        call    #spiWaitBusy
                        add     i2cAddr,#1
                        or      outa,spiMaskCS          ' Increment block address and go
                        tjnz    i2cCount,#spiDoWrite    '  to next if more data remains
                        jmp     #i2cGoUpdate

'' Mid level SPI I/O

spiSendCmd              andn    outa,spiMaskCS          ' Send command sequence.  Begin by
                        call    #spiRecvByte            '  selecting card and clocking
                        mov     i2cData,spiOp
                        or      i2cData,#$40            ' Send command byte (1st 2 bits %01)
                        call    #spiSendByte
                        mov     i2cData,spiParm
                        shr     i2cData,#15             ' Supplied address is sector number
                        call    #spiSendByte 
                        mov     i2cData,spiParm         ' Send to SD card as byte address,
                        shr     i2cData,#7              '  in multiples of 512 bytes
                        call    #spiSendByte
                        mov     i2cData,spiParm         ' Total length of this address is
                        shl     i2cData,#1              '  four bytes
                        call    #spiSendByte
                        mov     i2cData,#0
                        call    #spiSendByte
                        mov     i2cData,#$95            ' CRC code (for 1st command only)
                        call    #spiSendByte
spiResponse             movs    spiWaitData,#$FF        ' Wait for response from card
spiWaitBusy             call    #spiRecvByte
                        mov     i2cTemp,cnt
                        sub     i2cTemp,i2cTime         ' Check for expired timeout (1 sec)
                        cmp     i2cTemp,SaveClkFreq wc
              if_nc     or      i2cAddr,errorFlag
              if_nc     jmp     #i2cGoUpdate
spiWaitData             cmp     i2cData,#0-0       wz   ' Wait for some other response
              if_e      jmp     #spiWaitBusy            '  than that specified
spiSendCmd_ret
spiResponse_ret
spiWaitBusy_ret         ret

'' Low level byte I/O

spiSendByte             mov     i2cMask,#%10000000
:sendBit                test    i2cMask,i2cData    wc
                        andn    outa,spiMaskClk         ' Send data bytes MSB first
                        muxc    outa,spiMaskDI
                        or      outa,spiMaskClk
                        shr     i2cMask,#1              ' When mask shifted out, we're done
                        tjnz    i2cMask,#:sendBit
                        or      outa,spiMaskDI          ' Leave DI in idle (high) state
spiSendByte_ret         ret

spiRecvByte             mov     i2cMask,#%10000000
:recvBit                andn    outa,spiMaskClk         ' Receive data bytes MSB first
                        or      outa,spiMaskClk         ' Copy DO to data bit
                        test    spiMaskDO,ina      wc     
                        muxc    i2cData,i2cMask
                        shr     i2cMask,#1              ' When mask shifted out, we're done
                        tjnz    i2cMask,#:recvBit
                        and     i2cData,#%11111111      ' Eight bits received
spiRecvByte_ret         ret

'' For both I2C and SPI, store data on a read operation unless ioNoStore is set.
'' Accumulate a checksum and always save a copy of the first 16 bytes read.
'' If this is an ioBootCmd or ioSpiBoot, adjust the amount to be read based
'' on the value in the program preamble in the word at vbase ($0008).

StoreData               test    Options,#def#ioNoStore wc
                if_nc   wrbyte  i2cData,i2cBufAdr       ' Store data in specified location
                        add     i2cBufAdr,#1            '  and increment the address
                        add     CheckSum,i2cData        ' Accumulate checksum for ioBootCmd
ShiftData               shl     i2cData,#0-0
StoreLocal              or      Preamble+0,i2cData      ' Store a local copy of the program
                        add     ShiftData,#8            '  preamble for when we're reading
                        cmp     ShiftData,testIns  wz   '   in a new Spin program
                if_z    movs    ShiftData,#0            ' Pack the data into successive longs
                if_z    add     StoreLocal,incrDst
                if_z    cmp     StoreLocal,testDst wz   ' Stop after saving $0010 bytes
                if_z    mov     StoreLocal,noStore
                if_z    test    i2cCmd,#def#ioBootCmd wc ' If we're reading in a new program,
          if_c_and_z    mov     i2cCount,Preamble+2     '   change i2cCount to vbase adjusted
          if_c_and_z    and     i2cCount,i2cWordMask    '   by number of bytes loaded so far.
          if_c_and_z    sub     i2cCount,#16 - 1        ' i2cCount will be decremented again
StoreData_ret           ret

'' After reading is finished for a boot, the stack marker is added below dbase
'' and memory is cleared between that and vbase (the end of the loaded program).
'' Memory beyond the stack marker is not cleared.  Note that if ioNoStore is set,
'' we go through the motions, but don't actually change memory or the clock.

nowBootSpin             test    Options,#def#ioNoStore wc
                        mov     i2cTemp,Preamble+2
                        shr     i2cTemp,#16             ' Get dbase value
                        sub     i2cTemp,#4
                if_nc   wrlong  StackMark,i2cTemp       ' Place stack marker at dbase
                        sub     i2cTemp,#4
                if_nc   wrlong  StackMark,i2cTemp
                        mov     i2cOther,Preamble+2     ' Get vbase value
                        and     i2cOther,i2cWordMask
                        sub     i2cTemp,i2cOther
                        shr     i2cTemp,#2         wz   ' Compute number of longs between
:zeroIt  if_nz_and_nc   wrlong  i2cZero,i2cOther        '  vbase and below stack marker
         if_nz_and_nc   add     i2cOther,#4
         if_nz_and_nc   djnz    i2cTemp,#:zeroIt        ' Zero that space (if any)
                        mov     i2cTemp,Preamble
                        cmp     i2cTemp,SaveClkFreq wz  ' Is the clock frequency the same?
                        mov     i2cTemp,Preamble+1
                        and     i2cTemp,#$FF            ' Is the clock mode the same also?
                if_ne   jmp     #:changeClock
                        cmp     i2cTemp,SaveClkMode wz  ' If both same, just go start COG
                if_e    jmp     #:justStartUp
:changeClock            and     i2cTemp,#$F8            ' Force use of RCFAST clock while
                if_nc   clkset  i2cTemp                 '  letting requested clock start
                        mov     i2cTemp,time_xtal
:startupDelay           djnz    i2cTemp,#:startupDelay  ' Allow 20ms@20MHz for xtal/pll to settle
                        mov     i2cTemp,Preamble+1
                        and     i2cTemp,#$FF            ' Then switch to selected clock
                if_nc   clkset  i2cTemp
:justStartUp            mov     i2cOther,i2cCmd         ' Use the COG supplied as the caller's
                        and     i2cOther,#%111          '  to start up the SPIN interpreter
                        test    Options,#def#ioStopLdr wz ' If ioStopLdr is set and ioNoStore is
                if_nz   cogid   i2cOther                '    clear, then use this cog for SPIN
                        or      i2cOther,interpreter
                if_nc   coginit i2cOther

'' The operation has completed, with or without errors.  Update the control block
'' in main memory and wait for the next operation to be requested.

i2cGoUpdate             and     i2cBufAdr,i2cWordMask   ' Copy updated information
                        shl     i2cCount,#16            '  back to control packet
                        or      i2cCount,i2cBufAdr
                        mov     i2cTemp,PAR
                        add     i2cTemp,#4
                        wrlong  i2cCount,i2cTemp
                        wrlong  i2cAddr,PAR             ' Indicate operation is done
                        jmp     #i2cEntryPoint          '  and go wait for a new one

'' This action table contains bit sequences for controlling device addressing and read/write
'' mode selection for each of the commands possible.  From LSB to MSB, the actions are:
'' 0 - Write the EEPROM device select code for write mode and 2 address bytes
'' 1 - Write the MSB device address or (for ioRead1Cmd/ioWrite1Cmd) a device select code
'' 2 - Write the LSB device address or (for ioRead0Cmd/ioWrite0Cmd) a device select code
'' 3 - Output a Start Sequence prior to reselecting in read mode
'' 4 - Fetch a data value for writing
'' 5 - Construct an EEPROM device select code for read mode and 2 address bytes
'' 6 - Construct a read mode device select code from the MSB of the 16 bit device address
'' 7 - Write the data value or read mode device select code
'' 8 - Read a byte of data from the device and store it

i2cZero
ActionTbl               long    %0000000000             ' Command not used (indicates done)
                        long    %0110101111,%0010010111 ' Read/Write with 2 bytes of addressing
                        long    %0111001110,%0010010110 ' Read/Write with 1 byte of addressing
                        long    %0100000100,%0010010100 ' Read/Write data only

'' Constants for all routines

i2cWordMask             long    $0000FFFF
i2cAddrMask             long    $00FFFFFF
errorFlag               long    $80000000               ' NAK received during write cycle
speedMask               long    $40000000               ' One if 100KHz bus, zero if 400KHz
time_xtal               long    20 * 20000 / 4 / 1      ' 20ms (@20MHz, 1 inst/loop)
interpreter             long    ($0004 << 16) | ($F004 << 2) | %0000
i2cBootSCLm             long    |<def#i2cBootSCL        ' Bit mask for pin 28 SCL use
spiBlkSize                                              ' Number of bytes in an SD card block
incrDst                 long    %10_00000000            ' Used to increment destination field
testIns                 shl     i2cData,#32             ' Used to compare for end of word packing
initStore               or      Preamble+0,i2cData      ' Used to initialize packing instruction
testDst                 or      Preamble+4,i2cData      ' Used to check for end of packing buffer
noStore                 jmp     #StoreData_ret          ' Used after all data stored into Preamble
spiInitCnt              long    32768 / 8               ' Initial SPI clocks produced
StackMark               long    $FFF9FFFF               ' Two of these mark the base of the stack

'' Variables for all routines

Preamble                long    0, 0, 0, 0              ' Private copy of program preamble
Action                  long    0
i2cOther
i2cCogId                long    0
i2cCmd                  long    0
FirstCall               long    -1                      ' One if I2C pins not initialized yet
i2cTemp                 long    0
i2cCount                long    0
i2cBufAdr               long    0
i2cAddr                 long    0
i2cDataSet              long    0                       ' Minumum data setup time (ticks)
i2cClkLow               long    0                       ' Minimum clock low time (ticks)
i2cClkHigh              long    0                       ' Minimum clock high time (ticks)
i2cDataSet1             long    0                       ' Minumum data setup time (ticks) 100KHz
i2cClkLow1              long    0                       ' Minimum clock low time (ticks) 100KHz
i2cClkHigh1             long    0                       ' Minimum clock high time (ticks) 100KHz
i2cDataSet4             long    0                       ' Minumum data setup time (ticks) 400KHz
i2cClkLow4              long    0                       ' Minimum clock low time (ticks) 400KHz
i2cClkHigh4             long    0                       ' Minimum clock high time (ticks) 400KHz
i2cPause                long    0                       ' Pause before re-fetching next operation
SaveClkFreq             long    0                       ' Initial clock frequency (clkfreqVal)
SaveClkMode             long    0                       ' Initial clock mode value (clksetVal)
spiBlkCnt               long    0                       ' Number of SD card bytes to go in block
CheckSum                long    0                       ' Checksum of bytes for ioBootCmd
Options                 long    0                       ' Option bits (ioNoStore, ioLowSpeed)

'' Local variables for low level I2C routines

spiOp                                                   ' Operation code for SPI command
i2cSCL                  long    0                       ' Bit mask for SCL
spiParm                                                 ' Parameter value for SPI command
i2cSDA                  long    0                       ' Bit mask for SDA
i2cTime                 long    0                       ' Used for timekeeping
i2cData                 long    0                       ' Data to be transmitted / received
i2cMask                 long    0                       ' Bit mask for bit to be tx / rx
i2cBitCnt               long    0                       ' Number of bits to tx / rx

'' Additional local variables for SPI SD Card access

spiMaskDO               long    0
spiMaskClk              long    0
spiMaskDI               long    0
spiMaskCS               long    0

                        fit

{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}