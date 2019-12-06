Con

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  CLK_FREQ = ((_clkmode-xtal1)>>6)*_xinfreq
  MS_001 = CLK_FREQ / 1_000
  
  RFM_SDN = 0
  RFM_IRQ = 1
  RFM_SEL = 2
  RFM_SCK = 3
  RFM_SDI = 4
  RFM_SDO = 5

  ' // SHIFTIN Constants
  MSBPRE   = 0
  LSBPRE   = 1
  MSBPOST  = 2
  LSBPOST  = 3
  OnClock  = 4   ' Used for I2C
  
  ' // SHIFTOUT Constants
  LSBFIRST = 0
  MSBFIRST = 1

  
Obj

  Ser  :  "FullDuplexSerial"             ' 1 Cog


Var

  ' // Input
  long nButton

  ' // RFM
  long nAddress[8], nOutData[8]
  long nSel

  long nCheckSum, PacketSize   
  long anTXBuf[32], anRXBuf[32]

  long RX_ANT, TX_ANT, nInData, nStatus1, nStatus2, LED, nirq    

  ' // SPI
  long RESET, DRDY, SSNOT, MOSI, MISO, SCLK


    

Pub Start | i, dbg

  Ser.start(31, 30, 0, 115200)

  nButton := 0                             ' Set To Transmit on Loop  (Debug, Only One Transciever)

  dira[RFM_IRQ]~                           ' Set IRQ to Input  
  dira[RFM_SDI]~                           ' Set SDI to Input
  dira[RFM_SDO]~~                          ' Set SDO to Output
  dira[RFM_SCK]~~                          ' Set SCK to Output
  dira[RFM_SDN]~~                          ' Set SDN to Output
  outa[RFM_SDN]~                           ' Set SDN Low (Deafult = Chip On) 
  dira[RFM_SEL]~~                          ' Set nSel to Output
  outa[RFM_SEL]~~                          ' Pull nSel High (Defalult State)  

  ' // RFM Init
  RFM_Init
  
  repeat
   
    ' nIRQ Pin Indicates that we have Received a Packet

    nIRQ := INA[RFM_IRQ]
    
    if nIRQ == 0                ' Packet Recieved
    
      ' Clear the Interrupt

      nStatus1 := SPI_IN($03)            ' R, $03   ' Read the Interrupt Registers 1 (in order to clear them)  
      nStatus2 := SPI_IN($04)            ' R, $04   ' Read the Interrupt Registers 2 (in order to clear them)  

      ser.tx(13)
      ser.str(string("nStatus1: "))
      ser.bin(nStatus1, 8)
      ser.tx(13)
      ser.str(string("nStatus2: "))
      ser.bin(nStatus2, 8)
      ser.tx(13)      

      ' Read in the Data

      repeat i from 0 to PacketSize - 1
        nAddress := $7F
        anRxBuf[i] := SPI_IN(nAddress)

      nSel := 1                 ' Unnececessary?

      ' Calculate the Checksum...

      nCheckSum := 0

      repeat i from 0 to PacketSize - 2
        nCheckSum := nCheckSum + anRxBuf[i]
        ser.hex(anRxBuf[i], strsize(anRxBuf[i]))
        ser.str(string(" "))
        anRxBuf[i] := 0

      ser.str(string("ChkSum = "))
      ser.hex(anRxBuf[i], strsize(anRxBuf[i]))
      ser.tx (13)

      ' Verify that the Calculated Checksum matches the Last Byte in the Packet

      if nCheckSum == anRxBuf[PacketSize-1]
        LED := 1
        ser.str(string("ChkSum MATCH!"))
        ser.tx (13)
        Pause(50)
        LED := 0

      RX_Reset                  ' RX Reset

    ' Check for Button Press   *** To Be Altered ***

    if nButton == 0  ' The Button is Pressed...
      ser.str(string("Xmitting"))
      ser.tx (13)

      ' Here would be a good place to load the relevant data into anTxBuf

      ' // Generate TX Test Data
      repeat i from 0 to 30
        anTXBuf[i] := i
              
      To_TX_Mode

      ' and return back to RX_Mode   

      To_RX_Mode

{
        MainLoop:
          'nIRQ Pin Indicates that we have received a packet
          if nIRQ = 0 then 'Packet received
            'Clear the interrupt
            nAddress = $03 : GOSUB SPI_In : nStatus1 = nInData
            nAddress = $04 : GOSUB SPI_In : nStatus2 = nInData
            'Read in the data
            for i = 0 to PacketSize-1
              nAddress = $7F : GOSUB SPI_In : anRxBuf[i] = nInData
            next i
            nSel = 1 'unncecessary?
            'Calculate the checksum...
            nCheckSum = 0
            for i =  0 to PacketSize-2
              nCheckSum = nCheckSum + anRxBuf[i]
              'SEROUT2 PORTA.3,49236,[Ihex2 anRxBuf[i]," "]
              anRxBuf[i] = 0
            next i
            'SEROUT2 PORTA.3,49236,[13,10,"ChkSum=",Ihex2 anRxBuf[i],13,10]
            'Verify that the calculate checksum matches the last byte in the packet                
            if  nChecksum = anRxBuf[PacketSize-1] then
              LED = 1
              'SEROUT2 PORTA.3,49236,["ChkSum MATCH!",13,10]
              PAUSE 500
              LED = 0;
            ENDIF
            GOSUB rx_reset; // rx reset
          endif
          'Check for button press
          if nButton = 0 then 'the button is pressed...
            'SEROUT2 PORTA.3,49236,["Xmitting",13,10]
            'Here would be a good place to load the relevant data into anTxBuf
            gosub To_TX_Mode
            'and return back to RX_Mode
            GOSUB To_RX_Mode
          endif
        GOTO MainLoop
}


Pri RFM_INIT



    nAddress := $06  ' 0000110
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' Disable Interrupts

    nAddress := $07  ' 0000111
    nOutData := $01  ' 00000001
    SPI_OUT(nAddress, nOutData)                     ' Set READY Mode

    nAddress := $09  ' 0001001
    nOutData := $7F  ' 01111111
    SPI_OUT(nAddress, nOutData)                     ' Cap = 12.5 pF

    nAddress := $0A  ' 0001010
    nOutData := $05  ' 00000101
    SPI_OUT(nAddress, nOutData)                     ' Clk output is 2 MHz


    ' // *** May need changed or updated:
    
    nAddress := $0B  ' 0001011
    nOutData := $F4  ' 11110100
    SPI_OUT(nAddress, nOutData)                     ' GPIO0 is RX Data Output        

    nAddress := $0C  ' 0001100
    nOutData := $EF  ' 11101111
    SPI_OUT(nAddress, nOutData)                     ' GPIO1 Tx/Rx Data CLK Output

    nAddress := $0D  ' 0001101
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' GPIO2 for MCLK Output

    nAddress := $0E  ' 0001110
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' GPIO Port use Default Value         


    nAddress := $0F  ' 0001111
    nOutData := $70  ' 01110000
    SPI_OUT(nAddress, nOutData)                     ' No ADC Used         

    nAddress := $10  ' 0010000
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' No ADC Used

    nAddress := $12  ' 0010010
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' No Temp Sensor Used

    nAddress := $13  ' 0010011
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' No Temp Sensor Used

    nAddress := $1D  ' 0011101
    nOutData := $40  ' 01000000
    SPI_OUT(nAddress, nOutData)                     ' AFC Loop 

