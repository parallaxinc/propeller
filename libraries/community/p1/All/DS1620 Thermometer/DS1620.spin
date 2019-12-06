'' *****************************
'' *  DS1620                   *
'' *  (C) 2006 Parallax, Inc.  *
'' *****************************
''
'' This object provides essential inteface methods to the DS1620; using
'' free-running mode while connected to a host.


CON

  RdTmp         = $AA                                   ' read temperature
  WrHi          = $01                                   ' write TH (high temp)
  WrLo          = $02                                   ' write TL (low temp)
  RdHi          = $A1                                   ' read TH
  RdLo          = $A2                                   ' read TL
  RdCntr        = $A0                                   ' read counter
  RdSlope       = $A9                                   ' read slope
  StartC        = $EE                                   ' start conversion
  StopC         = $22                                   ' stop conversion
  WrCfg         = $0C                                   ' write config register
  RdCfg         = $AC                                   ' read config register

  #0, TempC, TempF


VAR

  word  dpin, cpin, rst, started


OBJ

  io    : "shiftio"  
  delay : "timing" 
    

PUB start(data_pin, clock_pin, rst_pin)

'' Initializes DS1620 for free-run with host CPU 

  dpin := data_pin
  cpin := clock_pin
  rst := rst_pin

  high(rst)                                             ' activate sensor
  io.shiftout(dpin, cpin, io#LsbFirst, WrCfg, 8)        ' write to config register
  io.shiftout(dpin, cpin, io#LsbFirst, %10, 8)          ' set for CPU, free-run
  low(rst)                                              ' deactivate
  delay.pause1ms(10)                                    ' allow EE write
  high(rst)                                             ' reactivate
  io.shiftout(dpin, cpin, io#LsbFirst, StartC, 8)       ' start conversions  
  low(rst)
  started~~                                             ' flag sensor as started


PUB gettempc | tc

'' Returns temperature in 0.1° C units
'' -- resolution is 0.5° C

  if started
    high(rst)                                           ' activate sensor
    io.shiftout(dpin, cpin, io#LsbFirst, RdTmp, 8)      ' send read temp command
    tc := io.shiftin(dpin, cpin, io#LsbPre, 9)          ' read temp in 0.5° C units
    low(rst)                                            ' deactivate sensor

    tc := tc << 23 ~> 23                                ' extend sign bit
    tc *= 5                                             ' convert to 10ths
    return tc
       

PUB gettempf | tf

'' Returns temperature in 0.1° F units
'' -- resolution is 0.9° F

  if started
    tf := gettempc * 9 / 5 + 320                        ' convert to Fahrenheit
    return tf


PUB setlo(alarm, tmode)

'' Sets low-level alarm
'' -- alarm level is passed in 1° units

  if started

    if lookdown(tmode : TempC, TempF)
      
      case tmode
        TempC : alarm <<= 1                             ' convert to 0.5° units
        TempF : alarm := ((alarm - 32) * 5 / 9) << 1    ' convert to C, 0.5° units 
      
      high(rst)
      io.shiftout(dpin, cpin, io#LsbFirst, WrLo, 8)     ' select low temp register
      io.shiftout(dpin, cpin, io#LsbFirst, alarm, 9)    ' write alarm value 
      low(rst)
      delay.pause1ms(10)                                ' allow EE write


PUB sethigh(alarm, tmode)

'' Sets high-level alarm
'' -- alarm level is passed in 1° units 

  if started

    if lookdown(tmode : TempC, TempF)
      
      case tmode
        TempC : alarm <<= 1
        TempF : alarm := ((alarm - 32) * 5 / 9) << 1
      
      high(rst)
      io.shiftout(dpin, cpin, io#LsbFirst, WrHi, 8)     ' select hi temp register
      io.shiftout(dpin, cpin, io#LsbFirst, alarm, 9)    ' write alarm value  
      low(rst)
      delay.pause1ms(10)                                ' allow EE write



PRI high(pin)

  outa[pin]~~                                           ' write "1" to pin
  dira[pin]~~                                           ' make an output


PRI low(pin)

  outa[pin]~                                            ' write "0" to pin
  dira[pin]~~                                           ' make an output