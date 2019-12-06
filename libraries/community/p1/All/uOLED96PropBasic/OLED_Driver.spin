{{
Modified Tiny Basic for use with 4D Systems' uOLED-96-Prop.

Copyright (c) 2008 4D Systems.  See end of file for terms of use.
Written by Atilla Aknar and Steve McManus with modifications by Michael Green.
}}

CON
'*------------------------------------------------------------------------*
'*  General definitions                                                   *
'*------------------------------------------------------------------------*

  ON       =  1
  OFF      =  0
  INPUT    =  1
  OUTPUT   =  0
  ENABLE   =  1
  DISABLE  =  0
  SET      =  1
  CLEAR    =  0

'*------------------------------------------------------------------------*
'*  OLED Interface (PINS)                                                 *
'*------------------------------------------------------------------------*
  CS_OLED         =  8               ' OLED Chip Select Signal
  RESETPIN_OLED   =  9               ' OLED Reset Signal
  D_C             =  10              ' Data/Command
  WR_OLED         =  11              ' OLED Write Signal
  RD_OLED         =  12              ' OLED Read Signal
  CS_VHI          =  13              ' OLED VCC Enable

'*------------------------------------------------------------------------*
'*  OLED-96 Registers                                                     *
'*------------------------------------------------------------------------*
  SET_COLUMN_ADDRESS    =       $15
  SET_ROW_ADDRESS       =       $75
  CONTRAST_RED          =       $81
  CONTRAST_GREEN        =       $82
  CONTRAST_BLUE         =       $83
  CONTRAST_MASTER       =       $87
  CONTRAST_RED_2ND      =       $8A
  CONTRAST_GREEN_2ND    =       $8B
  CONTRAST_BLUE_2ND     =       $8C
  REMAP_COLOUR_SETTINGS =       $A0
  DISPLAY_START_LINE    =       $A1
  DISPLAY_OFFSET        =       $A2
  DISPLAY_NORMAL        =       $A4
  DISPLAY_ALL_ON        =       $A5
  DISPLAY_ALL_OFF       =       $A6
  DISPLAY_INVERSE       =       $A7
  DUTY_CYCLE            =       $A8
  MASTER_CONFIGURE      =       $AD
  DISPLAY_OFF           =       $AE
  DISPLAY_ON            =       $AF
  POWERSAVE_MODE        =       $B0
  PHASE_PRECHARGE       =       $B1
  CLOCK_FREQUENCY       =       $B3
  SET_GRAYSCALE_LUT     =       $B8
  RESET_GRAYSCALE_LUT   =       $B9
  PRECHARGE_VOLTAGE_RGB =       $BB
  SET_VCOMH             =       $BE
  OLED_NOP              =       $E3
  LOCK_COMMAND          =       $FD

  DRAW_LINE             =       $21
  DRAW_RECTANGLE        =       $22
  COPY_AREA             =       $23
  DIM_WINDOW            =       $24
  CLEAR_WINDOW          =       $25
  FILL_ENABLE_DISABLE   =       $26
  SCROLL_SETUP          =       $27
  STOP_SCROLL           =       $2E
  START_SCROLL          =       $2F

  _65K_COLOURS          =       $72


'*-------------------------------------------------------------------------*
'*  Screen Related definitions                                             *
'*-------------------------------------------------------------------------*
  X_RES            =               96
  Y_RES            =               64

  MAXCOLOUR        =               $FFFF
  MAX_TEXTROWS     =               25

  BLACK            =               $0000
  WHITE            =               $FFFF
  RED              =               $F800
  GREEN            =               $07E0
  BLUE             =               $001F
  YELLOW           =               RED | GREEN