{        
    GFSK/FSK RX Modem Settings (100 kbps, 50 khz Fd, AFC Enabled):
    $1C, $88
    $20, $3C
    $21, $01
    $22, $11
    $23, $11
    $24, $07
    $25, $FF
    $1D, $40
    $1E, $02
    $2A, $50
    $1F, $03
    $69, $60
     
    OOK RX Modem Settings (100 kbps, 200 khz bw):
    $1C, $81
    $20, $3C
    $21, $01
    $22, $11
    $23, $11
    $24, $02
    $25, $24
    $2C, $18
    $2D, $06
    $2E, $27
    $1F, $03
    $69, $60
}

    nAddress := $1C  ' 0011100
    nOutData := $88
    SPI_OUT(nAddress, nOutData)                     ' IF Filter Bandwidth 

    nAddress := $20  ' 0100000
    nOutData := $3C
    SPI_OUT(nAddress, nOutData)                     ' Clock recovery

    nAddress := $21  ' 0100001
    nOutData := $01
    SPI_OUT(nAddress, nOutData)                     ' Clock recovery
 
    nAddress := $22  ' 0100010
    nOutData := $11
    SPI_OUT(nAddress, nOutData)                     ' Clock recovery

    nAddress := $23  ' 0100011
    nOutData := $11
    SPI_OUT(nAddress, nOutData)                     ' Clock recovery             

    nAddress := $24  ' 0100100
    nOutData := $07
    SPI_OUT(nAddress, nOutData)                     ' Clock recovery Timing

    nAddress := $25  ' 0100101
    nOutData := $FF
    SPI_OUT(nAddress, nOutData)                     ' Clock recovery Timing

    nAddress := $2C  ' 0101100
    nOutData := $40
    SPI_OUT(nAddress, nOutData)                     ' Zero OOK Counter

    nAddress := $2D  ' 0101101
    nOutData := $02
    SPI_OUT(nAddress, nOutData)                     ' Zero OOK Counter        

    nAddress := $2E  ' 0101110
    nOutData := $50
    SPI_OUT(nAddress, nOutData)                     ' Slicer Peak Hold

    nAddress := $1F  ' 0011111
    nOutData := $03  ' 00000011
    SPI_OUT(nAddress, nOutData)                     ' Clock recovery Gearshift Override

    nAddress := $69
    nOutData := $60
    SPI_OUT(nAddress, nOutData)                     ' 
            
    
    nAddress := $30  ' 0110000
    nOutData := $8C  ' 10001100
    SPI_OUT(nAddress, nOutData)                     ' Data Access Control

    nAddress := $32  ' 0110010
    nOutData := $FF  ' 11111111
    SPI_OUT(nAddress, nOutData)                     ' Header Control

    nAddress := $33  ' 0110011
    nOutData := $42  ' 01000010
    SPI_OUT(nAddress, nOutData)                     ' Header 3, 2, 1,0 used for head length, fixed packet length, synchronize word length 3, 2

    nAddress := $34  ' 0110100
    nOutData := 64   ' Bin = 01000000 = Decimal 64 = $40                      *** Update 
    SPI_OUT(nAddress, nOutData)                     ' 64 nibble = 32 Byte Preamble

    nAddress := $35  ' 0110101
    nOutData := $20  ' 00100000
    SPI_OUT(nAddress, nOutData)                     ' 0x35 Need to Detect 20 Bit Preamble

    nAddress := $36  ' 0110110
    nOutData := $2D  ' 00101101
    SPI_OUT(nAddress, nOutData)                     ' Synchronize Word

    nAddress := $37  ' 0110111
    nOutData := $D4  ' 11010100
    SPI_OUT(nAddress, nOutData)                     ' Synchronize Word    

    nAddress := $38  ' 0111000
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' Synchronize Word    

    nAddress := $39  ' 0111001
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' Synchronize Word

    nAddress := $3A  ' 0111010
    nOutData := "h"  ' 01101000
    SPI_OUT(nAddress, nOutData)                     ' Set Tx Header

    nAddress := $3B  ' 0111011
    nOutData := "o"  ' 01101111
    SPI_OUT(nAddress, nOutData)                     ' Set Tx Header

    nAddress := $3C  ' 0111100
    nOutData := "p"  ' 01110000
    SPI_OUT(nAddress, nOutData)                     ' Set Tx Header

    nAddress := $3D  ' 0111101
    nOutData := "e"  ' 01100101
    SPI_OUT(nAddress, nOutData)                     ' Set Tx Header

    nAddress := $3E  ' 0111110
    nOutData := $40  ' PacketSize  ' 01000000 = 64 = $40
    SPI_OUT(nAddress, nOutData)                     ' Total TX 17 Byte

    nAddress := $3F  ' 0111111
    nOutData := "h"  ' 01101000
    SPI_OUT(nAddress, nOutData)                     ' Set RX Header

    nAddress := $40  ' 1000000
    nOutData := "o"  ' 01101111
    SPI_OUT(nAddress, nOutData)                     ' Set RX Header

    nAddress := $41  ' 1000001
    nOutData := "p"  ' 01110000
    SPI_OUT(nAddress, nOutData)                     ' Set RX Header

    nAddress := $42  ' 1000010
    nOutData := "e"  ' 01100101
    SPI_OUT(nAddress, nOutData)                     ' Set RX Header

    nAddress := $43  ' 1000011
    nOutData := $FF  ' 11111111
    SPI_OUT(nAddress, nOutData)                     ' All The Bits to be Checked

    nAddress := $44  ' 1000100
    nOutData := $FF  ' 11111111
    SPI_OUT(nAddress, nOutData)                     ' All The Bits to be Checked

    nAddress := $45  ' 1000101
    nOutData := $FF  ' 11111111
    SPI_OUT(nAddress, nOutData)                     ' All The Bits to be Checked

    nAddress := $46  ' 1000110
    nOutData := $FF  ' 11111111
    SPI_OUT(nAddress, nOutData)                     ' All The Bits to be Checked

    nAddress := $56  ' 1010110
    nOutData := $01  ' 00000001
    SPI_OUT(nAddress, nOutData)                     ' Reserved

    {
    TX Power Setting ()
    111 = Max
    000 = Min
    }
    
    nAddress := $6D  ' 1101101
    nOutData := $01  '$07  ' 00000111
    SPI_OUT(nAddress, nOutData)                     ' TX Power to Near Min ($01) 'Max

    {
    TX Data Rate Settings (100 kbps):
    $6E, $19
    $6F, $9A
    $70, $0E
    $58, $ED
    }

    nAddress := $6E  ' 1101110
    nOutData := $19
    SPI_OUT(nAddress, nOutData)                     ' TX Data Rate (100k Baud)

    nAddress := $6F  ' 1101111
    nOutData := $9A
    SPI_OUT(nAddress, nOutData)                     ' TX Data Rate (100k Baud)

    nAddress := $70  ' 1110000
    nOutData := $0E
    SPI_OUT(nAddress, nOutData)                     ' Manchester ON

    nAddress := $58  ' 1011000
    nOutData := $ED
    SPI_OUT(nAddress, nOutData)                     ' Reserved

                            
    nAddress := $79  ' 1111001
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' No Frequency Hopping
    
    nAddress := $7A  ' 1111010
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' No Frequency Hopping

    {
    TX Frequency Deviation Settings (50 khz):
    $72, $50
    $71, $23
    }

    nAddress := $71  ' 1110001
    nOutData := $23  '$23
    SPI_OUT(nAddress, nOutData)                     ' Changed 'Gfsk, fd[8] = 0, No Invert for Tx/Rx Data, FIFO Mode, TxCLK --> GPIO

    nAddress := $72  ' 1110010
    nOutData := $50  '$50
    SPI_OUT(nAddress, nOutData)                     ' Frequency Deviation Setting to 50khz '35k = 56*625

    
    nAddress := $73  ' 1110011
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' No Frequency Offset
 
    nAddress := $74  ' 1110100
    nOutData := $00  ' 00000000
    SPI_OUT(nAddress, nOutData)                     ' No Frequency Offset    

    {
    RX/TX Carrier Freq Settings (900Mhz Center, 937.5khz IF):
    $75, $75
    $76, $00
    $77, $00
    }
    
    nAddress := $75  ' 1110101
    nOutData := $75 
    SPI_OUT(nAddress, nOutData)                     ' Frequency Set to 900 Mhz '434 MHz

    nAddress := $76  ' 1110110
    nOutData := $00 
    SPI_OUT(nAddress, nOutData)                     ' Frequency Set to 900 Mhz '434 MHz

    nAddress := $77  ' 1110111
    nOutData := $00 
    SPI_OUT(nAddress, nOutData)                     ' Frequency Set to 900 Mhz '434 MHz

      
    'NOTE:
    'The following 5 registers are listed as RESERVED in the RFM22B v1.1  *** (Using RFM23BP)
    'datasheet.  Try remming them if problems are experienced

    nAddress := $5A  ' 1011010
    nOutData := $7F  ' 01111111
    SPI_OUT(nAddress, nOutData)                     ' Reserved

    nAddress := $59  ' 1011001
    nOutData := $40  ' 01000000
    SPI_OUT(nAddress, nOutData)                     ' Reserved
 
    nAddress := $6A  ' 1101010
    nOutData := $0B  ' 00001011
    SPI_OUT(nAddress, nOutData)                     ' Reserved

    nAddress := $68  ' 1101000
    nOutData := $04  ' 00000100
    SPI_OUT(nAddress, nOutData)                     ' Reserved

     
           
{
        'Initial configuration of RFM22 Registers
        InitRFM:
          'Disable Interrupts
          nAddress = $06 : noutData = $00 : GOSUB SPI_Out
          'Set READY mode
          nAddress = $07 : nOutData = $01    : GOSUB SPI_Out
          'cap = 12.5 pF
          nAddress = $09 : nOutData = $7F : GOSUB SPI_Out
          'Clk output is 2 MHz
          nAddress = $0A : nOutData = $05 : GOSUB SPI_Out
          'GPIO0 is RX data output
          nAddress = $0B : nOutData = $F4    : GOSUB SPI_Out
          'GPIO1 Tx/Rx data clk output
          nAddress = $0C : nOutData = $EF    : GOSUB SPI_Out
          'GPIO2 for MCLK output
          nAddress = $0D : nOutData = $00 : GOSUB SPI_Out
          'GPIO port use default value
          nAddress = $0E : nOutData = $00 : GOSUB SPI_Out
          'no ADC used
          nAddress = $0F : nOutData = $70 : GOSUB SPI_Out
          nAddress = $10 : nOutData = $00 : GOSUB SPI_Out
          'no temp sensor used
          nAddress = $12 : nOutData = $00 : GOSUB SPI_Out
          nAddress = $13 : nOutData = $00 : GOSUB SPI_Out
          'no manchester code, no data whiting, data rate < 30Kbps
          nAddress = $70 : nOutData = $20 : GOSUB SPI_Out
          'IF filter bandwidth
          nAddress = $1C : nOutData = $1D : GOSUB SPI_Out
          'AFC loop
          nAddress = $1D : nOutData = $40 : GOSUB SPI_Out
          'Clock Recovery
          nAddress = $20 : nOutData = $A1    : GOSUB SPI_Out
          nAddress = $21 : nOutData = $20    : GOSUB SPI_Out
          nAddress = $22 : nOutData = $4E    : GOSUB SPI_Out
          nAddress = $23 : nOutData = $A5    : GOSUB SPI_Out
           'Clock Recovery timing
          nAddress = $24 : nOutData = $00    : GOSUB SPI_Out
          nAddress = $25 : nOutData = $0A    : GOSUB SPI_Out
          'zero OOK counter
          nAddress = $2C : nOutData = $00 : GOSUB SPI_Out
          nAddress = $2D : nOutData = $00 : GOSUB SPI_Out
          'slicer peak hold
          nAddress = $2E : nOutData = $00 : GOSUB SPI_Out
          'TX data rate (4800 baud)
          nAddress = $6E : nOutData = $27 : GOSUB SPI_Out
          nAddress = $6F : nOutData = $52    : GOSUB SPI_Out
          'Data Access Control
          nAddress = $30 : nOutData = $8C : GOSUB SPI_Out
          'Header Control
          nAddress = $32 : nOutData = $FF : GOSUB SPI_Out
          ' header 3, 2, 1,0 used for head length, fixed packet length, synchronize word length 3, 2,
          nAddress = $33 : nOutData = $42 : GOSUB SPI_Out
          '64 nibble = 32byte preamble
          nAddress = $34 : nOutData = 64 : GOSUB SPI_Out
          '0x35 need to detect 20bit preamble
          nAddress = $35 : nOutData = $20 : GOSUB SPI_Out
          ' synchronize word
          nAddress = $36 : nOutData = $2D : GOSUB SPI_Out
          nAddress = $37 : nOutData = $D4 : GOSUB SPI_Out
          nAddress = $38 : nOutData = $00 : GOSUB SPI_Out
          nAddress = $39 : nOutData = $00 : GOSUB SPI_Out
          ' set tx header
          nAddress = $3A : nOutData = "h" : GOSUB SPI_Out
          nAddress = $3B : nOutData = "o" : GOSUB SPI_Out
          nAddress = $3C : nOutData = "p" : GOSUB SPI_Out
          nAddress = $3D : nOutData = "e" : GOSUB SPI_Out
          ' total tx 17 byte
          nAddress = $3E : nOutData = PacketSize : GOSUB SPI_Out                    
          ' set rx header
          nAddress = $3F : nOutData = "h" : GOSUB SPI_Out
          nAddress = $40 : nOutData = "o" : GOSUB SPI_Out
          nAddress = $41 : nOutData = "p" : GOSUB SPI_Out
          nAddress = $42 : nOutData = "e" : GOSUB SPI_Out
          ' all the bits to be checked
          nAddress = $43 : nOutData = $FF : GOSUB SPI_Out
          nAddress = $44 : nOutData = $FF : GOSUB SPI_Out
          nAddress = $45 : nOutData = $FF : GOSUB SPI_Out
          nAddress = $46 : nOutData = $FF : GOSUB SPI_Out
          'Reserved
          nAddress = $56 : nOutData = $01 : GOSUB SPI_Out
          ' tx power to Max
          nAddress = $6D : nOutData = $07    : GOSUB SPI_Out
          ' no frequency hopping
          nAddress = $79 : nOutData = $00 : GOSUB SPI_Out
          nAddress = $7A : nOutData = $00 : GOSUB SPI_Out
          ' Gfsk, fd[8] =0, no invert for Tx/Rx data, fifo mode, txclk -->gpio
          nAddress = $71 : nOutData = $22    : GOSUB SPI_Out
          ' frequency deviation setting to 35k = 56*625
          nAddress = $72 : nOutData = $38    : GOSUB SPI_Out
          ' no frequency offset
          nAddress = $73 : nOutData = $00 : GOSUB SPI_Out
          nAddress = $74 : nOutData = $00 : GOSUB SPI_Out
          ' frequency set to 434MHz
          nAddress = $75 : nOutData = $53    : GOSUB SPI_Out
          nAddress = $76 : nOutData = $64    : GOSUB SPI_Out
          nAddress = $77 : nOutData = $00    : GOSUB SPI_Out
          'NOTE:
          'The following 5 registers are listed as RESERVED in the RFM22B v1.1
          'datasheet.  Try remming them if problems are experienced
          nAddress = $5A : nOutData = $7F : GOSUB SPI_Out
          nAddress = $59 : nOutData = $40 : GOSUB SPI_Out
          nAddress = $58 : nOutData = $80 : GOSUB SPI_Out
          nAddress = $6A : nOutData = $0B : GOSUB SPI_Out
          nAddress = $68 : nOutData = $04 : GOSUB SPI_Out
         
         
          'Clock Recovery Gearshift Override
          nAddress = $1F : nOutData = $03 : GOSUB SPI_Out
          PAUSEUS 1000 'Let the settings settle
        return
}

    
Pri RX_Reset

  nAddress := $07
  nOutData := $01
  SPI_OUT(nAddress, nOutData)     ' Set READY Mode (Xtal is ON)

  nAddress := $7E
  nOutData := PacketSize
  SPI_OUT(nAddress, nOutData)     ' Set the RX FIFO Almost Full interrupt level to 17 (same as the packet size)

  nAddress := $08
  nOutData := $03
  SPI_OUT(nAddress, nOutData)     ' Clear the RX FIFO and disable multi-packet
   
  nAddress := $07
  nOutData := $05
  SPI_OUT(nAddress, nOutData)     ' READY mode set, RX on in Manual Receiver Mode 

  nAddress := $06
  nOutData := 000000
  SPI_OUT(nAddress, nOutData)     ' Disable Extra / Oddball Interrupts 

  nAddress := $05
  nOutData := $02
  SPI_OUT(nAddress, nOutData)     ' Valid Packet Received interrupt is enabled

