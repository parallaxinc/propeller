'' ============================================================================
'' Driver code for Nordic nRF2401      V1.05                A.Marincak Jan 2008
'' ============================================================================
''
''  Version 1.05
''    - xmit, recv, and setmode functions have semaphore wrappers
''    - semaphore ID returned by init() function
''
'' ============================================================================
''
'' TRF24G Pins ...
''
''      CS       - in       -> Device Config Select
''      CE       - in       -> Device RF IO Select
''      CLK1     - in       -> Clock for Shock Burst Tx & Rx
''      DR1      - out      -> Device Data 1 Ready Flag
''      DATA     - in/out   -> Shock Burst Tx & Rx Data in / out
''      CLK2     - in       -> Clock for 2nd receiver      (NOT USED)
''      DR2      - out      -> Device Data 2 Ready Flag    (NOT USED)
''      DOUT2    - out      -> Data channel 2              (NOT USED)
''
'' This driver assumes that the TRF24G module will be used as a tranceiver,
'' using the shockburst mode. A dual channel receiver mode is available,
'' but it is not implemented here.
''
'' Timing assumes 80Mhz operation.
''
'' PROPELLER RESOURCES used:
''
''      5 IO pins to connect to the TRF24G
''      1 system semaphore to serialize access
''
'' ============================================================================
''
''
''  Public Functions
''
''    init( p_cs, p_ce, p_clk, p_dr, p_dat )
''
''        Defines the propeller pins used to communicate with the TRF24G, note
''        only 5 pins are used. The others (CLK2, DR2, DOUT2) are not used by
''        this driver. They are used when setting the TRF24G to dual receiver
''        mode.
''
''              p_cs  = Propeller pin connected to the TRF24G CS pin
''              p_ce  = Propeller pin connected to the TRF24G CE pin
''              p_clk = Propeller pin connected to the TRF24G CLK pin
''              p_dr  = Propeller pin connected to the TRF24G DR1 pin
''              p_dat = Propeller pin connected to the TRF24G DATA pin
''
''        Returns the ID of the semaphore created to serialize access to the
''                device. The xmit (transmit), recv (receive), and setmode
''                functions automatically use this semaphore, the user does
''                not need to make any special arrangements. Another cog will
''                block until the semaphore is free, then proceed.
''
''
''    configure( cfg_ptr )
''
''        This write the configuration block to the TRF24G. This is an array
''        of 15 bytes. You simply pass the pointer to the configuration block
''        and this function clocks it in.
''
''        Leaves the device in RX Standyby mode (i.e. listening for incoming
''        RF packets.
''
''        Sample Configuration Block: (see Nordic documentation for full info)
''
''          $C8  ' Data2 width (bits) excluding addr & crc (25 bytes)
''          $C8  ' Data1 width (bits) excluding addr & crc (25 bytes)
''          $AA  ' Channel #2 - Addr Byte 1 (MSB)
''          $55  '            - Addr Byte 2
''          $BB  '            - Addr Byte 3
''          $CC  '            - Addr Byte 4
''          $01  '            - Addr Byte 5
''          $AA  ' Channel #1 - Addr Byte 1 (MSB)
''          $55  '            - Addr Byte 2
''          $BB  '            - Addr Byte 3
''          $CC  '            - Addr Byte 4
''          $01  '            - Addr Byte 5
''          $A3  ' 7-2:address width(40), 1:CRC Mode(16), 0:CRC enable(on)
''          $6F  ' 7:Dual Ch mode(off), 6:ShockBurst mode(on), 
''                 5:1m/250k bps(1mbps), 4-2:xtal sel(16Mhz), 1-0:rf Power(hi)
''          $05  ' 7-1:RF channel(2), 0:RX enable(on=Rx mode)
''
''          The above configures the device to respond on RF Channel 2 at
''          address AA55BBCC01 (40 bit addressing) using 16 bit CRC and
''          1 Mbps shockburst mode. Transmit RF is at full power. Data
''          payload is 25 bytes per packet.
''
''
''    xmit( dat_ptr )
''
''        This function transmits  a data packet. It always transmits a full
''        load as per configuration. It will automatically switch to transmit
''        mode (RF_MODE_TXON) to send the data. When completed sending data to
''        the TRF24G it will switch the module to recieve mode (RF_MODE_RXON)
''        and leave it in recieve mode.
''
''              dat_ptr = A pointer to the transmit buffer which contains the
''                        address to transmit to and the data itself. For 
''                        example using the sample configuration above. The
''                        address is 5 bytes and the payload is 25 bytes.
''                        Therefore the buffer MUST be 30 bytes (or more, but
''                        only the 1st 30 bytes are used). Format:
''
''                          AAAAADDDDDDDDDDDDDDDDDDDDDDDDD
''                              A = address (5 bytes)
''                              D = data (25 bytes)
''
''
''    recv( dat_ptr )
''
''        This function receives data from the TRF24G. If necessary it will
''        switch to recieve mode (RF_MODE_RXON) to get the data. When done it
''        will leave it in the recieve mode.
''
''              dat_ptr = A pointer to the receive buffer wich will receive
''                        RF payload only. This will always be exactly the 
''                        number of bytes specified in the configuration.
''
''
''
''    setmode( mode )
''
''        This function is used to change the operating mode of the TRF24G. It
''        is mostly useful to turn off the device for power saving by putting
''        the device into a standby mode. In normal operation one would put
''        the device in recieve mode (RF_MODE_RXON) and wait for incomming
''        packets.
''
'' ============================================================================
''
''  General Operation
''
''    Quite simple
''
''      1) call the init() function to identify the pins
''      2) call the configure() function to set up the device
''      3) call setmode(RF_MODE_RXON) to listen for RF packets.
''
''          Once set up there is not much to do. Simply call xmit() or recv().
''          The functions always leave the TRF24G in the recieve mode so you
''          can just poll the DR1 pin for incoming data packets and transmit
''          at any time.
''
''          Monitor the state ot the DR1 pin, if it goes high there is data in
''          the TRF24G's buffer ready to be read in ... call recv() to get the
''          data.
''
''          You can transmit at any time by filling the transmit buffer with
''          the destination address and the data to transmit. Call xmit() to
''          send the data. When done the function will return with the TRF24G
''          in the receive mode (RF_MODE_RXON).
''
'' ============================================================================


