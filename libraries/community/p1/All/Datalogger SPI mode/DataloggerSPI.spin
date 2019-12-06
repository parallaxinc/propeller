{{
/**
 * This object provides methods to access the Parallax Datalogger (#27937) using SPI.
 * After reset/powerup, the datalogger operates in Extended Commandset and Binary input.
 * This object does that also so there should be no communication issues regarding the protocol.
 * Although there are methods to set the commandset and monitormode, these are not required.
 *
 * One issue of the datalogger is that it may send unsollicited messages. If a disk is inserted
 * while powered up, then such a message will be sent. For this reason it is necessary to call
 * the method receivePromptOrError at the start of the main program. Best to have the disk inserted
 * prior to reset/powerup.
 *
 * Another issue is that some commands output an unknown number of bytes. The DIR command for example,
 * as that depends on the number of files in the directory. I therefore created a method 'directory'
 * that must be called first. If it returns false then method 'directoryNext' must be called repeatedly
 * until that returns true. Only then the datalogger has outputted all bytes for the DIR command.
 *
 * It is discouraged to use the methods setShortCommandset, setMonitormodeAscii, diskSuspend, diskWakeup
 * and monitorSuspend as these may lead to an unresponsive datalogger.
 * 
 * Revision History:
 * December 24, 2007 v1.0: Initial release.
 * @author Peter Verkaik (verkaik6@zonnet.nl)
 */
}}


CON

  CR      = 13  'carriage return
  BUFSIZE = 32  'size of responseBuffer
  
  '//monitor configuration commands
  cmdSCS = $10 '//10 0D ;Response none ;switches to shortened command set
  cmdECS = $11 '//11 0D ;Response none ;switches to extended command set
  cmdIPA = $90 '//90 0D ;Response none ;monitor commands use ascii values
  cmdIPH = $91 '//91 0D ;Response none ;monitor commands use binary values
  cmdSBD = $14 '//14 20 divisor 0D ;Response prompt ;change monitor baud rate
  cmdFWV = $13 '//13 0D ;Response data,prompt ;display firmware version
  cmdUE  = $45 '//45 0D ;Response 'E' ;echo 'E' for synchronization
  cmdLE  = $65 '//65 0D ;Response 'e' ;echo 'e' for synchronization

  '//disk commands
  cmdDIR = $01 '//01 0D, 01 20 file 0D ;list files in current directory
  cmdCD  = $02 '//02 20 file 0D ;change current directory
  cmdRD  = $04 '//04 20 file 0D ;reads a whole file
  cmdDLD = $05 '//05 20 file 0D ;delete subdirectory from current directory
  cmdMKD = $06 '//06 20 file 0D ;make new subdirectory in current directory
  cmdDLF = $07 '//07 20 file 0D ;delete a file
  cmdWRF = $08 '//08 20 dword 0D data ;write to currently open file
  cmdOPW = $09 '//09 20 file 0D, 09 20 file 20 datetime 0D ;open file for writing
  cmdCLF = $0A '//0A 20 file 0D ;close currently open file
  cmdRDF = $0B '//0B 20 dword 0D ;read from currently open file
  cmdREN = $0C '//0C 20 file 20 file 0D ;rename file or directory
  cmdOPR = $0E '//0E 20 file 0D, 0E 20 file 20 date 0D ;open file for reading
  cmdSEK = $28 '//28 20 dword 0D ;seek to position in currently open file
  cmdFS  = $12 '//12 0D ;get free space (< 4GB) on disk
  cmdFSE = $93 '//93 0D ;get free space on disk
  cmdIDD = $0F '//0F 0D ;get information about the disk (< 4GB)
  cmdIDDE= $94 '//94 0D ;get information about the disk
  cmdDSN = $2D '//2D 0D ;get disk serial number
  cmdDVL = $2E '//2E 0D ;get disk volume label
  cmdDIRT= $2F '//2F 20 file 0D ;list specified file with times and dates

  '//power management commands
  cmdSUD = $15 '//15 0D ;suspend disk
  cmdWKD = $16 '//16 0D ;wake disk
  cmdSUM = $17 '//17 0D ;suspend monitor

  '//debug commands
  cmdSD  = $03 '//03 20 dword 0D ;sector dump
  cmdSW  = $92 '//92 20 dword 0D data ;sector write
  cmdFWU = $95 '//95 20 file 0D ;upgrade firmware from named file on disk

  '//commands to FT232/FT245/FT2232 on usb port 1 or usb port 2
  cmdFBD = $18 '//18 20 divisor 0D ;set baud rate
  cmdFMC = $19 '//19 20 word 0D ;set modem control
  cmdFSD = $1A '//1A 20 word 0D ;set data characteristics
  cmdFFC = $1B '//1B 20 byte 0D ;set flow control
  cmdFGM = $1C '//1C 0D ;get modem status
  cmdFSL = $22 '//22 20 byte 0D ;set latency timer
  cmdFSB = $23 '//23 20 byte 0D ;set bit mode
  cmdFGB = $24 '//24 0D ;get bit mode

  '//unused I/O pins commands (not applicable to datalogger VDAP firmware)
  cmdIOR = $29 '//29 20 byte 0D ;read I/O port
  cmdIOW = $2A '//2A 20 byte byte byte 0D ;write I/O port

  '//printer commands (not applicable to datalogger VDAP firmware)
  cmdPGS = $81 '//81 0D ;get printer status
  cmdPSR = $82 '//82 0D ;printer soft reset

  '//usb device commands (not applicable to datalogger VDAP firmware)
  cmdQP1 = $2B '//2B 0D ;query usb port 1
  cmdQP2 = $2C '//2C 0D ;query usb port 2
  cmdQD  = $85 '//85 20 byte 0D ;query device
  cmdSC  = $86 '//86 20 byte 0D ;set device specified as current device
  cmdDSD = $83 '//83 20 byte 0D data ;send data to usb device
  cmdDRD = $84 '//84 0D ;read back data from usb device
  cmdSSU = $9A '//9A 20 qword 0D ;send setup data to usb device endpoint
  cmdSF  = $87 '//87 20 byte 0D ;set device specified as FTDI device
  cmdQSS = $98 '//98 0D ;query slave status (only available on VDPS)

  '//VMUSIC commands (not applicable to datalogger VDAP firmware)
  cmdVPF = $1D '//1D 20 file 0D ;play a single file
  cmdVST = $20 '//20 0D ;stop playback
  cmdV3A = $21 '//21 0D ;play all MP3 files
  cmdVSF = $25 '//25 0D ;skip forward one track
  cmdVSB = $26 '//26 0D ;skip back one track
  cmdVRD = $1F '//1F 20 byte 0D ;read command register
  cmdVWR = $1E '//1E 20 byte 0D ;write command register
  cmdVSV = $88 '//88 20 byte 0D ;set playback volume

    