DAT
font_8x8   byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
           byte %00110000,%00110000,%00110000,%00110000,%00110000,%00000000,%00110000,%00000000
           byte %01101100,%01101100,%01101100,%00000000,%00000000,%00000000,%00000000,%00000000
           byte %01101100,%01101100,%11111110,%01101100,%11111110,%01101100,%01101100,%00000000
           byte %00110000,%01111100,%11000000,%01111000,%00001100,%11111000,%00110000,%00000000
           byte %00000000,%11000110,%11001100,%00011000,%00110000,%01100110,%11000110,%00000000
           byte %00111000,%01101100,%00111000,%01110110,%11011100,%11001100,%01110110,%00000000
           byte %01100000,%01100000,%11000000,%00000000,%00000000,%00000000,%00000000,%00000000
           byte %00011000,%00110000,%01100000,%01100000,%01100000,%00110000,%00011000,%00000000
           byte %01100000,%00110000,%00011000,%00011000,%00011000,%00110000,%01100000,%00000000
           byte %00000000,%01100110,%00111100,%11111111,%00111100,%01100110,%00000000,%00000000
           byte %00000000,%00110000,%00110000,%11111100,%00110000,%00110000,%00000000,%00000000
           byte %00000000,%00000000,%00000000,%00000000,%00000000,%00110000,%00110000,%01100000
           byte %00000000,%00000000,%00000000,%11111100,%00000000,%00000000,%00000000,%00000000
           byte %00000000,%00000000,%00000000,%00000000,%00000000,%00110000,%00110000,%00000000
           byte %00000100,%00001100,%00011000,%00110000,%01100000,%11000000,%10000000,%00000000
           byte %01111100,%11000110,%11001110,%11011110,%11110110,%11100110,%01111100,%00000000
           byte %00110000,%01110000,%00110000,%00110000,%00110000,%00110000,%11111100,%00000000
           byte %01111000,%11001100,%00001100,%00111000,%01100000,%11001100,%11111100,%00000000
           byte %01111000,%11001100,%00001100,%00111000,%00001100,%11001100,%01111000,%00000000
           byte %00011100,%00111100,%01101100,%11001100,%11111110,%00001100,%00011110,%00000000
           byte %11111100,%11000000,%11111000,%00001100,%00001100,%11001100,%01111000,%00000000
           byte %00111000,%01100000,%11000000,%11111000,%11001100,%11001100,%01111000,%00000000
           byte %11111100,%11001100,%00001100,%00011000,%00110000,%00110000,%00110000,%00000000
           byte %01111000,%11001100,%11001100,%01111000,%11001100,%11001100,%01111000,%00000000
           byte %01111000,%11001100,%11001100,%01111100,%00001100,%00011000,%01110000,%00000000
           byte %00000000,%00110000,%00110000,%00000000,%00000000,%00110000,%00110000,%00000000
           byte %00000000,%00110000,%00110000,%00000000,%00000000,%00110000,%00110000,%01100000
           byte %00011000,%00110000,%01100000,%11000000,%01100000,%00110000,%00011000,%00000000
           byte %00000000,%00000000,%11111100,%00000000,%00000000,%11111100,%00000000,%00000000
           byte %01100000,%00110000,%00011000,%00001100,%00011000,%00110000,%01100000,%00000000
           byte %01111000,%11001100,%00001100,%00011000,%00110000,%00000000,%00110000,%00000000
           byte %01111100,%11000110,%11011110,%11011110,%11011110,%11000000,%01111000,%00000000
           byte %00110000,%01111000,%11001100,%11001100,%11111100,%11001100,%11001100,%00000000
           byte %11111100,%01100110,%01100110,%01111100,%01100110,%01100110,%11111100,%00000000
           byte %00111100,%01100110,%11000000,%11000000,%11000000,%01100110,%00111100,%00000000
           byte %11111000,%01101100,%01100110,%01100110,%01100110,%01101100,%11111000,%00000000
           byte %01111110,%01100000,%01100000,%01111000,%01100000,%01100000,%01111110,%00000000
           byte %01111110,%01100000,%01100000,%01111000,%01100000,%01100000,%01100000,%00000000
           byte %00111100,%01100110,%11000000,%11000000,%11001110,%01100110,%00111110,%00000000
           byte %11001100,%11001100,%11001100,%11111100,%11001100,%11001100,%11001100,%00000000
           byte %01111000,%00110000,%00110000,%00110000,%00110000,%00110000,%01111000,%00000000
           byte %00011110,%00001100,%00001100,%00001100,%11001100,%11001100,%01111000,%00000000
           byte %11100110,%01100110,%01101100,%01111000,%01101100,%01100110,%11100110,%00000000
           byte %01100000,%01100000,%01100000,%01100000,%01100000,%01100000,%01111110,%00000000
           byte %11000110,%11101110,%11111110,%11111110,%11010110,%11000110,%11000110,%00000000
           byte %11000110,%11100110,%11110110,%11011110,%11001110,%11000110,%11000110,%00000000
           byte %00111000,%01101100,%11000110,%11000110,%11000110,%01101100,%00111000,%00000000
           byte %11111100,%01100110,%01100110,%01111100,%01100000,%01100000,%11110000,%00000000
           byte %01111000,%11001100,%11001100,%11001100,%11011100,%01111000,%00011100,%00000000
           byte %11111100,%01100110,%01100110,%01111100,%01101100,%01100110,%11100110,%00000000
           byte %01111000,%11001100,%11100000,%01111000,%00011100,%11001100,%01111000,%00000000
           byte %11111100,%00110000,%00110000,%00110000,%00110000,%00110000,%00110000,%00000000
           byte %11001100,%11001100,%11001100,%11001100,%11001100,%11001100,%11111100,%00000000
           byte %11001100,%11001100,%11001100,%11001100,%11001100,%01111000,%00110000,%00000000
           byte %11000110,%11000110,%11000110,%11010110,%11111110,%11101110,%11000110,%00000000
           byte %11000110,%11000110,%01101100,%00111000,%00111000,%01101100,%11000110,%00000000
           byte %11001100,%11001100,%11001100,%01111000,%00110000,%00110000,%01111000,%00000000
           byte %11111110,%00000110,%00001100,%00011000,%00110000,%01100000,%11111110,%00000000
           byte %01111000,%01100000,%01100000,%01100000,%01100000,%01100000,%01111000,%00000000
           byte %11000000,%01100000,%00110000,%00011000,%00001100,%00000110,%00000010,%00000000
           byte %01111000,%00011000,%00011000,%00011000,%00011000,%00011000,%01111000,%00000000
           byte %00010000,%00111000,%01101100,%11000110,%00000000,%00000000,%00000000,%00000000
           byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%11111111
           byte %00110000,%00110000,%00011000,%00000000,%00000000,%00000000,%00000000,%00000000
           byte %00000000,%00000000,%01111000,%00001100,%01111100,%11001100,%01110110,%00000000
           byte %11100000,%01100000,%01100000,%01111100,%01100110,%01100110,%11011100,%00000000
           byte %00000000,%00000000,%01111000,%11001100,%11000000,%11001100,%01111000,%00000000
           byte %00011100,%00001100,%00001100,%01111100,%11001100,%11001100,%01110110,%00000000
           byte %00000000,%00000000,%01111000,%11001100,%11111100,%11000000,%01111000,%00000000
           byte %00111000,%01101100,%01100000,%11110000,%01100000,%01100000,%11110000,%00000000
           byte %00000000,%00000000,%01110110,%11001100,%11001100,%01111100,%00001100,%11111000
           byte %11100000,%01100000,%01101100,%01110110,%01100110,%01100110,%11100110,%00000000
           byte %00110000,%00000000,%01110000,%00110000,%00110000,%00110000,%01111000,%00000000
           byte %00001100,%00000000,%00001100,%00001100,%00001100,%11001100,%11001100,%01111000
           byte %11100000,%01100000,%01100110,%01101100,%01111000,%01101100,%11100110,%00000000
           byte %01110000,%00110000,%00110000,%00110000,%00110000,%00110000,%01111000,%00000000
           byte %00000000,%00000000,%11001100,%11111110,%11111110,%11010110,%11000110,%00000000
           byte %00000000,%00000000,%11111000,%11001100,%11001100,%11001100,%11001100,%00000000
           byte %00000000,%00000000,%01111000,%11001100,%11001100,%11001100,%01111000,%00000000
           byte %00000000,%00000000,%11011100,%01100110,%01100110,%01111100,%01100000,%11110000
           byte %00000000,%00000000,%01110110,%11001100,%11001100,%01111100,%00001100,%00011110
           byte %00000000,%00000000,%11011100,%01110110,%01100110,%01100000,%11110000,%00000000
           byte %00000000,%00000000,%01111100,%11000000,%01111000,%00001100,%11111000,%00000000
           byte %00010000,%00110000,%01111100,%00110000,%00110000,%00110100,%00011000,%00000000
           byte %00000000,%00000000,%11001100,%11001100,%11001100,%11001100,%01110110,%00000000
           byte %00000000,%00000000,%11001100,%11001100,%11001100,%01111000,%00110000,%00000000
           byte %00000000,%00000000,%11000110,%11010110,%11111110,%11111110,%01101100,%00000000
           byte %00000000,%00000000,%11000110,%01101100,%00111000,%01101100,%11000110,%00000000
           byte %00000000,%00000000,%11001100,%11001100,%11001100,%01111100,%00001100,%11111000
           byte %00000000,%00000000,%11111100,%10011000,%00110000,%01100100,%11111100,%00000000
           byte %00011100,%00110000,%00110000,%11100000,%00110000,%00110000,%00011100,%00000000
           byte %00011000,%00011000,%00011000,%00000000,%00011000,%00011000,%00011000,%00000000
           byte %11100000,%00110000,%00110000,%00011100,%00110000,%00110000,%11100000,%00000000
           byte %01110110,%11011100,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
           byte %00000000,%01100110,%01100110,%01100110,%01100110,%01100110,%01011100,%10000000

