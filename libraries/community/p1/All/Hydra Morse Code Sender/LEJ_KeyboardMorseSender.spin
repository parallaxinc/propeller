' //////////////////////////////////////////////////////////////////////
' Morse Code Sender Demo - This demo allows keys to be pressed and echoes them to
' the screen and sends the Morse Code letters by the debug light and out
' the audio side of the tv hookup.
' 
' AUTHOR: Andre' LaMothe
' MODIFIED: Larry Jennings
' LAST MODIFIED: 5.30.09
' VERSION 1.0
' COMMENTS: Sends Morse Code Letters out via the debug light and the 
'           audio port.
' CONTROLS: keyboard
' ESC - Clear Screen
'
' //////////////////////////////////////////////////////////////////////

'///////////////////////////////////////////////////////////////////////
' CONSTANTS SECTION ////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

CON

  _clkmode = xtal1 + pll8x              ' enable external clock and pll times 8
  _xinfreq = 10_000_000 + 0000          ' set frequency to 10 MHZ plus some error
  _stack = ($2400 + $2400 + $100) >> 2  ' accomodate display memory and stack
  dotrate = 7_000_000                   ' sets the speed of the code sent, the lower, the faster                                                             
  ' dotrate is the basic time interval of Morse Code. The length of the dash, the spaces between
  ' elements (dot, dash, letters and words) is all determined by this number.
  ' graphics driver and screen constants
  PARAMCOUNT        = 14        

  OFFSCREEN_BUFFER  = $3800             ' offscreen buffer
  ONSCREEN_BUFFER   = $5C00             ' onscreen buffer

  ' size of graphics tile map
  X_TILES           = 12
  Y_TILES           = 12
  
  SCREEN_WIDTH      = 192
  SCREEN_HEIGHT     = 192 

  BYTES_PER_LINE    = (192/4)

  KEYCODE_ESC       = $CB
  KEYCODE_ENTER     = $0D
  KEYCODE_BACKSPACE = $C8

'///////////////////////////////////////////////////////////////////////
' VARIABLES SECTION ////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

VAR

  long  tv_status     '0/1/2 = off/visible/invisible           read-only
  long  tv_enable     '0/? = off/on                            write-only
  long  tv_pins       '%ppmmm = pins                           write-only
  long  tv_mode       '%ccinp = chroma,interlace,ntsc/pal,swap write-only
  long  tv_screen     'pointer to screen (words)               write-only
  long  tv_colors     'pointer to colors (longs)               write-only               
  long  tv_hc         'horizontal cells                        write-only
  long  tv_vc         'vertical cells                          write-only
  long  tv_hx         'horizontal cell expansion               write-only
  long  tv_vx         'vertical cell expansion                 write-only
  long  tv_ho         'horizontal offset                       write-only
  long  tv_vo         'vertical offset                         write-only
  long  tv_broadcast  'broadcast frequency (Hz)                write-only
  long  tv_auralcog   'aural fm cog                            write-only

  word  screen[x_tiles * y_tiles] ' storage for screen tile map
  long  colors[64]                ' color look up table

  ' string/key stuff
  byte sbuffer[9]
  byte curr_key
  byte temp_key 
  long data

  ' terminal vars
  long row, column
 
  ' counter vars
  long curr_cnt, end_cnt

  word jx, ix, ltr, pntr, letter[60], count, sendltr , strlen

'///////////////////////////////////////////////////////////////////////
' OBJECT DECLARATION SECTION ///////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////
OBJ

  tv    : "tv_drv_010.spin"          ' instantiate a tv object
  gr    : "graphics_drv_010.spin"    ' instantiate a graphics object
  key   : "keyboard_iso_010.spin"    ' instantiate a keyboard object       
  snd   : "NS_sound_drv_051_22khz_16bit.spin"  'Sound Driver
'///////////////////////////////////////////////////////////////////////
' EXPORT PUBLICS  //////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

PUB start | iz, jz, base, base2, dx, dy, xz, yz, x2, y2, last_cos, last_sin

