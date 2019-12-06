{{ ir_tx_nec_demo.spin

  Bob Belleville

  Demo both transmitter and reader for NEC codes.
  
  see readme.pdf for more documentaton

  2007/03/07 - essentially from scratch
  2007/03/08 - fine tune
               

}}
 
CON

                                'use 80MHz for max resolution
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        _irrpin  = 0           'reader pin
        _irxpin  = 1           'transmitter pin
        
VAR

        
OBJ

        term    : "serial_terminal"
        irrx    : "ir_reader_nec"
        irtx    : "ir_tx_nec"


PUB start | kbd, rtn

  
  term.start(12)                'start the terminal
  irrx.init(0,0,2,false)        'start the ir reader
  irtx.start(1)                 'start the ir transmitter

                                'allow time to get terminal
                                '  running
  repeat while term.getcnb == -1
    term.str(@msg3)
    waitcnt(40_000_000+cnt)
    
  term.str(@title)
  term.str(@msg1)
  term.str(@msg2)

  repeat
    if (kbd := term.getcnb) <> -1
      kbd &= $7f                        'mask to 7 bits
      nl
      term.dec(kbd)                     'from terminal kbd via ir to ir rcv
      irtx.send(kbd<<16 | $a5a5)
    if (rtn := irrx.fifo_get) <> -1     'rcv with ir receiver and dequeue
      sp
      term.out("(")
      term.dec(rtn)                       'show keycode rcv'd
      comma
      term.hex(irrx.fifo_get_lastvalid,6) 'show full code rcv'd
      term.out(")")
    

PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)

    
DAT

title   byte    "ir_tx_nec_demo.spin",13,10,0
msg1    byte    "typed keys are sent ir and rcv'd ir",13,10,0
msg2    byte    "type away:",13,10,0  
msg3    byte    "any key to begin",13,10,0
