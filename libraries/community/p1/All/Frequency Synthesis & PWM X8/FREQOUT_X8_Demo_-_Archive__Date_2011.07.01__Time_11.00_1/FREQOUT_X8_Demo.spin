CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

OBJ

  FREQ8 : "FREQOUT_X8"

VAR

  LONG freq_set[8]  
  LONG io_pin[8]

PUB Main

  io_pin[0] := 8
  io_pin[1] := 9
  io_pin[2] := 10
  io_pin[3] := 11
  io_pin[4] := 12
  io_pin[5] := 13
  io_pin[6] := 14
  io_pin[7] := 15
                           
  freq_set[0] := 2000
  freq_set[1] := 4000
  freq_set[2] := 6000
  freq_set[3] := 8000
  freq_set[4] := 10000
  freq_set[5] := 12000
  freq_set[6] := 14000
  freq_set[7] := 16000

  FREQ8.start(80, @io_pin, @freq_set)
