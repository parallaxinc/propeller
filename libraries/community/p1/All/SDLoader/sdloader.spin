'' =================================================================================================
''
''   File....... sdloader.spin  (version 1.00)
''   Requires... SD Card and reader (FAT16), boot EEPROM must be 64K not 32K
''   Purpose.... resident loader to allow updates via SD card
''   Author..... Brian Riley, Underill Center, VT, USA
''               various parts based upon work/ideas from
''               Matthew Cornelisse
''               Nick McClanahan
''               Jon McPhalen
''               and a lot of work by Mike Green on the underlying
''                 hardware drivers as well as help converting to the Femto
''                 based sd/spi/i2c hardware handlers
''
''               -- see below for terms of use
''
''   E-mail..... brianbr@wulfden.org
''   Started.... 5/5/2010
''   Updated.... 5/9/2010
'' =================================================================================================
''
''    How to use:
''
''  1) Load this code to propeller in normal load to low EEPROM fashion
''  2) open the actual firmware file you want to be on the propeller
''  3) select save to EEPROM file and name it "update.pgm" and save to SD card
''  4) insert SD card to propeller system and power up
''  5) sdloader will read and load "update.pgm" to high EEPROM, erase the file
''     then load from high EEPROM to RAM and begin running the new program
''  6) if you have a need to load a large number of boards with the same file
''     create and save to the SD card an empty file named "nodelete.txt". This
''     will stop sdloader from erasing the file
''------------------------------------------------------------------------------
''
''    Additional features
''
''  7) If you need to update the sdloader program itself repeat steps 2-5, except
''     name the file "loader.pgm" and it will be loaded into low EEPROM, step 6
''     also applies with regard to file erasure.
''  8) If you want/need to run a program for a quick test, you may open the file
''     and save to EEPROM file, naming it "run.pgm" and save it to the SD card.
''     sdloader will see this and load it directly to RAM and run it. No erase
''     option is available. Upon power cycling or hitting reset no trace of the
''     program is left on the hardware except the file on the SD card.
''  9) If there is a "run.pgm" the sdloader is terminated by the new load and run.
''     If not it drops down to step 11.
'' 10) ANY or ALL of the three .PGM files may be present on the SD card. sdloader
''     looks first for "loader.pgm", then "update.pgm" and then "run.pgm"
'' 11) If no SD card is present, or an SD card is present, but none of the named
''     files are there, sdloader drops to load from high EEPROM to RAM and run.
'' 12) In step 10 if no intelligible program is in high EEPROM it will still be
''     loaded to RAM and run ... ya get what you get!
''
''------------------------------------------------------------------------------


CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000       '80 MHz

    PAGESIZE = 32

    LO_EEPROM = $0000           ' based upon 24LC512 (64KB)
    HI_EEPROM = $8000


VAR byte buffer[PAGESIZE]
    long maincog
    long ss[50]                ' Stack for watchdog timer
    long ioControl[2]

OBJ
    SD    : "fsrwFemto"        ' Has different mount call
    sdspi : "sdspiFemto"       ' SPIN program loader and support routines  

DAT

RunNow                  byte    "run.pgm", 0
NewLoader               byte    "loader.pgm", 0
NewFirmware             byte    "update.pgm", 0
NoDelete                byte    "nodelete.txt", 0

  
PUB start | wdcog
  maincog := cogid              ' get cog# of current cog

  sd.start(@iocontrol)          ' start fsrw, point to IO control block

  wdcog:=cognew(wd,@ss)         ' start watchdog

  if \sd.mount(0,1,2,3) == 0    ' access SD card (DO,Clk,DI,CS)
                                ' yes, card mounted
    cogstop(wdcog)              ' stop watchdog

                                ' test for file to be loaded into low
                                ' EEPROM, nominally a replacement bootloader
    \loadEEPROM(@NewLoader, LO_EEPROM)

                                ' test for file to be loaded into high
                                ' EEPROM, this will be the normal running program
    \loadEEPROM(@NewFirmware, HI_EEPROM)

                                ' test for file to be immediately loaded
                                ' into RAM and RUN, leaving no EEPROM footprint
    if \sd.popen(@RunNow, "r") == 0
      sd.bootSDCard             ' this loads the current open file from SD card and runs it
                                ' successful, the  new program is now in command
                                ' fail, it drops through to default high EEPROM prog

  sdspi.bootEEPROM(sdspi#bootAddr + $8000) ' load from 2nd 32K of EEPROM


PRI wd
  waitcnt(cnt+clkfreq/2)        ' wait for 10th of a second

  cogstop(maincog)              ' stop hung main cog

  sdspi.bootEEPROM(sdspi#bootAddr + $8000) ' load from 2nd 32K of EEPROM


PRI loadEEPROM (fname, eeAdr) | a, c, d

  eeAdr += sdspi#bootAddr     ' always use boot EEPROM

  if \SD.popen(fname,"r")
     abort string("Can't open file")
  if SD.pread(@buffer,PAGESIZE) <> PAGESIZE
     abort string("Can't read program")
  if SD.writeEEPROM(eeAdr,@buffer,PAGESIZE)
     abort string("Copy EEPROM write error")
  if SD.writeWait(eeAdr)
     abort string("Copy EEPROM wait error")

  a := word[@buffer+SD#vbase]   'use actual size of program

  repeat c from PAGESIZE to a - 1 step PAGESIZE
    d := (a - c) <# PAGESIZE
    if SD.pread(@buffer,d) <> d
      abort string("Can't read program")
    if SD.writeEEPROM(eeAdr+c,@buffer,d)
      abort string("Copy EEPROM write error")
    if SD.writeWait(eeAdr+c)
      abort string("Copy EEPROM wait error")

  if \SD.pclose < 0
     abort string("Error closing file")
  if \sd.popen(@NoDelete, "r") <> 0
    \sd.popen(fname, "d")


'-------------------------------------------------------------------
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