font_5x7   byte $00,$00,$00,$00,$00,$00,$00,$00  ' space
           byte $02,$02,$02,$02,$02,$00,$02,$00  '  "!"
           byte $36,$12,$24,$00,$00,$00,$00,$00  '  """
           byte $00,$14,$3E,$14,$3E,$14,$00,$00  '  "#"
           byte $08,$3C,$0A,$1C,$28,$1E,$08,$00  '  "$"
           byte $22,$22,$10,$08,$04,$22,$22,$00  '  "%"
           byte $04,$0A,$0A,$04,$2A,$12,$2C,$00  '  "&"
           byte $18,$10,$08,$00,$00,$00,$00,$00  '  "'"
           byte $20,$10,$08,$08,$08,$10,$20,$00  '  "("
           byte $02,$04,$08,$08,$08,$04,$02,$00  '  ")"
           byte $00,$08,$2A,$1C,$1C,$2A,$08,$00  '  "*"
           byte $00,$08,$08,$3E,$08,$08,$00,$00  '  "+"
           byte $00,$00,$00,$00,$00,$06,$04,$02  '  ","
           byte $00,$00,$00,$3E,$00,$00,$00,$00  '  "-"
           byte $00,$00,$00,$00,$00,$06,$06,$00  '  "."
           byte $20,$20,$10,$08,$04,$02,$02,$00  '  "/"
           byte $1C,$22,$32,$2A,$26,$22,$1C,$00  '  "0"
           byte $08,$0C,$08,$08,$08,$08,$1C,$00  '  "1"
           byte $1C,$22,$20,$10,$0C,$02,$3E,$00  '  "2"
           byte $1C,$22,$20,$1C,$20,$22,$1C,$00  '  "3"
           byte $10,$18,$14,$12,$3E,$10,$10,$00  '  "4"
           byte $3E,$02,$1E,$20,$20,$22,$1C,$00  '  "5"
           byte $18,$04,$02,$1E,$22,$22,$1C,$00  '  "6"
           byte $3E,$20,$10,$08,$04,$04,$04,$00  '  "7"
           byte $1C,$22,$22,$1C,$22,$22,$1C,$00  '  "8"
           byte $1C,$22,$22,$3C,$20,$10,$0C,$00  '  "9"
           byte $00,$06,$06,$00,$06,$06,$00,$00  '  ":"
           byte $00,$06,$06,$00,$06,$06,$04,$02  '  ";"
           byte $20,$10,$08,$04,$08,$10,$20,$00  '  "<"
           byte $00,$00,$3E,$00,$3E,$00,$00,$00  '  "="
           byte $02,$04,$08,$10,$08,$04,$02,$00  '  ">"
           byte $1C,$22,$20,$10,$08,$00,$08,$00  '  "?"
           byte $1C,$22,$2A,$2A,$1A,$02,$3C,$00  '  "@"
           byte $08,$14,$22,$22,$3E,$22,$22,$00  '  "A"
           byte $1E,$22,$22,$1E,$22,$22,$1E,$00  '  "B"
           byte $18,$24,$02,$02,$02,$24,$18,$00  '  "C"
           byte $0E,$12,$22,$22,$22,$12,$0E,$00  '  "D"
           byte $3E,$02,$02,$1E,$02,$02,$3E,$00  '  "E"
           byte $3E,$02,$02,$1E,$02,$02,$02,$00  '  "F"
           byte $1C,$22,$02,$02,$32,$22,$1C,$00  '  "G"
           byte $22,$22,$22,$3E,$22,$22,$22,$00  '  "H"
           byte $3E,$08,$08,$08,$08,$08,$3E,$00  '  "I"
           byte $20,$20,$20,$20,$20,$22,$1C,$00  '  "J"
           byte $22,$12,$0A,$06,$0A,$12,$22,$00  '  "K"
           byte $02,$02,$02,$02,$02,$02,$3E,$00  '  "L"
           byte $22,$36,$2A,$2A,$22,$22,$22,$00  '  "M"
           byte $22,$22,$26,$2A,$32,$22,$22,$00  '  "N"
           byte $1C,$22,$22,$22,$22,$22,$1C,$00  '  "O"
           byte $1E,$22,$22,$1E,$02,$02,$02,$00  '  "P"
           byte $1C,$22,$22,$22,$2A,$12,$2C,$00  '  "Q"
           byte $1E,$22,$22,$1E,$0A,$12,$22,$00  '  "R"
           byte $1C,$22,$02,$1C,$20,$22,$1C,$00  '  "S"
           byte $3E,$08,$08,$08,$08,$08,$08,$00  '  "T"
           byte $22,$22,$22,$22,$22,$22,$1C,$00  '  "U"
           byte $22,$22,$22,$14,$14,$08,$08,$00  '  "V"
           byte $22,$22,$22,$2A,$2A,$2A,$14,$00  '  "W"
           byte $22,$22,$14,$08,$14,$22,$22,$00  '  "X"
           byte $22,$22,$14,$08,$08,$08,$08,$00  '  "Y"
           byte $3E,$20,$10,$08,$04,$02,$3E,$00  '  "Z"
           byte $3E,$06,$06,$06,$06,$06,$3E,$00  '  "["
           byte $02,$02,$04,$08,$10,$20,$20,$00  '  "\"
           byte $3E,$30,$30,$30,$30,$30,$3E,$00  '  "]"
           byte $00,$00,$08,$14,$22,$00,$00,$00  '  "^"
           byte $00,$00,$00,$00,$00,$00,$00,$7F  '  "_"
           byte $10,$08,$18,$00,$00,$00,$00,$00  '  "`"
           byte $00,$00,$1C,$20,$3C,$22,$3C,$00  '  "a"
           byte $02,$02,$1E,$22,$22,$22,$1E,$00  '  "b"
           byte $00,$00,$3C,$02,$02,$02,$3C,$00  '  "c"
           byte $20,$20,$3C,$22,$22,$22,$3C,$00  '  "d"
           byte $00,$00,$1C,$22,$3E,$02,$3C,$00  '  "e"
           byte $18,$24,$04,$1E,$04,$04,$04,$00  '  "f"
           byte $00,$00,$1C,$22,$22,$3C,$20,$1C  '  "g"
           byte $02,$02,$1E,$22,$22,$22,$22,$00  '  "h"
           byte $08,$00,$0C,$08,$08,$08,$1C,$00  '  "i"
           byte $10,$00,$18,$10,$10,$10,$12,$0C  '  "j"
           byte $02,$02,$22,$12,$0C,$12,$22,$00  '  "k"
           byte $0C,$08,$08,$08,$08,$08,$1C,$00  '  "l"
           byte $00,$00,$36,$2A,$2A,$2A,$22,$00  '  "m"
           byte $00,$00,$1E,$22,$22,$22,$22,$00  '  "n"
           byte $00,$00,$1C,$22,$22,$22,$1C,$00  '  "o"
           byte $00,$00,$1E,$22,$22,$1E,$02,$02  '  "p"
           byte $00,$00,$3C,$22,$22,$3C,$20,$20  '  "q"
           byte $00,$00,$3A,$06,$02,$02,$02,$00  '  "r"
           byte $00,$00,$3C,$02,$1C,$20,$1E,$00  '  "s"
           byte $04,$04,$1E,$04,$04,$24,$18,$00  '  "t"
           byte $00,$00,$22,$22,$22,$32,$2C,$00  '  "u"
           byte $00,$00,$22,$22,$22,$14,$08,$00  '  "v"
           byte $00,$00,$22,$22,$2A,$2A,$36,$00  '  "w"
           byte $00,$00,$22,$14,$08,$14,$22,$00  '  "x"
           byte $00,$00,$22,$22,$22,$3C,$20,$1C  '  "y"
           byte $00,$00,$3E,$10,$08,$04,$3E,$00  '  "z"
           byte $38,$0C,$0C,$06,$0C,$0C,$38,$00  '  "{"
           byte $08,$08,$08,$08,$08,$08,$08,$08  '  "|"
           byte $0E,$18,$18,$30,$18,$18,$0E,$00  '  "}"
           byte $00,$2C,$1A,$00,$00,$00,$00,$00  '  "~"
           byte $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F  '  --

