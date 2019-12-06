{{ memStick_demo.spin

  Bob Belleville

  A demo for memStick.spin.

  See memStick_dev.spin for development and more
  interactive testing.
  
  Parallax "Memory Stick Datalogger" part #27937.

    http://www.parallax.com
  
  see readme.pdf for more documentaton

  2007/11/08 - from ummc work
          09 - try to get startup rationalized
               (can't figure a way)
          10 - make memStick_check and move on
          11 - correct bug in build command
               add most functions
          12 - consolidate gains; bytewise read
               change wait timing for slow
               response
               gbyte and all g* functions
          13 - change to FDS_sgf for CTS control
          15 - some cleanup; sync; fix seek
               demo code
          16 - revise read, clean up error handling
               misc bugs
          17 - more tests manageWB
          19 - documentation, more tests
          20 - create memStick.spin and memStick_demo.spin
               from memStick_dev.spin
          21 - hopefully final cleanup before release
  
  To use:

  memStick pinout:
                        i/o
  1 Vss
  2 RTS#                 i
  3 Vdd (5vdc)
  4 RXD receive data     i
  5 TXD transmit data    o
  6 CTS#                 o
  7 NC
  8 RI# (low to resume)  (output prop side)

  Propeller connections:
  
  TX   Transmit Data   --> 27937.4 (RXD)
  RTS  Request To Send --> 27937.6 (CTS)
  RX   Receive Data    <-- 27937.5 (TXD)
  CTS  Clear To Send   <-- 27937.2 (RTS)

  See the Con block for pin number constants.

  Connect all 4 lines through 4.7K resistors for
  safety.
  
  Compile and run this as a top object file.

  Start a terminal emulator on the com port
  used by the Propeller Tool.  Set 8N1 and
  115200 baud.  Open the port and press any
  key when "any key to begin" is shown.

  Summary of negative error codes:

  -1 eof (end of file) not really an error
  -2 some problem from the Vinculum monitor
     message is in rb
  -3 too long between input data
  -4 memStick not responding
  -5 no file open
  -6 field empty (from g* functions)

  
}}
 
CON

                                'use 80MHz
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        _rxpin          = 0
        _txpin          = 1
        _rtspin         = 2
        _ctspin         = 3
        
'        _rate1          = 9600     'memStick default baud rate
        _rate1          = 115200   'memStick modified baud rate

        _wchunk         = 512      'size of write buffer
        _wextra         = 32
        
        
VAR

        byte    cmd[32]          'a small buffer
        byte    demobuf[100]     'for demo method
        
        long    wbufptr          'pointer to wbuf
        byte    wbuf[_wchunk+_wextra]
        
          
OBJ
        term    : "serial_terminal"
        fm      : "format_memory"
        fs      : "memStick"

PUB start | rc, i, lastcnt
  
  term.start(12)                'start the terminal (PC)

                                'allow time to get terminal
                                '  running
  repeat while (rc := term.getcnb) == -1
    term.str(@msg0)
    waitcnt(40_000_000+cnt)     'message about 1/2 sec
                                'until keyboard
  nl
  term.str(@title)              'banner

                                'get everything going
  rc := fs.start(_rxpin,_txpin,_rtspin,_ctspin,_rate1,20)

  term.str(string("run demo1:"))
  nl
  demo1
  
  term.str(string("misc:"))
  nl
  sdec( string("no file "), fs.open(string("none.txt"),1) )
  sdec( string("try sync: "), fs.sync(2) )
  
  term.str(string("run demo2:"))
  nl
  demo2
  
  term.str(string("all done"))
  nl

PUB se(code)
  if code == -2
    term.str(fs.getErrorString)
    nl
  else
    case code
      -1 :
        term.str(string("eof"))
      -3 :
        term.str(string("time out between rcv'd chars"))
      -4 :
        term.str(string("memStick not responding"))
      -5 :
        term.str(string("no file open"))
      -6 :
        term.str(string("empty field from g*"))
          
PUB demo1 | rc, p, i

'' show many of the capabilities

{
  First create a file of 100 lines in .csv format:
  nnn,xxx,(yyy),,31415925<cr><lf> (25 total char)
  n 100..199
  x in hex
  y as a string
  an empty field
  a number which is like pi
}
  term.str(@fn1)
  nl
  se( fs.open(@fn1,2) )
  i := 100
  repeat 100
    p := @demobuf
    p := fm.pdec(p,i)
    p := fm.pcomma(p)  
    p := fm.phex(p,i,3)
    p := fm.pcomma(p)
    p := fm.pbyte(p,"(")  
    p := fm.pdec(p,i)
    p := fm.pbyte(p,")")  
    p := fm.pcomma(p)  
    p := fm.pcomma(p)
    p := fm.pstrz(p,string("31415926"))
    p := fm.peol(p,0)           'cr/lf type
    byte[p]~                    'needed for strsize only
    se( fs.write(@demobuf,strsize(@demobuf)) )
    i++
    term.putc(".")              'show progress

  nl
  se( fs.close )                   'must do on writes

{
  Show file length.
}
  rc := fs.getFileLength(@fn1)
  term.str(string("file length is: "))
  term.dec(rc)
  nl
{
  Now open for reading and show the first two lines.
}
  term.str(string("now read"))
  nl
  se( fs.open(@fn1,1) )
  repeat 2
    se( fs.gline(@demobuf) )       'demobuf is long enough
    term.str(@demobuf)
    nl
{
  Seek to line 33, read and decode the fields.
  The return code is the terminator (,nl,eof) or
  an error code which is negative.  See the code.
}
  term.str(string("now seek and show"))
  nl
  se( fs.seek(33*25) )
  rc := fs.gdec(@i)
  showdemo1(rc,i,0)  
  rc := fs.ghex(@i)
  showdemo1(rc,i,0)  
  rc := fs.gstr(@cmd)
  showdemo1(rc,@cmd,1)  
  rc := fs.gdec(@i)
  showdemo1(rc,i,0)  
  rc := fs.gdec(@i)
  showdemo1(rc,i,0)  
{
  Seek to line 98, read to end of file.
}
  term.str(string("read to end of file"))
  nl
  se( fs.seek(98*25) )
  repeat 4
    rc := fs.gline(@demobuf)
    if rc => 0
      term.str(@demobuf)
      nl
    else
      quit                      'end of file detected
{
  Delete file.
}
  term.str(string("delete file"))
  nl
  se( fs.deleteFile(@fn1) )
  term.str(string("done. (See code)"))
  nl    
    
PRI showdemo1(rc,i,type)
  term.str(string("return code: "))
  term.dec(rc)
  if type == 0
    term.str(string(" value: "))
    term.dec(i)
  else
    term.str(string(" string: "))
    term.str(i)
  nl

PUB demo2 | rc, p, i

'' demonstrate the use of manageWB

{
  First create a file of 1000 lines in .csv format:
  nnn,xxx,(yyy),,31415925<cr><lf> (25 total char)
  n 100..999
  x in hex
  y as a string
  an empty field
  a number which is like pi
}
  term.str(@fn2)
  nl
  se( fs.open(@fn2,2) )
  manageWB(0)                   'init write buffer
  i := 100
  repeat 1000
    wbufptr := fm.pdec(wbufptr, i)
    wbufptr := fm.pcomma(wbufptr)  
    wbufptr := fm.phex(wbufptr, i,3)
    wbufptr := fm.pcomma(wbufptr)
    wbufptr := fm.pbyte(wbufptr, "(")  
    wbufptr := fm.pdec(wbufptr, i)
    wbufptr := fm.pbyte(wbufptr, ")")  
    wbufptr := fm.pcomma(wbufptr)  
    wbufptr := fm.pcomma(wbufptr)
    wbufptr := fm.pstrz(wbufptr, string("31415926"))
    wbufptr := fm.peol(wbufptr, 0)     'cr/lf type
    se( manageWB(2) )           'write if needed only
    term.putc(".")
    i++
  nl
  se( manageWB(1) )             'flush any leftovers
  se( fs.close )                   'must do on writes

{
  Show file length.
}
  rc := fs.getFileLength(@fn2)
  term.str(string("file length is: "))
  term.dec(rc)
  nl
  term.str(string("done. (See code)"))
  nl    

PUB manageWB(mode) | rc, n
{{

  (copy this method to the module that
   will call memStick.spin)
   
  use this with format_memory to achieve
  much higher write speed

  set _wchunk to some large size say
  a block size 512 bytes
  
  set _wextra to the length of the longest
  line to be output via calls that put
  data into wbuf using wbufptr as the pointer

  call open in memStick.spin
  call init  (mode == 0)
  
  (repeat these two as needed)
  call format_memory to build a line
              or part of a line using
              wbufptr as the pointer
  call check (2)
  ....
  call flush (1) to get anything leftover
  call close in memStick.spin

  returns 0 if ok else negative error codes
  listed in the header comment

  see demo in memStick_dev.spin
}}
  case mode
    0 :                         'init
      wbufptr := @wbuf
      return 0
    1 :                         'flush
      n := wbufptr-@wbuf
      if n
        rc := fs.write(@wbuf,n)
        wbufptr := @wbuf
        return rc
    2 :                         'check/write if needed
      n := wbufptr-@wbuf
      if n > _wchunk
        rc := fs.write(@wbuf,_wchunk)
        if rc
          return rc             'some error
        n -= _wchunk            'leftover
        bytemove(@wbuf,@wbuf+_wchunk,n)
        wbufptr -= _wchunk
      return 0
      
        

PUB sdec(str,x)
  term.str(str)
  term.dec(x)
  nl  
PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)

DAT

title   byte    "memStick_demo",13,10,13,10,0
msg0    byte    "any key to start",13,10,0
fn1     byte    "myfile.csv",0
fn2     byte    "myfile2.csv",0

        