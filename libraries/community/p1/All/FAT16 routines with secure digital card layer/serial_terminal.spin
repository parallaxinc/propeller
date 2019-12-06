{{
  Jonathan Dummer
}} 

CON
  _clkmode = term#_clkmode
  _xinfreq = term#_xinfreq
  ' command parsing
  cmd_length = 256
  num_tokens = 16
  ' file handling, using a 8KB buffer
  buf_len = 8 * 1024

OBJ
  term : "sysdep"
  sdfat[2]: "fsrw"
  block : "safe_spi"
  'block : "mb_rawb_spi"
                                                                  
VAR
  ' program buffer
  long tokens[num_tokens]
  long tindex
  byte tin[cmd_length]
  byte cursor ' : > *

  ' various other things
  byte tbuf[32]
  long file_buf[buf_len >> 2] ' force this to be long aligned

PUB begin

  ' start my interface
  \term.start
           
  ' set my text buffer to nothing
  tindex := 0
  bytefill( @tin, 0, cmd_length ) ' terminate it
  cursor := ">"
  
  ' start my inifinite loop
  repeat
    if handle_in( 1000 )

                       
PRI execute_command( cmd_str_ptr ) | ntok, i, tmp, c, rot, tmr
  ' start by tokenizing our command string, and upper-case it
  ntok := tokenize( cmd_str_ptr, @tokens, num_tokens )
  if ntok < 1
    return ' short-circuit
    
  ' check each of out commands
  if strcomp( tokens[0], string( "?" ) ) or strcomp( tokens[0], string( "HELP" ) )
    ' show the help screen
    term.str( string( "       ? ", $BB, " Help Summary", $0D ) ) 
    term.str( string( "    COPY ", $BB, " Copy a file A to B", $0D ) )
    term.str( string( "  CONCAT ", $BB, " Copy A B..N to Z", $0D ) )
    term.str( string( "     DEL ", $BB, " Delete a file", $0D ) )
    term.str( string( "     DIR ", $BB, " Directory listing", $0D ) )
    term.str( string( "    ECHO ", $BB, " Right back atcha!", $0D ) )
    term.str( string( "    INFO ", $BB, " System Summary", $0D ) )
    term.str( string( "   MOUNT ", $BB, " Mount the SD card", $0D ) )
    term.str( string( "     SUM ", $BB, " Do a FNV-1a checksum on a file", $0D ) )
    term.str( string( "    TYPE ", $BB, " Print a file", $0D ) )
    term.str( string( " UNMOUNT ", $BB, " Mount the SD card", $0D ) )
    term.str( string( "    SEEK ", $BB, " perform a seek test (LONG)", $0D ) )   
    ' add in any extra help here    

  elseif strcomp( tokens[0], string( "INFO" ) )
    ' I need some more input
    term.str( string( "Clock Speed: " ) )
    i := 1_000_000
    term.dec( clkfreq / i )
    term.tx( "." )
    tmp := clkfreq // i
    repeat 3
      i /= 10
      term.tx( "0" + (tmp / i) )
      tmp //= i    
    term.str( string( " [MHz]", $0D ) )    
      
  elseif strcomp( tokens[0], string( "ECHO" ) )
    ' I need some more input
    term.str( string( "You typed: " ) )
    repeat i from 1 to ntok - 1 
      term.str( tokens[i] )
      term.tx( " " )

  elseif strcomp( tokens[0], string( "DIR" ) )
    ' opening the dir is just like opening a file
    sdfat.opendir
    repeat while 0 == sdfat.nextfile(@tbuf)
      ' show the filename
      term.str( @tbuf )
      repeat 15 - strsize( @tbuf )
        term.tx( " " )
      ' so I need a second file to open and query filesize
      sdfat[1].popen( @tbuf, "r" )
      term.dec( sdfat[1].get_filesize )
      sdfat[1].pclose      
      term.str( string( " bytes", $0D ) )

  elseif strcomp( tokens[0], string( "MOUNT" ) )
    term.str( string( "mount returned " ) )
    term.dec( sdfat.mount_explicit(term#sd_DO, term#sd_CLK, term#sd_DI, term#sd_CS) )     

  elseif strcomp( tokens[0], string( "UNMOUNT" ) )
    term.str( string( "unmount returned " ) )
    term.dec( sdfat.unmount )

  elseif strcomp( tokens[0], string( "CONCAT" ) )
    if ntok < 4
      term.str( string( "You need to specify at least three filenames.", $0D ) )
    else
      term.str( string( "Please wait: |" ) )
      ' start with the targetfile
      if sdfat.popen( tokens[ntok-1], "w" ) < 0
        term.str( string( "failed to open '" ) )
        term.str( tokens[ntok-1] )
        term.str( string( "' for writing!" ) )        
      else
        repeat i from 1 to ntok-2
          if sdfat[1].popen( tokens[i], "r" ) > -1
            tmp := sdfat[1].pread( @file_buf, buf_len )
            repeat while tmp > 0
              sdfat.pwrite( @file_buf, tmp )
              tmp := sdfat[1].pread( @file_buf, buf_len )
              term.tx( 8 )
              term.tx( byte[string("|/-\")][rot++ & 3] )
            sdfat[1].pclose
        sdfat.pclose
      term.str( string( 8, "done." ) ) 
      
  elseif strcomp( tokens[0], string( "COPY" ) )
    if ntok < 3
      term.str( string( "You need to specify two filenames.", $0D ) )
    else
      term.str( string( "Please wait: |" ) )
      tmp := sdfat.popen( tokens[1], "r" )
      if tmp => 0
         tmp := sdfat[1].popen( tokens[2], "w" )
      repeat while tmp > -1
        i := @file_buf
        tmp := sdfat.pread( i, buf_len )
        if tmp > 0
           sdfat[1].pwrite( i, tmp )
        term.tx( 8 )
        term.tx( byte[string("|/-\")][rot++ & 3] )
      sdfat.pclose
      sdfat[1].pclose
      term.str( string( 8, "done." ) )
    
  elseif strcomp( tokens[0], string( "DEL" ) )
    if ntok < 2
      term.str( string( "You need to specify a filename.", $0D ) )
    else
      tmp := sdfat.popen( tokens[1], "d" )

  elseif strcomp( tokens[0], string( "SUM" ) )
    ' FNV-1a hash
    if ntok < 2
      term.str( string( "You need to specify a filename.", $0D ) )
    else
      term.str( string( "Please wait: |" ) )
      c := 2166136261
      tmp := sdfat.popen( tokens[1], "r" )
      tmr := -block.get_milliseconds
      repeat while tmp > -1
        i := @file_buf
        tmp := sdfat.pread( i, buf_len )
        repeat (tmp #> 0)
          c *= 16777619
          c ^= byte[i++]
        term.tx( 8 )
        term.tx( byte[string("|/-\")][rot++ & 3] )
      tmr += block.get_milliseconds
      sdfat.pclose
      term.str( string( 8, "done.", $0D, " of '" ) )
      term.str( tokens[1] )
      term.str( string( "'is " ) )
      term.hex( c, 8 )
      term.str( string( " (in " ) )
      term.dec( tmr )
      term.str( string( " ms)" ) )
      
  elseif strcomp( tokens[0], string( "TYPE" ) )
    if ntok < 2
      term.str( string( "You need to specify a filename.", $0D ) )
    else
      tmp := sdfat.popen( tokens[1], "r" )
      repeat while tmp > -1
        i := @file_buf
        tmp := sdfat.pread( i, buf_len )
        repeat (tmp #> 0)
          c := byte[i++]
          if (c => "!") and (c =< "}")
            term.tx( c )
      sdfat.pclose

  elseif strcomp( tokens[0], string( "SEEK" ) )
    tmp := sdfat.popen( string( "seek.tst" ), "w" )
    if tmp > -1
      tmr := |<18 - 1
      term.tx( "-" )
      repeat i from 0 to tmr
        sdfat.pputc( i & $FF )
      sdfat.pclose
      term.tx( "/" )
      tmp := sdfat.popen( string( "seek.tst" ), "r" )
      rot := true
      if tmp > -1
        ' good, we have a file
        repeat i from 0 to tmr
          sdfat.seek( i )
          c := sdfat.pgetc
          rot &= (c == (i & $FF))
        term.tx( "\" )
        repeat i from tmr to 0
          sdfat.seek( i )
          c := sdfat.pgetc
          rot &= (c == (i & $FF))
        if rot
          term.str( string( "Verification of 'seek.tst' SUCCEEDED", 13 ) )
        else
          term.str( string( "Verification of 'seek.tst' FAILED", 13 ) )          
    else
      term.str( string( "Failed to write 'seek.tst'", 13 ) )
    
  else
    term.str( string( "Unknown Command" ) )

  ' end with a CR
  term.tx( $0D )


PRI tokenize( string_ptr, token_ptr, max_tokens ) : found_tokens | slen, was_ws, is_ws, i
  ' go through the string, storing the lead pointer to any
  ' non-whitespace tokens, and zero terminating each token
  slen := strsize( string_ptr )-1
  was_ws := true
  repeat i from 0 to slen
    ' is this important?
    is_ws := byte[string_ptr][i] < $21
    if is_ws
      ' make it a 0, so tokens will be terminated
      byte[string_ptr][i] := 0
    else
      ' well, it's not white-space...can I upper-case it?
      if (byte[string_ptr][i] > $60) and (byte[string_ptr][i] < $7B)
        byte[string_ptr][i] -= $20
      ' it may be interesting      
      if was_ws
        ' yep, we just switched..store this token
        long[token_ptr][found_tokens] := string_ptr + i
        found_tokens++
        if found_tokens => max_tokens
          return max_tokens
    ' and move on
    was_ws := is_ws
  ' done, and the return value is in found_tokens 

  
PRI handle_in( ms ) : did_something | char_in
  ' spin for ms milliseconds, waiting for input
  char_in := term.rxtime( ms )
  did_something := false
  repeat while char_in => 0
    ' we got some input!
    did_something := true
    term.tx( char_in ) ' echo it
    if char_in == $08 ' backspace
      tindex--
      tindex #>= 0
    elseif char_in == $0D ' [Enter] terminates
      char_in := -1
      byte[@tin][tindex] := 0
      tindex := 0 ' reset my character index
      execute_command( @tin ) ' do the whatever!
      term.tx( cursor )
      term.tx( " " )
    else
      byte[@tin][tindex] := char_in
      tindex++
      tindex <#= cmd_length-1
     ' continue with the next character
    char_in := term.rxcheck   