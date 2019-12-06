'' parallel lcd driver
'' for using a HD44780 based 4 x 20 parallel lcd
'' dan miller 23 july 2006
''
{{
           10k    5v                                  +--+
            +?----?--------------------------------+  ¦  ¦
  +------+  ¦??+                                   ¦  ¦  ?grd            nibble ops msb first
  ?      ?--¦• ¦     10                   13    15 ¦  ¦  
 grd     ¦  ¦  ¦  11 ¦  9              12 ¦  14 ¦  ¦  ??-+ 100
         ¦  ¦  ¦  ¦  ¦  ¦              ¦  ¦  ¦  ¦  ¦  ?  ¦
         ¦  ¦  ¦  ¦  ¦  ¦              ¦  ¦  ¦  ¦  ¦  ?--+
      +--¦--¦--¦--¦--¦--¦--¦--¦--¦--¦--¦--¦--¦--¦--¦--¦--+               
    1 ¦  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  ¦  16    LCD
         v  v  v  r  r  e  D  D  D  D  D  D  D  D  V  V
         s  c  l  s  /  n  0  1  2  3  4  5  6  7  B  B
         s  c  c     w                             +  -


         
}} 
con


  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000

' -------------------------------------------------------------------------
' IO Pins
' -------------------------------------------------------------------------

                                            ' LCD bus is 12..15
E               =     9                     ' Enable Bit
RW              =     10                    ' Read Write Bit
RS              =     11                    ' Register Select Bit
obj

 delay    : "timing"
 bs2      : "BS2_Functions"    
var
' -------------------------------------------------------------------------
' Variables
' -------------------------------------------------------------------------

byte char                       ' Character To Send To LCD
byte inst                       ' Instuction To Send To LCD
byte index[2]                   ' Character Pointer




{{ usage - uncomment the 'tester  located below to run and test this module by itself'
          otherwise, with the line tester commented out, use start thusly -->

            term      : "parallel_lcd" 

              term.start
          repeat                        
            term.out($00)                ' clear screen
            term.str(string("Dan's Sawmill "))
            term.pos(0,2)                        ' second line, pos 0
            term.str(string("Sawmill head height"))
  
            display_height(0,3)                   ' third line , pos 0
            term.out($22)                          ' the " char
            term.pos(0,4)                          ' fourth line, pos 0
            term.str(string("2nd key for more"))
         
            ( a example from one of my programs )
 }}

pub Start  | temp 
  
  waitcnt(clkfreq * 1 + cnt)                        ' let lcd come up  
    dira[8..15] := %11111111                            ' Make  Output.
    
    outa[RS] := 0
    outa[RW] := 0
    
   
    Init_Lcd
    'tester                                       ' code to check module by itself
    
pub tester  | temp
  
  repeat  temp  from 0 TO 14                   ' 14 Characters in test line
    IF temp == 19                               ' Check For End Of Line
       Next_Line                                ' Jump To Next Line
     
    char := Text[temp]                           ' Read Next Character From EEPROM
    Send_Text                                   ' Send Character To LCD Display


PUB str(stringptr)

'' Print a zero-terminated string

  repeat strsize(stringptr)
    out(byte[stringptr++])


PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    out("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      out(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      out("0")
    i /= 10

PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    out((value <-= 1) & 1 + "0")

  
PUB out(c) | i, k

'' Output a character
''
''     $00 = clear screen
''     $01 = home
''     $08 = backspace
''     $09 = tab (8 spaces per)
''     $0D = return
''     $0A = cursor
''     $0B = no cursor
''  others = printable characters

    case c
           $00:
             Inst := %0000_0001                      ' cursor home , clear display
             Send_Inst
           
           $01:
             Inst := %0000_0010                      ' cursor home 
             Send_Inst
             
           $08:
             Inst := %0001_0000                      ' backspace
             Send_Inst
             
           $09: repeat
                  char := 32
                  Send_Text
                  
 
           $0D:
             next_line
             
           $0A :
               Inst := %0000_1111                     ' cursor blink
               Send_Inst
               
           $0B :
               Inst := %0000_1100                      ' no cursor, no blink
               Send_Inst
               
           other:
              char := c
              Send_Text
  
pri  Init_Lcd

  delay.pause1ms(200)
  outa[15..8] := %00000000                       ' Reset The LCD
  bs2.PULSOUT(E,1)                           ' Send Command Three Times
  Wait_Busy
  bs2.PULSOUT(E,1)
  Wait_Busy
  bs2.PULSOUT(E,1)
  Wait_Busy
  
  outa[15..12] := %0010                     ' Set To 4-bit Operation
  bs2.PULSOUT(E,1)
  
  delay.pause1ms(200)
    
  'Inst := %00101000                      ' Function Set (4-Line Mode)
  Inst := %00101100
  Send_Inst
  Inst := %0000_0001                      ' cursor home , clear display
  Send_Inst
  Inst := %0000_1100                      ' no Cursor, no blink
  Send_Inst
  
 

pri Send_Inst | temp1            ' can we use byte move, then shift up 4 times ?

    temp1 := Inst
    temp1 := temp1>>4
    
  outa[RS] := 0                                ' Set Instruction Mode
  outa[15..12] := temp1                       ' Send High Nibble
  bs2.PULSOUT(E,3)
  Wait_Busy
  outa[15..12] := Inst                        ' Send Low Nibble
  bs2.PULSOUT(E,3)
  Wait_Busy
  outa[RS] := 1                               ' Set LCD Back To Text Mode
 

pri Send_Text   | temp1

    
    temp1 := Char
    temp1 := temp1>>4
    
  outa[RS] := 1                               ' Set data Mode   
  outa[15..12] := temp1                        ' Send High Nibble
 
  bs2.PULSOUT(E,10)
  
  Wait_Busy
  outa[15..12] := Char                        ' Send Low Nibble
  
  bs2.PULSOUT(E,10)
  
  Wait_Busy
  outa[RS] := 0
 

pub Next_Line
  
     Inst := %11000000                         ' Move Cursor To Line 2
                        
  Send_Inst
 

pub Wait_Busy

  delay.pause1ms(10)


{{
Older 4x20 LCD displays, like the Optrex I'm using, have different line layout:

0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 
40 .. .. .. .. .. .. .. .. .. 49 .. .. .. .. .. .. .. .. 59 
20 .. .. .. .. .. .. .. .. .. 30 .. .. .. .. .. .. .. .. 39 
60 .. .. .. .. .. .. .. .. .. 70 .. .. .. .. .. .. .. .. 79 

Notice that the lines 1 and 3 follow each other. Line 2 is followed by line 4.
So basically when filling all character positions, the lines will be filed in this order:
 line 1, line 3, line 2 and finally line 4.  }}

pub pos(x,y) | counter

                                                        '' ============================
                                                        '' position cursor at position (X,Y)
                                                        '' ============================
                                                        '' Usage:
                                                        '' horizontal position or column (X)
                                                        '' vertical position or line (Y)

  Inst := %0000_0010                      ' cursor home 
  Send_Inst
  counter := 0                            ' reset counter

  case y
  
    1 :   '4x20: row1
                 counter := %00000000
                 counter := counter + X 
                 Inst := %10000000 + counter 
                 Send_Inst
                  
    2 :
     ' 4x20: row2 
                 counter := %01000000
                 counter := counter + X - 1
                 Inst := %10000000 + counter 
                 Send_Inst
    3 :
      ' 4x20: row3 
                 counter := %00010101
                 counter := counter + X - 1
                 Inst := %10000000 + counter 
                 Send_Inst
    4 :
     ' 4x20: row4 
                 counter := %01010101
                 counter := counter + X - 1
                 Inst := %10000000 + counter 
                 Send_Inst
                 
 


  
dat
  Text byte "Dan's Sawmill "     ' Message To Send To LCD     