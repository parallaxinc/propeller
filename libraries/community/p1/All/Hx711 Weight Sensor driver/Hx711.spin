{{      
************************************************
* Propeller Hx711 Engine  .. Spin Version  v.1 *
************************************************

Revision History:
         V.1   - first attempt
}}
CON
' The number of clock bits sets the gain for the next sample. There are always 24bits of data.
' Always send 24 clock bits + Bits

  Bits = 1                                      '25 bits = 128 gain CHANNEL A
' Bits = 2                                      '26 bits = 32 gain CHANNEL B!!!!!
' Bits = 3                                      '27 bits = 64 gain CHANNEL A
  

VAR
  long  ClockDelay
  long  _Cpin
  long  _Dpin
  long  _Scale
  long  _Offset

PUB start (Dpin, Cpin)

' Setup the Clock delay count value and pin directions
'
' Must call this once before use

  _Cpin := Cpin
  _Dpin := Dpin
  _Scale := 1880                                        ' reasonable value to start with
  _Offset := 5081                                       ' measure you offset with the zero command and then put in here

  ClockDelay := (clkfreq / 1000000) * 10                ' 1uS clock pulse
  outa[_Cpin]~                                          ' set initial clock state, low to enable Hx711, if high chip powers down after 60uS
  dira[_Cpin]~~                                         ' make cpin output
  dira[_Dpin]~                                          ' make Data pin input  

PUB Ready
' returns the state of the Hx711, true if there is data to read.
' Hx711 data pin is low when data is ready.
'
  return not ina[_Dpin]
  
PUB ReadRaw|Value
' Data is MSB first with pre clock.
' Raw version, not scaled or offset corrected
  Value~                                                ' clear output 

  repeat 24
    Clock
    Value := (Value << 1) | ina[_Dpin]

  repeat Bits                                           ' extra clocks set the gain for the next sample, see above.
    Clock

  case bits
    1:
      Value := Value / 128                              ' correct for the 128 gain
    2:
      Value := Value / 32
    3:
      Value := Value / 64

  return Value    

PUB Read
' Corrected and polished version
  return (((ReadRaw * 10000) / _Scale) - _Offset)

PUB ReadSmooth(Samples)|AccValue
' returns averaged value

  AccValue := 0

  repeat Samples
    repeat
    until Ready                                     ' wait for the Hx711 to be ready.
    AccValue := AccValue + Read                     ' average the value over 100 samples

  return (AccValue / Samples)
 
Pub Clock
  outa[_Cpin]~~
  waitcnt(cnt+ClockDelay)
  outa[_Cpin]~
  waitcnt(cnt+ClockDelay)

Pub GetScale
  return _Scale

Pub SetScale(Scale)
  _Scale := Scale
  return _Scale
  
Pub GetOffset
  return _Offset

Pub SetOffset(Offset)
  _Offset := Offset
  return _Offset

Pub ZeroOffset|AccValue
' zero the scale. call when the scale is empty

  AccValue := 0

  repeat 100
    repeat
    until Ready                                     ' wait for the Hx711 to be ready.
    AccValue := AccValue + ReadRaw                     ' average the value over 100 samples

  _Offset := ((AccValue * 100) / _Scale)            ' Need to get back to  multiplying by 10000 again to get reasonable sized number, so could sample 1000 and muliply by 10

  return _Offset
  
DAT
