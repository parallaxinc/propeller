{{
Modified Tiny Basic for use with 4D Systems' uOLED-96-Prop.
Definitions object derived from Propeller OS.

Copyright (c) 2008 Michael Green.  See end of file for terms of use.
}}

'' 2007-02-26 - Initial revisions for use with BOE-BOT Basic
'' 2007-09-29 - Modified for configurable serial buffer sizes
'' 2007-10-07 - Added changes for uOLED-96-Prop support

CON
'' Hardware dependent and other basic definitions

  clockMode   = xtal1 | pll8x
  xtalClock   =  8_000_000
  csOLED      =  8
  resetOLED   =  9
  d_cOLED     = 10
  wrOLED      = 11
  rdOLED      = 12
  csVHI       = 13
  spiCS       = 14
  spiClk      = 15
  spiDO       = 16
  spiDI       = 17
 
'' General hardware dependent definitions

  maxPinPairs = 16                             ' Maximum number of possible I2C busses
  i2cBootSCL  = 28                             ' I2C Clock pin for boot EEPROM
  i2cBootSDA  = i2cBootSCL + 1                 ' I2C Data pin for boot EEPROM
  bootAddr    = i2cBootSCL << 18               ' File address for boot EEPROM

'' The following are fixed locations assigned at the top of RAM memory to avoid
'' having them overwritten when a new program is loaded.  Most of these are pointers
'' to work areas allocated "below" them.  The last pointer is reserved for non-system
'' programs

  endMemory   = $8000                          ' Address past the end of RAM
  initMarker  = endMemory -  4                 ' Unique marker for initialized data
  memPtr      = endMemory -  8                 ' Address of last allocated long
  randomSeed  = endMemory - 12                 ' Random seed for "?" operator
  loaderCog   = endMemory - 16                 ' Cog number + 1 of loader cog
  userPtr     = endMemory - 20                 ' Address of work area for "user"
  ioControl   = endMemory - 28                 ' I/O control block for general use
  endFree     = ioControl                      ' Address past initial free memory

  uniqueMark  = $965A3EC1                      ' Indicates that RAM was initialized
  noSuchAddr  = $8000                          ' "Invalid" address for initializing pointers

'' Command definitions for i2cSpiLdr routines

  ioReadCmd   = %00000001                      ' Read from EEPROM to HUB RAM (16 bit addresses)
  ioWriteCmd  = %00000010                      ' Write to EEPROM from HUB RAM (16 bit addresses)
  ioRead1Cmd  = %00000011                      ' Read from a device with only 8-bit addresses
  ioWrite1Cmd = %00000100                      ' Write to a device with only 8-bit addresses
  ioRead0Cmd  = %00000101                      ' Read from a device without address bytes
  ioWrite0Cmd = %00000110                      ' Write to a device without address bytes
  ioBootCmd   = %00001000                      ' Read from EEPROM to HUB RAM, then start a
                                               '  new SPIN interpreter in the COG whose ID is
                                               '  supplied in the lower 3 bits of this command
                                               '  This COG is stopped before the read is done.
  ioSpiInit   = %00010000                      ' Initialize the specified SPI bus and SD card
  ioSpiStop   = %00010001                      ' Change all SD card pins to inputs
  ioSpiRead   = %00010010                      ' Read one or more bytes from the SD card
  ioSpiWrite  = %00010011                      ' Write one or more bytes from the SD card
  ioSpiBoot   = %00011000                      ' Like ioBootCmd, but uses ioSpiRead for loading
  ioCmdMask   = %00011111                      ' Used to mask off command bits
  ioSpiMask   = %00010000                      ' Used to test for SPI command codes

' Options for commands

  ioNoStore   = %00100000                      ' If set, data is not stored into main memory
                                               '  If ioBootCmd or ioSpiBoot, no cogs are
                                               '   stopped and a new cog is not started.
  ioLowSpeed  = %01000000                      ' If set, I2C runs at 100KHz rather than 400KHz
  ioStopLdr   = %10000000                      ' If set, the loader's cog is stopped after a boot

' Return status

  ioWriteErr  = %10000000                      ' An error occurred during an I2C write (NAK)

  ioTestRdy   = ioCmdMask << 24                ' Used to test 1st control long for ready
  ioTestErr   = ioWriteErr << 24               ' Used to test 1st control long for write error

'' Internal SPIN information at fixed locations in RAM/EEPROM image

  clkfreqVal  = $0000                          ' Current CLKFREQ value stored here
  clksetVal   = $0004                          ' Current CLKSET value stored here
  chksumVal   = $0005                          ' Checksum over memory stored here
  spinPbase   = $0006                          ' must be $0010
  spinVbase   = $0008                          ' number of longs loaded times 4
  spinDbase   = $000A                          ' above where $FFF9FFFF's get placed
  spinPcurr   = $000C                          ' points to SPIN code
  spinDcurr   = $000E                          ' points to local stack
  
'' Display control codes

  Bsp         = $08                            ' backspace
  Tab         = $09                            ' tab (8 spaces per)
  Lf          = $0A                            ' linefeed
  Cr          = $0D                            ' carriage return
  Esc         = $1B                            ' escape
  Delete      = $7F                            ' delete current character

'' Parameters for FullDuplexSerial to set buffer size
'' Currently: 64 bytes for receive and 64 bytes for transmit

  rxBufSize   = 1 << 6                         ' Receive buffer size (must be power of 2)
  rxPtrMask   = rxBufSize - 1                  ' Receive buffer pointer mask
  txBufSize   = 1 << 6                         ' Transmit buffer size (must be power of 2)
  txPtrMask   = txBufSize - 1                  ' Transmit buffer pointer mask

PUB allocatePRI(size)                          '' Allocate block of size bytes
  return long[memPtr] := (long[memPtr] - size) & !3

PUB allocate(size)                             '' Allocate a block of user work area
  if long[userPtr] <> noSuchAddr
    deallocate                                 ' Deallocate current area if allocated
  return long[userPtr] := allocatePRI(size)

PUB deallocate                                 '' User work area no longer in use
  long[memPtr] := endFree
  long[userPtr] := noSuchAddr                  ' Use ROM address for "invalid" address

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
