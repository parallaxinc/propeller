{{

┌──────────────────────────────────────────┐
│ ADS1118 Driver v0.3                      │
│ Author: Greg LaPolla                     │               
│ Email: glapolla@gmail.com                │               
│ Copyright (c) 2020 Greg LaPolla          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘
 This object is based on  ADS1115_2v1 by Tracy Allen & Michael McDonald

}}

CON

  START_NOW     = 1 << 15                                     ' Start of conversion in single-shot mode      

                                                              ' Input multiplexer configuration selection for bits "MUX"
                                                              ' Differential inputs
  DIFF_0_1      = %000 << 12                                  ' Differential input: Vin=A0-A1
  DIFF_0_3      = %001 << 12                                  ' Differential input: Vin=A0-A3
  DIFF_1_3      = %010 << 12                                  ' Differential input: Vin=A1-A3
  DIFF_2_3      = %011 << 12                                  ' Differential input: Vin=A2-A3   

                                                              ' Single ended inputs
  AIN_0         = %100 << 12                                  ' Single ended input: Vin=A0
  AIN_1         = %101 << 12                                  ' Single ended input: Vin=A1
  AIN_2         = %110 << 12                                  ' Single ended input: Vin=A2
  AIN_3         = %111 << 12                                  ' Single ended input: Vin=A3

                                                              ' Full scale range (FSR) selection by "PGA" bits. 
  FSR_6144      = %000 << 9                                   ' Range: ±6.144 v. LSB SIZE = 187.5μVFSR is +- 6.144 V
  FSR_4096      = %001 << 9                                   ' Range: ±4.096 v. LSB SIZE = 125μV
  FSR_2048      = %010 << 9                                   ' Range: ±2.048 v. LSB SIZE = 62.5μV ***DEFAULT
  FSR_1024      = %011 << 9                                   ' Range: ±1.024 v. LSB SIZE = 31.25μV
  FSR_512       = %100 << 9                                   ' Range: ±0.512 v. LSB SIZE = 15.625μV
  FSR_256       = %101 << 9                                   ' Range: ±0.256 v. LSB SIZE = 7.8125μV

	                                                          ' Used by "MODE" bit
  CONTINUOUS    = 0 << 8                                      ' Continuous conversion mode
  SINGLE_SHOT   = 1 << 8                                      ' Single-shot conversion and power down mode
  
                                                              ' Sampling rate selection by "DR" bits. 
  RATE8SPS      = %000 << 5                                   ' 8 samples/s, Tconv=125ms
  RATE16SPS     = %001 << 5                                   ' 16 samples/s, Tconv=62.5ms
  RATE32SPS     = %010 << 5                                   ' 32 samples/s, Tconv=31.25ms
  RATE64SPS     = %011 << 5                                   ' 64 samples/s, Tconv=15.625ms
  RATE128SPS    = %100 << 5                                   ' 128 samples/s, Tconv=7.8125ms ***DEFAULT
  RATE250SPS    = %101 << 5                                   ' 250 samples/s, Tconv=4ms
  RATE475SPS    = %110 << 5                                   ' 475 samples/s, Tconv=2.105ms
  RATE860SPS    = %111 << 5                                   ' 860 samples/s, Tconv=1.163ms

                                                              ' Used by "TS_MODE" bit 
  ADC_MODE       = 0 << 4                                     ' External (inputs) voltage reading mode
  TEMP_MODE      = 1 << 4                                     ' Internal temperature sensor reading mode

                                                              ' Used by "PULL_UP_EN" bit
  DOUT_PULLUP    = 1 << 3                                     ' Internal pull-up resistor enabled for DOUT ***DEFAULT
  DOUT_NO_PULLUP = 0 << 3                                     ' Internal pull-up resistor disabled

                                                              ' Used by "NOP" bits
  VALID_CFG      = %01 << 1                                   ' Data will be written to Config register
  NO_VALID_CFG   = %00 << 1                                   ' Data won't be written to Config register
  READY          = 0

  _ClockDelay    = 15                                          ' Clock delay in us
  _ClockState    = 0                                           ' Clock state 

 _10us           = 1_000_000 /        10                       ' Divisor for 10 us
  _1ms           = 1_000_000 /     1_000                       ' Divisor for 1 ms
  _1s            = 1_000_000 / 1_000_000                       ' Divisor for 1 s
 Bits            = 8
 
VAR
  word mode0                                                  ' Configuration string
  byte ipga
  byte wsps                                                   ' interal wait time factor for conversion to complete based on samples per second 
  long cs,sclk,din,dout                                       ' Communication pins for chip
  long ClockDelay,ClockState