'    nAddress := $85 ' 05  ' 0000101
'    nOutData := $06  ' 00000110                           
'    SPI_OUT(nAddress, nOutData)  ' Packet Sent & Valid Packet Recieved  Interrupts Enabled

  nStatus1 := SPI_IN($83) ' 03       ' R, $03   ' Read the Interrupt Registers (in order to clear them)  
  nStatus2 := SPI_IN($84) ' 04       ' R, $04   ' Read the Interrupt Registers (in order to clear them)

  
{
        'Configure RFM22 registers for reception
        RX_Reset:
          'Set READY Mode (Xtal is ON)
          nAddress = $07 : noutData = $01 : GOSUB SPI_Out
          'Set the RX FIFO Almost Full interrupt level to 17 (same as the packet size)
          nAddress = $7E : noutData = PacketSize : GOSUB SPI_Out
          'Clear the RX FIFO and disable multi-packet
          nAddress = $08 : noutData = $03 : GOSUB SPI_Out
          'Second write to complete clearing FIFO buffers    
          nAddress = $08 : noutData = $00 : GOSUB SPI_Out
          'READY mode set, RX on in Manual Receiver Mode
          nAddress = $07 : noutData = $05 : GOSUB SPI_Out
          'Disable extra/oddball interrupts
          nAddress = $06 : noutData = 000000 : GOSUB SPI_Out    
          'Valid Packet Received interrupt is enabled
          nAddress = $05 : noutData = $02 : GOSUB SPI_Out
          'Read the interrupt registers (in order to clear them)
          nAddress = $03 : GOSUB SPI_In : nStatus1 = nInData
          nAddress = $04 : GOSUB SPI_In : nStatus2 = nInData
        RETURN
}
    
Pri To_RX_Mode

    ser.str(string("Entering RX Mode..."))
    ser.tx (13)

    ' *** To turn TX/RX_ANT On or Off, use register 0E:
    ' 0E, %10000011  = on   (Direct I/O over GPIO)
    ' 0E, %10000000  = off  (Direct I/O over GPIO)
    
    SPI_OUT($0E, $00)           ' Turn Off Rx & Tx (GPIO0 Off, GPIO1 Off) 

    RX_ANT := 0                 ' Turn Off Reciever
    TX_ANT := 0                 ' Turn Off Transmitter

    nStatus1 := SPI_IN($03)            ' R, $03   ' Read the Interrupt Registers (in order to clear them)  
    nStatus2 := SPI_IN($04)            ' R, $04   ' Read the Interrupt Registers (in order to clear them)  

    nAddress := $07
    nOutData := $01
    SPI_OUT(nAddress, nOutData) ' Set READY Mode in RFM22    

    Pause(50)

    SPI_OUT($0E, $02)           ' Turn On Rx & Turn Off Tx (GPIO0 Off, GPIO1 On)
    
    RX_ANT := 1                 ' Configure for Reception
    TX_ANT := 0                 ' Configure for reception

    Pause(50)

    RX_Reset                    ' Configure RFM22 Registers for Reception

    'PAUSEUS(10)

    
{
        'Set up RFM22 hardware to receive mode
        To_RX_Mode:
          'SEROUT2 PORTA.3,49236,["Entering RX Mode...",13,10]
          RX_ANT = 0 'Turn off receiver
          TX_ANT = 0 'Turn off transmitter
          nAddress = $03 : GOSUB SPI_In : nStatus1 = nInData 'Clear interrupts part 1
          nAddress = $04 : GOSUB SPI_In : nStatus2 = nInData 'Clear interrupts part 2
          nAddress = $07 : noutData = $01 : GOSUB SPI_Out    'Set READY mode in RFM22
          pause 50    'Give it a moment
          RX_ANT = 1  'Configure for reception
          TX_ANT = 0  'Configure for reception
          pause 50    'Give it a moment
          GOSUB RX_Reset  'Configure RFM22 registers for reception
          PAUSEUS 10   'Give it a moment
        RETURN
}
 
Pri To_TX_Mode | i, Value', nCheckSum

    ser.str(string("Entering TX Mode..."))
    ser.tx (13)

    nAddress := $87   ' 07
    nOutData := $01
    SPI_OUT(nAddress, nOutData)  ' Set READY Mode (Xtal is ON)

    SPI_OUT($8E, $01) ' 0E             ' Turn Off Rx & Turn On Tx (GPIO0 On, GPIO1 Off)
    
    RX_ANT := 0                   ' Configure for Transmission
    TX_ANT := 1                   ' Configure for Transmission

    Pause(50)                     ' Give it a moment

    nAddress := $08
    nOutData := $03
    SPI_OUT(nAddress, nOutData)  ' Tell it we want to reset the FIFO       
        
    nAddress := $08
    nOutData := $00
    SPI_OUT(nAddress, nOutData)  ' Reset the FIFO

    nAddress := $34
    nOutData := 64    
    SPI_OUT(nAddress, nOutData)  ' Set the Preamble = 64 nibble

    nAddress := $3E
    nOutData := PacketSize
    SPI_OUT(nAddress, nOutData)  ' Set the Packet Length

    nCheckSum := 0
    
    repeat i from 0 to PacketSize - 2
      nAddress := $7F
      nOutData := anTXBuf[i]
      SPI_OUT(nAddress, nOUtData)         ' Write the Data to the TX FIFO  

      nCheckSum := nCheckSum + anTXBuf[i]  ' Calculate the Checksum
    
    nAddress := $7F
    nOutData := nCheckSum
    SPI_OUT(nAddress, nOutData)  ' Write the Checksum as the Last Byte
    
    nAddress := $34
    nOutData := 64    
    SPI_OUT(nAddress, nOutData)  ' Set the Preamble = 64 nibble

    nAddress := $05
    nOutData := $04
    SPI_OUT(nAddress, nOutData)  ' Enable the Packet Sent Interrupt

    nStatus1 := SPI_IN($03)            ' R, $03   ' Read the Interrupt Registers (in order to clear them)  
    nStatus2 := SPI_IN($04)            ' R, $04   ' Read the Interrupt Registers (in order to clear them)  

    LED := 1                    ' Turn on LED Immediatly Prior to Start of Transmission

    nAddress := $07
    nOutData := $09 ' 9
    SPI_OUT(nAddress, nOutData)  ' Tell the RFM to Start the Transmission

    ' Wait for the Interrupt to tell us the Transmission is Complete

    repeat while nIRQ == 1      ' *** Getting Stuck Here Again
      nIRQ := ina[RFM_IRQ]
    
    Pause(50)                   ' This pause exists only to make the LED blink long enough to see
    LED := 0                    ' Tturn Off the LED
           
{
        'Send the data contained in the anTXBuf array
        To_TX_Mode:
          'SEROUT2 PORTA.3,49236,["Entering RX Mode...",13,10]
          NAddress = $07 : noutData = $01 : GOSUB SPI_Out  'Set READY mode in RFM22
          RX_ANT = 0 'Configure for transmission
          TX_ANT = 1 'Configure for transmission
          Pause 50   'Give it a moment
          nAddress = $08 : noutData = $03 : GOSUB SPI_Out   'Tell it we want to reset the FIFO
          nAddress = $08 : noutData = $00 : GOSUB SPI_Out   'Reset the FIFO
          nAddress = $34 : noutData = 64 : GOSUB SPI_Out    'Set the preamble = 64nibble
          nAddress = $3E : noutData = PacketSize : GOSUB SPI_Out     'Set the packet length
          nCheckSum = 0
          for i = 0 to PacketSize-2
            nAddress = $7F : noutData = anTXBuf[i] : GOSUB SPI_Out    'Write the data to the TX FIFO
            nCheckSum = nChecksum + antxbuf[i]                        'Calculate the checksum
          next i
          nAddress = $7F : noutData = nCheckSum : GOSUB SPI_Out       'Write the checksum as the last byte
          nAddress = $05 : noutData = $04 : GOSUB SPI_Out             'Enable the packet sent interrupt
          nAddress = $03 : GOSUB SPI_In : nStatus1 = nInData   'Clear interrupts part 1
          nAddress = $04 : GOSUB SPI_In : nStatus2 = nInData   'Clear interrupts part 2
          LED = 1  'Turn on LED immediatly prior to start of transmission
          nAddress = $07 : noutData = 9 : GOSUB SPI_Out  'Tell the RFM22 to start the transmission
          'wait for the interrupt to tell us the transmission is complete
          TXWait:
          if nirq = 1 then
              goto TXWait
          endif
          pause 100  'This pause exists only to make the LED blink long enough to see
          LED = 0    'turn off the LED
        RETURN
}


Pri Pause(ms) | t
  t := cnt - 1088
  repeat ms
    waitcnt(t += MS_001)

Pri SPI_IN(mAddr) : Data_IN

    outa[RFM_SEL]~              ' Pull nSel LOW
    pause(50)                   ' Give it a moment
    SHIFTOUT (RFM_SDI, RFM_SCK, mAddr, MSBFIRST, 8)    ' SHIFTOUT Address MSB First (8 Bits)
    Data_IN := SHIFTIN (RFM_SDO, RFM_SCK, MSBPRE, 8) ' SHIFTIN  Data_IN MSB First (8 Bits)
    outa[RFM_SEL]~~             ' Pull nSel HIGH
    'pause(100)                  ' Unnecessary?

    return Data_IN

Pri SPI_OUT(mAddr, mData)

    outa[RFM_SEL]~              ' Pull nSel LOW
    pause(50)                   ' Give it a moment
    mAddr := mAddr + $80        ' Set Write Bit *** Important!!!
    SHIFTOUT (RFM_SDI, RFM_SCK, mAddr, MSBFIRST, 8)    ' SHIFTOUT mVal MSB First (8 Bits)
    SHIFTOUT (RFM_SDI, RFM_SCK, mData, MSBFIRST, 8)    ' SHIFTOUT mVal MSB First (8 Bits)    
    outa[RFM_SEL]~~             ' Pull nSel HIGH
    'pause(100)                  ' Unnecessary?    

  
