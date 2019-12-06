{{
'' =================================================================================================
''
''   File....... TI CD4067 - PASM)

''   Device..... CD4067 BB with Prop1ModRev1

''   Purpose.... Creating a PASM code to communicate & control a CD4067

''   Author..... Kenichi Kato (a.k.a. MacTuxLin) Copyright (c) 2012
''               -- see below for terms of use

''   E-mail..... MacTuxLin@gmail.com

''   Started.... 30 May 2012

''   Updated.... 06 Jun 2012
                  a. Completed version 0.3

              * ********************************************* *
              * PLEASE CHANGE THE PIN SETTINGS IN DRIVER FILE * 
              * ********************************************* *
}}
CON

  '--- --- --- --- --- ---  
  'Declaring the CPU Freq & Crystal Clock
  '--- --- --- --- --- ---  
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
  _Ms_001   = _ConClkFreq / 1_000


  '--- ***
  ' Debugging LED attached to a Prop Pin
  '--- ***
  _DebugLED       = 15

  
  '--- Available Channels on CD4067
  _cd4067_From    = 0
  _cd4067_To      = 15
  _cd4067_Sense   = 7


OBJ
  MUX   : "TI_CD4067_0v4.spin"
  DBG   : "FullDuplexSerialExt.spin"
  

PUB Main | i

  DBG.Start(31, 30, 0, 115_200)
  Pause(1500)
  DBG.Tx(0)
  

  DBG.Str(String(13, "CD4067 - CMOS De/Multiplexers"))
  DBG.Str(String(13, "============================="))
  DBG.Tx(13)

  ' Loads MUX Cog
  DBG.Str(String(13, "Load MUX ... "))
  DBG.Dec(MUX.Start)
  Pause(200)

  
  ' Test LEDs connected on Channel 6 to 15 of CD4067
  repeat 1
    repeat i from _cd4067_From to _cd4067_To
      MUX.CD4067_Send(i)
      DBG.Str(String(13, "Ch: "))
      DBG.Dec(i)
      DBG.Str(String("  ON"))
      Pause(100)
  Pause(500)


  ' Test Turn OFF CD4067
  MUX.CD4067_Off  ' PASSED
  Pause(500)


  ' Turn ON Debug LED
  DIRA[_DebugLED]~~
  OUTA[_DebugLED]~~


  ' - Again -
  ' Test LEDs connected on Channel 6 to 15 of CD4067
  repeat 1
    repeat i from _cd4067_From to _cd4067_To
      MUX.CD4067_Send(i)
      DBG.Str(String(13, "Ch: "))
      DBG.Dec(i)
      DBG.Str(String("  ON"))
      Pause(100)


  ' Test Sensing from CD4067 (Read Routine)
  DBG.Str(String(13, 13, "Getting Status for Ch# "))
  DBG.Dec(_cd4067_Sense)
  DBG.Str(String(": "))

  repeat 100
    DBG.Tx(13)
    DBG.Dec(MUX.CD4067_Read(_cd4067_Sense))
    Pause(100)

  
  OUTA[_DebugLED]~


  ' - Again x 2 -
  ' Test LEDs connected on Channel 6 to 15 of CD4067
  repeat 1
    repeat i from _cd4067_From to _cd4067_To
      MUX.CD4067_Send(i)
      DBG.Str(String(13, "Ch: "))
      DBG.Dec(i)
      DBG.Str(String("  ON"))
      Pause(100)
  

  repeat  'Endlessly
    


PRI Pause(ms) | t
{{Delay program ms milliseconds}}

  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _MS_001)