PUB Start (_cs,_sclk,_din,_dout)

  cs   := _cs
  sclk := _sclk
  din  := _din
  dout := _dout

  ClockState := _ClockState
  ClockDelay := ((clkfreq / 100000 * _ClockDelay) - 4296) #> 381    
  Configure(RATE250SPS, SINGLE_SHOT, READY)                   ' default configuration

PUB Configure (samplesPerSecond, shotMode, comparatorMode)
  
  mode0 := constant(1 << 15)|shotMode |samplesPerSecond |comparatorMode| VALID_CFG
  wsps := samplesPerSecond >> 5+2     ' 5 + 2    ' sets up for conversion wait time  4 is about twice the minimum wait

PUB ReadExplicit(channel, pga)| mode
  
  mode := mode0 |pga |channel |ADC_MODE
  ipga := pga >> 9
  
  low(cs)
  Write(mode.byte[1])
  Write(mode.byte[0])
  high(cs)
  
  return ReRead

PUB ReadTemp | mode, temp, time

  mode := mode0 |TEMP_MODE
  time := (clkfreq / _10us * 10) #> 381    
  
  low(cs)
  Write(mode.byte[1])
  Write(mode.byte[0])
  high(cs)
  
  waitcnt(time + cnt)  
  temp := Sample >> 2
  temp := temp * 3125 / 100000
  
  return temp
  
PUB ReadTempV | mode, temp, time

  mode := mode0 |TEMP_MODE
  time := (clkfreq / _10us * 10) #> 381    
  
  low(cs)
  Write(mode.byte[1])
  Write(mode.byte[0])
  high(cs)
  
  waitcnt(cnt + time)    
  temp := Sample >> 2
  
  return temp


PUB Nread(channel, pga, Nsamples, samplesPerSecond) | idx
  if (ina[dout] == 1)
    return negx

  Configure(samplesPerSecond,CONTINUOUS,READY)
  result := ReadExplicit(channel, pga)
  repeat idx from 1 to Nsamples - 1
    result += ReRead

  Configure(samplesPerSecond,SINGLE_SHOT,READY)

PRI ReRead

  result := Sample
  ~~result                                                            ' sign extend 16 bits to 32

  case ipga
    constant(FSR_6144 >> 9) : result := result * 187 + result / 2     ' units of 187.5 microvolts per bit
    constant(FSR_4096 >> 9) : result := result * 125                  ' units of 125 microvolts per bit
    constant(FSR_2048 >> 9) : result := result * 62 + result / 2      ' units of 62.5 microvolts
    constant(FSR_1024 >> 9) : result := result * 32 - result * 3 / 4  ' units of 31 1/4 microvolts
    constant(FSR_512 >> 9) : result := result * 16 - result * 3 / 8   ' units of 15 5/8 microvolts
    constant(FSR_256 >> 9) : result := result * 8 - result * 3 / 16   ' units of 7 13/16 microvolts
  return result

PRI Sample | mark

  mark := (clkfreq >> wsps) * 5 / 4 + cnt               ' (clkfreq*5) >> (wsps+2)
  
  low(cs)
  
  if (ina[dout] == 1)
    repeat 
    until (ina[dout] == 0 )                             'or (cnt - mark > 0)
  else
    waitcnt(mark)
  
  result.byte[1] := Read
  result.byte[0] := Read
  high(cs)
  
  return result

PRI HIGH(Pin)
    dira[Pin]~~
    outa[Pin]~~
    
PRI LOW(Pin)
    dira[Pin]~~
    outa[Pin]~
    
PRI Write(Value)

    dira[din]~~                                          ' make Data pin output
    outa[sclk] := ClockState                             ' set initial clock state
    dira[sclk]~~                                         ' make Clock pin output

    Value <<= (32 - Bits)                                ' pre-align msb
    
    repeat Bits
      outa[din] := (Value <-= 1) & 1                     ' output data bit
      waitcnt(cnt + ClockDelay)
      !outa[sclk]
      waitcnt(cnt + ClockDelay)
      !outa[sclk]

PRI Read |Value

    dira[dout]~                                            ' make dpin input
    outa[sclk] := ClockState                              ' set initial clock state
    dira[sclk]~~                                          ' make cpin output

    Value~                                                ' clear output 

    repeat Bits
      !outa[sclk]
      waitcnt(cnt + ClockDelay)
      !outa[sclk]
      waitcnt(cnt + ClockDelay)
      Value := (Value << 1) | ina[dout]
      
    return Value

PUB dbug(val)

case val
  0 : result := ipga
  1 : result := mode0
  2 : result := wsps
  3 : result := din
  4 : result := dout
  5 : result := sclk
  6 : result := cs

return result
  
DAT

{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
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
}}