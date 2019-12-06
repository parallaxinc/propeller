{{
Modified Tiny Basic for use with 4D Systems' uOLED-96-Prop.
I2C and SPI driver interface object derived from Propeller OS.

Copyright (c) 2008 Michael Green.  See end of file for terms of use.
}}

'' 2007-02-26 - Initial revisions for use with FemtoBasic
'' 2007-10-07 - Modified for use with uOLED-96-Prop

'' This portion is intended to be incorporated into programs and is the I2C/SPI/loader
'' application interface.

'' This object provides an I2C EEPROM read/write driver set up for 100KHz or 400KHz bus
'' speeds and sequential reads and paged writes.  A special read mode will stop the caller's
'' COG before overwriting the current program, then restart the SPIN interpreter with the
'' new program.  The control information is passed in a 2 long parameter block whose address
'' is passed to the read/write driver when it is started.  The parameter block is updated
'' when the operation completes with the current device address, byte count, and HUB address.
'' An error code is posted in the command/status byte.  Note that the following layout is
'' based on long values, not on the byte layout in memory.  The bus speed and page size
'' can be configured at compilation and can not currently be changed at run time.

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
'' byte count, and HUB address are all updated to their values at that time.

'' Command codes are provided for devices with zero, one, or two address bytes to follow
'' the device selection byte.  As for all I2C devices, addressing is done using write
'' mode and the device is reselected in read mode after the last address byte.  In the
'' case of ioRead0Cmd, the device is initially selected in read mode.  For 8-bit addresses,
'' the device select code is taken from bits 15-8 of the address value.  For the case
'' without address bytes, the device select code is taken from bits 7-0 of the address value.

'' The pins used for the boot EEPROM I2C bus (at least on Parallax's Demo Board) do not
'' have a pullup on SCL.  This requires that SCL be driven both high and low.  If the bus
'' used is on pins 28 and 29, SCL is actively driven at all times.

'' SPI data is handled a little differently.  For ioSpiInit, the 6 bit pin numbers for DO,
'' Clk, DI, and CS are given from MSB to LSB of the 24 bit address field of the command and
'' are used for all further I/O operations (until an ioSpiStop is done).

OBJ
  def : "OLED_definitions"                             '' Definitions for Propeller OS
  
PUB bootEEPROM(addr) | t, p                            '' Boot SPIN from a block in EEPROM
  stopNotRegistered
  t := def#ioBootCmd | def#ioLowSpeed | cogid          ' Prepare to stop COG of caller
  return doOperation(t,addr,0,long[def#memPtr])

PUB readEEPROM(addr,buffer,count) | t                  '' Read a block from EEPROM to RAM
  t := def#ioReadCmd | def#ioLowSpeed
  return doOperation(t,addr,buffer,count)

PUB writeEEPROM(addr,buffer,count) | t                 '' Write a block to EEPROM from RAM
  t := def#ioWriteCmd | def#ioLowSpeed
  return doOperation(t,addr,buffer,count)

PUB checkPresence(addr) | t
'' This routine checks to be sure there is an I2C bus and an EEPROM at the
'' specified address.  Note that this routine cannot distinguish between a
'' 32Kx8 and a 64Kx8 EEPROM since the 16th address bit is a "don't care" for
'' the 32Kx8 devices.  Return true if the EEPROM is present, false otherwise.
  t := def#ioReadCmd | def#ioLowSpeed
  return not doOperation(t,addr,0,0)

PUB writeWait(addr) | t                                '' Wait for EEPROM to complete write
  t := cnt                                             ' Maximum wait time is 20ms
  repeat until checkPresence(addr)
    if (cnt - t) > (clkfreq / 50)
      result := true                                   ' Return true if a timeout occurred
      quit                                             ' Return false (default) otherwise

PUB initSDCard(DO,Clk,DI,CS) | addr                    '' Initialize SD card access
  addr := DO << 18 | Clk << 12 | DI << 6 | CS
  return doOperation(def#ioSpiInit,addr,0,0)

PUB stopSDCard                                         '' Stop SD card access
  return doOperation(def#ioSpiStop,0,0,0)

PUB readSDCard(addr,buffer,count)                      '' Read block(s) from SD card to RAM
  return doOperation(def#ioSpiRead,addr,buffer,count)

PUB writeSDCard(addr,buffer,count)                     '' Write block(s) to SD card from RAM
  return doOperation(def#ioSpiWrite,addr,buffer,count)

PUB bootSDCard(addr,count)| t                          '' Boot SPIN from block(s) on an SD Card
  if count < 16                                        ' Must load at least 16 bytes
    return true
  stopNotRegistered
  t := def#ioSpiBoot | cogid                           ' Prepare to stop COG of caller
  return doOperation(t,addr,0,long[def#memPtr])

PRI stopNotRegistered | t, p                           '' Stop all cogs not needed for loading
  repeat t from 0 to 7
    if t <> long[def#loaderCog]-1 and t <> cogid             
      cogstop(t)

PRI doOperation(op,addr,buffer,count)                  '' Do I2C/SPI operation
  repeat while long[def#ioControl] & def#ioTestRdy     ' Wait for previous I/O to finish
  long[def#ioControl+4] := (count << 16) | (buffer & $FFFF)
  long[def#ioControl] := (op << 24) | (addr & $FFFFFF) ' Initiate new operation
  repeat while long[def#ioControl] & def#ioTestRdy     ' Wait for it to finish
  result := (long[def#ioControl] & def#ioTestErr) <> 0 ' Return true if error occurred

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
