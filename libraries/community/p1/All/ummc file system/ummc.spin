{{ ummc.spin

  Bob Belleville

  Actually interface a ummc SD flash card interface.
  
  2007/03/17 - from wait_ummc in ummc_testbed
          27 - continue after many interruptions
          28 - cleanup pass
          29 - more cleanup and build and test
               binary modes, add read

  Interface hardware is a Rogue Robotics ummc SD card
  reader/writer.

    http://www.roguerobotics.com/products/electronics/ummc
  
  See also readme.pdf for more documentaton.

  The basic idea.  This object allows an application to
  read and write files stored on an SD or MMC flash
  memory card.  These cards are formated for either
  FAT16 or FAT32 on a pc using a flash card interface.
  Thus files can be easily shared with any pc
  program for use.

  Four files can be open at any one time.  The open
  function does this.  Once open, files are accessed
  by file handle which is a number from 0 to 3.  The
  close function frees a handle for future use.

  Both reading and writing are easy.

  To open a file for writing choose either 'w' or 'a' mode.
  Open in 'w' mode requires that the file does NOT exist.
  A file is created with the name given in the call and
  data is written in chunks --- ordinarily a line or
  block of binary data.  It is too inefficient to write
  a byte at a time and this object doesn't buffer write
  data and then write when the buffer is full.  This
  design decision improves efficiency because data need
  never be moved in memory in the case of binary write.
  For text, write data is formatted into a memory string
  using the 'format_memory' object then written directly
  from that buffer.  Append mode 'a' creates a file if
  none exists and writes from the the beginning just like
  write mode.  If the file does exist new data is append
  to the end.  In either case no buffers are allocated
  for write by ummc and thus little storage used for write
  functions by the ummc object.

  In no case may the caller's write buffer exceed
  512 bytes.  This is a ummc rule.  A possible call is:

    tf := fsys.open(0,"a",string("/output.txt"),0,0)
    ...
    tf := fsys.write(0,@buf,n)

  Other examples show how this makes sense.

  Read must be buffered for efficiency.  To open for
  reading requires the address of a user supplied
  buffer and a block length.  The storage allocated
  for the buffer must be 4 bytes longer than the
  block length given.  Block length can be 1 to 512
  but short buffers are very inefficient. A possible
  call is:

    tf := fsys.open(1,"r",string("/data.csv"),@buf,bufl)
    ...
    rc := fsys.gdec(1,@mylong)
    rc := fsys.ghex(1,@my_other_long)
    rc := fsys.gstr(1,@mystring)

  Access is by the g* routines and/or if you want
  read and read_raw methods.
   
  gdec, ghex, gstr, gline - text and .csv methods
  gbin - binary method
    
    g* methods are used to get data from a file handle.
  
    Methods call read_raw on a file handle to get bytes.
    
    Both binary methods and text methods are available
      but they shouldn't be mixed as there are no EOLs
      or fields in binary streams.
      
    In text methods cr (13) is ignored and lf (10) is taken
      as a new line.  In this way both PC and Unix style
      EOLs will work with out need for conversion.  Mac
      style cr only files will have to be converted.

  As and example take gdec.  This method assumes the next
  thing in the input buffer is the ascii version of a
  decimal number followed by a comma, a newline, or 
  end of file.  It reads those bytes and stores a long
  at the address given in the call.

    rc := fsys.gdec(0,@number)

  This makes processing so called comma separated files
  quite easy.  (The format_memory object makes writing
  them just a easy.)  These routines return a code
  indicating any error condition and what condition
  terminated the method --- say EOF or ,.

  gline simply fills the users buffer up to the newline.
  The newline is not included and the buffer is zero
  terminated.  gline return 0 if all is well and error
  flags discussed below if not

  gbin simply copies bytes from the read buffer to memory
  reading more data from the flash card as needed.  For
  example read 4 binary longs from a previously created
  binary file:

    long  myarray[4]     'in the VAR block
    ...
    rc := fsys.gbin(0,@myarray,4<<2)

  In this example the original write could have been
  as simple as:

    tf := fsys.write(0,@myarray,4<<2)

  All binary methods (gbin, read, and read_raw)
  treat all bytes alike --- there is no EOL processing.

  gdec and ghex also ignore anything that isn't meaningfull
  like space and tabs.  As an example 0xFF, FF, F_F, are
  all fine for ghex.  As is -1_000_000 for gdec but as
  this isn't usual on the pc it won't be of much use.

  gstr takes everything up to the , nl, or EOF.  These
  chars can't be in these strings.  I didn't build any
  escape codes.  Use gline and parse as needed.

  g* methods have special convension for errors.  See
  below.

  There is a common convention for errors with the main
  routines: open, write, close, etc.  These routines
  return TRUE if all is completely well.  FALSE indicates
  that something went wrong.  In this case a 4 byte
  string holds the error code in the form E**0 where
  ** are the two bytes that indicate what the actual error
  was.

    tf := fsys.open(1,"r","/data.csv",@buf,bufl)
    if not tf
      print or handle error using fsys.error_addr
        to get the address of the error string.
      eq: term.str(fsys.error_string)
      or if byte[fsys.error_string+1] == "F" and
            byte[fsys.error_string+2] == "2'
        means file doesn't exist.

      or since these two chars are always hex digits
      error_num will return the value as in:
        if fsys_error_num == $F2
        as above

  read will read bytes directly bypassing the read buffer
  discussed above.  It is the fastest way to transfer
  data and can achieve 9.4K bytes per second.  But because
  of the design of the ummc module's interface there are
  drawbacks.  First only 512 bytes maximum can be
  transferred.  In this it matches write.  gbin can read
  any number of bytes.  Second the ummc module sends three
  possible formats:

    space (all the data requested up to 512 bytes) >
    space (all the data up to end of file if less than requested) >
    Exx> for errors

  The g* routines sort all this out.  read only partially
  sorts things out.  read uses the normal error protocol;
  however, your buffer will have to provide space for the
  initial space and the ending > and be long enough to
  receive the 4 bytes send on error.  All this may mess up
  the memory space you intended to fill with your binary
  data.
        
  Here is the error code list:

  The following are code generated directly by the ummc
  (from their documentation):

  E02     Buffer Overrun:  Too many bytes were sent in the command.
            All command can be a maximum of 256 bytes (including the path).
  E03     No Free Files:  This is a response from the Free File command.
            There are no more open handles. You must close an open file
            handle before a new one can be opened.
  E04     Unrecognized command.
  E06     Command formatting error:  this occurs if parameters are missing
            or invalid.
  E07     End of file
  E08     Card not inserted
  E09     MMC/SD Reset failure
  E0A     Card write protected 
  EE6     Read-only file:  a Read-Only file (file attributes) is trying
            to be opened for write or append.
  EE7     Not a file:  an invalid path. 
  EE8     Write Failure:  There could be many reasons for this (damaged card,
            card removed WHILE writing, etc) 
  EEA     No free space:  There is no free space on the card. 
  EEB     File not open:  The file handle specified has not been
            opened with the Open command. 
  EEC     Improper mode:  A Read command was attempted while the file
            has been opened for writing, or vice-versa.
  EED     Invalid Open mode:  only R, W, and A are acceptable open modes.
  EF1     Handle in use:  The specified handle is already being used.
  EF2     File does not exist:  The file in the path specified does not exist. 
  EF4     File already exists:  A Write command was issued, and the file
           in the path already exists.
  EF5     Path invalid:  The path specified does not exist. Ensure that
            all directory names in the path exist.
  EF6     Invalid handle:  The handle specified is not valid.
  EFB     Bad FSINFO Sector (FAT32 only)
  EFC     Unsupported FAT version:  Ensure the card is inserted correctly
            and that the card has been formatted to FAT16 or FAT32.
  EFD     Unsupported Partition type
  EFE     Bad Partition information
  EFF     Unknown Error

  The ummc has a funny response to a transaction when no card is
  inserted.  First it returns F08 --- which make good sense.  On
  the second read after a card is inserted it returns EFF  ---
  which makes no sense.  Use the demo program to see this.
  
  These code are generated by ummc itself:
  
  EB1     byte    "EB1",0 'invalid handle
  EB2     byte    "EB2",0 'handle already in use
  EB3     byte    "EB3",0 'handle not open
  EB4     byte    "EB4",0 'open mode invalid a,A,w,W,r,R only
  EB5     byte    "EB5",0 'ummc time out
  EB6     byte    "EB6",0 'requests invalid number of bytes
  EB7     byte    "EB7",0 'write request on handle open for read
  EB8     byte    "EB8",0 'read request on handle open for write
   
  The g* methods have a different return scheme:

    The low byte will contain the terminating character
    which will be either ',' or nl (10).  For _realerr
    or _eof the byte will be zero.
  
    If bit 16 (_realerr) is set then there is a real error
    and the above error code string will give details.

    If bit 17 (_eof) is set then this is just eof --- all
    data has be processed (even if the eof ended the
    field - the end nl is effectively added.)

    If bit 18 (_empty) is set then this is a indication
    that the field was completly empty as in ',,'.  gstr
    and gline just return empty strings.

    gline returns 0 on all valid lines.  Eof or error just
    return those flags.

    gbin returns 0 if any bytes were transfered.  It
    may transfer some bytes and then return an eof.
    This is mostly for speed.  Perhaps this needs
    to be fixed.
    
  ummc supports only two directory functions.  See
  delete_file and make_path below to completely
  delete a single file (which shouldn't be open
  at the time) and make a new sub directory.

  Three methods are for general housekeeping:  sync,
  get_freespace, and get_totalspace.

  sync attempts to confirm that an application and the
  ummc can communicate.  Call sync and check the error codes.

  get_freespace places the total volume's free space
  in K bytes (K=1024) in the long whose address is supplied
  as an argument to the method.  get_totalspace is
  similar and returns the full size of the card inserted.
  
  File byte position.  ummc will report current file
  byte position for both read and write.  The position
  method can be used with read handles only to do random
  reads.  get_position is used to find the current
  byte location.

    tf := fsys.get_position(0,@here) get position

    tf := fsys.position(0,here) 'set position for next read
    tf := fsys.position(0,0) 'read from start of file
        
  get_filelength places total file length in bytes
  in the long whose address is supplied as an argument to
  the method.
  
  There are no directory function so use the pc.  There
  is no way to list all the files on the SD card
  with the ummc.  A pc program could be used to build
  a directory, format it for your application's use and
  then write it to the root directory.  If it is created
  as a .csv type file then reading it is easy.

  Format not possible on the ummc so use the pc.
  Format for FAT16 is supposed to give faster write
  time but slower startup.  Format for FAT32 is supposed
  to give slightly slow write time but faster startup.

  The following is for quick reference.  These commands
  are automatically generated by this object and arn't
  need by the ordinary user of this object.  However if
  things go wrong, this will be handy.  Also see Rogue's
  documentation.

  All commands to the ummc have the following form:

  command_string cr [write data if required] response_string ">"
  
  Summary ummc commands (13 cr to execute, > ummc ready):
  
  >f                            return next free file handle (1..4)
  >o fh (r/w/a) /path           open
  >r fh [bytes [offset]]        up to 512 sends space first if ok
                                  else Exx for error
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
  >q                            volumn query rtn free/total> (kbytes = 1024)
  >v                            rtn version number>

  Of these only v, s, and f are never used by this object.
   
  The ummc protocol always has the form:

  command_string cr [write data if required] response_string ">"

  For everything except a true data reads the method 'transact'
  handles everything up to the response_string ">" which is
  always handled by 'wait.'  In the case of true read, methods
  'read' or 'read_block' replace 'transact.'  'check_fh' is called by
  every method that uses a file handle for common ummc command
  generation and error checking.

  'read_block' reads go to the buffers provided in the 'open' command.
  'read' reads go to user buffers.
  Everything else receives its response_string in 'rbuff'
  which is never very long.  The ummc module provides for
  a maximum of 512 bytes in either a read or write.

  Command_string can never be longer than 256 bytes and that
  would be with a very long /path/file name.

  There is a lot of code here and you may want to comment out
  any methods you don't actually use in you application to
  save space.

  The _cmdl constant can be made smaller if you are sure
  your file name aren't that long.
  
}}  


