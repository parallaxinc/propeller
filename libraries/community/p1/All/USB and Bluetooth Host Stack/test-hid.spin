' Quick HID device test. (Note that this is only for full-speed HID devices.
' Many HID devices are low-speed only.)

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000

OBJ
  hc : "usb-fs-host"
  term : "Parallax Serial Terminal"
  
VAR
  byte buf[64]

PUB main
  term.Start(115200)
        
  repeat
    testHID
    waitcnt(cnt + clkfreq)

PRI testHID | ifd, epd
                    
  if showError(\hc.Enumerate, string(term#CS, "Can't enumerate device"))
    return

  term.str(string(term#CS, "Found device "))
  term.hex(hc.VendorID, 4)
  term.char(":")
  term.hex(hc.ProductID, 4)
  term.str(string(term#NL, term#NL))
  
  if showError(\hc.Configure, string("Error configuring device"))
    return

  if not (ifd := hc.FindInterface(3))
    term.str(string(term#NL, "Device has no HID interfaces", term#NL))
    return

  ' First endpoint on the first HID interface
  epd := hc.NextEndpoint(ifd)  

  repeat while hc.GetPortConnection <> hc#PORTC_NO_DEVICE
    pollForHIDReports(epd)

PRI pollForHIDReports(epd) | retval

  retval := \hc.InterruptRead(epd, @buf, 64)
  
  if retval == hc#E_TIMEOUT
    ' No data available. Try again later.

    ' Show the button state continuously, but just flash the
    ' scroll wheel LEDs when we get a scroll packet.
    blinkenlights(buf[0], 0)

  elseif not showError(retval, string("Read Error"))
    ' Successful transfer

    term.char("[")
    term.dec(retval)
    term.str(string(" bytes] "))
    hexDump(@buf, retval)
    term.char(term#NL)

    blinkenlights(buf[0], ~buf[6])

PRI blinkenlights(buttons, dz) | leds                           
  ' Just for fun, map the mouse buttons and scroll wheel
  ' to the LEDs on the Propeller Demo Board. LEDs 0-5 are
  ' buttons, and 6-7 are scroll wheel.

  leds := buttons & $3F

  if dz > 0
    leds |= $40
  elseif dz < 0
    leds |= $80
  
  dira := $FF << 16
  outa := leds << 16
  
PRI hexDump(buffer, len)
  repeat while len--
    term.hex(BYTE[buffer++], 2)
    term.char(" ")        

PRI showError(error, message) : bool
  if error < 0
    term.str(message)
    term.str(string(" (Error "))
    term.dec(error)
    term.str(string(")", term#NL))
    return 1
  return 0

  