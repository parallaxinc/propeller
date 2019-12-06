{{ memStick_check.spin

  Bob Belleville

  It is just a confidence check routine that patches
  chars from the pc keyboard to the 27937 and show
  the characters that it returns.

    http://www.parallax.com
  
  see readme.pdf for more documentaton

  2007/11/08 - from ummc work
          09 - try to get startup rationalized
               (can't figure a way)
          10 - make memStick_check and move on

  Note on initialization:

  There are two basic cases:

  During development the memStick may be on and
  running in which case the baud rate has been
  set and the command set shortened.

  The memStick may be just powered up.  In which
  case everything has to be adjusted.  There is no
  easy way to see when everything is ready to go.

  This makes life hard.
  
  To use:

  memStick pinout:
  1 Vss
  2 RTS#                 (output prop side)
  3 Vdd (5vdc)
  4 RXD receive data     (output prop side)
  5 TXD transmit data    (input prop side)
  6 CTS#                 (input prop side)
  7 NC
  8 RI# (low to resume)  (output prop side)
  
  TX              Transmit Data   --> 27937.4 (RXD)
  RTS             Request To Send --> 27937.6 (CTS)
  RX              Receive Data    <-- 27937.5 (TXD)
  CTS             Clear To Send   <-- 27937.2 (RTS)

  Connect all 4 lines through 4.7K resistors for
  safety.
  
  Compile and run this as a top object file.

  Start a terminal emulator on the com port
  used by the Propeller Tool.  Set 8N1 and
  115200 baud.  Open the port and press any
  key when "any key to begin" is shown.

}}
 
CON

                                'use 80MHz
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        _rxpin          = 0
        _txpin          = 1
        _rtspin         = 2
        _ctspin         = 3
        
        _rate1          = 9600             'memStick default baud rate

        _wl             = 40
        
        
VAR

        byte    w[_wl]          'misc buffer

          
OBJ
        term    : "serial_terminal"
        'fm      : "format_memory"
        mst     : "FullDuplexSerial"

PUB start | rc                  'check serial terminal version
  
  term.start(12)                'start the terminal (PC)

                                'allow time to get terminal
                                '  running
  repeat while (rc := term.getcnb) == -1
    term.str(@msg0)
    waitcnt(40_000_000+cnt)     'message about 1/2 sec
                                'until keyboard
  nl
  term.str(@title)

' just patch chars from serial terminal to memStick

  dira[_rtspin]~~               ' ~~ Set I/O pin to output direction 
  outa[_rtspin] := 0            ' LOW RTS: Take Vinculum Out Of Reset
                                ' (this is hooked to 27937 CTS input
                                '  so it is now free to send data)
  
                                'start communication to the memStick
  mst.start(_rxpin,_txpin,0,_rate1)

  ' can take up to 20 sec from here on a 1G stick
        
  repeat
    rc := term.getcnb           'input from pc keyboard
    if rc <> -1
      mst.tx(rc)
    rc := mst.rxcheck           'input from memStick
    if rc <> -1
      if rc == $0D              'send as cr/lf
        nl
        next
      if rc => " " and rc =< $7E
        term.putc(rc)           'show char
      else
        term.hex(rc,2)          'show hex value if not printable
        sp
        
      
' just check that the serial terminal is working
  repeat
    rc := term.getc
    term.putc(rc)


PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)

DAT

title   byte    "memStick_check",13,10,13,10,0
msg0    byte    "any key to start",13,10,0

        