{{
Demo of Fast Propeller Communication on a single Propeller
}}
CON

  { ==[ CLOCK SET ]== }
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 6_250_000

  RX_pin = 12
  TX_pin = 11

OBJ

  DEBUG  : "FullDuplexSerial"    
  PCRX   : "PROP_COMM_RX"
  PCTX   : "PROP_COMM_TX" 

VAR

  LONG tx_stack[30]             ' probably be safe at 22 longs

PUB Main | rx_buff, i, seed, v

  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($D)
  DEBUG.str(string("If 'Warning' shows up, input does not match expected value",$D))

  cognew(tx, @tx_stack)         ' start transmit cog

'' -----------------------------------------------------
'' setup recieve cog

  rx_buff := PCRX.recieve(RX_pin)                       ' start RX cog
  seed := $9876_5432                                    ' make sure it is the same as tx cog

  REPEAT
    PCRX.waitrx_wd(100)                                 ' wait up to 100ms for information to be recieved.
    REPEAT i FROM 0 TO constant(PCRX#BUFFER_SIZE - 1)
      IF (?seed <> long[rx_buff][i])                    ' if information differs from what it is supposed to be
        DEBUG.str(string("Warning",$D)) 
    DEBUG.str(string("Buffer Good",$D))

PUB tx | tx_buff, i, seed
'' setup transmit cog
                        
  tx_buff := PCTX.send(TX_pin)                          ' start TX cog
  seed := $9876_5432                                    ' make sure it is the same as rx cog    
    
  REPEAT
    REPEAT i FROM 0 TO constant(PCTX#BUFFER_SIZE - 1)
      long[tx_buff][i] := ?seed                         ' fill buffer
    PCTX.transmitwait_wd(100)                           ' send buffer, then wait up to 100ms for it to complete
    waitcnt(120000 + cnt)                               ' give enough time for RX cog to "analize" data
  
  