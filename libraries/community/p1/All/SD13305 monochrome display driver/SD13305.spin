{{
  File: SD13305.spin
  Version: 0.1
  Data: 12.07.2008
  Author: Fabian Schwartau
  Project: Robo2
  E-Mail: fabian@opencode.eu

  With this interface you can access a SD13305 monochrome display controller. (graphic and text mode!)
  The file is not very well written and here is a low of unused crap but it works ;)
}}

CON
  '' Display pins   
  PIN_DISP_DATA_0  =  0 '' these pins must follow up - so DATA_1 is DATA_0+1 an so on   
  PIN_DISP_A0      =  8 '' Data type select
  PIN_DISP_WR      =  9 '' 8080 family MPU interface : Write signal / 6800 family: R/W signal
  PIN_DISP_RD      = 10 '' 8080 family MPU interface: Read signal / 8080 or 6800 family interface select       
  conSet               =  $40             '' 1000000 or 64 decimal = System set   (system set)
  conScroll            =  $44             '' 1000100 or 68 decimal = Scroll           (scroll)
  conCursorForm        =  $5d             '' 1011101 or 93 decimal = Horizontal and Vertical Cursor setup  (csr form)
  conCursorHdotScr     =  $5a             '' 1011010 or 90 decimal = HDOT SCR
  conCursorAddress     =  $46             '' 1000110 or 70 decimal = Set cursor position (set cursor)
  conCursorRight       =  $4c             '' 1001100 or 76 decimal = Makes cursor shift right (csrdir)
  conCursorDown        =  $4f             '' 1001111 or 79 decimal = Makes cursor shift down
  conOverlay           =  $5b             '' 1011011 or 91 decimal = Set overlay settings  (overlay)
  conWrite             =  $42             '' 1000010 or 66 decimal = Write data to memory   (mwrite)
  conDisplayON         =  $59             '' 1011001 or 89 decimal = Turn display on.               (display on)
  conDisplayOFF        =  $58             '' 1011000 or 88 decimal = Turn display off.              (display off)
  conCharPerLine       =  $28             '' 0101000 or 40 decimal = 40 characters / line   (

VAR
  ' low level
  long CPUFrequ

  ' graphic
  byte DataArray[9600]  ' Data array for graphic mode
  byte DataArrayChanges[1200]
  long i

  ' text
  long ConsolePos      

PUB Init(NewCPUFrequ)
  CPUFrequ:=NewCPUFrequ   '' set cpu speed for sleeps
  repeat i from 0 to 9599
    DataArray[i]:=$00
  repeat i from 0 to 1199
    DataArrayChanges[i]:=$00
  
  '' set pins to output
  dira[PIN_DISP_DATA_0..PIN_DISP_DATA_0+7]~~   '' set data pins output 
  dira[PIN_DISP_A0]~~                          '' set pin output
  dira[PIN_DISP_WR]~~                          '' set pin output
  dira[PIN_DISP_RD]~~                          '' set pin output 
  '' set Pins to default values                           
  outa[PIN_DISP_DATA_0..PIN_DISP_DATA_0+7]~    '' set data pins to GND
  outa[PIN_DISP_RD]~~                          '' set pin to 1  '' we dont want to read, we will never want to read yet...
  outa[PIN_DISP_WR]~~                          '' set pin to 1  '' we dont want to write right now, but later...
  outa[PIN_DISP_A0]~                           '' set pin to 0  '' will be used to set datatype

  SendCommand(conSet)
    SendData($32)
    SendData($87)
    SendData($07)
    SendData($27)
    SendData($2b)
    SendData($ef)
    SendData($28)
    SendData($00)
    
  SendCommand(conScroll)
    SendData($00)
    SendData($00)
    SendData($ef)
    SendData($00)
    SendData($10)
    SendData($ef)
    
    
  SendCommand(conCursorHdotScr)
    SendData($00)
    
  SendCommand(conOverlay)
    SendData($00)
    
  SendCommand(conDisplayOFF)
    SendData($54)  '' $56=cursor blinking with 2Hz
  
  '' ClearText, ClearGraphic
  ClearGraphic
  ClearText
  
  SendCommand(conCursorAddress)
    SendData($00)
    SendData($00)
  
  SendCommand(conCursorForm)
    SendData($04)
    SendData($86)

  SendCommand(conDisplayON)
  SendCommand(conCursorRight)
  SetAddress($0000)




' text

PUB ConsoleInit(YPos)
  ConsolePos:=YPos*40

PUB ConsoleWriteS(Text, Size) | ReadPos
  repeat ReadPos from 0 to Size-1
    if(byte[Text+ReadPos]==10)  '' CR
      ConsolePos-=ConsolePos//40
    elseif(byte[Text+ReadPos]==13)  '' LF
      ConsolePos+=40
    else
      WriteChar(ConsolePos, 0, byte[Text+ReadPos])
      ConsolePos++
      
PUB ConsoleWriteCC(Text) | ReadPos
  repeat ReadPos from 0 to STRSIZE(Text)-1
    if(byte[Text+ReadPos]==10)  '' CR
      ConsolePos-=ConsolePos//40
    elseif(byte[Text+ReadPos]==13)  '' LF
      ConsolePos+=40
    else
      WriteChar(ConsolePos, 0, byte[Text+ReadPos])
      ConsolePos++

PUB WriteText(XPos, YPos, Text) | ReadPos
  SetAddress(YPos*40+XPos)
  ReadPos:=0
  repeat ReadPos from 0 to STRSIZE(Text)-1
    SendData(byte[Text+ReadPos])

PUB WriteChar(XPos, YPos, Char)
  SetAddress(YPos*40+XPos)
  SendData(Char)
         
PUB ClearText | Counter
  SendCommand(conCursorAddress)
  SendData($00)
  SendData($00)

  SendCommand(conCursorRight)
  SendCommand(conWrite)
  repeat Counter from 0 to 30*40
    SendData($20)




' graphic
PUB SetPixel(XPos, YPos, Value) | ValueBuffer, DataArrayPos
  DataArrayPos:=(YPos*320+XPos)/8
  ValueBuffer:=DataArray[DataArrayPos]
  if(Value)
    ValueBuffer |=  (%1000_0000>>((YPos*320+XPos)//8))
  else
    ValueBuffer &= !(%1000_0000>>((YPos*320+XPos)//8))
  DataArray[DataArrayPos]:=ValueBuffer 
  DataArrayChanges[DataArrayPos/8]|=(%1000_0000>>(DataArrayPos//8))

PRI GetChangesBit(BitNo) : ReturnValue | ByteValue
  ByteValue:=DataArrayChanges[BitNo/8]
  if(ByteValue & (%1000_0000>>(BitNo//8)))
    ReturnValue:=1
  else
    ReturnValue:=0 

PUB Refresh | ReadPos, ChangesValue, LastReadPos
  LastReadPos:=0
  repeat ReadPos from 0 to 9599
    if(GetChangesBit(ReadPos))
      if(LastReadPos+1<ReadPos)
        SetAddress($1000+ReadPos)
      SendData(DataArray[ReadPos])
      LastReadPos:=ReadPos

PRI SetByte(XPos, YPos, Value) '' XPos is number of byte, not pixel!!!)
  SetAddress($1000+YPos*40+XPos)
  SendData(Value)       

PUB ClearGraphic | Counter
  SendCommand(conCursorAddress)
  SendData($00)
  SendData($10)

  SendCommand(conCursorRight)
  SendCommand(conWrite)
  repeat Counter from 0 to 240*40
    SendData($00)


' low level
  
PRI SendCommand(CommandByte)
  'WaitForDisp
  outa[PIN_DISP_A0]~~
  outa[PIN_DISP_DATA_0+7..PIN_DISP_DATA_0]:=CommandByte
  outa[PIN_DISP_WR]~
  SleepUS(5)
  outa[PIN_DISP_WR]~~    

PUB SendData(DataByte)
  'WaitForDisp    
  outa[PIN_DISP_A0]~
  outa[PIN_DISP_DATA_0+7..PIN_DISP_DATA_0]:=DataByte
  outa[PIN_DISP_WR]~
  SleepUS(5)
  outa[PIN_DISP_WR]~~
  
PUB SetAddress(Adress)
  'WaitForDisp
  SendCommand(conCursorAddress)
  SendData(Adress)
  SendData((Adress>>8)) 
  SendCommand(conCursorRight)
  SendCommand(conWrite)

PRI WaitForDisp
  dira[PIN_DISP_DATA_0..PIN_DISP_DATA_0+7]~   '' set data pins input
  outa[PIN_DISP_A0]~
  outa[PIN_DISP_RD]~
  outa[PIN_DISP_WR]~~
  repeat while ina[PIN_DISP_DATA_0+6]==0
    waitcnt(1+cnt)
  outa[PIN_DISP_RD]~~
  outa[PIN_DISP_WR]~
  dira[PIN_DISP_DATA_0..PIN_DISP_DATA_0+7]~~   '' set data pins output               

PRI SleepUS(SleepTime)
  waitcnt(((CPUFrequ/1000)*SleepTime)/1000 + cnt)