VAR
  byte SPI_CS    'chip select  - connects to Datalogger pin CS
  byte SPI_CLK   'clock output - connects to Datalogger pin SCLK       
  byte SPI_SDI   'data input   - connects to Datalogger pin SDO
  byte SPI_SDO   'data output  - connects to Datalogger pin SDI

  byte responseBuffer[BUFSIZE]

  
PUB DataloggerSPI(cs,sclk,sdi,sdo)
  SPI_CS := cs
  SPI_CLK := sclk
  SPI_SDI := sdi
  SPI_SDO := sdo
  'setup lines
  outa[SPI_CS]~                   ' Select normally low
  dira[SPI_CS]~~
  outa[SPI_CLK]~                  ' Clock normally low
  dira[SPI_CLK]~~
  outa[SPI_SDO]~                  ' SDO normally low
  dira[SPI_SDO]~~
  outa[SPI_SDI]~                  ' SDI input
  dira[SPI_SDI]~
  

PUB setShortCommandset
  '/**
  ' * Switch to short command set.
  ' */
  writeByte("S")
  writeByte("C")
  writeByte("S")
  writeByte(CR)

  
PUB setExtendedCommandset
  '/**
  ' * Switch to extended command set.
  ' * This is the default mode after reset.
  ' */
  writeByte("E")
  writeByte("C")
  writeByte("S")
  writeByte(CR)
  
  
PUB setMonitormodeAscii
  '/**
  ' * Display values in printable ASCII characters and input ascii numbers.
  ' */
  writeByte("I")
  writeByte("P")
  writeByte("A")
  writeByte(CR)

  
PUB setMonitormodeHex
  '/**
  ' * Display values in hex format and input binary numbers.
  ' * This is the default mode after reset.
  ' */
  writeByte("I")
  writeByte("P")
  writeByte("H")
  writeByte(CR)


