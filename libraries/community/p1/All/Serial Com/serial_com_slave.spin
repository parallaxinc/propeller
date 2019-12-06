{
                                *****************|| SERIAL COMMUNICATION LOGIC ||*********************

  This routine is the complement to the serial_com.spin routine. It is strictly for the slave device, just as
  the serial_com.spin program is for the master device. Further documentation is provided on the other programs

  **for use with serial_com.spin
}

var
  long SDA, CLK, CS, counter

pub initialize(data, clock, chipselect)                 'activate slave and identify data line, clock line, and chip select

  SDA := data
  CLK := clock
  CS := chipselect
  dira[SDA]~
  dira[CLK]~
  dira[CS]~

pub tx(info)                                            'transmit a byte of data to the master device
  dira[SDA]~~   
  info <<= 24
  counter := 0
  outa[SDA] := (info <-= 1) & 1
  repeat 8     
    waitpeq(|< CLK, |< CLK, 0)
    waitpeq(0, |< CLK, 0)
    outa[SDA] := (info <-= 1) & 1
  dira[SDA]~

pub stop                                                'send the stop signal (high state, CS pin)
  dira[CS]~~
  outa[CS]~~
  dira[CS]~
  
pub checkstart                                          'halt program until the start command is issued by the master device
  waitpeq(0, |< CS, 0)
  
pub rx | info                                           'receive a byte from the master device
  info := 0                          
  dira[SDA]~
  repeat 8                                              
    waitpeq(|< CLK, |< CLK, 0)                     
    info := (info << 1) | ina[SDA]   
    waitpeq(0, |< CLK, 0)
  return info                      