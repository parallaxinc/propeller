'@1 FX g C } f C } - $ $
'@2 SX X A * B }
'@3 SY 1 e | -
'@4 FZ 1 Z +
'@5 I Z 10 < @G 60
'@6 FZ 0
'@7 T
'@FA 0.1
'@FB 0.8
'@FC 250

CON                         
    _clkmode = xtal1 + pll16x                           
    _xinfreq = 5_000_000                                'Note Clock Speed for your setup!!
    SPINOFFSET = $10 ' like in the NAVCOM
OBJ
' this is where all of our imports go
  p: "pinout" ' this must be in EVERY antbot spin file, even if it's not used. Just in case.
  SERVO: "Servo32v3"
  fto: "FtoF"
  'ping:"DummyPingParser"
  'ping:"NMEAPingParser" ' this is just so it gets archived in
  ping:"DirectPingParser" ' this is just so it gets archived in
  com0:"FullDuplexSerialExt"
  rpn:"equationparser_RPN"
  s: "statemachine_debug"
  m: "DynamicMathLib"
  mem: "NOSIC_eeprom_driver"
  cam: "propcamera_module_preproc_antbotlayout_pcb"
  debug:"Simple_Serial"
  timer:"timer"

con
SERIALWAIT = 0'950_000'5_000_000 ' use for unreliable serial transports ex. xbee series 2
motorleft = 24
motorright = 25

dat
' servo pins setup (can be changed in software later i guess)
Servo0 byte p#SERVO0 & $FF
Servo1 byte p#SERVO1 & $FF
Servo2 byte p#SERVO2 & $FF
Servo3 byte p#SERVO3 & $FF
Servo4 byte p#SERVO4 & $FF
Servo5 byte p#SERVO5 & $FF
Servo6 byte p#SERVO6 & $FF
Servo7 byte p#SERVO7 & $FF
Servo8 byte p#SERVO8 & $FF
Servo9 byte p#SERVO9 & $FF

var
byte currentstate
PUB Start | temp

  fto.init                                               


  SERVO.Set(motorleft, 1500)                            
  SERVO.Set(motorright, 1500)

  temp := @Servo0
  repeat 10
    if byte[temp] < 24
       Servo.Set(byte[temp],1500)
    temp++
                     
  SERVO.Start

  com0.start(27,26,%0000,115200)    ' replace this with 31,30 to use without an xbee
  'com0.start(31,30,%0000,115200)    ' replace this with 27,26 to use with an xbee

  
  com0.str(string("Antbot Script Parser v0.2",13,10))  

  ping.start(@pingLF)

  ' pin 16 has the little jumper on it, receive-only; it acts like a sensor from the picaxe
  'debug_out.str(string("Init",13,10))
  s.lset(PROG)
  s.gset(PROG)
  s.gtick
  s.ltick
  s.gset(STOP)
  s.lset(STOP)
  s.gtick
  s.ltick
  SERVO.Set(motorleft, 1500)
  SERVO.Set(motorright, 1500)


  debugging := false
  repeat
       cam.runonce(true)
       cam.getmaxmin(true)
       lmed := cam.pmed
       lmax := cam.pmax
       lmin := cam.pmin
       
       maxy := m.ffloat(cam.y(cam.pmaxofs))                            
       maxx := m.ffloat(cam.x(cam.pmaxofs))                            
       miny := m.ffloat(cam.y(cam.pminofs))                            
       minx := m.ffloat(cam.x(cam.pminofs))                            
  
     if s.gnext <> s.gnow
         waitforcom
         com0.str(string(":::Machine state is now "))
         com0.str(fto.dec(s.gnext))
         com0.crlf
         releasecom

     s.gtick
     s.ltick
       
     ' Program code: this needs to be switched to script parser style and parallelized
      if progrunning
      
         if s.gnext <> s.gnow
           waitforcom
           com0.str(string(":::Program state is now "))
           com0.str(fto.dec(s.lnext))
           com0.crlf
           releasecom

         s.gtick

         stcnt := m.ffloat(s.gcnt)

         currentstate := s.gnow         
         rpn.fast 
          if ProgramGoesWhere[StateSize * currentstate] == "@"
           
                    ParseCommandString
           
                    if progrunning == 1 ' debug, so tell me what happens where
                       ResponseCha("<")
                       ResponseStr(fto.dec(currentstate))       
                       ResponseCha(">")
                    '  Execute all the commands in a state
                    ExecuteState(@GlobalFirst, progrunning == 1)
                    ExecuteState(@ProgramGoesWhere[StateSize*currentstate],progrunning==1)
                    ExecuteState(@GlobalLast, progrunning == 1)                        
           
         rpn.slow 
         doSteering(speedX,speedY)

      ParseCommandString     
      doSteering(speedX,speedY)

