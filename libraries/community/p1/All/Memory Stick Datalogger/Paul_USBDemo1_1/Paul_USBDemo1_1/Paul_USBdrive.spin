'' IO PINS
''
''  txUSB   = 10    ' Transmit Data   --> 27937.4 (RXD) white     
''  rxUSB   = 11    ' Receive Data    <-- 27937.5 (TXD) green
''
''  rtsUSB  = 17    ' Request To Send --> 27937.6 (CTS) white low to enable datalogger
''  ctsUSB  = 19    ' Clear To Send   <-- 27937.2 (RTS) blue  always low
''                                        27937.1 (GND)
''                                        27937.3 (+5V)
''                                        27937.7 (N/C)
''                                        27937.8 (N/C)

CON

  _clkmode  = xtal1 + pll16x                            ' use crystal x 16
  _xinfreq  = 5_000_000
  clk_freq   = 80_000_000
  
CON
  LF            = 10
  CR            = 13

CON
  txLCD   = 2     ' Green TX to LCD (LCD RX)       
  rxLCD   = 3     ' White RX from LCD (LCD TX)
  
  rxUSB   = 10    ' Receive Data    <-- 27937.5 (TXD) white
  txUSB   = 11    ' Transmit Data   --> 27937.4 (RXD) green
    
OBJ
  
  USB           : "FullDuplexSerial"

OBJ
'  LCD           : "Paul_SX4x40LCD"   
  std           : "Paul_StandardLibrary"       ' Paul's Standard Library     

VAR
  long initErrorCode
  long errorCode

{  
PUB main | i
'------------------ Propeller Startup ------------------------
  std.pause(500) 

'------------------ COM 1 LCD Display ------------------------   
  LCD.start(rxLCD, txLCD)
  LCD.tx(24)
  std.pause(1000)
  LCD.tx(12)  ' clear screen
  std.pause(10)

'---------------- COM 9 USB Drive ---------------------
  start(txUSB,rxUSB)                   ' start USB drive

' if (not (getErrorCode))

'  repeat
  
   
    LCD.pos16(0)
    LCD.dec(getErrorCode)
    LCD.tx(":")
    LCD.str(getErrorMessage)     


  if not getErrorCode
    
    OpenForWrite(string("Paul.txt"))
    Write(string("Hello World!"))
    Close(string("Paul.txt"))
    
    LCD.pos16(1)
    LCD.str(string("Free space: "))
    LCD.dec(FreeSpace4/1_000_000)
    LCD.str(string("MB"))
    LCD.tx(" ")
    LCD.dec(FreeSpace4/1_000)
    LCD.str(string("kB"))  
    
    LCD.pos16(2)
    LCD.str(string("File size: "))
    LCD.dec(filesize(string("Paul.txt")))
    LCD.str(string(" bytes"))
    
    
'    OpenForWrite(string("Big.txt"))
'    '2400 bytes
'    Write(string("0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     0123456789     "))
'    Close(string("Big.txt"))
   
'    LCD.pos16(3)
'    LCD.str(string("File size: "))
'    LCD.dec(filesize(string("Big.txt")))
'    LCD.str(string(" bytes"))
    
    LCD.pos16(12)
    LCD.str(string("Closed."))
    std.pause(500)
    LCD.pos16(12)
    LCD.str(string("       "))
  else
    LCD.pos16(2)
    LCD.str(string("done."))

  repeat
}

PUB start(tx_USB,rx_USB) | ioByte, i     
  if USB.start(rx_USB, tx_USB, 0, 9600) ' TX/RX, pins, true mode
'    dira[rts_USB]~~               ' ~~ Set I/O pin to output direction 
'    outa[rts_USB] :=0             ' LOW  ' RTS Take Vinculum Out Of Reset 

    'Drive
    '  Detected P2
    '  No Upgrade
    '  D:\>
    'No Drive
    '  On-Line:

'    repeat
'      ioByte := USB.rxtime(4000)
'      if ioByte == -1
'        LCD.str(string("_"))
'      else
'        LCD.tx(ioByte)
'    until ioByte == 13
'
'    LCD.pos16(12)
'    LCD.str(string("Done."))
'
'    std.pause(1000)

    repeat
      ioByte := USB.rxtime(4000)
    until (ioByte == -1)

    bigEsync
    if errorCode == 0
      smallEsync
      if errorCode == 0
        getErrorCode
  else
    errorCode := -1                ' failed to get cog
  initErrorCode := errorCode
  return errorCode

PUB checkErrorCode | ioByte 
  USB.rxflush
  USB.tx(CR)                ' Send CR to see if drive is present
  ioByte := USB.rxtime(100)
  if ioByte == "D"
    errorCode := 0          ' Success (0=false, -1=true)
    repeat                  ' Send/Get <cr>     
      ioByte:= USB.rxtime(100)
    until (ioByte == 13 OR ioByte == -1)
    if ioByte == 13
      errorCode := 0
    else
      errorCode := -10      ' failed cr #4
  elseif ioByte == "N"
    errorCode := -9         ' No Flash Drive  
  else
    errorCode := -8         ' failed cr #3
  return errorCode

