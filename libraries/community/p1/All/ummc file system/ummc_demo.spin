{{ ummc_demo.spin

  Bob Belleville

  This object demonstrates using ummc.spin to
  interface to a Rogue Robotics SD card reader/writer.

    http://www.roguerobotics.com/products/electronics/ummc
  
  see readme.pdf for more documentaton

  2007/03/17 - essentially from ummc_testbed.spin

  To use:

  Important.  See ummc_testbed to set the ummc's
  baud rate to 115200.
  
  Compile and run this as a top object file.

  Connect the prop's tx pin through a 4.7K resistor
  to the ummc's rx pin and the prop's rx pin through
  a 4.7K resistor to the ummc's tx pin.  This way if
  there is any error neither device will be harmed.
               
  Start a terminal emulator on the com port
  used by the Propeller Tool.  Set 8N1 and
  115200 baud.  Open the port and press any
  key when "any key to begin" is shown.

}}
 
CON

                                'use 80MHz
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        _rxpin          = 0
        _txpin          = 1
        _rate           = 115200

        _cmdl           = 40               'command buffer
        _wl             = 512+4            'write data buffer
        _rl             = 512+4            'rcv data buffer

                                           'g* error code flags
        _realerr        = $1_0000          'some real problem
        _eof            = $2_0000          'end of file
        _empty          = $4_0000          'field empty (dec and hex)
        
        
VAR

        byte    w[_wl]          'misc buffer
        byte    r[_rl]          'for an open read handle

          
OBJ
        term    : "serial_terminal"
        fsys    : "ummc"
        fm      : "format_memory"