CON

        _cmdl           = 256              'command buffer
        _rbuffl         = 40               'replies except true reads

                                           'g* error code flags
        _realerr        = $1_0000          'some real problem
        _eof            = $2_0000          'end of file
        _empty          = $4_0000          'field empty (dec and hex)
        
VAR

        long    rcnt            'to wait on FDS_sg input
        long    values[2]       'two longs
        byte    err[4]          'error code string stgz Exx0
        byte    cmd[_cmdl]      'build commands here
        byte    rbuff[_rbuffl]  'replies except true reads
        
        byte    flags[4]        'for 4 filehandles
        long    arbuf[4]        'address of read buffers (if any)
                                '  actual space must be blksize + 4
        long    rblkl[4]        'read block size
        long    rbptr[4]        'pointer to next byte to read
        long    rbend[4]        'pointer last byte to read +1


OBJ

        scon    : "FDS_sg"         'special version of FullDuplexSerial
        fm      : "format_memory"  'format strings in memory for command
                                   '  makeup
        

PUB start(rxpin,txpin,rate)

''  start cog for ummc communication
''  init ummc data struct

  scon.start(rxpin,txpin,0,rate)  'rev up the serial port
  bytefill(@flags,0,4)            'mark all handle free


PUB error_addr
''  return address of error code string
  return @err