PUB InitOLED
'' Initializes the display registers to their "NORMAL" values.
'' This method should not be changed or experimented with until you understand the
'' inter-workings of the display's registers.
'' If you make changes to this method, you risk rendering the display
'' unusable for normal operation. Failure to heed this warning could cause
'' permanent damage to the display controller. 
  OUTA[13..0] := %011101_00000000                 ' Leave Vcc off & start reset
  DIRA[13..0] := %111111_11111111                 ' Set Pins Direction for OLED       
  Reset_OLED
  PowerUp_Seq
  Write_cmd1(DISPLAY_NORMAL)                      ' Normal display
  Write_cmd2(CLOCK_FREQUENCY,       $F0)          ' clock & frequency
  Write_cmd2(DISPLAY_OFFSET,        $00)          ' Set display offset
  Write_cmd2(DUTY_CYCLE,            63)           ' Duty Cycle: 63+1
  Write_cmd2(MASTER_CONFIGURE,      $8E)          ' Set Master Configuration
  Write_cmd2(DISPLAY_START_LINE,    $00)          ' Set display start line = 0
  Write_cmd2(REMAP_COLOUR_SETTINGS, _65K_COLOURS) ' Set Re-map Color/Depth
  Write_cmd2(CONTRAST_MASTER,       $0F)          ' Set master contrast
  Write_cmd2(CONTRAST_RED,          $FF)          ' Set contrast current for R 
  Write_cmd2(CONTRAST_GREEN,        $FF)          ' Set contrast current for G 
  Write_cmd2(CONTRAST_BLUE,         $FF)          ' Set contrast current for B 
  Write_cmd2(PRECHARGE_VOLTAGE_RGB, $3E)          ' Set pre-charge voltage for RGB
  Write_cmd2(SET_VCOMH,             $3E)          ' Set VcomH
  Write_cmd2(POWERSAVE_MODE,        $00)          ' Power saving mode
  Write_cmd2(PHASE_PRECHARGE,       $11)          ' Set pre & dis_charge
  Write_cmd1(DISPLAY_ON)                          ' Display on
  Set_Full_Screen                                 ' Set screen boundries  

