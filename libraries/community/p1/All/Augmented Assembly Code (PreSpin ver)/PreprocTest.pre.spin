{{ Keyboard to Text with Preprocessor }}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

'#define Test_Include = FALSE               'a constant only for the preprocessor 
'#define
  VGA  = FALSE                              'with this syntax also spin knows the constant
'#define
  TV   = FALSE
'#define
  PC   = TRUE                               'use PropTerminal


OBJ
'#if PC
  term   :       "PC_Interface"      'Text and Keyboard (and mouse) in 1 object
  '#replace kb. = term.              ;use term-object also for kb-object
'#else
  kb     :       "Keyboard"
 '#if TV
  term   :       "TV_Text"
 '#else
  term   :       "VGA_Text"
 '#endif
'#endif
  
VAR


PUB Main | k

  'start the terminal
'#if VGA
  term.start(16)
'#endif
'#if PC
  term.start(31,30)
'#endif
'#if TV
  term.start(12)
'#endif
  term.str(string("PC_Keyboard Demo...",13))

  'start the keyboard
'#if !PC
  kb.start(26, 27)                'kb.start only needed if not PropTerminal
'#endif

  'echo keystrokes in hex
  repeat
    k := kb.getkey                'kb changes to term if PC=TRUE
    if k&255 > $CF
      term.out(12)
      term.out(k&7)
    term.hex(k,3)
    term.out(" ")

'#if Test_Include
  '#include "..\Simple_Serial.spin"    'only for test, will not be used
'#endif
    