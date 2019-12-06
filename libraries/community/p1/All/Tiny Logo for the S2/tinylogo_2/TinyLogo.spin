{{
----------------------------------------------------------------------------------------
File: TinyLogo.spin
Version: 1.02
Copyright (c) 2012 Michael Daumling
See end of file for terms of use.

This is a Tiny Logo interpreter for the S2. It contains a lot of commands, enables
procedure definitions with the TO command, and allows for downloads of precompiled
Logo programs. Because it is fairly large, it comes with two reduced versions of
S2.spin and S2Music.spin, where the song tables are removed. Adding own commands
is possible and recommended.

The software has not been tested in full yet. Please report any bugs to tinylogo@daumling.com.

Change list:

1.02: - MOTORS had a default argument count of 1 (should have been 2)

----------------------------------------------------------------------------------------
}}

CON

  _STACK        = 740
       
  'Clock setup
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  LOGO_VER_MAJOR = 1
  LOGO_VER_MINOR = 2

  MAX_INT       = 83_886
  MAX_NUM       = 83_886_07     ' $7fffff
  
  TEXT_SIZE     = 512           ' size of a text line
  PROGRAM_SIZE  = 512           ' size of the text line's program
  DATAHEAP_SIZE = 2048          ' data heap storage
  PROCHEAP_SIZE = 4096          ' procedure heap storage 
  ' The global table leaves about 100 entries after defining the primitives
  GLOBALS_SIZE  = Map#HDR_SIZE + 170 * Map#ELEM_SIZE
  ' The locals table takes max 15 elements we have max 15 arguments)
  LOCALS_SIZE   = Map#HDR_SIZE + 15 * Map#ELEM_SIZE
  STACK_SIZE    = 512

  VAL_NUM_BIT   = $80000000     ' value contains a number (value in low 24 bits)
  VAL_STR_BIT   = $40000000     ' value contains a string (addr of Pascal-style string in low word)
  VAL_LIST_BIT  = $20000000     ' value is a list (0-3 values, 0...254, 255 = no value)
  VAL_NAME_BIT  = $E0000000     ' a name
  VAL_PROC_BIT  = $10000000     ' value contains a procedure (proc addr in low word)
  VAL_PRIM_BIT  = $08000000     ' value contains a primitive (proc ptr in low word)
  VAL_EXEC_BIT  = $18000000     ' a procedure
  VAL_HANDLE_BIT= $04000000     ' value is a handle instead of an address
  VAL_HIDE_BIT  = $02000000     ' do not list this primitive
  VAL_FLAGS     = $FF000000
  VAL_NUM       = $00FFFFFF     ' mask for a number
  VAL_STR       = $0000FFFF     ' mask for a pstring address
  VAL_PROC      = $0000FFFF     ' mask for a proc address or proc data structure
  VAL_ARGC      = $000F0000     ' mask for argument count for procs 
  
  VAL_SHIFT_ARGC = 16

  GFLAG_PROMPT  = $01           ' issue prompt and echo
  
                                ' settable via TRACE
  DFLAG_TRACE      = $01        ' trace enter/exit
  DFLAG_TRACE_LINE = $02        ' trace each line
  DFLAG_TRACE_OP   = $04        ' trace each token
    
OBJ
  s2            : "s2Mini"
  music         : "s2_musicMini"
  map           : "Map"
  mem           : "Heap"
  serial        : "FullDuplexSerialPlus"
  
VAR  
  BYTE  prog[PROGRAM_SIZE]      ' toplevel program buffer
  ' The following two variables are used during parsing. When parsing
  ' a toplevel command, they point into and behind prog; when parsing
  ' a function definition during TO, they point into and behind the
  ' allocated buffer on the heap.
  WORD  progEnd                 ' pointer to end of program during run
  WORD  progBufEnd              ' end of program buffer

  WORD  ip                      ' pointer to current token while running
  BYTE  text[TEXT_SIZE]
  LONG  textp

  ' The globals map contains LONG values, with mask bits and values
  ' as defined as the VAL_XXXX constants above. The buffer must be long
  ' aligned. Data found here is:
  ' numbers:          VAL_NUM_BIT + the number (24 bits signed)
  ' strings:          VAL_STR_BIT + the string
  ' primitives:       VAL_PRIM_BIT + the primitive address inside the "builtins" table
  ' procedures:       VAL_PROC_BIT + the handle of the procedure
  ' For strings, VAL_HANDLE_BIT can be set; in that case, the string addr is a handle
  LONG  globals[GLOBALS_SIZE/4]
  ' The data heap holds strings, and temporary locals maps during the
  ' compilation of a procedure. Its contents may shift anytime.
  WORD  data_heap[DATAHEAP_SIZE/2]
  ' The procedure heap holds all user procedures. The contents of this heap
  ' only shift during the ER command or the redefinition of a procedure;
  ' both commands are only allowed at toplevel (ala a NULL proc_fp)
  WORD  proc_heap[PROCHEAP_SIZE/2]

  BYTE  logo_flags              ' global Logo flags
  BYTE  debug_flags             ' debug Logo flags
  BYTE  error_flag              ' set if Logo aborted
  BYTE  current_spd             ' need to track this S2 value
  
