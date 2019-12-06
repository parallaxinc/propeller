' Test communications with an FT232 UART device.

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000
  
OBJ
  uart : "usb-ft232"
  hc : "usb-fs-host"
  term : "Parallax Serial Terminal"

VAR
  byte  buf[1024]
  
PUB main
  term.Start(115200)

  repeat
    testUART
    waitcnt(cnt + clkfreq)

PRI testUART | count, i

  term.char(term#CS)

  if showError(\hc.Enumerate, string("Can't enumerate device"))
    return         

  if uart.Identify
    term.str(string("Identified as an FT232 device", term#NL))
  else
    term.str(string("Not a supported device!", term#NL))
    return

  if showError(\uart.Init, string("Error initializing device"))
    return

  term.str(string("Enter baud rate: "))
  uart.SetBaud(term.DecIn)
  
  term.str(string(term#NL, "Connected to UART. Forwarding characters to/from terminal.", term#NL))

  repeat while hc.GetPortConnection == hc#PORTC_FULL_SPEED

    count~
    repeat while term.RxCount
      buf[count++] := term.CharIn
    if count
      showError(\uart.Send(@buf, count), string("[TX Error]"))

    showError(count := \uart.Receive(@buf, 1024), string("[RX Error]"))
    if count > 0
      repeat i from 0 to count-1
        term.char(buf[i])
    
PRI showError(error, message) : bool
  if error < 0
    term.str(message)
    term.str(string(" (Error "))
    term.dec(error)
    term.str(string(")", term#NL))
    return 1
  return 0