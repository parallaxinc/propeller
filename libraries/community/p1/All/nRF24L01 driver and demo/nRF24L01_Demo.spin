''****************************************
''*  nFR24L01 Demo                       *
''*  Authors: Nikita Kareev              *
''*  See end of file for terms of use.   *
''****************************************
''
'' Nordic nRF24L01 demo
'' Reads data from Nordic FOB (http://www.sparkfun.com/commerce/product_info.php?products_id=8602)
'' Tested on:
'' http://www.sparkfun.com/commerce/product_info.php?products_id=691
''
'' Updated... 6 SEP 2009
''
'' Rev 0.1
CON
  _clkmode = xtal1 + pll16x                           
  _xinfreq = 5_000_000
    
OBJ   

  SER      : "FullDuplexSerialPlus"     'Serial port
  RECEIVER : "nRF24L01"                 'Nordic nRF24L01
  
CON

  'Pins
  SPI_SCK = 5 
  SPI_MISO = 7
  SPI_MOSI = 6 
  SPI_CSN = 4     
  SPI_CE = 3
  SPI_IRQ = 9

PUB Demo | payload[4], idx

  'Set IRQ pin state 
  dira[SPI_IRQ] := 0

  'Initialize serial (use Parallax Debug Terminal for feedback)
  SER.start(31, 30, 0, 57600)
  waitcnt(clkfreq*2 + cnt)
  SER.tx(SER#CLS)

  'Initialize Nordic nRF24L01
  RECEIVER.Init(SPI_SCK, SPI_MISO, SPI_MOSI, SPI_CSN, SPI_CE)
  SER.str(String("Receiver configured. Waiting for packets..."))
  SER.str(String(SER#CR)) 

  repeat
    if ina[SPI_IRQ]  == 0 'Wait for incoming data
      'We have some data
      payload := RECEIVER.ReadPayload
      SER.str(String("Data received: "))
      repeat idx from 0 to 3 
        SER.hex(payload[idx], 2)
      SER.str(String(SER#CR))
             