'///////////////////////////////////////////////////////////////////////
 ' GLOBAL INITIALIZATION ///////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

  'start keyboard on pingroup 3 
  key.start(3)

  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  'init colors
  repeat iz from 0 to 64
    colors[iz] := $00001010 * (iz+4) & $F + $FB060C02

  'init tile screen
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := onscreen_buffer >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)

  'start and setup graphics
  gr.start
  gr.setup(X_TILES, Y_TILES, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, onscreen_buffer)

  ' initialize terminal cursor position
  column :=0
  row := 0

  ' put up title screen
  ' set text mode
  gr.textmode(2,1,5,3)
  gr.colorwidth(1,0)
  gr.text(-SCREEN_WIDTH/2,SCREEN_HEIGHT/2 - 16, @title_string)
  gr.colorwidth(3,0)
  gr.plot(-192/2, 192/2 - 16)
  gr.line(192/2,  192/2 - 16)
  gr.colorwidth(2,0)
  ' start the sound routine
  snd.start(7)
  ' get and store the address of each letter string into the letter array
  ' each letter has a string of letters where 1 equals a dot and 2 equals a dash
  ' each string ends in a zero - since the length of letters in Morse Code
  ' varies (an "e" is a single dot, and a "j" is one dot followed by three dashes)
  ' the address of the start of each string does not occur at a regular spacing
  ' so this array is an array of pointers to the start of each letter.
  letter[0]:=0
  letter[1]:=@A
  letter[2]:=@B
  letter[3]:=@C
  letter[4]:=@D
  letter[5]:=@E
  letter[6]:=@F
  letter[7]:=@G
  letter[8]:=@H
  letter[9]:=@I
  letter[10]:=@J
  letter[11]:=@K
  letter[12]:=@L
  letter[13]:=@M
  letter[14]:=@N
  letter[15]:=@O
  letter[16]:=@P
  letter[17]:=@Q
  letter[18]:=@R
  letter[19]:=@S
  letter[20]:=@T
  letter[21]:=@U
  letter[22]:=@V
  letter[23]:=@W
  letter[24]:=@X
  letter[25]:=@Y
  letter[26]:=@Z
  letter[27]:=@Space
  letter[28]:=@N1
  letter[29]:=@N2
  letter[30]:=@N3
  letter[31]:=@N4
  letter[32]:=@N5
  letter[33]:=@N6
  letter[34]:=@N7
  letter[35]:=@N8
  letter[36]:=@N9
  letter[37]:=@N0
  letter[38]:=@Pperiod
  letter[39]:=@Pcomma
  letter[40]:=@Pquestion
  letter[41]:=@Pplus
  letter[42]:=@Pexclam
  letter[43]:=@Pequals
  letter[44]:=@Pslash
  letter[45]:=@Pcolon
  letter[46]:=@Psemicolon
  letter[47]:=@Phyphen
  letter[48]:=@Punderscore
  letter[49]:=@Popenparen
  letter[50]:=@Pcloseparen
  letter[51]:=@Papostrophe
  letter[52]:=@Pquote
  letter[53]:=@Pdollar
  letter[54]:=@Pampersand
  letter[55]:=@Pat_sign


 ' BEGIN GAME LOOP ////////////////////////////////////////////////////
  repeat 
   
    ' get key    
    if (key.gotkey==TRUE)
      curr_key := key.getkey
      Send(curr_key)
    'print character to screen
      Print_To_Term(curr_key)
    else ' gotkey 
      curr_key := 0      

' ////////////////////////////////////////////////////////////////////

PUB Print_To_Term(char_code)
' prints sent character to terminal or performs control code
' supports, line wrap, and return, esc clears screen      