PUB error_num
''  return numeric value of error code
  if err[0] == "E"
    return asciihex2bin(err[1])<<4 | asciihex2bin(err[2])
  else
    return 0                    'no error
    
PUB asciihex2bin(c)
''  return numeric value of any hex digit
  if lookdown(c:"0".."9")
    return (c - "0")
  if lookdown(c:"A".."F")
    return (c - "A" + 10)
  if lookdown(c:"a".."f")
    return (c - "a" + 10)
  return -1
    
PRI transact(awbuff,nwbuff) | tf, i, j

''  transactions with ummc except a true read
''  only write requires awbuff - the address of the
''    data to be written and its length nwbuff
''  file seek commands are r fh 0 position and return
''    no data bytes just space>

  scon.get(@rcnt,_rbuffl,@rbuff)         'start the receiver first 
  scon.put(strsize(@cmd),@cmd)           'send cmd buffer
  if nwbuff                              'a write
    scon.put(nwbuff,awbuff)
  tf := wait(0,@rbuff,@rcnt)             'wait for '>'
  if not tf
    bytemove(@err,@EB5,4)                'time out
    return false

  if lookdown(cmd[0]:"w","o","c","r","m","e","z")
    if rbuff[0] == "E"
      bytemove(@err,@rbuff,3)            'this is some error
      err[3]~
      return false
    else
      return true                        'no problem
      
  if lookdown(cmd[0]:"i","q")            'get values n1/n2>
    longfill(@values,0,2)
    j~                                   'index to values array
    repeat i from 0 to rcnt
      if rbuff[i] == ">"                 'all done
        return true
      if rbuff[i] == "/"
        j++
        next
      values[j] := values[j]<<3 + values[j]<<1 + (rbuff[i]-$30)
      
  return true                'this shouldn't happen
   
   
