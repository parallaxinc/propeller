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
    SPINOFFSET = $10 ' same as NAVCOM
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
byte frame2[cam#ARRAYSIZE]
byte buf


dat
PromptStrC byte 13,10
PromptStr byte "::"
PromptID  byte "X:",0
initstr byte "Antbot NOSIC v0.3 ready"
crlfstr byte 13,10,0
PUB Start | temp, temp2

    fto.init


  SERVO.Set(motorleft, 1500)
  SERVO.Set(motorright, 1500)

  temp := @Servo0
  repeat 10
    if byte[temp] < 24
       Servo.Set(byte[temp],1500)
    temp++
                     
  SERVO.Start

  com0.start(27,26,%0000,115200)    ' replace this with 31,30 to use without a xbee
  'com0.start(31,30,%0000,115200)    ' replace this with 31,30 to use without a xbee


  byte[@PromptID] := "0" + (p.id(-1)//10)

  com0.str(@PromptStr)
  com0.str(@initstr)

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
  
  repeat

  
       temp := cam.frm
       bytemove(@frame2,temp,cam#ARRAYSIZE)
       cam.runonce(true)
       cam.getmaxmin(true)
       temp2~
       'repeat cam#ARRAYSIZE
       '   frame2[temp2] := 0 #> (127 + byte[temp++] - frame2[temp2++])  <# 255

          
       lmed := cam.pmed
       lmax := cam.pmax
       lmin := cam.pmin

       
       lmedf := m.ffloat(lmed)
       lmaxf := m.ffloat(lmax)
       lminf := m.ffloat(lmin)

       maxy := m.ffloat(cam.y(cam.pmaxofs))                            
       maxx := m.ffloat(cam.x(cam.pmaxofs))                            
       miny := m.ffloat(cam.y(cam.pminofs))                            
       minx := m.ffloat(cam.x(cam.pminofs))                            


  
     if s.gnext <> s.gnow
         com0.str(@PromptStr)
         com0.str(string("Machine state is now "))
         com0.str(fto.dec(s.gnext))
         com0.crlf


     s.gtick

      
      if progrunning
      
         if s.lnext <> s.lnow
           com0.str(@PromptStr)
           com0.str(string("Program state is now "))
           com0.str(fto.dec(s.lnext))
           com0.crlf

         s.ltick

         stcnt := m.ffloat(s.lcnt)

         linecounter := s.lnow
         s.gset(PROG)
         rpn.fast 
         repeat

              if ProgramGoesWhere[LineSize * linecounter] == "@"

                        ParseCommandString

                        if progrunning == 1 ' debug, so tell me what happens where
                           ResponseCha("<")
                           ResponseStr(fto.dec(linecounter))       
                           ResponseCha(">")
                        
                        ExecuteCommand(@ProgramGoesWhere[LineSize*linecounter],progrunning==1)
                        if dtime > 0
                           timer.markSIF(m.fround(m.fmul(dtime,100_000.0)))             '50_000)'m.fround(m.fmul(dtime,1000.0)))
                           timer.waitSIF(0)
                        

         until ++linecounter > NumLines 
         rpn.slow 
         doSteering(speedX,speedY)

      ParseCommandString     
      doSteering(speedX,speedY)

         




con

STOP = 0
JOYSTICK = 1
PROG = 2

con
CmdStrLength = 50
var
byte commandstring[CmdStrLength] ' String holding the currently received commandline (buffered AI-side to make sure no characters are lost in tx)
byte executestring[CmdStrLength] ' String holding the currently received commandline (buffered AI-side to make sure no characters are lost in tx)

var
long UppercaseLetterVars[26]
var
long lmax, lmed, lmin
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
lmaxf  long 0.0      'q
lmedf  long 0.0      'r
lminf  long 0.0      's

dtime  long 0.5      'q ' debug time

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
            ExecuteCommand(@commandstring,true)       
            commandptr~~' := -1 ' rolls over to zero later
            bytefill(@commandstring, 0, CmdStrLength)


      ' new jog comamnd
      "0".."9": if commandptr < 1 ' just a joystick number by itelf
                                                commandptr~
                                                bytefill(@commandstring,0,CmdStrLength)
                                                s.gset(JOYSTICK)
                                                doJoystick(char_in)
                                                com0.str(@PromptStr)
                                                com0.tx(char_in)
                                                com0.str(string(" - Joystick",13,10))
                else
                                                byte[@commandstring + commandptr++] := (char_in) & $FF
                                                
      "`": if progrunning
      
              com0.str(@PromptStr)
              com0.str(string("Program abort",13,10))
              doSteering(0,0)
              progrunning~
              s.gset(STOP)
              s.lset(0)
           else
              byte[@commandstring + commandptr++] := (char_in) & $FF
              

      

      other:

       byte[@commandstring + commandptr] := char_in & $FF
       
       if (byte[@commandstring + commandptr] == 08)    ' backspace case -- needs to clean up cmdline
           repeat 2
              byte[@commandstring + commandptr--] := " "      ' backspace
       
       if ((commandptr == constant(CmdStrLength-1)) or (byte[@commandstring + commandptr] == 13) or (byte[@commandstring + commandptr] == 0))
          byte[@commandstring + commandptr]~
          ExecuteCommand(@commandstring,true)
          commandptr~~' := -1 ' rolls over to zero later
          bytefill(@commandstring, 0, CmdStrLength)
         
       ++commandptr ' := commandptr + 1

    
con
ResponseStringSize = 64
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
    com0.str(@ResponseString)
    ClearResponse

var
byte ProgramGoesWhere[LineSize*NumLines]
long linecounter ' essentially the PC for the virtual machine; is long to make math easier on my head
long linecounter_next
byte progrunning
long lastifresult
long lastsaveslot
con
LineSize = 32            
NumLines = 64


dat
talkingtowho byte p#AntbotID ' by default, start as "talking to me"
pri ExecuteCommand(CommandStringAddr,echoback) : offset | tempvar, cmderr, tempvar2, tempvar3, tempvar4, tempvar5


         generateecho := echoback
         offset~
         cmderr~
         bytemove(@executestring, CommandStringAddr, CmdStrLength)'strsize(CommandStringAddr)+1)
         if echoback
            ClearResponse
            
         ResponseStr(@PromptStr)

         if (executestring[0] == "@")


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
                     com0.tx(tempvar2) ' the whole point of this is to PRINT!
                 until  tempvar2 == 0 or executestring[tempvar+1] == 34
                 if executestring[tempvar+1] == 34   ' if closing " exists, also print a newline.
                    if echoback
                       ResponseCrlf
                    else
                       com0.crlf
                       
             ' secondary jog command for ease of programming
             "J":  tempvar~
                   tempvar2 := fto.ParseNextInt(@executestring, @tempvar)
                   if tempvar2 > -1
                     tempvar := tempvar // 10
                   ' new jog comamnd
                                                s.gset(JOYSTICK)
                                                doJoystick(tempvar+"0")
                                                com0.str(@PromptStr)
                                                com0.tx(tempvar+"0")
                                                com0.str(string(" - Joystick",13,10))
          
                       
             "0".."9": ' allows for self-modifying code: example @4 4 L replaces itself with @4 L in execution

             
                tempvar2 := offset := fto.ParseNextInt(@executestring, @tempvar)
                if byte[@executestring+offset] == "~"
                   bytefill(@ProgramGoesWhere[LineSize*tempvar], 0, LineSize)
                   ResponseStr(fto.dec(@ProgramGoesWhere[LineSize*tempvar])) ' debug address
                   ResponseStr(string(":Cleared"))
                else
                  tempvar3~
                  tempvar //= NumLines
                  byte[@executestring+offset] := "@"
                  repeat
                     offset++
                     tempvar3++
                  until byte[@executestring+offset] == 0
                  bytefill(@ProgramGoesWhere[LineSize*tempvar], 0, LineSize)
                  bytemove(@ProgramGoesWhere[LineSize*tempvar], @executestring+tempvar2, tempvar3)
                  ResponseStr(fto.dec(tempvar))'fto.hex(@ProgramGoesWhere[LineSize*tempvar],5)) ' debug address
                  ResponseCha(":")
                  ResponseStr(@ProgramGoesWhere[LineSize*tempvar])

                  
             "L": tempvar2 := fto.ParseNextInt(@executestring, @tempvar) ' list line  or just list
                  if tempvar2 == -1
                   repeat NumLines
                    if ProgramGoesWhere[LineSize * ++tempvar2] == "@"
                       fto.dec(tempvar2)
                       byte[fto.last] := "@"
                       com0.str(fto.last)
                       com0.tx(" ")
                       com0.str(@ProgramGoesWhere[(LineSize*tempvar2) + 1])
                       com0.crlf
                    
                  else

'                     ResponseStr(fto.hex(@ProgramGoesWhere[LineSize*tempvar],5)) ' debug address
'                     ResponseCha(":")
                     ResponseStr(fto.dec(tempvar))
                     ResponseCha(":")
                     ResponseStr(@ProgramGoesWhere[LineSize*tempvar])
                  ResponseStr(string("List: Done"))

             "Z":  ' zap
                bytefill(@ProgramGoesWhere, 0, constant(LineSize*NumLines))
                ResponseStr(string("Progmem cleared"))

                 ' bump line (move everything down one line)
             "B": tempvar2 := fto.ParseNextInt(@executestring, @tempvar) ' list line  or just list
                  if (tempvar2 == -1) or (tempvar > constant(NumLines-2))
                      ResponseStr(string("Can't bump"))
                  else
                      bytemove(@ProgramGoesWhere[LineSize*(tempvar+1)],@ProgramGoesWhere[LineSize*(tempvar)],LineSize*(NumLines - 1 - tempvar))
                      bytefill(@ProgramGoesWhere[LineSize*tempvar],0,LineSize)
                      ResponseStr(string("Line "))
                      ResponseStr(fto.dec(tempvar))
                      ResponseStr(string(" bumped; check your gotos!"))
                
             "W","R": ' write, read
                tempvar3 := fto.Upcase(executestring[1])
                tempvar4 := speedX
                tempvar5 := speedY
                doSteering(0,0)
                
                lastsaveslot := (m.fround(ParseExecutestring(EXPR, string("Current save slot"), m.ffloat(lastsaveslot),  0.0, 15.0, 3, 0)))

                PrintResponse
                
                mem.Initialize(mem#BootPin)
                mem.start(mem#BootPin)

                  tempvar := $0000_8000 + (lastsaveslot*constant(LineSize*NumLines))
                  tempvar2~   

                if tempvar3 == "W"  ' when saving, read back just in case

                  repeat constant(LineSize*NumLines/32)
                       mem.WritePage(mem#BootPin, mem#EEPROM, tempvar, @ProgramGoesWhere[tempvar2], 32)
                       repeat until mem.WriteWait(mem#BootPin, mem#EEPROM, tempvar) == 0
                       'mem.ReadPage(mem#BootPin, mem#EEPROM, tempvar, @ProgramGoesWhere[tempvar2], 32)
                       tempvar += 32
                       tempvar2 += 32
                       
                else  

                  repeat constant(LineSize*NumLines/32)
                       mem.ReadPage(mem#BootPin, mem#EEPROM, tempvar, @ProgramGoesWhere[tempvar2], 32)
                       tempvar += 32
                       tempvar2 += 32

                mem.stop(mem#BootPin)


'                ExecuteCommand(string("@L",13),echoback)


                ResponseStr(@PromptStr)
                ResponseStr(string("EEPROM operation complete"))
                doSteering(tempvar4,tempvar5)
                     
             ' if instruction 
             "I": tempvar := @executestring[1]
                  repeat
                     tempvar2 := byte[tempvar++]
                  until tempvar2 == "@" or tempvar2 == 0
                  if tempvar2 <> "@"
                     ResponseStr(@ifnotstr)
                  else
                     byte[--tempvar]~ ' set to zero for now
                     bytefill(@executestring," ",2)
                     tempvar2 := rpn.ExpressionParserRPN(@executestring, @UppercaseLetterVars, @LowercaseLetterVars, false)
                     byte[@ifevast2] := " "
                     ResponseStr(@ifevastr)
                     ResponseStr(fto.FloatToFormat(tempvar2,7,2))
                     lastifresult := tempvar2 
                     if (tempvar2 > 0) ' more than 0, not different from 0 -- this is intentional
                        ResponseCrlf
                        byte[tempvar] := "@"
                        ExecuteCommand(tempvar,echoback)
                  
             ' keep-if and keep-else instructions: if last "if" result evals to true(false for E) ,do this too
             "K","E": tempvar := @executestring[1]
                      tempvar3 := fto.Upcase(executestring[1]) 
                  repeat
                     tempvar++ 
                  until byte[tempvar] == "@" or byte[tempvar] == 0
                  if byte[tempvar] <> "@"
                     ResponseCha(tempvar3)
                     ResponseStr(@ifnotstr)
                  else
                     byte[@ifevast0] := tempvar3
                     if (lastifresult > 0 ) ^ (tempvar3 == "E")
                        byte[@ifevast2] := "1"
                        ExecuteCommand(tempvar,echoback)
                     else
                        byte[@ifevast2] := "0"

                     ResponseStr(@ifevast0)
  
             "Q":  ' end program (otherwise it's run the program at every cycle)
                    progrunning~
                    linecounter := NumLines+1
                    s.gset(STOP)
                    s.lset(STOP)
                    if echoback
                       ResponseStr(@PromptStr)
                       ResponseStr(@quitstr) 
                    else
                       com0.str(@PromptStr)
                       com0.str(@quitstr) 

             "P":
                 if StopMotorsOnPrintFrame
                  tempvar4 := speedX
                  tempvar5 := speedY
                  doSteering(0,0)
                  
                 if fto.upcase(executestring[2]) == "P"
                    PrintCameraFramePPM    ' ppm frame
                 elseif fto.upcase(executestring[2]) == "D"
                    PrintCameraFrameASCII(@frame2)  ' ascii frame
                    ResponseStr(string("Diff Frame done"))
                 else
                    PrintCameraFrameASCII(cam.frm)  ' ascii frame
                    ResponseStr(string("Frame done"))
             
                 if StopMotorsOnPrintFrame
                  doSteering(tempvar4,tempvar5)

             "M": ' me // message
                 if (executestring[2] => "0" and executestring[2] =< "9") or executestring[2] == "#"
                     tempvar3 := executestring[2]-"0"'fto.ParseNextInt(@executestring, @tempvar3)
                     case executestring[3]
                      "@":
                        'ResponseCha(executestring[2])'ResponseStr(fto.dec(tempvar3))
                        tempvar := 2
                        com0.tx("#")
                        repeat
                          tempvar2 := executestring[tempvar++]
                          com0.tx(tempvar2)
                        until  tempvar2 =< 13
                        com0.crlf
                        ResponseStr(string("Ok"))

                      "A".."Z","a".."z":

                        result := rpn.ExpressionParserRPN(@executestring+3, @UppercaseLetterVars, @LowercaseLetterVars, false)
                        
                        executestring[0] := "#" 'bytemove(@executestring, string("#!@F! "),7)
                        executestring[1] := executestring[2]
                        executestring[2] := "@"
                        executestring[4] := executestring[3]
                        executestring[3] := "F"
                        executestring[5] := " "
                        bytemove(@executestring+6,fto.FloatToFormat(result,11,3),11)  
                        bytemove(@executestring+17,@crlfstr,3)
                        com0.str(@executestring)
                        ResponseStr(string("Ok"))

                        
                        
                      other: ResponseStr(string("No valid message type"))
                 else
                     ResponseStr(string("No destination"))
                     
             "G","D": ' go/debug line or just go/debug or goto
                
                  tempvar3 := (fto.Upcase(executestring[1]) == "D")
                  tempvar2 := fto.ParseNextInt(@executestring, @tempvar)
                  if tempvar2 == -1 ' integer not found
                    progrunning := 2 + tempvar3 ' so 1 if debug run, 2 if straight run
                    'linecounter~ ' program repeats itself anyway...
                    ResponseStr(string("Going!"))
                  else
                    if progrunning ' be a goto
                       linecounter := (tempvar) // NumLines ' safety
                       ResponseStr(string("Goes to line "))
                       ResponseStr(fto.dec(linecounter--))
                    else ' just run that one line
                       ResponseStr(fto.dec(linecounter))
                       ResponseCha(":")
                       ExecuteCommand(@ProgramGoesWhere[LineSize*tempvar],tempvar3)

                ' next state / gosub (next execution starts at line after N)  
             "N": ResponseStr(string("Tick was "))
                  ResponseStr(fto.dec(s.lcnt))
                  s.lset(m.fround(ParseExecutestring(EXPR, string(", next start line"), m.ffloat(s.lnow),  0.0, constant(float(NumLines)), 3, 0)))
             

          ' Engages HP calculator emulator -- thought: do we want this to become a basic-style line thing instead?
             "?":
                  
                  bytefill(@executestring," ",2)
                  
                  ResponseStr(string("Result = "))
                  
                  result := rpn.ExpressionParserRPN(@executestring, @UppercaseLetterVars, @LowercaseLetterVars, false)
                  
                  ResponseStr(fto.FloatToFormat(result,11,3)) ' allows returning a value if we need to (better way of doing this? how do we prevent echo when running it in-state?)
                  
                  if !echoback
                      com0.str(fto.last) ' the whole point is to print it
                  
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
                   if echoback
                      PrintResponse
                   else
                       com0.str(@PromptStr)
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
                "M": joyy := ParseExecutestring(EXPR, @movestr, joyy,  0.333, 2.000, 7, 3)
                "T": joyx := ParseExecutestring(EXPR, @turnstr, joyx,  0.333, 2.000, 7, 3)
                "!": reboot
                   
               other:
                 cmderr~~
                 
             other:
                 cmderr~~

         elseif executestring[0] == "#"
                  if p.id(-1) == executestring[1] - "0" or executestring[1] == "#"
                     return ExecuteCommand(@executestring+2, echoback)
                  else
                     ResponseStr(string("Not for me or ambiguous command"))
 

         elseif executestring[0] == ":" 'or executestring[0] == 13 or executestring[0] == 10
                cmderr~ ' ok, it's another bot's response -- just ignore it.
                ClearResponse
                return ' make sure e don't answer it in any way!!!
         else
                cmderr~

         repeat
             offset++
         until (byte[@executestring + offset] == 13 or byte[@executestring + offset] == ";" or byte[@executestring + offset] == 10 or (byte[@executestring + offset] == 0))

         
         if cmderr
           ResponseStr(@executestring)
           ResponseStr(string(" ...Eh?"))
         
         ResponseCrlf
         
         if echoback 
             PrintResponse 
         else
             ClearResponse





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
   com0.str(@PromptStrC)

   repeat cam#ARRAYSIZE
    
           if (ch == cam#COLS)
               com0.str(@PromptStrC)
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
   
   'serial.rx

var
byte treval[8]
dat                          
greylevels byte " -=*%#O0"  ' ASCII from darkest to lightest
                    
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
         com0.str(@PromptStr)
         com0.str(string("Overcurrent!",13,10))

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
             com0.str(@PromptStr)
             com0.str(string("Estop: "))
             com0.str(fto.FloatToFormat(result,7,2))
             com0.crlf
             estopflag := 1.0
     else
         if estopflag~
             com0.str(@PromptStr)
             com0.str(string("Estop off",13,10))
         result~

pub doJoystick(recv) | X, Y

   recv -= "0"
                                  '  0    1     2     3     4    5    6     7    8    9
   X  :=  m.fmul(joyx,lookupz(recv: 0.0, -0.5,  0.0,  0.5, -1.0, 0.0, 1.0, -0.5, 0.0, 0.5))
   Y  :=  m.fmul(joyy,lookupz(recv: 0.0, -0.5, -1.0, -0.5,  0.0, 0.0, 0.0,  0.5, 1.0, 0.5))

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
           com0.str(@PromptStr)
           com0.str(string("Estop caused "))
           if CauseEstopToAbort & 1
             com0.str(string("prog "))
             progrunning~
           if CauseEstopToAbort & 2
             com0.str(string("mov "))
             SpeedY~
             SpeedX~
           com0.str(string("abort",13,10))
  
  SERVO.Set(motorleft, speedL)
  SERVO.Set(motorright, speedR)


pub xmittelemetry

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
  com0.str(fto.FloatToFormat(speedY,5,2))
  com0.tx("Y")
  com0.tx(",")
  com0.str(fto.FloatToFormat(speedX,5,2))
  com0.tx("X")
  com0.tx(",")
  com0.str(fto.dec(s.debugg))
  com0.tx("t")
  com0.crlf


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
quitstr  byte    "Quit",13,10,0
       