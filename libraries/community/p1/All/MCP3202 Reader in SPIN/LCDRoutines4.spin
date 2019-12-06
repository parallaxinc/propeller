{{21 Sep 09     Harprit Sandhu  
LCDRoutines4.spin

LCD ROUTINES for a 4 bit data path.      

The following are the names of the methods described in this program
  INITIALIZE_LCD
  PRINT (the_line)
  POSITION (LINE_NUMBER, HOR_POSITION) | CHAR_LOCATION
  SEND_CHAR (DISPLAY_CHAR)
  SEND_CHAR (DISPLAY_CHAR)
  PRINT_DEC (VALUE) | TEST_VALUE
  PRINT_HEX (VALUE, DIGITS)
  PRINT_BIN (VALUE, DIGITS)
  CLEAR
  HOME
  SPACE (QTY)

Revisions
  04 Oct 09  Initialize made more robust, misc unnecessary calls removed.
  
}} 
CON                             'all the constants used by all the METHODS 
                                'in this program have to be listed here             
  _CLKMODE=XTAL1 + PLL2X        'The system clock spec
  _XINFREQ   = 5_000_000        '10 Mhz
  DataBit4   = 12               'are named so that they can be called by
  DataBit5   = 13               'name if the need ever arises
  DataBit6   = 14
  DataBit7   = 15                                 
  RegSelect  = 16               'The three control lines           
  ReadWrite  = 17               '            
  Enable     = 18               '
  high       =1                 {define the High state}
  low        =0                 {define the Low state}   
  Inv_high   =0                 {define the Inverted High state}
  Inv_low    =1                 {define the Inverted Low state}

VAR                             'these are the variables we will use.
   byte  temp                   'for use as a pointer
   byte  index                  'to count characters

PUB Go
  INITIALIZE_LCD 
  repeat           
    print(String("4bit mode line 1"))
    position(2,1)
    print(String("4bit mode line 2"))
    waitcnt(clkfreq/4+cnt)
    clear
    waitcnt(clkfreq/4+cnt) 
'===================================================================================                                                                                                                                                                                            
{{initialize the LCD to use 4 lines of data
Includes a half second delay, clears the display and positons to 1,1
no variables used
}}
PUB INITIALIZE_LCD                'The addressses and data used here are
  waitcnt(150_000+cnt)            'specified in the Hitachi data sheet for the
  DIRA[DataBit4..Enable]~~        'display. YOU MUST CHECK THIS FOR YOURSELF.
  SEND_INSTRUCTION (%0011)        'Send 1
  waitcnt(49_200+cnt)             'wait                               
  SEND_INSTRUCTION (%0011)        'Send 2
  waitcnt(1_200+cnt)              'wait                
  SEND_INSTRUCTION (%0011)        'Send 3
  waitcnt(12_000+cnt)             'wait
  SEND_INSTRUCTION (%0010)        'set for 4 bit mode
  waitcnt(12_000+cnt)             'wait
    
  SEND_INSTRUCTION2 (%0010_1000)    'Sets DL=8 bits, N=2 lines, F=5x7 font 
 ' waitcnt(12_000+cnt)              'wait 
  SEND_INSTRUCTION2 (%0000_1110)    'Display on, Blink on, Sq Cursor off 
 ' waitcnt(12_000+cnt)              'wait
  SEND_INSTRUCTION2 (%0000_0110)    'Move Cursor, Do not shift display 
 ' waitcnt(12_000+cnt)              'wait 
  SEND_INSTRUCTION2 (%0000_0001)    'clears the LCD
  'waitcnt(12_000+cnt)              'wait  
  POSITION (1,1)
'===================================================================================                                                                                                                                                                                              
{{Sends instructions as opposed to a character to the LCD
no variables are used
}}                                                                       
PUB SEND_INSTRUCTION (D_DATA)    'set up for writing instructions
  CHECK_BUSY                           'wait for busy bit to clear before sending
  OUTA[ReadWrite] := 0                 'Set up to read busy bit         
  OUTA[RegSelect] := 0                 'Set up to read busy bit         
  OUTA[Enable]    := 1                 'Set up to toggle bit H>L
  OUTA[DataBit7..DataBit4] := D_DATA   'Ready to READ data in
  OUTA[Enable]    := 0                 'Toggle the bit H>L to xfer the data                               
'===================================================================================                                                                                                                                                                                              
{{Sends an instruction as opposed to a character to the LCD
no variables are used
}}                                                                       
PUB SEND_INSTRUCTION2 (D_DATA)    'set up for writing instructions
  CHECK_BUSY                           'wait for busy bit to clear before sending
  OUTA[ReadWrite] := 0                 'Set up to read busy bit         
  OUTA[RegSelect] := 0                 'Set up to read busy bit         
  OUTA[Enable]    := 1                 'Set up to toggle bit H>L
  OUTA[DataBit7..DataBit4] := D_DATA>>4   'Ready to READ data in
  OUTA[Enable]    := 0                 'Toggle the bit H>L to xfer the data    
  OUTA[Enable]    := 1                 'Set up to toggle bit H>L
  OUTA[DataBit7..DataBit4] := D_DATA   'Ready to READ data in
  OUTA[Enable]    := 0                 'Toggle the bit H>L to xfer the data
