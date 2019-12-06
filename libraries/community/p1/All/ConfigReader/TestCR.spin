{{
!!!! Attention !!!!
Make sure that the constant SDpinBase matches with your setup!

This is only a demo for how to use the ConfigReader.

Only little needs to be said here, as the inline comments tell nearly everything about
this test-program and the ConfigReader has it's own description.

BUF_SIZE should be 512+
Where + depends on the maximum line lenght you use in your config-file. If your maximum
line length is 40 you add 40.

PAR_SIZE should be 1+
Here + depends on the number of parameters you can have in one line.
So, it depends on your personal usage. Might be 1 if you only want to read keywords or
10 if you have a keyword with max. 9 parameters.

Of course there is a limitation. The amount of bytes that should be loaded has to be 512.
If the ConfigReader finds a different number of loaded bytes, it assumes that the file-end
has been reached.
}}
con
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

  SDpinBase = 0

  BUF_SIZE = 512+128
  PAR_SIZE = 10
  
obj
  term: "CogOS_IO(Term)"
  cr:   "ConfigReader"
  sd:   "fsrw"

var
  long par_list[PAR_SIZE]
  byte buffer[BUF_SIZE]
    
pub main | sz, ln, oldln, prsd, rd, aofs, badr, tmp
  ' Initialize the SD card
  sd.mount( SDpinBase )

  ' Initialize terminal
  term.start( 0,0 )
  tmp:=-1
  repeat while tmp==-1
    term.str( string( "ConfigReader test",$0d ) )
    term.str( string( "== please press key to start ==",$0d ) )
    tmp:=term.rxtime( 1000 )
  term.tx( 0 )
  term.tx( 1 )
  term.str( string( "ConfigReader test",$0d ) )

  sd.popen( string( "desk2.ini" ),"r" )

  ' tell the ConfigReader where to find the buffer and where to store the parsed data
  cr.init( @buffer, BUF_SIZE, @par_list, PAR_SIZE )

  ' prsd usually holds the return value of the ConfigReader function parse
  ' but to get the whole loop starting, we need to read the first sector
  prsd:=cr#RET_LOAD_NEXT + @buffer<<8
  ' this will loop until the parser says that the whole file has been read
  repeat until prsd==cr#RET_DONE
    ' prsd contains the result of parsing in the LSB (byte 0)
    case prsd & $ff
      ' the parser did not find a lineend in the remaining buffer, so it shifts
      ' the not yet read bytes to the beginning of the buffer and tells us in
      ' byte 1 and byte 2 where to put the next sector to
      cr#RET_LOAD_NEXT:
        badr := (prsd>>8) & $ffff
        ' don't change the number of bytes, as the ConfigReader expects it
        rd := sd.pread( badr, 512 )

      ' the parser found a line and parsed it's content. The result will be
      ' available starting with par_list[1]  
      cr#RET_PAR_FOUND:
        ' tmp := (prsd>>8)
        ' if (tmp < @buffer) or ( tmp > (@buffer + BUF_SIZE) )
        '   return

        ' psr_list[0] has a special meaning. The first word of a line in the config file
        ' is converted to a hash value. This way allows to use a case statement for
        ' comparing the input with the expected keywords. Otherwise we'd have a long
        ' list of stringcompares and all the strings would waste memory of course.
        case par_list[0]
          $0A1EFECE:  ' background
            term.str( string( "Found a setting for background ... opening ") )
            term.str( par_list[1] )
            term.tx( $0d )

          $00006AC3:  ' desk
            term.str( string( "Found a new desk section (" ) )
            term.dec( par_list[1] )
            term.tx( ")" )
            term.tx( $0d )

          other: ' unrecognized hash value, so print data
            term.str( string( "Found " ) )
            term.dec( prsd>>24 )
            term.str( string( " parameters for hash " ) )
            term.hex( par_list[0], 8 )
            term.str( string( " : " ) )
            term.str( prsd>>8 & $ffff )
            term.tx( $0d )

    ' here the ConfigReader is doing it's job. The return value will tell you how
    ' you have to proceed. rd is only different from 0 when the next part of the
    ' file has to be loaded.        
    prsd := cr.parse( rd )
    rd:=0

  term.str( string("done",$0d) )
  repeat

   