var
byte currentcommand[CmdStrLength]
dat
breakflag byte 0
pri ExecuteState(CommandBlockAddr, echoback)|commandpointer, lastpointer, executethrough, tempval
' this is needed to execute a series of commands, delimited by crlf
' commands are in the form precondition; command, command, command followed by crlf
commandpointer := 0
lastpointer := 0
executethrough := 1
' go through the command block, find a semicolon, comma, or crlf
repeat until byte[CommandBlockAddr + commandpointer] == 0 or breakflag
  repeat until byte[CommandBlockAddr + commandpointer] == ";" or byte[CommandBlockAddr + commandpointer] == "," or byte[CommandBlockAddr + commandpointer] == 13 or byte[CommandBlockAddr + commandpointer] == 0
    commandpointer++
  ' now whip up a substring that contains the command, and execute it. If we had a semicolon, it's more difficult, as we need to
  ' determine if it's true, and if false, skip until the next crlf
  if byte[CommandBlockAddr + commandpointer] == ";"
    if debugging
        waitforcom
        com0.str(substr(CommandBlockAddr + lastpointer, commandpointer - lastpointer))
        com0.tx(13)
        releasecom    
    tempval := (ExecuteCommand(substr(CommandBlockAddr + lastpointer, commandpointer - lastpointer), false) == false)
    commandpointer++
    if tempval    ' then this is false, stop executing through
      executethrough := 0
    else
      lastpointer := commandpointer
      executethrough := 1
  else
    if executethrough      
      if debugging
        waitforcom
        com0.str(substr(CommandBlockAddr + lastpointer, commandpointer - lastpointer))
        com0.tx(13)
        releasecom
      ExecuteCommand(substr(CommandBlockAddr + lastpointer, commandpointer - lastpointer), false)
      commandpointer++                 
      lastpointer := commandpointer
    elseif byte[CommandBlockAddr + commandpointer] == 13 or byte[CommandBlockAddr + commandpointer] == 10
       executethrough := 1
       commandpointer++             
       lastpointer := commandpointer
    else
      commandpointer++ ' this needs to be here so it skips past the ,!

  if dtime > 0
     timer.markSIF(m.fround(m.fmul(dtime,100_000.0)))             '50_000)'m.fround(m.fmul(dtime,1000.0)))
     timer.waitSIF(0)
  
breakflag := false
return    
con
' negative states are predefined system states, not code states
STOP = -1.0
PROG = -2.0
LGLOBAL = -3.0
FGLOBAL = -4.0

con
CmdStrLength = 126 ' must be less than the serial buffer
var
byte commandstring[CmdStrLength] ' String holding the currently received commandline (buffered AI-side to make sure no characters are lost in tx)
byte executestring[CmdStrLength] ' String holding the currently received commandline (buffered AI-side to make sure no characters are lost in tx)

var
long UppercaseLetterVars[26]
var
long lmax, lmed, lmin
byte programming
byte preprog
DAT ' floating-point global variables that can be assigned to letters


LowercaseLetterVars

joyx long 1.0           ' a excursion
joyy long 1.0           ' b excurstion

estopdist long 30.0      'c

speedY  long 0.0      'd
speedX  long 0.0      'e

pingLF long 0.0      'f
pingRF long 0.0      'g
pingLB long 0.0      'h
pingRB long 0.0      'i

batt   long 0.0      'j
stcnt  long 0.0      'k
battd  long 0.0      'l

maxx   long 0.0      'm
maxy   long 0.0      'n
minx   long 0.0      'o
miny   long 0.0      'p

' do something wiimote like?

qq     long 0.0      'q ' debug time

rr     long 0.0
ss     long 0.0
tt     long 0.0
uu     long 0.0
vv     long 0.0
ww     long 0.0
xxx    long 0.0
yyy    long 0.0
zz     long 0.0




dat ' flags and so on
CauseEstopToAbort byte 3
StopMotorsOnPrintFrame byte 1
generateecho byte 0
dtime long 0.0
sensorscale long 1.0
commandptr long 0

PRI ParseCommandString | char_in 'ComStringAddr, char_in

'' primitive command parser
'' commands are always shaped thus:
'' <atsign> <letter> <letter> <integer> <comma> <integer> <cr> <lf>
'' first letter is what command list it belongs to, second letter is what it is, then argument(s).

' DEVNOTE_MKB: PLEASE read this and tell me if it makes sense! I suck at interfaces!

 '

  'ComStringAddr := @commandstring


 ' if we use the same buffer for command & rxcheck, can we just parse it and flush it after execution/copy?
 
    ' now parse
  byte[@commandstring + CmdStrLength]~ ' := 0
  repeat
     char_in := com0.rxcheck
   case char_in

      -1: return false

      10: if byte[@commandstring + commandptr] <> 13 and commandptr > 2 ' intercept CRLFs
            byte[@commandstring + commandptr]~
            if (programming)
              compile(@commandstring)
            else
              ExecuteCommand(@commandstring,true)       
            commandptr~~' := -1 ' rolls over to zero later
            bytefill(@commandstring, 0, CmdStrLength)


      ' new jog comamnd
      "0".."9": if commandptr < 1 ' just a joystick number by itelf
                                                commandptr~
                                                bytefill(@commandstring,0,CmdStrLength)                                                
                                                doJoystick(char_in)
                                                waitforcom
                                                com0.str(string(":::"))
                                                com0.tx(char_in)
                                                com0.str(string(" - Joystick",13,10))
                                                releasecom
                else                            
                                                byte[@commandstring + commandptr++] := (char_in) & $FF
                                                
