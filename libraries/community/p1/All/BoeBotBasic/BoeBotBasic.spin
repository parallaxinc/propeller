{{
Modified Tiny Basic for use with a Propeller Protoboard on a BoeBot chassis.

Copyright (c) 2008 Michael Green.  See end of file for terms of use.
}}

'' This is a specialized version that uses a serial port for input and
'' output and supports up to 4 servos, a PING, IR distance sensors and
'' an HM-55B compass.  The compass is attached to a PCA9554 I/O Expander
'' which is on the boot EEPROM I2C bus.

'' 2007-10-16  Added additional output delays for FILES, LIST, DUMP
''             Added EEPROM dump to DUMP.  Fixed LOAD / SAVE bug
'' 2007-11-02  Fixed bugs in LOAD /SAVE /DUMP.  Added extensions to LOAD /SAVE

OBJ
   def     : "BB_definitions"          ' Propeller OS definitions including device specific
   ldrInit : "BB_i2cSpiInit"           ' Initialization and assembly portion of I2C/SPI driver
   mass    : "BB_massStorage"          ' EEPROM & SD card FAT file system support
   ser     : "BB_FullDuplexSerial"     ' Serial port for console

CON
   version   = 3                       ' Major version
   release   = 008                     ' Minor release
   testLevel = 0                       ' Test change level
   
   _clkmode  = def#clockMode
   _xinfreq  = def#xtalClock
   _free     = (def#endMemory - def#endFree + 3) / 4

   leftSrv   =  0                      ' Left wheel servo
   rightSrv  =  1                      ' Right wheel servo
   pingSrv   =  2                      ' PING bracket servo
   
   irDetect  =  3                      ' IR Detector pin (via 1K series resistor)
   irEmit    =  4                      ' IR LED Emitter pin (two each via 100 ohm resistor)
   pingData  =  5                      ' PING control pin (via 1K series resistor)
   xBeeRx    =  6                      ' xBee serial port receive pin (Martin's xBee protoboard)
   xBeeTx    =  7                      ' xBee serial port transmit pin

   bootTx    = 30                      ' Boot serial port transmit pin
   bootRx    = 31                      ' Boot serial port receive pin

   expAddr   = def#bootAddr + $40<<8   ' Expander I2C address
   expInp    = expAddr + 0             ' Expander input register
   expOut    = expAddr + 1             ' Expander output register
   expInv    = expAddr + 2             ' Expander invert inputs
   expDir    = expAddr + 3             ' Expander direction register
   
   hm55bEna  = %0001                   ' HM55B Enable (active low)
   hm55bClk  = %0010                   ' HM55B Clock (active neg edge)
   hm55bDI   = %0100                   ' HM55B Data input
   hm55bDO   = %1000                   ' HM55B Data output
   
   hm55bRst  = %0000                   ' HM55B Reset command
   hm55bMea  = %1000                   ' HM55B Measure command
   hm55bSta  = %1100                   ' HM55B Status command
   hm55bRdy  = %1100                   ' HM55B Ready status
   XYBits    = 11                      ' Number of bits from HM55B
   XYShft    = 32 - XYBits + 1         ' Sign extension shift count

   bspKey    = 8                       ' Input backspace key
   fEof      = -1                      ' End of file value
      
   maxstack  = 20                      ' Maximum stack depth
   linelen   = 256                     ' Maximum input line length
   quote     = 34                      ' Double quote
   caseBit   = !32                     ' Uppercase/Lowercase bit
   saveProg  = $7FF0                   ' End of saved program in EEPROM
   callStack = 512                     ' Minimum Spin call stack depth (longs)
   
var
   long sp, tp, eop, nextlineloc, curlineno, pauseTime
   long vars[26], stack[maxstack], control[2], progsize
   long forStep[26], forLimit[26], forLoop[26]
   long servoStack[20], servoTime[3], servoDur[3], servoStarted
   long pingStack[20], pingTime, pingStarted
   long xValue, yValue, tValue
   word outputs
   byte tline[linelen], tailLine[linelen], inVars[26], fileOpened

dat
   tok0  byte "IF", 0
   tok1  byte "THEN", 0
   tok2  byte "INPUT", 0    ' INPUT {"<prompt>";} <var> {,<var>}
   tok3  byte "PRINT", 0    ' PRINT {USING "<format>";} ...
   tok4  byte "GOTO", 0
   tok5  byte "GOSUB", 0
   tok6  byte "RETURN", 0
   tok7  byte "REM", 0
   tok8  byte "NEW", 0
   tok9  byte "LIST", 0
   tok10 byte "RUN", 0
   tok11 byte "RND", 0
   tok12 byte "OPEN", 0     ' OPEN " <file> ",<mode>
   tok13 byte "READ", 0     ' READ <var> {,<var>}
   tok14 byte "WRITE", 0    ' WRITE {USING "<format>";} ...
   tok15 byte "CLOSE", 0    ' CLOSE
   tok16 byte "DELETE", 0   ' DELETE " <file> "
   tok17 byte "RENAME", 0   ' RENAME " <file> "," <file> "
   tok18 byte "FILES", 0    ' FILES
   tok19 byte "SAVE", 0     ' SAVE or SAVE [<expr>] or SAVE "<file>"
   tok20 byte "LOAD", 0     ' LOAD or LOAD [<expr>] or LOAD "<file>"
   tok21 byte "NOT" ,0      ' NOT <logical>
   tok22 byte "AND" ,0      ' <logical> AND <logical>
   tok23 byte "OR", 0       ' <logical> OR <logical>
   tok24 byte "SHL", 0      ' <expr> SHL <expr>
   tok25 byte "SHR", 0      ' <expr> SHR <expr>
   tok26 byte "FOR", 0      ' FOR <var> = <expr> TO <expr>
   tok27 byte "TO", 0
   tok28 byte "STEP", 0     '  optional STEP <expr>
   tok29 byte "NEXT", 0     ' NEXT <var>
   tok30 byte "INA", 0      ' INA [ <expr> ]
   tok31 byte "OUTA", 0     ' OUTA [ <expr> ] = <expr>
   tok32 byte "PAUSE", 0    ' PAUSE <time ms> {,<time us>}
   tok33 byte "USING", 0    ' PRINT USING "<format>"; ...
   tok34 byte "ROL", 0      ' <expr> ROL <expr>
   tok35 byte "ROR", 0      ' <expr> ROR <expr>
   tok36 byte "SAR", 0      ' <expr> SAR <expr>
   tok37 byte "REV", 0      ' <expr> REV <expr>
   tok38 byte "BYTE", 0     ' BYTE [ <expr> ]
   tok39 byte "WORD", 0     ' WORD [ <expr> ]
   tok40 byte "LONG", 0     ' LONG [ <expr> ]
   tok41 byte "CNT", 0
   tok42 byte "PHSA", 0
   tok43 byte "PHSB", 0
   tok44 byte "FRQA", 0
   tok45 byte "FRQB", 0
   tok46 byte "CTRA", 0
   tok47 byte "CTRB", 0
   tok48 byte "DISPLAY", 0  ' DISPLAY <expr> {,<expr>}
   tok49 byte "KEYCODE", 0  ' KEYCODE
   tok50 byte "LET", 0
   tok51 byte "STOP", 0
   tok52 byte "END", 0
   tok53 byte "EEPROM", 0   ' EEPROM[ <expr> ]
   tok54 byte "FILE", 0     ' FILE
   tok55 byte "MEM", 0      ' MEM
   tok56 byte "SPIN", 0     ' SPIN [<expr>] or SPIN "<file>"
   tok57 byte "COPY", 0     ' COPY [<expr>],"<file>" or COPY "<file>",[<expr>] or
                            ' COPY [<expr>],<expr> where <expr> are different
   tok58 byte "DUMP", 0     ' DUMP <expr>,<expr> or DUMP [<expr>],<expr>
   tok59 byte "SRVLEFT", 0  ' SRVLEFT = <expr>
   tok60 byte "SRVRIGHT", 0 ' SRVRIGHT = <expr>
   tok61 byte "SRVPING", 0  ' SRVPING = <expr>
   tok62 byte "COMPASS", 0  ' COMPASS xVar, yVar, thetaVar
   tok63 byte "IRZONE", 0   ' IRZONE [ <freq>, <#zones>, <step>]
   tok64 byte "PING", 0     ' PING
   tok65 byte "EXPAND", 0   ' EXPAND [ <register> ]

   toks  word @tok0, @tok1, @tok2, @tok3, @tok4, @tok5, @tok6, @tok7
         word @tok8, @tok9, @tok10, @tok11, @tok12, @tok13, @tok14, @tok15
         word @tok16, @tok17, @tok18, @tok19, @tok20, @tok21, @tok22, @tok23
         word @tok24, @tok25, @tok26, @tok27, @tok28, @tok29, @tok30, @tok31
         word @tok32, @tok33, @tok34, @tok35, @tok36, @tok37, @tok38, @tok39
         word @tok40, @tok41, @tok42, @tok43, @tok44, @tok45, @tok46, @tok47
         word @tok48, @tok49, @tok50, @tok51, @tok52, @tok53, @tok54, @tok55
         word @tok56, @tok57, @tok58, @tok59, @tok60, @tok61, @tok62, @tok63
         word @tok64, @tok65
   tokx  word

   syn   byte "Syntax Error", 0
   ln    byte "Invalid Line Number", 0

