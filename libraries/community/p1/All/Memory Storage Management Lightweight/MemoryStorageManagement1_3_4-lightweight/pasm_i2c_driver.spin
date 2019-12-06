'' PASM I2C Driver  Version 1.0
'' Copyright (c) 2010 Dave Hein
'' June 6, 2010
'' See end of file for terms of use

'' This is a PASM version of Mike Green's Basic I2C Driver.  The
'' low level I2C routines have been converted to PASM to increase the
'' I/O speed.  These routines use the same calling interface as
'' the Basic I2C Driver Version 1.1 in the OBEX, and should be fully
'' compatible with any existing code that uses the Basic I2C Driver.

'' Just like the Basic I2C Driver, the PASM I2C Driver assumes
'' that the SDA pin is one higher than the SCL pin.  It assumes that
'' neither the SDA nor the SCL pins have pullups, so drives both.

'' This object uses the Initialize method to start up a cog rather than using
'' the start method.  This is done to remain consistent with the Basic I2C
'' Driver routines.  Initialize must be called at the beginning of the program.
'' This loads the PASM code in a cog, and clocks the I2C bus to initialize
'' the devices on the bus.  Subsequent calls may be made to Initialize, and
'' it will not cause the cog to be stopped or reloaded.

'' The bus I/O speed is controlled by the constant DELAY_CYCLES.  This constant
'' is used in the delay routine.  The total delay consists of calling the delay
'' routine, performing a waitcnt of CNT + DELAY_CYCLES, and then returning
'' from the delay routine.  Therefore, the total delay will be about
'' 12 + DELAY_CYCLES.

'' The delay time represents the clock high time, and half the clock low time.
'' It is also used to determine the setup and hold times for the data bit for
'' read, write, start and stop operations.  DELAY_CYCLES is defined with a
'' value of 52, which gives a total delay of 64 cycles.  At 80 MHz, this is
'' 0.8 usecs, which is about one-third of a 400 KHz cycle time.  This value
'' should be modified to provide the optimal speed for a particular application.

'' Please see Mike Green's Basic I2C Driver object for more information on
'' the I2C routines, and on how EEPROMs are addressed

CON
   ACK           = 0            ' I2C Acknowledge
   NAK           = 1            ' I2C No Acknowledge
   Xmit          = 0            ' I2C Direction Transmit
   Recv          = 1            ' I2C Direction Receive

   CMD_START     = 1            ' Issue a start bit
   CMD_STOP      = 2            ' Issue a stop bit
   CMD_READ      = 3            ' Transmit a byte to the I2C bus
   CMD_WRITE     = 4            ' Read a byte from the I2C bus
   CMD_INIT      = 5            ' Initialize the I2C bus
   CMD_READPAGE  = 6            ' Read one or more bytes in the page mode
   CMD_WRITEPAGE = 7            ' Write one or more bytes in the page mode
   
   DELAY_CYCLES  = 152           ' I2C Delay time.  Must be between 12 and 511

DAT
  cognum long 0
  cmdbuf long 0, 0

PUB Initialize(SCL)
'' Start cog if not started, and initialize the devices on the I2C bus
  'ser.dbprintf1(string("i2c initialize %d\n"), SCL)
  cmdbuf[1] := @SCL
  cmdbuf := CMD_INIT
  ifnot cognum
    cognum := cognew(@cmdloop, @cmdbuf) + 1
  repeat while cmdbuf

PUB Start(SCL)
'' Issue an I2C start command
  cmdbuf[1] := @SCL
  cmdbuf := CMD_START
  repeat while cmdbuf

PUB Stop(SCL)
'' Issue an I2C stop command
  cmdbuf[1] := @SCL
  cmdbuf := CMD_STOP
  repeat while cmdbuf

PUB Read(SCL, ackbit)
'' Read in i2c data, Data byte is output MSB first, SDA data line is
'' valid only while the SCL line is HIGH.  SCL and SDA left in LOW state.
  cmdbuf[1] := @SCL
  cmdbuf := CMD_READ
  repeat while cmdbuf
  result := cmdbuf[1]
  
PUB Write(SCL, data)
'' Write i2c data.  Data byte is output MSB first, SDA data line is valid
'' only while the SCL line is HIGH.  Data is always 8 bits (+ ACK/NAK).
'' SDA is assumed LOW and SCL and SDA are both left in the LOW state.
  cmdbuf[1] := @SCL
  cmdbuf := CMD_WRITE
  repeat while cmdbuf
  result := cmdbuf[1]
  