PUB getErrorCode | ioByte
  return errorCode

PUB bigEsync | ioByte
  USB.rxflush
  repeat                                              ' Send/Get E
    USB.str(string("E",CR))  
    ioByte := USB.rxtime(1000)
  until (ioByte == "E" OR ioByte == -1)
  if ioByte == "E"
    repeat                                            ' Send/Get <cr>     
      ioByte:= USB.rxtime(500)
    until (ioByte == 13 OR ioByte == -1)
    if ioByte == 13
      errorCode := 0               ' no error
    else
      errorCode := -4            ' failed cr #1
  elseif ioByte == -1
    errorCode := -3              ' tout E
  else
    errorCode := -2              ' fail E      

PUB smallEsync | ioByte
  USB.rxflush
  repeat                                          ' Send/Get e
    USB.str(string("e",CR))  
    ioByte := USB.rxtime(500)                     ' e[cr]D:\>[cr]
  until (ioByte == "e" OR ioByte == -1)
  if ioByte == "e"
    repeat                                        ' Send/Get <cr>     
      ioByte:= USB.rxtime(500)
    until (ioByte == 13 OR ioByte == -1)
    if ioByte == 13
      errorCode := 0          ' no error
    else
      errorCode := -7         ' failed cr #2                    
  elseif ioByte == -1
    errorCode := -6           ' tout e 
  else
    errorCode := -5           ' fail e
    
PUB getErrorMessage : errorMessage
  case errorCode
     0: errorMessage := @ErrorMsgNoError
    -1: errorMessage := @ErrorMsgCog      
    -2: errorMessage := @ErrorMsgFailBigE
    -3: errorMessage := @ErrorMsgtoutBigE
    -4: errorMessage := @ErrorMsgFailCR1
    -5: errorMessage := @ErrorMsgFailSmE   
    -6: errorMessage := @ErrorMsgtoutSmE
    -7: errorMessage := @ErrorMsgFailCR2
    -8: errorMessage := @ErrorMsgFailCR3
    -9: errorMessage := @ErrorMsgNoFlash
    -10: errorMessage := @ErrorMsgFailCR4
    other: errorMessage := @ErrorMsgUndefined

'-------------File Functions------------      
PUB OpenForWrite(filename)     ' Open file for output (write)
  USB.rxflush        
  USB.str(string("OPW "))       ' SEROUT TX\CTS, Baud, ["OPW seedfile.txt", CR]
  USB.str(filename)
  USB.tx(CR)
  WaitForCR

PUB OpenForRead(fileName)    ' Open file for input (read)   
  USB.rxflush        
  USB.str(string("OPR "))    
  USB.str(fileName)
  USB.tx(CR)
  WaitForCR

PUB Close(filename)         ' Close file
  USB.rxflush        
  USB.str(string("CLF "))     
  USB.str(filename)
  USB.tx(CR)       
  WaitForCR
  WaitForCR

PUB DeleteFile(fileName)           ' Delete, if one exists, ignore error if no file exists
'This will delete the file from the current directory and free up the FAT sectors.
  USB.rxflush        
  USB.str(string("DLF "))    
  USB.str(fileName)
  USB.tx(CR)
  WaitForCR

'---------------Read/Write------------------  
PUB Write(fileData) | length         ' Write data to file (file must be preopened)
  length := strsize(fileData)
  USB.rxflush        
  USB.str(string("WRF "))     
  USB.tx((length>>24) & $FF)
  USB.tx((length>>16) & $FF)
  USB.tx((length>> 8) & $FF)
  USB.tx( length      & $FF)
  USB.tx(CR)
  USB.str(fileData)
  USB.tx(CR)
  WaitForCR
'  WaitForCR


PUB WriteLine(fileData) | length         ' Write data to file (file must be preopened) followed by CRLF
  length := strsize(fileData) + 2
  USB.rxflush        
  USB.str(string("WRF "))     
  USB.tx((length>>24) & $FF)
  USB.tx((length>>16) & $FF)
  USB.tx((length>> 8) & $FF)
  USB.tx( length      & $FF)
  USB.tx(CR)
  USB.str(fileData)
  USB.tx(CR)
  USB.tx(LF)
  USB.tx(CR)
  WaitForCR
'  WaitForCR


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
  byte[stringptr] := 0            ' added    

PUB ReadFile(fileName,bytes,stringptr) | i    ' Read entire file
  USB.rxflush
  USB.str(string("RD "))
  USB.str(filename)
  USB.tx(CR)

  repeat i from 0 to bytes
    byte[stringptr++] := USB.rx
  byte[stringptr] := 0            ' added 