PRI check_fh(fh,inuse,cc)
{{
  check and start all commands that have a filehandle
  builds cmd with command space fh space [0..3]
  clears error
  set error code for invalid conditions
}}

  err[0]~                       'no error
  cmd[0] := cc
  if fh<0 or fh>3
    bytemove(@err,@EB1,4)       'invalid handle 0..3 only
    return false
  cmd[1] := " "
  cmd[2] := fh + $31
  cmd[3] := " "
  if inuse and flags[fh]==0     'be sure slot is inuse
    bytemove(@err,@EB3,4)       'handle not open
    return false
  if not inuse and flags[fh]<>0 'be sure slot isn't inuse
    bytemove(@err,@EB2,4)       'handle in use
    return false
  return true
 
PUB open(fh, mode, path, arbuff, blksize) | p, tf
{{

  open a file for read, write or append
  for read file must exist
  for write file must not exist
  for append file will be created if needed

  fh       0..3 must not be current in use
  mode     r,R,w,W,a,A open mode
  path     full path starting with root
           separators are '/'
           eg. /a.txt file a.txt in root
               /sub1/sub2/a.txt two levels down
  arbuff   address of a read buffer for read mode
           actual buffer must be 4 longer than blksize
  blksize  number of byte to be read when read buffer
           is empty - can be 1 to 512 but larger is
           more efficient
                           
  !actual store at arbuff MUST be 4 longer than blksize

  see note at top of file for error conditions
  
}}
  if not check_fh(fh,false,"o") 'common file handle processing
    return false
    
  rbptr[fh]~                    'always clear read pointers
  rbend[fh]~
  
  if mode=="a" or mode=="A" or mode=="w" or mode=="W"
    flags[fh] := 2              'write type
    arbuf[fh]~
    rblkl[fh]~
    
  elseif mode=="r" or mode=="r"
    if blksize < 1 or blksize > 512
      bytemove(@err,@EB6,4)     'invalid byte count
      return false
    flags[fh] := 1              'read type
    arbuf[fh] := arbuff         'address of read buffer
    rblkl[fh] := blksize        'read block size (buffer longer)
  else
    bytemove(@err,@EB4,4)       'invalid mode
    return false
  p := @cmd + 4                 'complete command
  byte[p++] := mode
  byte[p++] := " "
  p := fm.pstrz(p,path)         'copy in full filename
  byte[p++] := 13
  byte[p++]~
  tf := transact(0,0)
  if not tf                     'on error
    flags[fh]~                  '  don't leave handle open
  return tf

