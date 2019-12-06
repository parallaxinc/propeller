{EaDOG128L display driver in spin code
pls change or check I/O pin configuration!!}
CON
        SI = 8
        SCK = 9
        A0 = 10
        Rst = 11
        CS = 12
        Dled =13

VAR
byte pic_addr
word ch_addr
   
PUB Init | i, value             'Display work for initalisation
dira[8..13]~~                   'I/O pin set output
outa[Rst]~~                     'Set reset to high
outa[CS]~                       'Set CS to low
outa[A0]~                       'Set A0 to low initalize send's command
repeat i from 0 to 13
  shiftout(Initcommands[i])
ctrl_en(0)

PUB ch_column(value)'' Change column address
command(($100 | ($F0 & value )) >> 4)
command(($F & value))

PUB ch_page(value) ''Change Page address and change column $H00
Command($b0 | value)
ch_column(0)

PUB send_data(value) ''Write display byte in current column and Page address
data_en(1)
shiftout(value)
  
PUB ctrl_en(value)  ''Can select display 
if value == 1
  outa[CS]~                      'Controller enable                       
if value == 0
  outa[CS]~~                      'Controller disable                       

PUB allpoint_on(value) '' Display switch on or off all points 
if value == 0
  command($A4)
if value == 1
  command($A5)


PUB cls| i                      ''Can display clear
repeat i from 0 to 7
  ch_page($B0 + i)
  repeat 128
    send_data($00)
       
PUB blight(value)               ''Backlight on or off (no default please refer manual)
  if value == 0
    outa[Dled]~
  else
    outa[Dled]~~ 

PUB wrchar(column, page, str) | i, c ''write string at column and page address
ch_page(page)
ch_column(column*8)
repeat i from 1 to strsize(str)
  ch_addr := byte[str][i-1]
  ch_addr := ch_addr * 8
  repeat c from 0 to 7
    send_data(byte[@fonts[ch_addr + c]])

PRI shiftout(value)             ''Shift out byte
value <<= 24
repeat 8
  outa[SI] := (value <-= 1) & 1
  !outa[SCK]                  'set SCL to low 
  !outa[SCK]                 'Pulse clock to high

PRI data_en(value)              ''Can switch command (0) or Data(1) mode
if value == 0
  outa[A0]~                     'Data disable
if value == 1
  outa[A0]~~                    'Data enable

PRI command(value)              ''configure command mode and send command
data_en(0)
shiftout(value)
   
DAT                             ''defalut init command (refer manual)
Initcommands byte $40, $A1, $C0, $A6, $A2, $2F, $F8, $00, $27, $81, $10, $AC, $00, $AF
fonts file "parallax8x8_rot.pf"
        