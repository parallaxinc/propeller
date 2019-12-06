{{
Original Tiny Basic written by Tomas Rokicki & Radical Eye Software.

Copyright (c) 2008 Michael Green.  See end of file for terms of use.
}}

''               SRAM 0 CS  - pin 0
''               SRAM 1 CS  - pin 1
'' Winbond     & SRAM   DO  - pin 4
'' Winbond     & SRAM   Clk - pin 5
'' Winbond DIO & SRAM   DI  - pin 6
'' Winbond CS               - pin 7

'' All of the Flash and SRAM I/O pins have to have 10K pullups to +Vdd.
'' The Flash also has /WE and /HOLD pins that need a 10K pullup to +Vdd.
'' The SRAM has a /HOLD pin that should be connected to the same 10K
'' pullup as the Flash /WE and /HOLD pins.  There should be a 0.1uF
'' ceramic capacitor across the Vdd / Vss supply to these chips.  Ideally
'' there would be a capacitor for each memory chip.

obj
   fsrw  : "massStorage"               ' SPI/I2C Read/Write
   dsp   : "vga_Driver"                ' VGA Text Driver
   key   : "comboKeyboard"             ' Keyboard Driver

con
   version   = 4                       ' Major version
   release   = 0                       ' Minor release
   testLevel = 0                       ' Test change level
   
   progsize  = 2048                    ' Space reserved for program
   _clkmode  = xtal1 + pll16x
   _xinfreq  = 5_000_000

   tvPins    = 12                      ' TV pin numbers
   vgaPins   = 16                      ' VGA pin numbers
   keyPins   = 26                      ' Normal PS/2 keyboard

   bspKey    = $C8                     ' PS/2 keyboard backspace key
   breakKey  = $CC                     ' PS/2 keyboard application key
   fEof      = $FF
      
   maxstack  = 20                      ' Maximum stack depth
   linelen   = 256                     ' Maximum input line length
   quote     = 34                      ' Double quote
   caseBit   = !32                     ' Uppercase/Lowercase bit
   userPtr   = dsp#sync - 4            ' Pointer to program memory  ' VGA
   
var
   long sp, tp, eop, nextlineloc, rv, curlineno, pauseTime
   long vars[26], stack[maxstack], control[2]
   long forStep[26], forLimit[26], forLoop[26]
   long ioControl[2], fcb[4]
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
   tok59 byte "FERASE", 0   ' FERASE <expr>
   tok60 byte "FREAD", 0    ' FREAD [ <expr> , <expr> ]
   tok61 byte "FWRITE", 0   ' FWRITE  <expr> , <expr> , <expr>
   tok62 byte "FCB", 0      ' FCB
   tok63 byte "SREAD", 0    ' SREAD [ <expr> , <expr> ]
   tok64 byte "SWRITE", 0   ' SWRITE <expr> , <expr> , <expr>

   toks  word @tok0, @tok1, @tok2, @tok3, @tok4, @tok5, @tok6, @tok7
         word @tok8, @tok9, @tok10, @tok11, @tok12, @tok13, @tok14, @tok15
         word @tok16, @tok17, @tok18, @tok19, @tok20, @tok21, @tok22, @tok23
         word @tok24, @tok25, @tok26, @tok27, @tok28, @tok29, @tok30, @tok31
         word @tok32, @tok33, @tok34, @tok35, @tok36, @tok37, @tok38, @tok39
         word @tok40, @tok41, @tok42, @tok43, @tok44, @tok45, @tok46, @tok47
         word @tok48, @tok49, @tok50, @tok51, @tok52, @tok53, @tok54, @tok55
         word @tok56, @tok57, @tok58, @tok59, @tok60, @tok61, @tok62, @tok63
         word @tok64
   tokx  word

   syn   byte "Syntax Error", 0
   ln    byte "Invalid Line Number", 0

