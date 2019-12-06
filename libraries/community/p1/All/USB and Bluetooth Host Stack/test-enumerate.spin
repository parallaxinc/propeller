CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000

OBJ
  hc : "usb-fs-host"
  term : "Parallax Serial Terminal"
  
PUB main
  term.Start(115200)

  repeat
    testEnumerate
    waitcnt(cnt + clkfreq)

PRI testEnumerate
                    
  if showError(\hc.Enumerate, string(term#CS, "Can't enumerate device"))
    return         

  term.str(string(term#CS, "Found device "))
  term.hex(hc.VendorID, 4)
  term.char(":")
  term.hex(hc.ProductID, 4)

  term.str(string(term#NL, term#NL, "Raw device descriptor:", term#NL))
  hexDump(hc.DeviceDescriptor, hc#DEVDESC_LEN)

  term.str(string(term#NL, term#NL, "Device configuration:", term#NL))
  dumpConfig
  
  if showError(\hc.Configure, string("Error configuring device"))
    return

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

PRI dumpConfig | ifd, epd

  ifd := hc.FirstInterface
  repeat while ifd
  
    term.str(string("  Interface ptr="))
    term.hex(ifd, 4)
    term.str(string(" number="))
    term.hex(BYTE[ifd + hc#IFDESC_bInterfaceNumber], 2)
    term.str(string(" alt="))
    term.hex(BYTE[ifd + hc#IFDESC_bAlternateSetting], 2)
    term.str(string(" class="))
    term.hex(BYTE[ifd + hc#IFDESC_bInterfaceClass], 2)
    term.str(string(" subclass="))
    term.hex(BYTE[ifd + hc#IFDESC_bInterfaceSubclass], 2)
    term.char(term#NL)

      epd := ifd
      repeat while epd := hc.NextEndpoint(epd)
        
        term.str(string("    Endpoint ptr="))
        term.hex(epd, 4)
        term.str(string(" address="))
        term.hex(BYTE[epd + hc#EPDESC_bEndpointAddress], 2)
        term.str(string(" maxpacket="))
        term.hex(hc.UWORD(epd + hc#EPDESC_wMaxPacketSize), 4)
        term.char(term#NL)

    ifd := hc.NextInterface(ifd)
     