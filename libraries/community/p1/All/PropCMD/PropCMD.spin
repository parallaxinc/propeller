{{
PropCMD  Propeller Command Line SD card utility V1.01
by Roger Williams
Copyright (c) 2009 by Michelli Scales
See terms of use at end of this file

Based loosely on original PropDOS by Jeff Ledger

PropCMD implements a true parser which interprets arguments and
switches like /w regardless of the number of spaces separating
them, position on line, or order of switches.  PropCMD observes
the file system hidden attribute bit.

If there is a file on the SD named AUTOEXEC.BAT, when PropCMD
starts it will open the file, read the name of a file, and
load and run that file as if it were the argument of a SPIN
command.  Holding ESC down during boot inhibits this.  Note
that this is the opposite of PropDOS' autostart feature.
Also note this is not a true batch interpreter, and no other
commands can be included in autoexec.bat (so far).

PropCMD checks for AUTOEXEC.BAT before deciding to halt if
there is no keyboard, so it can be used to autoload a SD
program which does not in turn need a keyboard.

PropCMD COMMANDS:
-----------------

MOUNT
  Mount the SD.
  This is done automatically at startup if possible.

UNMOUNT
  Unmount the SD.
  The SD can then safely be changed.

DIR [*.ext] [/w] [/h] [/c] [|more] 
  Show the root directory of the SD.
  *.ext -- show only files with the indicated extension
  /w -- wide format
  /h -- show hidden files (based on attribute bit)
  /c -- show starting clusters
  |more -- pause between screens, ESC to quit
  ctrl-C cancels

TYPE filename [|more]
  Echo the file to the console. 
  |more -- pause between screens, ESC to quit
  ctrl-C cancels

DEL filename
  Delete the file.  Does not ask for confirmation.

COPY CON filename
  Echo lines of user input to the file until CTRL-Z pressed.
  ESC cancels the current input line without ending input.

SPIN filename
  Load the binary file and reboot the Propeller to run it.
  Forces .BIN extension whether it or any other is specified.

DUMP filename [|more]
  Display the file contents in hex and ASCII format.
  |more -- pause between screens, ESC to quit
  ctrl-C cancels

SD sectornum [|more]
  Sector Dump = display contents of the given SD sector
  in the Dump command format.
  
ROOTDIR
  Display the SD sector where the root directory begins

CHAIN filename [|more]
  Display the file's FAT cluster chain.
  |more -- pause between screens, ESC to quit
  ctrl-C cancels

CLUST2SD clusternum
  Display the SD sector where DOS cluster begins

VER
  display the version

COLOR colornum
  Sets the tv_text display text color 0-7.
  
NUM number
  Display the hex and decimal equivalents of number.
  If number has no prefix or $, it is hexadecimal
  # prefix means decimal, e.g. B == $B == #11
  This format is used for all numeric arguments.

DIRA pin [value]
  If value is supplied, set the given pin DIRA to
  the value; otherwise display the pin DIRA value.

OUTA pin [value]
  If value is supplied, set the given pin OUTA to
  the value; otherwise display the pin OUTA value.

PULSE pin time
  Invert the given pin OUTA for the time in system
  waitcnt ticks.

INA pin
  Display the INA value for the pin.

PropCMD does not attempt to SPIN commands it does not
recognize; it will reply Unknown Command.

Note that while this code observes the directory Hidden
Attribute bit, there are no functions to manipulate it.
fsrw does not expose this functionality and I would
rather work on a totally new filesystem capable of
opening multiple files than further patching to fsrw.

VIDEO DRIVERS -- by popular demand this is supplied with
the 25 line aigeneric driver, which is now MIT licensed.
I have left the commented-out code for using the Parallax
tv_text driver, which you can find by inspecting the
documentation view or searching text for "aigeneric."
Switching to tvtext limits you to 13 lines on the display,
but frees up about 400 longs of hub RAM for data and other
functions you might wish to add.

}}

CON
  ' I/O SETTINGS

   _clkmode  = xtal1 + pll16x
   _xinfreq  = 5_000_000
  ''
  '' Adjust for typical location of the keyboard.
  keyboard  = 26

  '' Adjust for the location of the video pingroup base
  video     = 12
   
  '' Adjust for location of the SD card.
{
  '' Typical Hydra Configuration: 0-7 Left for NES/Audio Connections
  
   spiDO     = 16
   spiClk    = 17
   spiDI     = 18
   spiCS     = 19
}

  '' Typical Demoboard/Protoboard Configuration
  
   spiDO     = 0
   spiClk    = 1
   spiDI     = 2
   spiCS     = 3

  '' Adjust for screen driver rows
{  
  screenrows = 13  'for tv_text
}
  screenrows = 25  'for aigeneric 


  bkspKey   = $C8
  escKey    = $CB
  ctlcKey   = $0263
  ctlzKey   = $027A
  
  USCORE    = $5F
  BKSP      = $08
  TAB       = $09
  LF        = $0A
  CR        = $0D
  CTLZ      = $1A
  ESC       = $1B
  SPC       = $20
   