PUB diskPresent: YesNo
  '/**
  ' * Test if disk is present.
  ' *
  ' * @return True if disk present, false if no disk
  ' */ 
  writeByte(CR)
  YesNo := receivePromptOrError(1000)
  if responseBuffer[0] == "N"    'check for "No Disk" response
    if responseBuffer[3] == "D"
      return false
      

PUB firmwareVersion: str | countCR,i,c
  '/**
  ' * Retrieve version of current monitor firmware and reflasher code. Note that the string is stored
  ' * in a buffer that will be overwritten by the next call to a method from this object.
  ' *
  ' * @return Address of asciiz string with following format (without quotes): "MAIN dd.ddAAAAA RPRG d.ddR",0
  ' */ 
  writeByte("F")
  writeByte("W")
  writeByte("V")
  writeByte(CR)
  countCR := 0
  i := 0
  repeat
    c := readByte
    if (c <> -1)
      responseBuffer[i++] := c
      if c == CR
        countCR++
        if countCR == 2
          responseBuffer[i-1] := " "  'replace CR with space
        if countCR == 3
          responseBuffer[i-1] := 0    'make asciiz string, leaving out prompt
  until countCR == 4
  return @responseBuffer + 1          'skip initial CR


PUB echo(e): YesNo | c
  '/**
  ' * Repeat either an uppercase "E" or a lowercase "e" followed by carriage return character.
  ' * This is primarily used for synchronization purposes.
  ' *
  ' * @param e Uppercase "E" or lowercase "e"
  ' * @return True if e echoed
  ' */ 
  if (e == "e") OR (e == "E")
    writeByte(e)
    writeByte(CR)
    c := readByte    'read echo
    readByte         'read CR
    return c == e
  return false
  

PUB directory(filename,buf,num,offset): YesNo | c
  '/**
  ' * List the available files in the current directory (filename = 0)
  ' * or show the filename specified with the filesize (filesize=0 if file is directory)
  ' *
  ' * @param filename 0 if no file specified, or asciiz string holding file name in 8.3 format
  ' * @param buf Array to hold the directory listing.
  ' * @param num Number of bytes to read. This number must be smaller than the buffer size
  ' *            because this method appends a closing null. Use bufsize-1 maximum for num.
  ' *            Bufsize should be at least 19 bytes to support "FILENAME.EXT dddd",CR,0 (when filename used)
  ' *            or at least 18 bytes to support "FILENAME.EXT DIR",CR,0 (when filename not used)
  ' * @param offset Startindex in buf to write bytes to.
  ' * @return True if complete listing, false if listing is larger in which case directoryNext must be called.
  ' */
  writeByte("D")
  writeByte("I")
  writeByte("R")
  if filename <> 0
    writeByte(" ")
    writeName(filename)
  writeByte(CR)
  repeat
    c := readByte  'read initial CR
  until c == CR
  return directoryNext(buf,num,offset)


PUB directoryNext(buf,num,offset): YesNo | i,c
  '/**
  ' * Read next portion of directory listing.
  ' * This method must be called if method directory or this method returned false.
  ' *
  ' * @param buf Array to hold the directory listing.
  ' * @param num Number of bytes to read. This number must be smaller than the buffer size
  ' *            because this method appends a closing null. Use bufsize-1 maximum for num.
  ' * @param offset Startindex in buf to write bytes to.
  ' * @return True if complete listing, false if listing is larger in which case this method must be called again.
  ' */
  i := 0
  repeat while num > 0
    c := readByte
    if (c <> -1)
      byte[buf+offset+i] := c
      i++
      num--
      if (c == CR)
        if isPrompt(buf+offset+i-5)    'in case CR is the CR following the prompt 
          byte[buf+offset+i-5] := 0    'make asciiz string, leaving out prompt
          return true
        if num < 17  'not enough space in buffer for another line: FILENAME.EXT DIR,CR
          quit
  byte[buf+offset+i] := 0 'closing zero
  return false


PRI cdRoot: YesNo | i,c
  '/**
  ' * Change directory to rootdirectory.
  ' */
  repeat
    writeByte("C")
    writeByte("D")
    writeByte(" ")
    writeByte(".")
    writeByte(".")
    writeByte(CR)
    i := 0
    repeat
      c := readByte
      if c <> -1
        responseBuffer[i++] := c
    until c == CR
    responseBuffer[i] := 0
  until strsize(@responseBuffer) <> 5 'no prompt+CR D:\>{0D} but Command failed (because we are already in root)    
  return true
  