' test for new line
  if (char_code == KEYCODE_ENTER)
    column :=0             
    if (++row > 13)    
      row := 13
  elseif (char_code == KEYCODE_ESC)
    gr.clear
    gr.textmode(2,1,5,3)
    gr.colorwidth(1,0)
    gr.text(-SCREEN_WIDTH/2,SCREEN_HEIGHT/2 - 16, @title_string)
    gr.colorwidth(3,0)
    gr.plot(-SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 16)
    gr.line(SCREEN_WIDTH/2,  SCREEN_HEIGHT/2 - 16)
    gr.colorwidth(2,0)
    column := row := 0
  else ' not a carriage return
    ' set the printing buffer up 
    sbuffer[0] := char_code
    sbuffer[1] := 0
    gr.text(-SCREEN_WIDTH/2 + column*12,SCREEN_HEIGHT/2 - 32 - row*12, @sbuffer)

    ' test for text wrapping and new line
    if (++column > 15)
      column := 0
      if (++row > 13)    
        row := 13
        ' scroll text window

'////////////////////////////////////////////////////////////////////////
' This routine compares the send_key character against the various letters,
' numbers, and punctuation, and sets the pointer to the proper number.
' Using a CASE statement allows checking for both upper and lower case
' alphabetic letters - either may be used.
PUB Send(send_key)  
  pntr:=0
 case send_key
  "A", "a" : pntr:=1 
  "B", "b" : pntr:=2
  "C", "c" : pntr:=3 
  "D", "d" : pntr:=4
  "E", "e" : pntr:=5 
  "F", "f" : pntr:=6
  "G", "g" : pntr:=7 
  "H", "h" : pntr:=8
  "I", "i" : pntr:=9 
  "J", "j" : pntr:=10
  "K", "k" : pntr:=11
  "L", "l" : pntr:=12
  "M", "m" : pntr:=13
  "N", "n" : pntr:=14
  "O", "o" : pntr:=15
  "P", "p" : pntr:=16
  "Q", "q" : pntr:=17
  "R", "r" : pntr:=18
  "S", "s" : pntr:=19
  "T", "t" : pntr:=20
  "U", "u" : pntr:=21
  "V", "v" : pntr:=22
  "W", "w" : pntr:=23
  "X", "x" : pntr:=24
  "Y", "y" : pntr:=25
  "Z", "z" : pntr:=26
  " "      : pntr:=27           
  "1"      : pntr:=28           
  "2"      : pntr:=29           
  "3"      : pntr:=30           
  "4"      : pntr:=31           
  "5"      : pntr:=32           
  "6"      : pntr:=33           
  "7"      : pntr:=34           
  "8"      : pntr:=35           
  "9"      : pntr:=36           
  "0"      : pntr:=37           
  "."      : pntr:=38           
  ","      : pntr:=39           
  "?"      : pntr:=40           
  "+"      : pntr:=41           
  "!"      : pntr:=42           
  "="      : pntr:=43           
  "/"      : pntr:=44           
  ":"      : pntr:=45           
  ";"      : pntr:=46           
  "-"      : pntr:=47           
  "_"      : pntr:=48           
  "("      : pntr:=49           
  ")"      : pntr:=50           
  "'"      : pntr:=51           
  $22      : pntr:=52    ' quotation mark - hexadecimal value      
  "$"      : pntr:=53           
  "&"      : pntr:=54           
  "@"      : pntr:=55
'
'    This portion of the routine reads the string for each letter, number or
'    punctuation and sends the appropriate dots or dashes to the light and
'    sound.
'                                                                                          
 DIRA[0] := 1
 ix:=0
 ltr:=BYTE[letter[pntr]]
 repeat
  if (ltr=="1")
   Dot
  if (ltr=="2")
   Dash
  ltr:=BYTE[letter[pntr]][++ix]
 until (ltr==0)
 Endletter
 if (send_key == " ")   ' If you have a space, then let another two dot times go by.
  Endletter             ' This increases separation between Morse letters indication
                        ' that an end of word has occurred.