OBJ
     key   : "comboKeyboard"             ' Keyboard Driver
     ''
     '' uncomment the desired video driver
{
     text  : "tv_text"                   ' Parallax 13-line Video
}
     text  : "aigeneric_driver"          ' AiGeneric 25-line Video 

{    the aigeneric driver requires the files
        AiGeneric_Driver.spin
        AiGenericDriver_002.spin
        AiGenericDriver_TV.spin  ... and ...
        Font_ATARI.spin.
     the tv_text driver is supplied with the PropTool.}
     
     fsrw  : "fsrwFemto"                 ' Modified SD routines
      
VAR
     byte inputbuffer[64]
     byte inputfields
     byte inputparse[7]
     byte cmd
     byte arg1
     byte arg2
     byte arg3
     byte OptWide
     byte OptMore
     byte OptPRN
     byte OptWC
     byte Lcount
     byte EscLock
      
     byte Mounted
     
     byte dirbuf[fsrw#DIRSIZE] ' 
     byte fileext[4]
     byte numbuf[12]
     long ioControl[2]
     byte secbuf[fsrw#SECTORSIZE] ' sector data buffer
   
PUB mainProgram  | r, i 

  key.start(keyboard)
  text.start(video)
  fsrw.start(@ioControl)                         ' Start SPI driver

  '' comment this out if using the aigeneric driver, or if you
  '' like the hideous default palette provided with tv_text
' text.setcolors(@alt_palette)
   
  dosver
  
  Mounted := (\fsrw.mount(spiDO,spiClk,spiDI,spiCS) => 0)
  waitcnt(clkfreq + cnt)

  ' If keyboard present, check for the ESC key to bypass autostart
  ' Note the esclock, which prevents the escapes from scrolling
  ' down the screen if this bypass succeeds; once PropCMD starts
  ' escape is ignored until some other character is pressed.
  '
  esclock := -1
  if mounted
    r := true
    if key.present
      i:=key.key
      if i == esckey
        r := false
    if r
      r := fsrw.popen(string("autoexec.bat"),"r")
      if r => 0
        text.str(string("AUTOEXEC.BAT found...",cr))
        repeat while r => 0
         r := fsrw.pgetc
          if r == spc or r == cr or i == 14
            inputbuffer[i] := 0
            quit
          else
            inputbuffer[i] := r
          i++
        fsrw.pclose
        arg1 := 0
        spin
       
  ' Since we're not autostarting there's not much point
  ' going on if there's no keyboard.
  '             
  if not key.present                                
     text.str(string(CR,"No keyboard present",CR))
     text.str(string("Keyboard expected on: "))
     text.dec(keyboard)
     text.str(string(CR,CR,"System halted.",CR))
     abort

  ' MAIN COMMAND LINE INTERPRETER LOOP
  '
  repeat

    if mounted   
      text.str(string("SD:\>"))
    else
      text.str(string("No Volume:>"))
      
    if input(@inputbuffer,64) == cr
      ucase(@inputbuffer)
      parse(@inputbuffer)
      cmd := inputparse[0]
      arg1 := inputparse[1]
      arg2 := inputparse[2]
      lcount := 0
      if inputbuffer[0] <> 0
        \DosCmd
    else
      text.out(cr)
         
PRI DosCmd |  r,i   
  '
  ' This looks horrible, but when I implemented a lookup table and
  ' used a case statement it was neither smaller nor faster, and
  ' greatly complicated the task of adding a command.  
  '
  ' We start with commands that don't need a volume mounted
  '
  if strcomp(@inputbuffer+cmd,string("MOUNT"))
    if mounted
      text.str(string("Volume Already Mounted.",cr))
    else
      r := \fsrw.mount(spiDO,spiClk,spiDI,spiCS)
      if r => 0
        mounted := true
      else
        'hint: try plugging in the SD card
        text.str(string("Mount Failed: Error "))
        text.hex(r,9)
        text.out(cr)
    return
   
  if strComp(@inputbuffer+cmd,string("CLS"))
    text.out($00) 
    return

{' This is useful if using tv_text...   
  if strComp(@inputbuffer+cmd,string("COLOR"))
    doscolor(numfromarg(@inputbuffer+arg1))
    return
}   
  if strComp(@inputbuffer+cmd,string("REBOOT"))
    reboot

  if strComp(@inputbuffer+cmd,string("NUM"))
    i := numfromarg(@inputbuffer+arg1)
    text.out("$")
    text.hex(i,8)
    text.str(string(" = #"))
    text.dec(i)
    text.out(cr) 
    return

  if strComp(@inputbuffer+cmd,string("VER"))
    dosver
    return 

  if strComp(@inputbuffer+cmd,string("DIRA"))
    if inputfields < 2
      abort
    i := numfromarg(@inputbuffer+arg1)
    if inputfields < 3
      'no value set, display
      text.str(string("Pin $"))
      text.hex(i,2)
      text.str(string(" DIRA = "))
      text.dec(dira[i])
      text.out(cr)
    else
      dira[i] := numfromarg(@inputbuffer+arg2)
    return            

  if strComp(@inputbuffer+cmd,string("OUTA"))
    if inputfields < 2
      abort
    i := numfromarg(@inputbuffer+arg1)
    if inputfields < 3
      'no value set, display
      text.str(string("Pin $"))
      text.hex(i,2)
      text.str(string(" OUTA = "))
      text.dec(outa[i])
      text.out(cr)
    else
      outa[i] := numfromarg(@inputbuffer+arg2)
    return            

  if strComp(@inputbuffer+cmd,string("PULSE"))
    if inputfields < 3
      abort
    i := numfromarg(@inputbuffer+arg1)
    r := numfromarg(@inputbuffer+arg2)
    !outa[i]
    waitcnt(r + cnt)
    !outa[i]
    return          

  if strComp(@inputbuffer+cmd,string("INA"))
    if inputfields < 2
      abort
    i := numfromarg(@inputbuffer+arg1)
    text.str(string("Pin $"))
    text.hex(i,2)
    text.str(string(" INA = "))
    text.dec(ina[i])
    text.out(cr)
    return

  if mounted

    if strcomp(@inputbuffer+cmd,string("DIR"))
      dosdir
      return
     
    if strcomp(@inputbuffer+cmd,string("UNMOUNT"))
      \fsrw.unmount
      mounted := false 
      return
     
    if strComp(@inputbuffer+cmd,string("TYPE"))
      dostype
      return
     
    if strComp(@inputbuffer+cmd,string("DEL"))
      r := fsrw.popen(@inputbuffer+arg1,"d")
      if r < 0
        text.str(string("File "))
        text.str(@inputbuffer+arg1)
        text.str(string(" Not Found.",cr))
      else        
        text.str(string("File "))
        text.str(@inputbuffer+arg1)
        text.str(string(" Deleted.",CR)) 
      return
      
    if strComp(@inputbuffer+cmd,string("COPY"))
      if not strcomp(@inputbuffer+arg1,string("CON"))
        text.str(string("File copy not supported.",cr))
      else     
        r := fsrw.popen(@inputbuffer+arg2,"w")
        if r < 0
          text.str(string("Could not open file "))
          text.str(@inputbuffer+arg2)
          text.str(string(".",cr))
        repeat
          r := input(@inputbuffer,39)
          if r == ctlz
            fsrw.pclose
            text.out(cr)
            quit
          elseif r == esc
            text.str(string("/Line",cr))
          else
            i := 0
            repeat while inputbuffer[i] <> 0 
              fsrw.out(inputbuffer[i])
              i++
            fsrw.out(13) 
      return
             
    if strComp(@inputbuffer+cmd,string("DUMP"))
      dosdump
      return
     
    if strComp(@inputbuffer+cmd,string("ROOTDIR"))
      text.str(string("Root Directory at SD Sector $"))
      text.hex(fsrw.dos_rootdir,6)
      text.out(13)
      return
        
    if strComp(@inputbuffer+cmd,string("FAT"))
      text.str(string("FAT at SD Sector $"))
      text.hex(fsrw.dos_fat,6)
      text.out(13)
      return
     
    if strComp(@inputbuffer+cmd,string("SD"))
      secdump
      return
     
    if strComp(@inputbuffer,string("CLUST2SD"))
      clust2sd
      return
     
    if strComp(@inputbuffer,string("CHAIN"))
      doschain
      return
     
    if strComp(@inputbuffer,string("SPIN"))
      'attempt to autoexecute a .bin
      'copy filename base to dirbuf
      spin
      return

    'if you don't want PropCMD to autospin anything you type
    'on the command line, comment the next three lines out

    arg1 := cmd  'I know this is so lazy it is totally evil,
                 'but then again you can't pass args to a spin
    spin
    return
     
  text.str(string("Unknown or Invalid Command.",cr))
     
' individual command handlers

pri dosver
  text.str(string("PropCMD V1.01 April 4, 2009",CR,"by Roger Williams",CR))

pri spin | i, j
  repeat i from 0 to 7
    j := byte[@inputbuffer+arg1+i]
    if j == 0 or j == "."
      quit
    else
      dirbuf[i] := j
  'force .bin extension
  strcopy(string(".BIN"),@dirbuf+i)
  if fsrw.popen(@dirbuf,"r") < 0
    text.str(string("Could not open file "))
    text.str(@dirbuf)
    text.str(string(".",cr))
  else
    fsrw.bootSDCard


pri doscolor(c)
  if c < 0 or c > 7
    text.str(string("Valid Colors are 0-7.",cr))
  else
    text.out($0c)
    text.out(48+c) 

pri clust2sd | aclust
  aclust := numfromarg(@inputbuffer+arg1)
  text.str(string("Cluster $"))
  text.hex(aclust,4)
  text.str(string(" at Sector $"))
  text.hex(fsrw.dos_clust2sd(aclust),6) 
  text.out(cr)

{ This is truly a kludge from hell.  In fsrw the functionality
  to locate a file's directory entry by its filename is deeply
  buried in popen.  So we just open the file and by inspection
  we find that fclust will be positioned to point at the first
  cluster.  Then of course the rest of the function is pure
  hand coding for similar reasons.  Originally I just had the
  cluster number as the argument, figuring that you could get
  that from DIR, but I found it annoying.}
  
pri doschain | r, aclust, l, sn, sl, erc 
  r := fsrw.popen(@inputbuffer+arg1,"r")
  if r < 0
    text.str(string("Could not open file: "))
    text.str(@inputbuffer+arg1)
    text.out(cr)
    return
  aclust := fsrw.dos_fclust
  optmore := checkoption(1,string("|MORE"))
  repeat
    l += 1
    if l>6
      lmore(0)
      l:=0
    text.hex(aclust,4)
    text.out(spc)
    if aclust<2 or aclust>$fff0
      if l <> 0
        lmore(0)
      quit
    sn := fsrw.dos_fat + (aclust >> 8)
    if sn<>sl
      erc := fsrw.readSDCard(sn, @secbuf, fsrw#SECTORSIZE)
      if erc < 0
        if l <> 0
          lmore(0)
        text.str(string("Could not read FAT sector $"))
        text.hex(sn,6)
        lmore(0)
        return
      sl := sn
    sn := (aclust & $ff) << 1
    aclust :=  byte[@secbuf+sn] + byte[@secbuf+sn+1]<<8        

PRI secdump | sdsec, erc, c, r, w, adx, v
  sdsec := numfromarg(@inputbuffer+arg1)
  optmore := checkoption(1,string("|MORE"))
  w := 8
  if checkoption(1,string("/W"))
    w := 16
  erc := fsrw.readSDCard(sdsec, @secbuf, fsrw#SECTORSIZE)
  if erc < 0
    text.str(string("Could not read SD sector $"))
    text.hex(sdsec,6)
    text.out(cr)
    return
  text.str(string("SD Sector "))
  text.hex(sdsec,6)
  text.out(58)
  text.out(cr)
  adx := 0
  repeat while adx < fsrw#sectorsize
    text.hex(adx,4)
    text.str(string(":"))
    c := 0
    repeat while c < w
      v := adx + c
      text.out(spc)
      text.hex(secbuf[v],2)
      c++
    c := 0
    text.out(spc)
    repeat while c < w
      v := adx + c
      r := secbuf[v]
      c++
      if r =< 1 or (r => bksp and r =< cr)
        text.out(46)
      else
        text.out(r)
    adx += 8
    if not lmore(0)
      return
     
PRI dosdump | r, c, lc[15], w, adx, atend
  r := fsrw.popen(@inputbuffer+arg1,"r")
  if r < 0
    text.str(string("Could not open file: "))
    text.str(@inputbuffer+arg1)
    text.out(cr)
    return
  optmore := checkoption(1,string("|MORE"))
  w := 8
  if checkoption(1,string("/W"))
    w := 16
  adx := 0
  atend := false
  repeat until atend
    text.out(spc)
    text.hex(adx,4)
    text.str(string(":"))
    c := 0
    repeat while c < w  
      r := fsrw.pgetc
      if r < 0
        text.str(string("   "))
        atend := true
        lc[c] := -1
      else
        text.out(spc)
        text.hex(r,2)
        lc[c] := r
      c++
    c := 0
    text.out(spc)
    repeat while c < w
      r := lc[c]
      if r =< 1 or (r => bksp and r =< cr)
        text.out(46)
      else
        text.out(r)
      c++
    adx += 8
    if not lmore(0)
      return

PRI dosdir | opthid, optc, r, i,  opt1, c, hidden, b, fs

  opt1 := 1
  optwc := false
  if word[@inputbuffer+arg1] == $2e2a  '*.
    optwc := true
    arg1 += 2
    opt1++
  opthid := checkoption(opt1,string("/H"))
  optc := checkoption(opt1,string("/C"))
  optmore := checkoption(opt1,string("|MORE"))
  optwide := checkoption(opt1,string("/W"))
  '
  text.out(cr)
  text.str(string("Directory of SD"))
  lmore(0)
  lmore(0)
  fsrw.opendir
  b := 0
  repeat
    'get next file    
    c := fsrw.nextfile(@dirbuf)
    if c == -1
      'we are finished
      if b > 0
        lmore(0)
      lmore(0)
      quit
      
    hidden := false
    
    if optwc
      'extract extension 
      repeat i from 0 to 2
        c := dirbuf[i+8]
        if c == spc
          fileext[i] := 0
        else
          fileext[i] := c
      'null terminate
      fileext[3] := 0
      'compare with pattern
      if not strcomp(@fileext,@inputbuffer+arg1)
        hidden := true

    if not opthid
      c := dirbuf[$B] 'attribute byte
      if c & 2        'hidden bit                
        hidden := true
   
    if not hidden

      if optwide
        'see if we need a CR
        c := 13
        if optc
          c += 5
        b += c
        if b > 39 
          if not lmore(0)
            return
          b := c
      else
        'display the file size
        'we can't use long[] unless the offset into the dirbuf is word aligned
        'this always works...
        fs := byte[@dirbuf+$1C] + byte[@dirbuf+$1D]<<8 + byte[@dirbuf+$1E]<<16 + byte[@dirbuf+$1F]<<24
        outdec(fs,10)
        text.out(spc)
        if opthid 
          c := dirbuf[$B] 'attribute byte
          if c & 2        'hidden bit
            text.out("H")
          else
            text.out(spc)                                                             
          text.out(spc)                                                             
           
      'always display the filename at fixed length
      r := 0
      repeat i from 0 to 7
        c := dirbuf[i]
        if c <> spc    
          text.out(c)
          r++
      if dirbuf[8] <> spc
        text.out(".")
        r++
        repeat i from 8 to 10
          c := dirbuf[i]
          if c <> spc    
            text.out(c)
            r++
      repeat while r < 13
        text.out(spc)
        r++

      if optc
        text.out("$")
        text.hex(byte[@dirbuf+$1B],2)
        text.hex(byte[@dirbuf+$1A],2)
        text.out(spc)
        
      if not optwide
        'displayed file size already, now cr/more
        if not lmore(0)
          return
     
pri dostype | r, c
  r := fsrw.popen(@inputbuffer+arg1,"r")
  if r < 0
    text.str(string("Could not open file: "))
    text.str(@inputbuffer+arg1)
    text.out(cr)
    return
  optmore := checkoption(1,string("|MORE"))
  r := 0
  repeat
    c := fsrw.pgetc
    if c < 0
      text.out(cr)
      fsrw.pclose
      return
    if c > 0
      if c == cr
        r := 0
        if not lmore(0)
          fsrw.pclose
          return
      elseif c>1 and (c < bksp or c > cr)
        text.out(c)
        r++
        if r == 40
          'wrapped to next line
          r := 0
          if not lmore(true)
            fsrw.pclose
            return

' functions used by commands
           
pri numfromarg(s) | nbase, c
  nbase := 16
  result := 0
  repeat 
    c := byte[s]
    s++
    if c == 0
      return
    elseif c == "$" '$=hex
      nbase := 16
    elseif c == "#"
      nbase := 10
    else
      if c => "a"
        c := c - constant("a"-10)
      elseif c => "A"
        c := c - constant("A"-10)
      elseif c => "0"
        c := c - "0"
      result := result * nbase + c
      
pri lmore(nocr) | c
  result := true
  if nocr == 0
    text.out(cr)
  c := key.key
  if c == ctlckey
    abort
  if optmore
    lcount++
    if lcount > screenrows - 2
      text.str(string("-more-"))
      c := key.getkey
      if c == esckey or c == ctlckey
        text.str(string(" (aborted)",cr))
        return false
      repeat 6
        text.str(string(bksp,spc,bksp))
      lcount := 0
    
{ input collects up to size-1 characters of keyboard
  input, ending on CR or ESC and properly handling
  backspace. Returns cr, esc, or ctlz. }
     
pri input(buffer, size) | c, cursor
  'NB size is size of input buffer; user can enter
  '1 fewer characters than this due to null term
  byte[buffer] := 0
  c:=0
  cursor:=0
  text.out(uscore)
  repeat
    c := key.key
    if c <> 0

      if c <> esckey 
        esclock := 0
        
      if c == bkspkey
        if cursor > 0
        byte[buffer--] := 0
        cursor--
        text.str(string(bksp,spc,bksp,bksp,spc,bksp,uscore))
        c := 0

      elseif c == cr
        text.str(string(bksp,spc,bksp,cr))
        return c
         
      elseif c == esckey and not esclock
        text.str(string(bksp,spc,bksp))
        return esc
      
      elseif c == ctlzkey
        text.str(string(bksp,spc,bksp))
        return ctlz

      elseif c > 31 and c < 127
        if cursor < size
          text.out(bksp)
          text.out(c)
          text.out(uscore)
          byte[buffer++] := c
          cursor++
          byte[buffer] := 0
                  
{ parse locates up to 8 space delimited subfields in the
  buffer and returns pointers to them in inputparse[],
  setting inputfields to the number found. Found fields
  are zero terminated where they lay so they can be
  treated as separate ordinary strings. }

pri parse(buffer) | cursor, c
  'not all code checks to see if an option actually exists,
  'so default all results to point at the null terminator
  cursor := strsize(buffer)
  repeat c from 0 to 7
    inputparse[c] := cursor
  cursor := 0
  inputfields := 0
  'advance to next nonspace character
  'or find end of string
  repeat
    repeat
      c := byte[buffer][cursor++]    
      if c == 0
        return
      if c <> spc
        quit
    inputparse[inputfields] := cursor-1
    inputfields++
    if inputfields > 7
      return
    'advance to next space or find end
    repeat
      c := byte[buffer][cursor++]
      if c == 0
        return
      if c == spc
        byte[buffer][cursor-1] := 0
        quit    
        
' Check for an option.  We have to tell it the first argument
' in the split command line to check because this routine
' doesn't know how many fixed-position arguments might be
' required or found.
'
PRI CheckOption(FirstArg, Opt) | n
  n := 1
  repeat while n < inputfields
    if strcomp(@inputbuffer+inputparse[n],opt)
      result := true
    n++

' The text.dec method doesn't provide for fixed digits

PRI outdec(value,len) | j

  j := len
  byte [@numbuf+j] := 0
  j--
  repeat
    byte[@numbuf+j] := value // 10 + "0"
    j--
    value /= 10
    if value == 0 or j == 0
      quit
  repeat
    if j < 0
      quit
    byte [@numbuf+j] := spc
    j--
  text.str(@numbuf)
       
PRI strcopy(src,dest) | c
  c := -1
  repeat while c <> 0
    c := byte[src]
    byte[dest] := c
    src++
    dest++

PRI ucase(astr) | c
  repeat
    c := byte[astr]
    if c == 0
      quit
    if c => "a" and c =< "z"
        byte[astr] := c - constant("a" - "A")
    astr++
{
dat
''
'' This DAT block can be omitted if using the aigeneric driver
'' or the default palette for tv_text.

alt_palette     byte    $07,   $02    '0    white / black (background)
                byte    $07,   $02    '1    white / black
                byte    $6B,   $02    '2    green / black
                byte    $0A,   $02    '3     blue / black
                byte    $02,   $07    '4    black / white
                byte    $BB,   $07    '5      red / white
                byte    $07,   $BB    '6    white / red
                byte    $07,   $0A    '7    white / blue
}
{{

                                                   TERMS OF USE: MIT License                                                                                                              

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation     
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:                                                                   
                                                                                                                              
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                                                                                                                              
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         
}}