'      "`": if progrunning
      
'              com0.str(string(":::Program abort",13,10))
 '             doSteering(0,0)
 '             progrunning~
 '             s.gset(STOP)
 '             s.lset(0)
 '          else
 '             byte[@commandstring + commandptr++] := (char_in) & $FF
      other:

       byte[@commandstring + commandptr] := char_in & $FF
       
       if (byte[@commandstring + commandptr] == 08)    ' backspace case -- needs to clean up cmdline
           repeat 2
              byte[@commandstring + commandptr--] := " "      ' backspace
       
       if ((commandptr == constant(CmdStrLength-1)) or (byte[@commandstring + commandptr] == 13) or (byte[@commandstring + commandptr] == 0))
          byte[@commandstring + commandptr]~
          if (programming)
              compile(@commandstring)
          else
              ExecuteCommand(@commandstring,true)
          commandptr~~' := -1 ' rolls over to zero later
          bytefill(@commandstring, 0, CmdStrLength)
         
       ++commandptr ' := commandptr + 1

PUB compile(cmdstringaddr) | TempAddress ' cmdstringaddr is the address to a string
if (strcomp(cmdstringaddr, string("@E"))) ' end prog flag
    ResponseStr(string("End Programming", 13))       
    programming := 0
    s.gset(PreProg)
else
    ' command is either a sta or a rule
    ResponseStr(cmdstringaddr)
    ResponseStr(string(" OK", 13))        
    if strcomp(substr(cmdstringaddr, 4), string("STA "))    
      'cmdstringaddr[5] and onward is always the state number if it's a state, as states 
      fto.parsenextint(cmdstringaddr, @TempAddress)
      s.gset(TempAddress)
    elseif strcomp(substr(cmdstringaddr, 4), string("GLF"))
      s.gset(FGLOBAL)
    elseif strcomp(substr(cmdstringaddr, 4), string("GLL"))
      s.gset(LGLOBAL)     
    else ' else go to end of state and put it on
      if s.gnow == FGLOBAL
         TempAddress := @GlobalFirst
      elseif s.gnow == LGLOBAL
         TempAddress := @GlobalLast
      else
        TempAddress := @ProgramGoesWhere + s.gnow*StateSize
      if strsize(@ProgramGoesWhere+s.gnow*StateSize) < StateSize - 1
        bytemove(TempAddress + strsize(TempAddress), cmdstringaddr, strsize(cmdstringaddr))
        byte[TempAddress+strsize(TempAddress)] := 13 ' append crlf
        byte[TempAddress+strsize(Tempaddress) + 1] := 0 ' append 0
      else
        ResponseStr(string("State Full"))        
PrintResponse  
con
ResponseStringSize = 127
var
byte ResponseString[ResponseStringSize]
byte ResponseOffset
pri ResponseStr(StringAddrToAdd) | size
if generateecho
    size := strsize(StringAddrToAdd)
    if (ResponseOffset+size) > constant(ResponseStringSize-1)
        size := constant(ResponseStringSize-1) - ResponseOffset
    bytemove(@ResponseString[ResponseOffset], StringAddrToAdd, size)
    ResponseOffset += size
pri ResponseCha(CharToAdd) 
if generateecho
    byte[@ResponseString][ResponseOffset++] := CharToAdd.byte[0]    

pri ResponseCrlf
if generateecho
    ResponseStr(string(13,10))
pri ClearResponse
if generateecho
    bytefill(@ResponseString,0,50)
    ResponseOffset~

pri PrintResponse
if generateecho
    ResponseString[++ResponseOffset]~
    waitforcom
    com0.str(@ResponseString)
    releasecom
    ClearResponse