PUB changeDirectory(dirname): YesNo | i,c
  '/**
  ' * Change directory.
  ' *
  ' * @param dirname Asciiz string with name of the directory in 8.3 format
  ' *        use ".." to move a higher directory, use "\" to move to the rootdirectory
  ' * @return True if command succesful.
  ' */
  if byte[dirname] == "\"
    return cdRoot
  else
    writeByte("C")
    writeByte("D")
    writeByte(" ")
    writeName(dirname)
    writeByte(CR)
    return receivePromptOrError(1000)
  

PUB deleteDirectory(dirname): YesNo | i,c
  '/**
  ' * Delete directory.
  ' *
  ' * @param dirname Asciiz string with name of the directory in 8.3 format.
  ' *        The directory must be empty or the command will fail.
  ' * @return True if command succesful.
  ' */
  writeByte("D")
  writeByte("L")
  writeByte("D")
  writeByte(" ")
  writeName(dirname)
  writeByte(CR)
  return receivePromptOrError(1000)


PUB makeDirectory(dirname,datetime): YesNo | i
  '/**
  ' * Make directory.
  ' *
  ' * @param dirname Asciiz string with name of the directory in 8.3 format.
  ' *        The directory must not already exist.
  ' * @param datetime Optional date and time stamp, 32bit value: use 0 if not required
  ' *        25:31  year      0-127 0=1980 127=2107
  ' *        21:24  month     1-12  1=january 12=december
  ' *        16:20  day       1-31  1=first day of month
  ' *        11:15  hour      0-23  24 hour clock
  ' *         5:10  minute    0-59
  ' *         0:4   seconds/2 0-29  0=0 seconds 29=58 seconds
  ' * @return True if command succesful.
  ' */
  writeByte("M")
  writeByte("K")
  writeByte("D")
  writeByte(" ")
  writeName(dirname)
  if datetime <> 0
    writeByte(" ")
    writeByte(datetime.byte[3])
    writeByte(datetime.byte[2])
    writeByte(datetime.byte[1])
    writeByte(datetime.byte[0])
  writeByte(CR)
  return receivePromptOrError(1000)


PUB deleteFile(filename): YesNo
  '/**
  ' * Delete file.
  ' *
  ' * @param filename Asciiz string with name of the file in 8.3 format.
  ' *        The file must exist and must not be opened.
  ' * @return True if command succesful.
  ' */
  writeByte("D")
  writeByte("L")
  writeByte("F")
  writeByte(" ")
  writeName(filename)
  writeByte(CR)
  return receivePromptOrError(1000)
  

PUB closeFile(filename): YesNo
  '/**
  ' * Close file.
  ' *
  ' * @param filename Asciiz string with name of the file in 8.3 format.
  ' *        The file must be opened.
  ' * @return True if command succesful.
  ' */
  writeByte("C")
  writeByte("L")
  writeByte("F")
  writeByte(" ")
  writeName(filename)
  writeByte(CR)
  return receivePromptOrError(1000)
  

PUB openFileForRead(filename,datetime): YesNo
  '/**
  ' * Open file for read.
  ' *
  ' * @param filename Asciiz string with name of the file in 8.3 format.
  ' *        The file must exist and no other file must be opened.
  ' * @param datetime Optional date and time stamp, 32bit value: use 0 if not required
  ' *        25:31  year      0-127 0=1980 127=2107
  ' *        21:24  month     1-12  1=january 12=december
  ' *        16:20  day       1-31  1=first day of month
  ' *        11:15  hour      not used
  ' *         5:10  minute    not used
  ' *         0:4   seconds/2 not used
  ' * @return True if command succesful.
  ' */
  writeByte("O")
  writeByte("P")
  writeByte("R")
  writeByte(" ")
  writeName(filename)
  if datetime <> 0
    writeByte(" ")
    writebyte(datetime.byte[3])
    writeByte(datetime.byte[2])
  writeByte(CR)
  return receivePromptOrError(1000)
  