PUB ReadPage(SCL, devSel, addrReg, dataPtr, count) : ackbit
'' Read in a block of i2c data.  Device select code is devSel.  Device starting
'' address is addrReg.  Data address is at dataPtr.  Number of bytes is count.
'' The device select code is modified using the upper 3 bits of the 19 bit addrReg.
'' Return zero if no errors or the acknowledge bits if an error occurred.
  cmdbuf[1] := @SCL
  cmdbuf := CMD_READPAGE
  repeat while cmdbuf
  ackbit := cmdbuf[1]
  
PUB WritePage(SCL, devSel, addrReg, dataPtr, count) : ackbit
'' Write out a block of i2c data.  Device select code is devSel.  Device starting
'' address is addrReg.  Data address is at dataPtr.  Number of bytes is count.
'' The device select code is modified using the upper 3 bits of the 19 bit addrReg.
'' Most devices have a page size of at least 32 bytes, some as large as 256 bytes.
'' Return zero if no errors or the acknowledge bits if an error occurred.  If
'' more than 31 bytes are transmitted, the sign bit is "sticky" and is the
'' logical "or" of the acknowledge bits of any bytes past the 31st.
  cmdbuf[1] := @SCL
  cmdbuf := CMD_WRITEPAGE
  repeat while cmdbuf
  ackbit := cmdbuf[1]

PUB ReadByte(SCL, devSel, addrReg) : data
'' Read in a single byte of i2c data.  Device select code is devSel.  Device
'' starting address is addrReg.  The device select code is modified using the
'' upper 3 bits of the 19 bit addrReg.  This returns true if an error occurred.
   if ReadPage(SCL, devSel, addrReg, @data, 1)
      return -1

PUB ReadWord(SCL, devSel, addrReg) : data
'' Read in a single word of i2c data.  Device select code is devSel.  Device
'' starting address is addrReg.  The device select code is modified using the
'' upper 3 bits of the 19 bit addrReg.  This returns true if an error occurred.
   if ReadPage(SCL, devSel, addrReg, @data, 2)
      return -1

PUB ReadLong(SCL, devSel, addrReg) : data
'' Read in a single long of i2c data.  Device select code is devSel.  Device
'' starting address is addrReg.  The device select code is modified using the
'' upper 3 bits of the 19 bit addrReg.  This returns true if an error occurred.
'' Note that you can't distinguish between a return value of -1 and true error.
   if ReadPage(SCL, devSel, addrReg, @data, 4)
      return -1

PUB WriteByte(SCL, devSel, addrReg, data)
'' Write out a single byte of i2c data.  Device select code is devSel.  Device
'' starting address is addrReg.  The device select code is modified using the
'' upper 3 bits of the 19 bit addrReg.  This returns true if an error occurred.
   if WritePage(SCL, devSel, addrReg, @data, 1)
      return true
   return false

PUB WriteWord(SCL, devSel, addrReg, data)
'' Write out a single word of i2c data.  Device select code is devSel.  Device
'' starting address is addrReg.  The device select code is modified using the
'' upper 3 bits of the 19 bit addrReg.  This returns true if an error occurred.
'' Note that the word value may not span an EEPROM page boundary.
   if WritePage(SCL, devSel, addrReg, @data, 2)
      return true
   return false

PUB WriteLong(SCL, devSel, addrReg, data)
'' Write out a single long of i2c data.  Device select code is devSel.  Device
'' starting address is addrReg.  The device select code is modified using the
'' upper 3 bits of the 19 bit addrReg.  This returns true if an error occurred.
'' Note that the long word value may not span an EEPROM page boundary.
   if WritePage(SCL, devSel, addrReg, @data, 4)
      return true
   return false

PUB WriteWait(SCL, devSel, addrReg) : ackbit
'' Wait for a previous write to complete.  Device select code is devSel.  Device
'' starting address is addrReg.  The device will not respond if it is busy.
'' The device select code is modified using the upper 3 bits of the 18 bit addrReg.
'' This returns zero if no error occurred or one if the device didn't respond.
   devSel |= addrReg >> 15 & %1110
   Start(SCL)
   ackbit := Write(SCL, devSel | Xmit)
   Stop(SCL)
   return ackbit

