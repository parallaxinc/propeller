{{
LCDDEMO Version 1.2 April 21,2007
Added the ability to define custom characters
Added the ability to change already defined custom characters while they're being displayed
Changed method to send commands to the LCD a public method  
Added clear current line
Fixed some minor problems
Removed use of escape to display characters.
Legal character codes are now, 0-7 and 32-127

Version 1.1 April 16,2007
Added the escape character test in the string output
so that any character (0-255) can be sent to the display
Added lines per display (lcdlines) so that other displays
(1 to n lines) can be used.

4 bit parallel interface to a
4 line by 20 character LCD
Which uses the Hitachi HD44780 LCD controller

**************************************************
*****  DO NOT set the clock for RCMODE=SLOW  *****
**************************************************

These are the connections I used

  PORTA          LCD Display
           ┌──── PIN 1  GND
           │ +5V PIN 2  VCC
           ┣──── PIN 3  Contrast
  PIN 5 ───┼──── PIN 4  Enable
           ┣──── PIN 5  RD/!WR
  PIN 4 ───┼──── PIN 6  Register Select
           ┣──── PIN 7  D0
          ┌╋──── PIN 8  D1
          ┣──── PIN 9  D2
           └──── PIN 10 D3
  PIN 3───────── PIN 11 D4
  PIN 2───────── PIN 12 D5
  PIN 1───────── PIN 13 D6
  PIN 0───────── PIN 14 D7 



Methods used in LCDDEMO:
pub init  'Initialize the LCD to four bit mode and clear it
pub writestr(stringptr)          Write out a string to the LCD
pub writecg(CharCode, stringptr) Write custom characters to the cg ram
pub writecgline(CharCode, CharLine, stringptr) Write a line into a custom character
pub commandOut(code)             Write out a command to the display controller
pub writeOut(character)          Write out a single character to the display
pub cls                          Clear the display
pub cll                          Clear the current line
pub cursor_on                    Turn the cursor and blink on
pub cursor_off                   Turn the cursor and blink off
pub pos(line,column)             Set the position
pub home                         Go back to the start of the line
pub uSdelay(DelayuS)             Delay for # of microseconds

                                Method Descriptons:
                                
        init                     Initialize the LCD

        writestr(@string)        Write a string at the current position
                If the string is terminated by a carriage return ($0D) or
                line feed ($0A) then the position will move to the next line
                If the string exceeds the line length, then it will wrap to the next
                line. If this occurs on the last line, it will wrap to the first line        

        writecg(character code, @string) Write a custom character to the cg ram
                Character codes may be 0-7
                string contains the data for the code(s)
                more than one character may be written at a time
                Creation of custom characters is eased by using the
                LCD Character Creator from Parallax but copy only the hex code portion from
                the LCD Character Creator
                  WRONG: Char0 DATA $00,$00,$00,$00,$00,$00,$00,$00
                  RIGHT: $00,$00,$00,$00,$00,$00,$00,$00 
                Terminate the write process with an eog ($FF)

        writecgline(character code, character line, @string)
                Character codes may be 0-7
                Character lines may be 0-7
                Terminate the same way as writecg (eog)

        commandOut(code)         Write a command to the display controller

        writeOut("character")    Write a single character at the current position

        cls                      Clear the display

        cll                      Clear the current line
        
        cursor_on                Cursor on and blinking
        
        cursor_off               Turn the cursor off. Off is default after initialization

        pos(line, column)        Set position at line 1-4, column 1-20
        
        home                     Home to the beginning of the current line
        
        uSdelay(#microseconds)   Delay a specific number of microseconds
}}

con
  rs= 4               'Register select
  en= 5               'Enable
  msb = 3             'Highest dataline
  lsb = 0             'Lowest dataline
  'LCD Commands
  EightBitInit = 3    'Eight Bit mode
  FourBitInit = 2     'Four Bit mode
  ClearLcd = 1        'Clear the LCD
  CursorBlink = $0F   'Turn the cursor on and blink it
  NoCursor = $0C      'Turn the cursor off
  'LCD constants
  lcdlines = 4        '# of lines on the LCD. Assumes the lines are a power of 2 (1,2,4,8,16,etc..)
  linelength = 20     'LCD line length  
  Line1 = $80         'Address of the First Line
  Line2 = $C0         'Address of the Second Line
  Line3 = $94         'Address of the Third Line
  Line4 = $D4         'Address of the Fourth Line  
  lf = $0A            'Line Feed code
  cr = $0D            'Carriage Return code
  esc = $1B           'Escape code
  eos = $FF           'End Of String code
  eog = $ff           'End of Custom Graphics Load command
  cgra = $40          'Address of the cgram
  off = 0             'Cursor State constant
  on = 1              'Cursor State constant
  space = $20
  
var
  byte CurrentLine    'Current Line position Value 0-3
  byte CurrentPos     'Current Column position Value 0-19
  byte CursorState
  byte ddra           'Screen Data address
    
pub init  'Initialize the LCD to four bit mode and clear it
  dira[msb..lsb]~~
  outa[msb..lsb]~
  dira[en..rs]~~
  outa[en..rs]~
  outa[msb..lsb] := EightBitInit
  enable
  uSdelay(5000)
  enable
  enable
  outa[msb..lsb] := FourBitInit
  enable
  commandOut(12)
  commandOut(6)
  commandOut(ClearLcd)
  CurrentLine := 0
  CurrentPos := 0
  CursorState := off  
  uSdelay(5000)

pub writestr(stringptr)              'Write out a string to the LCD
  repeat
    if byte[stringptr] > 7 AND byte[stringptr] < space
      case byte[stringptr]
        lf, cr:                         'If a carriage return or line feed, go to a new line
          newline
      stringptr++
    else            
      writeOut(byte[stringptr++])
      CurrentPos++
          if CurrentPos == linelength
            CurrentPos := 0
  while byte[stringptr] <> eos 'test for end of string
              
pub writecg(CharCode, stringptr) | cgCount,endofjob  'Write custom characters to the cg ram
  endofjob := false
  cgCount := CharCode * 8        'Start the byte count
  commandOut(cgCount + cgra)     'Set the write address
  repeat while (endofjob == false) AND (cgCount < 64)
    cgCount++
    if (byte[stringptr] == eog)' AND (byte[stringptr + 1] == eog)
      endofjob := true
    else
      writeOut(byte[stringptr++])
  CurrentLine++
  CurrentPos++
  pos(CurrentLine,CurrentPos)              

pub writecgline(CharCode, CharLine, stringptr) | cgCount,endofjob  'Write a line into a custom character
  endofjob := false
  cgCount := CharCode * 8 + CharLine        'Start the byte count
  commandOut(cgCount + cgra)                'Set the write address
  repeat while (endofjob == false) AND (cgCount < 64)
    cgCount++
    if (byte[stringptr] == eog)' AND (byte[stringptr + 1] == eog)
      endofjob := true
    else
      writeOut(byte[stringptr++])
  CurrentLine++
  CurrentPos++
  pos(CurrentLine,CurrentPos)   

pub commandOut(char)            'Write out a command to the display controller
  outa[rs]~
  writeOut(char)
 
pub writeOut(character)         'Write out a single character to the display
  outa[msb..lsb] := character / 16
  enable
  outa[msb..lsb] := character & 15
  enable
  outa[rs]~~

pub cls                         'Clear the display
  commandOut(ClearLcd)
  CurrentLine := 0
  CurrentPos := 0
  uSdelay(5000)
  if CursorState == on
    cursor_on
  else
    cursor_off    

pub cll | lptr                  'Clear the current line
  home
  lptr := 0
  repeat while lptr < linelength
    writeOut(" ")
    lptr++
    
pub cursor_on                   'Turn the cursor and blink on
  CursorState := on
  commandOut(CursorBlink)

pub cursor_off                  'Turn the cursor and blink off
  CursorState := off
  commandOut(NoCursor)

pub pos(line,column)            'Set the position
  CurrentLine := (line - 1) & (lcdlines-1)
  CurrentPos := column - 1
  checkddra
  ddra += CurrentPos
  commandOut(ddra)

pub home                        'Go back to the start of the line
  CurrentLine--
  newline

pub uSdelay(DelayuS)            'Delay for # of microseconds
  waitcnt((clkfreq/1_000_000) * DelayuS + cnt)
  
pri enable                      'Toggle the enable line
  outa[en]~~
  uSdelay(100)
  outa[en]~
  uSdelay(100)
        
pri newline                     'Go to the next line
  CurrentPos := 0
  CurrentLine++
  CurrentLine &= (lcdlines-1)
  checkddra
  commandOut(ddra)
   
pri checkddra                   'Generate the LCD line address
    case CurrentLine
      0: ddra := Line1          'Address of First Line
      1: ddra := Line2          'Address of Second Line
      2: ddra := Line3          'Address of Third Line
      3: ddra := Line4          'Address of Fourth Line