PUB openFileForWrite(filename,datetime): YesNo
  '/**
  ' * Open file for write.
  ' *
  ' * @param filename Asciiz string with name of the file in 8.3 format.
  ' *        If the file does not exist it is created. No other file must be opened.
  ' *        If the file exists, data is appended to the end of the file.
  ' * @param datetime Optional date and time stamp, 32bit value: use 0 if not required
  ' *        25:31  year      0-127 0=1980 127=2107
  ' *        21:24  month     1-12  1=january 12=december
  ' *        16:20  day       1-31  1=first day of month
  ' *        11:15  hour      0-23  24 hour clock
  ' *         5:10  minute    0-59
  ' *         0:4   seconds/2 0-29  0=0 seconds 29=58 seconds
  ' * @return True if command succesful.
  ' */
  writeByte("O")
  writeByte("P")
  writeByte("W")
  writeByte(" ")
  writename(filename)
  if datetime <> 0
    writeByte(" ")
    writebyte(datetime.byte[3])
    writeByte(datetime.byte[2])
    writebyte(datetime.byte[1])
    writeByte(datetime.byte[0])
  writeByte(CR)
  return receivePromptOrError(1000)
  

PUB readFromFile(buf,num,offset): YesNo | c
  '/**
  ' * Read bytes from file opened for read.
  ' *
  ' * @param buf Array to hold the read bytes.
  ' * @param num Number of bytes to read. Must not exceed the number of remaining bytes in the file.
  ' *            Call method filesize prior to opening the file and adjust num so it will not read beyond EOF.
  ' * @param offset Startindex in buf to write bytes to.
  ' * @return True if command succesful.
  ' */
  writeByte("R")
  writeByte("D")
  writeByte("F")
  writeByte(" ")
  writeByte(num.byte[3])
  writeByte(num.byte[2])
  writeByte(num.byte[1])
  writeByte(num.byte[0])
  writeByte(CR)
  repeat while num > 0
    c := readByte
    if c <> -1
      byte[buf+offset] := c
      offset++
      num--
  return receivePromptOrError(1000)
  

PUB writeToFile(buf,num,offset): YesNo
  '/**
  ' * Write bytes to file opened for write.
  ' *
  ' * @param buf Array holding the bytes to write.
  ' * @param num Number of bytes to write. Make sure the number is valid or it may lead to disk full.
  ' * @param offset Startindex in buf to read bytes from.
  ' * @return True if command succesful.
  ' */
  writeByte("W")
  writeByte("R")
  writeByte("F")
  writeByte(" ")
  writeByte(num.byte[3])
  writeByte(num.byte[2])
  writeByte(num.byte[1])
  writeByte(num.byte[0])
  writeByte(CR)
  repeat while num-- > 0
    writeByte(byte[buf+offset])
    offset++
  return receivePromptOrError(1000)
  

PUB readFile(filename,buf,num,offset): YesNo | c,size
  '/**
  ' * Read all bytes from file.
  ' * No file must be opened. This method limits the number of bytes read if filesize < num.
  ' *
  ' * @param filename Asciiz string with name of the file in 8.3 format.
  ' *        The file must exist and no file must be opened.
  ' * @param buf Array to hold the read bytes.
  ' * @param num Number of bytes to read. This number is limited to the filesize if filesize < num.
  ' * @param offset Startindex in buf to write bytes to.
  ' * @return True if command succesful.
  ' */
  size := filesize(filename)
  if size < num
    num := size
  if num > 0
    writeByte("R")
    writeByte("D")
    writeByte(" ")
    writeName(filename)
    writeByte(CR)
    repeat while num > 0
      c := readByte
      if c <> -1
        byte[buf+offset] := c
        offset++
        num--
    return receivePromptOrError(1000)
  return true
  

PUB filesize(filename): size | i
  '/**
  ' * Retrieve file size.
  ' * No file must be opened.
  ' *
  ' * @param filename Asciiz string with name of the file in 8.3 format.
  ' *        The file must exist and no file must be opened.
  ' * @return Filesize in bytes.
  ' */
  directory(filename,@responseBuffer,BUFSIZE-1,0)
  i := 0
  repeat while responseBuffer[i] <> " "
    i++
  i++
  size.byte[0] := responseBuffer[i++]  
  size.byte[1] := responseBuffer[i++]  
  size.byte[2] := responseBuffer[i++]  
  size.byte[3] := responseBuffer[i]  
  receivePromptOrError(1000)
  return size
  

