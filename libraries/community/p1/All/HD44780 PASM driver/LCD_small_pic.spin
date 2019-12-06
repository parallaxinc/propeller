con
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

  LCDBasePin    = 8
  LEDOnPin      = 255

{{
HOW TO USE:
===========
Attach a 16x4 display to the propeller and change the base pin constant above accordingly.
For a 16x2 display you'll have to move the graphics window one lin up.
If you have connected the backlight for example to a FET that switches on the backlight,
then you can use LEDOnPin to switch it on, otherwise keep the value and no pin will
be switched on.

This piece of code shows you how to add a 40x16 graphics display area to your TEXT DISPLAY.
If it flickers, first increase the contrast on the display. If it still flickers you can
pay a bit with cntdelta in function graph. 

For understanding the CMD_INSTR, please find a list of display instructions in the driver.
}}

obj
  LCD: "BenkyLCDdriver"
  rndm: "RealRandom"

var
  long stack[12]
  byte sync
    
pub main | i, b, v
  rndm.start

  ' if LEDOnPin is a valid pin number, set to output a 1 (enable LED) 
  if LEDOnPin < 31
    outa[ LEDOnPin ] := 1 
    dira[ LEDOnPin ] := 1

  LCD.start( LCDBasePin,0 )
  LCD.exec( LCD#CMD_INSTR, %10000000 ) ' this sets the 'cursor' position
  LCD.exec( LCD#CMD_PRINT, @frm1 )

'  LCD.exec( LCD#CMD_SETRATE, 2000000 ) 
'  LCD.exec( LCD#CMD_INSTR, %10000000 + $40 ) ' set the position
  '                           char1    char2     slot   blink-rate
'  LCD.exec( LCD#CMD_SETBLINK, "a"<<24 + "A"<<16 + 0<<8 + 5 ) 

'  LCD.exec( LCD#CMD_SETLEN, 0<<16 + 16 )
'  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 + $50<<16 + @text3 )

  waitcnt( clkfreq*10+cnt )
  cognew( graph, @stack )

  repeat
    ' display a picture
    bytemove( @buf1, @pic, 128 )
    repeat 10
      counter:=counter+1
      hex( counter, 8 )
      waitcnt( clkfreq + cnt )

    ' draw lines
    clear
    repeat i from 0 to 15
      pixel( i, i )
      pixel( 39-i, i )
      pixel( i, 15 - i )
      pixel( 39-i, 15 - i )

    repeat 10
      counter:=counter+1
      hex( counter, 8 )
      waitcnt( clkfreq + cnt )

    ' draw some equalizer-style bars
    clear
    repeat 500
      b:=rndm.random
      v:=rndm.random
      b&=7
      v&=15
      bar( b, v )
      counter:=counter+1
      hex( counter, 8 )
      waitcnt( clkfreq/10 + cnt )

dat
counter  long 0

longt byte "This is a long text-row, which shall be printed on the small display. "
      byte "And it contains a counter "
text3 byte "00000000 ... ;o) ",0

PUB hex(value, digits) | blubb
  value <<= (8 - digits) << 2
  repeat blubb from 0 to digits-1
    byte[@text3+blubb]:=lookupz((value <-= 4) & $F : "0".."9", "A".."F")

pub bar( x, h ) | i
  repeat i from 15 to 0
    if (i-h)>0
      byte[@buf1+(i>>3)*64][(i&7)+x<<3]:=$1f
    else    
      byte[@buf1+(i>>3)*64][(i&7)+x<<3]:=$00

pub graph | cntwait , cntdelta
  cntdelta:=clkfreq/30
  cntwait:=cnt

  repeat
    LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
    LCD.exec( LCD#CMD_SETCHAR, @buf1 )  ' Power plug
    LCD.exec( LCD#CMD_SETCHAR, @buf1+8 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf1+16 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf1+24 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf1+32 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf1+40 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf1+48 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf1+56 )  ' Rails
    LCD.exec( LCD#CMD_INSTR, %10000000 + $44 ) ' this sets the 'cursor' position
    LCD.exec( LCD#CMD_PRINTN, @inter1 + 8<<16)
    LCD.exec( LCD#CMD_INSTR, %10000000 + $44 ) ' this sets the 'cursor' position
    sync:=1
    cntwait+=cntdelta
    waitcnt( cntwait )
    sync:=0   
    LCD.exec( LCD#CMD_PRINTN, @leerst + 8<<16)
    LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
    LCD.exec( LCD#CMD_SETCHAR, @buf2 )  ' Power plug
    LCD.exec( LCD#CMD_SETCHAR, @buf2+8 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf2+16 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf2+24 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf2+32 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf2+40 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf2+48 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @buf2+56 )  ' Rails
    LCD.exec( LCD#CMD_INSTR, %10000000 + $14 ) ' this sets the 'cursor' position
    LCD.exec( LCD#CMD_PRINTN, @inter1 + 8<<16)
    sync:=1
    cntwait+=cntdelta
    waitcnt( cntwait )
    sync:=0   
    LCD.exec( LCD#CMD_INSTR, %10000000 + $14 ) ' this sets the 'cursor' position
    LCD.exec( LCD#CMD_PRINTN, @leerst + 8<<16)

pub clear | i
  bytefill( @buf1, 0, 128 )

pub pixel(x, y)
  if y<8
    byte[@buf1][(x/5)*8+y]|= |<(4-x//5)  
  else
    byte[@buf2][(x/5)*8+y-8]|= |<(4-x//5)
      
dat
frm1  byte 255,"Graphics",255,255,"Demo",255,0
frm2  byte 255

buf1  byte 0[64]
buf2  byte 0[64]

pic   byte %11111,%11111,%11000,%11000,%11000,%11000,%11000,%11111
      byte %11100,%11110,%00111,%00011,%00011,%00111,%11110,%11100
      byte %00000,%00000,%00110,%00110,%00000,%00000,%00110,%00110
      byte %00000,%00000,%00000,%01111,%11100,%11000,%11000,%11000
      byte %00000,%00000,%00000,%10000,%11000,%11000,%11000,%11000
      byte %00000,%00000,%00011,%00100,%01000,%01001,%10000,%10000
      byte %00000,%11111,%00000,%00000,%00000,%10001,%11011,%11011
      byte %00000,%00000,%11000,%00100,%00010,%10010,%00001,%00001

      byte %11111,%11000,%11000,%11000,%11000,%11000,%11111,%11111
      byte %11100,%11110,%00111,%00011,%00011,%00111,%11110,%11100
      byte %00110,%00110,%00111,%00010,%00000,%00000,%00011,%01111
      byte %01111,%00000,%00000,%00001,%00111,%11110,%11000,%00000
      byte %11000,%11000,%10000,%10000,%00000,%00000,%00000,%00000
      byte %10000,%10000,%01001,%01000,%00100,%00011,%00000,%00000
      byte %00000,%00000,%00000,%11111,%00000,%00000,%11111,%00000
      byte %00001,%00001,%10010,%00010,%00100,%11000,%00000,%00000

inter1 byte 0,1,2,3,4,5,6,7
leerst byte "        "