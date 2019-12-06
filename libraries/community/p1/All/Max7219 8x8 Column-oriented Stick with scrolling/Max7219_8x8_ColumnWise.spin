{Drive a stick of MAX7219 8x8 modules.
Assumes modules are wired so that a write to a data register
affects a column of LEDs.
Configuration bits allow modules swap, columns within modules, bits within columns}
CON
        _clkmode = xtal1 + pll16x    'Standard clock mode 
        _xinfreq = 5_000_000         '* crystal frequency = 80 MHz
        
'*********************configuration constants*********************
        #0, ModBit, ColBit, BitBit            'bit positions of flags

VAR
  long  MyParm[6]                      'passing addresses, etc to display driver
  byte  cog
  byte  ascii, colcount                'current character, current column within character
  long  TextPoint                      'pointer into message
  long  delay                          'time between columns in approx millisec
  long  Command                       '$8000_xxxx    'display frame
                                      '$4000_000x    'set brightness
  long  NmbrCols                      'number of columns to operate on                                    

  
PUB start(CS, Clk, D, NMax, Cf) : success
    {start new process; return true if successful:   Input parameters
      CS:  Max chip select pin
      Clk: Max clock pin
      D:   Max Data pin
      NMax:  Number of Max7219's in string
      Cf:  Maxfiguration code
            Bit 0: Swap modules
            Bit 1: Swap columns within modules
            Bit 2: Swap bits with columns}

    stop                                  'standard startup            
    delay := 50                           'initially pretty slow scroll
    NmbrCols := NMax * 8                  'get my copy of number of columns
    MyParm[0] := CS | (Clk << 8) | (D << 16) | (NMax << 24)
    MyParm[1] := @Command              'address of command long (in this object)
    MyParm[2] := Cf                    'the three configuration bits                            
    success := (cog := cognew(@PCog, @MyParm) +1)    'start up the output cog    

pub stop
    if cog
       cogstop(cog~ -1)       'mandatory stop method

pub  WriteMessage(MyPoint, BAdrs) 'write a zero-terminated string followed by five blanks
     {MyPoint is the beginning address of the string
      BAdrs is the address of the buffer
      Note this address gets passed all the way through to the PASM cog
      as well as being used locally}
     repeat                   'until you come to a zero
        Ascii := byte[MyPoint++]   'get next character
        if (Ascii == 0)
          repeat 5                'space between messages
            writeChar(" ", BAdrs)    
          return                 'all done
        writechar(Ascii, BAdrs)         'scroll character onto screen

pub  writeChar(TheChar, MyBuff)                        'scroll one character onto the screen
     repeat colcount from 0 to 4
        bytemove(MyBuff+1, MyBuff, NmbrCols-1)  'make room for new column
        byte[MyBuff] := byte[@C20 + colcount + (5* (TheChar - $20))]   'insert new column from font
        WriteArray(MyBuff)                        'display it
        repeat delay
           waitcnt(clkfreq/1000 + cnt)          'slow down
     bytemove(MyBuff+1, MyBuff, NmbrCols-1)     'make room for space
     Byte[MyBuff] := 0                          'between letters
     WriteArray(MyBuff)
     repeat delay 
        waitcnt(clkfreq/1000 + cnt)

Pub WriteArray(whence)
    Command := whence | $8000_0000             'display frame
    repeat while (Command <> 0)                'return as soon as PASM fetches buffer
    
pub  SetDelay(val)                            'set millisec between columns
     delay := val

pub  SetBright(val)                           'set brightness 0..15
     command := $4000_0000 | val              'issue command 
     repeat while (command <> 0)              'await completion                    
   

