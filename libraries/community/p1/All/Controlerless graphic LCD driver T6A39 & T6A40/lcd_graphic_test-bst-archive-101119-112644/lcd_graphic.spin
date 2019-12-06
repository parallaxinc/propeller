{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│               Alex Pirvulescu     Controller-less T6A39/T6A40 240x64 LCD driver                                              │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│    TERMS OF USE: Parallax Object Exchange License                                                                            │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

Pinout:
  1 - Din       LCD data in
  2 - FLM       LCD frame indicator
  3 - NC        not connected
  4 - LP        LCD line indicator
  5 - SCP       LCD pixel clock
  6 - GND       LCD logic GND
  7 - Vcc       LCD logic +5V
  8 - GND       LCD driving ground
  9 - Vee       LCD negative contrast voltage -12V
  10- V0        LCD bias voltage (100k pot cursor with one end connected to GND and the other end connected to Vee)
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  LCD_D         = 16 ' LCD Din pin
  LCD_FLM       = 17 ' LCD FLM pin
  LCD_LP        = 18 ' LCD LP pin
  LCD_SCP       = 19 ' LCD SCP pin

  WIDTH         = 240
  HEIGHT        = 64
  WIDTH_BYTES   = WIDTH / 8
  HEIGHT_BYTES  = HEIGHT / 8
  RESOLUTION    = WIDTH * HEIGHT
  FB_SIZE        = RESOLUTION / 8

  CFG_ROTATED   = 1<<0

  CMD_PIXEL     = 1
  CMD_CHAR      = 2

VAR
  byte _fb[FB_SIZE]
  byte _txt_col, _txt_line
  byte _gr_x, _gr_y
  long ptrs[4]
  long config
  long gr_command[8]

OBJ
  font : "Font_ATARI_DEMO"


{{
        Starts the LCD refresh loop. Eats 1 cog

        I've used a HLM2644 display from a Toshiba copier with pins on the left side for normal position.
        If "rotated" is 1 then the pins will be on the right side for normal position
}}
PUB Start(rotated)
  config := 0
  if rotated == 1
    config |= CFG_ROTATED
  gr_command := 0               ' no graphics command for the moment
  ptrs[0] := @gr_command        ' pointer to graphics command
  ptrs[1] := @_fb               ' pointer to framebuffer
  ptrs[2] := font.GetPtrToFontTable ' pointer to font
  ptrs[3] := config           ' pointer to config

  Clear(0)
  _txt_col := 0
  _txt_line := 0
  cognew(@refresh_entry, @ptrs)

{{
  Sets a pixel to the desired value: 1 - black, 0 - white
}}

PUB SetPixel(X, Y, V)
  gr_command[1] := X
  gr_command[2] := Y
  gr_command[3] := V
  gr_command[0] := CMD_PIXEL
  _gr_x := X
  _gr_y := Y
  repeat while gr_command[0]

PUB DrawLineTo(X, Y, V)
  DrawLine(_gr_x, _gr_y, X, Y, V)

{{
  Draws a line from x0, y0 to x1, y1 with the specified "color": 1 - black, 0 - white
}}
PUB DrawLine(x0, y0, x1, y1, _color) | dx, dy, difx, dify, sx, sy, ds

'Draw a straight line from (x0, y0) to (x1, y1).

  difx := ||(x0 - x1)           'Number of pixels in X direciton.
  dify := ||(y0 - y1)           'Number of pixels in Y direction.
  ds := difx <# dify            'State variable change: smaller of difx and dify.
  sx := dify >> 1               'State variables: >>1 to split remainders between line ends.
  sy := difx >> 1
  dx := (x1 < x0) | 1           'X direction: -1 or 1
  dy := (y1 < y0) | 1           'Y direction: -1 or 1
  repeat (difx #> dify) + 1     'Number of pixels to draw is greater of difx and dify, plus one.
    setpixel(x0, y0, _color)           'Draw the current point.
    if ((sx -= ds) =< 0)        'Subtract ds from x state. =< 0 ?
      sx += dify                '  Yes: Increment state by dify.
      x0 += dx                  '       Move X one pixel in X direciton.
    if ((sy -= ds) =< 0)        'Subtract ds from y state. =< 0 ?
      sy += difx                '  Yes: Increment state by difx.
      y0 += dy                  '       Move Y one pixel in Y direction.

  _gr_x := x1
  _gr_y := y1

{{
  Draws a circle with center on x0, y0, radius and "color"
}}
PUB DrawCircle(_x0, _y0, _radius, _color) | f, ddF_x, ddF_y, x, y
  f := 1 - _radius
  ddF_x := 0
  ddF_y := -2 * _radius
  x := 0
  y := _radius
  SetPixel(_x0, _y0 + _radius, _color)
  SetPixel(_x0, _y0 - _radius, _color)
  SetPixel(_x0 + _radius, _y0, _color)
  SetPixel(_x0 - _radius, _y0, _color)

  repeat while x < y
    if f>= 0
      y--
      ddF_y += 2
      f += ddF_y

    x++
    ddF_x += 2
    f += ddF_x + 1
    SetPixel(_x0 + x, _y0 + y, _color)
    SetPixel(_x0 - x, _y0 + y, _color)
    SetPixel(_x0 + x, _y0 - y, _color)
    SetPixel(_x0 - x, _y0 - y, _color)
    SetPixel(_x0 + y, _y0 + x, _color)
    SetPixel(_x0 - y, _y0 + x, _color)
    SetPixel(_x0 + y, _y0 - x, _color)
    SetPixel(_x0 - y, _y0 - x, _color)

{{
  Clears the display buffer
}}
PUB Clear(V)
  if V
    bytefill(@_fb, $ff, FB_SIZE)
  else
    bytefill(@_fb, $00, FB_SIZE)

PUB DrawChar(line, col, ch)
  gr_command[1] := line
  gr_command[2] := col
  gr_command[3] := ch
  gr_command[0] := CMD_CHAR

  repeat while gr_command[0]

{{
  Sets the text position for char(), str(), dec(), bin() and hex() display
}}
PUB GoTo(_line, _col)
  _txt_line := _line
  _txt_col := _col

  if _txt_line > 7
    _txt_line := 7
  if _txt_col > 30
    _txt_col := 30

{{
  Draws a char to current position
}}
PUB Char(ch)
  DrawChar(_txt_line, _txt_col, ch)
  _txt_col++
  if _txt_col == 30
    _txt_col := 0
    _txt_line++
    if _txt_line == 8
      _txt_line := 0

PUB Str(stringptr)
  repeat strsize(stringptr)
    Char(byte[stringptr++])

PUB Dec(value) | i, x
  x := value == NEGX            'Check for max negative
  if value < 0
    value := ||(value+x)        'If negative, make positive; adjust for max negative
    Char("-")   'and output sign

  i := 1_000_000_000            'Initialize divisor

  repeat 10     'Loop for 10 digits
    if value => i
      Char(value / i + "0" + x*(i == 1))        'If non-zero digit, output digit; adjust for max negative
      value //= i               'and digit from value
      result~~  'flag non-zero found
    elseif result or i == 1
      Char("0") 'If zero digit (or only digit) output it
    i /= 10     'Update divisor

PUB Bin(value, digits)
  value <<= 32 - digits
  repeat digits
    Char((value <-= 1) & 1 + "0")

PUB Hex(value, digits)
  value <<= (8 - digits) << 2
  repeat digits
    Char(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

DAT
        org   0

refresh_entry
        ' control pins are outputs
        or dira, LCD_D_SHIFT
        or dira, LCD_FLM_SHIFT
        or dira, LCD_LP_SHIFT
        or dira, LCD_SCP_SHIFT

        ' control pins are initially low
        andn outa, LCD_D_SHIFT
        andn outa, LCD_FLM_SHIFT
        andn outa, LCD_LP_SHIFT
        andn outa, LCD_SCP_SHIFT

        mov _t1, par
        rdlong _cmd_base, _t1
        add _t1, #4
        rdlong _fb_base, _t1     ' pointer to framebuffer
        add _t1, #4
        rdlong _font_base, _t1   ' pointer to font
        add _t1, #4
        rdlong _config, _t1      ' pointer to configuration register
        add _t1, #4

frame_loop

        mov _fb_address, _fb_base

        or outa, LCD_FLM_SHIFT  ' FLM high on first line

        mov _c_line, #HEIGHT    ' HEIGHT lines follow

line_loop

        mov _c_col, #WIDTH_BYTES ' WIDTH pixels per line

col_loop
        rdbyte _fb_data, _fb_address
        shl _fb_data, #24
        add _fb_address, #1

        mov _px_cnt, #8              ' 8 pixels per byte
pixel_loop
        shl _fb_data, #1 wc     ' shift one pixel into lcd
        if_c or outa, LCD_D_SHIFT
        if_nc andn outa, LCD_D_SHIFT

        ' pulse SCP
        mov _timer, cnt
        add _timer, PULSE_DELAY
        or outa, LCD_SCP_SHIFT
        waitcnt _timer, PULSE_DELAY
        andn outa, LCD_SCP_SHIFT
        'waitcnt timer, PULSE_DELAY

        call #graphics_command

pixel_cont

        djnz _px_cnt, #pixel_loop

        djnz _c_col, #col_loop

        ' pulse LP
        mov _timer, cnt
        add _timer, PULSE_DELAY
        or outa, LCD_LP_SHIFT
        waitcnt _timer, PULSE_DELAY
        andn outa, LCD_LP_SHIFT
        'waitcnt timer, PULSE_DELAY

        andn outa, LCD_FLM_SHIFT' FLM low after the first line

:nextline
        djnz  _c_line, #line_loop


        jmp #frame_loop

graphics_command
        rdlong _cmd, _cmd_base wz
  if_z  jmp #graphics_command_ret

        cmp _cmd, #CMD_PIXEL wz
  if_z  call #gr_pixel
        cmp _cmd, #CMD_CHAR wz
  if_z  call #gr_char

gr_done
        wrlong ZERO, _cmd_base               ' reset command

graphics_command_ret
        ret

gr_pixel
        mov _cmd, _cmd_base
        add _cmd, #4
        rdlong px, _cmd  ' x coord
        add _cmd, #4
        rdlong py, _cmd  ' y coord
        add _cmd, #4
        rdlong pc, _cmd  ' color
        call #pixel_sub
gr_pixel_ret
        ret

pixel_sub
        test _config, #CFG_ROTATED wz
  if_z  jmp #pixel_sub_not_rotated
        mov   _t1, #WIDTH - 1
        sub _t1, px
        mov px, _t1

        mov _t1, #HEIGHT - 1
        sub _t1, py
        mov py, _t1

pixel_sub_not_rotated
        mov _t1, px
        shr _t1, #3

        mov _m1, py
        mov _m2, #WIDTH_BYTES


        call #multiply

        add _t1, _mr
        add _t1, _fb_base

        mov _t2, px
        xor _t2, #7
        and _t2, #7
        mov _t3, #1
        shl _t3, _t2

        rdbyte _t4, _t1
        cmp pc, #1 wz
  if_z  or _t4, _t3
  if_z  jmp #pixel_sub_end
        cmp pc, #2 wz
  if_z  xor _t4, _t3
  if_z  jmp #pixel_sub_end
        andn _t4, _t3
pixel_sub_end
        wrbyte _t4, _t1

pixel_sub_ret
        ret

gr_char
        mov _cmd, _cmd_base
        add _cmd, #4
        rdlong cline, _cmd ' line
        add _cmd, #4
        rdlong ccol, _cmd ' column
        add _cmd, #4
        rdlong cchar, _cmd ' char

        test _config, #CFG_ROTATED wz
  if_z  jmp #gr_char_not_rotated
        mov _t1, #HEIGHT_BYTES
        sub _t1, #1
        sub _t1, cline
        mov cline, _t1

        mov _t1, #WIDTH_BYTES
        sub _t1, #1
        sub _t1, ccol
        mov ccol, _t1

gr_char_not_rotated
        mov cfbptr, _fb_base
        mov _m1, cline
        mov _m2, #WIDTH
        call #multiply
        add cfbptr, _mr
        add cfbptr, ccol

        test _config, #CFG_ROTATED wz
  if_z  jmp #gr_char_fb_not_rotated
        add cfbptr, #WIDTH - WIDTH_BYTES
gr_char_fb_not_rotated
        mov cptr, cchar
        shl cptr, #3
        add cptr, _font_base

        mov _t1, #8
        test _config, #CFG_ROTATED wz
  if_z  jmp #char_loop_not_rotated
char_loop_rotated
        rdbyte _t2, cptr
        rev _t2, #24
        wrbyte _t2, cfbptr
        add cptr, #1
        sub cfbptr, #WIDTH_BYTES
        djnz _t1, #char_loop_rotated
        jmp #gr_char_ret


char_loop_not_rotated
        rdbyte _t2, cptr
        wrbyte _t2, cfbptr
        add cptr, #1
        add cfbptr, #WIDTH_BYTES
        djnz _t1, #char_loop_not_rotated

gr_char_ret
        ret



multiply
        shl _m1, #16
        mov _mt, #16
        shr _m2, #1      wc

:mloop
  if_c  add _m2, _m1      wc
        rcr _m2, #1      wc
        djnz _mt, #:mloop
        mov _mr, _m2
multiply_ret
        ret


PULSE_DELAY   long      20

LCD_D_SHIFT   long |< LCD_D
LCD_FLM_SHIFT long |< LCD_FLM
LCD_LP_SHIFT  long |< LCD_LP
LCD_SCP_SHIFT long |< LCD_SCP

ZERO          long 0                       'constants

_fb_base      res 1
_fb_data      res 1
_fb_address   res 1

_font_base    res 1
_config       res 1

_cmd_base res 1
_cmd   res 1


' pixel vars
px                      res     1
py                      res     1
pc                      res 1 ' pixel color

' char vars
cline   res 1
ccol    res 1
cchar   res 1
cptr    res 1
cfbptr  res 1

_t1            res 1
_t2            res 1
_t3            res 1
_t4            res 1
_t5            res 1

_timer         res 1
_c_line       res 1
_c_col        res 1
_px_cnt           res 1

' multiply vars
_m1      res 1
_m2      res 1
_mt      res 1
_mr      res 1
