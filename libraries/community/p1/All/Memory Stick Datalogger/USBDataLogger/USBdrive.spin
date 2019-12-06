'' ***************************************
'' *  Parallax USB Datalogger V1.0       *
'' ***************************************
''
'' http://www.parallax.com/detail.asp?product_id=27937
''
'' Created September 26, 2007
'' Written by Paul Deffenbaugh
'' Program Revision v1.0

CON
  LF            = 10
  CR            = 13
  
OBJ
  
  USB           : "FullDuplexSerial"
'  LCD           : "lcd_ezdisplay"  

PUB start(tx_USB,rts_USB,rx_USB,cts_USB) | ioByte, i, started     
  if USB.start(rx_USB, tx_USB, 0, 9600) ' TX/RX, pins, true mode

    dira[rts_USB]~~               ' ~~ Set I/O pin to output direction 
    outa[rts_USB] :=0             ' LOW  ' RTS Take Vinculum Out Of Reset 

    'Drive
    '  Detected P2
    '  No Upgrade
    '  D:\>
    'No Drive
    '  On-Line:

'    LCD.cls
'    LCD.debug(string("Start:"))

    getSerialBytes
    
'    LCD.str(string("E :"))   
    USB.rxflush      
    repeat 
      USB.str(string("E",CR))   ' SEROUT TX\CTS, Baud, ["E", CR]  ' Sync Command Character
      ioByte := USB.rxtime(1000)' GOSUB Get_Data ' Get Response
'      LCD.putB(ioByte)
    until (ioByte == "E" OR ioByte == -1)
'    LCD.crlf(LHS)
    if ioByte == "E"
'      LCD.str(string("e :"))   
      USB.rxflush                                                
      repeat
        USB.str(string("e",CR))   ' SEROUT TX\CTS, Baud, ["e", CR]  ' Sync Command Character  
        ioByte := USB.rxtime(1000)' GOSUB Get_Data ' Get Response
'        LCD.putB(ioByte)          ' Wait for e[cr]D:\>[cr]
      until (ioByte == "e" OR ioByte == -1)
'      LCD.crlf(LHS)
      waitcnt(clkfreq/10 + cnt)   '100ms

      if ioByte == "e"
'        LCD.str(string("CR:"))      ' DEBUG "Checking for USB Flash drive...", CR
        USB.rxflush
        USB.tx(CR)                  ' Send CR to see if drive is present
        ioByte := USB.rxtime(1000)
'        LCD.putb(ioByte)
'        LCD.crlf(LHS)  
  
        if ioByte == "D"
          started := 0          'SUCCESS (0=false)
        elseif ioByte == "N"
          started := -6         'LCD.debug(string("No Disk"))  
        else
          started := -5         'LCD.debug(string("USB Failed: cr")) 
      else
        started := -4           'LCD.debug(string("USB Failed: e"))  
    else
      started := -3             'LCD.debug(string("USB Failed: E" ))
  else
    started := -1               'LCD.debug(string("USB Failed: Cog")) 
  return started

'-------------File Functions------------      
PUB OpenForWrite(filename)     ' Open file for output (write)
  USB.rxflush        
  USB.str(string("OPW "))       ' SEROUT TX\CTS, Baud, ["OPW seedfile.txt", CR]
  USB.str(filename)
  USB.tx(CR)
  return WaitForCR

PUB OpenForRead(fileName)    ' Open file for input (read)   
  USB.rxflush        
  USB.str(string("OPR "))    
  USB.str(fileName)
  USB.tx(CR)
  return WaitForCR

PUB Close(filename)         ' Close file
  USB.rxflush        
  USB.str(string("CLF "))     
  USB.str(filename)
  USB.tx(CR)       
  return WaitForCR

PUB DeleteFile(fileName)           ' Delete, if one exists, ignore error if no file exists
'This will delete the file from the current directory and free up the FAT sectors.
  USB.rxflush        
  USB.str(string("DLF "))    
  USB.str(fileName)
  USB.tx(CR)
  return WaitForCR

'---------------Read/Write------------------  
PUB WriteLine(fileData)         ' Write data to file (file must be preopened) followed by CRLF
  USB.rxflush        
  USB.str(string("WRF "))       ' ["WRF ", $00, $00, $00, $05, CR, DEC5 result, CR]
  USB.tx($00)
  USB.tx($00)
  USB.tx($00)
  USB.tx(strsize(fileData)+2)
  USB.tx(CR)
  USB.str(fileData)
  USB.tx(CR)
  USB.tx(LF)
  USB.tx(CR)  
  return WaitForCR

PUB Write(fileData)         ' Write data to file (file must be preopened)
  USB.rxflush        
  USB.str(string("WRF "))     
  USB.tx($00)
  USB.tx($00)
  USB.tx($00)
  USB.tx(strsize(fileData))
  USB.tx(CR)
  USB.str(fileData)
  USB.tx(CR)
  return WaitForCR