PUB renameFile(oldname,newname): YesNo
  '/**
  ' * Rename file or directory.
  ' *
  ' * @param oldname Asciiz string with current name of the file or directory in 8.3 format.
  ' *        The file must be closed.
  ' * @param newname Asciiz string with new name of the file or directory in 8.3 format.
  ' * @return True if command succesful.
  ' */
  writeByte("R")
  writeByte("E")
  writeByte("N")
  writeByte(" ")
  writeName(oldname)
  writeByte(" ")
  writeName(newname)
  writeByte(CR)
  return receivePromptOrError(1000)
  

PUB seek(offset): YesNo
  '/**
  ' * Seek to position in open file
  ' *
  ' * @param offset Position to seek to. Position is only valid from 0 to filesize.
  ' * @return True if command succesful.
  ' */
  writeByte("S")
  writeByte("E")
  writeByte("K")
  writeByte(" ")
  writeByte(offset.byte[3])
  writeByte(offset.byte[2])
  writeByte(offset.byte[1])
  writeByte(offset.byte[0])
  writeByte(CR)
  return receivePromptOrError(1000)
  

PUB diskFreeSpace(power2): free | i
  '/**
  ' * Retrieve the freespace remaining on the disk.
  ' *
  ' * @param power2 To scale reported size: 0=bytes, 10=kilobytes, 20=megabytes
  ' * @return Scaled freespace, -1 if freespace can not be represented by 32bits for given power2 value.
  ' */ 
  writeByte("F")
  writeByte("S")
  writeByte("E")
  writeByte(CR)
  receiveTwoCR
  'at this point responseBuffer[0] to responseBuffer[5] is filled, responseBuffer[0] is LSB
  repeat power2/10
    bytemove(@responseBuffer,@responseBuffer+1,5)
    responseBuffer[5] := 0
    repeat i from 0 to 4
      responseBuffer[i] := (responseBuffer[i] >> 2) | (responseBuffer[i+1] << 6)  'shift 2bits
    power2 -= 10
  if (responseBuffer[4] <> 0) OR (responseBuffer[5] <> 0) 'size cannot be represented by 32bits
    return -1
  free.byte[0] := responseBuffer[0]
  free.byte[1] := responseBuffer[1]
  free.byte[2] := responseBuffer[2]
  free.byte[3] := responseBuffer[3]
  return free


PUB diskIdentify(buf,num,offset): YesNo | countCR,i,c
  '/**
  ' * Retrieve summary of information about the disk.
  ' *
  ' * @param buf Array to hold the disk info.
  ' * @param num Number of bytes to read. This number must be smaller than the buffer size
  ' *            because this method appends a closing null. Use bufsize-1 maximum for num.
  ' *            Bufsize should be at least 256 bytes to hold all the info.
  ' * @param offset Startindex in buf to write bytes to.
  ' * @return True if full info, false if info truncated.
  ' */ 
  writeByte("I")
  writeByte("D")
  writeByte("D")
  writeByte("E")
  writeByte(CR)
  countCR := 0
  i := 0
  repeat while num > 0 
    c := readByte
    if (c <> -1)
      byte[buf+offset+i] := c
      i++
      num--
      if c == CR
        countCR++
        if countCR == 12
          byte[buf+offset+i-1] := 0    'make asciiz string, leaving out prompt
        if countCR == 14
          return true
  byte[buf+offset+i] := 0              'make asciiz string, failsafe
  return false


PUB diskVolumeLabel: label
  '/**
  ' * Retrieve the volume label from the disk.
  ' *
  ' * @return Address of asciiz string holding the volume label.
  ' */ 
  writeByte("D")
  writeByte("V")
  writeByte("L")
  writeByte(CR)
  receiveTwoCR
  return @responseBuffer


PUB diskSerialNumber: serial
  '/**
  ' * Retrieve 32bit serial number of the disk.
  ' *
  ' * @return 32bit serial number.
  ' */ 
  writeByte("D")
  writeByte("S")
  writeByte("N")
  writeByte(CR)
  receiveTwoCR
  serial.byte[0] := responseBuffer[0]
  serial.byte[1] := responseBuffer[1]
  serial.byte[2] := responseBuffer[2]
  serial.byte[3] := responseBuffer[3]
  return serial


PRI receiveTwoCR | countCR,i,c
  '/**
  ' * Receive from datalogger until two CR are received.
  ' * The received bytes are stored in responseBuffer.
  ' */
  countCR := 0
  i := 0
  repeat
    c := readByte
    if (c <> -1)
      responseBuffer[i++] := c
      if c == CR
        countCR++
        if countCR == 1
          responseBuffer[i-1] := 0    'make asciiz string, leaving out prompt
  until countCR == 2


