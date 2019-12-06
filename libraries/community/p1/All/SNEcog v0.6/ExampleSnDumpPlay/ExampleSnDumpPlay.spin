'
' A minimalistic SN dump player.

CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    sdPins   = 0
    rightPin = 10  
    leftPin  = 11
                       
VAR
  byte buffer[64]

OBJ
  SN : "SNEcog"
  SD : "fsrw" 
                                                      
PUB Main | continue, i, waitFor
  sd.mount(sdPins)                     ' Mount SD card
  sd.popen(string("Ending.vgm"), "r")  ' Open tune
  SN.start(rightPin, leftPin, true)    ' Start SNcog

  '"Handle" vgm header (ignore it)
  sd.pread(@buffer, 64)
  if buffer[$34] <> 0 | buffer[$35] <> 0 | buffer[$36] <> 0 | buffer[$37] <> 0
    sd.pread(@buffer, 64)       

  ' Below is a minimalistic implementation of the ".vgm" format
  ' Have a look at the .vgm file format documentation for a better understanding
  waitFor := cnt + 10_000_000
  repeat

    continue := true
    repeat while continue

      sd.pread(@buffer, 1)            ' Read a command byte

      if buffer[0] == $50             ' Was it a register update command?
        sd.pread(@buffer, 1)          ' Read the regsiter value from sd
        SN.setRegister(buffer[0])     ' Write the value to SNEcog
        
      elseif buffer[0] == $61         ' Wait an arbitrary amount of time
        sd.pread(@buffer, 2)
        waitFor := (constant(80_000_000/44100) * (buffer[0] | (buffer[1]<<8) ) ) #> 50
        waitFor := cnt + waitFor
        continue := false
        
      elseif buffer[0] == $62         ' Wait 1/60 of a second
        waitFor := cnt + constant(80_000_000/60)
        continue := false
        
      elseif buffer[0] == $63         ' Wait 1/50 of a second
        waitFor := cnt + constant(80_000_000/50)
        continue := false
        
      elseif buffer[0] == $66         ' We are finished; Lets reboot just for fun. :)
        reboot
 
    waitcnt(waitFor)                  ' Wait until the right time to
    SN.flipRegisters                  ' Update the SN registers
             