PUB Seek(fileptr)   
  USB.rxflush 
  USB.str(string("SEK "))
  USB.tx((fileptr>>24) & $FF)
  USB.tx((fileptr>>16) & $FF)
  USB.tx((fileptr>> 8) & $FF)
  USB.tx( fileptr      & $FF)
  USB.tx(CR)
  WaitForCR    

'-------------Directory Functions------------------
PUB MakeDir(dirName)            ' Create folder and ignore error if folder exists    
  USB.rxflush 
  USB.str(string("MKD "))    
  USB.str(dirName)
  USB.tx(CR)
  WaitForCR

PUB CD(dirName)            ' Create folder and ignore error if folder exists    
  USB.rxflush 
  USB.str(string("CD "))    
  USB.str(dirName)
  USB.tx(CR)
  WaitForCR

PUB CDup(dirName)               ' Change directory, move up one level   
  USB.rxflush 
  USB.str(string("CD ..",CR))
  WaitForCR  

PUB DLD(dirName)                ' Delete directory
  USB.rxflush 
  USB.str(string("DLD "))    
  USB.str(dirName)
  USB.tx(CR)
  WaitForCR
  
PUB filesize(fileName) : bytes ' Lists the file name followed by the size.

  USB.rxflush 
  USB.str(string("DIR "))       ' Use this before doing a file read  
  USB.str(fileName)                 '   to know how many bytes to expect.
  USB.tx(CR)
  WaitForCR                 
  WaitForSpace      ' Skips file name
  bytes := USB.rx
  bytes |= USB.rx << 8
  bytes |= USB.rx << 16
  bytes |= USB.rx << 24
  WaitForCR
  WaitForCR
  


'---------File System-------------      
PUB Rename(oldName,newName)     ' Rename file or directory        
  USB.rxflush 
  USB.str(string("REN "))
  USB.str(oldName)
  USB.tx(" ")
  USB.str(newName)
  USB.tx(CR)
  WaitForCR

PUB FreeSpace4 : bytes  ' Display free space (four bytes, max 4 GB/giga bytes)
' Returns free space in bytes on disk.
' For disks of over 4 GBytes in size this will return $FFFFFFFF
' If more than 4 GByte available use "FSE" 

  USB.rxflush 
  USB.str(string("FS",CR))

  bytes := USB.rx
  bytes |= USB.rx << 8
  bytes |= USB.rx << 16
  bytes |= USB.rx << 24

  WaitForCR
  WaitForCR
  return bytes

{
  LCD.dec(USB.rx)
  LCD.tx(",")
  LCD.dec(USB.rx)
  LCD.tx(",")
  LCD.dec(USB.rx)
  LCD.tx(",")
  LCD.dec(USB.rx)
  LCD.tx(",")
  LCD.dec(USB.rx)
  LCD.tx(",")
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
  LCD.tx(USB.rx)
'  LCD.dec(USB.rx)
'  LCD.tx(",")
'  LCD.dec(USB.rx)
'  LCD.tx(",")
'  LCD.dec(USB.rx)
'  LCD.tx(",")
'  LCD.dec(USB.rx)
'  LCD.tx(",")
'  LCD.dec(USB.rx)
'  LCD.tx(",")
'  LCD.dec(USB.rx)
'  LCD.tx(",")
'  LCD.dec(USB.rx)
'  LCD.tx(",")
'  LCD.dec(USB.rx)
}
 
'PUB FreeSpace6                   ' Display free space (six bytes, max 281 TB/tera bytes)
'<free space in hex(6 bytes) LSB first> $0D
'  USB.rxflush 
'  USB.str(string("FSE "))
'  USB.tx(CR)
'  WaitForCR
      
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
  WaitForCR    
  
'-----------Private Functions------------
PRI WaitForCR | ioByte
  repeat
    ioByte := USB.rxtime(500)
  until ioByte == CR OR ioByte == -1
 
  if ioByte == CR
    return True
  else
    return False

PRI waitForSpace | ioByte
  repeat
    ioByte := USB.rxtime(500)
  until ioByte == " " OR ioByte == -1
 
  if ioByte == " "
    return True
  else
    return False

DAT
  ErrorMsgNoError       byte "USB ok",0
  ErrorMsgCog           byte "No Cog",0     
  ErrorMsgFailCR1       byte "Fail CR1",0 
  ErrorMsgFailCR2       byte "Fail CR2",0
  ErrorMsgFailCR3       byte "Fail CR3",0
  ErrorMsgFailCR4       byte "Fail CR4",0
  ErrorMsgNoFlash       byte "No Flash",0     
  ErrorMsgUndefined     byte "USB Fail",0      
  ErrorMsgFailBigE      byte "Fail 'E'",0     
  ErrorMsgtoutBigE      byte "tout 'E'",0     
  ErrorMsgFailSmE       byte "Fail 'e'",0     
  ErrorMsgtoutSmE       byte "tout 'e'",0     