PUB start 
'' Start hardware driver cogs and low level routines
  s2.start 
  s2.start_motors
  s2.start_tones
  s2.button_mode(true, true)   
  s2.set_voices(s2#SIN,s2#SIN)
  s2.set_volume(90)
  s2.here_is(0, 0)
  s2.heading_is_deg(0)
  serial.start(s2#RX, s2#TX, 0, 115200)
    
  ' Initialize Logo
  current_spd := 7
  init
  debug_flags~
  battery_min := $FF

  play_chord
  ' Wait for a CR
  repeat
    case rx
      $0d:
        logo_flags |= GFLAG_PROMPT
        ' Send the initial prompt, 16 = clear screen
        tx(16)
        tx(13)
        str(string("Tiny Logo V"))
        print_value(constant(VAL_NUM_BIT + (LOGO_VER_MAJOR) * 100 + LOGO_VER_MINOR))
        crlf
        quit
      $04:
        connect
        quit
      $05:
        disconnect
        quit

  repeat
    if \read_line(logo_flags & GFLAG_PROMPT)
      run_program

DAT
{{
The list of built-in commands; the map entry for a primitive is a ptr to that entry.
The order of commands is not accidental, but has been produced by a utility that
created an AVL tree and then dumped it. This order forms a tree that is initially
balanced (except for the optional debugging commands),

Each entry has the following layout:

        DB opcode
        DB flagsAndArgc
        DB lenOfName
        DB name[lenOfName]

The flagsAndArgc byte has the default argument count in the low 4 bits 0-3. Bits 4 and 5
contain the operator precedence weight for infix operators. Bit 7, if set, hides the entry
from being listed with the POPRS command.
}} 
builtins
              BYTE     cMAKE,     2, 4,"MAKE"
              BYTE       cNE,   $32, 2,"<>"
              BYTE   cDOWNLD,   $81, 7,".DOWNLD"        ' do not list
              BYTE      cADD,   $42, 1,"+"
              BYTE      cMUL,   $52, 1,"*"
              BYTE      cMOD,   $52, 1,"%"
              BYTE      cSUB,   $42, 1,"-"
              BYTE   cPROMPT,   $81, 7,".PROMPT"        ' do not list
              BYTE     cHEAP,   $81, 5,".HEAP"          ' DEBUG do not list 
              BYTE     cDUMP,   $81, 5,".DUMP"          ' DEBUG do not list
              BYTE      cMAP,   $80, 4,".MAP"           ' DEBUG do not list 
              BYTE       cLT,   $32, 1,"<"
              BYTE      cDIV,   $52, 1,"/"
              BYTE       cLE,   $32, 2,"<="
              BYTE   cLOGAND,     2, 3,"AND"
              BYTE       cGT,   $32, 1,">"
              BYTE       cEQ,   $32, 1,"="
              BYTE       cGE,   $32, 2,">="
              BYTE     cBATT,     0, 4,"BATT"           ' S2
              BYTE       cBK,     1, 2,"BK"             ' S2
              BYTE      cARC,     2, 3,"ARC"            ' S2
              BYTE     cBEEP,     0, 4,"BEEP"           ' S2
              BYTE       cBT,     0, 2,"BT"
              BYTE       cIF,     1, 2,"IF"
              BYTE    cERALL,     0, 5,"ERALL"
              BYTE      cEND,     0, 3,"END"
              BYTE      cCOS,     1, 3,"COS"
              BYTE  cCOUNTDN,     1, 9,"COUNTDOWN"      ' S2
              BYTE       cER,     1, 2,"ER"
              BYTE       cFD,     1, 2,"FD"             ' S2
              BYTE     cITEM,     2, 4,"ITEM"
              BYTE   cBITAND,     2, 6,"LOGAND"
              BYTE    cBITOR,     2, 5,"LOGOR"
              BYTE    cLIGHT,     0, 7,"S.LIGHT"        ' S2
              BYTE   cLIGHTS,     3, 6,"LIGHTS"         ' S2
              BYTE       cLN,     0, 6,"S.LINE"         ' S2
              BYTE   cBITNOT,     1, 6,"LOGNOT"
              BYTE      cLSH,     2, 3,"LSH"
              BYTE   cBITXOR,     2, 6,"LOGXOR"
              BYTE     cLEFT,     1, 2,"LT"             ' S2
              BYTE     cPONS,     0, 4,"PONS"
              BYTE    cLOGOR,     2, 2,"OR"
              BYTE   cLOGNOT,     1, 3,"NOT"
              BYTE      cMEM,     0, 3,"MEM"
              BYTE   cMOTORS,     2, 6,"MOTORS"         ' S2
              BYTE   cMOVING,     0, 7,"MOVING?"        ' S2
              BYTE     cOBST,     0,10,"S.OBSTACLE"     ' S2
              BYTE    cNOTES,     3, 5,"NOTES"          ' S2
              BYTE   cOUTPUT,     1, 2,"OP"
              BYTE       cPO,     1, 2,"PO"
              BYTE    cPOALL,     0, 5,"POALL"
              BYTE      cSIN,     1, 3,"SIN"
              BYTE    cPRINT,     1, 2,"PR"
              BYTE     cPOPS,     0, 4,"POPS"
              BYTE    cPOPRS,     0, 5,"POPRS"
              BYTE    cRIGHT,     1, 2,"RT"             ' S2
              BYTE   cREPEAT,     1, 6,"REPEAT"
              BYTE    cSPEED,     1, 8,"SETSPEED"       ' S2
              BYTE    cTHING,     1, 5,"THING"
              BYTE  cSTALLED,     0, 8,"STALLED?"       ' S2
              BYTE     cSQRT,     1, 4,"SQRT"
              BYTE     cSTOP,     0, 4,"STOP"
              BYTE    cTRACE,     1, 5,"TRACE"
              BYTE       cTO,     0, 2,"TO"
              BYTE    cTIMER,     0, 5,"TIMER"          ' S2
              BYTE   cTOPLVL,     0, 8,"TOPLEVEL"
              BYTE    cWHILE,     0, 5,"WHILE"

              BYTE         0

PRI connect
  logo_flags &= !GFLAG_PROMPT
  str(@str_ok)
  print_value(constant(VAL_NUM_BIT + (LOGO_VER_MAJOR) * 100 + LOGO_VER_MINOR))
  crlf
  s2.set_leds(s2#OFF, s2#OFF, s2#OFF, s2#NO_CHANGE)
  music.play_note(music#THSC,music#C4,0)
  music.play_note(music#THSC,music#G4,0)
  textp := @text

PRI disconnect
  logo_flags |= GFLAG_PROMPT
  s2.set_leds(s2#OFF, s2#OFF, s2#OFF, s2#NO_CHANGE)
  music.play_note(music#THSC,music#G4,0)
  music.play_note(music#THSC,music#C4,0)   
  textp := @text
   
PRI init | p, elem, val
  clear
  mem.init(@data_heap, DATAHEAP_SIZE)
  mem.init(@proc_heap, PROCHEAP_SIZE)
  map.init(@globals, GLOBALS_SIZE, @data_heap)
  parse_init(@prog, @prog + PROGRAM_SIZE)
  ' fill in the globals for the built-in procedures
  p := @builtins
  repeat while byte[p]
    elem := map.find(@globals, p+2, Map#STATIC)
    val := VAL_PRIM_BIT + byte[p] + ((byte[p+1] & $7F) << VAL_SHIFT_ARGC)
    if byte[p+1] & $80
      val |= VAL_HIDE_BIT
    map.set_value(elem, val)
    p += byte[p][2] + 3
  
PRI clear
  fp~
  error_flag~
  stack_top := @stack
  textp := @text
  ip := @prog
    
PRI run_program
  clear
  parse_init(@prog, @prog + PROGRAM_SIZE)
  if \parse_line
    store_primitive(cSTOP)
    \run

CON
{{
        The parser
}}  

  #0
  cNUM0                 ' integers numbers from 0 to 127
  #$80
  cNUM1         = $80   ' numbers from 0.00 to 2.55 are encoded in 1 byte
  cNUM2         = $81   ' numbers from 2.56 to 655.35 are encoded in 2 bytes
  cNUM3         = $82   ' numbers from 655.36 to MAX_NUM are encoded in 3 bytes
  cSTR          = $83   ' a byte plus the string follows
  cPROC         = $84   ' a byte plus the name follows
  cNAME         = $85   ' a byte plus the name follows
  cOPAR         = $86   ' (, size size of the list follows (2 bytes) so we can skip
  cCPAR         = $87   ' )
  cOBRK         = $88   ' [, size size of the list follows (2 bytes) so we can skip
  cCBRK         = $89   ' ]
  cLINE         = $8A   ' line number follows as byte
  cREC          = $8B   ' recursive call
  cLGET         = $8C   ' local fetch, 0-based index follows
  cLSET         = $8D   ' local store, 0-based index follows
  cDEF          = $8E   ' download: define a proc; followed by argc, procname, size as word, data, CRC
  
  #$90
  cFIRST_PRIM
  #$90
  cTO,cEND,cSTOP,cOUTPUT,cMEM,cDOWNLD,cPRINT,cTRACE
  cBT,cPROMPT,cMUL,cDIV,cMOD,cADD,cSUB,cEQ
  cNE,cLT,cGT,cLE,cGE,cLSH,cBITAND,cBITOR
  cBITXOR,cBITNOT,cLOGAND,cLOGOR,cLOGNOT,cSIN,cCOS,cSQRT
  cMAKE,cTHING,cPO,cPOALL,cPONS,cPOPS,cPOPRS,cER
  cERALL,cIF,cREPEAT,cWHILE,cTOPLVL,cITEM
  
  ' S2 specific commands
  #$D0
  cLIGHT,cLN,cOBST,cSPEED,cFD,cBK,cLEFT,cRIGHT
  cARC,cTIMER,cSTALLED,cMOVING,cBEEP,cNOTES,cLIGHTS,cCOUNTDN
  cMOTORS,cBATT

' _DEBUG
  #$F0
  cDUMP,cMAP,cHEAP
  cDEBUG_1 = cDUMP
' END _DEBUG

  cLAST_PRIM = cHEAP

{{
Read a line of input from the console and store that line in prog. Interpret the backspace character.
Echo the characters and print a prompt if echo is TRUE. Returns the text ptr of 0 on buffer overrun.
Convert the input to upper case except for characters enclosed in '|'. Throws or returns TRUE.
}}
PRI read_line(echo) | ch
' Read a line or a program
  textp := @text
  if echo
    if to_name
      pstr(to_name)
    str(string("> "))
  repeat
    ch := read(echo)
    if ch == $0D
      if echo
        crlf
      byte[textp] := 0
        return TRUE
    elseif ch == "|"
      store(ch, echo)
      repeat
        ch := read(echo)
        store(ch, echo)
      until (ch == "|") OR (ch == $0D)
    else
      if (ch => "a") AND (ch =< "z")
        ch -= 32
      store(ch, echo)
       
PRI read(echo) | ch
  ' Read a single character, interpret backspaces, and check for battery and overcurrent
  repeat
    repeat while (ch := rxtime(200)) < 0
      battery_check
      oc_check
    ' Ctrl-D switches to condensed mode, prints the
    ' Logo version and reenters the line
    if ch == $04
      connect
    elseif ch == $05
      disconnect
    elseif (ch == $08) OR (ch == $7F)
      if textp > @text
        textp--
        if echo
          tx(8)
          tx(" ")
          tx(8)
    else
      return ch
     
PRI store(ch, echo)
  ' Store a single character; print a message and return FALSE if the buffer is exhausted
  byte[textp] := ch
  if echo
    tx(ch)
  if ++textp => (@text + TEXT_SIZE)
    error(@err_text_too_large)

PRI parse_init(where, end)
'
'' Setup the parsing pointers.
'' @where    the pointer to the buffer that takes the code
'' @end      the pointer to the first byte behind that buffer
'
  textp := @text
  progEnd := where
  progBufEnd := end

PRI parse_line
'
'' Parse the line at textp into the given buffer. Either throws or returns TRUE.
'
  textp := @text
  repeat while byte[textp]
    parse_token
  return TRUE

PRI parse_token | ch, bgn, p
'
'' Parse a single token into the current buffer.
'' May abort.
'
  ' skip whitespace
  repeat while ch := BYTE[textp++]
    ifnot lookdown(ch: " ", 9)
      quit
      
  bgn := progEnd
  case ch
    ";":
      byte[textp]~
    $00,$0d:
      bytecode_error
    $22:
      parse_word(cSTR)
    "(":
      parse_list(cOPAR, cCPAR, ")")
    "[":
      parse_list(cOBRK, cCBRK, "]")
    ")","]":
      bracket_error(@err_too_many_brackets, ch)
    ":":
      parse_word(cNAME)
      if to_locals
        compile_name(bgn)

    "+","-":
      if (BYTE[textp] => "0" and BYTE[textp] =< "9")
        textp--
        store_number(parse_number(10))
      else
        p := 1 + (ch << 8)
        store_primitive(map.get(@globals, @p))
        
    "*","/","=","%":
      ' fake a string in p (Propeller is little endian)
      p := 1 + (ch << 8)
      store_primitive(map.get(@globals, @p))
       
    "<":
      ' fake a string in p (Propeller is little endian)
      if lookdown(byte[textp]: "=",">","<")
        p := 2 + ("<" << 8) + (byte[textp++] << 16)
      else
        p := 1 + (ch << 8)
      store_primitive(map.get(@globals, @p))
      
    ">":
      ' fake a string in p (Propeller is little endian)
      if lookdown(byte[textp]: "=",">")
        p := 2 + (">" << 8) + (byte[textp++] << 16)
      else
        p := 1 + (ch << 8)
      store_primitive(map.get(@globals, @p))
             
    "#":
      case byte[textp]
        "D": ch := 10
        "H": ch := 16
        "O": ch := 8
        "B": ch := 2
        other: error(@err_bad_num_base)
      textp++
      store_number(parse_number(ch))
      
    "0".."9":
      textp--
      store_number(parse_number(10))
        
    other:
      textp--
      parse_word(cPROC)
      ' check if this is a primitive
      ch := map.get(@globals, bgn+1)
      if (ch & VAL_PRIM_BIT)
        progEnd := bgn
        ' If this is an MAKE opcode, compile separately
        if (ch & VAL_PROC) == cMAKE
          compile_make
        else
          ' store the opcode
          store_primitive(ch)
      elseif to_locals
        compile_proc(bgn)

  return bgn

PRI store_primitive(val)
  check_space(2)
  byte[progEnd++] := val                     ' opcode     
  byte[progEnd++] := val >> VAL_SHIFT_ARGC   ' argc plus weight 
   
PRI parse_list(op, endop, end) | p
'
'' Parse a (list) or a [list]
'
  check_space(3)
  byte[progEnd++] := op
  p := progEnd
  progEnd += 2
  repeat while byte[textp] <> end
    ifnot byte[textp]
      bracket_error(@err_bracket, end)
    parse_token
  textp++
  store_opcode(endop)
  endop := progEnd - p - 2
  byte[p++] := endop
  byte[p++] := endop >> 8
  
PRI parse_number(base) | n, frac, digit, fracdigits, decpoint, sign
  n~
  frac~
  fracdigits~
  decpoint~
  sign := 1
  case byte[textp]
    "-": textp++
         sign := -1
    "+": textp++
    
  repeat
    if byte[textp] == "."
      if decpoint
        error(@err_bad_digit)
      decpoint++
      textp++
    digit := byte[textp]
    if is_separator(digit)
      quit
    if (digit => "0") and (digit =< "9")
      digit -= "0"
    elseif (digit => "A") and (digit =< "F")
      digit -= "7"
    if digit => base
      error(@err_bad_digit)
    textp++
    if decpoint
      if ++fracdigits < 4
        frac := frac * base + digit
    else
      n := n * base + digit
      if n > MAX_INT
        error(@err_overflow)
        
  repeat while ++fracdigits < 4
    frac *= 10
  if frac // 10 => 5
    frac += 10
  n *= sign
  result := n * 100 + frac / 10 

PRI store_number(n)
  if n > 0
    if (n < 12800) and not (n // 100)
      check_space(1)
      byte[progEnd++] := n / 100
      return
    elseif n =< $ff
      check_space(2)
      byte[progEnd++] := cNUM1
      byte[progEnd++] := n
      return
    elseif n =< $ffff
      check_space(3)
      byte[progEnd++] := cNUM2
      byte[progEnd++] := n
      byte[progEnd++] := n >> 8
      return
  check_space(4)
  byte[progEnd++] := cNUM3
  byte[progEnd++] := n
  byte[progEnd++] := n >> 8
  byte[progEnd++] := n >> 16
   
PRI parse_word(token) | ch, ch1, p, len
  p := textp
  len~
  if byte[textp] == "|"
    textp++
    p++
    repeat while not lookdown(byte[textp]:"|","0",$0d)
      textp++
    len := textp - p
    if byte[textp] == "|"
      textp++
  else
    repeat
      ch := byte[textp]
      if is_separator(ch)
        quit
      textp++
    len := textp - p
    
  if len > 255
    error(@err_word_too_long)
          
  check_space(len + 2)
  byte[progEnd++] := token
  byte[progEnd++] := len
  bytemove(progEnd, p, len)
  progEnd += len

PRI compile_name(p) | val
'
'' Attempt to compile a cNAME opcode into a cLGET opcode by looking up
'' the name in the to_locals map, which, of course, must exist.
'' @p    points to teh cNAME opcode
' 
  val := map.get(mem.deref(@data_heap, to_locals), p+1)
  if val
    ' If so, replace with cLGET and remove the string
    byte[p++] := cLGET
    byte[p++] := val - 1
    progEnd := p

PRI compile_proc(p)
'
'' Attempt to compile a cPROC opcode into a cREC opcode for a recursive
'' (and potentially tail recursive) call by comparing the string to to_name,
'' which, of course, must exist.
'' @p   points to the cPROC opcode
  if streq(to_name, p+1)
    byte[p] := cREC
    progEnd := p + 1
   
PRI compile_make | p, bgn, val
'
'' Attempt to compile the first argument to an MAKE opcode into the
'' 0-based index of the local variable to set. It calls eval(0) to
'' get to the argument, which in turn should return a cSTR opcode.
'' eval checks the 1st arg of cMAKE to be a cSTR opcode.
'
  check_space(2)
  bgn := progEnd
  byte[progEnd++] := cMAKE
  byte[progEnd++] := 2       ' argc for cMAKE
  ' next must be a string
  p := parse_token
  if (byte[p] == cSTR) and to_locals
    val := map.get(mem.deref(@data_heap, to_locals), p+1)
    if val
      ' it is a local variable; store the index as token
      byte[bgn] := cLSET
      byte[bgn+1] := val-1
      progEnd := p
   
PRI is_separator(ch)
  result := lookdown(ch: 0, 9, 13, $22, " ",":",";","+","-","*","/","=","%","<",">","#","(",")","[","]")
  
PRI check_space(n)
  if (progEnd + n) => progBufEnd
    error(@err_no_memory)

PRI store_opcode(opcode)
  check_space(1)
  byte[progEnd++] := opcode

CON
  MOTOR_OC_TRIP             = 210                   'Motor driver over current level
                                                    'Battery minimum detection levels
  BATTERY_LOW_TRIP          = (700*2550)/(400*33)   '7.0V
  BATTERY_DEAD_TRIP         = (600*2550)/(400*33)   '6.0V 

VAR
  BYTE  battery_min

PRI oc_check
  ''Check for a hardware motor driver over current condition
  ''An OC condition is indicated by blinking Red LED's
  ''and the speaker beeping every 10 seconds.
  
  if s2.get_adc_results(s2#ADC_IMOT) > MOTOR_OC_TRIP
    s2.start 
    s2.start_tones
    s2.set_leds(s2#BLINK_RED,s2#BLINK_RED,s2#BLINK_RED,s2#OFF)
    repeat
      s2.beep
      s2.delay_tenths(100) 

PRI battery_check : sample
  ''Set the power LED corresponding to the battery voltage level

  sample := s2.get_adc_results(s2#ADC_VBAT)
  if sample < battery_min                                                 'Save the lowest battery
    battery_min := sample                                                 'voltage detected

  if battery_min > BATTERY_LOW_TRIP
    s2.set_led(s2#POWER,s2#BLUE)
  elseif battery_min > BATTERY_DEAD_TRIP
    s2.set_led(s2#POWER,s2#DIM_BLUE)
  else
    s2.set_led(s2#POWER,s2#BLINK_BLUE)

CON

{{
The VM operates with stack frames. Initially, the frame does not contain space
for locals. eval_args() fills in the frame and lets it grow accordingly.
After eval_args() has finished, argc contains number of arguments only. Max 15
argumentsare possible.

The instruction pointer for a user proc is in the frame as an offset. This is
necessary because the handle-absed memory of a proc may move while the proc is
executed.

        WORD    last            ' pointer to last frame
        WORD    last_proc       ' pointer to last proc frame
        WORD    procName        ' address of procedure name (0 for primitives)
        WORD    proc            ' handle for user defined procs
        BYTE    procID          ' primitive proc ID
        BYTE    level           ' the stack level
        BYTE    argc            ' number of arguments
        BYTE    stop_flag       ' TRUE to stop a proc
        LONG    locals[n]       ' space for arguments
}}

  FP_LAST       = 0             ' word
  FP_LAST_PROC  = 1             ' word
  FP_NAMEHANDLE = 2             ' word
  FP_PROCHANDLE = 3             ' word
  FP_PROCID     = 8             ' byte
  FP_LEVEL      = 9             ' byte
  FP_ARGC       = 10            ' byte
  FP_STOP       = 11            ' byte
  FP_LOCALS     = 3             ' long
  FP_LOCALS_OFF = 12            ' offset

VAR
        LONG    stack[STACK_SIZE/4] ' must be LONG aligned
        WORD    fp, stack_top       ' frame pointer
        WORD    proc_fp             ' frame pointer for user defined procs
        
PRI run
  ip := @prog
  fp~
  proc_fp~
  error_flag~
  stack_top := @stack
  repeat while byte[ip] <> cSTOP
    result := \eval(0)
    if result or error_flag
      quit
  ifnot error_flag
    ' if the result is 16 bit, it is a string that someone threw
    if result and not (result & $FFFF0000)
      str(@ErrorMsg)
      str(result)
      \error_end
    elseif result <> $FFFFFFFF
      ' $FFFFFFFF is the value that DOWNLD or $ERALL throw
      print_result(result)
  error_flag~
    
PRI eval(weight) | val, elem, op
'
' Run a single opcode or procedure call, and return the result
'
  val~
  print_opcode
  case op := byte[ip++]
    cLINE:    if rxcheck == $03
                stopped
              trace_line(byte[ip++])
              return 0
    cLGET:    ifnot proc_fp
                bytecode_error
              val := long[proc_fp][FP_LOCALS + byte[ip++]]
    cLSET:    ifnot proc_fp
                bytecode_error
              op := byte[ip++]  
              long[proc_fp][FP_LOCALS + op] := eval(0)
    cOBRK:    ip--
              val := eval_list(TRUE, 0)       
    cOPAR:    val := eval_plist
    0..127:   val := VAL_NUM_BIT + (op * 100)
    cNUM1:    val := VAL_NUM_BIT + byte[ip++]
    cNUM2:    val := VAL_NUM_BIT + byte[ip++] + (byte[ip++] << 8)
    cNUM3:    val := VAL_NUM_BIT + byte[ip++] + (byte[ip++] << 8) + (byte[ip++] << 16)
    cSTR:     val := VAL_STR_BIT + ip
              ip += byte[ip] + 1
    cNAME:    val := map.get(@globals, ip)
              ifnot val & VAL_NAME_BIT
                str_error(ip, @err_not_a_name)
              ip += byte[ip] + 1  
    cPROC:    elem := map.find(@globals, ip, Map#DONT_CREATE)
              val := map.value(elem)
              ifnot val & VAL_EXEC_BIT
                str_error(ip, @err_not_a_proc)
              if val & VAL_PRIM_BIT
                bytecode_error                                  ' cannot be a primitive
              ip += byte[ip] + 1
              new_frame
              word[fp][FP_NAMEHANDLE] := map.key_handle(elem)       
              eval_args((val & VAL_ARGC) >> VAL_SHIFT_ARGC)
              val := run_procedure(val & VAL_PROC)
    cREC:     ' recursive call of current frame
              ' Set up a new frame, and eval all args
              op := fp
              val := byte[op][FP_ARGC]
              new_frame
              word[fp][FP_NAMEHANDLE] := word[op][FP_NAMEHANDLE]
              word[fp][FP_PROCHANDLE] := word[op][FP_PROCHANDLE]        
              eval_args(val)
              ' if we are out of code, this is tail recursion
              ' every proc ends with cSTOP
              ' skip any line opcodes
              elem := ip
              repeat while byte[elem] == cLINE
                elem += 2
              if lookdown(byte[elem]: cSTOP,cOUTPUT)
                ' copy the args of the new frame to the old location
                ' and forget about the new frame
                bytemove(op + FP_LOCALS_OFF, fp + FP_LOCALS_OFF, val<<2)
                stack_top := fp
                fp := op
                byte[fp][FP_ARGC] := val
                byte[fp][FP_STOP]~
                val~
                ' Set the IP to the start of the proc
                ip := mem.deref(@proc_heap, word[fp][FP_PROCHANDLE])
                trace_enter(TRUE)
              else
                val := run_procedure(word[fp][FP_PROCHANDLE])
    other:    if op < cFIRST_PRIM or op > cLAST_PRIM
                bytecode_error
              new_frame
              byte[fp][FP_PROCID] := op
              ' check if the 1st argument to MAKE is a cSTR
              if (op == cMAKE) and (byte[ip+1] <> cSTR)
                proc_error(@err_needs_name, 1)
              eval_args(byte[ip++] & $0F)                ' argc
              val := run_primitive(op)                   ' opcode
                                 

  ' check for infix operators following
  repeat
    op := byte[ip]
    if op < cFIRST_PRIM or op > cLAST_PRIM
      return val
    if (byte[ip+1] & $f0) =< weight
      return val
    ' OK, we have an infix operator with a higher weight
    print_opcode
    new_frame
    byte[fp][FP_PROCID] := op
    ip++
    push_arg(val)
    push_arg(eval(byte[ip++] & $f0))
    val := run_primitive(op)

PRI eval_list(do_eval, argnum) | nextp
'
'' Eval a [runlist], and leave ip behind the list
'' ip points to cOBRK
'
  nextp := skip_list(argnum)
  ip += 3
  if do_eval
    repeat while (not result) and (byte[ip] <> cCBRK)
      result := eval(0)
  ip := nextp

PRI skip_list(argnum)
' Return the IP value that would point IP behind a list
  if byte[ip] <> cOBRK
    proc_error(@err_needs_list, argnum)
  result := ip + (byte[ip+1] + (byte[ip+2] << 8)) + 3
   
PRI eval_plist | op, val, elem
  '
  '' Eval a (runlist): collect all arguments for a procedure call,
  '' or run ist as a list if not; ip points to byte behind cOPAR
  '
  ' skip the size
  ip += 2
  op := byte[ip++]
  if op == cPROC
    ' a procedure; ip points to the name
    elem := map.find(@globals, ip, Map#DONT_CREATE)
    val := map.value(elem)
    ifnot (val & VAL_EXEC_BIT)
      str_error(ip, @err_not_a_proc)
    new_frame
    word[fp][FP_NAMEHANDLE] := map.key_handle(elem)
    ip += byte[ip] + 1
    eval_all_args
    if byte[fp][FP_ARGC] < ((val & VAL_ARGC) >> VAL_SHIFT_ARGC)
      proc_error(@err_needs_more_inputs, 0)
    result := run_procedure(val)
  elseif op < cFIRST_PRIM or op > cLAST_PRIM
    ' (expression)
    ip--
    repeat while byte[ip] <> cCPAR
      result := eval(0)
      if result
        quit
    if byte[ip] == cCPAR
      ip++
  else
    ' a primitive; skip argc - we eval all args
    ip++
    new_frame
    byte[fp][FP_PROCID] := op
    eval_all_args
    result := run_primitive(op)

PRI eval_args(args)
'
'' Fill in the arguments for this frame.
'
  byte[fp][FP_ARGC]~
  repeat args
    if lookdown(byte[ip]: cSTOP,cOUTPUT,cCPAR,cCBRK,cLINE)
      proc_error(@err_needs_more_inputs, 0)
    push_arg(eval(0))

PRI eval_all_args
'
'' Fill in the arguments for this frame, but eval them until a ")" is found.
'
  byte[fp][FP_ARGC]~
  repeat
    if byte[ip] == cCPAR
      ' end of PLIST collection
      ip++
      return
    push_arg(eval(0))

PRI push_arg(val) | argnum
  argnum := byte[fp][FP_ARGC]
  ifnot val
    proc_error(@err_no_value, argnum+1)
  if argnum > 15
    proc_error(@err_too_many_args, 0)
  if (stack_top + 4) > (@stack + STACK_SIZE)
    error(@err_stack_overrun)
  stack_top += 4
  long[fp + FP_LOCALS_OFF][argnum++] := val
  byte[fp][FP_ARGC] := argnum
      
PRI argc
  return byte[fp][FP_ARGC]
  
PRI arg(n)
  if n > byte[fp][FP_ARGC]
    proc_error(@err_needs_more_inputs, 0)
  result := long[fp + FP_LOCALS_OFF - 4 + n*4]
  if result & VAL_HANDLE_BIT
    result := (result & $FFFF0000) | mem.deref(@data_heap, result)
  
PRI str_arg(n)
  result := arg(n)
  ifnot (result & VAL_STR_BIT)
    proc_error(@err_needs_name, n)
  result &= VAL_STR
          
PRI num_arg(n)
  result := arg(n)
  ifnot (result & VAL_NUM_BIT)
    proc_error(@err_needs_number, n)
  result := num_val(result)

PRI num_val(n)
  n &= VAL_NUM
  if n & $800000
    n |= $FF000000
  return n

PRI int_val(n) | sign
  sign := 1
  if n < 0
    n := -n
    sign := -1
  if (n // 100) => 50
    n += 100
  return (n / 100) * sign

PRI int_arg(n)
  result := int_val(num_arg(n))
  
PRI int_arg_rng(n, minn, maxx)
  result := int_arg(n)
  if (result < minn) or (result > maxx)
    proc_error(@err_out_of_range, n)
          
PRI to_num(n)
  if (n < -MAX_NUM) or (n > MAX_NUM)
    error(@err_overflow)
  result := (n & VAL_NUM) | VAL_NUM_BIT

PRI to_int(n)
  result := to_num(n * 100)

PRI to_list(n1, n2, n3)
' Convert the given three bytes to a list
  result := VAL_LIST_BIT | ((n1 & $FF) << 16) | ((n2 & $FF) << 8) | (n3 & $FF)
  
PRI new_frame | last
'
' Allocate a new frame, but do not allocate any args yet
'
  if (stack_top + FP_LOCALS_OFF) > (@stack + STACK_SIZE)
    proc_error(@err_stack_overrun, 0)
  last := fp
  fp := stack_top
  stack_top += FP_LOCALS_OFF
  long[fp][0]~
  long[fp][1]~
  long[fp][2]~
  word[fp][FP_LAST] := last
  if last
    byte[fp][FP_LEVEL] := byte[last][FP_LEVEL]+1

PRI drop_frame(val)
'
' drop the current frame
'
  if fp
    trace_exit(val)
    if fp == proc_fp
      ' restore the proc frame chain if this frame is a proc frame
      proc_fp := word[fp][FP_LAST_PROC]
    stack_top := fp
    fp := word[fp][FP_LAST]

PRI proc_name(f)
  ifnot f
    result := @pstr_toplevel
  elseif word[f][FP_NAMEHANDLE]
    result := map.key_deref(@globals, word[f][FP_NAMEHANDLE])
  else
    result := get_primitive(byte[f][FP_PROCID])    

VAR
  ' The following data is global to this object because it must
  ' be cleaned up in case of errors. The error_end method does this
  ' before aborting.
  WORD  to_handle     ' handle to proc_heap memory
  WORD  to_name       ' procedure name for the prompt
  WORD  to_locals     ' map for local variables in data_heap
  
PRI run_procedure(h) | retaddr, myfp
'
'' Run a user defined procedure. h is the handle to the proc.
'
  trace_enter(FALSE)
  myfp := fp
  word[fp][FP_LAST_PROC] := proc_fp
  word[fp][FP_PROCHANDLE] := h
  byte[fp][FP_STOP]~
  proc_fp := fp
  retaddr := ip
  ip := mem.deref(@proc_heap, h)
  repeat while not result and not byte[myfp][FP_STOP]
    result := eval(0)
  if result and not byte[myfp][FP_STOP]
    value_error(result)
  fp := myfp
  drop_frame(result)
  ip := retaddr

PRI run_primitive(id)
  trace_enter(FALSE)
  case id
    cTO:                        _to
    cEND:                       proc_error(@err_procedure, 0)
    cOUTPUT:                    result := _output
    cSTOP:                      _stop
    cDOWNLD:                    _downld
    cMEM:                       result := _mem
    cPRINT:                     _print
    cTRACE:                     debug_flags := int_arg_rng(1, 0, 255)
    cMAKE:                      _make
    cPOALL:                     print_map(@globals, VAL_NAME_BIT | VAL_EXEC_BIT)
    cPONS:                      print_map(@globals, VAL_NAME_BIT)   
    cPOPS:                      print_map(@globals, VAL_PROC_BIT)   
    cPOPRS:                     print_map(@globals, VAL_PRIM_BIT)
    cER:                        _er
    cERALL:                     _erall   
    cTHING:                     result := _thing
    cMUL:                       result := _mul
    cDIV,cMOD:                  result := _divmod(id)
    cADD:                       result := _add
    cSUB:                       result := _sub
    cEQ..cGE:                   result := compare(id)
    cLSH..cBITNOT:              result := _bitops(id)
    cLOGAND..cLOGNOT:           result := _boolops(id)
    cSIN:                       result := _sin
    cCOS:                       result := _cos
    cSQRT:                      result := _sqrt
    cIF:                        result := _if
    cITEM:                      result := _item
    cREPEAT:                    result := _repeat
    cBT:                        print_stack(FALSE)
    cPO:                        _po
    cPROMPT:                    _prompt
    cWHILE:                     _while
    cTOPLVL:                    abort 0
    ' S2 commands
    cSPEED:                     _speed
    cLEFT:                      s2.turn_by_deg(int_arg(1) // 360)
                                s2.wait_stop
    cRIGHT:                     s2.turn_by_deg(-int_arg(1) // 360)
                                s2.wait_stop
    cFD:                        s2.go_forward(s2_distance(1))
                                s2.wait_stop
    cBK:                        s2.go_forward(-s2_distance(1))
                                s2.wait_stop
    cARC:                       _arc
    cTIMER:                     result := _timer
    cBEEP:                      s2.beep
    cNOTES:                     s2.play_tone(int_arg_rng(3, 1, 8191), int_arg_rng(1,0,10000), int_arg_rng(2,0,10000))
    cMOTORS:                    _motors
    cLIGHTS:                    _lights
    cBATT:                      result := _batt
    cLIGHT:                     result := _light
    cLN:                        result := _line
    cOBST:                      result := _obst
    cMOVING:                    result := to_int(s2.moving)
    cSTALLED:                   result := to_int(s2.stalled)
    cCOUNTDN:                   _countdn
    
    other:
      case id
      ' _DEBUG
        cDUMP:     _dump
        cMAP:      dump_map(@globals)
        cHEAP:     _heap
      ' END _DEBUG
        other:     bytecode_error
        
  drop_frame(result)

PRI s2_distance(a)
'
'' The S2 moves in units of 0.5 mm, so change the argument (which is mm) to that unit
'
  result := -32767 #> num_arg(a) / 50 <# 32767

PRI _motors | left, right, dur
' MOTORS left right (duration)
  left := int_arg_rng(1, -255, 255)
  right := int_arg_rng(2, -255, 255)
  if argc => 3
    dur := int_arg_rng(3, 0, 100000)
  s2.wheels_now(left, right, dur)

PRI _lights | c[3], n, val
' LIGHTS color1 color2 color3
  repeat n from 0 to 2
    c[n] := lookupz(int_arg_rng(n+1,0,10) : s2#OFF,s2#RED,s2#ORANGE,s2#YELLOW,s2#CHARTREUSE,s2#GREEN,s2#DIM_RED,s2#DIM_GREEN,s2#BLINK_RED,s2#BLINK_GREEN,s2#ALT_RED_GREEN)
  s2.set_leds(c[0], c[1], c[2], s2#NO_CHANGE)
     
PRI _batt
  result := to_num(s2.get_adc_results(s2#ADC_VBAT) * constant(400*33) / 2550)

PRI _light
' let us hope that these routines never return 255!
  result := to_list(s2.light_sensor(s2#LEFT), s2.light_sensor(s2#CENTER), s2.light_sensor(s2#RIGHT))
  
PRI _line
  result := to_list(s2.line_sensor(1, 0) & 1, s2.line_sensor(2, 0) & 1, 255)
  
PRI _obst | n, thld
  result := to_list(s2.obstacle(1, 0) & 1, s2.obstacle(2, 0) & 1, 255)

VAR
  LONG last_timer
  
PRI _timer
' Outputs the first timer
  if argc => 1
    last_timer := s2.get_timer(0)
  return to_int(0 #>(s2.get_timer(0) - last_timer) <# MAX_INT)

PRI _countdn | n, freq
  n := int_arg(1)
  freq := music#C5
  s2.set_led(s2#LEFT, s2#RED) 
  s2.set_led(s2#CENTER, s2#RED) 
  s2.set_led(s2#RIGHT, s2#RED) 
  repeat until n == 0
    case n
      9: freq := music#CS5
      8: freq := music#D5
      7: freq := music#DS5
      6: freq := music#E5
      5: freq := music#F5
      4: freq := music#FS5
      3: freq := music#G5
      2: freq := music#GS5
         s2.set_led(s2#RIGHT, s2#OFF)
      1: freq := music#A6
         s2.set_led(s2#CENTER, s2#OFF)
    music.play_note(64, freq, 0)
    s2.delay_tenths(10)
    --n
  s2.set_led(s2#LEFT, s2#OFF) 
  play_chord

PRI _arc | full_circle, wheel_space, ccw_units, radius, l, r
  wheel_space := s2.get_wheel_calibration
  full_circle := wheel_space >> 16
  wheel_space &= $FFFF
  ccw_units := full_circle * (-360 #> -int_arg(1) <# 360) / 360
  radius := s2_distance(2)
  r := ccw_units * (radius + wheel_space) / wheel_space
  l := ccw_units * (radius - wheel_space) / wheel_space
  if ccw_units < 0
    ' The original S2 code moved backwards here. Not good.
    s2.move(-r, -l, 0, current_spd, 0)
  else
    s2.move(l, r, 0, current_spd, 0)
  s2.wait_stop

PRI _speed
  current_spd := (1 #> num_arg(1) <# 100) * 15 / 100
  s2.set_speed(current_spd) 
       
PRI play_chord
  music.play_note(music#THSC,music#C4,0)
  music.play_note(music#THSC,music#E4,0)
  music.play_note(music#THSC,music#G4,0)
  music.play_note(music#SXTH,music#C5,music#G4)

PRI _to | val, buf, p, a, n, elem
'
'' Define a procedure. Works only if the procedure is not a name
'' or a primitive. The methods allocates all available memory,
'' uses that buffer to parse the input lines, shrinks the buffer
'' again and stores the handle along with the number of arguments
'' into the global map.
'
  if proc_fp
    proc_error(@err_toplevel, 0)
  ' Lookup the name (must be a pstr a.k.a cPROC) and not a primitive or name
  if byte[ip] <> cPROC
    proc_error(@err_needs_name, 1)
  to_name := ++ip
  val := map.get(@globals, to_name)
  if val & VAL_PRIM_BIT
    str_error(to_name, @err_is_primitive)
  if val & VAL_NAME_BIT
    str_error(to_name, @err_is_name)
  ' skip the name
  ip += byte[ip] + 1

  ' Allocate all remaining memory (shrink later)
  to_handle := mem.alloc_all(@proc_heap)   
  buf := mem.deref(@proc_heap, to_handle)
  
  ' Get the formal parameters; must be cNAME (:N) or cPROC (N)
  to_locals := mem.alloc(@data_heap, LOCALS_SIZE)
  map.init(mem.deref(@data_heap, to_locals), LOCALS_SIZE, @data_heap)
  a~
  repeat while byte[ip] <> cSTOP
    if ++a > 15
      proc_error(@err_too_many_args, 0)
    ifnot lookdown(byte[ip]: cPROC, cNAME)
      proc_error(@err_needs_name, a+1)
    ++ip
    ' Store an 1-based index into the map; we can use static allocation
    ' because the names only persist during this function
    elem := map.find(mem.deref(@data_heap, to_locals), ip, Map#STATIC)
    map.set_value(elem, a)
    ip += byte[ip] + 1

  ' Now we have all formals defined and in the @locals map
  ' Let us get all of the lines!
  n~
  parse_init(buf, buf + mem.size(@proc_heap, to_handle))
  repeat
    ' may throw
    read_line(logo_flags & GFLAG_PROMPT)
    ' progEnd points to the first token
    check_space(2)
    byte[progEnd++] := cLINE
    if ++n < 255
      byte[progEnd++] := n
    else
      byte[progEnd++]~
    p := progEnd
    parse_line
    if byte[p] == cEND
      byte[p] := cSTOP
      progEnd := p+2 
      quit
    
  ' We are done; store the result. q points to the first byte behind buffer
  ' Add $FF to satisfy disas_proc() if q is odd
  ' because the size that we get for the proc is always even
  if progEnd & 1
    byte[progEnd++] := $FF

  ' since the map contained static data, just discard it
  mem.free(@data_heap, to_locals)
  to_locals~
  mem.shrink(@proc_heap, to_handle, progEnd - buf)
  map.put(@globals, to_name, VAL_PROC_BIT + (a << VAL_SHIFT_ARGC)+ to_handle)
    
  pstr(to_name)
  if val
    mem.free(@proc_heap, val & VAL_PROC)
    val := string(" redefined")
  else
    val := string(" defined")
  str(val)
  crlf
  to_handle~
  to_name~

PRI streq(str1, str2) | i
  i := byte[str1] - byte[str2]
  if i
    return FALSE
  i := byte[str1]  
  repeat i
    if BYTE[str2++] - BYTE[str1++]
      return FALSE
  return TRUE

PRI _output
' come here if OP is called at toplevel
  result := arg(1)
  if proc_fp
    byte[proc_fp][FP_STOP]~~
  else
    abort result
  
PRI _stop
  if proc_fp
    byte[proc_fp][FP_STOP]~~
  else
    abort 0
      
PRI _mem
  str(string("proc="))
  dec(mem.free_mem(@proc_heap))
  str(string(" data="))
  dec(mem.free_mem(@data_heap))
  str(string(" globals="))
  dec(map.free_entries(@globals))
  crlf

PRI _item | n
  n := int_arg_rng(1, 1, 3)
  result := arg(2)
  ifnot result & VAL_LIST_BIT
    proc_error(@err_needs_list, 2)
  case n
   1: result >>= 16
   2: result >>= 8
  result &= $FF
  if result == 255
    proc_error(@err_out_of_range, 1)
  result := to_int(result)
  
PRI _print | i, a, val
  a := argc
  if (a)
    repeat i from 1 to a
      if i > 1
        tx(" ")
      val := arg(i)
      if val & VAL_STR_BIT
        ' print a string without vertical bars
        pstr(val & VAL_STR)
      else
        print_value(val)
  crlf
   
PRI _make | name, val, oldval 
  name := str_arg(1)
  val  := arg(2)
  name := map.find(@globals, name, Map#DYNAMIC)
  oldval := map.value(name)
  if (oldval & VAL_PRIM_BIT)
    str_error(map.key(@globals, name), @err_is_primitive)            
  if (oldval & VAL_PROC_BIT)
    str_error(map.key(@globals, name), @err_is_procedure)
  ' If the old value is a handle, release it
  if (oldval & VAL_HANDLE_BIT)
    mem.free(@data_heap, oldval)
  map.set_value(name, check_string(val))

PRI _lmake | name, oldval, val
'
'' Local MAKE. If the 1st argument was a string, the parser
'' replaces it with the index of the local variable in to_compile.
'
  ifnot proc_fp
    proc_error(@err_procedure, 0)
  name := int_arg(1)
  val := arg(2)
  oldval := long[proc_fp][FP_LOCALS + name]
  ' If the old value is a handle, release it
  if (oldval & VAL_HANDLE_BIT)
    mem.free(@data_heap, oldval)
  long[proc_fp][FP_LOCALS + name] := check_string(val)
  
PRI check_string(val) | len, p
  ' If a string is to be stored, create a copy if the string
  ' is inside the program buffer, because that buffer will be
  ' overwritten by the next user command
  if val & VAL_STR_BIT
    p := val & VAL_STR
    if (p => @prog) and (p < progEnd)
      len := byte[p] + 1
      val := mem.alloc(@data_heap, len)
      bytemove(mem.deref(@data_heap, val), p, len)
      val |= VAL_STR_BIT | VAL_HANDLE_BIT
  return val
  
PRI _thing | name
  name := str_arg(1)
  result := map.get(@globals, name)
  ifnot (result & VAL_NAME_BIT)
    str_error(name, @err_not_a_name)

PRI _mul | a, b, upper
  a := num_arg(1)
  b := num_arg(2)
  result := a * b
  upper := a ** b
  if upper and (upper <> -1)
    error(@err_overflow)
  if result // 100 => 50
    result += 100
  return to_num(result / 100)
  
PRI _divmod(op) | a, b     
  a := num_arg(1)
  b := num_arg(2)
  ifnot b
    proc_error(@err_div0, 0)
  if op == cDIV
    a := a * 100 / b
  else
    a //= b
  return to_num(a)
  
PRI _add
  ' unary?
  if argc == 1
    return to_num(num_arg(1))
  return to_num(num_arg(1) + num_arg(2))
  
PRI _sub
  ' unary?
  if argc == 1
    return to_num(-num_arg(1))
  return to_num(num_arg(1) - num_arg(2))

PRI compare(op) | val1, val2, len1, len2, i
'
' Compare two values
' Return > 0 if val1 is < val2, < 0 if val1 > val2
' or 0 if the values are the same
'
  val1 := arg(1)
  val2 := arg(2)
  if val1 & val2 & VAL_NUM_BIT
    result := num_arg(1) - num_arg(2)
  elseif (val1 & val2 & VAL_STR_BIT)
    result := map.strcmp(val1 & VAL_STR, val2 & VAL_STR)
  case op
    cEQ: result := result == 0
    cNE: result := result <> 0
    cLT: result := result <  0
    cLE: result := result =< 0
    cGT: result := result >  0
    cGE: result := result => 0
  result := to_int(result)

PRI _bitops(op) | a, b
  a := int_arg(1)
  b := int_arg(2)
  case op
    cLSH:
      if b < 0
        a >>= -b
      else
        a <<= b
    cBITAND:                    a &= b
    cBITOR:                     a |= b
    cBITXOR:                    a ^= b
    cBITNOT:                    a := !a
  result := to_int(a)
  
PRI _boolops(op) | a, b
  a := num_arg(1)
  b := num_arg(2)
  case op
    cLOGAND:                    a := a and b
    cLOGOR:                     a := a or b
    cLOGNOT:                    a := not a
  result := to_int(a)
  
PRI do_sin(x) | y, q
  x:= -35999 #> x <# 35999
  if x < 0
    x := 36000 - x
  x := x * 8192 / 36000         ' extend to max 8191
  q := x >> 11                  ' two highest bits of 13 are the quadrant, 0, 1, 2 or 3
  y := (x & $7ff) << 1          ' 0 to 90- degrees, are contained in 11 bits, shift left one for Word offset
                                ' this is the address offset into the sine table in hub rom
                                ' note: the parentheses are important for operator precedence
  case q                        ' select quadrant 0,1,2,3    
    0 : result := word[$E000 + y]
    1 : result := word[$F000 - y]   ' 2049 angles, 16 bit sin(angle) values corresponding 0 to 90 degrees. 
    2 : result := -word[$E000 + y]  ' the same table is folded over and mirrored for all 360 degrees
    3 : result := -word[$F000 - y]  ' value returned in the range of -$ffff to +$ffff
  result := to_num((result * 100) / $FFFF)
  
PRI _sin
  return do_sin(num_arg(1))
  
PRI _cos
  return do_sin(num_arg(1) + 9000)

PRI _sqrt | val
  val := num_arg(1)
  if val < 0
    error(@err_sqrt)
  result := to_num(^^(val * 100))

PRI _if  
  if byte[ip] <> cOBRK
    proc_error(@err_needs_list, 2)
  if num_arg(1)
    result := eval_list(TRUE, 2)
    ' skip the ELSE list
    if byte[ip] == cOBRK
      eval_list(FALSE, 3)
  else
    eval_list(FALSE, 2)
    if byte[ip] == cOBRK
      result := eval_list(TRUE, 3)
    
PRI _repeat | n, p
  if byte[ip] <> cOBRK
    proc_error(@err_needs_list, 2)
  n := int_arg(1)
  if n =< 0
    return 0
  p := ip
  repeat n
    if rxcheck == $03
      stopped
    ip := p
    result := eval_list(TRUE, 2)
    if result
      quit

PRI _while | cond, rl, end
  cond := ip
  ip := skip_list(1)
  rl := ip
  ip := skip_list(2)
  end := ip
  ' the loop
  repeat
    if rxcheck == $03
      stopped
    ip := cond
    result := eval_list(TRUE, 1)
    if result == VAL_NUM_BIT ' 0 
      quit
    ip := rl
    eval_list(TRUE, 2)
  ip := end
  result~ 
     
PRI _po | val
  val := map.get(@globals, str_arg(1))
  ifnot val
    return
  ifnot val & VAL_EXEC_BIT
    pstr(str_arg(1))
    str(string(" = "))
    print_value(val)
  if val & VAL_PROC_BIT
    disas_proc(val & VAL_PROC)
  else
    str(string("TO "))
    pstr((val & VAL_PROC) + 2)
    crlf

PRI _er | a, name, val
  if proc_fp
    proc_error(@err_toplevel, 0)
  ifnot argc
    return
  repeat a from 1 to argc
    name := str_arg(a)
    val := map.get(@globals, name)
    ifnot val
      str_error(name, @err_not_a_proc)
    if val & VAL_PRIM_BIT
      str_error(name, @err_is_primitive)
    if val & VAL_PROC_BIT
      mem.free(@proc_heap, val & VAL_PROC)
    elseif val & VAL_HANDLE_BIT  
      mem.free(@data_heap, val & VAL_STR)
    map.remove(@globals, name)

PRI _erall
  init
  ' in case condensed mode is on
  print_result(0)
  abort $FFFFFFFF
  
PRI _prompt
  if num_arg(1)
    logo_flags |= GFLAG_PROMPT
  else
    logo_flags &= !GFLAG_PROMPT

PRI _downld | op
'
'' Download and run a compiled program. The CRC byte
'' is simply a byte that is shifted left by 1 and XORed
'' with the incoming byte.
'' @siz  the size in bytes without the CRC byte
'
  bytes_left := int_arg(1)
  bytes_to_read~
  crc~
  progEnd := @prog
  repeat while bytes_left
    op := rxcrc
    if op == cDEF
      _define
    else
      check_space(1)
      byte[progEnd++] := op
  store_primitive(cSTOP)
  print_ready(1)
  if (crc & $FF) <> rx
    error(@err_crc)
  print_ready(0)
  \run
  ' back to toplevel, and do not print anything
  abort $FFFFFFFF
      
PRI _define | a, name, h, namesize, siz, ch
'
'' Define a procedure in download mode. The following data is received:
''  byte  argc
''  byte  lenOfName
''  byte  name[lenOfName]
''  word  lenOfCode
''  byte  code[lenOfCode]
'
  name := progEnd
  a := rxcrc
  namesize := rxcrc
  check_space(1)
  byte[progEnd++] := namesize
  repeat namesize
    ch := rxcrc
    check_space(1)
    byte[progEnd++] := ch
  siz := rxcrc + (rxcrc << 8)
  h := mem.alloc(@proc_heap, siz)
  ch := mem.deref(@proc_heap, h)
  repeat siz
    byte[ch++] := rxcrc
  map.put(@globals, name, VAL_PROC_BIT + (a << VAL_SHIFT_ARGC) + h)
  ' dispose of the name
  progEnd := name

VAR
  WORD  bytes_left    ' number of bytes left to read during a download
  BYTE  crc           ' checksum byte for downloads
  BYTE  bytes_to_read ' the number of bytes to read, usually 16
    
PRI rxcrc
  ifnot bytes_to_read
    ' ask for more bytes, max 16
    bytes_to_read := bytes_left <# 16
    print_ready(bytes_to_read)
  result := rx
  crc := (crc << 1) ^ result
  --bytes_left
  --bytes_to_read
  
CON
{{
  Printing
}}

PRI print_frame(f) | i, a
  pstr(proc_name(f))
  a := byte[f][FP_ARGC]
  if (a)
    repeat i from 1 to a
      tx(" ")
      print_value(long[f + FP_LOCALS_OFF][i-1])

PRI print_stack(at) | f
  f := fp
  repeat while f
    if at
      if logo_flags & GFLAG_PROMPT
        str(string("At: "))
      else
        str(@str_bt)
        dec(byte[f][FP_LEVEL])
        tx(" ")
    print_frame(f)
    crlf
    f := word[f][FP_LAST]
                      
PRI print_result(val)
  if logo_flags & GFLAG_PROMPT
    if val
      str(string("Result: "))
      print_value(val)
      crlf
  else
    str(@str_ok)
    print_value(val)
    crlf

PRI print_value(val) | ch
  if val & VAL_HANDLE_BIT
    val := (val & $ffff0000) | mem.deref(@data_heap, val)
  if val & VAL_STR_BIT
    print_string(VAL & VAL_STR)
  elseif val & VAL_NUM_BIT
    print_number(val & VAL_NUM)
  elseif val & VAL_LIST_BIT
    ch := "["
    repeat 3
      if (val & $FF0000) == $FF0000
        quit
      tx(ch)
      ch := " "
      dec((val & $FF0000) >> 16)
      val <<= 8
    tx("]")
  elseif val
    str(string("{proc}"))
  else
    str(string("nothing"))

PRI print_number(n)
'
'' Print a number with max 2 decimal places
'
  if n & $00800000
    n |= $ff000000
    tx("-")
    n := -n       
  dec(n / 100)
  n //= 100
  if n
    tx(".")
    tx(n / 10 + "0")
    if n // 10
      tx(n // 10 + "0")
   
PRI print_string(s) | p, len, bars, ch
'
'' Print a string, and enclose it in vertical bars if required
'
  p := s
  len := byte[p]
  bars~
  repeat len
    ch := byte[++p]
    if is_separator(ch) or ((ch => "a") and (ch =< "z"))
      bars~~
      quit
  if bars
    tx("|")
  pstr(s)
  if bars
    tx("|")

PRI print_ready(n)
'
'' Ask for more bytes to be sent in non-prompt mode during a download
'
  ifnot logo_flags & GFLAG_PROMPT
    str(@str_ready)
    dec(n)
    crlf
   
PRI trace_enter(reenter)
  if (debug_flags & DFLAG_TRACE)
    repeat byte[fp][FP_LEVEL]
      tx(" ")
    if reenter
      reenter := string("Re-entering ")
    else
      reenter := string("Entering ")
    str(reenter)
    print_frame(fp)
    crlf

PRI trace_exit(val)
  if (debug_flags & DFLAG_TRACE)
    repeat byte[fp][FP_LEVEL]
      tx(" ")
    str(string("Leaving "))
    print_frame(fp)
    if val
      str(string(" with "))
      print_value(val)
    crlf

PRI trace_line(line)
' print the line info only for lines > 0 (all lines > 255 have 0 as line)
  if line and fp and (debug_flags & DFLAG_TRACE_LINE)
    pstr(proc_name(fp))
    str(string(", line "))
    dec(line)
    crlf
    
PRI print_opcode
  if debug_flags & DFLAG_TRACE_OP
    disas(ip)

PRI pstr(s) | len
  len := byte[s]
  repeat len
    tx(byte[++s])
    
PRI get_primitive(id) | p
'
'' Get a primitive name by ID by walking the table of primitives.
'
  p := @builtins
  repeat while byte[p]
    if byte[p] == id
      return p + 2
      quit
    p += byte[p+2] + 3
  return @pstr_bad_primitive
        
PRI crlf
  tx(13)    

PRI rxcheck
  result := serial.rxcheck

PRI rxtime(tm)
  result := serial.rxtime(tm)

PRI rx
  result := serial.rx

PRI tx(val)
  serial.tx(val)

PRI str(val)
  serial.str(val)

PRI dec(val)
  serial.dec(val)

PRI hex(val, digits)
  serial.hex(val, digits)

CON
{{
  Runtime errors
}}

PUB error(msg)
'
'' Print an error message
'' @msg   the error message with byte 1 being the error code
'
  if logo_flags & GFLAG_PROMPT 
    str(@ErrorMsg)
    str(msg+1)
  else
    str(@str_err)
    dec(byte[msg])
  error_end
          
PRI str_error(ps, msg)
'
'' Print a combined error message
'' @ps    a Pascal string
'' @msg   the error message with byte 1 being the error code
'
  if logo_flags & GFLAG_PROMPT 
    str(@ErrorMsg)
    pstr(ps)
    tx(" ")
    str(msg+1)
  else
    str(@str_err)
    dec(byte[msg])
    tx(" ")
    pstr(ps)
  error_end
        
PRI proc_error(msg, n)
'
'' Print an error message with the current proc name at the beginning (if present)
'' @msg   the error message with byte 1 being the error code
'' @n     the parameter number (0 if no parameter)
'
  if logo_flags & GFLAG_PROMPT 
    str(@ErrorMsg)
    pstr(proc_name(fp))
    tx(" ")
    str(msg+1)
    if n
      str(string(" as its "))
      tx(n+"0")
      str(string(". input"))
  else
    str(@str_err)
    dec(byte[msg])
    tx(" ")
    pstr(proc_name(fp))
    tx(" ")
    dec(n)
 error_end
  
PRI value_error(val)
'
'' Print a "You don't say" message
'' @val   the unexpected value
'
  if logo_flags & GFLAG_PROMPT 
    str(@ErrorMsg)
    str(@err_value+1)
    print_value(val)
  else
    str(@str_err)
    dec(byte[@err_value])
    tx(" ")
    print_value(val)
  error_end
  
PRI bytecode_error
'
'' Print a "Byte code error" message
'
  if logo_flags & GFLAG_PROMPT 
    str(@ErrorMsg)
    str(@err_bytecode+1)
    hex(ip, 4)
    tx(":")
    hex(byte[ip], 2)
  else
    str(@str_err)
    dec(byte[@err_bytecode])
  error_end

PRI bracket_error(msg, ch)
'
'' Print a Missing Bracket error
'' @ch   the missing bracket
'
  if logo_flags & GFLAG_PROMPT 
    str(@ErrorMsg)
    str(msg+1)
    tx(ch)
  else
    str(@str_err)
    dec(byte[msg])
    tx(" ")
    tx(ch)
  error_end

PRI stopped
  if logo_flags & GFLAG_PROMPT
    tx(13)
    str(string("Stopped!"))
  else
    str(@str_stopped)
  error_end   

PRI error_end
  crlf
  print_stack(TRUE)
  ' cleanup: free any TO procedure handle if TO threw
  if to_handle
    mem.free(@proc_heap, to_handle)
  if to_locals
  ' since the map contained static data, just discard it
    mem.free(@data_heap, to_locals)
  to_handle~
  to_name~
  to_locals~
  error_flag~~
  abort FALSE
     
CON
{{
        Debug routines, should be removed from final product
}}

DAT
  dump_addr   WORD      0
  dump_len    WORD      128
  dump_fmt    WORD      1
  
PRI _dump | val
  if argc => 1
    val := arg(1)
    if (val & VAL_STR_BIT)
      val &= VAL_STR
      case byte[val+1]
        "D": dump_addr := @data_heap
        "P": dump_addr := @proc_heap
        "G": dump_addr := @globals
    else
      dump_addr := int_arg(1)
  if argc => 2
    dump_len := int_arg(2)
  if argc => 3
    dump_fmt := lookdown(int_arg(3):1,2,4)
    ifnot dump_fmt
      dump_fmt := 1
  dump(dump_addr, dump_len, dump_fmt)
  dump_addr += dump_len

PRI _heap
  if int_arg(1)
    dump_heap(@proc_heap)
  else
    dump_heap(@data_heap)
    
PRI dump(buf, len, ws) | j, cp
  repeat while len > 0
    cp := buf
    hex(buf, 4)
    repeat j from 0 to 15 step ws
      tx(" ")
      if j => len
        repeat ws << 1
          tx(" ")
      else
        case ws
          1: hex(byte[buf], 2)
          2: hex(word[buf], 4)
          4: hex(long[buf], 8)
        buf += ws
    str(string("   "))
    repeat j from 0 to 15
      if j => len
        quit
      elseif byte[cp] < 32
        tx(".")
      else
        tx(byte[cp])
      cp++
    crlf
    len -= 16

PRI dump_heap(buf) | p, q
'
'' Dump the heap
'
  str(string("Buf  = "))
  hex(buf, 4)
  crlf
  str(string("Free = "))
  hex(word[buf][mem#BUF_TBL_FREE], 4)
  crlf
  str(string("Bgn  = "))
  hex(word[buf][mem#BUF_MEM_BGN], 4)
  crlf
  str(string("Top  = "))
  hex(word[buf][mem#BUF_MEM_TOP], 4)
  crlf
  str(string("End  = "))
  hex(word[buf][mem#BUF_MEM_END], 4)
  crlf
  ' Check free table integrity
  p := buf + mem#BUF_TBL_FREE
  repeat while p
    q := word[p]
    ifnot q & $8000
      str(string("Free table holds occupied entry at "))
      hex(p, 4)
      crlf
      return
    p := q & $7FFF
  ' Dump occupied entries
  repeat p from buf + mem#BUF_HDR_SIZE to word[buf][mem#BUF_MEM_BGN]-2 step 2
    q := word[p]
    ifnot q & $8000
      str(string("h = "))
      hex(p, 4)
      str(string(", size = "))
      dec(word[q][-1] - 2)
      crlf
      dump(q, word[q][-1]-2, 1)

PRI print_map(buf, mask)
'
'' Print a Logo representation of the map contents according to the mask
'
  print_tree(buf, map.root(buf), mask)
  
PRI print_tree(buf, elem, mask) | val
  ifnot elem
    return
  print_tree(buf, map.left(elem), mask)
  val := map.value(elem)
  if (val & mask)
    if val & VAL_EXEC_BIT
      ' check for the Do Not List bit
      ifnot val & VAL_HIDE_BIT
        str(string("TO "))
        pstr(map.key(buf, elem))
        crlf
    else
      pstr(map.key(buf, elem))
      str(string(" = "))
      print_value(val)
      crlf  
  print_tree(buf, map.right(elem), mask)

PRI dump_map(buf)
'
'' Print the entire tree with indents etc
'
  dump_tree(buf, map.root(buf), "C", 0)
  
PRI dump_tree(buf, elem, ch, lvl)
  ifnot elem
    return
  dump_tree(buf, map.left(elem), "L", lvl+1)
  tx(ch)
  repeat lvl
    tx(" ")
  pstr(map.key(buf, elem))
  str(string(" = "))
  hex(map.value(elem), 8)
  tx(" ")
  crlf
  dump_tree(buf, map.right(elem), "R", lvl+1)

PRI disas(p) | q, op, i, c
'
'' Disassemble the opcode at the given location,
'' and return the new location
'
  case op := byte[p]
    cOPAR,cOBRK,cNUM2: c := 3
    cLGET,cNUM1,cLINE: c := 2
    cNUM3:             c := 4
    cSTR,cNAME,cPROC:  c := (2 + byte[p+1]) <# 4
    other:             if op < cFIRST_PRIM or op > cLAST_PRIM
                         c := 1
                       else
                         c := 2
  hex(p, 4)
  tx(" ")
  q := p
  repeat i from 1 to c
    hex(byte[q++], 2)
    tx(" ")
  if c < 4
    repeat i from c+1 to 4
      str(string("   "))
    
  case op := byte[p++]
    cOPAR:   tx("(")
             p += 2
    cCPAR:   tx(")")
    cOBRK:   tx("[")
             p += 2
    cCBRK:   tx("]")
    cREC:    str(string("recurse"))
    cLINE:   str(string("line "))
             dec(byte[p++])
    cLGET:   str(string("lget "))
             dec(byte[p++])
    cLSET:   str(string("lset "))
             dec(byte[p++])
    0..127:  dec(op)
    cNUM1:   print_number(byte[p++])
    cNUM2:   print_number(byte[p++] + (byte[p++] << 8))
    cNUM3:   print_number(byte[p++] + (byte[p++] << 8) + (byte[p++] << 16))
    cSTR:    tx($22)
             print_string(p)
             p += byte[p] + 1
    cNAME:   tx(":")
             print_string(p)
             p += byte[p] + 1
    cPROC:   print_string(p)
             p += byte[p] + 1
    cDEF:    str(string("def "))
             dec(byte[p++])
             tx(" ")
             pstr(p)
             p := byte[p] + 1
             tx(" ")
             c := byte[p++] + (byte[p++] << 8)
             dec(c)
    other:   if op < cFIRST_PRIM or op > cLAST_PRIM
               hex(op,2)
             else
               pstr(get_primitive(op))
               p++
  crlf
  return p

PRI disas_proc(h) | p, end
'
'' Disassemble a procedure. The last byte may be $FF as a filler
'' if the size of the proc is odd
  p := mem.deref(@proc_heap, h)
  end := p + mem.size(@proc_heap, h)
  ' filler byte?
  if byte[end-1] == $FF
    end--
  repeat while p < end
    p := disas(p)
    
DAT
  ' in non-prompt mode, std responses start with Ctrl-C
  str_ok                byte    $03,"OK ",0
  str_err               byte    $03,"ERR ",0
  str_ready             byte    $03,"RDY ",0
  str_bt                byte    $03,"BT ",0
  str_stopped           byte    $03,"STOP",0
  
  pstr_toplevel         byte    8,"toplevel"
  pstr_bad_primitive    byte    5,"{bad}"
  
  ErrorMsg              byte    "Error: ",0
  ' with no arguments
  err_div0              byte    1,"Division by 0",0
  err_no_memory         byte    2,"Out of memory",0
  err_stack_overrun     byte    3,"Too many nested procedure calls",0
  err_word_too_long     byte    4,"Word is > 255 characters",0
  err_text_too_large    byte    5,"Text too large",0 
  err_bad_num_base      byte    6,"Bad number base",0
  err_bad_digit         byte    7,"Bad digit",0
  err_overflow          byte    8,"Overflow",0
  err_crc               byte    9,"Checksum error",0
  err_sqrt              byte    10,"Square root of a negative number",0
  ' with one argument
  err_bracket           byte    11,"Missing closing ",0
  err_too_many_brackets byte    12,"Too many closing ",0
  err_bytecode          byte    13,"Bad bytecode ",0
  err_needs_more_inputs byte    14,"needs more inputs",0
  err_value             byte    15,"You don't say what to do with ",0
  err_not_a_name        byte    16,"is not a name",0
  err_not_a_proc        byte    17,"is not a procedure",0
  err_is_name           byte    18,"is a name",0
  err_is_primitive      byte    19,"is a primitive",0
  err_is_procedure      byte    20,"is a procedure",0
  err_too_many_args     byte    21,"has more than 15 inputs",0
  err_toplevel          byte    22,"cannot be part of a procedure",0
  err_procedure         byte    23,"must be part of a procedure",0
  ' with a possible 2nd argument "as its %2. input"
  err_needs_name        byte    24,"needs a word",0
  err_needs_number      byte    25,"needs a number",0
  err_needs_list        byte    26,"needs a list",0
  err_out_of_range      byte    27,"'s input is out of range",0
  err_no_value          byte    28,"got nothing",0

''=======[ License ]===========================================================
{{{
+--------------------------------------------------------------------------------------+
¦                            TERMS OF USE: MIT License                                 ¦                                                            
+--------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this  ¦
¦software and associated documentation files (the "Software"), to deal in the Software ¦
¦without restriction, including without limitation the rights to use, copy, modify,    ¦
¦merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    ¦
¦permit persons to whom the Software is furnished to do so, subject to the following   ¦
¦conditions:                                                                           ¦
¦                                                                                      ¦
¦The above copyright notice and this permission notice shall be included in all copies ¦
¦or substantial portions of the Software.                                              ¦
¦                                                                                      ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   ¦
¦INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         ¦
¦PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    ¦
¦HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF  ¦
¦CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  ¦
¦OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                         ¦
+--------------------------------------------------------------------------------------+
}}