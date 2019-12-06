CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


  pin_rs        = 24
  pin_e         = 25
  pin_d4        = 26
  pin_d5        = 27
  pin_d6        = 28
  pin_d7        = 29

VAR
  long Xv
  long _fb_mode
  byte _fb[80]
  byte _x, _y

OBJ
  'debug : "Parallax Serial Terminal"

PUB Init(fb_mode)
  _fb_mode := fb_mode
  InitLCD
  'debug.start(115200)

PRI InitLCD
  dira[pin_rs]~~
  dira[pin_e]~~
  dira[pin_d4]~~
  dira[pin_d5]~~
  dira[pin_d6]~~
  dira[pin_d7]~~

  ' Now init the LCD
  Delay_ms(20)
  outa[pin_rs] := 0

  Send_Nibble($03)
  Delay_ms(1)
  Send_Nibble($03)
  Delay_ms(1)
  Send_Nibble($03)
  Delay_ms(1)
  Send_Nibble($02)
  Delay_ms(1)

  ' we are in 4 bit mode now
  Send_Cmd($28)
  Clear
  Home
  Send_Cmd($0c)

PUB Update | k
  if _fb_mode == 1
    GoToRaw(0, 0)
    repeat k from 0 to 79
      SendDataRaw(_fb[k])

PUB Clear
  if _fb_mode == 1
    bytefill(@_fb, " ", 80)
    Home
  else
    Send_Cmd($01)
    Delay_ms(4)

PUB Home
  if _fb_mode == 1
    _x := 0
    _y := 0
  else
    Send_Cmd($02)
    Delay_ms(4)


PUB GoTo(line, col)
  if _fb_mode == 1
    _x := col
    _y := line
  else
    GoToRaw(line, col)

PRI GoToRaw(line, col)
  case line
    1: Send_Cmd($c0 | col)
    2: Send_Cmd($94 | col)
    3: Send_Cmd($d4 | col)
    OTHER: Send_Cmd($80 | col)

PUB Send_Cmd(cmd_value)
  outa[pin_rs] := 0
  Send_Byte(cmd_value)

PUB Send_Data(data_value)
  'debug.str(string("Sending data: "))
  'debug.char(data_value)
  if _fb_mode == 1
    _fb[_y * 20 + _x] := data_value
    _x++
    if(_x == 20)
      _x := 0
      _y++
      GoToRaw(_y, _x)
      if _y == 4
        _y := 0
        GoToRaw(_y, _x)

    'debug.str(string("  x="))
    'debug.dec(_x)
    'debug.str(string("  y="))
    'debug.dec(_y)
    'debug.char($0a)
  else
    SendDataRaw(data_value)

PRI SendDataRaw(data_value)
  outa[pin_rs] := 1
  Send_Byte(data_value)

PUB Str(stringptr)
  repeat strsize(stringptr)
    Send_Data(byte[stringptr++])

PUB Dec(value) | i, x
  x := value == NEGX                                                            'Check for max negative
  if value < 0
    value := ||(value+x)                                                        'If negative, make positive; adjust for max negative
    Send_Data("-")                                                                   'and output sign

  i := 1_000_000_000                                                            'Initialize divisor

  repeat 10                                                                     'Loop for 10 digits
    if value => i
      Send_Data(value / i + "0" + x*(i == 1))                                        'If non-zero digit, output digit; adjust for max negative
      value //= i                                                               'and digit from value
      result~~                                                                  'flag non-zero found
    elseif result or i == 1
      Send_Data("0")                                                                 'If zero digit (or only digit) output it
    i /= 10                                                                     'Update divisor

PUB Bin(value, digits)
  value <<= 32 - digits
  repeat digits
    Send_Data((value <-= 1) & 1 + "0")

PUB Hex(value, digits)
  value <<= (8 - digits) << 2
  repeat digits
    Send_Data(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PRI Delay_ms(count_ms)
  repeat count_ms
    waitcnt(clkfreq / 1000 + cnt)

PRI Strobe_E
  outa[pin_e] := 1
  'waitcnt(clkfreq / 10000 + cnt)
  outa[pin_e] := 0

PRI Send_Nibble(nibble_value)
  outa[pin_d7] := (nibble_value & $08) >> 3
  outa[pin_d6] := (nibble_value & $04) >> 2
  outa[pin_d5] := (nibble_value & $02) >> 1
  outa[pin_d4] := (nibble_value & $01)
  Strobe_E


PRI Send_Byte(byte_value)
  Send_Nibble(byte_value >> 4)
  Send_Nibble(byte_value & $0f)


