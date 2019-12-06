{{ ir_view_serial.spin

  Bob Belleville

  This object receives input from an IR remote and dumps
  mark/space timing information to the serial port.

  This is a good tool to identify what an IR remote is
  sending.

  Decodes NEC type and Sony type codes automatically.
  In some cases RC5 bi-phase codes can be correctly
  decoded --- but it is not certain.
  Valid RC5 codes have 14 bits and have code
    110d dddd kkkk kk00 or
    111d dddd kkkk kk00
  RC5x codes have 15 bits and have code 
    110d dddd kkkk kkk0 or
    111d dddd kkkk kkk0
  where d are device address bits (5)
  and   k are keycodes (6 or 7)
  RC6 code are not detected or decoded.

  Connect an IR receiver module to a pin and set
    irpin below.
  To use this run it with the Prop tool.
  Start a terminal emulator on the com port used by
    the Prop tool.  (115200 baud 8n1)
  Hit a key to start sampling.
  Use a capture file to accumulate codes.
  Remember to stop the terminal when you want to
    use the Prop tool again.
  (realterm on sourceforge works as to others)
  
  see readme.pdf for more documentaton

  2007/02/28 - derived from showbit_demo.spin
               and tv_terminal_demo.spin
  2007/03/08 - convert for serial terminal
  2007/03/09 - auto decode
  2007/03/10 - rc5 decode (sometimes)               

}}
 
CON
                                'will only run at this speed - sorry
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000
        
        _quiet   = 10000        'ir completely quiet after codes/repeats
        _sbl     = 85           'mark of an extra start burst pair is at
                                '  least this long
        _sac     = 200          'space after code at least this long

        irpin    = 0            'IR receiver module input pin

        _maxbuff = 600          'number of marks and spaces max
        
VAR

        long    buff[_maxbuff]
        long    npairs
        byte    decode_mode

OBJ

        term    : "serial_terminal"


PUB start | i, kbd

  'start the terminal
  term.start(12)

                                'allow time to get terminal
                                '  running
  repeat while term.getcnb == -1
    term.str(@msg3)
    waitcnt(40_000_000+cnt)
    
  term.str(@title)
  
  repeat
                                'for future expansion - not now used
    if (kbd := term.getcnb) <> -1
      term.out(kbd)
      next
    fill_buff                   'read mark/space timings to buff
    dump_buff                   'show them and decode them

pub fill_buff | iron, iroff
{{
  count the time for mark/space pairs until
  a _esl length space terminates
  buff is filled and npairs is the 2x the
  number of pairs seen
}}
  dira[irpin]~                  'input on p0 (0 clear)
  npairs~
  'longfill(@buff,0,_maxbuff)
  repeat while ina[irpin]==1    'wait any mark
  repeat
    iron~
    iroff~
    repeat while ina[irpin]==0  'time mark
      iron++
      if iron > 10000           'this just balances mark/space counts
    
    repeat while ina[irpin]==1  'time space
      iroff++
      if iroff>_quiet           'end of sequence
        buff[npairs++]:=iron
        buff[npairs++]:=iroff   'save last pair
        return
        
    buff[npairs++]:=iron
    buff[npairs++]:=iroff
    if npairs => _maxbuff-2
      npairs -= 2               'don't overfill the buffer

PUB dump_buff | i, j, sdata, edata
''  show pairs

  term.str(@msg4)               'show pair count
  term.dec(npairs)
  nl
  i~
  j~
  sdata~                        'data bits start at this index
  repeat
    if i => npairs              'done?
      nl
      quit
    if buff[i] > _sbl           'most likely a start burst pair
      nl
      j := 3
      sdata += 2
    term.dec(buff[i++])         'mark
    sp
    term.dec(buff[i++])         'space
    term.str(@gap)
    j++
    if buff[i-1] > _sac         'guess that single code ends
      nl
      edata := i
      decode(sdata,edata)       'decode if possible
      sdata := edata
      j~
    if j => 4                   '4 to line max
      nl
      j~

PUB decode(s,e) | i, mk, spa, mnmk, mxmk, mnsp, mxsp, code, mask, nbits, x
''  check buff to see what this might be
  if e-s =< 8
    term.str(@msg5)
    return
  mnmk := mxmk := buff[s]
  mnsp := mxsp := buff[s+1]

  ' find the min and max of the marks and spaces
  
  repeat i from s+2 to e-4 step 2
    mk  := buff[i]
    spa := buff[i+1]
    if mnmk > mk
      mnmk := mk
    if mxmk < mk
      mxmk := mk
    if mnsp > spa
      mnsp := spa
    if mxsp < spa
      mxsp := spa
                                'bi-phase changes both

  {caution this won't always work
  
   if the actual code word has long pulses only in the mark
   or only in the space it won't be recognized here and will
   be taken up (incorrectly) below

   we really have to know what code we have to
   accurately do bi-phase
  }
                                  
  if mxmk-mnmk > 10 and mxsp-mnsp > 10
    mask := $8000               'assume msb comes first
    code~                       'build up code word
    nbits~                      'count bit
    x := (mxsp-mnsp)>>1 + mnsp  'find a long/short threshold
                                'create the code word
    i := s
    if buff[i] > x
      term.str(@msg6)           'not rc5 or rc5x - not decoded here
      return
    repeat
      if i => e
        term.str(@msg10)
        term.hex(code,8)
        term.out("(")
        term.dec(nbits)
        term.out(")")
        nl
        quit
      if i & 1                  'odd i's are spaces, even marks
        nbits++
        mask >>= 1
        if buff[i] > x
          i++
        else
          i += 2
      else
        nbits++
        code |= mask
        mask >>= 1
        if buff[i] > x
          i++
        else
          i += 2
    return
                                'variable space
  if mxsp-mnsp > 10
    term.str(@msg7)
    mask := 1                   'assume lsb comes first
    code~                       'build up code word
    nbits~                      'count bit
    x := (mxsp-mnsp)>>1 + mnsp  'find a 0/1 threshold
                                'create the code word
    repeat i from s to e-4 step 2
      if buff[i+1] > x
        code |= mask
      nbits++
      mask <<= 1
    term.hex(code,8)            'show it with bit count
    term.out("(")
    term.dec(nbits)
    term.out(")")
    nl
    return
                                'variable mark (count last mark as data)
  if mxmk-mnmk > 10
    term.str(@msg8)
    mask := 1
    code~
    nbits~
    x := (mxmk-mnmk)>>1 + mnsp
    repeat i from s to e-2 step 2
      if buff[i] > x
        code |= mask
      nbits++
      mask <<= 1
    term.hex(code,8)
    term.out("(")
    term.dec(nbits)
    term.out(")")
    nl
    return
  else                          'neither varies all zero or 1
    term.str(@msg9)
    return  
          
PUB sp
  term.out(" ")
PUB nl
  term.out(13)
  term.out(10)

DAT

title   byte    "Push a remote button",13,10,13,10,0
gap     byte    "   ",0
msg3    byte    "any key to begin",13,10,0
msg4    byte    "total samples:  ",0
msg5    byte    "repeat (?)",13,10,0
msg6    byte    "bi-phase code: (not decoded)",13,10,0
msg7    byte    "variable space code: ",0
msg8    byte    "variable mark code: ",0
msg9    byte    "may be all 0 or all 1",13,10,0
msg10   byte    "rc5(14bit) or rc5x(15bit): ",0