PUB Write_cmd1(cmd)
'' Shifts out one byte of either register address or data placed on pins 7 through 0
  OUTA[D_C] := 0
  OUTA[CS_OLED] := 0
  OUTA[WR_OLED] := 0
  OUTA[7..0] := cmd.byte[0]                      ' pins 7:0 
  OUTA[WR_OLED] := 1
  OUTA[CS_OLED] := 1
  OUTA[D_C] := 1

PUB Write_cmd2 (cmd1, cmd2)                      ' write 2 bytes to display
  Write_cmd1(cmd1)
  Write_cmd1(cmd2)

PUB Write_cmd3 (cmd1, cmd2, cmd3)                ' write 3 bytes to display
  Write_cmd1(cmd1)
  Write_cmd1(cmd2)
  Write_cmd1(cmd3)

PUB PowerDown_Seq
'' Used to power down the screen electronics without disturbing the screen data written to GRAM
'' Can be used instead of a screensaver to prolong the life of the display and/or conserve power
  Write_cmd1(DISPLAY_OFF)
  OUTA[CS_VHI] := 0                              ' Disable OLED VCC
  waitcnt(clkfreq/10 + cnt)                      ' Wait 100ms

PUB PowerUp_Seq
'' Powers on the screen electronics and displays any screen data previously written to GRAM
'' You can continue to write to GRAM (the screen) while the display is powered down and on PowerUp,
'' the latest screen data will be displayed.
  Write_cmd1(DISPLAY_OFF)
  OUTA[CS_VHI] := 1                              ' Enable OLED VCC
  waitcnt(clkfreq/10 + cnt)                      ' Wait 100ms

