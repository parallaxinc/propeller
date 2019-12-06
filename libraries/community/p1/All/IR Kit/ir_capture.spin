{{ ir_capture.spin

  Bob Belleville

  This object receives input from an IR remote(s).

  serial_terminal is to to capture input for a period
  of time and then dump the raw timing data to the
  pc.  mark space timing is given in microseconds.

  Connect an IR receiver module to a pin and set
    _irpin below.
  To use this run it with the Prop tool.
  Start a terminal emulator on the com port used by
    the Prop tool.  (115200 baud 8n1)
  Hit a key to start sampling.
  Use a capture file to accumulate data.
  Remember to stop the terminal when you want to
    use the Prop tool again.
  (realterm on sourceforge works as to others)
  
  capture format (data to terminal):
  >any text     - any note typed (cr(enter) to sample)
  1,n           - number of samples detected
  2,mark,space  - mark,space pair in usec
  3             - likely end of individual code

  This is a good tool to see what an advanced
  universal remote is sending when it send mulitple
  code to various devices.

  see readme.pdf for more documentaton

  2007/03/04 - essentially from scratch
  2007/03/10 - automatic sample stop on remotes quiet
               

}}
 
CON

                                'use 80MHz for max resolution
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        _irpin   = 0
        _ics     = 16_000       'min space to treat as between
                                '  codes (usec)
        _quiet   = 200_000      'remotes quite this long to end sample
                                '(count in spin loop see below (about 5sec) )                                
        _nmax    = 7000         'max longs in buffer (all most all memory)

        
VAR

        long   ibuff            'index buff
        long   buff[_nmax]      'store sample times
        
        long   stack[30]        'for sample running in cog
        byte   cog              'to stop sampler
        
OBJ

        term    : "serial_terminal"


PUB start | kbd, n, i, mark, space
  
  term.start(12)                'start the terminal

                                'allow time to get terminal
                                '  running
  repeat while term.getcnb == -1
    term.str(@msg0)
    waitcnt(40_000_000+cnt)     'message about 1/2 sec
                                'until keyboard
    
  term.str(@title)
  term.str(@msg1)

  repeat
                                'flush any terminal input
    repeat while term.getcnb <> -1
    term.out(">")               'invite keyboard input
    repeat
      kbd := term.getc          'get any keyboard (blocks)
      if kbd == 13              'enter key
        nl
        quit
      term.out(kbd)             'echo note
    ibuff~
    n~
    i~
    cog := cognew(sample,@stack) 'run sample full tilt
    repeat                      'wait for ir input to be quiet
      if n == ibuff             'ibuff not moving
        i++
        if i > _quiet
          cogstop(cog)
          quit
      else                      'still sampling wait more
        n := ibuff
        i~
    term.out("1")               'show sample count
    comma
    term.dec(n)
    nl
                                'convert all samples to mark
                                'and space in microseconds
                                'and output that data as pairs
    repeat i from 2 to ibuff step 2
      term.out("2")
      comma
      term.dec(mark :=(buff[i-1] - buff[i-2])/80)  'mark usec
      comma
      term.dec(space:=(buff[i  ]-buff[i-1])/80)    'space usec
      nl
      if space > _ics
        term.out("3")
        nl

        
PUB sample 
'' sample ir
'' has to be stopped by main loop !      

  repeat
    waitpeq(0,|<_irpin,0)          'wait for any ir on
    buff[ibuff++] := cnt
    waitpeq(|<_irpin, |<_irpin, 0) 'wait for space
    buff[ibuff++] := cnt
    if ibuff => _nmax              'don't overflow buffer
      ibuff -= 2
  
PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)

    
DAT

title   byte    "ir_capture",13,10,0
msg0    byte    "any key to begin",13,10,0
msg1    byte    "type any note and press return to sample",13,10,0

