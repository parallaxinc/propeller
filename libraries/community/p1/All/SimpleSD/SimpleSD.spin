CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

OBJ
  PST         : "Parallax Serial Terminal"
  SDCard      : "SDCard"

var                                 
  byte buffer[512] ' Just one sector

PUB main | i


' 1) Connect the SD interface to the propeller. Change the "SDCard.start" line
'    to use the correct pin numbers.
' 2) Format an SD card (FAT or FAT32)
' 3) Use notepad to create a text file. Copy the file to the SD card.
' 4) Insert the SD card into the propeller interface and run this code
' 5) Use the Parallax Serial Terminal to see the output
      

  ' Give the user time to switch from the Propeller Tool to the
  ' Serial Termial
  PauseMSec(2000)

  ' Start the debug terminal
  PST.Start(115200)                                       
  PST.Home
  PST.Clear
  PST.str(string("Started",13,"Mount status: "))

  ' Mount the SD card (these are the port pins I am using)
  '                          DO  CLK DI  CS
  i := SDCard.start(@buffer, 24, 26, 25, 27)
  PST.hex(i,4)
  PST.str(string(13,"First data-sector: "))

  ' Print the first data sector number
  PST.hex(SDCard.getFirstFileSector,4)
  PST.str(string(13,"First few bytes of file:",13))
  ' Read the first sector from the first file
  SDCard.readFileSectors(@buffer,0,1)   

  ' Show 16 bytes of the file data
  i :=0
  repeat while i<16  
    PST.hex(buffer[i],2)
    PST.char(32)
    ++i        
 
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)
                                                               