'
' This routine sends a dot or "dit" followed by a space the same length 
PUB Dot
 snd.PlaySoundFM(0,snd#SHAPE_SQUARE, snd#NOTE_E5, snd#DURATION_INFINITE|(snd#SAMPLE_RATE), 255,$CFFF_FFFC)
 OUTA[0] := 1
 waitcnt(CNT + dotrate)
 snd.StopSound(0)
 OUTA[0] := 0
 waitcnt(CNT + dotrate)

'This routine sends a dash or "dah" followed by a space as long as a dot
PUB Dash
 snd.PlaySoundFM(0,snd#SHAPE_SQUARE, snd#NOTE_E5, snd#DURATION_INFINITE|(snd#SAMPLE_RATE), 255,$CFFF_FFFC)
 OUTA[0] := 1
 waitcnt(CNT + 3 * dotrate)
 snd.StopSound(0)
 OUTA[0] := 0
 waitcnt(CNT + dotrate)

' This routine waits for two dots worth of time - no sound, no light
PUB EndLetter
 OUTA[0] := 0
 waitcnt(CNT + 2 * dotrate)










'///////////////////////////////////////////////////////////////////////
' DATA SECTION /////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

DAT

' TV PARAMETERS FOR DRIVER /////////////////////////////////////////////

tvparams
                long    0               'status
                long    1               'enable
                long    %011_0000       'pins
                long    %0000           'mode
                long    0               'screen
                long    0               'colors
                long    x_tiles         'hc
                long    y_tiles         'vc
                long    10              'hx timing stretch
                long    1               'vx
                long    0               'ho
                long    0               'vo
                long    55_250_000      'broadcast
                long    0               'auralcog

' STRING STORAGE //////////////////////////////////////////////////////

title_string    byte    "Type and Send Morse",0         'text
blank_string    byte    "        ",0

'///////////////////////////////////////////////////////////////////////
' Letters in Morse
'
  A     byte  "12",0
  B     byte  "2111",0
  C     byte  "2121",0
  D     byte  "211",0
  E     byte  "1",0
  F     byte  "1121",0
  G     byte  "221",0
  H     byte  "1111",0
  I     byte  "11",0
  J     byte  "1222",0
  K     byte  "212",0
  L     byte  "1211",0
  M     byte  "22",0
  N     byte  "21",0
  O     byte  "222",0
  P     byte  "1221",0
  Q     byte  "2212",0
  R     byte  "121",0
  S     byte  "111",0
  T     byte  "2",0
  U     byte  "112",0
  V     byte  "1112",0
  W     byte  "122",0
  X     byte  "2112",0
  Y     byte  "2122",0
  Z     byte  "2211",0
'
' Numbers in Morse
' 
  N1    byte  "12222",0
  N2    byte  "11222",0
  N3    byte  "11122",0
  N4    byte  "11112",0
  N5    byte  "11111",0
  N6    byte  "21111",0
  N7    byte  "22111",0
  N8    byte  "22211",0
  N9    byte  "22221",0
  N0    byte  "22222",0
'
' Punctuation in Morse
'  
  Pperiod        byte  "121212",0
  Pcomma         byte  "221122",0
  Pquestion      byte  "112211",0
  Pplus          byte  "12121",0
  Pexclam        byte  "212122",0 ' Exclaimation mark
  Pequals        byte  "21112",0  ' Double Dash or Prosign BT
  Pslash         byte  "21121",0
  Pcolon         byte  "222111",0
  Psemicolon     byte  "212121",0
  Phyphen        byte  "211112",0
  Punderscore    byte  "112212",0
  Popenparen     byte  "21221",0  ' Open Parenthesis (
  Pcloseparen    byte  "212212",0 ' Closed Parenthesis )
  Papostrophe    byte  "122221",0
  Pquote         byte  "121121",0 ' Quotation Mark
  Pdollar        byte  "1112112",0 ' Dollar Sign $
  Pampersand     byte  "12111",0 ' Ampersand "&" or Wait
  Pat_sign       byte  "122121",0 'The @ sign        
  Space byte  0,0

'////////////////////////////////////////////////////
'////////////////////////////////////////////////////