var
byte ProgramGoesWhere[StateSize*NumStates]
byte GlobalFirst[GlobFirstSize]
byte GlobalLast[GlobLastSize]
byte progrunning
byte debugging
long lastsaveslot
con
' state machine setup
NumStates = 6
StateSize = 1280
GlobFirstSize = 128
GlobLastSize = 128
pri ExecuteCommand(CommandStringAddr,echoback) | tempvar, cmderr, tempvar2, tempvar3, tempvar4, tempvar5, offset

         generateecho := echoback
         offset~
         cmderr~
         bytemove(@executestring, CommandStringAddr, CmdStrLength)'strsize(CommandStringAddr)+1)
           
         repeat 3
           ResponseCha(":")
         if (executestring[0] == " " or executestring[0] == ":")
             repeat until executestring[++offset] <> "@"   ' prevents blowing the stack through recursion 
             return ExecuteCommand(CommandStringAddr + --offset, echoback)
         elseif (executestring[0] == "@") 

          case fto.Upcase(executestring[1]) ' commands go in here

             "@": 
                  repeat until executestring[++offset] <> "@"   ' prevents blowing the stack through recursion 
                  return ExecuteCommand(CommandStringAddr + --offset, echoback)   

             "/": return ' pass/comment
             
             34: ' ascii "  -- print back to user (useful in programs as a print statement)
                 tempvar := 1
                 repeat
                   tempvar2 := executestring[++tempvar]
                   if echoback 
                     ResponseCha(tempvar2)
                   else
                     waitforcom
                     com0.tx(tempvar2) ' the whole point of this is to PRINT!
                     releasecom
                 until  tempvar2 == 0 or executestring[tempvar+1] == 34
                 if executestring[tempvar+1] == 34   ' if closing " exists, also print a newline.
                    if echoback
                       ResponseCrlf
                    else
                       waitforcom   
                       com0.crlf
                       releasecom

             "O": ' org
                progrunning := false
                programming := true
                ResponseStr(string("Programming"))
                preprog := s.gnow
                ResponseCrlf

             "D": ' delay time (roughly in milliseconds)
                tempvar := m.fround(rpn.ExpressionParserRPN(@executestring, @UppercaseLetterVars, @LowercaseLetterVars, false))
                tempvar2 := 381 + (clkfreq*tempvar/1000)
                com0.str(fto.dec(tempvar)) ' debug
                com0.tx("-")               ' debug
                com0.tx(">")               ' debug
                com0.str(fto.dec(tempvar2))' debug
                waitcnt(cnt + tempvar2)
                ResponseStr(string("Delay Over"))
                ResponseCrlf     
              '  waitcnt(cnt + 381 + m.fround(rpn.ExpressionParserRPN(@executestring, @UppercaseLetterVars, @LowercaseLetterVars, false)))
               ' ResponseStr(string("Delay Over"))
               ' ResponseCrlf

             "X": 'exchange line in state with new line : this is really complicated; for now just wipe states
                 tempvar3~
                 tempvar3 := fto.ParseNextInt(@executestring, @tempvar)
                 tempvar3~
                  tempvar3 := fto.ParseNextInt(@executestring, @tempvar2)
                  tempvar3:=2
                  repeat until byte[@executestring + tempvar3] <> "#" and byte[@executestring + tempvar3] <> " "
                    tempvar3++
                  ' now we're at a bunch of data we can insert into state tempvar1 at line tempvar2
                  tempvar4 := ProgramGoesWhere[StateSize*tempvar] ' start of state, now count newlines
                  tempvar5 := 1
                  repeat until tempvar5 == tempvar2 or tempvar4 == 0
                     com0.tx("x")
                     tempvar4++
                     if byte[tempvar4] == 13
                        tempvar5++
                 if byte[tempvar4] <> 0
                   if tempvar5 > 1 
                     tempvar4++ ' account for cr
                   ' this will make tempvar4 a pointer to the start of the line we are replacing

           '       bytemove(dest, source, len)
                  ' Now we need line length and see if the new line will break state size!
           
                  tempvar2~ ' tempvar2 is line length now
                  repeat until byte[tempvar4+tempvar2] == 13
                    tempvar2++
                  tempvar2++ 'account for cr                                     
           
           
                  if (strsize(@ProgramGoesWhere+tempvar*StateSize) + strsize(@executestring+tempvar3) - tempvar2) > StateSize 
                    responseStr(string("New Input Too Large"))
                    responseCrlf
                  else
                    ' we want to shift, then move, in case the line is longer!
                    bytemove(tempvar4+strsize(@executestring+tempvar3), tempvar4+tempvar2, strsize(tempvar4+tempvar2))                      
                    bytemove(tempvar4, @executestring+tempvar3,strsize(@executestring+tempvar3))
                  ResponseStr(string("Line Edit OK"))
                  ResponseCrlf
                  ResponseStr(@executestring+tempvar3)
                  ResponseStr(string("OK"))
                  ResponseCrlf                                     
                 
             "G": 'go
                programming := false
                progrunning := true
                ResponseStr(string("Running Program"))
                ResponseCrlf

             "U": 'debUg
                programming := false
                progrunning := true
                debugging := true
                ResponseStr(string("Debugging Program"))
                ResponseCrlf
          
             ' secondary jog command for ease of programming
             "J":  tempvar~
                   tempvar2 := fto.ParseNextInt(@executestring, @tempvar)
                   if tempvar2 > -1
                     tempvar := tempvar // 10
                   ' new jog comamnd        
                                                doJoystick(tempvar+"0")
                                                waitforcom
                                                com0.str(string(":::"))
                                                com0.tx(tempvar+"0")
                                                com0.str(string(" - Joystick",13,10))
                                                releasecom

             "B": ' break
                  breakflag := true
                
             "L": tempvar2 := fto.ParseNextInt(@executestring, @tempvar) ' list state or just list
                  waitforcom
                  if tempvar2 == -1
                   com0.str(string("FGLOBAL"))
                   com0.crlf
                   com0.str(@GlobalFirst)
                   com0.str(string("LGLOBAL"))
                   com0.crlf
                   com0.str(@GlobalLast)                   
                   repeat NumStates
                    if ProgramGoesWhere[StateSize * ++tempvar2] == "@"
                       fto.dec(tempvar2)
                       ' change the positive-sign space (no negative sign here) to @