PUB main | err, s
'' Initialize the I/O routines including console I/O, servos, PING, I2C/SPI, compass
'' Clear the program space and variables, then read a line and interpret it.
   long[def#memPtr] := def#endFree                        ' Start at end of HUB memory
   long[def#randomSeed] := def#initMarker                 ' Initialize random seed
   long[def#userPtr] := def#noSuchAddr
   ser.start(xBeeRx,xBeeTx,%0000,9600)                    ' Start console serial port
   servoStarted := false
   pingStarted := false
   longfill(@servoTime,0,3)
   longfill(@servoDur,0,3)
   pingTime := 0
   ser.str(string("BOE-BOT Basic"))
   if version > 0 or release > 0 or testLevel > 0
     ser.str(string(" Version "))
     ser.dec(version)
     ser.tx(".")
     if release < 100
       ser.tx("0")
     if release < 10
       ser.tx("0")
     ser.dec(release)
     if testLevel > 0
       ser.tx("a"+testLevel-1)
   if not ldrInit.start                                   ' Now start up the I2C driver
     abort false
   mass.writeExpander(expOut,%0000_0001)                  ' Setup PCA9554 I/O Expander
   mass.writeExpander(expInv,%0000_0000)                  '  Ena high, Clk & DO low
   mass.writeExpander(expDir,%1111_1000)                  '  DI input, high true
   long[def#initMarker] := def#uniqueMark                 ' Basic initialization complete
   ser.tx(def#Cr)
   ser.tx(def#Lf)
   pauseTime := 0
   outputs := 0
   fileOpened := 0
   progsize := long[def#memPtr] - @err - (callStack << 2) ' Allocate memory
   if progsize < 512
      ser.str(string("Available memory < 512 bytes",def#Cr,def#Lf))
      abort
   def.allocate(progsize)
   ser.dec(progsize)
   ser.str(string(" bytes available",def#Cr,def#Lf))
   clearall
   s := 0
   curlineno := -1
   ifnot \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
      ifnot \mass.openFile(string("autoexec.bas"),"r")
         if (err := \processLoad) <> fEof
            showError(err)
            newprog
         ifnot \mass.closeFile < 0
            \mass.unmountSDVol
         if err == fEof
            s := string("run")
   repeat
      err := \doline(s)
      s := 0
      if err
         showError(err)

PRI showError(err)
   if curlineno => 0
      ser.str(string("IN LINE "))
      ser.dec(curlineno)
      ser.tx(" ")
   if err < 0
      ser.str(string("SD card "))
      ser.dec(err)
      ser.tx(def#Cr)
      ser.tx(def#Lf)
   else
      putlinet(err)
   nextlineloc := eop - 2

PRI getline | i, c
   i := 0
   repeat
      c := ser.rx
      if c == bspKey
         if i > 0
            ser.str(string(def#Bsp," ",def#Bsp))
            i--
      elseif c == def#Cr
         ser.tx(c)
         ser.tx(def#Lf)
         tline[i] := 0
         tp := @tline
         return
      elseif (i < linelen-1) and (c < def#Delete)
         ser.tx(c)                   ' other key not delete key
         tline[i++] := c

pri putlinet(s) | c, ntoks
   ntoks := (@tokx - @toks) / 2
   repeat while c := byte[s++]
      if c => 128
         if (c -= 128) < ntoks
            ser.str(@@toks[c])
            if c <> 7   ' REM
               ser.tx(" ")
         else
            ser.tx("{")
            ser.dec(c)
            ser.tx("}")
      else
         ser.tx(c)
   ser.tx(def#Cr)
   ser.tx(def#Lf)
   waitcnt(clkfreq/20 + cnt)         ' no handshaking, allow time

pri spaces | c
   repeat
      c := byte[tp]
      if c == 0 or c > " "
         return c
      tp++

pri skipspaces
   if byte[tp]
      tp++
   return spaces

pri parseliteral | r, c
   r := 0
   repeat
      c := byte[tp]
      if c < "0" or c > "9"
         return r
      r := r * 10 + c - "0"
      tp++

pri movprog(at, delta)
   if eop + delta + 2 - long[def#userPtr] > progsize
      abort string("NO MEMORY")
   bytemove(at+delta, at, eop-at)
   eop += delta

pri fixvar(c)
   if c => "a"
      c -= 32
   return c - "A"

pri isvar(c)
   c := fixvar(c)
   return c => 0 and c < 26

pri tokenize | tok, c, at, put, state, i, j, ntoks
   ntoks := (@tokx - @toks) / 2
   at := tp
   put := tp
   state := 0
   repeat while c := byte[at]
      if c == quote
         if state == "Q"
            state := 0
         elseif state == 0
            state := "Q"
      if state == 0
         repeat i from 0 to ntoks-1
            tok := @@toks[i]
            j := 0
            repeat while byte[tok] and ((byte[tok] ^ byte[j+at]) & caseBit) == 0
               j++
               tok++
            if byte[tok] == 0 and not isvar(byte[j+at])
               byte[put++] := 128 + i
               at += j
               if i == 7
                  state := "R"
               else
                  repeat while byte[at] == " "
                     at++
                  state := "F"
               quit
         if state == "F"
            state := 0
         else
            byte[put++] := byte[at++]
      else
         byte[put++] := byte[at++]
   byte[put] := 0

pri wordat(loc)
   return (byte[loc]<<8)+byte[loc+1]

pri findline(lineno) | at
   at := long[def#userPtr]
   repeat while wordat(at) < lineno
      at += 3 + strsize(at+2)
   return at

pri insertline | lineno, fc, loc, locat, newlen, oldlen
   lineno := parseliteral
   if lineno < 0 or lineno => 65535
      abort @ln
   tokenize
   fc := spaces
   loc := findline(lineno)
   locat := wordat(loc)
   newlen := 3 + strsize(tp)
   if locat == lineno
      oldlen := 3 + strsize(loc+2)
      if fc == 0
         movprog(loc+oldlen, -oldlen)
      else
         movprog(loc+oldlen, newlen-oldlen)
   elseif fc
      movprog(loc, newlen)
   if fc
      byte[loc] := lineno >> 8
      byte[loc+1] := lineno
      bytemove(loc+2, tp, newlen-2)

pri clearvars
   sp := 0
   nextlineloc := long[def#userPtr]
   bytefill(@vars, 0, 26)
   pauseTime := 0

pri newprog
   eop := long[def#userPtr]
   byte[eop++] := 255
   byte[eop++] := 255
   byte[eop] := 0

pri clearall
   newprog
   clearvars

pri pushstack
   if sp => constant(maxstack-1)
      abort string("RECURSION ERROR")
   stack[sp++] := nextlineloc

pri getAddress(delim) | t
   if spaces <> "["
      abort @syn
   skipspaces
   result := expr
   if delim == "." and (result < 0 or result > 31)
      abort string("Invalid pin number")
   if delim == "." or delim == ","
      if spaces == delim
         if delim == "."             ' Handle the form <expr>..<expr>
            if byte[++tp] <> "."
               abort @syn
            result <<= 8
            skipspaces
            t := expr
            if t < 0 or t > 31
               abort string("Invalid pin number")
            result |= t | $10000
         else                        ' Handle the form <expr>,<expr>
            if result & 1 or result < 0 or result > 31
               abort string("Invalid pin number")
            skipspaces
            result := (result << 18) | (expr & $7FFFF)
      elseif delim == ","
         result := (result & $7FFFF) | def#bootAddr
   if spaces <> "]"
      abort @syn
   tp++

pri factor | tok, t, i, f, z, s
   tok := spaces
   tp++
   case tok
      "(":
         t := expr
         if spaces <> ")"
            abort @syn
         tp++
         return t
      "a".."z","A".."Z":
         return vars[fixvar(tok)]
      158: ' INA [ <expr>{..<expr>} ]
         t := getAddress(".")
         if t > $FFFF
           tok := t & $FF
           t := (t >> 8) & $FF
           repeat i from t to tok
              outputs &= ! |< i
           dira[t..tok]~
           return ina[t..tok]
         else
           outputs &= ! |< t
           dira[t]~
           return ina[t]
      166: ' BYTE [ <expr> ]
         return byte[getAddress(" ")]
      167: ' WORD [ <expr> ]
         return word[getAddress(" ")]
      168: ' LONG [ <expr> ]
         return long[getAddress(" ")]
      181: ' EEPROM [ <expr> ]
         t := getAddress(",")
         if mass.readEEPROM(t,@t,1)
            abort string("EEPROM read")
         return t & $FF
      182: ' FILE
         return mass.getByte
      183: ' MEM
         return progsize - (eop - long[def#userPtr] )
      169: ' CNT
         return CNT
      170: ' PHSA
         return PHSA
      171: ' PHSB
         return PHSB
      172: ' FRQA
         return FRQA
      173: ' FRQB
         return FRQB
      174: ' CTRA
         return CTRA
      175: ' CTRB
         return CTRB
      177: ' KEYCODE [ <mstime> ]
         return ser.rxtime(getAddress(" "))
      139: ' RND <expr>
         return (?long[def#randomSeed] >> 1) ** (factor << 1)
      190: ' COMPASS
         if hm55bValue <> hm55bRdy            ' Get raw x,y values
           abort string("COMPASS timeout")
         tValue := $80000000                  ' Do cordic conversion
         cognew(@cordic,@xValue)              '  for Brads = Atn(x,y)
         t := cnt
         repeat until tValue <> $80000000     ' Wait until finished
            if cnt - t > clkfreq / 20         ' Timeout: 50ms
               abort string("Cordic timeout")
         return tValue
      191: ' IRZONE [ <freq>, <#zones>, <step>]
         if spaces <> "["
            abort @syn
         skipspaces
         f := expr
         if spaces <> ","
            abort @syn
         skipspaces
         z := expr
         if spaces <> ","
            abort @syn
         skipspaces
         s := expr
         if spaces <> "]"
            abort @syn
         skipspaces
         repeat i from z-1 to 0             ' From most off freq to center freq
            t := f + i * s
            if pulseOut(irEmit,t,t/200#>1,irDetect,0)
               return i
         return -1                          ' Indicates not detected at all
      192: ' PING
         ifnot pingStarted
            cognew(pingProcess,@pingStack)  ' PING handler
            waitcnt(clkfreq / 50 + cnt)     ' Wait 20ms for first value
            pingStarted := true
         return pingTime * 10_000 / 29_034  ' Get current PING distance in mm
      193: ' EXPAND [ <register> ]
         return mass.readExpander(getAddress(" ") | expAddr)
      "-":
         return - factor
      "!":
         return ! factor
      "$", "%", quote, "0".."9":
         --tp
         return getAnyNumber
      other:
         abort(@syn)

pri shifts | tok, t
   t := factor
   tok := spaces
   if tok == 152 ' SHL
      tp++
      return t << factor
   elseif tok == 153 ' SHR
      tp++
      return t >> factor
   elseif tok == 162 ' ROL
      tp++
      return t <- factor
   elseif tok == 163 ' ROR
      tp++
      return t -> factor
   elseif tok == 164 ' SAR
      tp++
      return t ~> factor
   elseif tok == 165 ' REV
      tp++
      return t >< factor
   else
      return t

pri bitFactor | tok, t
   t := shifts
   repeat
      tok := spaces
      if tok == "&"
         tp++
         t &= shifts
      else
         return t

pri bitTerm | tok, t
   t := bitFactor
   repeat
      tok := spaces
      if tok == "|"
         tp++
         t |= bitFactor
      elseif tok == "^"
         tp++
         t ^= bitFactor
      else
         return t

pri term | tok, t
   t := bitTerm
   repeat
      tok := spaces
     if tok == "*"
        tp++
        t *= bitTerm
     elseif tok == "/"
        if byte[++tp] == "/"
           tp++
           t //= bitTerm
        else
           t / =bitTerm
     else
        return t

pri arithExpr | tok, t
   t := term
   repeat
      tok := spaces
      if tok == "+"
         tp++
         t += term
      elseif tok == "-"
         tp++
         t -= term
      else
         return t

pri compare | op, a, b, c
   a := arithExpr
   op := 0
   spaces
   repeat
      c := byte[tp]
      case c
         "<": op |= 1
              tp++
         ">": op |= 2
              tp++
         "=": op |= 4
              tp++
         other: quit
   case op
      0: return a
      1: return a < arithExpr
      2: return a > arithExpr 
      3: return a <> arithExpr
      4: return a == arithExpr
      5: return a =< arithExpr
      6: return a => arithExpr
      7: abort string("Invalid comparison")

pri logicNot | tok
   tok := spaces
   if tok == 149 ' NOT
      tp++
      return not compare
   return compare

pri logicAnd | t, tok
   t := logicNot
   repeat
      tok := spaces
      if tok == 150 ' AND
         tp++
         t := t and logicNot
      else
         return t

pri expr | tok, t
   t := logicAnd
   repeat
      tok := spaces
      if tok == 151 ' OR
         tp++
         t := t or logicAnd
      else
         return t

pri specialExpr
   if spaces <> "="
      abort @syn
   skipspaces
   return expr

pri scanFilename(f) | c, chars
   chars := 0
   tp++                         ' skip past initial quote
   c := byte[tp++]              
   repeat while c <> quote and c <> 0
      if chars++ < 31
         byte[f++] := c         ' keep up to 31 characters
      c := byte[tp++]
   byte[f] := 0

pri texec | ht, nt, restart, thisLine, uS, a,b,c,d, f0,f1,f2,f3,f4,f5,f6,f7
   uS := clkfreq / 1_000_000
   thisLine := tp - 2
   restart := 1
   repeat while restart
      restart := 0
      ht := spaces
      if ht == 0
         return
      nt := skipspaces
      if isvar(ht) and nt == "="
         tp++
         vars[fixvar(ht)] := expr
      elseif ht => 128
         case ht
            128: ' THEN
               a := expr
               if spaces <> 129
                  abort string("MISSING THEN")
               skipspaces
               if not a
                  return
               restart := 1
            130: ' INPUT {"<prompt>";} <var> {, <var>}
               if nt == quote
                  c := byte[++tp]
                  repeat while c <> quote and c
                     ser.tx(c)
                     c := byte[++tp]
                  if c <> quote
                     abort @syn
                  if skipspaces <> ";"
                     abort @syn
                  nt := skipspaces
               if not isvar(nt)
                  abort @syn
               b := 0
               inVars[b++] := fixvar(nt)
               repeat while skipspaces == ","
                  nt := skipspaces
                  if not isvar(nt) or b == 26
                     abort @syn
                  inVars[b++] := fixvar(nt)
               getline
               tokenize
               repeat a from 1 to b
                  vars[inVars[a-1]] := expr
                  if a < b
                     if spaces == ","
                        skipspaces
            131: ' PRINT
               a := 0
               repeat
                  nt := spaces
                  if nt == 0 or nt == ":"
                     quit
                  if nt == quote
                     tp++
                     repeat
                        c := byte[tp++]
                        if c == 0 or c == quote
                           quit
                        ser.tx(c)
                        a++
                  else
                     d~
                     if (b := expr) < 0
                        -b
                        ser.tx("-")
                        a++
                     c := 1_000_000_000
                     repeat 10
                        if b => c
                           ser.tx(b / c + "0")
                           a++
                           b //= c
                           d~~
                        elseif d or c == 1
                           ser.tx("0")
                           a++
                        c /= 10
                  nt := spaces
                  if nt == ";"
                     tp++
                  elseif nt == ","
                     ser.tx(" ")
                     a++
                     repeat while a & 7
                        ser.tx(" ")
                        a++
                     tp++
                  elseif nt == 0 or nt == ":"
                     ser.tx(def#Cr)
                     ser.tx(def#Lf)
                     quit
                  else
                     abort @syn
            132, 133: ' GOTO, GOSUB
               a := expr
               if a < 0 or a => 65535
                  abort @ln
               b := findline(a)
               if wordat(b) <> a
                  abort @ln
               if ht == 133
                  pushstack
               nextlineloc := b 
            134: ' RETURN
               if sp == 0
                  abort string("INVALID RETURN")
               nextlineloc := stack[--sp]
            135: ' REM
               repeat while skipspaces
            136: ' NEW
               clearall
            137: ' LIST {<expr> {,<expr>}}
               b := 0                ' Default line range
               c := 65535
               if spaces <> 0        ' At least one parameter
                  b := c := expr
                  if spaces == ","
                     skipspaces
                     c := expr
               a := long[def#userPtr]
               repeat while a+2 < eop
                  d := wordat(a)
                  if d => b and d =< c
                     ser.dec(d)
                     ser.tx(" ")
                     putlinet(a+2)
                  a += 3 + strsize(a+2)
            138: ' RUN
                  clearvars
            140: ' OPEN " <file> ", R/W/A
               if spaces <> quote
                  abort @syn
               scanFilename(@f0)
               if spaces <> ","
                  abort @syn
               case skipspaces
                  "A", "a": d := "a"
                  "W", "w": d := "w"
                  "R", "r": d := "r"
                  other: abort string("Invalid open file mode")
               tp++
               if \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
                  abort string("Can't mount SD card")
               if \mass.openFile(@f0,d)
                  abort string("Can't open file")
               fileOpened := true
            141: ' READ <var> {, <var> }
               if not isvar(nt)
                  abort @syn
               d := 0
               inVars[d++] := fixvar(nt)
               repeat while skipspaces == ","
                  nt := skipspaces
                  if not isvar(nt) or d == 26
                     abort @syn
                  inVars[d++] := fixvar(nt)
               a := 0
               repeat
                  c := mass.getByte
                  if c < 0
                     abort string("Can't read file")
                  elseif c == def#Cr or c == fEof
                     tline[a] := 0
                     tp := @tline
                     quit
                  elseif c == def#Lf
                     next
                  elseif a < linelen-1
                     tline[a++] := c
               tokenize
               repeat a from 1 to d
                  vars[inVars[a-1]] := expr
                  if a < d
                     if spaces == ","
                        skipspaces
            142: ' WRITE ...
               d := 0 ' record column
               repeat
                  nt := spaces
                  if nt == 0 or nt == ":"
                     quit
                  if nt == quote
                     tp++
                     repeat
                        c := byte[tp++]
                        if c == 0 or c == quote
                           quit
                        mass.out(c)
                        d++
                  else
                     a := expr
                     if a < 0
                        -a
                        mass.out("-")
                        d++
                     b := 1_000_000_000
                     c := false
                     repeat 10
                        if a => b
                           mass.out(a / b + "0")
                           a //= b
                           c := true
                           d++
                        elseif c or b == 1
                           mass.out("0")
                           d++
                        b /= 10
                  nt := spaces
                  if nt == ";"
                     tp++
                  elseif nt == ","
                     mass.out(" ")
                     d++
                     repeat while d & 7
                        mass.out(" ")
                        d++
                     tp++
                  elseif nt == 0 or nt == ":"
                     mass.out(def#Cr)
                     mass.out(def#Lf)
                     quit
                  else
                     abort @syn
            143: ' CLOSE
               fileOpened := false
               if \mass.closeFile < 0
                  abort string("Error closing file")
               \mass.unmountSDVol
            144: ' DELETE " <file> "
               if spaces <> quote
                  abort @syn
               scanFilename(@f0)
               if \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
                  abort string("Can't mount SD card")
               if \mass.openFile(@f0,"d")
                  abort string("Can't delete file")
               if \mass.closeFile < 0
                  abort string("Error deleting file")
               \mass.unmountSDVol
            145: ' RENAME " <file> "," <file> "
               if spaces <> quote
                  abort @syn
               scanFilename(@f0)
               if spaces <> ","
                  abort @syn
               if skipspaces <> quote
                  abort @syn
               scanFilename(@f0)
               abort string("Rename not implemented")
            146: ' FILES
               if \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
                  abort string("Can't mount SD card")
               mass.startSDFiles
               b := 0
               d := false
               repeat while mass.nextSDFiles(@f0) == 0
                  d := true
                  if b == 39
                     ser.tx(def#Cr)
                     ser.tx(def#Lf)
                     waitcnt(clkfreq/20 + cnt)
                     b := 0
                  ser.str(@f0)
                  repeat 13 - strsize(@f0)
                     ser.tx(" ")
                  b := b + 13
               if d
                  ser.tx(def#Cr)
                  ser.tx(def#Lf)
                  waitcnt(clkfreq/20 + cnt)
               \mass.unmountSDVol
            147: ' SAVE or SAVE [<expr>] or SAVE "<filename>"
               if (nt := spaces) == quote
                  scanFilename(@f0)
                  if \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
                     abort string("Can't mount SD card")
                  if \mass.openFile(@f0,"w")
                     abort string("Can't create file")
                  processSave
                  if \mass.closeFile < 0
                     abort string("Error closing file")
                  \mass.unmountSDVol
               else
                  if spaces == "["               ' Align save area for paged writes
                     a := getaddress(",") + 64
                     if (a & 63) == 63
                        a += 64
                     a := (a & $7FFC0) | def#bootAddr
                  else
                     a := ((saveProg - progsize) & $7FC0) | def#bootAddr
                  nt := spaces
                  if nt <> 0 and nt <> ":"
                     abort @syn                  ' Write program to EEPROM
                  d := eop - long[def#userPtr] + 1
                  if mass.writeEEPROM(a-2,@d,2)  ' Write program size
                     abort string("Save EEPROM write")
                  if mass.writeWait(a-2)
                     abort string("Save EEPROM timeout")
                  repeat c from 0 to d step 64   ' Write the program itself
                     if mass.writeEEPROM(a+c,long[def#userPtr]+c,d-c<#64)
                        abort string("Save EEPROM write")
                     if mass.writeWait(a+c)
                        abort string("Save EEPROM timeout")
            148: ' LOAD or LOAD [<expr>] or LOAD "<filename>"
               if (nt := spaces) == quote
                  scanFilename(@f0)
                  if \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
                     abort string("Can't mount SD card")
                  if \mass.openFile(@f0,"r")     ' Open requested file
                     abort string("Can't open file")
                  a := @tailLine                 ' Save statement tail
                  repeat while byte[a++] := byte[tp++]
                  newprog
                  processLoad
                  tp := @tailLine                ' Scan copy after load
                  if \mass.closeFile < 0
                     abort string("Error closing file")
                  \mass.unmountSDVol
               else
                  if nt == "["                   ' Align save area for paged writes
                     a := getaddress(",") + 64
                     if (a & 63) == 63
                        a += 64
                     a := (a & $7FFC0) | def#bootAddr
                  else
                     a := ((saveProg - progsize) & $7FC0) | def#bootAddr
                  nt := spaces
                  if nt <> 0 and nt <> ":"
                     abort @syn                  ' Read program from EEPROM
                  if mass.readEEPROM(a-2,@d,2)
                     abort string("Load EEPROM read")
                  d &= $FFFF
                  if d < 3 or d > progsize       ' Read program size & check
                     abort string("Invalid program size")
                  c := @tailLine                 ' Save statement tail
                  repeat while byte[c++] := byte[tp++]
                  tp := @tailLine                ' Scan copy after load
                  if mass.readEEPROM(a,long[def#userPtr],d)
                     abort string("Load EEPROM read")
                  eop := long[def#userPtr] + d - 1
                  nextlineloc := eop - 2         ' Leave it stopped
            154: ' FOR <var> = <expr> TO <expr> {STEP <expr>}
               ht := spaces
               if ht == 0
                  abort @syn
               nt := skipspaces
               if not isvar(ht) or nt <> "="
                  abort @syn
               a := fixvar(ht)
               skipspaces
               vars[a] := expr
               if spaces <> 155 ' TO             ' Save FOR limit
                  abort @syn
               skipspaces
               forLimit[a] := expr
               if spaces == 156 ' STEP           ' Save step size
                  skipspaces
                  forStep[a] := expr
               else
                  forStep[a] := 1                ' Default step is 1
               if spaces
                  abort @syn
               forLoop[a] := nextlineloc         ' Save address of line
               if forStep[a] < 0                 '  following the FOR
                  b := vars[a] => forLimit[a]
               else                              ' Initially past the limit?
                  b := vars[a] =< forLimit[a]
               if not b                          ' Search for matching NEXT 
                  repeat while nextlineloc < eop-2
                     curlineno := wordat(nextlineloc)
                     tp := nextlineloc + 2
                     nextlineloc := tp + strsize(tp) + 1
                     if spaces == 157            ' NEXT <var>
                        nt := skipspaces         ' Variable has to agree
                        if not isvar(nt)
                           abort @syn
                        if fixvar(nt) == a       ' If match, continue after
                           quit                  '  the matching NEXT
            157: ' NEXT <var>
               nt := spaces
               if not isvar(nt)
                  abort @syn
               a := fixvar(nt)
               vars[a] += forStep[a]             ' Increment or decrement the
               if forStep[a] < 0                 '  FOR variable and check for
                  b := vars[a] => forLimit[a]
               else                              '  the limit value
                  b := vars[a] =< forLimit[a]
               if b                              ' If continuing loop, go to
                  nextlineloc := forLoop[a]      '  statement after FOR
               tp++
            159: ' OUTA [ <expr>{..<expr>} ] = <expr>
               a := getAddress(".")
               if a > $FFFF
                  b := a & $FF
                  a := (a >> 8) & $FF
                  outa[a..b] := specialExpr
                  dira[a..b]~~
                  repeat c from a to b
                     outputs |= |< c
               else
                  outa[a] := specialExpr
                  dira[a]~~
                  outputs |= |< a
            160: ' PAUSE <expr> {,<expr>}
               if pauseTime == 0                 ' If no active pause time, set it
                  spaces                         '  with a minimum time of 50us
                  pauseTime := expr * 1000
                  if spaces == ","               ' First (or only) value is in ms
                     skipspaces
                     pauseTime += expr           ' Second value is in us
                  pauseTime #>= 50
               if pauseTime < 10_050             ' Normally pause at most 10ms at a time,
                  waitcnt(pauseTime * uS + cnt)  '  but, if that would leave < 50us,
                  pauseTime := 0                 '   pause the whole amount now
               else                             
                  a := pauseTime <# 10_000     
                  waitcnt(a * uS + cnt)          ' Otherwise, pause at most 10ms and
                  nextlineloc := thisLine        '  re-execute the PAUSE for the rest
                  pauseTime -= 10_000
            166: ' BYTE [ <expr> ] = <expr>
               a := getAddress(" ")
               byte[a] := specialExpr
            167: ' WORD [ <expr> ] = <expr>
               a := getAddress(" ")
               word[a] := specialExpr
            168: ' LONG [ <expr> ] = <expr>
               a := getAddress(" ")
               long[a] := specialExpr
            170: ' PHSA =
               PHSA := specialExpr
            171: ' PHSB =
               PHSB := specialExpr
            172: ' FRQA =
               FRQA := specialExpr
            173: ' FRQB =
               FRQB := specialExpr
            174: ' CTRA =
               CTRA := specialExpr
            175: ' CTRB =
               CTRB := specialExpr
            176: ' DISPLAY <expr> {,<expr>}
               spaces
               ser.tx(expr)
               repeat while spaces == ","
                  skipspaces
                  ser.tx(expr)
            178: ' LET <var> = <expr>
               nt := spaces
               if not isvar(nt)
                  abort @syn
               tp++
               vars[fixvar(nt)] := specialExpr
            179: ' STOP
               nextlineloc := eop-2
               return
            180: ' END
               nextlineloc := eop-2
               return
            181: ' EEPROM [ <expr> ] = <expr>
               a := getAddress(",")
               b := specialExpr
               if mass.writeEEPROM(a,@b,1)
                  abort string("EEPROM write")
               if mass.writeWait(a)
                  abort string("EEPROM timeout")
            182: ' FILE = <expr>
               if mass.out(specialExpr) < 0
                  abort string("SDCARD write error")
            184: ' SPIN [{<expr>,}<expr>] or "<file>"
               if spaces == quote
                  scanFilename(@f0)
                  mass.bootFile(@f0)
               else
                  a := getAddress(",") & !$7FFF
                  ifnot mass.checkPresence(a)
                     abort string("No EEPROM there")
                  mass.bootEEPROM(a)
               abort string("SPIN unsuccessful")
            185: ' COPY [<expr>],"<file>" or COPY "<file>",[<expr>] or
                 ' COPY [<expr>],[<expr>] where <expr> are different
               if spaces == quote
                  scanFileName(@f0)
                  if spaces <> ","
                     abort @syn
                  skipspaces
                  b := getAddress(",") & !$7FFF
                  ifnot mass.checkPresence(b)
                     abort string("No EEPROM there")
                  if \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
                     abort string("Can't mount SD card")
                  if \mass.openFile(@f0,"r")
                     abort string("Can't open file")
                  if mass.readFile(@f0,32) <> 32
                     abort string("Can't read program")
                  if mass.writeEEPROM(b,@f0,32)
                     abort string("Copy EEPROM write error")
                  if mass.writeWait(b)
                     abort string("Copy EEPROM wait error")
                  a := word[@f0+def#spinVbase]
                  repeat c from 32 to a - 1 step 32
                     d := (a - c) <# 32
                     if mass.readFile(@f0,d) <> d
                        abort string("Can't read program")
                     if mass.writeEEPROM(b+c,@f0,d)
                        abort string("Copy EEPROM write error")
                     if mass.writeWait(b+c)
                        abort string("Copy EEPROM wait error")
                  if \mass.closeFile < 0
                     abort string("Error closing file")
                  \mass.unmountSDVol
               else
                  a := getAddress(",") & !$7FFF
                  ifnot mass.checkPresence(a)
                     abort string("No EEPROM there")
                  if spaces <> ","
                     abort @syn
                  skipspaces
                  if spaces == quote
                     scanFileName(@f0)
                     if \mass.mountSDVol(def#spiDO,def#spiClk,def#spiDI,def#spiCS) < 0
                        abort string("Can't mount SD card")
                     if \mass.openFile(@f0,"w")
                        abort string("Can't create file")
                     b := 0
                     if mass.readEEPROM(a+def#spinVbase,@b,2)
                        abort string("Copy EEPROM read error")
                     repeat c from 0 to b - 1 step 32
                        d := (b - c) <# 32
                        if mass.readEEPROM(a+c,@f0,d)
                           abort string("Copy EEPROM read error")
                        if mass.writeFile(@f0,d) <> d
                           abort string("Can't save program")
                     if \mass.closeFile < 0
                        abort string("Error closing file")
                     \mass.unmountSDVol
                  else
                     if a == (b := getAddress(",") & !$7FFF)
                        abort string("EEPROM areas same")
                     ifnot mass.checkPresence(b)
                        abort string("No EEPROM there")
                     d := 0
                     if mass.readEEPROM(a+def#spinVbase,@d,2)
                        abort string("Copy EEPROM read error")
                     repeat c from 0 to d - 1 step 32
                        if mass.readEEPROM(a+c,@f0,32)
                           abort string("Copy EEPROM read error")
                        if mass.writeEEPROM(b+c,@f0,32)
                           abort string("Copy EEPROM write error")
                        if mass.writeWait(b+c)
                           abort string("Copy EEPROM wait error")
            186: ' DUMP <addr>,<size>
                 ' DUMP [<pin>,<addr>],<size>
               if spaces == "["
                  c := getAddress(",")
                  a := c & $F80000
                  b := c & $07FFFF
               else
                  a := -1
                  b := expr
               if spaces <> ","
                  abort @syn
               skipspaces
               dumpMemory(a,b,expr)
            187, 188, 189: ' SRVLEFT/SRVRIGHT/SRVPING {[ <#pulses> ]} = <width>
               if spaces == "["
                  skipspaces                        ' Optional # pulses
                  b := expr                         '  provided
                  if spaces <> "]"
                     abort @syn
                  tp++
               else
                  b := -1
               if a := specialExpr                  ' Set left servo position
                  a := a #> 500 <# 2500             ' If non-zero, limit range
               ifnot servoStarted
                  cognew(servoProcess,@servoStack)  ' Simple servo handler
                  servoStarted := true
               servoDur[ht-187] := 0
               servoTime[ht-187] := a
               servoDur[ht-187] := b
            190: ' COMPASS <x>,<y>
               if hm55bValue <> hm55bRdy
                 abort string("COMPASS timeout")
               if not isvar(nt)
                  abort @syn
               vars[fixvar(nt)] := xValue           ' Get raw x value
               nt := skipspaces
               if nt <> ","
                  abort @syn
               nt := skipspaces
               if not isvar(nt)
                  abort @syn
               vars[fixvar(nt)] := yValue           ' Get raw y value
               tp++
            192: ' PING
               ifnot pingStarted
                  cognew(pingProcess,@pingStack)    ' PING handler
                  pingStarted := true
               pingTime := 0                        ' Start PING
            193: ' EXPAND [ <register> ] = <expr>
               a := getAddress(" ") | expAddr
               mass.writeExpander(a,specialExpr)
      else                                   
         abort(@syn)
      if spaces == ":"
         restart := 1
         tp++

pri doline(s) | c              ' Execute the string in s or wait for input
   curlineno := -1
   if ser.breakCheck(def#Esc)  ' Check for an Esc character in the
      ser.rxflush              '  serial input buffer
      nextlineloc := eop-2     ' If present, stop the program
   if nextlineloc < eop-2
      curlineno := wordat(nextlineloc)
      tp := nextlineloc + 2
      nextlineloc := tp + strsize(tp) + 1
      texec
   else
      if fileOpened
         fileOpened := false
         if mass.closeFile < 0
            ser.str(string("Error closing open file",def#Cr,def#Lf))
         \mass.unmountSDVol
      pauseTime := 0
      repeat c from 0 to 15
         if outputs & |< c
            dira[c]~
            outa[c]~
      outputs := 0
      if s
         bytemove(tp:=@tline,s,strsize(s)+1)
      else
         putlinet(string("OK"))
         getline
      c := spaces
      if "0" =< c and c =< "9"
         insertline
         nextlineloc := eop - 2
      else
         tokenize
         if spaces
            texec

PRI processLoad : c | a
   repeat
      tp := @tline                  ' Copy line to tline
      repeat
         c := mass.getByte
         if c < 0 or c == def#Cr    ' Stop at CR or EOF
            quit
         elseif c == def#Lf         ' Ignore LF
            next
         elseif tp < @tline+linelen-1
            byte[tp++] := c
      byte[tp] := 0
      tp := @tline
      if c < 0 and c <> fEof
         quit
      case spaces
         "0".."9":                  ' Line number
            insertline
            nextlineloc := eop - 2
         0: if c == fEof            ' Empty line
               quit                
         other:
            abort string("Missing line number in file")
      if c == fEof                  ' Line terminated by EOF
         quit

PRI processSave | a, c, ntoks
   ntoks := (@tokx - @toks) / 2
   a := long[def#userPtr]
   repeat while a+2 < eop
      mass.dec(wordat(a))
      mass.out(" ")
      a += 2
      repeat while c := byte[a++]
         if c => 128
            if (c -= 128) < ntoks
               mass.str(@@toks[c])
               if c <> 7   ' REM
                  mass.out(" ")
            else
               mass.out("{")
               mass.dec(c)
               mass.out("}")
         else
            mass.out(c)
      mass.out(def#Cr)
      mass.out(def#Lf)

PRI getAnyNumber | c, t
   case c := byte[tp]
      quote:
         if result := byte[++tp]
            if byte[++tp] == quote
              tp++
            else
               abort string("missing closing quote")
         else
            abort string("end of line in string")
      "$":
         c := byte[++tp]
         if (t := hexDigit(c)) < 0
            abort string("invalid hex character")
         result := t
         c := byte[++tp]
         repeat until (t := hexDigit(c)) < 0
            result := result << 4 | t
            c := byte[++tp]
      "%":
         c := byte[++tp]
         if not (c == "0" or c == "1")
            abort string("invalid binary character")
         result := c - "0"
         c := byte[++tp]
         repeat while c == "0" or c == "1"
            result := result << 1 | (c - "0")
            c := byte[++tp]
      "0".."9":
         result := c - "0"
         c := byte[++tp]
         repeat while c => "0" and c =< "9"
            result := result * 10 + c - "0"
            c := byte[++tp]
      other:
        abort string("invalid literal value")

PRI hexDigit(c)
'' Convert hexadecimal character to the corresponding value or -1 if invalid.
   if c => "0" and c =< "9"
      return c - "0"
   if c => "A" and c =< "F"
      return c - "A" + 10
   if c => "a" and c =< "f"
      return c - "a" + 10
   return -1

PUB dumpMemory(pin,addr,size) | i, c, p, first, buf0, buf1, buf2
'' This routine dumps a portion of the RAM/ROM to the display (pin == -1).
'' If pin is not -1, it is an EEPROM address in the form required by the
'' I2C routines in i2cSpiInit.  The specified address is or'd with this.
'' The format is 8 bytes wide with hexadecimal and ASCII.
   addr &= $7FFFF
   first := true
   p := addr & $7FFF8
   repeat while p < (addr + size)
      if first
         ser.hex(addr,5)
         first := false
      else
         ser.hex(p,5)
      ser.tx(":")
      repeat i from 0 to 7
         byte[@buf0][i] := " "
         if p => addr and p < (addr + size)
            if pin <> -1
               c := 0
               if mass.readEEPROM(pin|p,@c,1)
                  abort string("EEPROM read")
            else
               c := byte[p]
            ser.hex(c,2)
            if c => " " and c =< "~"
               byte[@buf0][i] := c
         else
            ser.tx(" ")
            ser.tx(" ")
         ser.tx(" ")
         p++
      buf2 := 0
      ser.tx("|")
      ser.str(@buf0)
      ser.tx("|")
      ser.tx(def#Cr)
      ser.tx(def#Lf)
      waitcnt(clkfreq/20 + cnt)

PRI servoProcess | i, t, w, uS
   uS := clkfreq / 1_000_000
   outa[leftSrv..pingSrv]~
   dira[leftSrv..pingSrv]~~
   repeat
      t := 0                                   ' Keep total of pulse widths
      repeat i from 0 to 2
         if servoDur[i] <> 0                   ' Number of pulses to produce
            if servoTime[i] > 0                '  or -1 for indefinite
               w := servoTime[i] * uS
               outa[leftSrv+i]~~               ' If pulse width is non-zero
               waitcnt(w + cnt)                '  produce the requested pulse
               outa[leftSrv+i]~
               t += w
            if servoDur[i] > 0
               servoDur[i]--
      waitcnt(20_000*uS - t + cnt)             ' Pause for remainder of 20ms period

PRI pingProcess | initial, uS
   uS := clkfreq / 1_000_000
   repeat
      if pingTime == 0
         outa[pingData]~                      ' Clear I/O pin & make an output
         dira[pingData]~~             
         outa[pingData]~~                     ' Set I/O Pin & hold for at least 5uS
         outa[pingData]~~ 
         outa[pingData]~                   
         dira[pingData]~                      ' Make I/O pin an input and
         waitpne(0, |< pingData, 0)           '  wait For Pin To Go HIGH
         initial := cnt        
         waitpeq(0, |< pingData, 0)           ' Wait for pin To Go LOW 
         pingTime := ((cnt - initial)/uS)>>1  ' Compute one-way pulse width
      else
         waitcnt(clkfreq / 50 + cnt)          ' Pause about 20ms if not PINGing

PRI pulseOut(pin, freq, dur, checkPin, checkVal)
   ctra := ctrb := 0                          ' Stop counters if running
   frqa := calcFrq(freq)                      ' Get FRQA for frequency
   frqb := 1                                  ' Neg edge -> PHSB + 1
   phsb := phsa := 0                          ' Clear phases
   outa[pin]~
   dira[pin]~~                                ' Pin to output low
   ctra := %00100 << 26 | pin                 ' CTRA -> NCO
   ctrb := %01110 << 26 | pin                 ' CTRB -> Negative edge
   if dur                                     ' Go forever if dur = zero
      repeat until phsb => dur                ' Cycle counting loop
         if checkPin => 0
            if ina[checkPin] == checkVal      ' Quit early if condition met
               result := true
               quit
      waitpeq(0, |< pin, 0)                   ' Make sure pin is zero
      ctra := 0                               ' Stop CTRA module
      dira[pin]~                              ' Make pin an input
      ctrb := frqa := frqb := 0               ' Clear counter modules
                                                         
PRI calcFrq(f)

  {Solve FRQA/B = frequency * (2^32) / clkfreq with binary long division.}
  
  f <<= 1
  repeat 32                                   ' Binary long-division 
    result <<= 1
    if f => clkfreq
      f -= clkfreq
      result++        
    f <<= 1

PRI hm55bGet(bits, out) | mask                '' Shift in data
   mask := |< bits
   repeat bits
      mass.writeExpander(expOut,out|hm55bClk) ' Clock from low to high
      mask >>= 1
      if mass.readExpander(expInp) & hm55bDO  ' Sample data bit
         result |= mask
      mass.writeExpander(expOut,out)          ' Clock from high to low

PRI hm55bPut(bits, out, data) | mask          '' Shift out data
   mask := |< bits
   repeat bits
      mask >>= 1
      if data & mask
         mass.writeExpander(expOut,out|hm55bClk|hm55bDI)
         mass.writeExpander(expOut,out|hm55bDI)
      else
         mass.writeExpander(expOut,out|hm55bClk)
         mass.writeExpander(expOut,out)

PRI hm55bValue : status | out, time
   out := mass.readExpander(expOut)           ' Get current expander value
   out := out & !hm55bClk & !hm55bDI
   mass.writeExpander(expOut,out|hm55bEna)    ' Make sure enable goes high
   mass.writeExpander(expOut,out&!hm55bEna)   '  then back to low
   hm55bPut(4,out&!hm55bEna,hm55bRst)         ' Send reset command to HM55B
   mass.writeExpander(expOut,out|hm55bEna)    ' Make sure enable goes high
   mass.writeExpander(expOut,out&!hm55bEna)   '  then back to low
   hm55bPut(4,out&!hm55bEna,hm55bMea)         ' Send measure command to HM55B
   time := cnt
   repeat until status == hm55bRdy
      mass.writeExpander(expOut,out|hm55bEna) ' Make sure enable goes high
      if cnt - time > clkfreq / 10            '  then back to low
         return                               ' Allow 100ms for measurement
      mass.writeExpander(expOut,out&!hm55bEna)
      hm55bPut(4,out&!hm55bEna,hm55bSta)      ' Send status command to HM55B
      status := hm55bGet(4,out&!hm55bEna)     '  and shift in the status
   xValue := hm55bGet(XYbits,out&!hm55bEna) << XYShft ~> XYShft    ' Get data &
   yValue := -(hm55bGet(XYbits,out&!hm55bEna) << XYShft ~> XYShft) ' sign extend
   mass.writeExpander(expOut,out|hm55bEna)    ' Disable compass

DAT
              org       0
cordic        rdlong    cx,PAR
              mov       t1,PAR
              add       t1,#4
              rdlong    cy,t1
              abs       cx,cx           wc    ' Get absolute value of x
        if_c  neg       cy,cy                 ' Negate y if x was negative
              mov       ca,#0             
              rcr       ca,#1                 ' Sign of angle is sign of x

              movs      :lookup,#table
              mov       t1,#0
              mov       t2,#20

:loop         mov       dx,cy           wc
              sar       dx,t1
              mov       dy,cx
              sar       dy,t1
              sumc      cx,dx
              sumnc     cy,dy
:lookup       sumc      ca,table

              add       :lookup,#1
              add       t1,#1
              djnz      t2,#:loop
              shr       ca,#19
              wrlong    cx,PAR
              mov       t1,PAR
              add       t1,#4
              wrlong    cy,t1
              add       t1,#4
              wrlong    ca,t1
              cogid     t2
              cogstop   t2

table         long    $20000000
              long    $12E4051E
              long    $09FB385B
              long    $051111D4
              long    $028B0D43
              long    $0145D7E1
              long    $00A2F61E
              long    $00517C55
              long    $0028BE53
              long    $00145F2F
              long    $000A2F98
              long    $000517CC
              long    $00028BE6
              long    $000145F3
              long    $0000A2FA
              long    $0000517D
              long    $000028BE
              long    $0000145F
              long    $00000A30
              long    $00000518

cx            res     1
cy            res     1
ca            res     1
t1            res     1
t2            res     1
dx            res     1
dy            res     1

{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}