PUB Reset_OLED
'' Resets the display registers to their default values. If you call this method, you must call
'' InitOLED method. Equavalent to removing power from the display, without the risk of damaging the
'' screen electronics. Use the PowerDown_Seq before removing power from the display.
  OUTA[RESETPIN_OLED] := 0
  waitcnt(clkfreq/10 + cnt)                      ' Wait 100ms
  OUTA[RESETPIN_OLED] := 1

PUB Set_GRAM_Access(xStart, xEnd, yStart, yEnd)
'' Sets the upper-left (xStart, yStart) and the lower-right (xEnd, yEnd) corners of the area of
'' Graphic RAM that may be written to
  Write_cmd3(SET_COLUMN_ADDRESS, xStart, xEnd)
  Write_cmd3(SET_ROW_ADDRESS,    yStart, yEnd)
  
PUB Set_Full_Screen
  Set_GRAM_Access (0, 95, 0, 63)

PUB Write_Start_GRAM
'' Required before any write operation to GRAM
  OUTA[D_C] := 1
  OUTA[CS_OLED] := 0

PUB Write_GRAM_Byte(byteData)
'' Writes one byte of color data to the screen memory. Only useful in 256 color mode.
  OUTA[WR_OLED] := 0
  OUTA[7..0] := byteData.byte[0]
  OUTA[WR_OLED] := 1

PUB Write_GRAM_Word(wordData)
'' Writes two bytes of color data to the screen memory. Two bytes required for 16 bit
'' 65K color mode
  OUTA[WR_OLED] := 0
  OUTA[7..0] := wordData.byte[1]                 ' MSB
  OUTA[WR_OLED] := 1
  OUTA[WR_OLED] := 0
  OUTA[7..0] := wordData.byte[0]                 ' LSB
  OUTA[WR_OLED] := 1

PUB Write_Stop_GRAM
  OUTA[CS_OLED] := 1

PUB Set_Contrast (Value)                         ' Default value is 15
'' Master Contrast setting. To prolong the OLED life, use a lower setting.
  Write_cmd2(CONTRAST_MASTER, Value & $0F)       ' Set master contrast 0 to 15

PUB Set_Contrast_RGB (RCont, GCont, BCont)       ' Default values are 255
  Write_cmd2(CONTRAST_RED,   RCont)              ' Set contrast current for Red 
  Write_cmd2(CONTRAST_GREEN, GCont)              ' Set contrast current for Green 
  Write_cmd2(CONTRAST_BLUE,  BCont)              ' Set contrast current for Blue 

PUB PutPixel (X,Y, R,G,B)
'' Writes 2 bytes (16 bits) of color data to the upper-left corner (X,Y) of the area in
'' Graphic RAM defined by the Set_GRAM_Access method.
'' Puts a single pixel of colour R,G,B at screen coordinates X,Y
  Set_GRAM_Access (X, 95, Y, 63)                  
  Write_Start_GRAM
  Write_GRAM_Word(((R >> 3)<<11)|((G >> 2)<<5)|(B >> 3))
  Write_Stop_GRAM
  
PUB Line (X1,Y1,X2,Y2, R,G,B)
'' Inbuilt graphics command using the Write_cmd method to shift out the command and data required
'' by the display controller
  Write_cmd1(DRAW_LINE)                          ' Draw Line mode
  Write_cmd2(X1, Y1)                             ' set x1,y1
  Write_cmd2(X2, Y2)                             ' set x2,y2
  Write_cmd3(R>>2, G>>2, B>>2)                   ' set Line colour
  waitcnt(clkfreq/1000 + cnt)                    ' wait 1ms
  
PUB Rectangle (X1,Y1,X2,Y2,FILL, R,G,B)
'' Inbuilt graphics command using the Write_cmd method to shift out the command and data required
'' by the display controller.
'' Note that although the inbuilt command supports seperate fill and outline colors,this method
'' uses the supplied RGB values for both.
  if FILL
     Write_cmd2(FILL_ENABLE_DISABLE, 1)         ' Solid rectangle
  else
     Write_cmd2(FILL_ENABLE_DISABLE, 0)         ' Empty rectangle
  Write_cmd1(DRAW_RECTANGLE)                    ' Draw Rectangle mode
  Write_cmd2(X1, Y1)                            ' set x1,y1
  Write_cmd2(X2, Y2)                            ' set x2,y2
  Write_cmd3(R>>2, G>>2, B>>2)                  ' set outline colour
  Write_cmd3(R>>2, G>>2, B>>2)                  ' set fill colour
  waitcnt(clkfreq/1000 + cnt)                   ' wait 1ms
  