Pri SHIFTOUT (Dpin, Cpin, Value, Mode, Bits)| bitNum
  outa[Dpin]:=0                                            ' Data pin = 0
  dira[Dpin]~~                                             ' Set data as output
  outa[Cpin]:=0
  dira[Cpin]~~

  If Mode == LSBFIRST                                      ' Send LSB first    
     REPEAT Bits
        outa[Dpin] := Value                                ' Set output
        Value := Value >> 1                                ' Shift value right
        !outa[Cpin]                                        ' cycle clock
        !outa[Cpin]
        waitcnt(1000 + cnt)                                ' delay

  elseIf Mode == MSBFIRST                                  ' Send MSB first               
     REPEAT Bits                                                                
        outa[Dpin] := Value >> (bits-1)                    ' Set output           
        Value := Value << 1                                ' Shift value right
        !outa[Cpin]                                        ' cycle clock          
        !outa[Cpin]                                                             
        waitcnt(1000 + cnt)                                ' delay                
  outa[Dpin]~                                              ' Set data to low
 
    
Pri SHIFTIN (Dpin, Cpin, Mode, Bits) : Value | InBit
    dira[Dpin]~                                            ' Set data pin to input
    outa[Cpin]:=0                                          ' Set clock low 
    dira[Cpin]~~                                           ' Set clock pin to output 
                                                
    If Mode == MSBPRE                                      ' Mode - MSB, before clock
       Value:=0
       REPEAT Bits                                         ' for number of bits
          InBit:= ina[Dpin]                                ' get bit value
          Value := (Value << 1) + InBit                    ' Add to  value shifted by position
          !outa[Cpin]                                      ' cycle clock
          !outa[Cpin]
          waitcnt(1000 + cnt)                              ' time delay

    elseif Mode == MSBPOST                                 ' Mode - MSB, after clock              
       Value:=0                                                          
       REPEAT Bits                                         ' for number of bits                    
          !outa[Cpin]                                      ' cycle clock                         
          !outa[Cpin]                                         
          InBit:= ina[Dpin]                                ' get bit value                          
          Value := (Value << 1) + InBit                    ' Add to  value shifted by position                                         
          waitcnt(1000 + cnt)                              ' time delay                            
                                                                 
    elseif Mode == LSBPOST                                 ' Mode - LSB, after clock                    
       Value:=0                                                                                         
       REPEAT Bits                                         ' for number of bits                         
          !outa[Cpin]                                      ' cycle clock                          
          !outa[Cpin]                                                                             
          InBit:= ina[Dpin]                                ' get bit value                        
          Value := (InBit << (bits-1)) + (Value >> 1)      ' Add to  value shifted by position    
          waitcnt(1000 + cnt)                              ' time delay                           

    elseif Mode == LSBPRE                                  ' Mode - LSB, before clock             
       Value:=0                                                                                   
       REPEAT Bits                                         ' for number of bits                   
          InBit:= ina[Dpin]                                ' get bit value                        
          Value := (Value >> 1) + (InBit << (bits-1))      ' Add to  value shifted by position    
          !outa[Cpin]                                      ' cycle clock                          
          !outa[Cpin]                                                                             
          waitcnt(1000 + cnt)                              ' time delay

    elseif Mode == OnClock                                            
       Value:=0
       REPEAT Bits                                         ' for number of bits
                                        
          !outa[Cpin]                                      ' cycle clock
          waitcnt(500 + cnt)                               ' get bit value
          InBit:= ina[Dpin]                                ' time delay
          Value := (Value << 1) + InBit                    ' Add to  value shifted by position
          !outa[Cpin]
          waitcnt(500 + cnt)                           

           
Dat    ' // Ported RFM28BP Data
{
  ' // 64 byte Preamble Data?
  byte RFM23BData[21] = ["H", "o", "p", "e", "R", "F", " ", "R", "F", "M", " ", "C", "O", "B", "R", "F", "M", "2", "3", "B", "S"]                          
  byte RFM22BData[21] = ["H", "o", "p", "e", "R", "F", " ", "R", "F", "M", " ", "C", "O", "B", "R", "F", "M", "2", "2", "B", "S"] 
  byte RFM43BData[21] = ["H", "o", "p", "e", "R", "F", " ", "R", "F", "M", " ", "C", "O", "B", "R", "F", "M", "4", "3", "B", "S"] 
  byte RFM42BData[21] = ["H", "o", "p", "e", "R", "F", " ", "R", "F", "M", " ", "C", "O", "B", "R", "F", "M", "4", "2", "B", "S"] 

  
  word RF2xFreqTbl[5][3] = [$7547, $767D, $7700,        ' //0
                            $7547, $767D, $7700,        ' //315MHz
                            $7553, $7664, $7700,        ' //434MHz
                            $7573, $7664, $7700,        ' //868MHz        
                            $7575, $76BB, $7780]        ' //915MHz


  word RF2xConfigTbl[35] = [$0506,
                            $0600,
                            $0803,            '     //software reset FIFO
                            $0800, 
                            $097F,            ' // $09    config crystal carry cap value
                            $0BD2,            ' // $0B    GPIO0 Txen
                            $0C14,            ' // $0C    GPIO1   RfData  RF Input
                            $0DD5,            ' // $0D    GPIO2 Rxen 

                            $1C1B,            ' //Rx para. 2.4Kbps +/-35KHz
                            $2041,
                            $2160,
                            $2227,
                            $2352,
                            $2400,
                            $2507,
                            $1E0A,
                            $2A1E,
                            $1F03,
                            $6960,
                                              '     //Packet Setting
                            $3088,            ' // $30    config the data package function,NoCRC
                            $3200,            ' // $32    No Header check
                            $330C,            ' // $33    Sync 3Byte£ No Header
                            $340A,            ' // $34    5Byte Preamble
                            $3600+$AA,        ' // $36    SyncWord = AA2DD4               
                            $3700+$2D,        ' // $37
                            $3800+$D4,        ' // $38
                            $3E00+$15,        ' // $3E    PK Length 21Byte
        
                            $5880,            ' // $58
                            $6D0F,            ' // $5D    Max Power 
                            $6E13,            ' // $6E    2.4Kbps Tx
                            $6FA9,

                            $7024,            ' // $70    disable mancester encode
                            $7122,            ' // $71    FIFO FSK
                            $7238,            ' // $72    +/-35KHz
                            $0701]            ' // $07    Standby Mode

}

