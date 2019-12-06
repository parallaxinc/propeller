'' +--------------------------------------------------------------------------+
'' | Cluso's Propeller System Information                                     |
'' +--------------------------------------------------------------------------+
'' |  Author:        (c)2012 "Cluso99" (Ray Rodrick)                          |
'' |  License:       MIT License - See end of file for terms of use           |
'' +--------------------------------------------------------------------------+
'' RR20120506   displays propeller system information

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  PIN_SI        = 31            'serial in
  PIN_SO        = 30            'serial out
  SIO_MODE      = 0             'serial mode
  SIO_BAUD      = 115200        'serial baud

OBJ
  fdx   :       "FullDuplexSerial"
  str   :       "Simple_Numbers"
  
VAR
        byte    cogsfree        ' a bit for each cog; 1=free  
        
PUB start
  waitcnt(clkfreq*3 + cnt)
  fdx.start(PIN_SI,PIN_SO,SIO_MODE,SIO_BAUD)
  info                                                  ' print the info
  repeat                                                ' and just loop here indefinately

PRI PrintString(stringPointer)
'   fdx.str(stringPointer)
    repeat strsize(stringPointer)
      fdx.tx(byte[stringPointer++])                     ' when using fdx
'     tv.out(byte[stringPointer++])                     ' when using tv
     

PRI info | i,j, cogs[8]


    PrintString(string(" ClockFreq "))
    PrintString(str.dec(long[$0]))
    PrintString(string("Hz, ClockMode "))
    PrintString(str.ihex(byte[$4],2))
    PrintString(string(", Cog "))
    PrintString(str.dec(cogid))
    PrintString(string(13))
    
    j~
    repeat i from 0 to 7
      cogs[i] := cognew(@entry,0) +1                    ' try to start cog(s)
      if cogs[i]                                        ' free? (=started)
        j++                                             ' yes:
        cogsfree |= (1<<i)                              ' yes: set respective bit on
    PrintString(string(" Cogs available("))
    PrintString(str.dec(j))
    PrintString(string("): "))
    PrintString(str.ibin(cogsfree,8))
    PrintString(string(" = "))
    repeat i from 0 to 7
      if cogs[i]
        PrintString(str.dec(cogs[i]-1))          ' print avail cog#
        PrintString(string(" "))
        cogstop(cogs[i] -1)                             ' stop the cog(s)
    PrintString(string(13,13))

DAT
'' Just a simple pasm program to test if a cog is available
              org       0
entry         jmp       #entry                  ' loops here until cogstop forced!

dat                                                   
{{
+------------------------------------------------------------------------------------------------------------------------------+
|                                                   TERMS OF USE: MIT License                                                  |                                                            
+------------------------------------------------------------------------------------------------------------------------------+
|Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    | 
|files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    |
|modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software|
|is furnished to do so, subject to the following conditions:                                                                   |
|                                                                                                                              |
|The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.|
|                                                                                                                              |
|THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          |
|WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         |
|COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   |
|ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         |
+------------------------------------------------------------------------------------------------------------------------------+
}}