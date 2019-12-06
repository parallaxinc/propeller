{{SD_uAlfat.spin}}
{{
  PUBlic functions:
        initialize(SDtx,SDrx,SDreset,TermTX,TermRX)
                                init SD tx, rx and reset pins and potentially term tx and rx pins (otherwise set value to -1)
                                toggle reset pin
                                receive and print incomming values
                                setpower to fullpower
                                changebaud to 115200
                                init MMC/SD card
        makeFolder(folder)
                                make folder with the name folder @ dir                                                                                                                  
        changeDir(folder)
                                change dir to /folder/                                                                                                                                  
        openfile(fileName, handle)
                                open file, if file doesn't exist, then it will be created, otherwise it will be overwritten, use handle (0..3)                                          
        openfileAppend(fileName, handle)
                                open file, if file doesn't exist, then it will be created, otherwise text will be added at the end, use handle (0..3)                                   
        openFileRead(fileName, handle)
                                open file to read, file must exist in this dir                                                                                          
        writeFile(text, handle)                                                                                                         
                                write 'text' to file opened in handle (0..3)                          
        writeEnter(handle)
                                write an carriage return to file opened in handle (0..3)                                                                     
        readFile(handle,amount)
                                read amount characters from file opened in handle (0..3)                                                                                                                                                                    
        DelFile(fileName)
                                delete file fileName
        DelFolder(folder)
                                delete folder folder
        flushFile(handle)
                                flush file opened in handle (0..3)
        closeFile(handle)
                                close file opened in handle (0..3)                                                 
        quickFormat
                                Quick format the SD/MMC        
        getVersion
                                Getversion and return it
        enableEcho(YesNo)
                                enable echo (if true) otherwise disable echo
        SetPower(PowerMode,Baud)
                                setpower to powermode with baudrate baud
        ChangeBaud(Baud)
                                change baudrate to baud
        initTimer
                                initialize timer
        SetTimeDate
                                set time and date
        getTimeDate
                                get time and date (print on term)
        getStats
                                get statistics (print on term)
        initMMCSD
                                initialize MMCSD before doing things with it (done in initialize)
        initFilesFolders
                                init files and folder (dir = root)
  PRIvate function:
        goRec
                                Receive values and save them in ch[99] until error received and save error in error[2] and print                    
}}
CON
  _clkmode   = xtal1 + pll16x
  _xinfreq   = 5_000_000    

  #0,Full,Reduced,Hiber
                                                                                
  #0,Baud_9600_70, Baud_19200_70, Baud_38400_70, Baud_57600_70, Baud_115200_70, Baud_230400_70, Baud_460800_70, Baud_921600_70, Baud_9600_10, Baud_19200_10, Baud_38400_10, Baud_57600_10, Baud_115200_10, Baud_230400_10, Baud_460800_10                       
VAR

  BYTE  TX_SD, RX_SD, RESET_SD, TX_Term, RX_Term
  LONG  ch[99], error[2]

OBJ

  SD    : "FullDuplexSerial"
  Term  : "FullDuplexSerial"                   

PUB initialize(SDtx,SDrx,SDreset,TermTX,TermRX)


  TX_SD    := SDtx
  RX_SD    := SDrx
  RESET_SD := SDreset
  TX_Term  := TermTX
  RX_Term  := TermRX

  Term.start(RX_Term,TX_Term,0,9600)               
  SD.start(RX_SD,TX_SD,0,9600)

  waitcnt(clkfreq + cnt)

  Term.str(string("initialized"))
  
  outa[RESET_SD]~~
  dira[RESET_SD]~~

  repeat 2
    !outa[RESET_SD]

  goRec

  SetPower(Full,Baud_9600_70)
  ChangeBaud(Baud_115200_70)
  InitMMCSD

PUB print(str)

  Term.str(str)

PUB makeFolder(folder)

  SD.str(string("M "))
  SD.str(folder)
  SD.tx(13)
  goRec

PUB changeDir(folder)

  SD.str(string("A "))
  SD.str(folder)
  SD.tx(13)
  goRec

PUB openfile(fileName, handle)

  SD.str(string("O "))
  SD.str(handle)
  SD.str(string("W>"))
  SD.str(fileName)
  SD.tx(13)
  goRec
  
PUB openfileAppend(fileName, handle)

  SD.str(string("O "))
  SD.str(handle)
  SD.str(string("A>"))
  SD.str(fileName)
  SD.tx(13)
  goRec

PUB openFileRead(fileName, handle)

  SD.str(string("O "))
  SD.str(handle)
  SD.str(string("R>"))
  SD.str(fileName)
  SD.tx(13)
  goRec

