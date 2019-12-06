{{ ummc_term.spin

  Bob Belleville

  This object patches a pc terminal through to the
  Rogue Robotics SD card reader/writer.

  This is first step in using this device:

  http://www.roguerobotics.com/products/electronics/ummc
  
  see readme.pdf for more documentaton

  2007/03/11 - essentially from scratch
          27 - copy in termline for possible
               future use -- retest

  Compile and run this as a top object file.

  Connect the prop's tx pin through a 4.7K resistor
  to the ummc's rx pin and the prop's rx pin through
  a 4.7K resistor to the ummc's tx pin.  This way if
  there is any error neither device will be harmed.
               
  Start a terminal emulator on the com port
  used by the Propeller Tool.  Set 8N1 and
  115200 baud.  Open the port and press any
  key when "any key to begin" is shown.

  Try simple commands starting with 'v' to see if
  the connection is ok.

  Simple stuff will work but if the response from
  the ummc is greater than 16 bytes FullDuplexSerial's
  buffers will overflow and data will be lost.

  Move on to ummc_demo.
  
  Summary ummc commands (13 cr to execute, > ummc ready):
  
  >f                            return next free file handle (1..4)
  >o fh (r/w/a) /path           open
  >r fh [bytes [offset]]        up to 512
  >w fh [bytes]                 up to 512 next n bytes counted
  >i fh                         returns offset/length>
  >c fh                         close

  >s n value                    0 baud rate
                                  (9600,19200,38400,57600,115200) use (0,1,2,3,4)
                                  remains set between power cycles
                                1 write time out
                                  0 none else value * 10ms
  >m /path                      make directory (must start at root /)
  >e /path                      delete file (absolute path)
  >z                            system status rtn space> or error code>
  >q                            volumn query rtn used/total>
  >v                            rtn version number>                                  
}}
 
CON

                                'use 80MHz
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        _rxpin          = 0
        _txpin          = 1
        _rate           = 115200

                                  
VAR

  long  bPtr                    'working input buffer ptr
  byte  cmd[100]                'to build a command for the ummc

          
OBJ

  term  : "serial_terminal"
  ummc  : "FullDuplexSerial"


PUB start | kbd, in
  
  term.start(12)                       'start the terminal
  ummc.start(_rxpin,_txpin,0,_rate)    'start FDS uart to ummc

                                'allow time to get terminal
                                '  running
  repeat while term.getcnb == -1
    term.str(@msg0)
    waitcnt(40_000_000+cnt)     'message about 1/2 sec
                                'until keyboard
  
  term.str(@title)
  term.str(@msg1)

  bPtr := @cmd
  repeat
                                'input from the ummc is here
    if (in := ummc.rxcheck) <> -1
      if in < 32                'show any non printing this way
        term.out("(")
        term.dec(in)
        term.out(")")
      else
        term.out(in)            'show printing chars
      if in == 10               'newline
        nl

                                'input from pc terminal is buffered
                                'here and sent to the ummc on cr
                                'so that backspace and esc (line kill)
    if (kbd := term.getcnb) <> -1
      if kbd == 8                   'backspace
        if bPtr > @cmd              'can do
          bPtr--
          byte[bPtr]~
          nl                        'reshow on new line
          term.out(">")
          term.str(@cmd)
        next
      if kbd == 27                  'esc is start new line
        bPtr := @cmd
        byte[bPtr]~
        nl
        term.out(">")
        term.str(@cmd)
        next
      if kbd == 13                  'send cmd and reset
        byte[bPtr++] := 13
        byte[bPtr]~
        ummc.str(@cmd)              'send to ummc
        bPtr := @cmd                'reset
        nl
        next
      
      byte[bPtr++] := kbd           'save char
      term.out(kbd)                 'echo
       
{not actually used here but taken as a pattern
 for code above
         
PUB termline(bPtr,maxc,prompt) | startPtr, kbd
{{
  get a line of input from the terminal but
    not more than maxc bytes
  place bytes starting at bPtr
  use 'prompt' at prompt char
  end on enter key (13) and put it into the buffer
  zero terminate and return char count
}}
  startPtr := bPtr
  maxc--                        'leave room for null
  byte[bPtr]~
  term.out(prompt)
  repeat
    kbd := term.getc
    if kbd == 8                 'backspace
      if bPtr > startPtr
        bPtr--
        byte[bPtr]~
        nl                      'reshow on new line
        term.out(prompt)
        term.str(startPtr)
        next
    if kbd == 27                'esc - clear line
      bPtr := startPtr
      byte[bPtr]~
      nl
      term.out(prompt)
      term.str(bPtr)
      next
    if bPtr-startPtr < maxc
    if kbd < 32 and kbd <> 13
      next
    if bPtr-startPtr < maxc
      byte[bPtr++] := kbd       'append char
      byte[bPtr]~
      if kbd == 13
        return bPtr-startPtr
      term.out(kbd)             'echo

}


PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)


DAT

title   byte    "ummc_term",13,10,0
msg0    byte    "any key to begin",13,10,0
msg1    byte    "running",13,10,0
