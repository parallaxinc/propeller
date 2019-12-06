{{ memStick.spin

  Bob Belleville

  Actually interface a a memory stick using a
  Parallax #27937 board.
  
  2007/11/20 - from ummc.spin somewhat
               mostly from memStick_dev.spin
  
  See also readme.pdf for more documentaton.

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

  Connect all 4 lines through 4.7K resistors for
  safety.
  
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

        _rchunk         = 256        'size of read buffer block

        _cmdl           = 32         'command buffer (4+2*12+1)
        _rl             = 32         'replies except true reads
        _rl2            = _rchunk+8
        

VAR

        byte    fmode            'access mode of current file
                                 '  0 - none open
                                 '  1 - open for read
                                 '  2 - open for write
        byte    fname[13]        '8.3 + null

        byte    cmd[_cmdl]       'command buffer
        byte    rb[_rl]          'read buffer
        long    rbcnt            'counter for rd buffer
        byte    rb2[_rl2]        'block of read data for bytewise read
        long    rbcnt2           'count of bytes read
        long    findex           'index into byte read buffer
        long    fmax             'index to last byte(+1) in byte read buffer
        long    flen             'length of file open for read
        long    fpos             'position of bytewise read in file

        

OBJ

        mst     : "FDS_sgf"        'special version of FullDuplexSerial
        fm      : "format_memory"  'format strings in memory for command
                                   '  makeup
        

PUB start(rxpin,txpin,rtspin,ctspin,rate,syncmax) | rc

''  start cog for memStick communication
''  init data struct

  rc := mst.start(rxpin,txpin,ctspin,0,rate)
  
  dira[rtspin]~~                ' ~~ Set I/O pin to output direction 
  outa[rtspin] := 0             ' Take Vinculum Out Of Reset

  sync(syncmax)                 'wait until memStick ready to go

  fmode~
  findex~
  fmax~
  flen~
  fpos~
  return rc                     'true if okay

PUB stop
'' shutdown cog
  mst.stop
  
PUB getErrorString
'' return the address of the error string returned by memStick
  rb[rbcnt]~
  return @rb
  
PUB sync(maxsec) | rc, t1, sec, lchar, lcnt, csf, n

'' synchronizes with the memStick processor
'' returns:
'' 0 - completely timed out something is dead
'' 1 - ready with disk inplace
'' 2 - ready with no disk

'' this should be safe to call at any time
'' (it is called by start above)

  cmd[0] := $0d                 'send one <CR> only
  mst.get(@rbcnt,_rl,@rb)       'receive buffer and ocunt
  mst.put(1,@cmd)               'send command
  t1 := cnt                     'watch total time
  sec~
  lchar~
  lcnt~
  csf~
  n~
  repeat                        'see what we get
    if (cnt-t1) > clkfreq       'one sec passes
      sec++
      t1 := cnt
      if sec>maxsec
        mst.get_stop            'no more input here
        return 0                'complete failure
    if lcnt == rbcnt            'nothing new
      next
    rc := rb[lcnt++]            'get this new char
    
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
'' 'close' read files here for error control

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
'' memory space starting at data must be n+8
'' returns number of bytes actually read or
'' error code as a negative number
'' returns:
'' 0..n number of bytes read
'' see head comment for negative error codes

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
''  accepts 0xnnn, $nnn, and nnn formats as hex
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
  nl
  negative values are errors see above    
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

PUB sleep(wake) | rc

'' sleep if wake==0 else wake
'' be sure to see the Vinculum documents

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
  d1 := clkfreq * 2             '2 sec timeout (make longer if
                                '  you get -3 error that don't seem
                                '  right)
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


DAT

cr      byte    $0D
