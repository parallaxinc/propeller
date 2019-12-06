{{

  Demo for the bluetooth-serial module.

  USB Bluetooth module attached on P0-P1,
  Television output starting at P12.
  Requires a 6 MHz crystal.

}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000
  
OBJ
  spp : "bluetooth-serial"
  term : "tv_text"

DAT

splashScreen
        byte $C, $85
        byte "       Bluetooth Serial Port Demo       "
        byte $C, $80
        byte "This is a simple Bluetooth stack and USB"
        byte "host for the Propeller microcontroller. "
        byte "The only external component is a common "
        byte "and inexpensive USB bluetooth adapter.  "
        byte "Requires 4 cogs and under 10 kB RAM.    "
        byte $D
        byte "Received text:", $D
        byte $D        
        byte $0

PUB main | tmp
  term.start(12)

  ' Start the Bluetooth stack, report errors
  if tmp := \spp.start
    term.str(string("Error "))
    term.dec(tmp)
    return

  term.str(@splashScreen)

  repeat
    tmp := spp.charIn

    ' Echo each character to the TV
    term.out(tmp)

    ' Verbosely echo it back over Bluetooth   
    spp.str(string("You pressed: "))
    spp.hex(tmp, 2)
    spp.str(string(" ("))
    spp.char(tmp)
    spp.str(string(")", $D))
