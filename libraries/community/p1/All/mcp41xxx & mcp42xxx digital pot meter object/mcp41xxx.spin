''*********************************
''*  MCP41xxx/42xxx Driver v1.0   *
''*  (C) 2008 Xander Soldaat.     *
''*********************************

' Write() function originally taken from another module, written by someone else.
' However, I can't remember which one and by whom it was written.
' If you know where it came from or who wrote it, I will be more than
' happy to credit them for it :)

' This code has only been tested with the 41010, the 10k Ohm single version.

' The datasheet for the 41xxx/42xxx can be found via Google easily enough :)

CON
  ' Commands to be sent to the MCP41xxx/42xxx
  CMD_NONE1     = %0000_0000
  CMD_WRITE     = %0001_0000
  CMD_SHUTD     = %0010_0000
  CMD_NONE2     = %0011_0000

  POT_NONE      = %0000_0000
  POT_0         = %0000_0001
  POT_1         = %0000_0010
  POT_BOTH      = %0000_0011

  ' Minimum and maximum values that the pots can be set to
  POT_MIN       = 0
  POT_MAX       = 255

VAR
  byte CS                                               ' Chip Select, has pull-up, 0 to enable
  byte SCK                                              ' Serial Clock 
  byte SI                                               ' Serial Data Input 

'PUB main
'  init(0, 1, 2)
'  setpot(POT_0, 0)
'  waitcnt(cnt + clkfreq)
 ' setpot(POT_0, 128)
'  waitcnt(cnt + clkfreq)
'  setpot(POT_0, 255)   

PUB init(_CS, _SCK, _SI)
'' Initialise this module, set the pins for CS, SCK and SI
  CS := _CS
  SCK := _SCK
  SI := _SI
  
  dira[CS]~~
  dira[SCK]~~
  dira[SI]~~

PUB shutdown(pot) | packet
'' Shut down the specified pot(s)
'' pot can be set to POT_0, POT_1 or POT_BOTH 
  ' sanity checking of parameter, value shouldn't drop below 0 or go above 255
  if pot < POT_0 or pot > POT_BOTH
    packet.byte[1] := CMD_SHUTD | pot
    packet.byte[0] := 0    
  

PUB setpot(pot, value) | packet
'' Sets the pot(s) to the specified value
'' pot can be set to POT_0, POT_1 or POT_BOTH
'' value can be set from 0 to 255
  ' sanity checking of parameters,
  ' value shouldn't drop below 0 or go above 255
  ' pot should be either POT_0, POT_1 or POT_BOTH
  if pot < POT_0 or pot > POT_BOTH or value < 0 or value > 255
    return 1
  else
    packet.byte[1] := CMD_WRITE | pot
    packet.byte[0] := value
    write(16, packet)

PRI write(Bits,Data) | temp                             ' Send DATA MSB first
  outa[CS] := 0                                         ' clear CS 
  temp := 1 << ( Bits - 1 )
  repeat Bits
    outa[SI] := (Data & temp)/temp                      ' Set bit value
    outa[SCK] := 1                                      ' Clock bit
    outa[SCK] := 0                                      ' Clock bit
    temp := temp / 2
    outa[SI] := 0
  outa[CS] := 1                                         ' set CS to 1      