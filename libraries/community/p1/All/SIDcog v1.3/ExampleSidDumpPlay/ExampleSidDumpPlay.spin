'
' A minimalistic SID dump player.
' Plays a C64 tune dumped from a .sid file.
'
CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    SD_PINS  = 0
    playRate = 50'Hz
    rightPin = 10  
    leftPin  = 11
                       
VAR
  byte  buffer[25]

OBJ
  SID : "SIDcog"
  SD  : "fsrw" 
  
PUB Main 

  sd.mount(SD_PINS)                     ' Mount SD card
  sid.start(rightPin, leftPin)          ' Start the emulated SID in a cog
  sd.popen(string("Lost_F~1.dmp"), "r") ' Open tune

  'Main loop
  repeat
    waitcnt(cnt + (clkfreq/playRate))   ' Wait one VBL
    sd.pread(@buffer,25)                ' Read 25 bytes from SD card
    sid.updateRegisters(@buffer)        ' Write 25 byte to SIDcog 
 