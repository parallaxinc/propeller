{
How to use:
1) copy this code to propeller
2) open file you want to install on the propeller
3) press F8
4) press save EEPROM file
5) save file as code.bin
6) place on uSD card or email to custoers that need updates.
7) if mass installing you can add a file called "nodelete.txt" to card
   and the file will not be deleted off the uSD card like normal. 
}


CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000       '80 MHz

    PAGESIZE = 32
    
VAR byte pauseval
    byte buffer[PAGESIZE*2]
    byte wdcog
    long maincog
    long ss[1000]
OBJ
    SD  : "FSRW"
    sdspi : "sdspiFemto"       ' SPIN program loader and support routines  
    i2c : "Basic_I2C_Driver" 


  
PUB start|i,j,start_time
  'start watchdog
  'maincog:=cogid
  wdcog:=cognew(wd,@ss)

  'access SD card 
  i:=sd.mount(0)
  if (i<>0)
    loadTop 'No SD Card load top half

  'stop watchdog
  cogstop(wdcog)
  
  'See if code.eeprom was present
  i:=sd.popen(string("code.bin"), "r")
  if (i<>0)
    loadTop 'File not there so load top half

  'Load EEPROM code from uSD card
  repeat j from 0 to constant(($8000/PAGESIZE)-1)
    i:=sd.pread(@buffer, PAGESIZE)
    i2c.WritePage(i2c#BootPin, i2c#EEPROM, $8000+(j*PAGESIZE), @buffer, PAGESIZE)
    start_time := cnt ' prepare to check for a timeout
    repeat while i2c.WriteWait(i2c#BootPin, i2c#EEPROM, $8000+(j*PAGESIZE))
      if cnt - start_time > clkfreq / 10
        i:=false
        quit

  'if nodelete.txt is not present delete image
  if (sd.popen(string("nodelete.txt"), "r")<>0)
    sd.popen(string("code.bin"), "d" )

  'load the EEPROM contents
  loadTop

PRI wd
  'wait for 10th of a sec
  waitcnt(cnt+clkfreq/2)

  'stop hanged main cog
  cogstop(maincog)

  'Load program
  loadTop
  
PRI loadTop
  sdspi.bootEEPROM(sdspi#bootAddr + $8000)

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