' A data integrity test, using an FT232 UART with its TX and RX pins shorted.
' This repeatedly sends a particular type of packet, and counts errors of
' each type. The terminal may be used to interactively change the packet
' characteristics.
'
' For debugging, this outputs trigger signals on several pins, for triggering
' logic analyzer traces on transmit, receive, or error.

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000

  PIN_TX_TRIGGER = 4
  PIN_RX_TRIGGER = 5
  PIN_ERR_TRIGGER = 6
  
  UI_UPDATE_HZ = 20
  
  NUM_ERROR_BUCKETS = 8

  ' Number of times to poll for received data during each test.
  RX_POLL_ROUNDS = 500
  
  E_TOO_SHORT = -1
  E_TOO_LONG  = -2
  E_BAD_DATA  = -3
  
OBJ
  uart : "usb-ft232"
  hc : "usb-fs-host"
  term : "Parallax Serial Terminal"

VAR
  byte  buf[1024]

  ' Parameters
  byte  pattern
  word  burstSize
  long  baudRate
  long  debug

  long  testCount
  long  errCounts[NUM_ERROR_BUCKETS]
  
PUB main | uiPeriod, nextUpdate
  term.Start(115200)
  baudRate := 1000000
  burstSize := 16

  dira[PIN_TX_TRIGGER]~~
  dira[PIN_RX_TRIGGER]~~
  dira[PIN_ERR_TRIGGER]~~

  uiPeriod := clkfreq / UI_UPDATE_HZ
  nextUpdate := cnt + uiPeriod
  
  repeat
    if not showError(\deviceInit, string("Can't initialize device"))
      term.str(@uiTemplate)
      repeat while hc.GetPortConnection == hc#PORTC_FULL_SPEED

        if (cnt - nextUpdate) > 0
          nextUpdate += uiPeriod
          uiUpdate

        collectErrors(\runTest)

    waitcnt(cnt + clkfreq)

PRI deviceInit
  hc.Enumerate
  uart.Init

PRI showError(error, message) : bool
  if error < 0
    term.str(message)
    term.str(string(" (Error "))
    term.dec(error)
    term.str(string(")", term#NL))
    return 1
  return 0

DAT
uiTemplate    byte      term#CS
              byte      "FT232 Loopback Test"

              byte      term#HM, term#PX, 30, "Test #"
          
              byte      term#PC, 1, 2, "Settings"
              byte      term#PC, 4, 3, "Baud Rate: [Q/A]"
              byte      term#PC, 3, 4, "Burst Size: [W/S]"
              byte      term#PC, 6, 5, "Pattern: [E/D]"
              byte      term#PC, 5, 6, "HC Debug: [R/F]"

              byte      term#PC, 30, 2, "Errors"
              byte      term#PC, 34, 3, "Success:"
              byte      term#PC, 38, 4, "CRC:"
              byte      term#PC, 38, 5, "PID:"
              byte      term#PC, 34, 6, "Timeout:"
              byte      term#PC, 33, 7, "Bad Data:"
              byte      term#PC, 32, 8, "Too Short:"
              byte      term#PC, 33, 9, "Too Long:"
              byte      term#PC, 36, 10, "Other:"

              byte      term#PC, 1, 11, "Last bad data buffer:"
              byte      term#PC, 1, 16, "Error rate chart:"
              
              byte      0
            
PUB uiUpdate | i
  repeat while term.rxCount
    longfill(@errCounts, 0, NUM_ERROR_BUCKETS)
    testCount~
    
    case term.charIn
      "q": baudRate := (baudRate + 100) <# 1000000
      "a": baudRate := (baudRate - 100) #> 100
      "w": burstSize := (burstSize + 1) <# 1024
      "s": burstSize := (burstSize - 1) #> 1
      "e": pattern++
      "d": pattern--
      "r": debug++
      "f": debug--

      "Q": baudRate := (baudRate + 1000) <# 1000000
      "A": baudRate := (baudRate - 1000) #> 100
      "W": burstSize := (burstSize + 10) <# 1024
      "S": burstSize := (burstSize - 10) #> 1
      "E": pattern += $10
      "D": pattern -= $10

      other: term.str(@uiTemplate)
      
  term.str(string(term#HM, term#PX, 36))
  term.dec(testCount)

  term.str(string("      ", term#PC, 21, 3))
  term.dec(baudRate)
  term.str(string("  ", term#PC, 21, 4))
  term.dec(burstSize)
  term.str(string("  ", term#PC, 21, 5))
  term.hex(pattern, 2)
  term.str(string("  ", term#PC, 21, 6))
  term.dec(debug)
  term.str(string("  "))
  
  ' Update error buckets

  repeat i from 0 to NUM_ERROR_BUCKETS - 1
    term.position(43, 3 + i)
    term.dec(errCounts[i])
    term.str(string("    "))

    term.position(50, 3 + i)
    term.char("(")
    term.dec(errCounts[i] * 100/ testCount)
    term.str(string("%)", term#CE))
    
  ' Update error rate bargraph chart.
  ' Each row represents one burst size, bar length is error rate.
  term.position(1, 17 + ($f & (burstSize - 1)))
  term.dec(burstSize)
  term.str(string(" "))
  term.positionX(6)
  term.chars("#", (testCount - errCounts[0]) * 60 / testCount)
  term.char(term#CE)

PUB showBadData | i
  ' Dump out data buffer
  term.position(0, 12)
  repeat i from 0 to burstSize - 1
    term.char(" ")
    term.hex(buf[i], 2)
  term.char(term#CE)

PUB runTest | len, i
  hc.SetDebugFlags(debug)
  uart.SetBaud(baudRate)

  bytefill(@buf, pattern, burstSize)
  outa[PIN_TX_TRIGGER]~~
  uart.Send(@buf, burstSize)
  outa[PIN_TX_TRIGGER]~
  
  len~
  repeat RX_POLL_ROUNDS

    outa[PIN_RX_TRIGGER]~~
    len += uart.Receive(@buf + len, burstSize - len)
    outa[PIN_RX_TRIGGER]~

    if len == burstSize
      repeat i from 0 to burstSize - 1
        if buf[i] <> pattern
          showBadData
          abort E_BAD_DATA 
      return
        
  if len < burstSize
    abort E_TOO_SHORT
  elseif len > burstSize
    abort E_TOO_LONG

  
PUB collectErrors(r)
  if r <> hc#E_SUCCESS
    outa[PIN_ERR_TRIGGER]~~
    outa[PIN_RX_TRIGGER]~
    outa[PIN_TX_TRIGGER]~
    outa[PIN_ERR_TRIGGER]~

  testCount++
  case r
    hc#E_SUCCESS: errCounts[0]++
    hc#E_CRC: errCounts[1]++
    hc#E_PID: errCounts[2]++
    hc#E_TIMEOUT: errCounts[3]++
    E_BAD_DATA: errCounts[4]++
    E_TOO_SHORT: errCounts[5]++
    E_TOO_LONG: errCounts[6]++
    other: errCounts[7]++
