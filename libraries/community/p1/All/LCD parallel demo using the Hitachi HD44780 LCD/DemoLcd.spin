{{ Demo LCD
  Uses LCDDEMO Version 1.2

  See LCDDEMO.spin for connections to LCD
        LCD uses 4 bit mode
        6 port pins are used

  DO NOT set the clock for RCMODE=SLOW
  
  LCDDEMO Commands:
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
  esc = $1B     'Escape code
  cr = $0D      'Carriage Return code                 
  lf = $0A      'Line Feed code
  eos = $FF       'End of string code
  eog = $FF     'End of graphics code
  space = $20   'Space character code
  
obj
  LCD : "LCDDEMO"
  
pub main
  LCD.init                      'Initialize the display
  LCD.writestr(@text)           'Write the first string
  LCD.writestr(@next1)          'Write the second string
  LCD.pos(3,11)                 'Set the third line position
  LCD.writestr(@try1)           'Write the third string
  LCD.home                      'Go back to the beginning of the line
  LCD.writestr(@last)           'Write the fourth string
  LCD.writestr(@line5)          'Write the fifth string
  LCD.uSdelay(4_000_000)        'Delay 4 seconds
  LCD.cls                       'Clear the screen
  LCD.writestr(@try2)           'Write the last string
  LCD.pos(3,1)                  'Set position to the third line, first column
  LCD.writestr(@blinkon)        'Cursor on message
  LCD.pos(2,10)                 'Position on the second line, column 10
  LCD.cursor_on                 'Turn the cursor on
  LCD.writeOut("A")             'Write the letter A out to the display
  LCD.uSdelay(4_000_000)        'Delay 4 seconds
  LCD.cursor_off                'Turn the cursor off
  LCD.pos(3,15)                 'Set position to the third line, first column  
  LCD.writestr(@blinkoff)       'Cursor off message
  LCD.writestr(@ornot)          'Or not message
  LCD.uSdelay(1_000_000)        'Delay 1 second
  LCD.cursor_on                 'Turn the cursor on
  LCD.uSdelay(2_000_000)        'Delay 2 seconds
  LCD.writecg(0,@char0)         'Write the graphics characters to codes 0 and 1
  LCD.cls
  LCD.writestr(@escapechar)     'Display the characters 0-7
  LCD.uSdelay(4_000_000)
  LCD.cursor_off                'Turn the cursor off
  LCD.cls
  LCD.writestr(@graphictest)
  LCD.pos(2,6) 
  LCD.writestr(@hello)          'Display Hello
  LCD.home                      'Home the position
  LCD.pos(3,10)                  'Move to the third line
  LCD.writestr(@char7string)
  LCD.uSdelay(2_000_000)        'Delay 2 seconds
  LCD.writecgline(7,0,@change71)'Change character 7    
  LCD.uSdelay(2_000_000)        'Delay 2 seconds
  LCD.writecgline(7,0,@change72)'Change character 7
  LCD.pos(4,1)
  LCD.writestr(@byebye)
  LCD.uSdelay(2_000_000)        'Delay 2 seconds
  LCD.writecgline(7,0,@change73)'Change character 7
  LCD.cll                       'Clear the current line  
  repeat                        'Just sit and run
  
dat
  text        byte "Line 1",cr,eos
  next1       byte "Line 2",lf,eos
  try1        byte "Third Line",eos
  last        byte "Line Four",cr,eos
  line5       byte "Line five on line 4",cr,eos
  try2        byte "New screen after cls",eos
  blinkon     byte "The cursor is on",eos
  blinkoff    byte "off",cr,eos
  ornot       byte "Or not",eos
  char0       byte $05,$05,$0D,$15,$0F,$05,$05,$05      'CG Ram data
  char1       byte $00,$00,$04,$0A,$1C,$04,$02,$01
  char2       byte $04,$0A,$0A,$0A,$0A,$0A,$04,$1B
  char3       byte $04,$0A,$0A,$0A,$0A,$0A,$04,$1B
  char4       byte $00,$00,$00,$0E,$11,$11,$0E,$10
  char5       byte $00,$11,$04,$00,$04,$0A,$04,$00
  char6       byte $1B,$00,$04,$00,$1F,$00,$00,$00
  char7       byte $1B,$00,$04,$11,$0E,$11,$00,$00,eog
  escapechar  byte "Graphics characters",cr,0," ",1," ",2," ",3
              byte 4," ",5," ",6," ",7,cr,eos
  hello       byte 5," ",0,1,2,3,4,"!",eos
  char7string byte 7,cr,"Changing Character 7",eos
  byebye      byte " Bye-bye Character 7",eos
  graphictest byte "   Graphics test",cr,eos
  change71    byte $1F,$1B,$15,$11,$1B,$1F,$1B,$1F,eog
  change72    byte $00,$00,$0E,$0E,$0E,$0E,$00,$00,eog
  change73    byte $00,$00,$00,$00,$00,$00,$00,$00,eog
               