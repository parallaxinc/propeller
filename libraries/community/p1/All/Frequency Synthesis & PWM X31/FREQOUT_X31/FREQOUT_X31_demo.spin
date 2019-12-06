CON

  { ==[ CLOCK SET ]== }
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000

OBJ

  FREQ  : "FREQOUT_X31"

VAR

PUB Main

  Example1
  'Example2

PUB Example1 | duty[31], pin[31], freqo[31], i
'' Example of use 1 
                         
  longfill(@pin, -1, 31)                                ' make sure all unwanted pins are inactive

  longfill(@duty, 50, 31)                               ' default all pins to 50% duty

  REPEAT i FROM 0 TO 15
    pin[i] := i                                         ' set pins 0 through 15
    freqo[i] := i * 20 + 400                            ' frequency on this pin is the pin number times 20 plus 400
              
  FREQ.start(@duty, @pin, @freqo)

PUB Example2 | duty[31], pin[31], freqo[31], i
'' Example of use 2 
                         
  longfill(@pin, -1, 31)                                ' make sure all unwanted pins are inactive

  longfill(@duty, 50, 31)                               ' default all pins to 50% duty

  pin[0] := 5                                           
  freqo[0] := 1234                                      ' set pin 5 to 1234Hz

  pin[1] := 6
  freqo[1] := 2345                                      ' set pin 6 to 2345Hz at 30% duty
  duty[1] := 30

  pin[2] := 3
  freqo[2] := 3456                                      ' set pin 3 to 3456Hz at 70% duty
  duty[2] := 70

  pin[3] := 8
  freqo[3] := 10000                                     ' set pin 8 to 10000Hz

  pin[4] := 10
  freqo[4] := 4567                                      ' set pin 10 to 4567Hz at 52% duty
  duty[4] := 52
  
              
  FREQ.start(@duty, @pin, @freqo)