'==================================================================================          
{{Sends a single character to the LCD in two halves
}}
PUB SEND_CHAR (D_CHAR)           'set up for writing to the display    
  CHECK_BUSY                           'wait for busy bit to clear before sending
  OUTA[ReadWrite] := 0                 'Set up to read busy bit
  OUTA[RegSelect] := 1                 'Set up to read busy bit
  OUTA[Enable]    := 1                 'Set up to toggle bit H>L
  OUTA[DataBit7..DataBit4] := D_CHAR>>4
 ' waitcnt(12_000+cnt)
  OUTA[Enable]    := 0
  OUTA[Enable]    := 1   
  OUTA[DataBit7..DataBit4] :=D_CHAR 
  OUTA[Enable]    := 0                 'Toggle the bit H>L
'===================================================================================
{{Print a line of characters to the LCD
uses variables index and temp
}}                                                                 
PUB PRINT (the_line)                   'This routine handles more than one Char at a time
'called as PRINT(string("the_line"))   '"the_line" contains the pointer to line. Line is
'because we have to point to the line  'zero terminated but we will not use that.  We will
                                       'use the string size instead. Easier to understand
  index:=0                             'Reset the counter we are using to count chars sent
  repeat                               'repeat for all chars in the list
    temp:= byte[the_line][index++]     'temp contains the char/byte pointed to by the index
    SEND_CHAR (temp)                   'send the 'pointed to' char to the LCD
  while index<strsize(the_line)        'keep doing it till the last char is sent 
'===================================================================================
{{Position cursor
}}
PUB POSITION (LINE_NUMBER, HOR_POSITION) | CHAR_LOCATION  'Position the cursor at location
  'Horizontal Position : 1 to 16       'specified by the two numbers
  'Line Number : 1 or 2        
  CHAR_LOCATION := (LINE_NUMBER-1) * 64   'figure location. See Hitachi HD44780 data sheet
  CHAR_LOCATION += (HOR_POSITION-1) + 128 'figure location. See Hitachi HD44780 data sheet
  SEND_INSTRUCTION2 (CHAR_LOCATION)     'send the instruction to position cursor
'===================================================================================           
{{Check for busy
}}
PUB CHECK_BUSY | BUSY_BIT              'routine to check busy bit
  OUTA[ReadWrite] := 1                 'Set to read the busy bit         
  OUTA[RegSelect] := 0                 'Set to read the busy bit
  DIRA[DataBit7..DataBit4] := %0000    'Set the entire port to be an input         
  REPEAT                               'Keep doing it till clear
    OUTA[Enable]  := 1                 'set to 1 to get ready to toggle H>L this bit
    BUSY_BIT := INA[DataBit7]          'the busybit is bit 7 of the byte read
                                       'INA is the 32 input pins on the PROP and we
                                       'are reading data bit 7 which is on pin 15!
    OUTA[Enable]  := 0                 'make the enable bit go low for H>L toggle
  WHILE (BUSY_BIT == 1)                'do it as long as the busy bit is 1
  DIRA[DataBit7..DataBit4] := %1111      'done, so set the data port back to outputs   
'===================================================================================
{{Print decimal value
}}
PUB PRINT_DEC (VALUE) | TEST_VALUE     'for printing values in decimal format
  IF (VALUE < 0)                       'if it is a negative value             
    -VALUE                             'change it to a positive
    SEND_CHAR("-")                     'and print a - sign on the LCD
  TEST_VALUE := 1_000_000_000          'we get individual digits by comparing to this
                                       'value and then dividing by 10 to get the next value
  REPEAT 10                            'There are 10 digits maximum in our system
    IF (VALUE => TEST_VALUE)           'see if our number is bigger than testValue
      SEND_CHAR(VALUE / TEST_VALUE + "0")     'if it is, divide to get the digit 
      VALUE //= TEST_VALUE             'figure the next value for the next digit
      RESULT~~                         'result of what just did so we can pass it on below
    ELSEIF (RESULT OR TEST_VALUE == 1) 'if the result was a 1 then division was even
      SEND_CHAR("0")                   'so we sent out a zero
    TEST_VALUE /= 10                   'we divide by 10 to test for the next digit
                                       '                                             
'===================================================================================
{{Print Hexadecimal value
}}
PUB PRINT_HEX (VALUE, DIGITS)          'for printing values in HEX format
  VALUE <<= (8 - DIGITS) << 2          'you can specify up to 8 digits or FFFFFFFF max
  REPEAT DIGITS                        'do each digit
    SEND_CHAR(LOOKUPZ((VALUE <-= 4) & $F : "0".."9", "A".."F"))
                                       'use lookup table to select character
'===================================================================================
{{Print Binary value
}}                                              '
PUB PRINT_BIN (VALUE, DIGITS)          'for printing values in BINARY format
  VALUE <<= 32 - DIGITS                '32 binary digits is the max for our system
  REPEAT DIGITS                        'Repeat for each digit desired
    SEND_CHAR((VALUE <-= 1) & 1 + "0") 'send a 1 or a 0
'===================================================================================
{{Clear screen
}}    
PUB CLEAR                              'Clear the LCD display and go home
  SEND_INSTRUCTION2 (%0000_0001)       'This is the clear screen and go home command
'===================================================================================
{{Go to position 1,1   Does not clear the screen
}}  
PUB HOME                               'go to position 1,1.  
  SEND_INSTRUCTION2 (%0000_0011)       'Not cleared
'===================================================================================
{{Print spaces
}}
PUB SPACE (qty)                        'Prints spaces, for between numbers 
  repeat (qty)
    PRINT(STRING(" "))
'===================================================================================
{{
}}                   