PUB writeFile(text, handle) | i,f

  i:=0
  f:=strsize(text)
  
  SD.str(string("W "))
  SD.str(handle)
  SD.str(string(">"))
  
  repeat while (f//10)<>0
    i++
    f:=f/10
  
  SD.hex(strsize(text),i)
  SD.tx(13)
  goRec
'  if error[0]==string("0") and error[1]==string("0")
    SD.str(text)
 ' SD.tx(13)
  goRec

PUB writeEnter(handle)
                    
  SD.str(string("W "))
  SD.str(handle)
  SD.str(string(">"))
  SD.hex(2,1)
  SD.tx(13)
  goRec
  SD.tx($0D)
  SD.tx($0A)
  goRec

PUB readFile(handle,amount,read) 

  SD.str(string("R "))
  SD.str(handle)
  SD.str(string("^>"))
  SD.dec(amount)
  SD.tx(13)
  goRec
  goRec
  LONG[read] := WriteRead(amount)

PRI WriteRead(amount) | p, i

  p := (@ch)+4

  repeat i from 0 to amount-1
    ReadStr[i] := LONG[p]
    p += 4
  ReadStr[i] := 0

  return @ReadStr

PUB DelFile(fileName)

  SD.str(string("D "))
  SD.str(fileName)
  SD.tx(13)
  goRec

PUB DelFolder(folder)

  SD.str(string("E "))
  SD.str(folder)
  SD.tx(13)
  goRec      
  
PUB flushFile(handle)

  SD.str(string("F "))
  SD.str(handle)
  SD.tx(13)
  goRec

PUB closeFile(handle)

  SD.str(string("C "))
  SD.str(handle)
  SD.tx(13)
  goRec

PUB quickFormat

  SD.str(string("Q CONFIRM FORMAT",13))
  goRec
  goRec

PUB getVersion(version) | i

  SD.str(string("V",13))
  goRec
  LONG[version] := WriteVersion

PRI WriteVersion | p, i

  p := (@ch)+4

  repeat i from 0 to 11
    VerStr[i] := LONG[p]
    p += 4

  return @verStr

PUB enableEcho(YesNo)

  if YesNo
    YesNo := string("1")
  else
    YesNo := string("0")
  SD.str(string("# "))
  SD.str(YesNo)
  SD.tx(13)
  goRec  

PUB SetPower(PowerMode,Baud)

  case PowerMode
    Full:      PowerMode := string("F")
    Reduced:   PowerMode := string("R")
    Hiber:     PowerMode := string("H") 
             
  case Baud
    Baud_9600_70:   Baud := string("DCEF")    
    Baud_19200_70:  Baud := string("6EEF")
    Baud_38400_70:  Baud := string("37EF")
    Baud_57600_70:  Baud := string("43F2")
    Baud_115200_70: Baud := string("1EF4")
    Baud_230400_70: Baud := string("0FF4")
    Baud_460800_70: Baud := string("05A9")
    Baud_921600_70: Baud := string("028B")
    Baud_9600_10:   Baud := string("1FAB")
    Baud_19200_10:  Baud := string("0386")
    Baud_38400_10:  Baud := string("067C")
    Baud_57600_10:  Baud := string("08E5")
    Baud_115200_10: Baud := string("04E5")
    Baud_230400_10: Baud := string("02E5")
    Baud_460800_10: Baud := string("01E5")  

  SD.str(string("Z "))
  SD.str(PowerMode)
  SD.str(string(">"))
  SD.str(Baud)
  SD.tx(13)
  goRec
  goRec
  
PUB ChangeBaud(Baud) | value

  case Baud
    Baud_9600_70:   Baud := string("DCEF")
                    value:= 9600
    Baud_19200_70:  Baud := string("6EEF")
                    value:= 19200
    Baud_38400_70:  Baud := string("37EF")
                    value:= 68400
    Baud_57600_70:  Baud := string("43F2")
                    value:= 57600
    Baud_115200_70: Baud := string("1EF4")
                    value:= 115200
    Baud_230400_70: Baud := string("0FF4")
                    value:= 230400
    Baud_460800_70: Baud := string("05A9")
                    value:= 460800
    Baud_921600_70: Baud := string("028B")
                    value:= 921600
    Baud_9600_10:   Baud := string("1FAB")
                    value:= 9600
    Baud_19200_10:  Baud := string("0386")
                    value:= 19200
    Baud_38400_10:  Baud := string("067C")
                    value:= 38400
    Baud_57600_10:  Baud := string("08E5")
                    value:= 57600
    Baud_115200_10: Baud := string("04E5")
                    value:= 115200
    Baud_230400_10: Baud := string("02E5")
                    value:= 230400
    Baud_460800_10: Baud := string("01E5")  
                    value:= 460800

  SD.str(string("B "))
  SD.str(Baud)
  SD.tx(13)
  goRec
  SD.stop
  SD.start(RX_SD,TX_SD,0,value)
  goRec

PUB initTimer

  SD.str(string("T S",13))
  goRec

PUB SetTimeDate

  SD.str(string("S 3AB45800",13))
  goRec

PUB getTimeDate

  SD.str(string("G F",13))
  goRec
  goRec

PUB getStats

  SD.str(string("K",13))
  goRec
  goRec
  
PUB initMMCSD

  SD.str(string("I",13))
  goRec

PUB initFilesFolders

  SD.str(string("@",13))
  goRec
  
PRI goRec | i

  i:=0
  
  repeat while ch[i]<>"!"
    i++
    Term.tx(ch[i]:=SD.rx)

  i:=0
  
  repeat 2    
    Term.tx(error[i]:=SD.rx)
    i++

  Term.tx(SD.rx)

DAT

  VerStr  byte "xxxxxxxxxxxx", 0
  ReadStr byte "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",0
  