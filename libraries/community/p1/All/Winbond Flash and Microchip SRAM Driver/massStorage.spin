
'   fsrw.spin 1.4  4 February 2007   Radical Eye Software
'
'   This object provides FAT16 file read/write access on a block device.
'   Only one file open at a time.  Open modes are 'r' (read), 'a' (append),
'   'w' (write), and 'd' (delete).  Only the root directory is supported.
'   No long filenames are supported.  We also support traversing the
'   root directory.
'
'   In general, negative return values are errors; positive return
'   values are success.  Other than -1 on popen when the file does not
'   exist, all negative return values will be "aborted" rather than
'   returned.
'
'   Changes:
'       v1.1  28 December 2006  Fixed offset for ctime
'       v1.2  29 December 2006  Made default block driver be fast one
'       v1.3   6 January  2007  Added some docs, and a faster asm
'              9 January  2007  Modified to work with Propeller OS
'             22 January  2007  Added bridge to sdspi routine
'              3 February 2007  More debugging for assembly routines
'              5 February 2007  More work on bootSDCard
'       v1.4  20 February 2007  Updated to FSRW version 1.4
'              7 April    2007  Applied fix to nextfile routine
'              5 May      2009  Added support for Winbond flash driver

obj
'
'   The object that provides the block-level access.
'
   ldr    : "sdspiFemto"       ' SPIN program loader and support routines
   win    : "Winbond_Driver"   ' Driver for files stored on Winbond Flash

con
   bootAddr = ldr#bootAddr
   vBase    = ldr#vBase

var
   long fcb[4]

pub start(ioControl)
   longfill(@fcb,-1,4)
   return ldr.start(ioControl)

pub winSetVideo(cog1,cog2)
   return win.setVideo(cog1,cog2)

pub winStart(CS, Clk, DIO, DO, CS0, CS1)
   return win.start(CS, Clk, DIO, DO, CS0, CS1)

pub winStop
   return win.stop

pub stop
   return ldr.stop

pub initEEPROM(address)
   longfill(@fcb,-1,3)
   fcb[3] := address

pub bootEEPROM(address)
   return ldr.bootEEPROM(address)

pub readEEPROM(address, bufAdr, size)
   return ldr.readEEPROM(address, bufAdr, size)

pub writeEEPROM(address, bufAdr, size)
   return ldr.writeEEPROM(address, bufAdr, size)

pub checkPresence(address)
   return ldr.checkPresence(address)

pub writeWait(address) | startTime
   return ldr.writeWait(address)
   
pub initSDCard(DO, Clk, DI, CS)
   return ldr.initSDCard(DO, Clk, DI, CS)
   
pub stopSDCard
   return ldr.stopSDCard
   
pub bootSDCard(address, size)          ' Execute up to 32K from current file
   return ldr.bootSDCard(address, size)

pub readSDCard(address, bufAdr, size)
   return ldr.readSDCard(address, bufAdr, size)
   
pub writeSDCard(address, bufAdr, size)
   return ldr.writeSDCard(address, bufAdr, size)

pub out(c)                        ' Output a single character
   if fcb[0] & fcb[1] & fcb[2] == $FFFFFFFF
      ldr.writeEEPROM(fcb[3],@c,1)
      return ldr.writeWait(fcb[3]++)
   else
      return win.writeFile(@fcb,@c,1)

pub str(stringptr)                ' Output a zero-terminated string
   repeat strsize(stringptr)
      out(byte[stringptr++])

pub dec(value) | i                ' Output a decimal value
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
    
pub hex(value, digits)            ' Output a hexadecimal value
  value <<= (8 - digits) << 2
  repeat digits
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

pub bin(value, digits)            ' Output a binary value
  value <<= 32 - digits
  repeat digits
    out((value <-= 1) & 1 + "0")

pub flashSize                     ' Return the size of the flash memory in bytes
  return win.flashSize

pub readData(a,d,c)               ' Read a block of data from Flash
  return win.readData(a,d,c)

pub writeData(a,d,c)              ' Write a block of data to erased Flash
  return win.writeData(a,d,c)

pub eraseData(a)                  ' Erase a block of data
  return win.eraseData(a)

pub readSRAM(a,d,c)               ' Read a block of data from SRAM
  return win.readSRAM(a,d,c)

pub writeSRAM(a,d,c)              ' Write a block of data to SRAM
  return win.writeSRAM(a,d,c)

pub initFile(p,s)                 ' Initialize file control block
  return win.initFile(p,s)

pub openFile(p)                   ' Open a file for reading
  return win.openFile(p)

pub createFile(p)                 ' Create a file and open it for writing
  return win.createFile(p)

pub eraseFile(p)                  ' Erase an existing file
  return win.eraseFile(p)

pub readFile(p,a,c)               ' Read from an open file
  return win.readFile(p,a,c)

pub writeFile(p,a,c)              ' Write to an open file
  return win.writeFile(p,a,c)

pub firstFile(p)                  ' Set up for directory listing
  return win.firstFile(p)

pub nextFile(p)                   ' Set file control block for next file found
  return win.nextFile(p)

pub bootFile(p)                   ' Load a Spin program from an open file
  win.bootFile(p)

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
