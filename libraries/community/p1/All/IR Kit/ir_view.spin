{{ ir_view.spin

  Bob Belleville

  This object receives input from an IR remote and dumps
  mark/space timing information to tv_terminal.

  This is a good tool to identify what an IR remote is
  sending.

  Can try to decode NEC type and Sony type codes.
  Set _decode below

  see readme.pdf for more documentaton

  2007/02/28 - derived from showbit_demo.spin
               and tv_terminal_demo.spin

}}
 
CON

        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000
        
        '_sml    = 200           'length of a valid start mark pulse
                                '  is at least this long
        _esl    = 200           'length of space at end of sequence
                                '  is at least this long
        _zth    = 37            'space less the _zth is 0 else 1 (NEC)
                                'mark less than _zth is 0 else 1 (Sony)

        _decode = 1             '0 - don't try to decode
                                '1 - for NEC type (constant mark)
                                '2 - for Sony type (constant space)

        irpin   = 0             'IR receiver module input pin
        
VAR

        long    buff[200]
        long    npairs

OBJ

        term    : "tv_terminal"


PUB start | i

  'start the tv terminal
  term.start(12)

  term.str(@title)
  
  repeat
    fill_buff                   'read mark/space timings to buff
    dump_buff                   'show them
    case _decode                'decode if wanted
      1: decode_nec
      2: decode_sony
    waitcnt(12_000_000+cnt)     'some remotes repeat comes too
                                '  quickly --- fiddle this

pub fill_buff | iron, iroff
{{
  count the time for mark/space pairs until
  a _esl length space terminates
  buff is filled and npairs is the 2x the
  number of pairs seen
}}
  dira[irpin]~                  'input on p0 (0 clear)
  npairs~
  longfill(@buff,0,200)
  repeat while ina[irpin]==1    'wait any mark
  repeat
    iron~
    iroff~
    repeat while ina[irpin]==0  'time mark
      iron++
      if iron > 10000           'this just balances mark/space counts
    
    repeat while ina[irpin]==1  'time space
      iroff++
      if iroff>_esl             'end of sequence
        buff[npairs++]:=iron
        buff[npairs++]:=iroff   'save last pair
        return
        
    buff[npairs++]:=iron
    buff[npairs++]:=iroff
    if npairs => 196
      npairs -= 2               'don't overfill the buffer

PUB dump_buff | i, maxp
{{
  show all the pairs but don't overflow the screen
}}
  term.dec(npairs/2)            'display pair count
  if npairs => 84
    maxp := 84
    term.str(@sfull)
  else
    maxp := npairs
  nl
  
  term.dec(buff[0])             'display start pair
    sp
  term.dec(buff[1])
  term.out(13)
  
  repeat i from 2 to maxp-1 step 8
    term.dec(buff[i])
    sp
    term.dec(buff[i+1])
    term.str(@gap)
    
    term.dec(buff[i+2])
    sp
    term.dec(buff[i+3])
    term.str(@gap)
    
    term.dec(buff[i+4])
    sp
    term.dec(buff[i+5])
    term.str(@gap)
    
    term.dec(buff[i+6])
    sp
    term.dec(buff[i+7])
    nl

PUB decode_nec | i, x, y
  x~                            'build long result
  y := 1
  repeat i from 2 to npairs-3 step 2
    if buff[i+1] < _zth
      term.out(".")
      y<<=1
    else
      term.out("1")
      x |= y
      y<<=1
  nl
  term.hex(x,8)
  nl
      
PUB decode_sony | i, x, y
  x~                            'build long result
  y := 1
  repeat i from 2 to npairs-1 step 2
    if buff[i] < _zth
      term.out(".")
      y<<=1
    else
      term.out("1")
      x |= y
      y<<=1
  nl
  term.hex(x,8)
  nl
      
PUB sp
  term.out(" ")
PUB nl
  term.out(13)

DAT

title   byte    "Push a remote button",13,13,0
sfull   byte    " some not shown",0
gap     byte    "   ",0