DAT

'***********************************
'* Assembly language i2c driver    *
'***********************************

                        org
'
'
' Entry
' Wait for a non-zero command and process                        
cmdloop                 rdlong  t1, par            wz
        if_z            jmp     #cmdloop
                        mov     parm1, par
                        add     parm1, #4
                        rdlong  parm1, parm1    ' Get the address of the parameter list

                        rdlong  t2, parm1       ' SCL is always the first parameter
                        add     parm1, #4       ' Point to the next parameter
                        mov     scl_bit,#1
                        shl     scl_bit,t2
                        mov     sda_bit, scl_bit
                        shl     sda_bit, #1
                        
                        cmp     t1, #CMD_READPAGE  wz
        if_z            jmp     #ReadPage1
                        cmp     t1, #CMD_WRITEPAGE wz
        if_z            jmp     #WritePage1
                        cmp     t1, #CMD_READ      wz          
        if_z            jmp     #read_byte
                        cmp     t1, #CMD_WRITE     wz          
        if_z            jmp     #write_byte
                        cmp     t1, #CMD_START     wz          
        if_z            jmp     #start1
                        cmp     t1, #CMD_STOP      wz          
        if_z            jmp     #stop1
                        cmp     t1, #CMD_INIT      wz          
        if_z            jmp     #initialize1
                        neg     parm1, #1

ReturnParm              mov     t1, par
                        add     t1, #4
                        wrlong  parm1, t1
signal_ready            mov     t1, #0
                        wrbyte  t1, par
                        jmp     #cmdloop

ReadPage1               call    #ReadPageFunc
                        jmp     #ReturnParm
WritePage1              call    #WritePageFunc
                        jmp     #ReturnParm
read_byte               rdlong  parm1, parm1
                        call    #readbytefunc
                        jmp     #ReturnParm
write_byte              rdlong  parm1, parm1
                        call    #writebytefunc
                        jmp     #ReturnParm
start1                  call    #StartFunc
                        jmp     #ReturnParm
stop1                   call    #StopFunc
                        jmp     #ReturnParm
initialize1             call    #InitializeFunc
                        jmp     #ReturnParm

'' This routine reads a byte and sends the ACK bit.  It assumes the clock
'' and data lines have been low for at least the minimum low clock time.
'' It exits with the clock and data low for the minimum low clock time.                        
readbytefunc            mov     ackbit1, parm1 ' Get the ACK bit
                        mov     data1, #0     ' Initialize data byte to zero
                        andn    dira, sda_bit ' Set SDA as input
                        call    #delay
                        mov     count1, #8    ' Set loop count for 8

:loop                   call    #delay
                        or      outa, scl_bit ' Set SCL HIGH
                        call    #delay
                        shl     data1, #1     ' data byte left one bit
                        test    sda_bit, ina    wz
        if_nz           or      data1, #1     ' Set LSB if input bit is HIGH
                        andn    outa, scl_bit ' Set SCL LOW
                        call    #delay
                        djnz    count1, #:loop

                        cmp     ackbit1, #0     wz
        if_z            andn    outa, sda_bit ' Set SDA LOW if ACK
        if_nz           or      outa, sda_bit ' Set SDA HIGH if NAK
                        or      dira, sda_bit ' Set SDA as output
                        call    #delay
                        or      outa, scl_bit ' Set SCL HIGH
                        call    #delay
                        andn    outa, scl_bit ' Set SCL LOW
                        call    #delay
                        mov     parm1, data1  ' Return the data byte
readbytefunc_ret        ret

'' This routine writes a byte and reads the ACK bit.  It assumes that the clock
'' and data are set as outputs, and the clock has been low for at least half the
'' minimum low clock time.  It exits with the clock and data set as outputs, and
'' with the clock low for half the minimum low clock time.                        
writebytefunc           mov     data1, parm1  ' Get the data byte
                        mov     count1, #8    ' Set loop count for 8 bits

