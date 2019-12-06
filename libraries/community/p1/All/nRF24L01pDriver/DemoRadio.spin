{{
 DemonrfNRF24L01. Demonstrates the driver for nRF24L01+ and the SPIdriver. Includes a carrier wave scanner and a simple Sender, Receiver, and Beacon demo.
 Erlend Fj. 2015
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

 Includes Enhanced Shockburst Mode which provides a link level transport protocol

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements:  

=======================================================================================================================================================================

 About nRF24L01+
 ---------------
  -see driver heading

 
 REF:


=======================================================================================================================================================================
}
 
CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                      'use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                     'system freq as a constant
          mSec     = clk_freq / 1_000                               'ticks in 1ms
          uSec     = clk_freq / 1_000_000                           'ticks in 1us     (80 ticks)


          PINmosi  = 5
          PINmiso  = 6
          PINclk   = 7
          PINcs    = 0
          PINce    = 1

          channel  = 113
           

VAR

          BYTE  telegram[32]

          
DAT
          RFaddr  BYTE  $E7, $E7, $E7, $E7, $E7                           'address used for transmitter&receiver id
          hello   BYTE "Hello world, this is a tx test!"                  '31 + 1 zero byte string - only used by the Beacon method

          
OBJ
          nrf  : "NRF24L01pDriver"
          pst    : "Parallax Serial Terminal"
          

PUB Main | value                                  

  pst.Start(115200)                      
  WAITCNT((2*(CLKFREQ/1000)) + CNT)
  value := pst.DecIn                                                       'Wait for keyboard entry before continue 
  
  pst.Str(String("Initializing bus and chip..."))
  nrf.Init(PINmosi, PINmiso, PINclk, PINcs, PINce)
  pst.Str(String("done."))
  pst.Chars(pst#NL, 2)
                    
  REPEAT                                                                        
    pst.Chars(pst#NL, 2)                                                        
    pst.Str(String("Enter 0-Scan the air, 1-Be transmitter, 2-Be receiver, 3-Be a beacon, 4-Register scan, -1-Quit: ")) 
    value := pst.DecIn                                                          
    pst.Chars(pst#NL, 2)

    CASE value
        0  : ScanAir
        1  : Transmitter
        2  : Receiver
        3  : Beacon
        4  : ScanR
        -1 : QUIT
      OTHER: pst.Str(String("Sorry - invalid input."))
     
  pst.Str(String(pst#NL,"Bye."))                  
                                                            

  
PUB ScanAir | start, ch

   pst.Str(String("Starts scanning, lists the channels with a carrier wave detected. Runs through all 125"))
   pst.Chars(pst#NL, 2)
   pst.Str(String("Channels detected: "))

   nrf.SetPrimaryMode(1)                   'primary receiver
   nrf.EnableRXpipes(%00001)               'pipe0 enabled
   nrf.SetShockburst(0)                    'no fancy transport protocol needed                              
   nrf.ChipEnable(1)                       'not really chip enable, but radio (part of it) enable
   WAITCNT(mSec + CNT)
   
     REPEAT ch FROM 0 TO 125               'Scan trhough channels
       nrf.SetRFchannel(ch)
       WAITCNT(mSec + CNT)
       pst.Str(String("."))
       start:= CNT
       REPEAT
         IF nrf.IsCarrier                  'check a few times if there is a carrier detect
           pst.Dec(ch)
           pst.Str(String(" + "))
           QUIT
       UNTIL CNT > start + 100*mSec  
                                                                                         
  pst.Chars(pst#NL, 2)      
  pst.Str(String("Finished."))
  pst.Chars(pst#NL, 2)
 


  
PUB ScanR |  regr, data1, data2, data3      'For info/debugging - display the regiser contents (for multibyte regs only first byte is displayed)

   REPEAT regr FROM $0 TO $17
     pst.Str(String("Register: "))
     pst.Hex(regr, 2)                           
     data3:= nrf.R_REGISTERbyte(regr)
     pst.Str(String("   nrf reply: "))
     pst.Bin(data3, 8)     
     pst.Chars(pst#NL, 2)

     
PUB Transmitter 

   pst.Str(String("Sends a string of up to 32 characters to a receiver on same channel and address"))
   pst.Chars(pst#NL, 2)

   nrf.SetPrimaryMode(0)                   'primary transmitter
   nrf.EnableRXpipes(%00001)               'pipe0 enabled
   nrf.SetShockburst(1)                    'fancy transport protocol                              
   nrf.SetPayloadWidth(0, 32)              'set up pipe0 for max length (32 bytes) 
   nrf.SetTransmitterPower(0)              'set to max power: 0dB
   nrf.SetRadioDatarate(1)                 'set to max datarate: 2Mbps
   nrf.SetRFchannel(channel)
   nrf.WriteRxPipeAddress(@RFaddr, 0)      'set pipe0 rf addr/id equal to DAT variable (assuming default address width of 5 bytes)
   nrf.WriteTxPipeAddress(@RFaddr)         'd.o. for tx
   nrf.FLUSH_TX                            'empty the buffer 

   REPEAT
     pst.Chars(pst#NL, 2)
     pst.Str(String("¥> "))                'prompt user to input a string
     pst.StrInMax(@telegram, 32)           'receive a string, max length 32 (which is max the radio can take)
     nrf.ReadNclearInterrupts              'get rid of old interrupts
     nrf.W_TX_PAYLOAD(@telegram, 32)       'write the string into tx buffer
     pst.Str(@telegram)
     
     nrf.ChipEnable(1)                     'pulse the radio to transmit
     WAITCNT(mSec + CNT)
     nrf.ChipEnable(0)
     WAITCNT(mSec + CNT)
     
     IF nrf.IsDataSent
       pst.Chars(pst#NL, 2)
       pst.Str(String("Data sent. "))
       pst.Chars(pst#NL, 2)
     IF nrf.IsMaxRetries       
       pst.Chars(pst#NL, 2)  
       pst.Str(String("Max retries "))  
       pst.Chars(pst#NL, 2)
     IF nrf.IsFullTX       
       pst.Chars(pst#NL, 2)  
       pst.Str(String("TX buffer full "))  
       pst.Chars(pst#NL, 2)
      
     IF STRSIZE(@telegram)== 0
       nrf.FLUSH_TX                            'empty the buffer
       nrf.ReadNclearInterrupts                'get rid of old interrupts
       QUIT
     

PUB Receiver | start

   pst.Str(String("Receive a string of up to 32 characters from a transmitter on same channel and address"))
   pst.Chars(pst#NL, 2)                                                                                                                        

   nrf.SetPrimaryMode(1)                   'primary receiver                                                                                   
   nrf.EnableRXpipes(%00001)               'pipe0 enabled
   nrf.SetShockburst(1)                    'transport protocol                                                                             
   nrf.SetRFchannel(channel)
   nrf.SetPayloadWidth(0, 32)
   'nrf.SetAddressWidth(5)                 'default is 5   (this method is not implemented in driver yet)                                                                               
   nrf.WriteRxPipeAddress(@RFaddr, 0)      'set pipe0 rf addr/id equal to DAT variable (assuming default address width of 5 bytes)
   nrf.WriteTxPipeAddress(@RFaddr)         'd.o. for tx 
   nrf.ChipEnable(1)                       'not really chip enable, but radio (part of it) enable
   WAITCNT(mSec + CNT)

   REPEAT
     pst.Str(String("¥~~ "))
     REPEAT UNTIL nrf.IsPayloadRX== 1      'payload in pipe0
     nrf.R_RX_PAYLOAD(@telegram, 32)
     nrf.ReadNclearInterrupts
     pst.Str(@telegram)
     pst.Chars(pst#NL, 2)
     IF STRSIZE(@telegram)== 0             'quit if empty telegram
       QUIT         

  pst.Chars(pst#NL, 2)      
  pst.Str(String("Finished."))
  pst.Chars(pst#NL, 2)
 


PUB Beacon | thetime

   pst.Str(String("Continously transmits by repeatedly sending a 32 byte text string. Time out after 30 sec"))
   pst.Chars(pst#NL, 2)

   nrf.SetPrimaryMode(0)                                    'primary transmitter                                                                   
   nrf.EnableRXpipes(%00001)                                'pipe0 enabled                                                                         
   nrf.SetShockburst(0)                                     'fancy transport protocol                                  
   nrf.SetPayloadWidth(0, 32)                               'set up pipe0 for max length (32 bytes)                                                
   nrf.SetTransmitterPower(0)                               'set to max power: 0dB                                                                 
   nrf.SetRadioDatarate(1)                                  'set to max datarate: 2Mbps                                                            
   nrf.SetRFchannel(0)                                                                                                                       
   nrf.WriteRxPipeAddress(@RFaddr, 0)                       'set pipe0 rf addr/id equal to DAT variable (assuming default address width of 5 bytes)
   nrf.WriteTxPipeAddress(@RFaddr)                          'd.o. for tx                                                                           
   nrf.FLUSH_TX                                             'empty the buffer                                                                      
                                                                                                                                                   
   pst.Chars(pst#NL, 2)                                                                                                                            
   pst.Str(String("¥! "))                                   'beacon start                                                                          
   nrf.ReadNclearInterrupts                                 'get rid of old interrupts                                                             
   nrf.W_TX_PAYLOAD(@telegram, 32)                          'write the string into tx buffer                                                       
   nrf.W_REGISTERbyte(nrf#RF_SETUP, %00011111)              'force PLL lock signal (bit4)

   nrf.ChipEnable(1)                                        'pulse the radio to transmit
   WAITCNT(mSec + CNT)
   nrf.ChipEnable(0)
   WAITCNT(mSec + CNT)

   nrf.REUSE_TX_PL                                          'enable reusing the same tx buffer
   
   thetime:= CNT
   REPEAT UNTIL thetime > 30*CLKFREQ  + CNT
       nrf.ChipEnable(1)                                    'pulse the radio to transmit
       WAITCNT(mSec + CNT)
       nrf.ChipEnable(0)
       WAITCNT(mSec + CNT)
       nrf.ReadNclearInterrupts
       
  nrf.W_REGISTERbyte(nrf#RF_SETUP, %00001111)              'release force PLL lock signal (bit4)      
  pst.Chars(pst#NL, 2)      
  pst.Str(String("Finished."))
  pst.Chars(pst#NL, 2)

  

PRI private_method_name


DAT
name    byte  "string_data",0        
        