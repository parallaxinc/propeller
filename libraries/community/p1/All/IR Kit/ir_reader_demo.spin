{{ ir_reader_demo.spin

  Bob Belleville

  This object receives input from an IR remote using
  object ir_reader_nec.spin or ir_reader_sony.spin.

  This is a good tool to use to build a table showing
  the key code for each button.

  see readme.pdf for more documentaton

  2007/03/01 - derived from ir_reader_nec_show.spen
               and tv_terminal_demo.spin
  2007/03/03 - generalized for nec and sony objects
               provide method to get device ID
               

}}
 
CON

                                'will NOT work at other speeds
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        _irrpin         = 0     'ir receiver module on this pin
        _device         = 0     'accept any device code
        _dlyrpt         = 6     'delay before acception code as repeat
        
VAR

OBJ

                                'select one rcvir and one term
                                
        rcvir   : "ir_reader_nec"
        'rcvir   : "ir_reader_sony"
        'rcvir   : "ir_reader_rc5"
        'term    : "tv_terminal"
        term    : "serial_terminal"


PUB start | keycode, x

  
  term.start(12)                'start the tv terminal
  term.str(@title)

  rcvir.init(_irrpin,_device,_dlyrpt,true)   'startup
  
  repeat
    keycode := rcvir.fifo_get   'try a get from fifo
    if keycode == -1            'empty try again
      next
    if keycode & $80
      term.out("R")             'show repeated code
      term.dec(keycode & $7F)
    else
      term.dec(keycode)         'show code
    sp
                                'device code is in low 16 bits
    term.hex(rcvir.fifo_get_lastvalid,8)
    nl
    {
    x := rcvir.fifo_debug       'show fifo head and tail pointers
    term.dec(x>>16 & $FFFF)     'fifo head
    term.out(":")
    term.dec(x & $FFFF)         'fifo tail
    nl
    }
    
    
PUB sp
  term.out(" ")
PUB nl
  term.out(13)
  term.out(10)
    
DAT

title   byte    "Push ir button for codes",13,13,0