Dat     ' // RFM28BP Datasheed Info
{
              Device Status
        Add  R/W  Function/Description  D7      D6      D5      D4       D3       D2      D1      D0      POR Def.
        02   R    Device Status         ffovfl  ffunfl  rxffem  headerr  freqerr  ---     cps[1]  cps[0] —---
         
              Interrupts
        Add  R/W  Function/Description  D7       D6           D5           D4           D3     D2        D1         D0          POR Def.
        03   R    Interrupt Status 1    ifferr   itxffafull   itxffaem     irxffafull   iext   ipksent   ipkvalid   icrcerror — ---
        04   R    Interrupt Status 2    iswdet   ipreaval     ipreainval   irssi        iwut   ilbd      ichiprdy   ipor —      ---
        05   R/W  Interrupt Enable 1    enfferr  entxffafull  entxffaem    enrxffafull  enext  enpksent  enpkvalid  encrcerror  00h
        06   R/W  Interrupt Enable 2    enswdet  enpreaval    enpreainval  enrssi       enwut  enlbd     enchiprdy  enpor       01h


              Frequency Programming
        Add  R/W  Function/Description         D7     D6     D5     D4     D3     D2     D1     D0     POR Def.
        73   R/W  Frequency Offset 1           fo[7]  fo[6]  fo[5]  fo[4]  fo[3]  fo[2]  fo[1]  fo[0]  00h
        74   R/W  Frequency Offset 2           ---    ---    ---    ---    ---    ---    fo[9]  fo[8]  00h
        75   R/W  Frequency Band Select        ---    sbsel  hbsel  fb[4]  fb[3]  fb[2]  fb[1]  fb[0]  35h
        76   R/W  Nominal Carrier Frequency 1  fc[15] fc[14] fc[13] fc[12] fc[11] fc[10] fc[9]  fc[8]  BBh
        77   R/W  Nominal Carrier Frequency 0  fc[7]  fc[6]  fc[5]  fc[4]  fc[3]  fc[2]  fc[1]  fc[0]  80h
         


        Table 12. Frequency Band Selection
        fb[4:0] Value N        Frequency Band
                 hbsel=0       hbsel=1
        0  24  240-249.9 MHz   480-499.9 MHz
        1  25  250-259.9 MHz   500-519.9 MHz
        2  26  260-269.9 MHz   520-539.9 MHz
        3  27  270-279.9 MHz   540-559.9 MHz
        4  28  280-289.9 MHz   560-579.9 MHz
        5  29  290-299.9 MHz   580-599.9 MHz
        6  30  300-309.9 MHz   600-619.9 MHz
        7  31  310-319.9 MHz   620-639.9 MHz
        8  32  320-329.9 MHz   640-659.9 MHz
        9  33  330-339.9 MHz   660-679.9 MHz
        10 34  340-349.9 MHz   680-699.9 MHz
        11 35  350-359.9 MHz   700-719.9 MHz
        12 36  360-369.9 MHz   720-739.9 MHz
        13 37  370-379.9 MHz   740-759.9 MHz
        14 38  380-389.9 MHz   760-779.9 MHz
        15 39  390-399.9 MHz   780-799.9 MHz
        16 40  400-409.9 MHz   800-819.9 MHz
        17 41  410-419.9 MHz   820-839.9 MHz
        18 42  420-429.9 MHz   840-859.9 MHz
        19 43  430-439.9 MHz   860-879.9 MHz
        20 44  440-449.9 MHz   880-899.9 MHz
        21 45  450-459.9 MHz   900-919.9 MHz
        22 46  460-469.9 MHz   920-939.9 MHz
        23 47  470-479.9 MHz   940-960 MHz


        
              Easy Frequency Programming for FHSS

        Fcarrier = Fnom + fhs[7 : 0]× ( fhch[7 : 0]×10kHz)

        For example, if the nominal frequency is set to 900 MHz using Registers 73h–77h, the channel step size is set to
        1 MHz using "Register 7Ah. Frequency Hopping Step Size," and "Register 79h. Frequency Hopping Channel
        Select" is set to 5d, the resulting carrier frequency would be 905 MHz. Once the nominal frequency and channel
        step size are programmed in the registers, it is only necessary to program the fhch[7:0] register in order to change
        the frequency.

        Add  R/W  Function/Description             D7       D6       D5       D4       D3       D2       D1       D0       POR Def.
        79   R/W Frequency Hopping Channel Select  fhch[7]  fhch[6]  fhch[5]  fhch[4]  fhch[3]  fhch[2]  fhch[1]  fhch[0]  00h
        7A   R/W Frequency Hopping Step Size       fhs[7]   fhs[6]   fhs[5]   fhs[4]   fhs[3]   fhs[2]   fhs[1]   fhs[0]   00h

        
         
              Frequency Deviation
        Add  R/W  Function/Description       D7        D6        D5        D4        D3     D2     D1         D0         POR Def.
        71   R/W  Modulation Mode Control 2  trclk[1]  trclk[0]  dtmod[1]  dtmod[0]  eninv  fd[8]  modtyp[1]  modtyp[0]  00h
        72   R/W  Frequency Deviation        fd[7]     fd[6]     fd[5]     fd[4]     fd[3]  fd[2]  fd[1]      fd[0]      20h

        

                        Frequency Offset Adjustment
        Add  R/W  Function/Description  D7     D6     D5     D4     D3     D2     D1     D0     POR Def.
        73   R/W  Frequency Offset      fo[7]  fo[6]  fo[5]  fo[4]  fo[3]  fo[2]  fo[1]  fo[0]  00h
        74   R/W  Frequency Offset                                                fo[9]  fo[8]  00h


        
              Automatic Frequency Control (AFC)
        
        AFC_pull_in_range = ±AFCLimiter[7:0] x (hbsel+1) x 625 Hz

        The AFC correction value may be read from register 2Bh. The value read can be converted to kHz with the
        following formula:

        AFC Correction = 156.25Hz x (hbsel +1) x afc_corr[7: 0]

                                  Frequency Correction
                       RX                     TX
        AFC disabled   Freq Offset Register   Freq Offset Register
        AFC enabled    AFC                    Freq Offset Register
         

              TX Data Rate Generator
        Add   R/W  Function/Description  D7        D6        D5        D4        D3        D2        D1       D0       POR Def.
        6E    R/W  TX Data Rate 1        txdr[15]  txdr[14]  txdr[13]  txdr[12]  txdr[11]  txdr[10]  txdr[9]  txdr[8]  0Ah
        6F    R/W  TX Data Rate 0        txdr[7]   txdr[6]   txdr[5]   txdr[4]   txdr[3]   txdr[2]   txdr[1]  txdr[0]  3Dh
                                                                                                    

        modtyp[1:0] Modulation Source
              00 -- Unmodulated Carrier
              01 -- OOK
              10 -- FSK
              11 -- GFSK (enable TX Data CLK when direct mode is used)
               

              Modulation Data Source
        Add  R/W  Function/Description       D7        D6        D5        D4        D3     D2     D1         D0         POR Def.
        71   R/W  Modulation Mode Control 2  trclk[1]  trclk[0]  dtmod[1]  dtmod[0]  eninv  fd[8]  modtyp[1]  modtyp[0]  00h
                      
              
        dtmod[1:0] Data Source
              00 - Direct Mode using TX/RX Data via GPIO pin (GPIO configuration required)
              01 - Direct Mode using TX/RX Data via SDI pin (only when nSEL is high)
              10 - FIFO Mode
              11 - PN9 (internally generated)
               

        trclk[1:0] TX/RX Data Clock Configuration
              00 - No TX Clock (only for FSK)
              01 - TX/RX Data Clock is available via GPIO (GPIO needs programming accordingly as well)
              10 - TX/RX Data Clock is available via SDO pin (only when nSEL is high)
              11 - TX/RX Data Clock is available via the nIRQ pin


              Output Power Selection
        Add  R/W  Function/Description  D7         D6        D5           D4           D3      D2        D1        D0        POR Def.
        6D   R/W  TX Power              papeakval  papeaken  papeaklv[1]  papeaklv[0]  lna_sw  txpow[2]  txpow[1]  txpow[0]  18h
              
        txpow[2:0] RFM23BP Output Power
              000  TBD
              001  TBD
              010  TBD
              011  TBD
              100  TBD
              101  +28dBm
              110  +29dBm
              111  +30dBm


              Crystal Oscillator     Cint = 1.8 pF + 0.085 pF x xlc[6:0] + 3.7 pF x xtalshift
        Add  R/W  Function/Description                 D7         D6      D5      D4      D3      D2      D1      D0      POR Def.
        09   R/W  Crystal Oscillator Load Capacitance  xtalshift  xlc[6]  xlc[5]  xlc[4]  xlc[3]  xlc[2]  xlc[1]  xlc[0]  7Fh              


              RX and TX FIFOs
        Add  R/W  Function/Description  D7         D6         D5          D4          D3          D2          D1          D0          POR Def.
        08   R/W  Operating &           antdiv[2]  antdiv[1]  antdiv[0]   rxmpk       autotx      enldm       ffclrrx     ffclrtx     00h
                  Function Control 2                                                              
        7C   R/W  TX FIFO Control 1     Reserved   Reserved   txafthr[5]  txafthr[4]  txafthr[3]  txafthr[2]  txafthr[1]  txafthr[0]  37h
        7D   R/W  TX FIFO Control 2     Reserved   Reserved   txaethr[5]  txaethr[4]  txaethr[3]  txaethr[2]  txaethr[1]  txaethr[0]  04h
         
        The RX FIFO has one programmable threshold called the FIFO Almost Full Threshold, rxafthr[5:0]. When the
        incoming RX data crosses the Almost Full Threshold an interrupt will be generated to the microcontroller via the
        nIRQ pin. The microcontroller will then need to read the data from the RX FIFO.

        Add  R/W  Function/Description  D7        D6        D5          D4          D3          D2          D1          D0          POR Def.
        7E   R/W  RX FIFO Control       Reserved  Reserved  rxafthr[5]  rxafthr[4]  rxafthr[3]  rxafthr[2]  rxafthr[1]  rxafthr[0]  37h
         
              

                                               Table 13. Packet Handler Registers
                                               
        Add  R/W   Function/Description    D7         D6         D5         D4         D3         D2          D1          D0          POR Def.
        30   R/W   Data Access Control     enpacrx    lsbfrst    crcdonly   skip2ph    enpactx    encrc       crc[1]      crc[0]      8Dh
        31   R     EzMAC                   status 0   rxcrc1     pksrch     pkrx       pkvalid    crcerror    pktx        pksent —    ---
        32   R/W   Header Control 1        [               bcen[3:0]               ]   [                 hdch[3:0]                 ]  0Ch                        
        33   R/W   Header Control 2        skipsyn    hdlen[2]   hdlen[1]   hdlen[0]   fixpklen   synclen[1]  synclen[0]  prealen[8]  22h
        34   R/W   Preamble Length         prealen[7] prealen[6] prealen[5] prealen[4] prealen[3] prealen[2]  prealen[1]  prealen[0]  08h
        35   R/W   Preamble Detect. Ctrl.  preath[4]  preath[3]  preath[2]  preath[1]  preath[0]  rssi_off[2] rssi_off[1] rssi_off[0] 2Ah
        36   R/W   Sync Word 3             sync[31]   sync[30]   sync[29]   sync[28]   sync[27]   sync[26]    sync[25]    sync[24]    2Dh
        37   R/W   Sync Word 2             sync[23]   sync[22]   sync[21]   sync[20]   sync[19]   sync[18]    sync[17]    sync[16]    D4h
        38   R/W   Sync Word 1             sync[15]   sync[14]   sync[13]   sync[12]   sync[11]   sync[10]    sync[9]     sync[8]     00h
        39   R/W   Sync Word 0             sync[7]    sync[6]    sync[5]    sync[4]    sync[3]    sync[2]     sync[1]     sync[0]     00h
        3A   R/W   Transmit Header 3       txhd[31]   txhd[30]   txhd[29]   txhd[28]   txhd[27]   txhd[26]    txhd[25]    txhd[24]    00h
        3B   R/W   Transmit Header 2       txhd[23]   txhd[22]   txhd[21]   txhd[20]   txhd[19]   txhd[18]    txhd[17]    txhd[16]    00h
        3C   R/W   Transmit Header 1       txhd[15]   txhd[14]   txhd[13]   txhd[12]   txhd[11]   txhd[10]    txhd[9]     txhd[8]     00h
        3D   R/W   Transmit Header 0       txhd[7]    txhd[6]    txhd[5]    txhd[4]    txhd[3]    txhd[2]     txhd[1]     txhd[0]     00h
        3E   R/W   Transmit Packet Length  pklen[7]   pklen[6]   pklen[5]   pklen[4]   pklen[3]   pklen[2]    pklen[1]    pklen[0]    00h
        3F   R/W   Check Header 3          chhd[31]   chhd[30]   chhd[29]   chhd[28]   chhd[27]   chhd[26]    chhd[25]    chhd[24]    00h
        40   R/W   Check Header 2          chhd[23]   chhd[22]   chhd[21]   chhd[20]   chhd[19]   chhd[18]    chhd[17]    chhd[16]    00h
        41   R/W   Check Header 1          chhd[15]   chhd[14]   chhd[13]   chhd[12]   chhd[11]   chhd[10]    chhd[9]     chhd[8]     00h
        42   R/W   Check Header 0          chhd[7]    chhd[6]    chhd[5]    chhd[4]    chhd[3]    chhd[2]     chhd[1]     chhd[0]     00h
        43   R/W   Header Enable 3         hden[31]   hden[30]   hden[29]   hden[28]   hden[27]   hden[26]    hden[25]    hden[24]    FFh
        44   R/W   Header Enable 2         hden[23]   hden[22]   hden[21]   hden[20]   hden[19]   hden[18]    hden[17]    hden[16]    FFh
        45   R/W   Header Enable 1         hden[15]   hden[14]   hden[13]   hden[12]   hden[11]   hden[10]    hden[9]     hden[8]     FFh
        46   R/W   Header Enable 0         hden[7]    hden[6]    hden[5]    hden[4]    hden[3]    hden[2]     hden[1]     hden[0]     FFh
        47   R     Received Header 3       rxhd[31]   rxhd[30]   rxhd[29]   rxhd[28]   rxhd[27]   rxhd[26]    rxhd[25]    rxhd[24] —  ---
        48   R     Received Header 2       rxhd[23]   rxhd[22]   rxhd[21]   rxhd[20]   rxhd[19]   rxhd[18]    rxhd[17]    rxhd[16] —  ---
        49   R     Received Header 1       rxhd[15]   rxhd[14]   rxhd[13]   rxhd[12]   rxhd[11]   rxhd[10]    rxhd[9]     rxhd[8] —   ---
        4A   R     Received Header 0       rxhd[7]    rxhd[6]    rxhd[5]    rxhd[4]    rxhd[3]    rxhd[2]     rxhd[1]     rxhd[0] —   ---
        4B   R     Received Packet Length  rxplen[7]  rxplen[6]  rxplen[5]  rxplen[4]  rxplen[3]  rxplen[2]   rxplen[1]   rxplen[0] — ---              



                       Table 14. Minimum Receiver Settling Time
              
             Mode           Approximate   Recommended Preamble   Recommended Preamble
                             Receiver      Length with 8-Bit      Length with 20-Bit
                           Settling Time  Detection Threshold    Detection  Threshold
                   
        (G)FSK AFC Disabled   1 byte           20 bits                 32 bits
        (G)FSK AFC Enabled    2 byte           28 bits                 40 bits
        (G)FSK AFC Disabled
             +Antenna
        Diversity Enabled     1 byte             ---                 — 64 bits
        (G)FSK AFC Enabled
             +Antenna
        Diversity Enabled     2 byte —           ---                    8 byte
        OOK                   2 byte            3 byte                  4 byte
        OOK + Antenna
        Diversity Enabled     8 byte —           ---                    8 byte



                                Microcontroller Clock

        Add  R/W   Function/Description           D7       D6      D5       D4       D3     D2       D1       D0       POR Def.
        0A   R/W   Microcontroller Output Clock                    clkt[1]  clkt[0]  enlfc  mclk[2]  mclk[1]  mclk[0]  06h
         
        mclk[2:0] Clock Frequency
              000 - 30 MHz
              001 - 15 MHz
              010 - 10 MHz
              011 - 4 MHz
              100 - 3 MHz
              101 - 2 MHz
              110 - 1 MHz
              111 - 32.768 kHz
         
        clkt[1:0] Clock Tail
              00 - 0 cycles
              01 - 128 cycles
              10 - 256 cycles
              11 - 512 cycles



                        Figure 27. General Purpose ADC Architecture
        Add  R/W   Function/Description   D7                D6         D5         D4         D3         D2         D1          D0          POR Def.
        0F   R/W   ADC Configuration      adcstart/adcbusy  adcsel[2]  adcsel[1]  adcsel[0]  adcref[1]  adcref[0]  adcgain[1]  adcgain[0]  00h
        10   R/W   Sensor Offset          ---               ---        ---        ---        soffs[3]   soffs[2]   soffs[1]    soffs[0]    00h
        11   R     ADC Value              adc[7]            adc[6]     adc[5]     adc[4]     adc[3]     adc[2]     adc[1]      adc[0] —                            

        

                        Temperature Sensor
        Add  R/W Function/Description      D7          D6          D5         D4         D3         D2         D1          D0          POR Def.
        12   R/W Temperature               tsrange[1]  tsrange[0]  entsoffs   entstrim   tstrim[3]  tstrim[2]  vbgtrim[1]  vbgtrim[0]  20h
                 Sensor Control
        13   R/W Temperature Value Offset  tvoffs[7]   tvoffs[6]   tvoffs[5]  tvoffs[4]  tvoffs[3]  tvoffs[2]  tvoffs[1]   tvoffs[0]   00h
         
                        Table 16. Temperature Sensor Range
        entoff   tsrange[1]   tsrange[0]   Temp. range   Unit   Slope     ADC8 LSB
        1        0            0           –64 …  64      °C     8 mV/°C   0.5 °C
        1        0            1           –64  … 192     °C     4 mV/°C   1   °C
        1        1            0            0   … 128     °C     8 mV/°C   0.5 °C
        1        1            1           –40  … 216     °F     4 mV/°F   1   °F
        0*       1            0            0 …   341     °K     3 mV/°K   1.333 °K
        *Note: Absolute temperature mode, no temperature shift. This mode is only for test purposes. POR value of
        EN_TOFF is 1.
         

        
                        Low Battery Detector
        Ad  R/W  Function/Description            D7  D6  D5  D4       D3       D2       D1        D0       POR Def.
        1A  R/W  Low Battery Detector Threshold              lbdt[4]  lbdt[3]  lbdt[2]  lbdt[1]   lbdt[0]  14h
        1B  R    Battery Voltage Level           0   0   0   vbat[4]  vbat[3]  vbat[2]  vbat[1]   vbat[0] —---

                        BatteryVoltage = 1.7 + 50mV × ADCValue

        ADC Value  VDD Voltage [V]
        0    ---   < 1.7
        1    ---   1.7–1.75
        2    ---   1.75–1.8
        … …       
        29   ---   3.1–3.15
        30   ---   3.15–3.2
        31   ---   > 3.2


                        Wake-Up Timer and 32 kHz Clock Source        
        Add  R/W  Function/Description    D7       D6       D5       D4       D3       D2       D1      D0      POR Def.
        14   R/W  Wake-Up Timer Period 1                             wtr[4]   wtr[3]   wtr[2]   wtr[1]  wtr[0]  03h
        15   R/W  Wake-Up Timer Period 2  wtm[15]  wtm[14]  wtm[13]  wtm[12]  wtm[11]  wtm[10]  wtm[9]  wtm[8]  00h
        16   R/W  Wake-Up Timer Period 3  wtm[7]   wtm[6]   wtm[5]   wtm[4]   wtm[3]   wtm[2]   wtm[1]  wtm[0]  00h
        17   R    Wake-Up Timer Value 1   wtv[15]  wtv[14]  wtv[13]  wtv[12]  wtv[11]  wtv[10]  wtv[9]  wtv[8] —---
        18   R    Wake-Up Timer Value 2   wtv[7]   wtv[6]   wtv[5]   wtv[4]   wtv[3]   wtv[2]   wtv[1]  wtv[0] —---
         


                        GPIO Configuration
        Add  R/W  Function/Description  D7 D6 D5 D4 D3 D2 D1 D0 POR Def.
        0B   R/W  GPIO0                 gpio0drv[1]  gpio0drv[0]  pup0        gpio0[4]    gpio0[3]  gpio0[2]  gpio0[1]  gpio0[0]  00h
                  Configuration        
        0C   R/W  GPIO1                 gpio1drv[1]  gpio1drv[0]  pup1        gpio1[4]    gpio1[3]  gpio1[2]  gpio1[1]  gpio1[0]  00h
                  Configuration
        0D   R/W  GPIO2                 gpio2drv[1]  gpio2drv[0]  pup2        gpio2[4]    gpio2[3]  gpio2[2]  gpio2[1]  gpio2[0]  00h
                  Configuration
        0E   R/W  I/O Port                           extitst[2]   extitst[1]  extitst[0]  itsdo     dio2      dio1      dio0      00h
                  Configuration

                    The GPIO settings for GPIO1 and GPIO2 are the same as for GPIO0 with the exception of the 00000 default
                    setting. The default settings for each GPIO are listed below:

        GPIO   00000-Default Setting
        GPIO0  POR
        GPIO1  POR Inverted
        GPIO2  Microcontroller Clock
         

                        Antenna Diversity
        Add  R/W Function/Description  D7         D6         D5         D4     D3      D2     D1       D0       POR Def.
        08   R/W Operating & Function  antdiv[2]  antdiv[1]  antdiv[0]  rxmpk  autotx  enldm  ffclrrx  ffclrtx  00h
                     Control 2
        
                        Table 17. Antenna Diversity Control
        antdiv[2:0]    RX/TX State                       Non RX/TX State
                       GPIO Ant1  GPIO Ant2              GPIO Ant1  GPIO Ant2
        000            0          1                      0          0
        001            1          0                      0          0
        010            0          1                      1          1
        011            1          0                      1          1
        100  Antenna Diversity Algorithm                 0          0
        101  Antenna Diversity Algorithm                 1          1
        110  Antenna Diversity Algorithm in Beacon Mode  0          0
        111  Antenna Diversity Algorithm in Beacon Mode  1          1         
         

                        RSSI and Clear Channel Assessment                
        Add  R/W  Function/Description                        D7         D6         D5         D4         D3         D2         D1         D0          POR Def.
        26   R    Received Signal Strength Indicator          rssi[7]    rssi[6]    rssi[5]    rssi[4]    rssi[3]    rssi[2]    rssi[1]    rssi[0] —
        27   R/W  RSSI Threshold for Clear Channel Indicator  rssith[7]  rssith[6]  rssith[5]  rssith[4]  rssith[3]  rssith[2]  rssith[1]  rssith[0]   00h





                        Table 18. Register Descriptions
                        
        Add  R/W  Function/Desc                   Data
                                                  D7                D6              D5              D4             D3           D2           D1            D0           POR Default
        00   R    Device Type                     0                 0               0               dt[4]          dt[3]        dt[2]        dt[1]         dt[0]        00111
        01   R    Device Version                  0                 0               0               vc[4]          vc[3]        vc[2]        vc[1]         vc[0]        06h
        02   R    Device Status                   ffovfl            ffunfl          rxffem          headerr        reserved     reserved     cps[1]        cps[0] —     ---
        03   R    Interrupt Status 1              ifferr            itxffafull      itxffaem        irxffafull     iext         ipksent      ipkvalid      icrcerror —  ---
        04   R    Interrupt Status 2              iswdet            ipreaval        ipreainval      irssi          iwut         ilbd         ichiprdy      ipor —       ---
        05   R/W  Interrupt Enable 1              enfferr           entxffafull     entxffaem       enrxffafull    enext        enpksent     enpkvalid     encrcerror   00h
        06   R/W  Interrupt Enable 2              enswdet           enpreaval       enpreainval     enrssi         enwut        enlbd        enchiprdy     enpor        03h
        07   R/W  Operating & Function Control 1  swres             enlbd           enwt            x32ksel        txon         rxon         pllon         xton         01h
        08   R/W  Operating & Function Control 2  antdiv[2]         antdiv[1]       antdiv[0]       rxmpk          autotx       enldm        ffclrrx       ffclrtx      00h
        09   R/W  Crystal Oscillator Load         xtalshft          xlc[6]          xlc[5]          xlc[4]         xlc[3]       xlc[2]       xlc[1]        xlc[0]       7Fh
                  Capacitance
        0A   R/W  Microcontroller Output Clock    Reserved          Reserved        clkt[1]         clkt[0]        enlfc        mclk[2]      mclk[1]       mclk[0]      06h
        0B   R/W  GPIO0 Configuration             gpio0drv[1]       gpio0drv[0]     pup0            gpio0[4]       gpio0[3]     gpio0[2]     gpio0[1]      gpio0[0]     00h           
        0C   R/W  GPIO1 Configuration             gpio1drv[1]       gpio1drv[0]     pup1            gpio1[4]       gpio1[3]     gpio1[2]     gpio1[1]      gpio1[0]     00h
        0D   R/W  GPIO2 Configuration             gpio2drv[1]       gpio2drv[0]     pup2            gpio2[4]       gpio2[3]     gpio2[2]     gpio2[1]      gpio2[0]     00h
        0E   R/W  I/O Port Configuration          Reserved          extitst[2]      extitst[1]      extitst[0]     itsdo        dio2         dio1          dio0 00h     ---
        0F   R/W  ADC Configuration               adcstart/adcdone  adcsel[2]       adcsel[1]       adcsel[0]      adcref[1]    adcref[0]    adcgain[1]    adcgain[0]   00h
        10   R/W  ADC Sensor Amplifier Offset     Reserved          Reserved        Reserved        Reserved       adcoffs[3]   adcoffs[2]   adcoffs[1]    adcoffs[0]   00h
        11   R    ADC Value                       adc[7]            adc[6]          adc[5]          adc[4]         adc[3]       adc[2]       adc[1]        adc[0] —     ---
        12   R/W  Temperature Sensor Control      tsrange[1]        tsrange[0]      entsoffs        entstrim       tstrim[3]    tstrim[2]    tstrim[1]     tstrim[0]    20h
        13   R/W  Temperature Value Offset        tvoffs[7]         tvoffs[6]       tvoffs[5]       tvoffs[4]      tvoffs[3]    tvoffs[2]    tvoffs[1]     tvoffs[0]    00h
        14   R/W  Wake-Up Timer Period 1          Reserved          Reserved        Reserved        wtr[4]         wtr[3]       wtr[2]       wtr[1]        wtr[0]       03h
        15   R/W  Wake-Up Timer Period 2          wtm[15]           wtm[14]         wtm[13]         wtm[12]        wtm[11]      wtm[10]      wtm[9]        wtm[8]       00h
        16   R/W  Wake-Up Timer Period 3          wtm[7]            wtm[6]          wtm[5]          wtm[4]         wtm[3]       wtm[2]       wtm[1]        wtm[0]       01h
        17   R    Wake-Up Timer Value 1           wtv[15]           wtv[14]         wtv[13]         wtv[12]        wtv[11]      wtv[10]      wtv[9]        wtv[8] —     ---
        18   R    Wake-Up Timer Value 2           wtv[7]            wtv[6]          wtv[5]          wtv[4]         wtv[3]       wtv[2]       wtv[1]        wtv[0] —     ---
        19   R/W  Low-Duty Cycle Mode Duration    ldc[7]            ldc[6]          ldc[5]          ldc[4]         ldc[3]       ldc[2]       ldc[1]        ldc[0]       00h
        1A   R/W  Low Battery Detector Threshold  Reserved          Reserved        Reserved        lbdt[4]        lbdt[3]      lbdt[2]      lbdt[1]       lbdt[0]      14h
        1B   R    Battery Voltage Level           0                 0               0               vbat[4]        vbat[3]      vbat[2]      vbat[1]       vbat[0] —    ---
        1C   R/W  IF Filter Bandwidth             dwn3_bypass       ndec[2]         ndec[1]         ndec[0]        filset[3]    filset[2]    filset[1]     filset[0]    01h
        1D   R/W  AFC Loop Gearshift Override     afcbd             enafc           afcgearh[2]     afcgearh[1]    afcgearh[0]  1p5 bypass   matap         ph0size      40h
        1E   R/W  AFC Timing Control              swait_timer[1]    swait_timer[0]  shwait[2]       shwait[1]      shwait[0]    anwait[2]    anwait[1]     anwait[0]    0Ah
        1F   R/W  Clock Recovery Gearshift        Reserved          Reserved        crfast[2]       crfast[1]      crfast[0]    crslow[2]    crslow[1]     crslow[0]    03h
                  Override
        20   R/W  Clock Recovery Oversampling     rxosr[7]          rxosr[6]        rxosr[5]        rxosr[4]       rxosr[3]     rxosr[2]     rxosr[1]      rxosr[0]     64h
                  Ratio
        21   R/W  Clock Recovery Offset 2         rxosr[10]         rxosr[9]        rxosr[8]        stallctrl      ncoff[19]    ncoff[18]    ncoff[17]     ncoff[16]    01h
        22   R/W  Clock Recovery Offset 1         ncoff[15]         ncoff[14]       ncoff[13]       ncoff[12]      ncoff[11]    ncoff[10]    ncoff[9]      ncoff[8]     47h
        23   R/W  Clock Recovery Offset 0         ncoff[7]          ncoff[6]        ncoff[5]        ncoff[4]       ncoff[3]     ncoff[2]     ncoff[1]      ncoff[0]     AEh
        24   R/W  Clock Recovery Timing Loop      Reserved          Reserved        Reserved        rxncocomp      crgain2x     crgain[10]   crgain[9]     crgain[8]    02h
                  Gain 1
        25   R/W  Clock Recovery Timing Loop      crgain[7]         crgain[6]       crgain[5]       crgain[4]      crgain[3]    crgain[2]    crgain[1]     crgain[0]    8Fh
                  Gain 0
        26   R    Received Signal Strength        rssi[7]           rssi[6]          rssi[5]        rssi[4]        rssi[3]      rssi[2]      rssi[1]       rssi[0] —    ---
                  Indicator
        27   R/W  RSSI Threshold for Clear        rssith[7]         rssith[6]        rssith[5]      rssith[4]      rssith[3]    rssith[2]    rssith[1]     rssith[0]    1Eh
                  Channel Indicator
        28   R    Antenna Diversity Register 1    adrssi1[7]        adrssia[6]       adrssia[5]     adrssia[4]     adrssia[3]   adrssia[2]   adrssia[1]    adrssia[0] — ---
        29   R    Antenna Diversity Register 2    adrssib[7]        adrssib[6]       adrssib[5]     adrssib[4]     adrssib[3]   adrssib[2]   adrssib[1]    adrssib[0] — ---
        2A   R/W  AFC Limiter                     Afclim[7]         Afclim[6]        Afclim[5]      Afclim[4]      Afclim[3]    Afclim[2]    Afclim[1]     Afclim[0]    00h
        2B   R    AFC Correction Read             afc_corr[9]       afc_corr[8]      afc_corr[7]    afc_corr[6]    afc_corr[5]  afc_corr[4]  afc_corr[3]   afc_corr[2]  00h
        2C   R/W  OOK Counter Value 1             afc_corr[9]       afc_corr[9]      ookfrzen       peakdeten      madeten      ookcnt[10]   ookcnt[9]     ookcnt[8]    18h
        2D   R/W  OOK Counter Value 2             ookcnt[7]         ookcnt[6]        ookcnt[5]      ookcnt[4]      ookcnt[3]    ookcnt[2]    ookcnt[1]     ookcnt[0]    BCh
        2E   R/W  Slicer Peak Hold                Reserved          attack[2]        attack[1]      attack[0]      decay[3]     decay[2]     decay[1]      decay[0]     26h
        2F   Reserved
        30   R/W  Data Access Control             enpacrx           lsbfrst          crcdonly       skip2ph        enpactx      encrc        crc[1]        crc[0]       8Dh
        31   R    EzMAC status                    0                 rxcrc1           pksrch         pkrx           pkvalid      crcerror     pktx          pksent —     ---
        32   R/W  Header Control 1                bcen[3:0]         hdch[3:0]        0Ch
        33   R/W  Header Control 2                skipsyn           hdlen[2]         hdlen[1]       hdlen[0]       fixpklen     synclen[1]    synclen[0]   prealen[8]   22h
        34   R/W  Preamble Length                 prealen[7]        prealen[6]       prealen[5]     prealen[4]     prealen[3]   prealen[2]    prealen[1]   prealen[0]   08h
        35   R/W  Preamble Detection Control      preath[4]         preath[3]        preath[2]      preath[1]      preath[0]    rssi_off[2]   rssi_off[1]  rssi_off[0]  2Ah
        36   R/W  Sync Word 3                     sync[31]          sync[30]         sync[29]       sync[28]       sync[27]     sync[26]      sync[25]     sync[24]     2Dh
        37   R/W  Sync Word 2                     sync[23]          sync[22]         sync[21]       sync[20]       sync[19]     sync[18]      sync[17]     sync[16]     D4h
        38   R/W  Sync Word 1                     sync[15]          sync[14]         sync[13]       sync[12]       sync[11]     sync[10]      sync[9]      sync[8]      00h
        39   R/W  Sync Word 0                     sync[7]           sync[6]          sync[5]        sync[4]        sync[3]      sync[2]       sync[1]      sync[0]      00h
        3A   R/W  Transmit Header 3               txhd[31]          txhd[30]         txhd[29]       txhd[28]       txhd[27]     txhd[26]      txhd[25]     txhd[24]     00h
        3B   R/W  Transmit Header 2               txhd[23]          txhd[22]         txhd[21]       txhd[20]       txhd[19]     txhd[18]      txhd[17]     txhd[16]     00h
        3C   R/W  Transmit Header 1               txhd[15]          txhd[14]         txhd[13]       txhd[12]       txhd[11]     txhd[10]      txhd[9]      txhd[8]      00h
        3D   R/W  Transmit Header 0               txhd[7]           txhd[6]          txhd[5]        txhd[4]        txhd[3]      txhd[2]       txhd[1]      txhd[0]      00h
        3E   R/W  Transmit Packet Length          pklen[7]          pklen[6]         pklen[5]       pklen[4]       pklen[3]     pklen[2]      pklen[1]     pklen[0]     00h
        3F   R/W  Check Header 3                  chhd[31]          chhd[30]         chhd[29]       chhd[28]       chhd[27]     chhd[26]      chhd[25]     chhd[24]     00h
        40   R/W  Check Header 2                  chhd[23]          chhd[22]         chhd[21]       chhd[20]       chhd[19]     chhd[18]      chhd[17]     chhd[16]     00h
        41   R/W  Check Header 1                  chhd[15]          chhd[14]         chhd[13]       chhd[12]       chhd[11]     chhd[10]      chhd[9]      chhd[8]      00h
        42   R/W  Check Header 0                  chhd[7]           chhd[6]          chhd[5]        chhd[4]        chhd[3]      chhd[2]       chhd[1]      chhd[0]      00h
        43   R/W  Header Enable 3                 hden[31]          hden[30]         hden[29]       hden[28]       hden[27]     hden[26]      hden[25]     hden[24]     FFh
        44   R/W  Header Enable 2                 hden[23]          hden[22]         hden[21]       hden[20]       hden[19]     hden[18]      hden[17]     hden[16]     FFh
        45   R/W  Header Enable 1                 hden[15]          hden[14]         hden[13]       hden[12]       hden[11]     hden[10]      hden[9]      hden[8]      FFh
        46   R/W  Header Enable 0                 hden[7]           hden[6]          hden[5]        hden[4]        hden[3]      hden[2]       hden[1]      hden[0]      FFh
        47   R    Received Header 3               rxhd[31]          rxhd[30]         rxhd[29]       rxhd[28]       rxhd[27]     rxhd[26]      rxhd[25]     rxhd[24] —   ---
        48   R    Received Header 2               rxhd[23]          rxhd[22]         rxhd[21]       rxhd[20]       rxhd[19]     rxhd[18]      rxhd[17]     rxhd[16] —   ---
        49   R    Received Header 1               rxhd[15]          rxhd[14]         rxhd[13]       rxhd[12]       rxhd[11]     rxhd[10]      rxhd[9]      rxhd[8] —    ---
        4A   R    Received Header 0               rxhd[7]           rxhd[6]          rxhd[5]        rxhd[4]        rxhd[3]      rxhd[2]       rxhd[1]      rxhd[0] —    ---
        4B   R    Received Packet Length          rxplen[7]         rxplen[6]        rxplen[5]      rxplen[4]      rxplen[3]    rxplen[2]     rxplen[1]    rxplen[0] —  ---
        4C-4E Reserved
        4F   R/W  ADC8 Control                    Reserved          Reserved         adc8[5]        adc8[4]        adc8[3]      adc8[2]       adc8[1]      adc8[0]      10h
        50-5F Reserved                                                                        
        60   R/W  Channel Filter Coefficient      Inv_pre_th[3]     Inv_pre_th[2]    Inv_pre_th[1]  Inv_pre_th[0]  chfiladd[3]  chfiladd[2]   chfiladd[1]  chfiladd[0]  00h
                  Address
        61    Reserved
        62   R/W  Crystal Oscillator/Control      pwst[2]           pwst[1]          pwst[0]        clkhyst        enbias2x     enamp2x       bufovr       enbuf        24h
                  Test
        63-68 Reserved
        69   R/W  AGC Override 1                  Reserved          sgi              agcen          lnagain        pga3         pga2          pga1         pga0         20h
        6A-6C Reserved                                                                                                                       
        6D   R/W  TX Power                        papeakval         papeaken         papeaklvl[1]   papeaklvl[0]   Ina_sw       txpow[2]      txpow[1]     txpow[0]     18h
        6E   R/W  TX Data Rate 1                  txdr[15]          txdr[14]         txdr[13]       txdr[12]       txdr[11]     txdr[10]      txdr[9]      txdr[8]      0Ah
        6F   R/W  TX Data Rate 0                  txdr[7]           txdr[6]          txdr[5]        txdr[4]        txdr[3]      txdr[2]       txdr[1]      txdr[0]      3Dh
        70   R/W  Modulation Mode Control 1       Reserved          Reserved         txdtrtscale    enphpwdn       manppol      enmaninv      enmanch      enwhite      0Ch
        71   R/W  Modulation Mode Control 2       trclk[1]          trclk[0]         dtmod[1]       dtmod[0]       eninv        fd[8]         modtyp[1]    modtyp[0]    00h
        72   R/W  Frequency Deviation             fd[7]             fd[6]            fd[5]          fd[4]          fd[3]        fd[2]         fd[1]        fd[0]        20h
        73   R/W  Frequency Offset 1              fo[7]             fo[6]            fo[5]          fo[4]          fo[3]        fo[2]         fo[1]        fo[0]        00h
        74   R/W  Frequency Offset 2              Reserved          Reserved         Reserved       Reserved       Reserved     Reserved      fo[9]        fo[8]        00h
        75   R/W  Frequency Band Select           Reserved          sbsel            hbsel          fb[4]          fb[3]        fb[2]         fb[1]        fb[0]        75h
        76   R/W  Nominal Carrier Frequency 1     fc[15]            fc[14]           fc[13]         fc[12]         fc[11]       fc[10]        fc[9]        fc[8]        BBh
        77   R/W  Nominal Carrier Frequency 0     fc[7]             fc[6]            fc[5]          fc[4]          fc[3]        fc[2]         fc[1]        fc[0]        80h
        78    Reserved
        79   R/W  Frequency Hopping Channel       fhch[7]           fhch[6]          fhch[5]        fhch[4]        fhch[3]      fhch[2]       fhch[1]      fhch[0]      00h
                  Select
        7A   R/W  Frequency Hopping Step Size     fhs[7]            fhs[6]           fhs[5]         fhs[4]         fhs[3]       fhs[2]        fhs[1]       fhs[0]       00h
        7B    Reserved
        7C   R/W  TX FIFO Control 1               Reserved          Reserved         txafthr[5]     txafthr[4]     txafthr[3]   txafthr[2]    txafthr[1]   txafthr[0]   37h
        7D   R/W  TX FIFO Control 2               Reserved          Reserved         txaethr[5]     txaethr[4]     txaethr[3]   txaethr[2]    txaethr[1]   txaethr[0]   04h
        7E   R/W  RX FIFO Control                 Reserved          Reserved         rxafthr[5]     rxafthr[4]     rxafthr[3]   rxafthr[2]    rxafthr[1]   rxafthr[0]   37h
        7F   R/W  FIFO Access                     fifod[7]          fifod[6]         fifod[5]       fifod[4]       fifod[3]     fifod[2]      fifod[1]     fifod[0] —   ---     
                                         
}