PUB main | err, s
'' Clear the program space and variables, then read a line and interpret it.
   dsp.start(vgaPins)                            ' Start display
   fsrw.winSetVideo(dsp.videoCog(0),dsp.videoCog(1))
   key.start(keyPins)                            ' Start keyboard driver
   fsrw.start(@ioControl)                        ' Start I2C/SPI driver
   pauseTime := 0
   outputs := 0
   fileOpened := 0
   long[userPtr] := userPtr - progsize           ' Allocate memory
   waitcnt(clkfreq + cnt)
   dsp.str(string("FemtoBasic"))
   if version > 0 or release > 0 or testLevel > 0
     dsp.str(string(" Version "))
     dsp.dec(version)
     dsp.out(".")
     if release < 100
       dsp.out("0")
     if release < 10
       dsp.out("0")
     dsp.dec(release)
     if testLevel > 0
       dsp.out("a"+testLevel-1)
   dsp.str(string(dsp#Cr,dsp#Lf))
   dsp.str(string("Stack "))
   dsp.dec(long[userPtr] - @s)
   dsp.str(string("B, program "))
   dsp.dec(progsize - 2)
   dsp.str(string("B",dsp#Cr,dsp#Lf))
   dsp.str(string("Mounting flash ... "))
   dsp.dec(fsrw.winStart(7, 5, 6, 4, 0, 1)*4)
   dsp.str(string("K free out of "))
   dsp.dec(fsrw.flashSize>>20)
   dsp.str(string("MB",dsp#Cr,dsp#Lf))
   waitcnt(clkfreq + cnt)
   if not key.present
      dsp.str(string("No keyboard present",dsp#Cr))
      abort
   key.clearkeys
   key.breakCode(breakKey)
   clearall
   s := 0
   curlineno := -1
   repeat
      err := \doline(s)
      s := 0
      if err
         showError(err)

PRI showError(err)
   if curlineno => 0
      dsp.str(string("IN LINE "))
      dsp.dec(curlineno)
      dsp.out(" ")
   if err < 0
      dsp.str(string("SD card "))
      dsp.dec(err)
      dsp.str(string(dsp#Cr,dsp#Lf))
   else
      putlinet(err)
   nextlineloc := eop - 2

PRI getline | i, c
   i := 0
   repeat
      c := key.getkey
      if c == bspKey
         if i > 0
            dsp.str(string(dsp#Bsp," ",dsp#Bsp))
            i--
      elseif c == dsp#Cr
         dsp.str(string(dsp#Cr,dsp#Lf))
         tline[i] := 0
         tp := @tline
         return
      elseif i < linelen-1
         dsp.out(c)
         tline[i++] := c

pri putlinet(s) | c, ntoks
   ntoks := (@tokx - @toks) / 2
   repeat while c := byte[s++]
      if c => 128
         if (c -= 128) < ntoks
            dsp.str(@@toks[c])
            if c <> 7   ' REM
               dsp.out(" ")
         else
            dsp.out("{")
            dsp.dec(c)
            dsp.out("}")
      else
         dsp.out(c)
   dsp.str(string(dsp#Cr,dsp#Lf))

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
   if eop + delta + 2 - long[userPtr] > progsize
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
   at := long[userPtr]
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
   bytefill(@vars, 0, 26)
   pauseTime := 0
   nextlineloc := long[userPtr]
   sp := 0

pri newprog
   byte[long[userPtr]][0] := 255
   byte[long[userPtr]][1] := 255
   byte[long[userPtr]][2] := 0
   eop := long[userPtr] + 2
   nextlineloc := eop - 2
   sp := 0

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
         result := (result & $7FFFF) | fsrw#bootAddr
   if spaces <> "]"
      abort @syn
   tp++

pri factor | tok, t, i, a
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
         if fsrw.readEEPROM(t,@t,1)
            abort string("EEPROM read")
         return t & $FF
      182: ' FILE
         ifnot fileOpened
            abort string("File not open")
         ifnot fsrw.readFile(@fcb,@result,1)
            abort string("End of file")
         return
      188: ' FREAD [ <expr> , <expr> ]
         if spaces <> "["
            abort @syn
         skipspaces
         t := expr
         if spaces <> ","
            abort @syn
         skipspaces
         a := expr
         if spaces <> "]" or a < 1 or a > 4
            abort @syn
         tp++
         return fsrw.readData(t,0,-a)
      191: ' SREAD [ <expr> , <expr> ]
         if spaces <> "["
            abort @syn
         skipspaces
         t := expr
         if spaces <> ","
            abort @syn
         skipspaces
         a := expr
         if spaces <> "]" or a < 1 or a > 4
            abort @syn
         tp++
         return fsrw.readSRAM(t,0,-a)
      190: ' FCB
         return @fcb
      183: ' MEM
         return progsize - (eop - long[userPtr] )
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
      177: ' KEYCODE
         return key.key
      139: ' RND <factor>
         return (rv? >> 1) ** (factor << 1)
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
   tp++ ' skip past initial quote
   repeat while (c := byte[tp++]) <> quote
      if chars++ < 31
         byte[f++] := c
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
                     dsp.out(c)
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
                        dsp.out(c)
                        a++
                  else
                     d~
                     if (b := expr) < 0
                        -b
                        dsp.out("-")
                        a++
                     c := 1_000_000_000
                     repeat 10
                        if b => c
                           dsp.out(b / c + "0")
                           a++
                           b //= c
                           d~~
                        elseif d or c == 1
                           dsp.out("0")
                           a++
                        c /= 10
                  nt := spaces
                  if nt == ";"
                     tp++
                  elseif nt == ","
                     dsp.out(" ")
                     a++
                     repeat while a & 7
                        dsp.out(" ")
                        a++
                     tp++
                  elseif nt == 0 or nt == ":"
                     dsp.str(string(dsp#Cr,dsp#Lf))
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
               a := long[userPtr]
               repeat while a+2 < eop
                  d := wordat(a)
                  if d => b and d =< c
                     dsp.dec(d)
                     dsp.out(" ")
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
               ifnot fsrw.initFile(@fcb,@f0)
                  abort string("Invalid file name format")
               case d
                  "a": abort string("Append file not supported")
                  "w": ifnot fsrw.createFile(@fcb)
                          abort string("Can't create flash file")
                  "r": ifnot fsrw.openFile(@fcb)
                          abort string("Can't open flash file")
               fileOpened := true
            141: ' READ <var> {, <var> }
               ifnot fileOpened
                  abort string("File not open")
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
                  c := 0
                  ifnot fsrw.readFile(@fcb,@c,1)
                     abort string("Can't read file")
                  elseif c == dsp#Cr or c == fEof
                     tline[a] := 0
                     tp := @tline
                     quit
                  elseif c == dsp#Lf
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
               ifnot fileOpened
                  abort string("File not open")
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
                        ifnot fsrw.writeFile(@fcb,@c,1)
                           abort string("Can't write file")
                        d++
                  else
                     a := expr
                     if a < 0
                        -a
                        ifnot fsrw.writeFile(@fcb,string("-"),1)
                           abort string("Can't write file")
                     b := 1_000_000_000
                     c := false
                     repeat 10
                        if a => b
                           f0 := a / b + "0"
                           ifnot fsrw.writeFile(@fcb,@f0,1)
                              abort string("Can't write file")
                           a //= b
                           c := true
                        elseif c or b == 1
                           ifnot fsrw.writeFile(@fcb,string("0"),1)
                              abort string("Can't write file")
                        b /= 10
                  nt := spaces
                  if nt == ";"
                     tp++
                  elseif nt == ","
                     ifnot fsrw.writeFile(@fcb,string(" "),1)
                        abort string("Can't write file")
                     d++
                     repeat while d & 7
                        ifnot fsrw.writeFile(@fcb,string(" "),1)
                           abort string("Can't write file")
                        d++
                     tp++
                  elseif nt == 0 or nt == ":"
                     ifnot fsrw.writeFile(@fcb,string(dsp#Cr,dsp#Lf),2)
                        abort string("Can't write file")
                     quit
                  else
                     abort @syn
            143: ' CLOSE
               fileOpened := false
            144: ' DELETE " <file> "
               if spaces <> quote
                  abort @syn
               scanFilename(@f0)
               ifnot fsrw.initFile(@fcb,@f0)
                  abort string("Invalid file name format")
               fsrw.eraseFile(@fcb)
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
               fsrw.firstFile(@fcb)
               c := 3
               repeat while fsrw.nextFile(@fcb)
                  b := 1
                  repeat a from 0 to 7
                     if fcb.byte[a] == $FF
                        b++
                     else
                        dsp.out(fcb.byte[a])
                  dsp.out(".")
                  repeat a from 8 to 10
                     if fcb.byte[a] == $FF
                        b++
                     else
                        dsp.out(fcb.byte[a])
                  if --c
                     repeat b
                        dsp.out(" ")
                  else
                     dsp.str(string(dsp#Cr,dsp#Lf))
                     c := 3
               if c <> 3
                  dsp.str(string(dsp#Cr,dsp#Lf))
            147: ' SAVE or SAVE "<filename>"
               if (nt := spaces) == quote
                  scanFilename(@f0)
                  ifnot fsrw.initFile(@fcb,@f0)
                     abort string("Invalid file name format")
                  ifnot fsrw.createFile(@fcb)
                     abort string("Can't create flash file")
                  d := eop - long[userPtr] + 1   ' Write program size
                  ifnot fsrw.writeFile(@fcb,@d,2)
                     abort string("Can't save program size")
                  ifnot fsrw.writeFile(@fcb,long[userPtr],d)
                     abort string("Can't save program")
               else
                  if nt == "["                   ' Align save area for paged writes
                     a := getaddress(",") + 64
                     if (a & 63) == 63
                        a += 64
                     a := (a & $7FFC0) | fsrw#bootAddr
                  else
                     a := ((userPtr - progsize - 62) & $7FC0) | fsrw#bootAddr
                  nt := spaces
                  if nt <> 0 and nt <> ":"
                     abort @syn                  ' Write program to EEPROM
                  d := eop - long[userPtr] + 1
                  if fsrw.writeEEPROM(a-2,@d,2)  ' Write program size
                     abort string("Save EEPROM write")
                  if fsrw.writeWait(a-2)
                     abort string("Save EEPROM timeout")
                  repeat c from 0 to d step 64   ' Write the program itself
                     if fsrw.writeEEPROM(a+c,long[userPtr]+c,d-c<#64)
                        abort string("Save EEPROM write")
                     if fsrw.writeWait(a+c)
                        abort string("Save EEPROM timeout")
            148: ' LOAD or LOAD "<filename>"
               if (nt := spaces) == quote
                  scanFilename(@f0)
                  ifnot fsrw.initFile(@fcb,@f0)
                     abort string("Invalid file name format")
                  ifnot fsrw.openFile(@fcb)
                     abort string("Can't open flash file")
                  ifnot fsrw.readFile(@fcb,@d,2)
                     abort string("Can't load program size")
                  d &= $FFFF
                  if d < 3 or d > progsize       ' Check for valid program size
                     abort string("invalid program size")
                  c := @tailLine                 ' Save statement tail
                  repeat while byte[c++] := byte[tp++]
                  tp := @tailLine                ' Scan copy after load
                  ifnot fsrw.readFile(@fcb,long[userPtr],d)
                     abort string("Can't load program")
                  eop := long[userPtr] + d - 1
                  nextlineloc := eop - 2         ' Leave it stopped
               else
                  if nt == "["                   ' Align save area for paged writes
                     a := getaddress(",") + 64
                     if (a & 63) == 63
                        a += 64
                     a := (a & $7FFC0) | fsrw#bootAddr
                  else
                     a := ((userPtr - progsize - 62) & $7FC0) | fsrw#bootAddr
                  nt := spaces
                  if nt <> 0 and nt <> ":"
                     abort @syn                  ' Read program from EEPROM
                  if fsrw.readEEPROM(a-2,@d,2)
                     abort string("Load EEPROM read")
                  d &= $FFFF
                  if d < 3 or d > progsize       ' Read program size & check
                     abort string("Invalid program size")
                  c := @tailLine                 ' Save statement tail
                  repeat while byte[c++] := byte[tp++]
                  tp := @tailLine                ' Scan copy after load
                  if fsrw.readEEPROM(a,long[userPtr],d)
                     abort string("Load EEPROM read")
                  eop := long[userPtr] + d - 1
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
               dsp.out(expr)
               repeat while spaces == ","
                  skipspaces
                  dsp.out(expr)
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
               if fsrw.writeEEPROM(a,@b,1)
                  abort string("EEPROM write")
               if fsrw.writeWait(a)
                  abort string("EEPROM timeout")
            182: ' FILE = <expr>
               ifnot fileOpened
                  abort string("File not open")
               a := specialExpr
               ifnot fsrw.writeFile(@fcb,@a,1)
                  abort string("End of file")
            184: ' SPIN [{<expr>,}<expr>] or "<file>"
               if spaces == quote
                  scanFilename(@f0)
                  ifnot fsrw.initFile(@fcb,@f0)
                     abort string("Invalid file name format")
                  ifnot fsrw.openFile(@fcb)
                     abort string("Can't open flash file")
                  fsrw.bootFile(@fcb)
               else
                  a := getAddress(",") & !$7FFF
                  ifnot fsrw.checkPresence(a)
                     abort string("No EEPROM there")
                  fsrw.bootEEPROM(a)
               abort string("SPIN unsuccessful")
            185: ' COPY [<expr>],"<file>" or COPY "<file>",[<expr>] or
                 ' COPY [<expr>],[<expr>] where <expr> are different
               if spaces == quote
                  scanFileName(@f0)
                  if spaces <> ","
                     abort @syn
                  skipspaces
                  b := getAddress(",") & !$7FFF
                  ifnot fsrw.checkPresence(b)
                     abort string("No EEPROM there")
                  ifnot fsrw.initFile(@fcb,@f0)
                     abort string("Invalid file name format")
                  ifnot fsrw.openFile(@fcb)
                     abort string("Can't open flash file")
                  d := 0
                  a := fcb[3] & $00FFFFFF
                  if fsrw.readData(a+fsrw#vbase,@d,2)
                     abort string("Copy EEPROM read error")
                  repeat c from 0 to d - 1 step 32
                     ifnot fsrw.readFile(@fcb,@f0,32<#(d-c))
                        abort string("Copy flash read error")
                     if fsrw.writeEEPROM(b+c,@f0,32<#(d-c))
                        abort string("Copy EEPROM write error")
                     if fsrw.writeWait(b+c)
                        abort string("Copy EEPROM wait error")
               else
                  a := getAddress(",") & !$7FFF
                  ifnot fsrw.checkPresence(a)
                     abort string("No EEPROM there")
                  if spaces <> ","
                     abort @syn
                  skipspaces
                  if spaces == quote
                     scanFileName(@f0)
                     ifnot fsrw.initFile(@fcb,@f0)
                        abort string("Invalid file name format")
                     ifnot fsrw.createFile(@fcb)
                        abort string("Can't create flash file")
                     d := 0
                     if fsrw.readEEPROM(a+fsrw#vbase,@d,2)
                        abort string("Copy EEPROM read error")
                     repeat c from 0 to d - 1 step 32
                        if fsrw.readEEPROM(a+c,@f0,32<#(d-c))
                           abort string("Copy EEPROM read error")
                        ifnot fsrw.writeFile(@fcb,@f0,32<#(d-c))
                           abort string("Copy flash write error")
                  else
                     if a == (b := getAddress(",") & !$7FFF)
                        abort string("EEPROM areas same")
                     ifnot fsrw.checkPresence(b)
                        abort string("No EEPROM there")
                     d := 0
                     if fsrw.readEEPROM(a+fsrw#vbase,@d,2)
                        abort string("Copy EEPROM read error")
                     repeat c from 0 to d - 1 step 32
                        if fsrw.readEEPROM(a+c,@f0,32<#(d-c))
                           abort string("Copy EEPROM read error")
                        if fsrw.writeEEPROM(b+c,@f0,32<#(d-c))
                           abort string("Copy EEPROM write error")
                        if fsrw.writeWait(b+c)
                           abort string("Copy EEPROM wait error")
            186: ' DUMP <expr>,<expr> or DUMP [<expr>],<expr>
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
            187: ' FERASE <expr>
               fsrw.eraseData(expr)
            189: ' FWRITE <expr> , <expr> , <expr>
               a := expr
               if spaces <> ","
                  abort @syn
               skipspaces
               b := expr
               if spaces <> ","
                  abort @syn
               skipspaces
               c := expr
               if c < 1 or c > 4
                  abort @syn
               fsrw.writeData(a,b,-c)
            192: ' SWRITE <expr> , <expr> , <expr>
               a := expr
               if spaces <> ","
                  abort @syn
               skipspaces
               b := expr
               if spaces <> ","
                  abort @syn
               skipspaces
               c := expr
               if c < 1 or c > 4
                  abort @syn
               fsrw.writeSRAM(a,b,-c)
      else
         abort(@syn)
      if spaces == ":"
         restart := 1
         tp++

pri doline(s) | c                 ' Execute the string in s or wait for input
   curlineno := -1
   if key.breakTest               ' Was the "break key" pressed?
      key.clearkeys               ' If so, clear the keyboard buffer
      key.breakCode(breakKey)     '  and reset the "break key"
      nextlineloc := eop-2        ' Stop the program
   if nextlineloc < eop-2
      curlineno := wordat(nextlineloc)
      tp := nextlineloc + 2
      nextlineloc := tp + strsize(tp) + 1
      texec
   else
      if fileOpened
         fileOpened := false
      pauseTime := 0
      repeat c from 0 to 15
         if outputs & |< c
            dira[c]~
            outa[c]~
      outputs := 0
      if s
         bytemove(tp:=@tline,s,strsize(s)+1)
      else
         putlinet(string(dsp#Esc,"[2zOK")) ' Reenable cursor
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
      a := 0
      repeat
         ifnot fsrw.readFile(@fcb,@c,1)
            abort string("Error reading file")
         if c == dsp#Cr or c == fEof
            tline[a] := 0
            tp := @tline
            quit
         elseif c == dsp#Lf
            next
         elseif c < 0
            quit
         elseif a < linelen-1
            tline[a++] := c
      if c == fEof and tline[0] == 0
         quit
      if c < 0
         abort string("Error while loading file")
      tp := @tline
      a := spaces
      if "0" =< a and a =< "9"
         insertline
         nextlineloc := eop - 2
      else
         if a <> 0
            abort string("Missing line number in file")

PRI processSave | a, c, d, ntoks
   ntoks := (@tokx - @toks) / 2
   a := long[userPtr]
   repeat while a+2 < eop
      d := wordat(a)
      fsrw.dec(d)
      fsrw.out(" ")
      d := a + 2
      repeat while c := byte[d++]
         if c => 128
            if (c -= 128) < ntoks
               fsrw.str(@@toks[c])
               if c <> 7   ' REM
                  fsrw.out(" ")
            else
               fsrw.out("{")
               fsrw.dec(c)
               fsrw.out("}")
         else
            fsrw.out(c)
      fsrw.out(dsp#Cr)
      fsrw.out(dsp#Lf)
      a += 3 + strsize(a+2)

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
'' The format is 8 bytes wide with hexadecimal and ASCII.  If the address
'' is greater than $7FFFFF, then it's treated as a flash memory address
'' that starts at $800000 (translated to $000000 to $7FFFFF).  If the
'' address is greater than $FFFF (and less than $800000), it's treated as
'' an SRAM address (translated to $0000 to $FFFF).
   first := true
   p := addr & $FFFFF8
   repeat while p < (addr + size)
      if first
         dsp.hex(addr,6)
         first := false
      else
         dsp.hex(p,6)
      dsp.out(":")
      repeat i from 0 to 7
         byte[@buf0][i] := " "
         if p => addr and p < (addr + size)
            c := 0
            if pin <> -1
               if fsrw.readEEPROM(pin|p,@c,1)
                  abort string("EEPROM read")
            else
               if p > $7FFFFF
                  fsrw.readData(p & $7FFFFF,@c,1)
               else
                  if p > $FFFF
                     fsrw.readSRAM(p & $FFFF,@c,1)
                  else
                     c := byte[p]
            dsp.hex(c,2)
            if c => " " and c =< "~"
               byte[@buf0][i] := c
         else
            dsp.out(" ")
            dsp.out(" ")
         if i < 7
            dsp.out(" ")
         p++
      buf2 := 0
      dsp.out("|")
      dsp.str(@buf0)
      dsp.out("|")
      dsp.str(string(dsp#Cr,dsp#Lf))

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
