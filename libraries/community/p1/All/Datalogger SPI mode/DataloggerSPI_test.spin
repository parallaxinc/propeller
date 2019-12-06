{{
/**
 * Test program for DataloggerSPI object and Spin Stamp. Tested with firmware v3.62
 * The program starts by deleting a subdirectory "testdir" in which a file "testfile.txt"
 * is written. After that, it will try to recreate them. The file will contain 5 bytes ("ABCDE").
 *
 * Revision History:
 * December 24, 2007 v1.0: Initial release.
 * @author Peter Verkaik (verkaik6@zonnet.nl)
 */
}}


CON
  'clock settings for spin stamp
  _clkmode = xtal1+pll8x
  _xinfreq = 10_000_000
  
  debugPort = 2 '0=none, 1=propeller TX/RX, 2=spin stamp SOUT/SIN
  
  '//Spin stamp pin assignments
  stampSOUT = 16  'serial out (pin 1 of spin stamp)
  stampSIN  = 17  'serial in  (pin 2 of spin stamp)
  stampATN  = 18  'digital in (pin 3 of spin stamp, when activated, do reboot)

  '//Propeller system pin assignments
  propSCL = 28 'external eeprom SCL
  propSDA = 29 'external eeprom SDA
  propTX  = 30 'programming output
  propRX  = 31 'programming input

  'Datalogger SPI pins
  SPI_CLK   = 13                  ' Clock out       (connects to Vinculum SCLK pin)
  SPI_CS    = 11                  ' Chip Select out (connects to Vinculum CS pin)
  SPI_SDO   = 14                  ' Data out        (connects to Vinculum SDI pin) 
  SPI_SDI   = 10                  ' Data in         (connects to Vinculum SDO pin)

  CR = 13                         ' Carriage return


OBJ
  debug:   "MultiCogSerialDebug"    '//debug serial driver
  logger:  "DataloggerSPI"
  

VAR
  byte debugSemID    'lock to be used by debug
  long atnStack[10]  'stack for monitoring ATN pin
  byte buffer[6]
  byte dirbuf[256]   'to hold directory command output
  

PUB start | t, s
  'get lock for debug
  debugSemID := locknew
  'start debug
  case debugPort
    1: debug.start(propRX,propTX,0,9600,debugSemID)
    2: debug.start(stampSIN,stampSOUT,0,9600,debugSemID)
  waitcnt(clkfreq + cnt) 'wait 1 second
  'monitor ATN pin (optional)
  if debugPort == 2
    cognew(atnReset,@atnStack)

  'start datalogger
  logger.DataloggerSPI(SPI_CS,SPI_CLK,SPI_SDI,SPI_SDO)
  
  debug.cprintf(string("Datalogger Test Program for Spin Stamp\r"),0,true)
  s := -1
  waitcnt(clkfreq / 4 + cnt)      ' Wait for 250ms initialization
  repeat
    logger.receivePromptOrError(2000)     ' get unsollicited message from datalogger
    if logger.diskPresent
      debug.cprintf(string("%s\r"),logger.firmwareVersion,true)
      debug.cprintf(string("disk freespace %d bytes\r"),logger.diskFreeSpace(0),true)       'diskFreeSpace must be called prior to diskIdentify
      debug.cprintf(string("disk freespace %d kilobytes\r"),logger.diskFreeSpace(10),true)  'or diskIdentify will not report free space
      debug.cprintf(string("disk freespace %d megabytes\r"),logger.diskFreeSpace(20),true)  '(since version 3.61)
      if logger.diskIdentify(@dirbuf,255,0)                                                    
        debug.cprintf(string("%s\r"),@dirbuf+1,true)                                  
      debug.cprintf(string("disk serial number %08x\r"),logger.diskSerialNumber,true)
      quit
    else
      debug.cprintf(string("No disk present. Please insert disk.\r"),0,true)
      waitcnt(clkfreq+cnt) 'wait 1 second
      
  'check for presence of directory testdir and file testfile.txt which are both to be deleted
  if logger.changeDirectory(string("\"))
    if logger.changeDirectory(string("testdir"))
      if logger.deleteFile(string("testfile.txt"))
        debug.cprintf(string("File testfile.txt deleted\r"),0,true)
      else
        debug.cprintf(string("File testfile.txt not found\r"),0,true)
      if logger.changeDirectory(string(".."))
        if logger.deleteDirectory(string("testdir"))
          debug.cprintf(string("Directory testdir deleted\r"),0,true)
        else
          debug.cprintf(string("Directory testdir not deleted\r"),0,true)
      else
        debug.cprintf(string("Unable to move to higher directory\r"),0,true)
    else
      debug.cprintf(string("Directory testdir not found\r"),0,true)
  else
    debug.cprintf(string("Unable to move to rootdirectory\r"),0,true)
    
  'create directory testdir and file testfile.txt
  if logger.changeDirectory(string("\"))
    if logger.directory(0,@dirbuf,255,0)
      debug.cprintf(string("rootdirectory is:\r%s"),@dirbuf,true)
    else
      debug.cprintf(string("dirbuf too small to hold directory listing\r"),0,true)
    debug.cprintf(string("creating testdir and testfile.txt ...\r"),0,true)
    if logger.makeDirectory(string("testdir"),0)
      if logger.changeDirectory(string("testdir"))
        if logger.openFileForWrite(string("testfile.txt"),0)
          if logger.writeToFile(string("ABCDE"),5,0)
            if logger.closeFile(string("testfile.txt"))
              if logger.readFile(string("testfile.txt"),@buffer,5,0)
                buffer[5] := 0
                debug.cprintf(string("Using readFile: File testfile.txt: %s\r"),@buffer,true)
                debug.cprintf(string("Filesize is %d bytes\r"),logger.filesize(string("testfile.txt")),true)
              else
                debug.cprintf(string("file not read\r"),0,true)
              if logger.openFileForRead(string("testfile.txt"),0)
                if logger.readFromFile(@buffer,5,0)
                  buffer[5] := 0
                  debug.cprintf(string("Using readFromFile: File testfile.txt: %s\r"),@buffer,true)
                else
                  debug.cprintf(string("Unable to read from file\r"),0,true)
                logger.closeFile(string("testfile.txt"))
              else
                debug.cprintf(string("Unable to open file for read\r"),0,true)
            else
              debug.cprintf(string("file not closed\r"),0,true)
          else
            debug.cprintf(string("file write error\r"),0,true)
        else
          debug.cprintf(string("file not opened for write\r"),0,true)
      else
        debug.cprintf(string("not moved to directory\r"),0,true)
    else
      debug.cprintf(string("directory not created\r"),0,true)
  else
    debug.cprintf(string("rootdirectory not selected\r"),0,true)

  'enter loop to allow manual commands
  repeat
    if s == -1                    ' Buffer not full in Vinculum?
      s := debug.rxcheck          ' Look for typed character
    if s > 0                      ' Character pending?
      if logger.writeByte(s)
        debug.cprintf(string("%c"),s,true)    ' If transmitted ok, echo to display
        s := -1                    ' Allow another
    if ((t := logger.readByte)) <> -1 'if new data read
      if ((t => " ") AND (t =< $7E))
        debug.cprintf(string("%c"),t,true)        ' Display all displayable characters
      else
        debug.cprintf(string("{%02x}"),t,true)    ' Or display hex code of others
        if t == CR
          debug.cprintf(string("%c"),t,true)      ' print CR as code and as character


PUB atnReset
  repeat  'loop endlessly
    if INA[stampATN] == 1
      reboot

      