PUB Rectangle2(X1,Y1,X2,Y2, R1,G1,B1, R2,G2,B2)
'' Inbuilt graphics command using the Write_cmd method to shift out the command and data required
'' by the display controller.
  Write_cmd2(FILL_ENABLE_DISABLE, 1)            ' Separate outline & fill colours
  Write_cmd1(DRAW_RECTANGLE)                    ' Draw Rectangle mode
  Write_cmd2(X1, Y1)                            ' set x1,y1
  Write_cmd2(X2, Y2)                            ' set x2,y2
  Write_cmd3(R1>>2, G1>>2, B1>>2)               ' set outline colour
  Write_cmd3(R2>>2, G2>>2, B2>>2)               ' set fill colour
  waitcnt(clkfreq/1000 + cnt)                   ' wait 1ms
  
PUB Copy (x1s, y1s, x2s, y2s, x1d, y1d)
'' Copies a part of the screen from one screen location to another.
'' where:
''      x1s = Top Left horizontal location of source
''      y1s = Top Left vertical location of source
''      x2s = Bottom Right horizontal location of source
''      y2s = Bottom Right vertical location of source
''      x1d = Top Left horizontal location of destination
''      y1d = Top Left vertical location of destination
  Write_cmd1(COPY_AREA)                         ' Copy mode
  Write_cmd2(x1s, y1s)                          ' set x1s,y1s
  Write_cmd2(x2s, y2s)                          ' set x2s,y2s
  Write_cmd2(x1d, y1d)                          ' set x1d,y1d
  waitcnt(clkfreq/1000 + cnt)                   ' wait 1ms
  
PUB DimWindow (x1, y1, x2, y2)
'' This command will dim the window area specified by a
'' starting point (x1, y1) and the ending point (x2, y2).
'' After executing this command, the selected window area will become darker as a result.

  Write_cmd1(DIM_WINDOW)                        ' Dim Window mode
  Write_cmd2(x1, y1)                            ' set x1s,y1s
  Write_cmd2(x2, y2)                            ' set x2s,y2s
  waitcnt(clkfreq/1000 + cnt)                   ' wait 1ms
  
PUB ScrollSetup (horizontal, vertical, lineStart, lines2scroll, interval)
'' This command sets up the parameters required for horizontal and vertical scrolling.
'' where:
''      horizontal:   Set number of columns as horizontal scroll offset
''                    range: 0dec..95dec (no horizontal scroll if set to 0)
''      lineStart:    Define start line address
''      lines2scroll: Set number of lines to be horizontally scrolled
''                    note: lineStart+lines2scroll <= 64
''      vertical:     Set number of lines as vertical scroll offset
''                    range: 0dec..63dec (no vertical scroll if set to 0)
''      interval:     Set time interval between each scroll step
''                    0 = 6 frames
''                    1 = 10 frames
''                    2 = 100 frames
''                    3 = 200 frames        
  Write_cmd1(SCROLL_SETUP)                      ' Scroll Setup mode
  Write_cmd1(horizontal)                        ' set horizontal
  Write_cmd1(lineStart)                         ' set lineStart
  Write_cmd1(lines2scroll)                      ' set lines2scroll
  Write_cmd1(vertical)                          ' set vertical
  Write_cmd1(interval)                          ' set interval
 
PUB ScrollStart
'' This command activates the scrolling function according to the settings made
'' by ScrollSetup(,,,) method.
  Write_cmd1(START_SCROLL)                      ' Start the Scrolling Function
    
PUB ScrollStop
'' This command deactivates the scrolling function.
  Write_cmd1(STOP_SCROLL)                       ' Stop the Scrolling Function
    
PUB CLS
'' Using the Rectangle method above, draws a black rectangle (solid) the size of the active screen
'' to clear all data from the screen (screen erase).                                
  Rectangle (0,0,95,63,1, 0,0,0)                ' Draws a Black rectangle (filled) from
                                                '  screen min(0,0) to screen max(95,63)
                                                
PUB putChar(font,char,X,Y,R1,G1,B1,R2,G2,B2) | row, col, width, fontTbl, mask
   if font                                      ' Draw a character in either of two fonts
      width := 8                                '  at the character cell specified using
      fontTbl := @font_8x8                      '   specified foreground and background
   else
      width := 6
      fontTbl := @font_5x7
   if char < " " or char > $7F                  ' Put a character on the screen
      return                                    '  using color at coordinate X,Y
   char := (char - " ") << 3                    ' Only printable characters
   X *= width
   Y <<= 3                                      ' Use multiples of 8 pixel height
   Set_GRAM_Access(X,X+width-1,Y,Y+7)           '  for the character cells.  The
   Write_Start_GRAM                             '   cell width depends on the font.
   repeat row from 0 to 7
      repeat col from 0 to width-1
         if font                                ' 5x7 and 8x8 font tables have pixels
            mask := |< (width-1-col)            '  in different order so need to adjust
         else                                   '   bit order appropriately
            mask := |< col
         if byte[fontTbl][char+row] & mask     ' Write foreground or background
            Write_GRAM_Word(((R1 >> 3)<<11)|((G1 >> 2)<<5)|(B1 >> 3))
         else
            Write_GRAM_Word(((R2 >> 3)<<11)|((G2 >> 2)<<5)|(B2 >> 3))
   Write_Stop_GRAM