CON
  dly_sb_active     = 16160         'standby to active time 202uS (at 80Mhz)

  RF_MODE_RXSBY     = 0             'current rf_mode definitions
  RF_MODE_RXON      = 1
  RF_MODE_TXSBY     = 2
  RF_MODE_TXON      = 3

  RF_SIZE_ADDR      = 5
  RF_SIZE_CRC       = 2
  RF_SIZE_PAYLOAD   = 25
  RF_SIZE_XMIT      = 30            'size of address + size of payload


VAR
  byte  pin_CS, pin_CE, pin_CLK1, pin_DR1, pin_DATA
  byte  io_var
  byte  rf_mode
  byte  rf_sem
  byte  sem_set


PUB init( p_cs, p_ce, p_clk, p_dr, p_dat )
''
''  Initializes the Propeller for I/O with a Nordic nRF2401 by identifying the
''  pins connected to the TRF24G. The names of the input parameters reflect the
''  pin names of the TRF24G.
''
''  returns > -1 = OK
''            -1 = sem error

  pin_CS    := p_cs
  pin_CE    := p_ce 
  pin_CLK1  := p_clk 
  pin_DR1   := p_dr 
  pin_DATA  := p_dat 

  dira[pin_CS]   := 1             'output
  outa[pin_CS]   := 0             'set pin low
  
  dira[pin_CE]   := 1             'output
  outa[pin_CE]   := 0             'set pin low
  
  dira[pin_CLK1] := 1             'output
  outa[pin_CLK1] := 0             'set pin low
  
  dira[pin_DR1]  := 0             'input
  
  dira[pin_DATA] := 0             'input (to start)

  rf_sem := locknew
  sem_set := 0

  return rf_sem


PUB configure( cfg_ptr ): err | cfg_byt, cfg_bit, byt, bit
''
''  cfg_ptr     - pointer to byte array with configuration data
''                (15 bytes)
''
''  returns 0 = OK   else Error code
''
''      Leaves TRF24G  RF_MODE_RXSBY
''         CLK1    = LO
''         CE      = LO
''         CS      = LO
''
  outa[pin_CE] := 0             'CE low
  outa[pin_CS] := 1             'CS high

  waitcnt(dly_sb_active + cnt)  'wait for standby to active time
  
  dira[pin_DATA] := 1           'DATA set to output

  cfg_byt := 0
  
  repeat 15                     'repeat for 15 configuration bytes
    bit := $80
    byt := byte[cfg_ptr++] 

    repeat 8                    'repeat for 8 bits per byte
      if byt & bit
        outa[pin_DATA] := 1
      else
        outa[pin_DATA] := 0             

      outa[pin_CLK1] := 1
      
      bit >>= 1
      
      outa[pin_CLK1] := 0

  outa[pin_CS] := 0

  outa[pin_DATA] := 0
  
  dira[pin_DATA] := 0         'DATA set to input
  rf_mode := RF_MODE_RXSBY  

  io_var :=  byt

  err := 0
  return err


