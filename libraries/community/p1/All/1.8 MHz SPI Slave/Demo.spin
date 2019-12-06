
{ Demo for SPI Slave
  Pin       Slave   Master
  MOSI:     1       11
  Clock:    0       10
  Chip Sel: 2       12
  The simulated master has a clock frequency of about 20 kHz; the PASM cog
  will run at up to 1.8 MHz.}
CON
        _clkmode = xtal1 + pll16x    'Standard clock mode 
        _xinfreq = 5_000_000         '* crystal frequency = 80 MHz

        SPI_Clock = 0, SPI_Data = 1,  SPI_CS = 2  'clock, data, and CS for slave receiver
        outclk = 10, outdata=11, outCS = 12      'clock, data, and CS for master transmitter    
        
VAR
  long  XmitData            'data send by demo program
  byte  XmitCount            'number of bits
    
  long  RcvData             'data received by machine cog
  byte  RcvCount             'number of bits received

  byte  example             'will demo several examples              '
  byte  TheCog              'used to report the cog number
  
OBJ
  pst      : "parallax serial terminal"
  sps      : "SPI Slave"
  
PUB main
    pst.Start (115_200)                    'start up serial terminal
    pst.str(String("hello, world   "))     'runs in cog 1
    pst.NewLine
    waitcnt(clkfreq/10 + cnt)

    dira[outclk]~~                       'outputs run in this cog
    dira[outdata]~~
    outa[outCS]~~                        'make sure this comes on High
    dira[outCS]~~
    
          {
          sps.start(Clock Pin, Data Pin, Chip Select Pin,
          Address of a long into which the received data will be written,
          Address of a byte into which the bit count of received data will be written)
           }      

    TheCog := sps.start(SPI_Clock, SPI_Data, SPI_CS, @RcvData, @RcvCount)
    pst.str(string("Started SPI Slave Cog.  Cog Number: "))
    pst.dec(TheCog)
    pst.newline

    repeat example from 0 to 6
      RcvCount := 0            'receiver cog will change this to actual bit count
      XMitData := lookupz(example: $12345678, $FFFFABCD, $55551942, $DEADBEEF, $DEADBEEF, $DEADBEEF, $DEADBEEF) 
      XmitCount := lookupz(example: 32, 16, 8, 32, 24, 16, 8) 'number of bits to send
      SimulateMaster(XmitData, XMitCount)                  'simulate an SPI master 
      repeat while (RcvCount == 0)    'wait for receiver to complete
      
      pst.str(string("Example: "))      'display it all
      pst.hex(example, 1)
      pst.str(string("  Bits Transmitted: "))
      pst.dec(lookupz(example: 32, 16, 8, 32, 24, 16, 8))
      pst.str(string("  Data Transmitted: "))
      pst.hex(XmitData, XmitCount/4)
      pst.str(string("  Bits Received: "))
      pst.dec(RcvCount)
      pst.str(string("  Data Received: "))
      pst.hex(RcvData, 8)
      pst.newline                 
      
    sps.stop
    pst.str(string("Stopped SPS Cog"))
    pst.newline
    waitcnt(clkfreq+cnt)

pri SimulateMaster(Data, Count)|MyCount
    outa[outCS]~                                     'active low chip select
    repeat MyCount from Count-1 to 0
      outa[outData] := (Data >> MyCount) & %1        'set data bit onto data pin
      outa[OutClk]~~                                 'clock High
      outa[OutClk]~                                  'then low
    outa[outData]~                                   'just cosmetic
    outa[outCS]~~                                    'chip select goes not active  
                                                                          