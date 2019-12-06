{{ memStick_demo.spin

  Bob Belleville

  This object is used to develop and test code that
  will be split off into a separate memStick.spin
  module.

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
        
'        _rate1          = 9600             'memStick default baud rate
        _rate1          = 115200           'memStick modified baud rate

        _sl             = 500
        _wl             = 40
        _rl             = 500
        _rl2            = 512+8
        
        _rchunk         = 256

        _debug          = 0

        _wchunk         = 512   'size of write buffer
        _wextra         = 32
        
        
VAR

        byte    scratch[_sl]     'receives misc bytes from memStick
        long    scrcnt           'a counter for the buffer
        byte    filename[13]     '8.3 + null
'        byte    cmd[_wl]         'command buffer
        byte    demobuf[100]     'for demo method
        
        long    wbufptr          'pointer to wbuf
        byte    wbuf[_wchunk+_wextra]
        
'used in the module
        
        byte    fmode            'access mode of current file
                                 '  0 - none open
                                 '  1 - open for read
                                 '  2 - open for write
        byte    fname[13]        '8.3 + null

        byte    cmd[_wl]         'command buffer
        byte    rb[_rl]          'read buffer
        long    rbcnt            'counter for rd buffer
        byte    rb2[_rl2]        'block of read data for bytewise read
        long    rbcnt2           'count of bytes read
        long    findex           'index into byte read buffer
        long    fmax             'index to last byte(+1) in byte read buffer
        long    flen             'length of file open for read
        long    fpos             'position of bytewise read in file

          
OBJ
        term    : "serial_terminal"
        fm      : "format_memory"
        mst     : "FDS_sgf"

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

                                'get FDS_sgf running
  mst.start(_rxpin,_txpin,_ctspin,0,_rate1)
  
  'mst.start(_rxpin,_txpin,0,_rate1)  'for FDS_sg.spin

                                 'these are done by sync
'  dira[_rtspin]~~               ' ~~ Set I/O pin to output direction 
'  outa[_rtspin] := 0            ' Take Vinculum Out Of Reset

  sync(_rtspin,20)               'wait until memStick ready to go
  nl
  
  mst.get(@scrcnt,_rl,@scratch) 'pick up out of transaction bytes
                                'to scratch buffer  
  i~
  lastcnt~
  repeat
    rc := term.getcnb           'input from pc keyboard
    if rc <> -1
      if rc == $0D
        cmd[i]~
        exec                    'all test and development functions
                                'restart scratch input
        mst.get(@scrcnt,500,@scratch)
        lastcnt~
        nl
        i~
      elseif rc == $1B          'esc to clear
        i~
        nl
      else
        cmd[i++] := rc          'add input to cmd

    if scrcnt > lastcnt         'some stray input from memStick
                                'like when a disks is plugged in
      rc := scratch[lastcnt]
      if rc == $0D
        nl
      elseif rc => " " and rc =< $7E
        term.putc(rc)
      else
        term.putc("(")          'so we can see non-printing chars
        term.hex(rc,2)
        term.putc(")")
      lastcnt++
      
PUB exec | rc, p

                                'd i and p don't use 'memStick.spin'
  case cmd[0]
    "d" :                                  'get dir
      p := @cmd
      p := fm.pstrz(p,string("DIR"))
      byte[p] := $0D
      mst.get(@scrcnt,_sl,@scratch)
      mst.put(4,@cmd)
      rc := wait(-1,@scratch,@scrcnt)
      dumpbuf(@scratch,scrcnt)
    "i" :                                  'IDD command
      p := @cmd
      p := fm.pstrz(p,string("IDD"))
      byte[p] := $0D
      mst.get(@scrcnt,_sl,@scratch)
      mst.put(4,@cmd)
      rc := wait(-1,@scratch,@scrcnt)
      dumpbuf(@scratch,scrcnt)
    "p" :                                  'check disk (CR)
      cmd[0] := $0D
      mst.get(@scrcnt,_sl,@scratch)
      mst.put(1,@cmd)
      rc := wait(0,@scratch,@scrcnt)
      dumpbuf(@scratch,scrcnt)

                                'module test routines      
    "l" :                                  'get file length
      getfilename
      rc := getFileLength(@filename)
      nl
      term.dec(rc)
      nl
    "f" :                                  'show total free space
      rc := getFreeSpace
      nl
      term.dec(rc)
      nl


    "y" :                       'run demo
      demo1
    "z" :                       'run demo
      demo2
    "s" :                       'test sync
      rc:= sync(_rtspin,20)
      sdec(string("sync: "),rc)
      
                                'commands with file name must be
                                'eq: r<space>8.3filename
                                '    r myfile.txt (space required)
    "r" :                                  'open to read
      getfilename
      se( open(@filename,1) )
    "w" :                                  'open to write
      getfilename
      se( open(@filename,2) )
    "a" :                                  'open to append
      getfilename
      se( open(@filename,3) )
    "c" :                                  'close
      se( close )
    "x" :                                  'delete file
      getfilename
      se( deleteFile(@filename) )
    "/" :                                  'connect to directory
      getfilename                          'can use ".." to go up
      se( cd(@filename) )
    "m" :                                  'make directory
      getfilename
      se( makeDirectory(@filename) )
    "M" :                                  'delete directory
      getfilename
      se( deleteDirectory(@filename) )
    "n" :                                  'rename file
      getfilename
      se( renameFile(@filename,string("newname.fil")) )
      
    "1" :                                  'block write from wtst1
      se( write(@wtst1,strsize(@wtst1)) )  
    "2" :                                  'block write from wtst2  
      se( write(@wtst2,strsize(@wtst2)) )
    "3" :                                  'block write many from wtst1
      repeat 10
        rc := write(@wtst1,strsize(@wtst1))
        if rc
          se(rc)
          quit
    "7" :                                  'read using read itself
      repeat
        rc := read(@rb2,512,1)
        if rc > 0 and rc <> 512
          term.dec(rc)
          nl
        if rc < 0  
          nl
          term.str(string("end code: "))
          term.dec(rc)
          nl
          quit
    "8" :                                  'read file by bytes but don't show
      repeat
        rc := gbyte
        if rc < 0
          nl
          term.str(string("end code: "))
          term.dec(rc)
          nl
          quit
    "9" :                                  'read file by bytes
      repeat
        rc := gbyte
        if rc < 0
          nl
          term.str(string("end code: "))
          term.dec(rc)
          nl
          quit
        if rc == $0d
          next
        if rc == $0a
          nl
          next
        term.putc(rc)
    other :
      term.str(@msg1)

PRI se(rc)
' show error if any
  if rc
    nl
    term.str(string("error code: "))
    term.dec(rc)
    sp
    if rc == -2                 'message from the memStick
      dumpbuf(@rb,rbcnt)
    nl
       
PRI getfilename | p
  p := @filename
  p := fm.pstrz(p,@cmd[2])
  byte[p]~
   
PRI dumpbuf(b,n) | rc, i
  i~
  repeat while i < n             
    rc := byte[b++]
    i++
    if rc => " " and rc =< $7E
      term.putc(rc)
    elseif rc == $0D
      nl
    else
      term.putc("(")
      term.hex(rc,2)
      term.putc(")")
  nl

PRI dumpcmd(n) | rc, i
  i~
  repeat while i < n
    rc := cmd[i++]
    if rc => " " and rc =< $7E
      term.putc(rc)
    term.putc(":")
    term.hex(rc,2)
    term.putc(" ")
  nl

PRI dumpfindex
  term.str(string("file mode:     "))
  term.dec(fmode)
  nl
  term.str(string("file name:     "))
  term.str(@fname)
  nl
  term.str(string("file length:   "))
  term.dec(flen)
  nl
  term.str(string("file position: "))
  term.dec(fpos)
  nl
  term.str(string("buffer index:  "))
  term.dec(findex)
  nl
  term.str(string("buffer max:    "))
  term.dec(fmax)
  nl

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
  se( open(@fn1,2) )
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
    se( write(@demobuf,strsize(@demobuf)) )
    i++
    term.putc(".")              'show progress

  nl
  se( close )                   'must do on writes

{
  Show file length.
}
  rc := getFileLength(@fn1)
  term.str(string("file length is: "))
  term.dec(rc)
  nl
{
  Now open for reading and show the first two lines.
}
  term.str(string("now read"))
  nl
  se( open(@fn1,1) )
  repeat 2
    se( gline(@demobuf) )       'demobuf is long enough
    term.str(@demobuf)
    nl
{
  Seek to line 33, read and decode the fields.
  The return code is the terminator (,nl,eof) or
  an error code which is negative.  See the code.
}
  term.str(string("now seek and show"))
  nl
  se( seek(33*25) )
  rc := gdec(@i)
  showdemo1(rc,i,0)  
  rc := ghex(@i)
  showdemo1(rc,i,0)  
  rc := gstr(@cmd)
  showdemo1(rc,@cmd,1)  
  rc := gdec(@i)
  showdemo1(rc,i,0)  
  rc := gdec(@i)
  showdemo1(rc,i,0)  
{
  Seek to line 98, read to end of file.
}
  term.str(string("read to end of file"))
  nl
  se( seek(98*25) )
  repeat 4
    rc := gline(@demobuf)
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
  se( deleteFile(@fn1) )
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
  se( open(@fn2,2) )
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
  se( close )                   'must do on writes

{
  Show file length.
}
  rc := getFileLength(@fn2)
  term.str(string("file length is: "))
  term.dec(rc)
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
        rc := write(@wbuf,n)
        wbufptr := @wbuf
        return rc
    2 :                         'check/write if needed
      n := wbufptr-@wbuf
      if n > _wchunk
        rc := write(@wbuf,_wchunk)
        if rc
          return rc             'some error
        n -= _wchunk            'leftover
        bytemove(@wbuf,@wbuf+_wchunk,n)
        wbufptr -= _wchunk
      return 0
      
        
PUB sync(rtspin,maxsec) | rc, t1, sec, lchar, lcnt, csf, n

'' synchronizes with the memStick processor
'' returns:
'' 0 - completely timed out something is dead
'' 1 - ready with disk inplace
'' 2 - ready with no disk

'' this should be safe to call at any time but must
'' be called at startup

  cmd[0] := $0d                 'send one <CR> only
  mst.get(@rbcnt,_rl,@rb)       'receive buffer and ocunt
  mst.put(1,@cmd)               'send command
  t1 := cnt                     'watch total time
  dira[rtspin]~~                'pin to output direction 
  outa[rtspin] := 0             'start Vinculum
  sec~
  lchar~
  lcnt~
  csf~
  n~
  repeat                        'see what we get
    if (cnt-t1) > clkfreq       'one sec passes
      sec++
      t1 := cnt
      term.putc("+")            'debug only
      if sec>maxsec
        mst.get_stop            'no more input here
        return 0                'complete failure
    if lcnt == rbcnt            'nothing new
      next
    rc := rb[lcnt++]            'get this new char
    
    if rc == $0D                'debug only
      term.str(string("<cr>"))
    else
      term.putc(rc)
      
    if rc == $0D                'end of some line
      if lchar == "k"           ' "No Disk<cr>"
        mst.get_stop            'no more input here
        return 2                'no disk
      if lchar == ":"           'cold start "On-Line:<cr>"
        csf := 1
      if lchar == ">"           ' "D:\><cr>"
        n++
      if csf and n == 2
        mst.get_stop            'no more input here
        return 1                'let's rock and roll!
      if n and not csf
        mst.get_stop            'no more input here
        return 1                'ditto
    lchar := rc                 'we are looking for x<cr> pairs
        
PUB open(fn,mode) | rc, p
{{
  fn is a pointer to a 8.3 file name zero terminated
  mode is:
    1 read
    2 write
    3 append
}}

  close
  
  p := @fname                   'copy name
  p := fm.pstrz(p,fn)
  byte[p]~
  
  if mode == 1
    rc := buildCMD(1,string("OPR "),@fname,0)
    fmode := 1
  else
    rc := buildCMD(1,string("OPW "),@fname,0)
    fmode := 2
  rc := transact(rc,0,0,0)
  if rc
    fmode~
    return rc
  if mode == 2                  'write append is default
    rc := seek(0)               'seek to start for write
    if rc
      return rc
  if mode == 1                  'setup to read bytes
    fpos~
    flen := getFileLength(@fname)
    if flen == -1
      fmode~
      return flen
    findex~
    fmax~
  return false
  
PUB close | rc, p

'' close if file open for write

  if fmode == 2
    rc := buildCMD(1,string("CLF "),@fname,0)
    rc := transact(rc,0,0,0)
    if rc
      fmode~
      return rc
  fmode~                        'also close read (no action)
  return false

PUB read(data,n,posf) | rc, cdata

'' read n bytes to buffer at address data
'' if posf is true the file position is updated
'' memory space starting a data must be n+8
'' returns number of bytes actually read or
'' error code as a negative number
'' returns:
'' 0..n number of bytes read
'' -1   eof
'' -2   no file open for read
'' -3   time out from FDS_sgf

  ifnot fmode
    return -5                   'nothing open
  if fpos => flen
    return -1                   'eof
  if fpos+n > flen              'only read to eof
    n := flen - fpos
  rc := buildCMD(2,string("RDF "),0,n)
  mst.get(@cdata,n+6,data)
  mst.put(rc,@cmd)              'send command
  rc := wait(n,data,@cdata)
  if rc
    return rc                   'other errors
  if posf
    fpos += n
  return n
    
PRI readRB2(n) | rc

' read to local buffer rb2

  rc := read(@rb2,n,0)
  if rc < 0
    return rc
  findex := 0
  fmax   := rc
  return false
    
PUB write(data,n) | rc

'' write n bytes from data to the open file

  rc := buildCMD(2,string("WRF "),0,n)
  rc := transact(rc,data,n,0)
  if rc
    fmode~
    return rc 
  return false

PUB gbyte | rc    

'' return the next byte in the open file using local buffer
'' 0..FF is the value of the byte
'' < 0 some error

  if findex => fmax          'need to read more
    rc := readRB2(_rchunk)
    if rc < 0                'some error
      return rc
  rc := rb2[findex++]        'the actual character
  fpos++                     'maintain file position
  return rc
    
PUB asciihex2bin(c)
''  return numeric value of any hex digit
  if lookdown(c:"0".."9")
    return (c - "0")
  if lookdown(c:"A".."F")
    return (c - "A" + 10)
  if lookdown(c:"a".."f")
    return (c - "a" + 10)
  return -1
    
PRI gnum_cc(along,fmt) | c, first, val, sgn

'  read to newline or , and collect a number
'  if dec true then signed decimal else hex
'  store this as a long at address along
'  see start comment for error codes
'  _cc means common code for other functions

  val~
  sgn := 1
  first := true
  repeat
    c := gbyte
    if c < -1                   'bad problem
      return c
    if c == 13                  'just ignore cr
      next
                                'check any field terminator
    if c == "," or c == 10 or c == -1
      if first                  'empty field or eof
        if c == -1
          return c              'no field before eof
        else
          long[along]~          'default to zero
          return -6             '  for empty field
      else                      'done
        long[along] := sgn * val
        return c
        
    first := false 
    if fmt == 0 and c == "-"
      sgn := -1
      next

    case fmt
      0:
        if lookdown(c:"0".."9")     '*10 = *8 + *2
          val := val<<3 + val<<1 + (c - $30)
      1:
        if (c := asciihex2bin(c)) <> -1
          val := val<<4 | c
           
PUB gdec(along) | c, first, val, sgn
''  read to newline or , and collect a signed decimal
''  store this as a long at address along
''  see start comment for error codes
  return gnum_cc(along,0)

PUB ghex(along) | c, first, val
''  read to newline or , and collect a hexadecimal
''  store this as a long at address along
''  see start comment for error codes
  return gnum_cc(along,1)

PRI gstr_cc(p,commaf) | c, nread

'  copy string to p and zero terminate
'  storate a p MUST be large enough
'  terminate on commaf if true
'  _cc means common code for other functions

  nread~                        'count bytes stored
  repeat
    c := gbyte
    if c < -1                   'bad problem
      byte[p]~
      return c
    if c == 13                  'ignore
      next
                                'check any field terminator
    if (commaf and c == ",") or c == 10 
      byte[p]~
      if commaf
        return c
      else
        return 0
      
    if c == -1                  'end of file
      if nread
        byte[p]~
        return 0
      else
        byte[p]~
        return -1               'true eof - no more lines
        
    byte[p++] := c
    nread++

PUB gstr(p) | c, nread
{{
  copy string to p and zero terminate
  storage at p MUST be large enough
  ends on comma, eol, eof
  returns the terminator:
  "," - comma terminator
   0  - eol (or eof if missing final lf
  -1  - eof with no data copied to p
  -2  - error with file system
}}
  return gstr_cc(p,true)

PUB gline(p) | c, nread

''  copy everything up to newline except cr
''  zero terminate
''  see gstr comment for error codes

  return gstr_cc(p,false)

PUB gbin(addr,n) | c, nread

''  get n bytes to addr - binary mode
''  storate at addr MUST be large enough
''  returns number read or -1 eof -2 file sys error

  nread~
  repeat while n--
    c := gbyte
    if c < 0            'end of file or error
      if nread          'got some anyway
        return nread
      else
        return c
    byte[addr++] := c
    nread++
  return 0              'ok 
          
PUB seek(n) | rc, p

'' move file pointer on open file
'' note: a seek on a write will work but on close
''       the file will be truncated to the current
''       file position

  ifnot fmode
    return -5
  rc := buildCMD(2,string("SEK "),0,n)
  rc := transact(rc,0,0,0)
  if rc
    return rc
  findex~
  fmax~
  fpos := n              'reset read buffering
  return false 
      
PUB getDirectory(dbuf,dmax) | rc, dcnt
{{
  dbuf - address of buffer to hold text
  dmax - max bytes accepted
  Note: as there is no way to know how big the
        directory actually is this is of only
        provisional value.
}}
  rc := buildCMD(0,string("DIR"),0,0)
  mst.get(@dcnt,dmax-8,dbuf)
  mst.put(rc,@cmd)
  rc := wait(0,dbuf,@dcnt)
  mst.get_stop                  'halt more input
  if rc
    return rc
  return false
  
PUB getFileLength(fn) | rc

'' return length of file in bytes (a long) (4Gmax!)

  rc := buildCMD(1,string("DIR "),fn,0)
  rc := transact(rc,0,0,strsize(fn)+8)
  if rc
    return rc 
  rc~
  repeat while rb[rc] <> " "    'value is after the space
                                '  LSB first
    rc++
  return rb[rc+1] | rb[rc+2]<<8 | rb[rc+3]<<16 | rb[rc+4]<<24
   
PUB getFreeSpace | rc

'' return total free space (a long) (4Gmax!)

  rc := buildCMD(0,string("FS"),0,0)
  rc := transact(rc,0,0,8)
  if rc
    return rc 
  return rb[0] | rb[1]<<8 | rb[2]<<16 | rb[3]<<24

PRI sleep(wake) | rc

'' sleep if wake==0 else wake

  if wake
    rc := buildCMD(0,string("WKD"),0,0)
  else
    rc := buildCMD(0,string("SUD"),0,0)
  rc := transact(rc,0,0,0)
  if rc
    return rc 
  return false

PRI dirmanage(s,name1,name2) | rc

' common code for directory management

  rc := buildCMD(3,s,name1,name2)
  rc := transact(rc,0,0,0)
  if rc
    return rc 
  return false

PUB cd(name)     

'' connect to directory
'' use name==0 to go up the tree

  ifnot name
    name := string("..")
  return dirmanage(string("CD "),name,0)
  
PUB renameFile(old,new)     

'' rename old to new

  return dirmanage(string("REN "),old,new)
  
PUB deleteFile(name)     

'' delete file (forever)

  return dirmanage(string("DLF "),name,0)
  
PUB makeDirectory(name)     

'' create a directory

  return dirmanage(string("MKD "),name,0)
  
PUB deleteDirectory(name)     

'' delete directory

  return dirmanage(string("DLD "),name,0)
  
PRI buildCMD(type,s,fn,value) | p, size

' various command forms

  p := @cmd
  p := fm.pstrz(p,s)
  case type
    0 :                         'just the s string
      byte[p]~
      size := strsize(@cmd) + 1    
    1 :                         '+ filename
      p := fm.pstrz(p,fn)
      byte[p]~
      size := strsize(@cmd) + 1
    2 :                         '+ number in binary MSB first
      byte[p]~
      size := strsize(@cmd) + 5
      p := fm.plMSBf(p,value)
    3 :                         '+ filename1 [+ filename2]
      p := fm.pstrz(p,fn)       '(for rename)
      if value
        p := fm.pspace(p)
        p := fm.pstrz(p,value)
      byte[p]~
      size := strsize(@cmd) + 1
  byte[p++] := $0D
  if _debug
    term.str(string("L="))
    term.dec(size)
    term.putc(" ")
    dumpcmd(size)
  return size

PRI transact(nc,writedata,n,e) | rc

'  command/response cycle manager for memStick
'  (except for true 'read' commands) see below
'  nc        - number of bytes in cmd buffer
'  writedata - address of data to write
'  n         - count of write data bytes
'              (zero for none)
'  e         - pass to wait

  mst.get(@rbcnt,_rl,@rb)       'start read
  mst.put(nc,@cmd)              'send command
  if n                          'also send data
    mst.put(n,writedata)
    mst.put(1,@cr)
  rc := wait(e,@rb,@rbcnt)
  mst.get_stop                  'no more input here
  if rc
    return rc
  return false                  'no error

PRI wait(expect,buff,acnt) | last, t, d1, cc, lc
{
  wait for a <CR> after expect chars have been
    received if previous char was > return 0 else
    -2 for a monitor error
  if expect == -1 then only stop on >CR else
    timeout
  (acnt is the address of the long which
   FDS_sgf updates)
}
  d1 := clkfreq * 5             '5 sec timeout
  t  := cnt                     'starting tick
  repeat while not long[acnt]   'wait any byte before start
                                '(allows transmitter to finish)
    if cnt-t > d1
      return -4                 'memStick not responding 
  last~
  lc~
  d1 := clkfreq * 2             '2 sec timeout
  t := cnt
  repeat
    if long[acnt] == last       'this means no new byte read
      if cnt-t > d1             'waiting too long for next byte
        return -3
    else                        'something new arrived
      last := long[acnt]
      cc   := byte[buff+last-1]
      if expect => 0 and last > expect and cc == $0D
        if lc == ">"
          return 0
        else
          return -2
      else                      'only accept >CR else timeout
        if cc == $0D and lc == ">"
          return 0
      lc := cc
      t := cnt                  'reset deadman


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

title   byte    "memStick_dev",13,10,13,10,0
msg0    byte    "any key to start",13,10,0
msg1    byte    "command unknown",13,10,0

cr      byte    $0D

wtst1   byte    "abcdefghijklmnopqrstuvwxyz 0123456789",13,10,0
wtst2   byte    "31415926,hello there,0xa9f45,0,,",13,10,0

fn1     byte    "myfile.csv",0
fn2     byte    "myfile2.csv",0

        