PUB xmit( dat_ptr ) | dat_bit, byt, bit
''  Write Packet To the TRF24G. Data is clocked out on the rising edges. The
''  pointer must point to a  buffer that contains the full address of the
''  intended recipient of the data followed immediately by the data itself. If
''  there is less data than the configured payload size, it will still send
''  the configured number of bytes (payload number of bytes) so the 
''  trailing data will be whatever is left over in the buffer (junk).
''
''  <!> NOTE : The transmit buffer is  *ALWAYS*  RF_SIZE_XMIT  + address size
''             bytes long. The first bytes are ALWAYS the address bytes.
''
''      Leaves TRF24G  = RX mode and active
''         CLK1    = LO
''         DATA    = LO
''         CE      = HI
''         CS      = LO
''
''      Data is shifted out MSB first (not an arbitrary choice).

  repeat until not lockset( rf_sem )
  sem_set := 1
  
  if SetMode( RF_MODE_TXON ) 
    repeat RF_SIZE_XMIT

      bit := $80
      byt := byte[dat_ptr++]

      repeat 8
        if byt & bit
          outa[pin_DATA] := 1
        else
          outa[pin_DATA] := 0

        outa[pin_CLK1] := 1
        
        bit >>= 1
        
        outa[pin_CLK1] := 0
            
    bit >>= 1                   ' just used as a short delay here
        
    outa[pin_DATA] := 0
    outa[pin_CE] := 0

    waitcnt(dly_sb_active + cnt) 'wait for transmit

    SetMode( RF_MODE_RXON )

  lockclr( rf_sem )
  sem_set := 0
  

PUB recv( dat_ptr ) : dat_cnt | dat_byt
''  Data is clocked in on falling edges, MSB first. The buffer pointed to must
''  be Payload size (RF_SIZE_XMIT) even if you know there will be less data.
''
''      Leaves TRF24G  = RX mode and active
''         CLK1    = LO
''         DATA    = LO
''         CE      = HI
''         CS      = LO
''
''      Returns the number of bytes read.

  repeat until not lockset( rf_sem )
  sem_set := 1

  dat_cnt := 0
  
  if SetMode( RF_MODE_RXON )
  
    repeat while ina[pin_DR1] == 1
      dat_byt := 0
    
      repeat 8

        dat_byt <<= 1
      
        outa[pin_CLK1] := 1

        if ina[pin_DATA] == 1
          dat_byt |= 1

        outa[pin_CLK1] := 0

      byte[dat_ptr++] := dat_byt
      dat_cnt++

  byte[dat_ptr] := 0

  lockclr( rf_sem )
  sem_set :=0
  
  return dat_cnt


PUB setmode( mode ) : err
''
''  Sets the TRF24G to the given mode.
''
''      Input mode is one of: 
''             RF_MODE_RXSBY    - standby low power mode, not listening
''             RF_MODE_RXON
''             RF_MODE_TXSBY    - standby low power mode
''             RF_MODE_TXON
''
''      Returns 1 = OK
''              0 = Error
''
''      Leaves   CS = LO    - programming off
''               CE = Hi/Lo - according to active / standby requirement
''              CLK = LO    - just convention
''             DATA = RD/WR - according to RX/TX mode requirement

  if sem_set == 0
    repeat until not lockset( rf_sem )

  err := 1

  if mode <> rf_mode
    case mode
      RF_MODE_RXSBY, RF_MODE_RXON:
        if rf_mode > RF_MODE_RXON
          iomode( 1 )                   'RX
        if mode == RF_MODE_RXSBY
          outa[pin_CE] := 0             'CE low
        if mode == RF_MODE_RXON
          outa[pin_CE] := 1             'CE high
          waitcnt(dly_sb_active + cnt)  'wait for standby to active time

      RF_MODE_TXSBY, RF_MODE_TXON:
        if rf_mode < RF_MODE_TXSBY
          iomode( 0 )                   'TX
        if mode == RF_MODE_TXSBY
          outa[pin_CE] := 0             'CE low
        if mode == RF_MODE_TXON
          outa[pin_CE] := 1             'CE high
          waitcnt(dly_sb_active + cnt)  'wait for standby to active time

      OTHER:
        err := 0

  if err == 1
    rf_mode := mode  

  if sem_set == 0
    lockclr( rf_sem )
  
  return err


PRI iomode( rx ) | cfg, bit
''  returns with TRF24G in stanby rx or tx mode as required
''
''  input rx = 1 for RX   0 for TX
''
''  Leaves   CS = LO    - programming off
''           CE = LO    - RF IO off
''           CLK = LO
''           DATA = RD/WR as required for RX/TX mode

  outa[pin_CE] := 0             'CE low
  outa[pin_CS] := 0             'CS low
  dira[pin_DATA] := 1           'DATA set to output

  outa[pin_CS] := 1             'CS high to program the TRF24G

  if rx == 1
    cfg := io_var | $01
  else
    cfg := io_var & $FE

  waitcnt(dly_sb_active + cnt)  'wait for standby to active time

  bit := $80

  repeat 8
    if cfg & bit
      outa[pin_DATA] := 1
    else
      outa[pin_DATA] := 0

    outa[pin_CLK1] := 1
    
    bit >>= 1

    outa[pin_CLK1] := 0

  outa[pin_DATA] := 0
  outa[pin_CS] := 0

  if rx == 1
    dira[pin_DATA] := 0         'DATA set to input
    rf_mode := RF_MODE_RXSBY  
  else
    dira[pin_DATA] := 1         'DATA set to output
    rf_mode := RF_MODE_TXSBY
  
