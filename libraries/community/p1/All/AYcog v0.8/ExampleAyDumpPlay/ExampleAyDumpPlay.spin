'
' A minimalistic AY/YM dump player.

CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    playRate = 50'Hz 
    sdPins   = 0
    rightPin = 10  
    leftPin  = 11
                       
VAR
  byte  buffer[100]

OBJ
  AY : "AYcog"
  SD : "fsrw" 
                                                      
PUB Main 

  sd.mount(sdPins)                      ' Mount SD card
  ay.start(rightPin, leftPin)           ' Start the emulated AY/YM in a cog
  sd.popen(string("cybernet.ym"), "r")  ' Open tune
  sd.pread(@buffer, 62)                 ' Skip header (header size varies from tune to tune)
    
  'Main loop
  repeat
    waitcnt(cnt + (clkfreq/playRate))   ' Wait one VBL
    sd.pread(@buffer, 16)               ' Read 16 bytes from SD card
    ay.updateRegisters(@buffer)         ' Write 16 byte to AYcog 
 