'                       byte[fto.last] := "@"
                       com0.str(string("STA "))
                       com0.dec(tempvar2)
                       com0.tx(" ")
                       com0.crlf
                       com0.str(@ProgramGoesWhere[(StateSize*tempvar2)])
                       com0.crlf                    
                  else
'                     ResponseStr(fto.hex(@ProgramGoesWhere[LineSize*tempvar],5)) ' debug address
'                     ResponseCha(":")
                     ResponseStr(fto.dec(tempvar))
                     ResponseCha(":")
                     ResponseStr(@ProgramGoesWhere[StateSize*tempvar])
                  ResponseStr(string("List: Done"))
                  releasecom

             "Z":  ' zap program, or if followed by a number, zap only that state
                if strsize(@executestring) > 2
                  ' zap only one state
                  tempvar := fto.ParseNextInt(@executestring, @tempvar2)
                  if tempvar > 0
                    com0.dec(tempvar2)
                    com0.tx(13)
                    bytefill(@ProgramGoesWhere+tempvar2*StateSize, 0, constant(StateSize))
                    ResponseStr(string("State "))
                    ResponseStr(fto.dec(tempvar2))
                    ResponseStr(string(" Cleared"))
                    ResponseCrlf
                  elseif executestring[2] == "F"
                    bytefill(@GlobalFirst, 0, constant(GlobFirstSize))
                    ResponseStr(string("Global First Cleared"))
                    ResponseCrlf 
                  elseif executestring[2] == "L"
                    bytefill(@GlobalLast, 0, constant(GlobLastSize))
                    ResponseStr(string("Global Last Cleared"))
                    ResponseCrlf                 
                  else
                    ResponseStr(string("No State to Clear"))
                    ResponseCrlf 
                else
                  bytefill(@ProgramGoesWhere, 0, constant(StateSize*NumStates))
                  bytefill(@GlobalFirst, 0, constant(GlobFirstSize))
                  bytefill(@GlobalLast, 0, constant(GlobLastSize))
                  ResponseStr(string("Progmem cleared"))
                
             "W","R": ' write, read
                tempvar3 := fto.Upcase(executestring[1])
                tempvar4 := speedX
                tempvar5 := speedY
                doSteering(0,0)
                
                lastsaveslot := (m.fround(ParseExecutestring(EXPR, string("Current save slot"), m.ffloat(lastsaveslot),  0.0, 15.0, 3, 0)))

                PrintResponse
                
                mem.Initialize(mem#BootPin)
                mem.start(mem#BootPin)

                  tempvar := $0000_8000 + (lastsaveslot*constant(StateSize*NumStates))
                  tempvar2~   

                if tempvar3 == "W"  ' when saving, read back just in case

                  repeat constant(StateSize*NumStates/32)
                       mem.WritePage(mem#BootPin, mem#EEPROM, tempvar, @ProgramGoesWhere[tempvar2], 32)
                       repeat until mem.WriteWait(mem#BootPin, mem#EEPROM, tempvar) == 0
                       'mem.ReadPage(mem#BootPin, mem#EEPROM, tempvar, @ProgramGoesWhere[tempvar2], 32)
                       tempvar += 32
                       tempvar2 += 32
                       
                else  

                  repeat constant(StateSize*NumStates/32)
                       mem.ReadPage(mem#BootPin, mem#EEPROM, tempvar, @ProgramGoesWhere[tempvar2], 32)
                       tempvar += 32
                       tempvar2 += 32

                mem.stop(mem#BootPin)


'                ExecuteCommand(string("@L",13),echoback)


                ResponseStr(string(":::EEPROM operation complete"))
                doSteering(tempvar4,tempvar5)
  
             "Q":  ' end program (otherwise it's run the program at every cycle)
                    progrunning~
                    currentstate~
                    debugging~
                    s.gset(STOP)
                    if echoback
                       ResponseStr(@quitstr) 
                    else
                       com0.str(@quitstr) 

             "P":
                 if StopMotorsOnPrintFrame
                  tempvar4 := speedX
                  tempvar5 := speedY
                  doSteering(0,0)
                  
                 if fto.upcase(executestring[2]) == "P"
                    PrintCameraFramePPM    ' ppm frame
                 else
                    PrintCameraFrameASCII(cam.frm)  ' ascii frame
                    ResponseStr(string("Frame done"))
                                                            
                 if StopMotorsOnPrintFrame
                  doSteering(tempvar4,tempvar5)

             ' Next state: max out at NumStates, takes any math expression                  
             "N": ResponseStr(string("Tick was "))
                  ResponseStr(fto.dec(s.lcnt))
                  s.gset(m.fround(ParseExecutestring(EXPR, string(", next state"), m.ffloat(s.gnow),  0.0, constant(float(NumStates)), 3, 0)))
             

          ' Engages HP calculator emulator -- thought: do we want this to become a basic-style line thing instead?
             "?":
                  bytefill(@executestring," ",2)
                  ResponseStr(string("Result = "))
                  result := rpn.ExpressionParserRPN(@executestring, @UppercaseLetterVars, @LowercaseLetterVars, false)
                  ResponseStr(fto.FloatToFormat(result,11,3)) ' allows returning a value if we need to (better way of doing this? how do we prevent echo when running it in-state?)
                  if !echoback
                      com0.str(fto.last) ' the whole point is to print it

             "E": ' Execute with no output; same as HP calculator emulator, but no printing
                  bytefill(@executestring," ",2)
                  ResponseStr(string("Result = "))     
                  result := rpn.ExpressionParserRPN(@executestring, @UppercaseLetterVars, @LowercaseLetterVars, false)
                  ResponseStr(fto.FloatToFormat(result,11,3)) ' allows returning a value if we need to (better way of doing this? how do we prevent echo when running it in-state?)
                                    
             "F":',"f":
              case executestring[2]

                "0".."9": ' quickset of first ten servos
                     srvstr2[0] := executestring[2]
                     tempvar2 := byte[(@Servo0)+srvstr2[0]-"0"]
                     executestring[2] := " "
                     tempvar := ParseExecutestring(EXPR, @srvstr, 0,  -1.0, 1.0, 6, 3)
                     tempvar := m.fround(m.fmul(tempvar,500.0)) + 1500
                     if tempvar2 < 24 ' pins 24 to 31 are taken so freeze this
                        Servo.Set(tempvar2,tempvar)
                     else
                        ResponseStr(string("Servo not available",13,10))
                         
                     'ResponseStr(fto.dec(tempvar2))

                "A".."Z":
                     extvstr[9] := executestring[2]
                     extvstr[10]~
                     tempvar := (extvstr[9] - "A") * 4
                     bytefill(@executestring," ",3)
                     long[@UppercaseLetterVars + tempvar] := ParseExecutestring(EXPR, @extvstr, long[@UppercaseLetterVars + tempvar],  -100000.0, 100000.0, 8, 3)
                     extvstr[10] := " "


                "a".."z":
                     extvstr[9] := executestring[2]
                     extvstr[10]~
                     tempvar := (extvstr[9] - "a") * 4
                     bytefill(@executestring," ",3)
                     long[@LowercaseLetterVars + tempvar] := ParseExecutestring(EXPR, @extvstr, long[@LowercaseLetterVars + tempvar],  -100000.0, 100000.0, 8, 3)
                     extvstr[10] := " "

               other:
                cmderr~~ 
              
             "T": ' telemetry options
                        xmittelemetry
                     
             "S": ' set global vars; see how easy it is?
              case fto.Upcase(executestring[2])
                "A": CauseEstopToAbort := ParseExecutestring(INT, string("CauseEstopToAbort"), CauseEstopToAbort,  0, 3, 2, 0) 
                "P": StopMotorsOnPrintFrame := ParseExecutestring(INT, string("StopMotorsOnPrintFrame"), StopMotorsOnPrintFrame,  0, 1, 2, 0) 
                "D": dtime := ParseExecutestring(EXPR, string("Interline debug delay"), dtime,  0.0, 10.0, 7, 4) 
                "S": sensorscale  := ParseExecutestring(EXPR, string("Sensor scaling"), sensorscale,  0.1, 10.0, 7, 4)
                     ping.setscale(sensorscale)
 
                "X": speedX := ParseExecutestring(EXPR, @varxstr, speedX,  -1.000, 1.000, 7, 3)
                     doSteering(speedX,speedY)
                "Y": speedY := ParseExecutestring(EXPR, @varystr, speedY,  -1.000, 1.000, 7, 3)
                     doSteering(speedX,speedY)
                "E": estopdist := ParseExecutestring(EXPR, @stopstr, estopdist,  6.0, 100.0, 7, 2)
                "M": joyy := ParseExecutestring(EXPR, @movestr, joyy,  0.300, 2.000, 7, 3)
                "T": joyx := ParseExecutestring(EXPR, @turnstr, joyx,  0.300, 2.000, 7, 3)
                "!": reboot
                   
               other:
                 cmderr~~
             other:
                 cmderr~~ 

         else
                cmderr~~ 

         repeat
             offset++
         until (byte[@executestring + offset] == 13 or byte[@executestring + offset] == ";" or byte[@executestring + offset] == 10 or (byte[@executestring + offset] == 0))

         
         if cmderr
           ResponseStr(@executestring)
           ResponseStr(string(" ...Eh?",13,10))
         else
           ResponseCrlf

         if echoback
             PrintResponse 
         else
             ClearResponse
    return


pri PrintCameraFramePPM | pixel, ch', ch2



  ch~
  
  com0.str(@magicstr)
  com0.crlf
  com0.dec(cam#COLS)
  com0.tx(" ")
  com0.dec(cam#ROWS)
  com0.crlf
  com0.str(@maxcolor)
  com0.crlf

  ch := cam.frm+cam#ARRAYSIZE-1
  'ch2~
  
  repeat cam#ARRAYSIZE
        pixstr[0] := pixstr[1] := pixstr[2] := byte[ch]
        com0.str(@pixstr)
        {
        if (++ch2 == cam#COLS)
            doSteering(speedX,speedY)
            ch2~
        }
        com0.txwait
        if serialwait
           waitcnt(cnt+constant(SERIALWAIT*3/cam#COLS))
     ch--

  com0.str(@crlfmag) ' so we know we're done


dat
crlfmag  byte 13,10
magicstr byte "P6",0 
maxcolor byte "240",0
pixstr   byte "###",0

pri PrintCameraFrameASCII(where) | ch, ch2, ldiff, temp, pix




     ldiff := (lmax-lmin) >> 3 '/8
     treval[0] := lmin                    '0
     treval[1] := lmin + (ldiff)          '1
     treval[2] := lmin + (ldiff * 2)      '2
     treval[3] := lmin + (ldiff * 3)      '3
     treval[4] := lmin + (ldiff * 4)      '4
     treval[5] := lmin + (ldiff * 5)      '5
     treval[6] := lmin + (ldiff * 6)      '6
     treval[7] := lmin + (ldiff * 7)      '7



   ch2 := where+cam#ARRAYSIZE-1
   ch~
   com0.tx(0)
   com0.tx(1)
   com0.crlf

   repeat cam#ARRAYSIZE
    
           if (ch == cam#COLS)
               com0.crlf
               ch~
               doSteering(speedX,speedY)
               com0.txwait   
               if serialwait
                  waitcnt(cnt+SERIALWAIT)

           {
           case  byte[ch2]
                          0..treval[1]: temp := (greylevels[5])
                  treval[1]..treval[2]: temp := (greylevels[4])                                        
                  treval[2]..treval[3]: temp := (greylevels[3])
                  treval[3]..treval[4]: temp := (greylevels[2])
                  treval[4]..treval[5]: temp := (greylevels[1])
                  other:                temp := (greylevels[0])       
           }


           
           pix := byte[ch2]

           ' remarkably stupidly implemented binary search tree

           if pix > treval[4]  ' efgh
              if pix > treval[6]  ' gh
                 if pix > treval[7]   ' h
                    temp := byte[constant(SPINOFFSET+@greylevels+7)]
                 else               'g
                    temp := byte[constant(SPINOFFSET+@greylevels+6)]
              else               ' ef
                 if pix > treval[5]  'f
                    temp := byte[constant(SPINOFFSET+@greylevels+5)]
                 else                'e
                    temp := byte[constant(SPINOFFSET+@greylevels+4)]
           else                 ' abcd
              if pix > treval[2]  'cd
                 if pix > treval[3]    'd
                    temp := byte[constant(SPINOFFSET+@greylevels+3)]
                 else                  'c
                    temp := byte[constant(SPINOFFSET+@greylevels+2)]
              else                    ' ab
                  if pix > treval[1]  ' b
                    temp := byte[constant(SPINOFFSET+@greylevels+1)]
                  else                  ' a
                    temp := byte[constant(SPINOFFSET+@greylevels+0)]
                  
           
           com0.tx(temp)

    ch++
    ch2--

  
   com0.crlf

var
byte treval[8]
dat                          
greylevels byte " -=*%#00"  ' ASCII from darkest to lightest

con
EXPR = 2
SINGLE = 1
INT = 0
ParseParameterEchoBack = true
NaN             =       $7FFF_FFFF ' used to mean invalid value in floating point
pri ParseExecuteString(IsFloat, InitialStringAddr,  OldParameter, LowerLimit, UpperLimit, FloatDigits, DecPoint): NewParameter | tempvar 

                 if ParseParameterEchoBack
                   ResponseStr(InitialStringAddr)
                   ResponseStr(@was_str)
                   if IsFloat
                      ResponseStr(fto.FloatToFormat(OldParameter,FloatDigits,DecPoint))
                   else
                      ResponseStr(fto.IntToFormat(OldParameter,FloatDigits,DecPoint))
                 if (IsFloat)
                    if (IsFloat == EXPR)     
                        NewParameter := rpn.ExpressionParserRPN(@executestring, @UppercaseLetterVars, @LowercaseLetterVars, false)
                        if NewParameter == NaN          ' DEVNOTE: Write the NAN-on-error inside the RPN parser!
                           NewParameter := OldParameter
                    else
                        if (fto.ParseNextFloat(@executestring, @NewParameter) == -1)
                            NewParameter := OldParameter
                    if (m.fcmpi((NewParameter), m#LESSTHAN, LowerLimit))
                         NewParameter := LowerLimit
                    if (m.fcmpi((NewParameter), m#MORETHAN, UpperLimit))
                         NewParameter := UpperLimit
                 else
                    if (fto.ParseNextInt(@executestring, @NewParameter) == -1)
                         NewParameter := OldParameter
                    if (NewParameter < LowerLimit)
                         NewParameter := LowerLimit
                    if (NewParameter > UpperLimit)
                         NewParameter := UpperLimit
                 if ParseParameterEchoBack
                   ResponseStr(@isnostr)
                   if IsFloat
                       ResponseStr(fto.FloatToFormat(NewParameter,FloatDigits,DecPoint))
                   else
                       ResponseStr(fto.IntToFormat(NewParameter,FloatDigits,DecPoint))
                   ResponseCrlf
                 return NewParameter  

dat
estopflag long  0

con

OVERCURRENT = -12.0 ' empirical
pub estopcheck(dist) | p1, p2  ' returns zero if no problem, distance if there is a problem.

     if m.fcmpi(battd, m#LESSTHAN, OVERCURRENT) ' overcurrent protection
         p1 := -999.0
         p2 := -999.0
         waitforcom
         com0.str(string(":::Overcurrent!",13,10))
         releasecom

     elseif speedY > 0          
        p1 := m.fsub(pingLF,dist)
        p2 := m.fsub(pingRF,dist)

     elseif speedY < 0
        p1 := m.fsub(pingLB,dist)
        p2 := m.fsub(pingRB,dist)
        
     elseif speedX < 0
        p1 := m.fsub(pingLF,dist)
        p2 := m.fsub(pingRB,dist)

     elseif speedX > 0
        p1 := m.fsub(pingLB,dist)
        p2 := m.fsub(pingRF,dist)
     else
        return 0  ' we're not moving!
        
     
     if p1 < 0 or p2 < 0
         result := m.fmin(p1,p2)
         if not estopflag
             waitforcom
             com0.str(string(":::Estop: "))
             com0.str(fto.FloatToFormat(result,7,2))
             com0.crlf
             estopflag := 1.0
             releasecom
     else
         if estopflag~
             waitforcom
             com0.str(string(":::Estop off",13,10))
             releasecom
         result~

pub doJoystick(recv) | X, Y

   recv -= "0"

   X  :=  m.fmul(joyx,lookupz(recv: 0.0,-1.0, 0.0, 1.0, -1.0, 0.0, 1.0, -1.0, 0.0, 1.0))
   Y  :=  m.fmul(joyy,lookupz(recv: 0.0,-1.0, -1.0, -1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0))

   doSteering(X,Y)




pub doSteering(XX,YY) |speedL, speedR

  speedL := speedR := 1500
  speedY := YY
  speedX := XX

  if not estopcheck(estopdist) 
     m.lock
     speedL := servoclamp(m.fround(m.fmul(m.fsub(yy,xx),500.0)),500) + 1500
     speedR := servoclamp(m.fround(m.fmul(m.fadd(yy,xx),500.0)),500) + 1500
     m.unlock
  else
        if CauseEstopToAbort
           waitforcom
           com0.str(string(":::Estop caused "))
           if CauseEstopToAbort & 1
             com0.str(string("prog "))
             progrunning~
           if CauseEstopToAbort & 2
             com0.str(string("mov "))
             SpeedY~
             SpeedX~
           com0.str(string("abort",13,10))
           releasecom
  SERVO.Set(motorleft, speedL)
  SERVO.Set(motorright, speedR)


pub xmittelemetry
  waitforcom
  com0.str(fto.FloatToFormat(pingLF,4,0))
  com0.tx("L")
  com0.tx("F")
  com0.tx(",")
  com0.str(fto.FloatToFormat(pingRF,4,0))
  com0.tx("R")
  com0.tx("F")
  com0.tx(",")
  com0.str(fto.FloatToFormat(pingLB,4,0))
  com0.tx("L")
  com0.tx("B")
  com0.tx(",")
  com0.str(fto.FloatToFormat(pingRB,4,0))
  com0.tx("R")
  com0.tx("B")
  com0.tx(",")
  com0.str(fto.FloatToFormat(speedY,6,3))
  com0.tx("Y")
  com0.tx(",")
  com0.str(fto.FloatToFormat(speedX,6,3))
  com0.tx("X")
  com0.tx(",")
  com0.str(fto.dec(s.debugl))
  com0.tx("t")
  com0.crlf
  com0.crlf
  releasecom

'  com0.str(ping.debug)
  
pri servoclamp (clampme, minmax)
    if minmax < 0
       minmax := -minmax
    if clampme > minmax
       clampme := minmax
    if clampme < -minmax
       clampme := -minmax
    return clampme

dat
  comportflag byte 0
pub waitforcom
  repeat until (comportflag == 0)
  comportflag := 1
pub releasecom
  comportflag~  
var
byte temp_string[64]
pub strcat(string1addr, string2addr)
   result := strsize(string1addr)
   bytemove(@temp_string, string1addr, result)
   bytemove(@temp_string[result], string2addr, strsize(string2addr) + 1)
   result := @temp_string
   return
pub substr(startaddr, length)
   bytemove(@temp_string, startaddr, length)   
   temp_string[length] := 0 ' cap the string 
   result := @temp_string   

dat
extvstr  byte    "Variable _ offset",0  ' the _ gets replaced by a number or letter
isnostr  byte    " and is now ",0
was_str  byte    " was ",0
varxstr  byte    "Current power(X)",0
varystr  byte    "Current power(Y)",0
stopstr  byte    "E-stop distance",0
movestr  byte    "Joystick MOVE axis power",0
turnstr  byte    "Joystick TURN axis power",0
telfstr  byte    "Telemetry period"
ifnotstr byte    "IF has nothing to do",0
ifevast0 byte    "_"
ifevastr byte    "IF evals to "
ifevast2 byte    "_",0
srvstr   byte    "Servo "
srvstr2  byte    "_ value",0
quitstr  byte    13,10,":::Quit",13,10,0
       