PUB start | n, tf, i, t1, t2, t3, t4, j, k, l, m
  
  term.start(12)                   'start the terminal
  fsys.start(_rxpin,_txpin,_rate)  'start file system

                                'allow time to get terminal
                                '  running
  repeat while term.getcnb == -1
    term.str(@msg0)
    waitcnt(40_000_000+cnt)     'message about 1/2 sec
                                'until keyboard
  
  term.str(@title)

  repeat

    tf := fsys.sync             'check connection
    if tf
      term.str(string("sync TRUE: communication ok"))
      nl
    else
      term.str(string("sync FALSE with error code: "))
      term.str(fsys.error_addr)
      nl
      term.str(@msg4)             'repeat if wanted 
      term.getc
      next

    nl
    'show volume data
    se( fsys.get_freespace(@t1) )   
    se( fsys.get_totalspace(@t2) )
    term.str(string("used: ") )
    term.dec(t2-t1)
    term.str(string("K bytes of total: ") )
    term.dec(t2)
    term.str(string("K bytes") )
    nl

    nl   
    'open a file, read and print all the lines - little checking
    term.str(string("just open and read a file using gline"))
    nl
    se( fsys.open(0,"r",@f1,@r,512) )
    term.str(@f1)
    nl
    repeat while not fsys.gline(0,@w) 'all good lines return 0
      term.str(@w)                    'not zero on eof (or error)
      nl 
    se( fsys.close(0) )           'free handle

    nl 
    'open a file, append several .csv type lines, close
    term.str(string("writing data.csv"))
    nl
    t1 := cnt
    se( fsys.open(0,"a",@f3,0,0) )
    repeat 5
      t2 := cnt
      n := @w                     'this how formatting goes
      n := fm.pdec(n,(t2-t1)/80)  'delta time in usec
      n := fm.pcomma(n)
      n := fm.phex(n,cnt,8)       'cnt in hex
      n := fm.pcomma(n)
      n := fm.phex(n,$1234FCA0,8) 'known pattern in hex
      n := fm.pcomma(n)
      n := fm.pcomma(n)           'an empty field
      n := fm.pstrz(n,@msg3)      'a string
      n := fm.peol(n,0)           'crlf type
      se( fsys.write(0,@w,n-@w) )
      t1 := t2
    se( fsys.close(0) )

    nl 
    'now read it all back as ordinary text
    term.str(string("now read back using gline --- no parsing"))
    nl
    se( fsys.open(0,"r",@f3,@r,512) )
    term.str(@f3)
    nl
    repeat while not fsys.gline(0,@w) 'all good lines return 0
      term.str(@w)                    'not zero on eof (or error)
      nl 
    se( fsys.close(0) )           'free handle

    nl 
    'now read it all back and decode fields
    term.str(string("now read back parse fields and show g* return values"))
    nl
    se( fsys.open(0,"r",@f3,@r,512) )
    term.str(@f3)
    nl
    repeat
      i := fsys.gdec(0,@t1)     'time field
      if i & _eof
        quit
      j := fsys.ghex(0,@t2)     'hex field
      k := fsys.ghex(0,@t3)     '2nd hex field
      l := fsys.ghex(0,@t4)     'empty field
      m := fsys.gstr(0,@w)      'the string
      term.dec(t1)
      sp
      term.hex(i,5)
      sp
      
      term.hex(t2,8)
      sp
      term.hex(j,5)
      sp
      
      term.hex(t3,8)
      sp
      term.hex(k,5)
      sp
      
      term.hex(t4,2)
      sp
      term.hex(l,5)
      sp
      
      term.str(@w)
      sp
      term.hex(m,5)
      
      nl
    se( fsys.close(0) )

    nl 
    'delete the file
    term.str(string("delete this .csv file"))
    nl
    se( fsys.delete_file(@f3) )

    nl
    term.str(string("if necessary create a file with 256 bytes 0..255"))
    nl
    'create a file with the bytes set 0..255 to test
    '  the position functions
    '  write it if necessary or use the one on the card
    term.str(string("attempt to open: "))
    term.str(@f4)
    nl
    tf := fsys.open(0,"w",@f4,0,0)
    if tf                       'file ready to write
      term.str(string("writing position test file: "))
      term.str(@f4)
      nl
      i := @w
      repeat n from 0 to 255
        byte[i++] := n          'build a buffer 0..255
      se( fsys.write(0,@w,256) )
      se( fsys.close(0) )
    else                        'already exists (most likely)
      term.str(@msg1)
      term.str(fsys.error_addr)
      nl
      term.str(string("EF4 means file already exists"))
      nl
      term.str(@f4)
      nl  

    nl
    term.str(string("now open the file and jump to various bytes"))
    nl
    'now open the file for reading and make various tests
    se( fsys.open(0,"r",@f4,@r,512))
    term.str(string("file position is: "))
    se( fsys.get_position(0,@n))
    term.dec(n)
    nl
    term.str(string("file length is: "))
    se( fsys.get_filelength(0,@n))
    term.dec(n)
    nl
    term.str(string("value at position 88: "))
    se( fsys.position(0,88))
    term.dec(fsys.read_raw(0))
    nl
    term.str(string("file position now is: "))
    se( fsys.get_position(0,@n))
    term.dec(n)
    nl
    term.str(string("value at position 157: "))
    se( fsys.position(0,157))
    term.dec(fsys.read_raw(0))
    nl
    term.str(string("file position now is: "))
    se( fsys.get_position(0,@n))
    term.dec(n)
    nl
    term.str(string("value at position 300: "))
    se( fsys.position(0,300))
    term.hex(fsys.read_raw(0),8)
    nl
    term.str(string("file position now is: "))
    se( fsys.get_position(0,@n))
    term.dec(n)
    nl
    fsys.close(0)

    nl
    term.str(string("append to a binary file 100k bytes - hit y key else skip"))
    nl
                                'result 4,650 bytes per second
    if term.getc == "y"
      se( fsys.open(3,"a",@f5,0,0) )
      repeat 250
        fsys.write(3,@bintst,400)
        term.out(".")
      fsys.close(3)
      nl
       
    term.str(string("binary read using gbin 100k bytes - hit y key else skip"))
    nl
                                'result 5,797 bytes per second
    if term.getc == "y"
      se( fsys.open(2,"r",@f5,@r,512) )
      repeat 250
        fsys.gbin(2,@bintst,400)
        term.out(".")
      fsys.close(2)
      nl
       
    term.str(string("binary read using read 100k bytes - hit y key else skip"))
    nl
                                'result 9,363 bytes per second
    if term.getc == "y"
      se( fsys.open(2,"r",@f5,@r,512) )
      repeat 250
        fsys.read(2,@bintst-1,400,@t1)
        term.out(".")
      fsys.close(2)
      nl
      term.str(string("these show the space and > on the ends of bintst"))
      nl
      term.hex(rfs,8)
      sp
      term.hex(rfgt,8)
      nl
      term.str(string("these show the first and last long in bintst"))
      nl
      term.hex(bintst[0],8)
      sp
      term.hex(bintst[99],8)
      nl
      
    term.str(@msg4)             'repeat if wanted 
    term.getc
      
PUB se(tf)
''  send the error code to the terminal
  if not tf
    sp
    term.str(@msg1)
    term.str(fsys.error_addr)
    sp
    term.hex(fsys.error_num,2)
    nl  

PUB sp
  term.out(" ")
PUB comma
  term.out(",")
PUB nl
  term.out(13)
  term.out(10)

DAT

title   byte    "ummc_demo",13,10,13,10,0
msg0    byte    "any key to begin",13,10,0
msg1    byte    "error code: ",0
msg2    byte    "(time out) ",0
msg3    byte    "text bit",0
msg4    byte    "any key to repeat demo",13,10,0

f1      byte    "/a.txt",0
f2      byte    "/spinsub.txt",0
f3      byte    "/data.csv",0
f4      byte    "/postest.dat",0
f5      byte    "/binary.dat",0

rfs     long   0                         'space from read goes here
bintst  long   1,2,3,4,5,6,7,8,9,10
        long   1,2,3,4,5,6,7,8,9,20
        long   1,2,3,4,5,6,7,8,9,30
        long   1,2,3,4,5,6,7,8,9,40
        long   1,2,3,4,5,6,7,8,9,50
        long   1,2,3,4,5,6,7,8,9,60
        long   1,2,3,4,5,6,7,8,9,70
        long   1,2,3,4,5,6,7,8,9,80
        long   1,2,3,4,5,6,7,8,9,90
        long   1,2,3,4,5,6,7,8,9,100
rfgt    long   0                         '> from read goes here

        