PRI CirclePlot(cx, cy, x, y,Fill,R,G,B)
'' Put a circle on the screen!
''
'' The Fill parameter is used to determine whether to use the LINE
'' method (for a filled circle) or PutPixel
''         
  if(Fill)
    if (x == 0) 
     LINE(cx, cy, cx, cy + y, R,G,B)
     LINE(cx, cy, cx, cy - y, R,G,B)
     LINE(cx, cy, cx + y, cy, R,G,B)
     LINE(cx, cy, cx - y, cy, R,G,B)
    else 
    if (x == y) 
     LINE(cx, cy, cx + x, cy + y, R,G,B)
     LINE(cx, cy, cx - x, cy + y, R,G,B)
     LINE(cx, cy, cx + x, cy - y, R,G,B)
     LINE(cx, cy, cx - x, cy - y, R,G,B)
    else           
    if (x < y) 
     LINE(cx, cy, cx + x, cy + y, R,G,B)
     LINE(cx, cy, cx - x, cy + y, R,G,B)
     LINE(cx, cy, cx + x, cy - y, R,G,B)
     LINE(cx, cy, cx - x, cy - y, R,G,B)
     LINE(cx, cy, cx + y, cy + x, R,G,B)
     LINE(cx, cy, cx - y, cy + x, R,G,B)
     LINE(cx, cy, cx + y, cy - x, R,G,B)
     LINE(cx, cy, cx - y, cy - x, R,G,B)
  else    
    if (x == 0) 
     PutPixel(cx, cy + y, R,G,B)
     PutPixel(cx, cy - y, R,G,B)
     PutPixel(cx + y, cy, R,G,B)
     PutPixel(cx - y, cy, R,G,B)
    else 
    if (x == y) 
     PutPixel(cx + x, cy + y, R,G,B)
     PutPixel(cx - x, cy + y, R,G,B)
     PutPixel(cx + x, cy - y, R,G,B)
     PutPixel(cx - x, cy - y, R,G,B)
    else 
    if (x < y) 
     PutPixel(cx + x, cy + y, R,G,B)
     PutPixel(cx - x, cy + y, R,G,B)
     PutPixel(cx + x, cy - y, R,G,B)
     PutPixel(cx - x, cy - y, R,G,B)
     PutPixel(cx + y, cy + x, R,G,B)
     PutPixel(cx - y, cy + x, R,G,B)
     PutPixel(cx + y, cy - x, R,G,B)
     PutPixel(cx - y, cy - x, R,G,B)
     
    
PUB Circle(X,Y,Rad,Fill,R,G,B) | Sum, XOff, YOff 
'' Draw a {RGB} circle of radius Rad at location X,Y
''
  XOff := 0
  YOff := Rad
  Sum := (5 - Rad*4)/4

  CirclePlot(X, Y, XOff, YOff,Fill,R,G,B)
  repeat while (XOff < YOff) 
    XOff++
    if (Sum < 0) 
      Sum += 2*XOff+1
    else 
       YOff--
       Sum += 2*(XOff-YOff)+1
    CirclePlot(X, Y, XOff, YOff,Fill,R,G,B)
  CirclePlot(X, Y, XOff, YOff,Fill, R,G,B)

PUB Arc(X,Y,Rad,Quad,Fill,R,G,B) | Sum, XOff, YOff
'' Plot an ARC ( 1/4 Circle ) at location Quad
'' Where Quad =
''  1 => 0 Degrees
''  2 => 45 Degrees
''  3 => 90 Degrees
''  4 => 180 Degrees
''
'' Where Fill =
''  Piece of Pie!!
''  0 - Draw Arc
''  1 - Draw "Filled" Arc
'' 
  XOff := 0
  YOff := Rad
  Sum := 3 - (Rad << 1)

  repeat while XOff < YOff
    if(Fill)
      CASE Quad
       1:
         Line(X,Y, X + XOff, Y - YOff, R,G,B )
         Line(X,Y, X - XOff, Y - YOff, R,G,B )
       2:
         Line(X,Y, X + YOff, Y + XOff, R,G,B )
         Line(X,Y, X + YOff, Y - XOff, R,G,B )
       3:
         Line(X,Y, X + XOff, Y + YOff, R,G,B )
         Line(X,Y, X - XOff, Y + YOff, R,G,B )
       4:
         Line(X,Y, X - YOff, Y + XOff, R,G,B )
         Line(X,Y, X - YOff, Y - XOff, R,G,B )
    else
      CASE Quad
       1:
         PutPixel( X + XOff, Y - YOff, R,G,B )
         PutPixel( X - XOff, Y - YOff, R,G,B )
       2:
         PutPixel( X + YOff, Y + XOff, R,G,B )
         PutPixel( X + YOff, Y - XOff, R,G,B )
       3:
         PutPixel( X + XOff, Y + YOff, R,G,B )
         PutPixel( X - XOff, Y + YOff, R,G,B )
       4:
         PutPixel( X - YOff, Y + XOff, R,G,B )
         PutPixel( X - YOff, Y - XOff, R,G,B )

    if Sum < 0
      Sum += (XOff << 2) + 6
    else
      Sum += ( ( XOff - YOff ) << 2 ) + 10
      YOff--
    XOff++

{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}
