{{///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SYSLOG   - Multi-cog debugging/information logging for SD card and optionally serial port
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
// v1.3 - Implemented variable watch routine
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
con

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'//// ADJUST THIS SECTION TO YOUR NEEDS /////////////////////////////////////////////////////////////////////////////////
'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  _ECHO         = true          'flag if log data is to be echoed to the serial port (see echo() description)

  VAR_LIST_SIZE = 10            'Size of array to monitor. Set to 0 to disable function


  PC_BAUD       = 115200        'serial port speed (pins are fixed to default 30/31)
  
  'PIN definitions--------------------------------------------------------------------------------
  SD_CD         =  9            'I SD card - Card Detect
  SD_CS         = 11            'O SD card - Chip Select (0=card inserted)
  SD_DI         = 12            'O SD card - Data In (TO card)
  SD_SCLK       = 13            'O SD card - Serial Clock
  SD_DO         = 14            'I SD card - Data Out (FROM card)

  RTC_SCL       = 28            'B RTC - Serial CLock
  RTC_SDA       = 29            'B RTC - Serial DAta

  _DELIM        = $7C           'field delimeter for log $(20=space, 7C=|, see character chart)

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  TITLE_SIZE    = 10            'Max title size in log
  VARNAME_BITS  = 4             'number of bits for variable name's length (4-> 16 chars max for var name)
  VARNAME_SIZE  = 1 << VARNAME_BITS 'Max name length for variable watching (includes trailing 0)

  #0, __INFO, __WARN, __ERROR, __CRITICAL, __FATAL      'Level of message enumeration

obj
  fat   :       "DS1307_SD-MMC_FATEngine"
  rtc   :       "DS1307_RTCengine"
  c     :       "Format"
  s     :       "Parallax Serial Terminal" '"fullDuplexSerialPlus"

dat
  SFNAME      byte "SYSLOG.log",0               'Log filename in SD card
  sStart      byte "SYSLOG Starting >>>>>>",0   'Init string
  sEnd        byte "SYSLOG Ending <<<<<<<<",0   'Finishing string
  slevel      byte "IWECF"                      'Level characters
  wstr        byte 00[132], 00, 00              'Working area for message line
  semID       byte 255                          'Init semId in invalid state
  rtclock     byte 255                          'init RTC lock in invalid state
  vecho       byte _echo                        'init echo default

  title0      byte " "[TITLE_SIZE],0                    'Function title in log for COG
  title1      byte " "[TITLE_SIZE],0                    '| 
  title2      byte " "[TITLE_SIZE],0                    '| 
  title3      byte " "[TITLE_SIZE],0                    '| 
  title4      byte " "[TITLE_SIZE],0                    '| 
  title5      byte " "[TITLE_SIZE],0                    '| 
  title6      byte " "[TITLE_SIZE],0                    '| 
  title7      byte " "[TITLE_SIZE],0                    '|
  titles      word @title0,@title1,@title2,@title3,@title4,@title5,@title6,@title7

  var_add     word 0[VAR_LIST_SIZE]             'Variable addresses
  var_name    byte 0[VAR_LIST_SIZE*VARNAME_SIZE]'Variable names
  var_qty     byte 0                            'Index of last variable being watched
  var_lst     long 0[VAR_LIST_SIZE]             'Last value of variable
                              
PUB rtc_lock                     'get new lock for sharing the RTC clock over the I2C bus
''Returns the lock for sharing the I2C bus where the RTC is placed
''Use it system-wide for each instance of the RTC engine

  if rtclock == 255
    rtclock := locknew
  return rtclock
  
pub Start | pfile, errorString, errorNumber
''Starts logging engine
''
''Opens \syslog.log file for appending on SD card
''
''Call it only once from top object

  if semID <> 255
    return                                              'Exit if already started!!!

  semID := locknew                                      'Reserve lock for multicog access

' if vecho                                              'If serial port enabled at compile time
  s.start(PC_BAUD)                                      'Start console
 
  ifnot rtc.RTCEngineStart(RTC_SDA, RTC_SCL, rtc_lock)
    abort FALSE
  
  ifnot fat.FATEngineStart(SD_DO, SD_SCLK, SD_DI, SD_CS, -1, SD_CD, RTC_SDA, RTC_SCL, rtc_lock)
    abort FALSE
  
  fat.mountPartition(0)                                 'Mount it

  errorString := \fat.newFile(@SFNAME)                  'Create SYSLOG.LOG if it doesn't exist
  errorNumber :=  fat.partitionError                    'Returns zero if no error occurred.
  
  if(errorNumber)                                       'Try to handle the "entry_already_exist" error.
    ifnot (errorNumber == fat#Entry_Already_Exist)
      abort errorString                                 'Unable to handle the error. Continue passing the error.

  pfile := fat.Openfile(@SFNAME, "A")                   'Open file for appending
  
  log(__INFO, @sStart)

  if VAR_LIST_SIZE
    cognew(monitor(0), @MonStk)
  
pub Stop
''Stops logging engine
''
''Closes SYSLOG.LOG and unmountspartition. Leaves FAT engine running

  log(__INFO, @sEnd)            'Signal we are aclosing SYSLOG
  fat.closeFile
  fat.unmountPartition

  if semID <> 255
    lockret(semId)              'Return semaphore
    semID := 255
    s.stop                      'Unload Serial

pub echo(pecho)
''Set echo to serial port
''
''- pecho      - true = echo log line, false=no data sent to serial port

  vecho := pecho & $FF          'Save flag to echo (true) or not to echo (false)

pub module(ptitle)              'Set a title for the COGs function
''Helps finding log information for a given cog function
''
''- ptitle                      Pointer to string with title for cog function

  bytefill(@@titles[cogid], " "   , TITLE_SIZE)
  bytemove(@@titles[cogid], ptitle, TITLE_SIZE) 
  
pub log(plevel, pmsg)| k
''Log message with severity
''Params:
''  plevel   - Enumeration __INFO, __WARN, __ERROR, __FATAL
''  pmsg     - String with message (100chars max)

  repeat until not lockset(semID)                       'Wait until other cogs finish logging

  'Format working string with logging information-----------------------------
  '          1111111111222222222233333333334
  '01234567890123456789012345678901234567890
  'yyyy-mm-dd|hh:mm:ss|D|C|Module    |L|Text

  rtc.readtime                  'Get current time stamp

  'XXXX check for time boundary in order to cycle syslog
  

  k := c.bprintf(@wstr,0,string("%04d-")       ,rtc.ClockYear)
  k := c.bprintf(@wstr,k,string("%02d-")       ,rtc.ClockMonth)
  k := c.bprintf(@wstr,k,string("%02d" ,_DELIM),rtc.ClockDate)
  k := c.bprintf(@wstr,k,string("%02d:")       ,rtc.ClockHour)
  k := c.bprintf(@wstr,k,string("%02d:")       ,rtc.ClockMinute)
  k := c.bprintf(@wstr,k,string("%02d" ,_DELIM),rtc.ClockSecond)
  k := c.bprintf(@wstr,k,string("%d"   ,_DELIM),rtc.ClockDay)
  k := c.bprintf(@wstr,k,string("%d"   ,_DELIM),cogid)
  k := c.bprintf(@wstr,k,string("%-10s",_DELIM),@@titles[cogid])
  k := c.bprintf(@wstr,k,string("%c"   ,_DELIM),slevel[(plevel #> __INFO) <# __FATAL])
  k := c.bprintf(@wstr,k,string("%.100s\r")    ,pmsg)
  wstr[k] := 0

  if vecho                                                                                
    s.str(@wstr)
  
  fat.writeString(@wstr)        'Write data
  'fat.flushData                'Leave unflushed for speed
 
  lockclr(semID)
'----------------------------------------------------------------------------------
pub AddVar(pvaradd, pvarname) | offset
''Add a variable to watch for changes and log
''
''pvaradd   -  Pointer to Variable's address
''pvarname  -  Pointer to string with variable name

  if var_qty < VAR_LIST_SIZE
    offset := var_qty << VARNAME_BITS
    bytefill(@var_name[offset], 0       , VARNAME_SIZE)
    bytemove(@var_name[offset], pvarname, VARNAME_SIZE)
    var_add[var_qty] := pvaradd
    var_lst[var_qty] := long[pvaradd]
    var_qty++


dat
  MonStk      long 0[150]
  txt         byte "Variable '"
  vtx         byte " "[VARNAME_SIZE-1],"' is now "
  vdc         byte " "[12],0 'max integer size in ascii string
  
pri monitor(void) | i, offset, tv

  module(string("VarMonitor"))

  repeat
    if var_qty
      repeat i from 0 to var_qty - 1
        if (tv:=long[var_add[i]]) <> var_lst[i]
          offset := i << VARNAME_BITS
          bytefill(@vtx, 32, constant(VARNAME_SIZE-1))
          bytemove(@vtx, @var_name[offset], strsize(@var_name[offset]))
          c.itoa(tv,@vdc)
          var_lst[i] := tv
          log(__INFO, @txt)
           
  
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