PUB Read(readLength,stringptr) | i    ' Read data from file (file must be preopened)
'This will send back the requested amount of data to the monitor.
  USB.rxflush
  USB.str(string("RDF ")) 
  USB.tx((readLength>>24) & $FF)
  USB.tx((readLength>>16) & $FF)
  USB.tx((readLength>> 8) & $FF)
  USB.tx( readLength      & $FF)
  USB.tx(CR)
  repeat i from 0 to readLength-1
    byte[stringptr++] := USB.rx

PUB ReadFile(fileName,fileSize,stringptr) | i    ' Read entire file
  USB.rxflush
  USB.str(string("RD "))
  USB.str(filename)
  USB.tx(CR)

  repeat i from 0 to fileSize
    byte[stringptr++] := USB.rx    

PUB Seek(fileptr)   
  USB.rxflush 
  USB.str(string("SEK "))
  USB.tx((fileptr>>24) & $FF)
  USB.tx((fileptr>>16) & $FF)
  USB.tx((fileptr>> 8) & $FF)
  USB.tx( fileptr      & $FF)
  USB.tx(CR)
  return WaitForCR    

'-------------Directory Functions------------------
PUB MakeDir(dirName)            ' Create folder and ignore error if folder exists    
  USB.rxflush 
  USB.str(string("MKD "))    
  USB.str(dirName)
  USB.tx(CR)
  return WaitForCR

PUB CD(dirName)            ' Create folder and ignore error if folder exists    
  USB.rxflush 
  USB.str(string("CD "))    
  USB.str(dirName)
  USB.tx(CR)
  return WaitForCR

PUB CDup(dirName)               ' Change directory, move up one level   
  USB.rxflush 
  USB.str(string("CD ..",CR))
  return WaitForCR  

PUB DLD(dirName)                ' Delete directory
  USB.rxflush 
  USB.str(string("DLD "))    
  USB.str(dirName)
  USB.tx(CR)
  return WaitForCR
  
PUB getSize(fileName) : size | ioByte ' Lists the file name followed by the size.
  USB.rxflush 
  USB.str(string("DIR "))       ' Use this before doing a file read  
  USB.str(fileName)                 '   to know how many bytes to expect.
  USB.tx(CR)
  WaitForCR                 

  if USB.rx <> "C"
    if waitForSpace
      size := 0   
      ioByte := USB.rx
      size += ioByte << 0
      ioByte := USB.rx
      size += ioByte << 8
      ioByte := USB.rx
      size += ioByte << 16
      ioByte := USB.rx
      size += ioByte << 24
      return size
  return 0

'---------File System-------------      
PUB Rename(oldName,newName)     ' Rename file or directory        
  USB.rxflush 
  USB.str(string("REN "))
  USB.str(oldName)
  USB.tx(" ")
  USB.str(newName)
  USB.tx(CR)
  return WaitForCR

PUB FreeSpace4 : size | ioByte  ' Display free space (four bytes, max 4 GB/giga bytes)
'Returns free space in bytes on disk.
'For disks of over 4 GBytes in size this will return $FFFFFFFF
'If more than 4 GByte available. Otherwise use "FSE"/FreeSpace6 command/function

  USB.rxflush 
  USB.str(string("FS "))
  USB.tx(CR)

  size := 0   
  ioByte := USB.rx
  size += ioByte << 0
  ioByte := USB.rx
  size += ioByte << 8
  ioByte := USB.rx
  size += ioByte << 16
  ioByte := USB.rx
  size += ioByte << 24
  return size

'PUB FreeSpace6                   ' Display free space (six bytes, max 281 TB/tera bytes)
'<free space in hex(6 bytes) LSB first> $0D
'  USB.rxflush 
'  USB.str(string("FSE "))
'  USB.tx(CR)
'  return WaitForCR
      
'---------Power Save-------------  
PUB Sleep                       ' USB Suspend Mode (Power Saving Mode)  
  USB.rxflush 
  USB.str(string("SUD", CR))  
  return WaitForCR
   
PUB Wake                       ' Wake Drive (Full Power) 
  USB.rxflush 
  USB.str(string("WKD", CR))   
  return WaitForCR

PUB powerDown
  USB.rxflush
  USB.str(string("SUM", CR))
  return WaitForCR

PUB setBaudRate(divisor)        'Set Baud Rate (See Baud Rate Table)           
  USB.rxflush             
  USB.str(string("SBD "))        
  USB.tx((divisor    ) & $FF)   '(3 bytes) LSB first  
  USB.tx((divisor>> 8) & $FF)
  USB.tx((divisor>>16) & $FF)
  USB.tx(CR)
  return WaitForCR    
  
'-----------Private Functions------------
PRI GetSerialBytes | ioByte
  repeat until ioByte == -1
    ioByte := USB.rxtime(3000)
'    LCD.putb(ioByte)           ' Opetionally display bytes as they come in
'  LCD.CRLF(LHS)

PRI WaitForCR | ioByte
  repeat
    ioByte := USB.rxtime(3000)
  until ioByte == CR OR ioByte == -1
 
  if ioByte == CR
    return True
  else
    return False

PRI waitForSpace | ioByte
  repeat
    ioByte := USB.rxtime(3000)
  until ioByte == " " OR ioByte == -1
 
  if ioByte == " "
    return True
  else
    return False    