DAT
PCog    org   0                'This PASM loads a string of MX7219's
        mov AdPar,Par          'get the address of input parameters
        rdlong Pins, AdPar     'get the three pin numbers and the number of Maxes
        add AdPar, #4
        rdlong AdCommand, AdPar  'address of command long
        Add AdPar, #4
        rdlong ConfigMask, AdPar  'get the three configuration bits             
        mov work1, Pins          'get the pins number
        and work1,#$FF           'CS pin number
        mov CSMask, #1           'make a mask with a single bit set
        shl CSMask, work1        'by shifting into proper position
        or outa, CSMask          'start out with CS high
        or dira, CSMask          'and enable it
        mov work1, Pins          'now the clock pin
        shr work1, #8
        and work1,#$FF           
        mov ClockMask, #1        
        shl ClockMask, work1
        or dira, ClockMask
        mov work1, Pins          'and the data pin
        shr work1, #16
        and work1,#$FF           
        mov DataMask, #1         
        shl DataMask, work1
        or dira, DataMask          'data pin and clock pin start out low
        mov work1, Pins            'finally, see how many maxes we have
        shr work1, #24
        and work1, #$7F             'number maxes
        mov NmbrMaxes, work1       'save it
         
        mov MyCommand, Shutdown    'get initial control
        call #Commo                'send to all 16 modules
        mov MyCommand, TestOff     'turn off lamp test if possible 
        call #Commo 
        mov MyCommand, Decode      'turn off 7-segment decoding
        call #Commo
        mov MyCommand, Intens      'template
        call #Commo
        mov MyCommand, SLimit       'all drivers
        call #Commo
        mov Mycommand, Normal      'normal operation
        call #Commo

'*********************wait here for something to do*************************                                                   
top     rdlong MyCommand, AdCommand wz  'wait for a command
        if_Z jmp #top                   'just hand here  
        test MyCommand, RComnd wz       'test for refresh command
        if_NZ jmp #SL 
        test MyCommand, BComnd wz        'set brightness display
        if_NZ jmp #Bright
        jmp #top                         'command not recognized

'*************get a copy of the frame buffer into cog memory and release boss cog
SL      mov FBPointer, MyCommand         'contains address in hub memory
        and FBPointer, HubMask           'address alone
        mov SLn1, GSLInst                'nice fresh copy of read instruction                                         
        mov SLCount, NmbrMaxes           'how many columns to fetch
        shl SLCount, #3                  'eight columns per max
SLn1    rdbyte MyFrame, FBPointer         'modified instruction         
        add SLn1, NextLong                'points to next long in MyFrame
        add FBPointer, #1                 'next byte in hub memory
        djnz SLCount, #SLn1               'eight time number maxes times
        wrlong zero, AdCommand          'finished fetching frame buffer: release boss cog
  
'******************now write the screen from the local frame buffer***********     
        mov RegCount, #8                'will do eight registers
RegLoop andn outa, CSMask               'make CS active  
        mov ChipCount, NmbrMaxes        'will do n MXs
ModLoop mov shifter, #9                 'we will form the load register instruction here 
        sub shifter, RegCount           '1,2,3...  
        shl shifter, #8                 'the register number aligned
        test ConFigMask, SModMask wz    'set zero flop according to swap/no swap        
        if_z mov work1, NmbrMaxes       'no swap case
        if_z sub work1, ChipCount       'module number
        if_NZ mov work1, ChipCount      'swap case
        if_NZ sub work1, #1
        shl work1, #3                   'times 8  We now are pointing at the right module
        test ConFigMask, SColMask wz    'now decide how to handle the column
        if_Z add work1, regcount        'no swap case plus register
        if_Z sub work1, #1              'less one
        if_NZ add work1, #8             'swap case
        if_NZ sub work1, regcount
        add work1, #MyFrame             'beginning of frame
        movs GByte, work1               'insert into instruction
        nop                             'lookahead   
GByte   mov Work1, 0-0                  'get this column
        test ConfigMask, SBitMask wz    'see if we need to swap bits
        if_NZ rev work1, #24            'swap bits if needful 
        or shifter, work1               'merge into load register instruction
        call #SWLeft                    'send one register worth to current module
        djnz ChipCount, #ModLoop        'send data to 16 modules
        or outa, CSMask                 'take away chip select
        nop
        nop
        djnz RegCount, #RegLoop                
        jmp #top                        'all done go look for more to do
        