PUB diskSuspend: YesNo
  '/**
  ' * Enable the automatic suspend mode that suspends the disk when not in use.
  ' * Disable the mode by calling diskWakeup.
  ' */
  writeByte("S")
  writeByte("U")
  writeByte("D")
  writeByte(CR)
  return receivePromptOrError(1000)
  
    
PUB diskWakeup
  '/**
  ' * Turn off the automatic suspended mode which is enabled by the diskSuspend command.
  ' * It should be called before transferring large amounts of data to or from disk.
  ' */ 
  writeByte("W")
  writeByte("K")
  writeByte("D")
  writeByte(CR)


PUB monitorSuspend
  '/**
  ' * Suspend monitor. To wake the monitor up again, pin RI# must be toggled.
  ' * A simple way to resume the Monitor when any input is sent to the device would be to tie Ring Indicator (RI#)
  ' * and the UART receive data (RXD) pins together.
  ' */ 
  writeByte("S")
  writeByte("U")
  writeByte("M")
  writeByte(CR)


PRI writeName(name)    
  '/**
  ' * write name to Vinculum.
  ' *
  ' * @param name Asciiz string with name in 8.3 format.
  ' */
  repeat while byte[name] <> 0
    writeByte(byte[name++])

    
PUB writeByte(value): YesNo
  '/**
  ' * write byte to Vinculum.
  ' *
  ' * @param value Byte to write.
  ' * @return True if byte send succesfully.
  ' */
  YesNo := (transfer(false,false,value) & 1) == 0


PUB readByte: val | t
  '/**
  ' * read byte from Vinculum.
  ' *
  ' * @return Byte read ($00-$FF) or -1.
  ' */
  if ((t := transfer(true,false,0)) & 1) == 0 'statusbit is 0 when new data
    return (t >> 1) & $FF  'new data read from Vinculum
  else
    return -1  'no data

    
PRI isPrompt(str): YesNo
  '/**
  ' * Check if string is prompt.
  ' *
  ' * str Address of string that might be prompt "D:\>",13
  ' */
  if byte[str++] == "D"
    if byte[str++] == ":"
      if byte[str++] == "\"
        if byte[str++] == ">"
          if byte[str] == CR
            return true
  return false
  

PUB receivePromptOrError(ms): YesNo | i,c,t
  '/**
  ' * Receive prompt (D:\>) or error. Times out in ms milliseconds second.
  ' *
  ' * @param ms Number of milliseconds in which this method times out.
  ' * @return True if prompt received.
  ' */
  i := 0
  t := cnt
  repeat
    c := readByte
    if c <> -1
      responseBuffer[i++] := c
  until (c == CR) OR (((cnt - t) / (clkfreq / 1000)) > ms)
  responseBuffer[i] := 0
  if strsize(@responseBuffer) == 5 'prompt+CR D:\>{0D}    
    return isPrompt(@responseBuffer)
  return false
    

PRI transfer(read,status,data): val | i,mask  '
  '/**
  ' * Transfer data to/from Vinculum USB Host in SPI mode, using seperate data in and data out pin 
  ' *
  ' * @param read True for read, false for write.
  ' * @pram status False to access command register, true to access status register.
  ' * @param data If write, byte to write. If read, not used.
  ' * @return 9bit value, bit0 is 0 if byte written succesfully or new data read
  ' *         If read, b8-b1 is byte read
  ' */
'' For read, send 110, then read 8 bits (MSB first), read statusbit (total 12 clockpulses)
'' For write, send 100, then write 8 bits (MSB first), read statusbit (total 12 clockpulses)
  val := 0
  data := $800 | ($400 & read) | ($200 & status) | (data << 1)
  mask := $800
  outa[SPI_CLK]~~                 ' At least one clock prior to selecting
  outa[SPI_CLK]~
  outa[SPI_CS]~~                  ' Select chip
  repeat i from 1 to 12           ' Start, direction, address, 8 data, status
    outa[SPI_SDO] := (data & mask) > 0
    val |= (mask & (ina[SPI_SDI] > 0))
    outa[SPI_CLK]~~               ' Data valid on positive edge of clock
    outa[SPI_CLK]~
    mask >>= 1
  outa[SPI_CS]~                   ' Deselect chip
  outa[SPI_CLK]~~                 ' At least one clock after deselecting
  outa[SPI_CLK]~
  return val
  