:loop                   shl     data1, #1     ' Shift left one bit
                        test    data1, #$100    wz ' Check MSB
        if_z            andn    outa, sda_bit ' Set SDA LOW if zero
        if_nz           or      outa, sda_bit ' Set SDA HIGH if not zero
                        call    #delay
                        or      outa, scl_bit ' Set SCL HIGH
                        call    #delay
                        andn    outa, scl_bit ' Set SCL LOW
                        call    #delay
                        djnz    count1, #:loop

                        andn    dira, sda_bit ' Set SDA as input
                        call    #delay
                        or      outa, scl_bit ' Set SDA HIGH
                        call    #delay
                        test    sda_bit, ina    wz ' Check SDA input
        if_z            mov     ackbit1, #0   ' Set to zero if LOW
        if_nz           mov     ackbit1, #1   ' Set to one if HIGH
                        andn    outa, scl_bit ' Set SCL LOW
                        call    #delay
                        or      dira, sda_bit ' Set SDA as output
                        mov     parm1, ackbit1 ' Return the ack bit
writebytefunc_ret       ret

'' This routine transmits the stop sequence, which consists of the data line
'' going from low to high while the clock is high.  It assumes that data and
'' clock are set as outputs, and the clock has been low for half the minimum
'' low clock time.  It exits with the clock and data floating high for the
'' minimum  high clock time.
stopfunc                andn    outa, sda_bit ' Set SDA LOW
                        call    #delay
                        or      outa, scl_bit ' Set SCL HIGH
                        call    #delay
                        or      outa, sda_bit ' Set SDA HIGH
                        call    #delay
                        andn    dira, scl_bit ' Float SCL HIGH
                        andn    dira, sda_bit ' Float SDA HIGH
stopfunc_ret            ret

'' This routine transmits the start sequence, which consists of the data line
'' going from high to low while the clock is high.  It assumes that the clock
'' and data were floating high for the minimum high clock time, and it exits
'' with the clock and data low for half the minimum low clock time.
startfunc               or      outa, sda_bit ' Set SDA HIGH
                        or      dira, sda_bit ' Set SDA as output
                        call    #delay
                        or      outa, scl_bit ' Set SCL HIGH
                        or      dira, scl_bit ' Set SCL as output
                        call    #delay
                        andn    outa, sda_bit ' Set SDA LOW
                        call    #delay
                        andn    outa, scl_bit ' Set SCL LOW
                        call    #delay
startfunc_ret           ret

'' This routine puts the I2C bus in a known state.  It issues up to nine clock
'' pulses waiting for the input to be in a high state.  It exits with the clock
'' driven high and the data floating in the high state for the minimum high
'' clock time.
initializefunc          andn    dira, sda_bit ' Set SDA as input
                        or      outa, scl_bit ' Set SCL HIGH
                        or      dira, scl_bit ' Set SCL as output
                        call    #delay
                        mov     count1, #9    ' Set for up to 9 loops
:loop                   andn    outa, scl_bit ' Set SCL LOW
                        call    #delay
                        call    #delay
                        or      outa, scl_bit ' Set SCL HIGH
                        call    #delay
                        test    sda_bit, ina    wz
        if_nz           jmp     #initializefunc_ret ' Quit if input is HIGH
                        djnz    count1, #:loop
initializefunc_ret      ret                   ' Quit after nine clocks

'' This routine delays for the minimum high clock time, or half the minimum
'' low clock time.  This delay routine is also used for the setup and hold
'' times for the start and stop signals, as well as the output data changes.
delay                   mov     delaycnt, cnt
                        add     delaycnt, #DELAY_CYCLES
                        waitcnt delaycnt, #0
delay_ret               ret

'PUB ReadPage(SCL, devSel, addrReg, dataPtr, count) : ackbit
readpagefunc            rdlong  devsel1, parm1
                        add     parm1, #4
                        rdlong  addrreg1, parm1
                        add     parm1, #4
                        rdlong  dataptr1, parm1
                        add     parm1, #4
                        rdlong  count2, parm1

'' Read in a block of i2c data.  Device select code is devSel.  Device starting
'' address is addrReg.  Data address is at dataPtr.  Number of bytes is count.
'' The device select code is modified using the upper 3 bits of the 19 bit addrReg.
'' Return zero if no errors or the acknowledge bits if an error occurred.
'   devSel |= addrReg >> 15 & %1110
                        mov     t1, addrreg1
                        shr     t1, #15
                        and     t1, #%1110
                        or      devsel1, t1
'   Start(SCL)                          ' Select the device & send address
                        call    #startfunc
'   ackbit := Write(SCL, devSel | Xmit)
                        mov     parm1, devsel1
                        or      parm1, #Xmit
                        call    #writebytefunc
                        mov     ackbit2, parm1
