'' ============================================================================
'' Program01  main   TRF24G Demo        A.Marincak  May 12 2007         Ver 1.0
'' ============================================================================
''
'' This program must run at 80Mhz (or you will need to adjust timimg calls)
''
'' IO Utilization
''
''   Pin  0     - Status LED       - a heartbeat LED, user must set theis up
''
''   Pin 16     - TRF24G Data1     - I/O
''   Pin 17     - TRF24G CLK1      - Out                                      
''   Pin 18     - TRF24G DR1       - In
''   Pin 19     - TRF24G CS        - Out
''   Pin 20     - TRF24G CE        - Out
''
''   Pin 24     - RfTx LED         - setup an LED for this (not on the TRF24G)
''   Pin 26     - RfRx LED         - setup an LED for this (not on the TRF24G)  
''   Pin 27     - RxTx Test Button - setup a button for testing 
''
''   Pin 30     - serial TX     - Obj: FullDuplexSerial (new Cog)
''   Pin 31     - serial RX     - Obj: FullDuplexSerial (new Cog)
''
''
'' This program does not do much other than show you how to setup and run
'' the TRF24G handler / driver code. A sample configuration is used in the
'' DAT section. It sets the TRF24G to 1Mbps Shockburst mode, with 16 bit CRC,
'' using RF channel 2, with a 40bit address. The address it responds to is
'' in the configuration. Make sure the other TRF24G is configured identically
'' (but with a different address of course). Set the destination address in
'' the TX buffer to be the address of the othre TRF24G.
'' 
''
'' The basic call sequence is
''
''      1) call the TRF24G  Init() method to identify the pins used
''      2) call the TRF24G  Configure() method to configure the device
''      3) call the TRF24G  SetMode() method with 1 to start rx monitoring
''      4) check the DR1 pin to see if anything has been received
''         - if so call the TRF24G recv() methode to get the packet
''      5) to send a packet call the TRF24G xmit() method
''
'' Please read the TRF24G (Nordic nRF2401) documentation ... it will give
'' you answers to many questions.

con
  _clkmode          = xtal1 + pll16x
  _xinfreq          = 5_000_000

  serial_rx         = 31        'serial Rx line
  serial_tx         = 30        'serial tx line

  rftx_btn          = 27        'used to trigger transmit
  rfrx_led          = 26        'set low to turn LED on
  rftx_led          = 24        'set low to turn LED on
    
  rf_ce             = 20        'trf24g data i/o select
  rf_cs             = 19        'trf24g configuration select
  rf_dr             = 18        'trf24g data ready bit
  rf_clk            = 17        'trf24g clock
  rf_dat            = 16        'trf24g data i/o bit
  
  status_led        = 0         'status LED  port


DAT
  rf_cfg  byte $C8  ' Data2 width (bits) excluding addr & crc (25 bytes)
          byte $C8  ' Data1 width (bits) excluding addr & crc (25 bytes)
          byte $AA  ' Channel #2 - Addr Byte 1 (MSB)
          byte $55  '            - Addr Byte 2
          byte $BB  '            - Addr Byte 3
          byte $CC  '            - Addr Byte 4
          byte $01  '            - Addr Byte 5
          byte $AA  ' Channel #1 - Addr Byte 1 (MSB) addres this TRF24G responds to
          byte $55  '            - Addr Byte 2
          byte $BB  '            - Addr Byte 3
          byte $CC  '            - Addr Byte 4
          byte $01  '            - Addr Byte 5
          byte $A3  ' 7-2:address width(40), 1:CRC Mode(16), 0:CRC enable(on)
          byte $6F  ' 7:Dual Ch mode(off), 6:ShockBurst mode(on), 5:1m/250k bps(1mbps), 4-2:xtal sel(16Mhz), 1-0:rf Power(hi)
          byte $05  ' 7-1:RF channel(2), 0:RX enable(on=Rx mode)

  tx_s   byte  13,10,"Sonar Output is ",0
  tx_i   byte  13,10,"Ir Output is ",0
  tx_r   byte  13,10,"Rf Output is ",0


OBJ
  RS232          : "FullDuplexSerial"  'include serial io handler
  trf24g         : "TRF24G"            'include Trf24g handler 

                               
VAR
  long heartbeat
  byte rf_txbuf[32]
  byte rf_rxbuf[32]
  byte tmp                      

  
PUB main

  rf_txbuf[ 0] := $AA           'Setup Tx buffer
  rf_txbuf[ 1] := $55
  rf_txbuf[ 2] := $BB
  rf_txbuf[ 3] := $CC
  rf_txbuf[ 4] := $02
  rf_txbuf[ 5] := "P"           'packet is sn ASCII string 
  rf_txbuf[ 6] := "R"           '  "Propeller says Hello!"
  rf_txbuf[ 7] := "o"
  rf_txbuf[ 8] := "p"
  rf_txbuf[ 9] := "e"
  rf_txbuf[11] := "l"
  rf_txbuf[12] := "l"
  rf_txbuf[13] := "e"
  rf_txbuf[14] := "r"
  rf_txbuf[15] := " "
  rf_txbuf[16] := "s"
  rf_txbuf[17] := "a"
  rf_txbuf[18] := "y"
  rf_txbuf[19] := "s"
  rf_txbuf[20] := " "
  rf_txbuf[21] := "H"
  rf_txbuf[22] := "e"
  rf_txbuf[23] := "l"
  rf_txbuf[24] := "l"
  rf_txbuf[25] := "o"
  rf_txbuf[26] := "!"
  rf_txbuf[27] := 0
  
  
  trf24g.Init( rf_cs, rf_ce, rf_clk, rf_dr, rf_dat )    'Initialize TRF24G
  trf24g.configure( @rf_cfg )
  trf24g.setmode( 1 )                                   '1 = RX_ON   3 = TX_ON

  RS232.start( serial_rx, serial_tx, 0, 9600 )          'initialize RS232 for PC io
  RS232.rxflush
  dira[status_led] := 1                                 'set status LED pin output
  outa[status_led] := 1                                 'set status LED pin high (LED off)

  dira[rfrx_led] := 1                                   'set Rf Rx LED pin output
  outa[rfrx_led] := 1                                   'set Rf Rx LED pin high (LED off)
  dira[rftx_led] := 1                                   'set Rf Tx LED pin output
  outa[rftx_led] := 1                                   'set Rf Tx LED pin high (LED off)
  
  heartbeat := cnt + 40_000_000
 
  repeat    
    if ina[rf_dr]
      outa[rfrx_led] := 0                               'Rf Rx LED On
      trf24g.recv( @rf_rxbuf )
      RS232.str(@rf_rxbuf)
      RS232.tx(13)
      RS232.tx(10)
      outa[rfrx_led] := 1                               'Rf Rx LED Off

    if ina[rftx_btn] == 0
      outa[rftx_led] := 0                             'Rf Tx LED On
      trf24g.xmit( @rf_txbuf )                        'transmit
      outa[rftx_led] := 1                             'Rf Tx LED Off
      
    if ( cnt > heartbeat )
      heartbeat := cnt + 40_000_000
      
      !outa[status_led]
          
    tmp := RS232.rxcheck
    if ( tmp <> $FF )
      case tmp
        "?"    : ShowHelp


PUB ShowHelp
  RS232.str(string(13,10))
  RS232.str(string("TRF24G DEMO V1.0",13,10))
  RS232.str(string("----------------",13,10))
  RS232.str(string("? = Help Screen",13,10))

  