'**********************rotate the frame buffer left one bit******


'********************set brightness***************
Bright  and MyCommand, #$F               'keep just the intensity
        or MyCommand, Intens             'template
        call #Commo                       'for everyone                                 
        wrlong zero, AdCommand           'all done
        jmp #top
                        
'*********************will send identical command all 16 modules        
Commo   mov ChipCount, NmbrMaxes            
        andn outa, CSMask             'make cs active
ComLP   mov shifter, MyCommand        'get a copy of the command
        call #SWLeft                  'and serialize it
        djnz ChipCount, #ComLP        '16 times
        or outa, CSMask
        nop
        nop
        nop
Commo_Ret ret                

SWLeft  mov BitC, #16                 'serialize shifter to left for 16 bits
        shl shifter, #16             'put value in left-most 16 bits 
SBLoop  rol shifter, #1 wc            'put high order bit into carry
        muxc outa,DataMask            'and then onto pin
        nop                             'data setup
        nop
        or outa, ClockMask              'clock hi
        nop
        nop
        andn outa, ClockMask            'clock goes low
        djnz BitC, #SBLoop              'for sixteen bits
SWLeft_Ret  ret                        'and return                                            

zero        long     0               'constants                                            
ShutDown    long     $0C00           'shutdown mode command
TestOff     long     $0F00           'test mode off
Normal      long     $0C01           'normal operation
Decode      long     $0900           'no decode
Intens      long     $0A00           'intensity template
SLimit      long     $0B07           'display all segments
RComnd      long     $8000_0000      'refresh command
BComnd      long     $4000_0000      'set brightness
GSLInst     rdbyte MyFrame, FBPointer  'Get byte from hub
NextLong    long     $200            'next location in myframe
HubMask     long     $7FFFF          'mask for an address in hub memory
SModMask    long     1 << ModBit     'mask for swap module configuration bit
SColMask    long     1 << ColBit
SBitMask    long     1 << BitBit         
AdPar       res                      'address into parameter list
Pins        res                      'the pins
AdCommand   res                      'address of command byte
CSMask      res                      'masks for the three pins
ClockMask   res
DataMask    res
MyCommand   res                      'my copy; also used by commo
Work1       res
Work2       res
ChipCount   res                      'number of MxChips
NmbrMaxes   res                      'number of maxes
Shifter     res                      'variable being shifted
BitC        res                      'shifter bit count 
MyCnt       res                      'used to time serializer
SLCount     res                      'counts scan lines
FBPointer   res                      'points into frame buffer 
RegCount    res                      'we will do eight registers
'SwapEm      res                      '1 says we will invert the module order
ConfigMask  res                      'the three configuration bits   
MyFrame     res      128             'my copy of max size frame buffer
            fit      300