Dat     ' // RFM22 Datasheed Info        ( *** Same as RFM28BP *** )
{

              Table 16. RX Modem Configurations for FSK and GFSK

                                   RX Modem setting examples for GFSK and FSK
                    
        Application parameters                             Register values (hex)
                
        Rb    Fd   mod    BW -3dB  dwn3_bypass  ndec_exp[2:0]  filset[3:0]  rxosr[10:0]  ncoff[19:0]  crgain[10:0]         
        kbps  kHz  index  kHz      1Ch          1Ch            1Ch          20,21h       21,22,23h    24,25h
        2     5     5.00  11.5     0            3              3            0FA          08312        06B
        2.4   4.8   4.00  11.5     0            3              3            0D0          09D49        0A0
        2.4   36   30.00  75.2     0            0              1            683          013A9        005
        4.8   4.8   2.00  12.1     0            3              4            068          13A93        278
        4.8   45   18.75  95.3     0            0              4            341          02752        00A
        9.6   4.8   1.00  18.9     0            2              1            068          13A93        4EE
        9.6   45    9.38  95.3     0            0              4            1A1          04EA5        024        
        10    5     1.00  18.9     0            2              1            064          147AE        521        
        10    40    8.00  90       0            0              3            190          051EC        02B        
        19.2  9.6   1.00  37.7     0            1              1            068          13A93        4EE        
        20    10    1.00  37.7     0            1              1            064          147AE        521
        20    40    4.00  95.3     0            0              4            0C8          0A3D7        0A6
        38.4  19.6  1.02  75.2     0            0              1            068          13A93        4D5
        40    20    1.00  75.2     0            0              1            064          147AE        521
        40    40    2.00  112.1    0            0              5            064          147AE        291
        50    25    1.00  75.2     0            0              1            050          1999A        668
        57.6  28.8  1.00  90       0            0              3            045          1D7DC        76E
        100   50    1.00  191.5    1            0              F            078          11111        446
        100   300   6.00  620.7    1            0              E            078          11111        0B8        
        125   125   2.00  335.5    1            0              8            060          15555        2AD              


         
              Table 17. Filter Bandwidth Parameters
         BW    ndec_exp  dwn3_bypass  filset
        [kHz]  1C-[6:4]  1C-[7]       1C-[3:0]
        2.6    5         0            1         
        2.8    5         0            2
        3.1    5         0            3
        3.2    5         0            4
        3.7    5         0            5
        4.2    5         0            6         
        4.5    5         0            7         
        4.9    4         0            1         
        5.4    4         0            2         
        5.9    4         0            3         
        6.1    4         0            4         
        7.2    4         0            5
        8.2    4         0            6
        8.8    4         0            7
        9.5    3         0            1
        10.6   3         0            2
        11.5   3         0            3
        12.1   3         0            4
        14.2   3         0            5
        16.2   3         0            6
        17.5   3         0            7
        18.9   2         0            1
        21.0   2         0            2
        22.7   2         0            3
        24.0   2         0            4
        28.2   2         0            5
        32.2   2         0            6
        34.7   2         0            7
        37.7   1         0            1
                 
         
         BW    ndec_exp  dwn3_bypass  filset
        [kHz]  1C-[6:4]  1C-[7]       1C-[3:0]
        41.7   1         0            2
        45.2   1         0            3
        47.9   1         0            4
        56.2   1         0            5
        64.1   1         0            6
        69.2   1         0            7
        75.2   0         0            1
        83.2   0         0            2
        90.0   0         0            3
        95.3   0         0            4
        112.1  0         0            5
        127.9  0         0            6
        137.9  0         0            7
        142.8  1         1            4
        167.8  1         1            5
        181.1  1         1            9
        191.5  0         1            15
        225.1  0         1            1
        248.8  0         1            2
        269.3  0         1            3
        284.9  0         1            4
        335.5  0         1            8
        361.8  0         1            9
        420.2  0         1            10
        468.4  0         1            11
        518.8  0         1            12
        577.0  0         1            13
        620.7  0         1            14
         
         
              Table 18. Channel Filter Bandwidth Settings
        BW[kHz]  dwn3_bypass  filset[3:0]
        75.2     0            1
        83.2     0            2
        90       0            3
        95.3     0            4
        112.1    0            5
        127.9    0            6
        137.9    0            7
        191.5    1            F
        225.1    1            1
        248.8    1            2
        269.3    1            3
        284.9    1            4
        335.5    1            8
        361.8    1            9
        420.2    1            10
        468.4    1            11
        518.8    1            12
        577      1            13
        620.7    1            14

         
              Table 19. ndec[2:0] Settings
        Rb(1+ enmanch) [kbps]
                            ndec[2:0]
        Min       Max
        0         1         5
        1         2         4
        2         3         3
        3         8         2
        8         40        1
        40        65        0


         
              Table 20. RX Modem Configuration for OOK with Manchester Disabled
                        RX Modem Setting Examples for OOK (Manchester Disabled)
        Appl Parameters         Register Values
        Rb        RX BW        dwn3_bypass  ndec_exp[2:0]  filset[3:0]  rxosr[10:0]  ncoff[19:0]  crgain[10:0]
        [kbps]    [kHz]        1Ch          1Ch            1Ch          20,21h       21,22,23h    24,25h
        1.2       75           0            4              1            0D0          09D49        13D
        1.2       110          0            4              5            0D0          09D49        13D
        1.2       335          1            4              8            271          0346E        06B
        1.2       420          1            4              A            271          0346E        06B
        1.2       620          1            4              E            271          0346E        06B
        2.4       335          1            3              8            271          0346E        06B
        4.8       335          1            2              8            271          0346E        06B
        9.6       335          1            1              8            271          0346E        06B
        10        335          1            1              8            258          0369D        06F
        15        335          1            1              8            190          051EC        0A6
        19.2      335          1            1              8            139          068DC        0D3
        20        335          1            1              8            12C          06D3A        0DC
        30        335          1            1              8            0C8          0A3D7        14A
        38.4      335          1            1              8            09C          0D1B7        1A6
        40        335          1            1              8            096          0DA74        1B7
        
              Table 21. RX Modem Configuration for OOK with Manchester Enabled

                      RX Modem Setting Examples for OOK (Manchester Disabled)
        Appl Parameters        Register Values
        Rb        RX BW        dwn3_bypass  ndec_exp[2:0]  filset[3:0]  rxosr[10:0]  ncoff[19:0]  crgain[10:0]
        [kbps]    [kHz]        1Ch          1Ch            1Ch          20,21h       21,22,23h    24,25h
        1.2       75           0            3              1            0D0          04EA5        13D
        1.2       110          0            3              5            0D0          04EA5        13D
        1.2       335          1            3              8            271          01A37        06B
        1.2       420          1            3              A            271          01A37        06B
        1.2       620          1            3              E            271          01A37        06B
        2.4       335          1            2              8            271          01A37        06B
        4.8       335          1            1              8            271          01A37        06B
        9.6       335          1            1              8            139          0346E        0D3
        10        335          1            1              8            12C          0369D        0DC
        15        335          1            1              8            0C8          051EC        14A
        19.2      335          1            1              8            09C          068DC        1A6
        20        335          1            1              8            096          06D3A        1B7
        30        335          1            0              8            0C8          051EC        14A
        38.4      335          1            0              8            09C          068DC        1A6
        40        335          1            0              8            096          06D3A        1B7
         
         

                ADC Offset Values
        adcoffs[3]  Input Offset (% of VDD)
        0           0 if adcoffs[2:0] = 0
                  -(8 - adcoffs[2:0]) x 0.12
        1           adcoffs[2:0] x 0.12
         


         
        Letter  ASCII Code    Binary    Letter  ASCII Code    Binary
            a       097     01100001        A       065     01000001
            b       098     01100010        B       066     01000010
            c       099     01100011        C       067     01000011
            d       100     01100100        D       068     01000100
            e       101     01100101        E       069     01000101
            f       102     01100110        F       070     01000110
            g       103     01100111        G       071     01000111
            h       104     01101000        H       072     01001000
            i       105     01101001        I       073     01001001
            j       106     01101010        J       074     01001010
            k       107     01101011        K       075     01001011
            l       108     01101100        L       076     01001100
            m       109     01101101        M       077     01001101
            n       110     01101110        N       078     01001110
            o       111     01101111        O       079     01001111
            p       112     01110000        P       080     01010000
            q       113     01110001        Q       081     01010001
            r       114     01110010        R       082     01010010
            s       115     01110011        S       083     01010011
            t       116     01110100        T       084     01010100
            u       117     01110101        U       085     01010101
            v       118     01110110        V       086     01010110
            w       119     01110111        W       087     01010111
            x       120     01111000        X       088     01011000
            y       121     01111001        Y       089     01011001
            z       122     01111010        Z       090     01011010
         
      
}
         
         
         
         