{{///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DEMO SYSLOG - Multi-cog debugging/information logging for SD card and optionally serial port
//
// Author      : Alex Stanfield
// Updated     : 5/15/2011
// Designed For: P8X32A
// Version     : 1.02
//
// Copyright (c) 2012 Alex Stanfield
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 5/12/2012.
// v1.2 - Changed formating modules from "clib" to "format"
//
//
// Prereqs:
// SW (included - also can be downloaded from OBEX)
// - SD card driver from Kwabena W. Agyeman (DS1307_SD-MMC_FATEngine or other flavor)
// - FullDuplexSerialPlus module from Parallax
// - Format module from Peter Verkaik
// HW
// - SD card
// - RTC 
//
// General rules for usage:
// - Only one SYSLOG module per system (that's the idea anyway ;-)
// - Init only once from top object using start()
// - Each cog can set it's Title for convenience using the module()
// - If you are using another RTC edit the "obj" section to include that one from the same implementation of the FAT SD card driver
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// Do NOT call the SD init routine (FATEngineStart) from your program, it's called from this module, so place it at the top
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}
CON   
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

obj              
  sys   : "syslog v1.3"
  c     : "format" 

var
  long stack1[150]    'Stack for second cog
  long stack2[150]    'Stack for third cog

dat
  name0 byte "APPLES" ,0
  name1 byte "ORANGES",0
  name2 byte "BERRIES",0
  name3 byte "GRAPES" ,0
  name4 byte "PEARS"  ,0
  name5 byte "LEMONS" ,0
  name6 byte "PEACHES",0
  name7 byte "PLUMS"  ,0
  names word @name0,@name1,@name2,@name3,@name4,@name5,@name6,@name7
  
pub main | i

  
  waitcnt(cnt+80_000_000)

  sys.module(string("MAIN"))    'You can change the main title even before starting the subsystem
  
  sys.start                     'Start syslog subsystem (only once from top object)

  sys.log(sys#__INFO, String("First syslog ever for the propeller!!!"))

  sys.addvar(@i, string("i (main)"))
                  
  cognew(secondary(0), @stack1) 'spawn other cogs to log data
  waitcnt(cnt+8_000_000)
  cognew(secondary(0), @stack2) '|


  repeat i from 1 to 10
    sys.log(i//4, string("This is a log line....."))    'log lines with random "level" 

  waitcnt(cnt+160_000_000)      'wait until all cogs finished before closing syslog
  sys.stop


pub secondary(void) | i, txt[50]

  sys.module(@@names[cogid])    'Change title for cog

  sys.log(sys#__INFO, string("Starting in another COG"))
  
  sys.addvar(@i, string("i (stack)"))
  
  repeat i from cogid*10 to cogid*10+10
    waitcnt(cnt+4_000_000)
    c.sprintf(@txt, string("Sample log line number: %d"), i)
   ' sys.log(i//4, @txt)

  sys.log(sys#__INFO, string("Finishing in secondary cog........"))
  repeat

{{/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}}