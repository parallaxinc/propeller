{
                                *****************|| SERIAL COMMUNICATION LOGIC ||*********************

  This system uses a data line [SDA], clock line [CLK], and chip select line [CS], in order to transmit data from one
  Propeller chip to another. The data works similar to I2C protocol, in that it is half duplex, bidirectional communication.
  However, the key difference is that the slave uses the CS line to indicate a termination of transmission. Capable currently
  of only handling one byte at a time, the data is transferred during a low CS state, and on high CLK pulses. When the CS is
  low and the CLK is high, the slave reads the state of the SDA line and loads it into a byte buffer. After eight bits have
  been transferred, the slave has received the byte of data and can terminate the data transfer by setting the CS pin to a
  high state. By using checkstop the master can hold all commands within the cog until the slave has administered the
  termination command. This is useful in applications that rely on the slave performing a mechanical task based on commands
  from the master, in that the slave can receive the command byte and then act upon the command, performing a mechanical
  action via motors or other systems, and then when the command is complete signal this by issuing the termination signal
  (high state on the CS pin). Likewise, the slave should be programmed to halt all receive commands until the CS line is
  driven low by the master device. 

  **for use with I2C_Slave.spin 
}

var
  long SDA, CLK, CS, counter

pub initialize(data, clock, chipselect)                 'Use this routine to ID the data line, the clock line, and the chip select line

  SDA := data
  CLK := clock
  CS := chipselect
  dira[SDA]~~
  dira[CLK]~~
  dira[CS]~~
  outa[CS]~~
  outa[CLK]~~
  outa[SDA]~~     

pub start                                               'to inform the slave device of a communication start
  dira[CS]~~
  dira[CLK]~~
  outa[CS]~
  outa[CLK]~
pub tx(info)                                            'transmit a byte to the slave device                                         
  pause(1_000)
  dira[SDA]~~
  dira[CLK]~~
  info <<= 24                           
  repeat 8                           
     outa[SDA] := (info <-= 1) & 1   
     outa[CLK]~~
     pause(1000)
     outa[CLK]~
     pause(1000)
pub checkstop                                           'check for the acknowledge signal from the slave device
  dira[CS]~
  waitpeq(|< CS, |< CS, 0)
  dira[CS]~~
  outa[CS]~~

pub rx | info                                           'receive a byte from the slave device
  pause(1_000)
  info := 0                          
  dira[SDA]~
  repeat 8                                              
     outa[CLK]~~                     
     info := (info << 1) | ina[SDA]
     pause(1000) 
     outa[CLK]~
     pause(1000)
  return info

pub pause(delay)                                        'a waitcnt routine for faster programming
  waitcnt(delay + cnt)
                      