DAT                         'This defines a five by seven plus descenders font
'Each byte is one column
C20   BYTE  %0000000, %0000000, %0000000, %0000000, %0000000  'Space
C21   BYTE  %0000000, %0000000, %1001111, %0000000, %0000000  'Exclamation
C22   BYTE  %0000000, %0000111, %0000000, %0000111, %0000000  'full quote
C23   BYTE  %0010010, %1111111, %0010100, %1111111, %0010100  'pound sign
C24   BYTE  %0100010, %0101010, %1111111, %0101010, %0010010  'dollar sign
C25   BYTE  %0100011, %0010011, %0001000, %1100100, %1100010  'percent sign
C26   BYTE  %0110110, %1001001, %1001001, %0100010, %1010000  'ampersand
C27   BYTE  %0000000, %0000101, %0000011, %0000000, %0000000  'single quote
C28   BYTE  %0000000, %0011100, %0100010, %1000001, %0000000  'open para
C29   BYTE  %0000000, %1000001, %0100010, %0011100, %0000000  'close para
C2A   BYTE  %0010100, %0001000, %0111110, %0001000, %0010100  'asterik
C2B   BYTE  %0001000, %0001000, %0111110, %0001000, %0001000  'plus
C2C   BYTE  %0000000, %11010000, %0110000, %0000000, %0000000   'comma
C2D   BYTE  %0001000, %0001000, %0001000, %0001000, %0001000  'minus
C2E   BYTE  %0000000, %1100000, %1100000, %0000000, %0000000  'period
C2F   BYTE  %0100000, %0010000, %0001000, %0000100, %0000010  'slash
C30   BYTE  %0111110, %1010001, %1001001, %1000101, %0111110  '0
C31   BYTE  %0000000, %1000010, %1111111, %1000000, %0000000  '1
C32   BYTE  %1000010, %1100001, %1010001, %1001001, %1000110  '2
C33   BYTE  %0100001, %1000001, %1000101, %1001011, %0110001  '3
C34   BYTE  %0011000, %0010100, %0010010, %1111111, %0010000  '4
C35   BYTE  %0100111, %1000101, %1000101, %1000101, %0111001  '5
C36   BYTE  %0111100, %1001010, %1001001, %1001001, %0110000  '6
C37   BYTE  %0000001, %1110001, %0001001, %0000101, %0000011  '7
C38   BYTE  %0110110, %1001001, %1001001, %1001001, %0110110  '8
C39   BYTE  %0000110, %1001001, %1001001, %0101001, %0011110  '9
C3A   BYTE  %0000000, %0110110, %0110110, %0000000, %0000000  'colon
C3B   BYTE  %0000000, %11010110, %0110110, %0000000, %0000000  'semi-colon
C3C   BYTE  %0001000, %0010100, %0100010, %1000001, %0000000   'less than
C3D   BYTE  %0010100, %0010100, %0010100, %0010100, %0010100   'equal
C3E   BYTE  %0000000, %1000001, %0100010, %0010100, %0001000   'greater than
C3F   BYTE  %0000010, %0000001, %1010001, %0001001, %0000110   'question mark
C40   BYTE  %0110010, %1001001, %1111001, %1000001, %0111110   'at sign
C41   BYTE  %1111110, %0010001, %0010001, %0010001, %1111110   'A
C42   BYTE  %1111111, %1001001, %1001001, %1001001, %0110110   'B
C43   BYTE  %0111110, %1000001, %1000001, %1000001, %0100010   'C
C44   BYTE  %1111111, %1000001, %1000001, %0100010, %0011100   'D
C45   BYTE  %1111111, %1001001, %1001001, %1001001, %1001001   'E
C46   BYTE  %1111111, %0001001, %0001001, %0001001, %0000001   'F
C47   BYTE  %0111110, %1000001, %1001001, %1001001, %1111010   'G
C48   BYTE  %1111111, %0001000, %0001000, %0001000, %1111111   'H
C49   BYTE  %0000000, %1000001, %1111111, %1000001, %0000000   'I
C4A   BYTE  %0100000, %1000000, %1000001, %0111111, %0000001   'J
C4B   BYTE  %1111111, %0001000, %0010100, %0100010, %1000001   'K
C4C   BYTE  %1111111, %1000000, %1000000, %1000000, %1000000   'L
C4D   BYTE  %1111111, %0000010, %0001100, %0000010, %1111111   'M
C4E   BYTE  %1111111, %0000100, %0001000, %0010000, %1111111   'N
C4F   BYTE  %0111110, %1000001, %1000001, %1000001, %0111110   'O
C50   BYTE  %1111111, %0001001, %0001001, %0001001, %0000110   'P
C51   BYTE  %0111110, %1000001, %1010001, %0100001, %1011110   'Q
C52   BYTE  %1111111, %0001001, %0011001, %0101001, %1000110   'R
C53   BYTE  %1000110, %1001001, %1001001, %1001001, %0110001   'S
C54   BYTE  %0000001, %0000001, %1111111, %0000001, %0000001   'T
C55   BYTE  %0111111, %1000000, %1000000, %1000000, %0111111   'U
C56   BYTE  %0011111, %0100000, %1000000, %0100000, %0011111   'V
C57   BYTE  %0111111, %1000000, %0111000, %1000000, %0111111   'W
C58   BYTE  %1100011, %0010100, %0001000, %0010100, %1100011   'X
C59   BYTE  %0000111, %0001000, %1110000, %0001000, %0000111   'Y
C5A   BYTE  %1100001, %1010001, %1001001, %1000101, %1000011   'Z
C5B   BYTE  %0000000, %1111111, %1000001, %1000001, %0000000   'open brackett
C5C   BYTE  %0000100, %0001000, %0010000, %0100000, %1000000   'backslash
C5D   BYTE  %0000000, %1000001, %1000001, %1111111, %0000000   'close brackett
C5E   BYTE  %0000100, %0000010, %0000001, %0000010, %0000100   'tilde
C5F   BYTE  %1000000, %1000000, %1000000, %1000000, %1000000   'Underscore
C60   BYTE  %0000000, %0000001, %0000010, %0000100, %0000000   'quote
C61   BYTE  %0100000, %1010100, %1010100, %1010100, %1111000   'a
C62   BYTE  %1111111, %1010000, %1001000, %1001000, %0110000   'b
C63   BYTE  %0111000, %1000100, %1000100, %1000100, %0100000   'c
C64   BYTE  %0110000, %1001000, %1001000, %1010000, %1111111   'd
C65   BYTE  %0111000, %1010100, %1010100, %1010100, %0011000   'e
C66   BYTE  %0001000, %1111110, %0001001, %0000001, %0000010   'f
C67   BYTE  %00011000, %10100100, %10100100, %10100100, %01111100   'g
C68   BYTE  %1111111, %0001000, %0000100, %0000100, %1111000    'h
C69   BYTE  %0000000, %0000000, %1111010, %0000000, %0000000    'i
C6A   BYTE  %1100000, %10000000, %10000100, %1111101, %0000000  'j
C6B   BYTE  %1111111, %0010000, %0101000, %1000100, %0000000    'k
C6C   BYTE  %0000000, %1000001, %1111111, %1000000, %0000000    'l
C6D   BYTE  %1111100, %0000100, %0011000, %0000100, %1111000    'm
C6E   BYTE  %1111100, %0001000, %0000100, %0000100, %1111000    'n
C6F   BYTE  %0111000, %1000100, %1000100, %1000100, %0111000    'o
C70   BYTE  %11111100, %00100100, %00100100, %00100100, %00011000   'p
C71   BYTE  %00010000, %00101000, %00101000, %00011000, %11111100  'q
C72   BYTE  %1111100, %0001000, %0000100, %0000100, %0001000   'r
C73   BYTE  %1001000, %1010100, %1010100, %1010100, %0100000   's
C74   BYTE  %0000100, %0111111, %1000100, %1000000, %0100000   't
C75   BYTE  %0111100, %1000000, %1000000, %0100000, %1111100   'u
C76   BYTE  %0011100, %0100000, %1000000, %0100000, %0011100   'v
C77   BYTE  %0111100, %1000000, %0110000, %1000000, %0111100   'w
C78   BYTE  %1000100, %0101000, %0010000, %0101000, %1000100   'x
C79   BYTE  %0001100, %10010000, %10010000, %10010000, %1111100  'y
C7A   BYTE  %1000100, %1100100, %1010100, %1001100, %1000100    'z
C7B   BYTE  %0000000, %0001000, %0110110, %1000001, %0000000    'Open brace
C7C   BYTE  %0000000, %0000000, %1111111, %0000000, %0000000    'stroke
C7D   BYTE  %0000000, %1000001, %0110110, %0001000, %0000000    'close brace
C7E   BYTE  %0001100, %0000010, %0001100, %0010000, %0001100    '
C7F   BYTE  %0111110, %0111110, %0111110, %0111110, %0111110    'delete                       
                                                       