PUB close(fh)

'' close file and reset struct

  if not check_fh(fh,true,"c") 'common file handle processing
    return false

  flags[fh]~                   'this turns this slot off  
  cmd[4] := 13
  cmd[5]~
  return transact(0,0)

PUB write(fh,abuff,buffl) | p

'' write buffl bytes from abuff to fh

  if not check_fh(fh,true,"w") 'common file handle processing
    return false

  if buffl < 0 or buffl > 512
    bytemove(@err,@EB6,4)       'invalid byte count
    return false
  if flags[fh] <> 2             'type 2 append/write
    bytemove(@err,@EB7,4)       'write to read handle
    return false
  if buffl == 0
    return true                 'no need to bother ummc

  p := @cmd + 4
  p := fm.pdec(p,buffl)         'put byte count in command
  byte[p++] := 13               '  and terminate command
  byte[p]~
  return transact(abuff,buffl)  'send command and data

PUB read(fh,abuff,size,anread) | p, tf
{{
  be careful with this - it is fast but there are
    safer ways to read data below

  this is called by read_block
  
  read into the buffer at abuff size bytes from this file
  write a long to the address anread of the number of bytes
    actually read (not counting the space and >
  buffer will receive first a space, then the data, then a
    > so address the buffer correctly
  on any error the buffer will contain Exx>
  size may be 1..512 for EB6 error results
  abuff itself must be 4 bytes longer than size
}}

  if not check_fh(fh,true,"r")  'common file handle processing
    return false

  if flags[fh] <> 1             'type 1 to read
    bytemove(@err,@EB8,4)       'read from write handle
    return false

  if size < 1 or size > 512
    bytemove(@err,@EB6,4)       'invalid number of bytes
    return false

  p := @cmd + 4
  p := fm.pdec(p,size)          'put byte count in command
  byte[p++] := 13               '  and terminate command
  byte[p]~
  
  rbptr[fh]~                    'always clear read pointers
  rbend[fh]~                    'so read_block will restart

  p := abuff
  scon.get(@rcnt,size+4,p)          'start the receiver first 
  scon.put(strsize(@cmd),@cmd)      'send cmd buffer
  tf := wait(size+1,p,@rcnt)        'wait for '>'
  if not tf
    if rcnt > 0 and byte[p + rcnt - 1] == ">"
      if byte[p] == "E"         'error from ummc (or just eof)
        bytemove(@err,p,3)      'this is some error
        err[3]~
        return false
      else                      'read often short at end of file
        'rbptr[fh] := p + 1
        'rbend[fh] := p + rcnt - 1
        long[anread] := rcnt-2  'space and > don't count here
        return true
    else
      bytemove(@err,@EB5,4)     'it really timed out
      return false
  else
    'rbptr[fh] := p + 1          'normal full buffer read
    'rbend[fh] := p + rcnt - 1
    long[anread] := rcnt-2
    return true

PRI read_block(fh) | tf, p, nread

'' fill read buffer when needed
  
  if fh<0 or fh>3
    bytemove(@err,@EB1,4)       'invalid handle 0..3 only
    return false
  p := arbuf[fh]
  tf := read(fh,p,rblkl[fh],@nread)
  if not tf
    return false
  rbptr[fh] := p + 1            'some or all data read
  rbend[fh] := p + nread + 1
  return true
    
PUB read_raw(fh) | tf
''  read the next byte from this file handle
''  return byte read in low word of return long
''  returns two flags in high word:
''    _realerr ($1_0000) actual error
''    _eof     ($2_0000) end of file

                                'note file handle NOT checked
                                '  since read_block does
  if rbptr[fh] == rbend[fh]     'need more data from file
    tf := read_block(fh)        'this does check
    if not tf
      if error_num == $07
        return _eof             'end of file
      return _realerr           'error return
  return byte[rbptr[fh]++]
         
PRI gnum_cc(fh,along,fmt) | c, first, val, sgn

''  read to newline or , and collect a number
''  if dec true then signed decimal else hex
''  store this as a long at address along
''  see start comment for error codes
''  _cc means common code for other functions

  val~
  sgn := 1
  first := true
  repeat
    c := read_raw(fh)
    if c & _realerr             'bad problem
      return c
    if c == 13                  'just ignore
      next
                                'check any field terminator
    if c == "," or c == 10 or c & _eof
      if first                  'empty field or eof
        if c & _eof
          return c
        else
          long[along]~          'default to zero
          return c | _empty     '  for empty field
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
           
PUB gdec(fh,along) | c, first, val, sgn
''  read to newline or , and collect a signed decimal
''  store this as a long at address along
''  see start comment for error codes
  return gnum_cc(fh,along,0)

PUB ghex(fh,along) | c, first, val
''  read to newline or , and collect a hexadecimal
''  store this as a long at address along
''  see start comment for error codes
  return gnum_cc(fh,along,1)

PRI gstr_cc(fh,p,comma) | c, nread

''  copy string to p and zero terminate
''  storate a p MUST be large enough
''  terminate on comma if true
''  _cc means common code for other functions

  nread~                        'count bytes stored
  repeat
    c := read_raw(fh)
    if c & _realerr             'bad problem
      byte[p]~
      return c
    if c == 13                  'ignore
      next
                                'check any field terminator
    if (comma and c == ",") or c == 10 
      byte[p]~
      if comma
        return c
      else
        return 0
      
    if c & _eof                 'end of file
      if nread
        byte[p]~
        if comma
          return c              'return the terminator
        else
          return 0
      else
        byte[p]~
        return _eof             'true eof - no more lines
        
    byte[p++] := c
    nread++

PUB gstr(fh,p) | c, nread

''  copy string to p and zero terminate
''  storate a p MUST be large enough
''  ends on comma, eol, eof
''  see start comment for error codes

  return gstr_cc(fh,p,true)

PUB gline(fh,p) | c, nread

''  copy everything up to newline except cr
''  zero terminate
''  see start comment for error codes

  return gstr_cc(fh,p,false)

PUB gbin(fh,addr,n) | c

''  get n bytes to addr - binary mode
''  storate at addr MUST be large enough
''  see start comment for error codes

  repeat while n--
    c := read_raw(fh)
    if c => _realerr            'end of file or error
      return c
    byte[addr++] := c
  return 0 
          
PRI inquire(fh)

'' get file position in value[0] and
'' total file size in value[1]

  if not check_fh(fh,true,"i") 'common file handle processing
    return false
    
  return transact(0,0)

PUB get_filelength(fh,along) | tf

''  fill long at along with current total file length

  tf := inquire(fh)
  if not tf
    return tf
  long[along] := values[1]
  return tf
  
PUB get_position(fh,along) | tf, offset

''  fill long at along with current file position

  tf := inquire(fh)
  if not tf
    return tf
  if flags[fh] == 2             'write handle
    long[along] := values[0]
  else
    if rbend[fh] == rbptr[fh]
      offset := 0               'buffer not yet read
    else
      offset := (rbend[fh] - rbptr[fh] + 1)
    long[along] := values[0] - offset
  return tf
  
PUB position(fh,offset) | p, tf

'' reset read position to offset
'' this can be used with the 'read' method

  if not check_fh(fh,true,"r") 'common file handle processing
    return false

  if flags[fh] <> 1             'type 1 to read
    bytemove(@err,@EB8,4)       'read from write handle
    return false

  p := @cmd + 4
  byte[p++] := "0"              'byte count is zero
  byte[p++] := " "
  p := fm.pdec(p,offset)        'put offset into command
  byte[p++] := 13               '  and terminate command
  byte[p]~

  tf := transact(0,0)           'command is r fh 0 offset cr
  if not tf                     'valid result is just space
    return tf                   'this gets all other errors
    
  rbptr[fh]~                    'clear read pointers so
  rbend[fh]~                    '  buffer will refill next read_raw
  return true

PUB delete_file(path) | p

''  delete (completely) this file

  err[0]~
  p := @cmd
  byte[p++] := "e"              'ummc erase command
  byte[p++] := " "
  p := fm.pstrz(p,path)            'copy in path
  byte[p++] := 13               '  and terminate command
  byte[p]~
  return transact(0,0)          'send command
  
PUB make_path(path) | p

''  create this directory

  err[0]~
  p := @cmd
  byte[p++] := "m"              'ummc make path command
  byte[p++] := " "
  p := fm.pstrz(p,path)         'copy in path
  byte[p++] := 13               '  and terminate command
  byte[p]~
  return transact(0,0)          'send command
  
PRI get_volume_data | p

''  get freespace and total volume size to values[0 and 1]
''  result is K bytes (1024 = K)

  err[0]~
  p := @cmd
  byte[p++] := "q"              'ummc query command
  byte[p++] := " "
  byte[p++] := 13               '  and terminate command
  byte[p]~
  return transact(0,0)          'send command
  
PUB get_freespace(along) | tf

''  store total volume free space in K bytes at long at along 
''  result is K bytes (1024 = K)

  tf := get_volume_data
  if not tf
    return true
  long[along] := values[0]
  return tf
      
PUB get_totalspace(along) | tf

''  store total volume space in K bytes at long at along
''  result is K bytes (1024 = K)

  tf := get_volume_data
  if not tf
    return true
  long[along] := values[1]
  return tf
      
PUB sync | p, tf

''  issue a z command - return true if all is well

  err[0]~
  p := @cmd
  byte[p++] := "z"              'ummc status command
  byte[p++] := " "
  byte[p++] := 13               '  and terminate command
  byte[p]~
  tf := transact(0,0)           'send command
  if not tf
    return tf                   'some problem
  if rbuff[0] <> " "
    bytemove(@err,@EB9,4)       'result not space
    return false
  return true
  
PRI wait(expect,buff,acnt) | last, t, d1, d2
{{
''  wait for ummc response

''  'expect' bytes before checking for '>'
''  FDS_sg will be loading bytes into array 'buff'
''    and will be incrementing the long at address 'acnt'
''  time out and return false if nothing happens in
''    5 seconds or if there is a delay of longer than
''    2 milliseconds after bytes start to flow
''  else return true

  All this complexity is needed for two reasons:

  One can't just watch for '>' in the input stream
  because it may be a byte in either a text or
  binary file.

  On read, near end of file, the ummc sends what
  is left then '>'.  So the '>' won't be seen because
  the expected number of bytes won't have been send
  but ummc will be done.  The short time out detects
  this condition and exits in 2ms.

  In the ordinary condition, the '>' will be seen
  and the TRUE return will be immediate.

  With transact this is the heart of this object.
   
}}

  d1 := clkfreq * 5             '5 sec timeout
  d2 := 2 * clkfreq / 1_000     '2 ms
  t  := cnt                     'starting tick
  repeat while not long[acnt]   'wait any byte before start
                                '(allows transmitter to finish)
    if cnt-t > d1
      return false              'ummc not functional 
  last~
  t := cnt
  repeat
    if long[acnt] == last       'this means no new byte read
      if cnt-t > d2             'waiting too long for next byte
        return false
    else                        'something new arrived
      last := long[acnt]
      if last > expect and byte[buff+last-1] == ">"
        return true  
      t := cnt                  'reset deadman
       

DAT

EB1     byte    "EB1",0 'invalid handle
EB2     byte    "EB2",0 'handle already in use
EB3     byte    "EB3",0 'handle not open
EB4     byte    "EB4",0 'open mode invalid a,A,w,W,r,R only
EB5     byte    "EB5",0 'ummc time out
EB6     byte    "EB6",0 'requests invalid number of bytes
EB7     byte    "EB7",0 'write request on handle open for read
EB8     byte    "EB8",0 'read request on handle open for write
EB9     byte    "EB9",0 'sync failed