'   ackbit := (ackbit << 1) | Write(SCL, addrReg >> 8 & $FF)
                        mov     parm1, addrreg1
                        shr     parm1, #8
                        and     parm1, #$ff
                        call    #writebytefunc
                        shl     ackbit2, #1
                        or      ackbit2, parm1
'   ackbit := (ackbit << 1) | Write(SCL, addrReg & $FF)          
                        mov     parm1, addrreg1
                        and     parm1, #$ff
                        call    #writebytefunc
                        shl     ackbit2, #1
                        or      ackbit2, parm1
'   Start(SCL)                          ' Reselect the device for reading
                        call    #startfunc
'   ackbit := (ackbit << 1) | Write(SCL, devSel | Recv)
                        mov     parm1, devsel1
                        or      parm1, #Recv
                        call    #writebytefunc
                        shl     ackbit2, #1
                        or      ackbit2, parm1
'   repeat count - 1
'      byte[dataPtr++] := Read(SCL, ACK)
'   byte[dataPtr++] := Read(SCL, NAK)
:loop                   cmp     count2, #1 wz
        if_z            mov     parm1, #NAK
        if_nz           mov     parm1, #ACK
                        call    #readbytefunc
                        wrbyte  parm1, dataptr1
                        add     dataptr1, #1
                        djnz    count2, #:loop

'   Stop(SCL)
                        call    #stopfunc
'   return ackbit
                        mov     parm1, ackbit2
readpagefunc_ret        ret

'PUB WritePage(SCL, devSel, addrReg, dataPtr, count) : ackbit
writepagefunc           rdlong  devsel1, parm1
                        add     parm1, #4
                        rdlong  addrreg1, parm1
                        add     parm1, #4
                        rdlong  dataptr1, parm1
                        add     parm1, #4
                        rdlong  count2, parm1

'' Write out a block of i2c data.  Device select code is devSel.  Device starting
'' address is addrReg.  Data address is at dataPtr.  Number of bytes is count.
'' The device select code is modified using the upper 3 bits of the 19 bit addrReg.
'' Most devices have a page size of at least 32 bytes, some as large as 256 bytes.
'' Return zero if no errors or the acknowledge bits if an error occurred.  If
'' more than 31 bytes are transmitted, the sign bit is "sticky" and is the
'' logical "or" of the acknowledge bits of any bytes past the 31st.
'   devSel |= addrReg >> 15 & %1110
                        mov     t1, addrreg1
                        shr     t1, #15
                        and     t1, #%1110
                        or      devsel1, t1
'   Start(SCL)                          ' Select the device & send address
                        call    #startfunc
'   ackbit := Write(SCL, devSel | Xmit)
                        mov     parm1, devsel1
                        or      parm1, #Xmit
                        call    #writebytefunc
                        mov     ackbit2, parm1
'   ackbit := (ackbit << 1) | Write(SCL, addrReg >> 8 & $FF)
                        mov     parm1, addrreg1
                        shr     parm1, #8
                        and     parm1, #$ff
                        call    #writebytefunc
                        shl     ackbit2, #1
                        or      ackbit2, parm1
'   ackbit := (ackbit << 1) | Write(SCL, addrReg & $FF)          
                        mov     parm1, addrreg1
                        and     parm1, #$ff
                        call    #writebytefunc
                        shl     ackbit2, #1
                        or      ackbit2, parm1
'   repeat count                        ' Now send the data
'      ackbit := ackbit << 1 | ackbit & $80000000 ' "Sticky" sign bit         
'      ackbit |= Write(SCL, byte[dataPtr++])
:loop                   shl     ackbit2, #1 wc
        if_c            or      ackbit2, signbit
                        rdbyte  parm1, dataptr1
                        add     dataptr1, #1
                        call    #writebytefunc
                        or      ackbit2, parm1
                        djnz    count2, #:loop
'   Stop(SCL)
                        call    #stopfunc
'   return ackbit
                        mov     parm1, ackbit2
writepagefunc_ret       ret

signbit         long    $80000000
scl_bit         res     1
sda_bit         res     1
count1          res     1
t1              res     1
t2              res     1
data1           res     1
ackbit1         res     1
delaycnt        res     1
parm1           res     1
devsel1         res     1
addrreg1        res     1
dataptr1        res     1
count2          res     1
ackbit2         res     1

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