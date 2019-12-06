'' prop_backpack_tv_overlay2
''
'' Copyright (c) 2010 Philip C. Pilgrim
'' (See end of file for terms of use.)
''
''-----------[ Description ]----------------------------------------------------
''
'' This Propeller object provides video character overlay capabilities to the
'' Propeller Backpack as defined in the PDF on the Propeller Backpack product
'' page. (Go to www.parallax.com and "Search" for 28327.) In addition, this
'' version of the program provides the capability to define and animate one's                              
'' own character glyphs. See the comments below for the additional documentation.
''
''-----------[ Revision History ]-----------------------------------------------
''
'' 2010.07.27: Initial version, based on "prop_backpack_tv_overlay" object.
''
''-----------[ Program ]--------------------------------------------------------

CON

  VIDIN         = 22            'Video input pin for sync extraction.
  CLAMP         = 19            'Sync level clamp output pin.
  VIDSW         = 11            'Video in -> video out gating pin.
  VIDOUT        = 8             'Video out 8-bit bank (not all pins are used).

  PINOFFSET     = 3             'Offset of first video output pin from beginning of bank.
  CLKSPERPIXEL  = 8             'Timing info for video.
  MAXCOLS       = 44            'Maximum number of character columns per window.
  MINTWIN       = 60            'Minimum index for a time/date window.

' Template of byte offsets in slot long.

  WINNO         = 0             'Window number.
  XPOS          = 1             'X position of upper left-hand corner.
  YPOS          = 3             'Y position of upper left-hand corner.

' Template of bits in slot long.

  SHOWSLT       = 1 << 6        'Bit 0 of XPOS.  Set to make window visible.
  LASTSLT       = 1 << 7        'Bit 7 of WINNO. Set to indicate last window in display.

' Template of byte offsets in window header.

  FLAG          = 0             'Flag bits.
  XDIM          = 1             'Width in character columns.
  YDIM          = 2             'Height in character rows.
  XYSCROLL      = 3             'Current horizontal and vertical smooth scroll in fractions of a character.
  MASK_TRANS    = 4             'Window transparency.
  FG_BG         = 5             'Foreground and background "colors".
  XCUR          = 6             'Cursor column position.
  YCUR          = 7             'Cursor row position.
  AUTOSCROLL    = 8             'Smooth scrolling speed.

  HEADERSIZE    = 9             'Length of window header in bytes.

  ' FLAG bits.

  DOUBLEWIDE    = 1 << 0        'Double wide characters.
  DOUBLEHIGH    = 1 << 1        'Double high characters.
  BLINKING      = 1 << 2        'Switch to cause foreground to blink against background.
  WORDWRAP      = 1 << 3        'Switch to enable automatic word wrapping.
  TYPE          = $0f << 4      'Window type: 0 - 15.

  ' Status bits.

  BLANKING      = 1 << 0        'Display is blanking: safe to change window.
  GOTSYNC       = 1 << 1        'Sync has been acquired.

  'Commands recognized by "out" method.

  CLS           = $00           '( ) Clear the current window, and home cursor.
  HOME          = $01           '( ) Move cursor to home position.
  CRSRXY        = $02           '(col,row) Move cursor to col and row.
  CRSRLF        = $03           '( ) Move cursor to the left.
  CRSRRT        = $04           '( ) Move cursor to the right.
  CRSRUP        = $05           '( ) Move cursor up.
  CRSRDN        = $06           '( ) Move cursor down.
  SHODSP        = $07           '(dispno) Show display number dispno.
  BKSP          = $08           '( ) Erase prior character and move cursor left.
  TAB           = $09           '( ) Move cursor right to next column divisible by 8.
  LF            = $0A           '( ) Linefeed. Scroll up if on bottom line.
  CLREOL        = $0B           '( ) Clear to the end of the current line.
  CLRDN         = $0C           '( ) Clear from cursor position to the end of the window.
  CR            = $0D           '( )Carriage return. Scroll up if necessary.
  CRSRX         = $0E           '(col) Move cursor to column col.
  CRSRY         = $0F           '(row) Move cursor to row.
  DEFWIN        = $10           '(winno,cols,rows) Define a new window winno sized cols x rows. Make it the current window.
  USEWIN        = $11           '(winno) Change the current window to winno.
  CHGCLR        = $12           '(mask,transparent,fgnd,bkgd) Change current window color to mask, transparent, fgnd, and bkgd.
  SCROLL        = $13           '(offset) Set X (one-line) or Y (multi-line) scroll offset (0 - 15) for current window.
  SMSCRL        = $14           '(rate) Set smooth scrolling rate in current window to rate ms/scan line.
  WDWRAP        = $15           '(yn) Set word wrapping for current window: on (yn<>0) or off (yn==0).
  BLINK         = $16           '(yn) Set blinking for current window: on (yn<>0) or off (yn==0).
  CPYWIN        = $17           '(winno) Copy contents of winno to current window.
  APNDSP        = $18           '(disp,winno,x,y) Append window winno to display disp at location (x,y).
  MOVWIN        = $19           '(slot,x,y) Move window in slot to (x,y).
  SHOWIN        = $1A           '(slot,yn) Show window in slot: yes (yn<>0) or no (yn==0).
  CHGWIN        = $1B           '(slot,winno) Change window in slot to winno.
  PRESET        = $1C           '(dispno,presetno) Create display dispno using preset presetno.
  SETTIM        = $1D           '(yr,mo,day,hr,min,sec) Set the current time.

  MARK          = $1E           '( )Return MARK to acknowledge reaching this point.
  ESC           = $1F           '(char) Escape next character char (i.e. print as-is).

  CLRWIN        = $FF           '( )Same as CLS where strings do not permit 0.
  NONE          = $FF
  ZERO          = $FF           'Same as 0 when used as an argument.
  _0            = $FF
  NO            = $FF
  YES           = $01

  DBL           = $80           'OR with height and width arguments to get double-sized characters.
  SHO           = $40           'OR with window number to set visibility on.

  'Preset names.

  BIGWIN        = $01           '40 x 13 regular window.
  CREDITS       = $02           'Vertically overscanned window with smooth scrolling.
  MARQUEE       = $03           'Single row at bottom with smooth scrolling.
  HILO          = $04           'Single rows top and bottom.
  HILO2         = $05           'Dual rows top and bottom.
  DATETIME      = $06           'Date and time in lower right-hand corner.
  HIDATTIM      = $07           'Same as DATETIME with message row along top.
  CROSS         = $08           'Single cross-shaped cursor in middle of 40 x 13 screen.
  BOX           = $09           'Single box-shaped cursor in middle of 40 x 13 screen.
  DOT           = $0A           'Single dot cursor in middle of 40 x 13 screen.

  ' Window type names.

  REGWIN        = 0             'Regular window.
  HMS24         = 1             'Time window: [ 23:59:59 ]
  HMS12         = 2             'Time window: [12:59:59pm]
  YMD           = 3             'Date window: [2099-12-31]
  MDY           = 4             'Date window: [12/31/2099]
  DMY           = 5             'Date window: [31-12-2099]
  YMDHMS24      = 6             'Date/time window: [2099-12-31 23:59:59]
  MDYHMS12      = 7             'Date/time window: [12/31/2099 12:59:59pm]
  DMYHMS12      = 8             'Date/time window: [31-12-2099 12:59:59pm]

PUB start(bufaddr, bufsize) | i, n, usersize

'' Startup routine. Requires the address of an external byte buffer of length bufsize.
''
'' The parameter bufsize may also contain, in its upper 16 bits, a count of how much
'' upper RAM to set aside for user-defined characters. This RAM will be set aside in
'' 1024-byte blocks, each block corresponding to 16 characters, starting from character
'' $F0, and working downwards ($E0, $D0, etc.). Once reserved thus, the corresponding ROM
'' character glyphs are copied into RAM, where they can be changed by the user at any
'' time, thus effecting animation, if so desired.
''
'' Since the RAM area used by these glyphs resides in unallocated upper RAM (beginning
'' at $7FFF and working downward), it is necessary for the user's main program to
'' reserve this memory using the _free constant thus:
''
''   CON
''
''
''     USER_BLOCKS = 2             'Can range from 0 to 16.
''     _free = 256 * USER_BLOCKS
''
'' Then, when calling start, including USER_BLOCKS in tthe call, thus:
''
''     overlay.start(@buffer, USER_BLOCKS << 16 | BUFSIZE)
''
'' For compatibility with the original prop_backpack_tv_overlay, the
'' USER_BLOCKS stuff can be omitted if no user charater glyph definitions
'' are needed.
''
'' This method starts a new cog and returns its address + 1; 0 if unsuccessful.

  stop
  bufptr := bufaddr & $7fff
  bufmax := (bufaddr + bufsize) & $7fff
  displayptr := @slotlist
  activewindow~
  longfill(@slotlist, 0, 96)
  font_addr := $8000
  if (usersize := (bufsize >> 16) <# 16)
    n := usersize << 10
    longmove($8000 - n, $c000 - n, n >> 2)
    font_addr -= n
  repeat i from 0 to 15
    translate[i] := ((i + usersize) ^ i) << 4
  trsp := tr(" ")
  trhy := tr("-")
  return ((cogno := cognew(@display, @displayptr) + 1) <> 0) & @displayptr
   
PUB stop

'' Stops the overlay.

  if (timecogno)
    cogstop(timecogno - 1)
    lockret(timelock)
    timecogno~
  if (cogno)
    cogstop(cogno - 1)
    cogno~
    return true
  else
    return false

PUB setchar (character, glyphaddr) | i, j, rampix, usrpix, ramaddr, baseaddr

'' Replace the single glyph in the RAM font with a new glyph, beginning at
'' location glyphaddr. The new glyph must include 32 words, arranged top
'' to bottom. Bit 15 of each word represents the leftmost pixel; bit 0,
'' the rightmost.

  if ((baseaddr := getglyphaddr(character)) < $8000)
    repeat i from 0 to 31
      ramaddr := baseaddr + (i << 2)
      rampix := (long[ramaddr] -> (character & 1)) & $aaaa_aaaa
      usrpix := word[glyphaddr + (i << 1)] -> 16
      repeat j from 0 to 15
        rampix := (rampix | (usrpix <-= 1) & 1) -> 2
      long[ramaddr] := rampix <- (character & 1)

PUB setpair (charpair, glyphaddr)

'' Set font for the character pair indicated by charpair (even number)
'' to the glyphs contained in the 32 longs at glyphaddr. The format
'' of the new pair in memory must match the interleaved format of characters
'' in ROM.

  longmove(getglyphaddr(charpair), glyphaddr, 32)

PUB getglyphaddr (c)

'' Return the address of the glyph indicated by c (even number).

  return font_addr + (tr(c) >> 1 << 7)

PUB getstatus

'' Returns the current status byte:
''
'' +---+---+---+---+---+---+---+---+
'' | 0   0   0   0   0   0 | S | B |
'' +---+---+---+---+---+---+---+---+  , where
''
'' S is set to one when the overlay has locked onto the incoming video's sync, and
'' B is set to one during vertical blanking, during which time screen updates can
''   be made glitch-free.

  return status

PUB presetdisplay(dispno, presetnumber)

  case presetnumber
    BIGWIN:
      newwindow(dispno, 40, 13)
      appendtodisplay(dispno, SHO|dispno, 0, 26)
    CREDITS:
      newwindow(dispno, 40, 17)
      smoothscroll(50)
      colorcurrentwindow($fba0)
      appendtodisplay(dispno, SHO|dispno, 0, 1)
      str(string(CRSRXY, _0, 16))
    MARQUEE:
      newwindow(dispno, 42, 1)
      appendtodisplay(dispno, SHO|dispno, 0, 225)
      colorcurrentwindow($f680)
      smoothscroll(8)
    HILO:
      newwindow(dispno + 1, 40, 1)
      newwindow(dispno, 40, 1)
      appendtodisplay(dispno, SHO|dispno, 0, 26)
      appendtodisplay(dispno, SHO|(dispno + 1), 0, 223)
    HILO2:
      newwindow(dispno + 1, 40, 2)
      newwindow(dispno, 40, 2)
      appendtodisplay(dispno, SHO|dispno, 0, 26)
      appendtodisplay(dispno, SHO|(dispno + 1), 0, 207)
    DATETIME:
      newwindow(60, 0, YMDHMS24)
      appendtodisplay(dispno, SHO|60, 2125, 225)
    HIDATTIM:
      newwindow(60, 0, YMDHMS24)
      newwindow(dispno, 40, 1)
      appendtodisplay(dispno, SHO|dispno, 0, 26)
      appendtodisplay(dispno, SHO|60, 2125, 225)         
    CROSS:
      newwindow(dispno, 2, 1)
      str(string(ESC, $B4, ESC, $AF))
      colorcurrentwindow($8fa0)
      appendtodisplay(dispno, SHO|dispno, 1968, 116)
      usewindow(0)                                                                                                              
    BOX:
      newwindow(dispno, 2, 1)                                                                                                  
      str(string(ESC, $01, ESC, $09))
      colorcurrentwindow($8fa0)
      appendtodisplay(dispno, SHO|dispno, 1968, 116)
      usewindow(0)
    DOT:
      newwindow(dispno, 2, 1)
      str(string(" ", ESC, $0F))
      colorcurrentwindow($8fa0)
      scrollcurrentwindow(8,0)
      appendtodisplay(dispno, SHO|dispno, 1968, 116)
      usewindow(0)
  showdisplay(dispno)
     
PUB appendtodisplay(dispno, window, x, y) | i

'' Append the window to display number dispno (0 =< dispno =< 63) at position x, y.

  if (1 =< dispno and dispno =< 63 and 0 =< window and window =< 127)
    repeat i from dispno to 63
      if (slotlist[i] == 0)
        slotlist[i] := window | LASTSLT
        movewindow(i, x, y)
        if (i > dispno)
          slotlist[i - 1] &= !LASTSLT
        quit

PUB showdisplay(dispno)

'' Use the display list given by dispno (0 =< dispno =< 63).

  if (0 =< dispno and dispno =< 63)
    displayptr := @slotlist[dispno]

PUB movewindow(slotno, x, y) | xscale, yscale, window, winaddr

'' Change the screen position of the window in slot slotno to (x,y). 

  if (slotlist[slotno])
    window := slotlist[slotno] & $3f
    winaddr := windowlist[window]
    xscale := 1 - (byte[winaddr][FLAG] & DOUBLEWIDE <> 0)
    yscale := 1 - (byte[winaddr][FLAG] & DOUBLEHIGH <> 0) 
    if (x == 0)
      x := 2040 - byte[winaddr][XDIM] * xscale * 450 / 10 - xscale * 24
    if (y == 0)
      y := 131 - byte[winaddr][YDIM] * yscale * 8
    x := (x #> 0 <# 4041 - byte[winaddr][XDIM] * xscale * 447 / 5 - xscale * 141) + 800    
    y := y #> 1 <# 255
    slotlist[slotno] := slotlist[slotno] & $ff | x << 8 | y << 24
     
PUB showwindow(slotno, yn)

'' Set visibility of window in slot slotno: yn == 0: hide; yn <> 0: show.

  if (slotlist[slotno])
    slotlist[slotno] := slotlist[slotno] & !SHOWSLT | (yn <> false) & SHOWSLT

PUB changewindow(slotno, window) | winaddr, xscale, x

'' Change the window in slotno to window.

  if (slotlist[slotno] and 0 =< window and window =< 127)
    winaddr := windowlist[window & $3F]
    xscale := 1 - (byte[winaddr][FLAG] & DOUBLEWIDE <> 0)
    x := slotlist[slotno] >> 8 & $ffff <# 4841 - byte[winaddr][XDIM] * xscale * 447 / 5 - xscale * 141 
    slotlist[slotno] := slotlist[slotno] & $ff000080 | window & $7f | x << 8

PUB settime(yr, mo, da, hr, mn, sc) | i

  if (timecogno == 0)
    if ((timelock := locknew) < 0)
      return false
    if ((timecogno := cognew(timer, @tstack) + 1) == 0)
      lockret(timelock)
      return false
  repeat while lockset(timelock)
  repeat i from 0 to 5
    curtime[i] := yr[i]
  lockclr(timelock)
  return true
   
PUB newwindow(window, width, height) | flgs, req

'' Define a new window:
''   window = reference number (0 =< window =< 63),
''   x = display position of left edge,
''   y = display line of top edge,
''   width = width in character columns (< 0 for double wide characters),
''   height = height in character rows (< 0 for double high characters).   

  if (window < 1 or window > 63 or windowlist[window])
    return false
  if (width & $7f == 0 and window => MINTWIN)
    case height & $0f
      YMD, MDY, DMY, HMS24, HMS12: width := width & $80 + 10
      MDYHMS12, DMYHMS12: width := width & $80 + 21
      YMDHMS24: width := width & $80 + 19
    flgs := (height & $0f) << 4      
    height := height & $80 + 1
  else
    flgs~
  flgs |= (width & $80 <> 0) & DOUBLEWIDE
  width := (width & $7f) #> 2 <# MAXCOLS / (1 - (flgs & DOUBLEWIDE <> 0)) + (flgs & DOUBLEWIDE <> 0)
  flgs |= (height & $80 <> 0) & DOUBLEHIGH
  height := (height & $7f) #> 1
  req := HEADERSIZE + width * height + 1
  if (bufptr + req > bufmax)
    return false
  windowlist[window] := bufptr
  bufptr += req
  usewindow(window)
  _flag := flgs
  _xdim := width
  _ydim := height
  _xyscroll~
  _autoscroll~
  clearcurrentwindow
  colorcurrentwindow($faa0)
  return true

PUB usewindow(window)

'' Make window the current window for subsequent operations (0 =< window =< 63).
'' (Operations on window 0 have no effect.)

  updatewindow
  if(0 =< window and window =< 63)
    if (activewindow := windowlist[window])
      bytemove(@_flag, activewindow, HEADERSIZE)
      _base := activewindow + HEADERSIZE

PUB copytocurrentwindow(src) | srctype

'' Copy text of source window to destination window.

  if (activewindow and (src := windowlist[src]) and byte[src][XDIM] == _xdim and byte[src][YDIM] == _ydim and _flag & TYPE == 0)
    if (srctype := byte[src][FLAG] & TYPE)
      repeat while lockset(timelock)
    repeat until status & BLANKING
    bytemove(activewindow + 1, src + 1, HEADERSIZE + _xdim * _ydim)
    bytemove(@_flag + 1, activewindow + 1, HEADERSIZE - 1)
    if (srctype)
      lockclr(timelock)     
       
PUB clearcurrentwindow

'' Clear the current window.

  if (activewindow)
    bytefill(activewindow + HEADERSIZE, trsp, _xdim * _ydim + 1)
    _xcur~
    _ycur~
    updatewindow

PUB colorcurrentwindow(color)

'' Change the color scheme of the current window to color.

  _mask_trans := color >> 8
  _fg_bg := color
  updatewindow
   
PUB scrollcurrentwindow(xscroll, yscroll)

'' Change smooth scroll position of the current window to xscroll pixels left,
'' and yscroll pixels up. (Changes fine position within one character only.)

  _xyscroll := xscroll << 4 + yscroll & $0f
  updatewindow
   
PUB smoothscroll(pace)

'' Set the pace of smooth scrolling in current window.
'' pace == 0 turns off autoscrolling; pace > 0 is millisecond delay to scroll one pixel.

  _autoscroll := pace
  updatewindow
   
PUB wrapwords(yn)

'' Set word warap for current window: yn == 0: wrap off; yn <>0: wrap on.

  _flag := _flag & !WORDWRAP | (yn <> false) & WORDWRAP
  updatewindow
   
PUB setblink(yn)

'' Set blinking for current window: yn == 0: blink off; yn <>0: blink on.   
     
  _flag := _flag & !BLINKING | (yn <> false) & BLINKING
  updatewindow
   
PUB str(stringptr)

'' Print a zero-terminated string to the current window.

  repeat strsize(stringptr)
    out(byte[stringptr++])

PUB out(c) | i

'' Output character to current window and interpret embedded commands.

  if (nargs)
    arg0[--nargs] := c & (c <> ZERO)
    if (nargs== 0)
      case  cmd
        CRSRXY:
          _xcur := arg1 <# _xdim
          _ycur := arg0 <# _ydim - 1
          updatewindow
        CRSRX:
          _xcur := arg0 <# _xdim
          updatewindow
        CRSRY:
          _ycur := arg0 <# _ydim - 1
          updatewindow
        USEWIN: usewindow(arg0)
        MOVWIN: movewindow(arg2, arg1 * 1491 / 100, arg0)
        CHGCLR:
          _mask_trans := arg3 << 4 | arg2 & $0f
          _fg_bg := arg1 << 4 | arg0 & $0f
          updatewindow
        CPYWIN:
          copytocurrentwindow(arg0)
        SCROLL:
          if (_ydim == 1)
            scrollcurrentwindow(arg0, 0)
          else
            scrollcurrentwindow(0, arg0)
        SMSCRL: smoothscroll(arg0)
        SHOWIN: showwindow(arg1, arg0)
        CHGWIN: changewindow(arg1, arg0)
        PRESET: presetdisplay(arg1, arg0)
        APNDSP: appendtodisplay(arg3, arg2, arg1 * 1491 / 100, arg0)
        WDWRAP: wrapwords(arg0)
        BLINK: setblink(arg0)
        ESC: print(arg0)
        DEFWIN: newwindow(arg2, arg1, arg0)
        SHODSP: showdisplay(arg0)
        SETTIM: settime(arg5, arg4, arg3, arg2, arg1, arg0)          
  elseif (c == MARK)
    return MARK
  else
    case c
      CLS, CLRWIN: clearcurrentwindow
      HOME:
        _xcur~
        _ycur~
        'updatewindow
      CRSRLF:
        if (_xcur)
          _xcur--
        elseif (_ycur)
          _ycur--
          _xcur := _xdim - 1
        'updatewindow
      CRSRRT:
        if (_xcur < _xdim - 1)
          _xcur++
        elseif (_ycur < _ydim -1)
          _ycur++
          _xcur~
        'updatewindow
      CRSRUP:
        if (_ycur)
          _ycur--
        'updatewindow
      CRSRDN:
        if (_ycur < _ydim - 1)
          _ycur++
        'updatewindow
      BKSP:
        if (_xcur | _ycur)
          out(CRSRLF)
          print(" ")
          out(CRSRLF)
      TAB:
        repeat
          print(" ")
        while (_xcur & 7)
      LF:
        if (_ycur < _ydim - 1)
          out(CRSRDN)
        else
          i := _xcur
          out(CR)
          _xcur := i
          'updatewindow
      CLREOL:
        i := _xcur
        repeat _xdim - _xcur
          print(" ")
        _xcur := i
        'updatewindow
      CLRDN:
        if (activewindow)
          bytefill(_base + _ycur * _xdim + _xcur, trsp, _xdim * (_ydim - _ycur) - _xcur + 1)
      CR:
        repeat _xdim - _xcur // _xdim
          print(" ")
      CRSRX, CRSRY, SHODSP, USEWIN, CPYWIN, SCROLL, SMSCRL, WDWRAP, BLINK, ESC:
        cmd := c
        nargs := 1
      CRSRXY, SHOWIN, CHGWIN, PRESET:
        cmd := c
        nargs := 2
      DEFWIN, MOVWIN:
        cmd := c
        nargs := 3
      CHGCLR, APNDSP:
        cmd := c
        nargs := 4
      SETTIM:
        cmd := c
        nargs := 6
      other:
        print(c)
  return 0

PRI timer | systime, i, winaddr, wintype, n, typ

  systime := cnt
  repeat
    waitcnt(systime += clkfreq)
    repeat while lockset(timelock)
    if (++cursec > 59)
      cursec~
      if (++curmin > 59)
        curmin~
        if (++curhour > 23)
          curhour~
          if (++curday > lookup(curmonth: 31, 28 - (curyear & 3 == 0), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))
            curday := 1
            if (++curmonth > 12)
              curmonth := 1
              ++curyear
    repeat i from MINTWIN to 63
      if ((winaddr := windowlist[i]) and (typ := byte[winaddr][FLAG] >> 4))
        case typ
          HMS24: n := puthms24(@timebuf)
          HMS12: n := puthms12(@timebuf)
          YMD: n := putymd(@timebuf)
          MDY: n := putmdy(@timebuf)
          DMY: n := putdmy(@timebuf)
          YMDHMS24:
            n := putymd(@timebuf)
            n += puthms24(@timebuf + n)
          MDYHMS12:
            n := putmdy(@timebuf)
            timebuf[n++] := trsp
            n += puthms12(@timebuf + n)
          DMYHMS12:
            n := putdmy(@timebuf)
            timebuf[n++] := trsp
            n += puthms12(@timebuf + n)
        bytemove(winaddr + HEADERSIZE, @timebuf, n)
    lockclr(timelock)

PRI puthms24(addr)

  trmove(addr, string(" 00:00:00 "), 10)
  putdec2(addr + 1, curhour)
  putdec2(addr + 4, curmin)
  putdec2(addr + 7, cursec)
  return 10

PRI puthms12(addr)

  trmove(addr, string("00:00:00am"), 10)
  if (curhour > 11)
    byte[addr][8] := "p"
  if (curhour // 12 == 0)
    putdec2(addr, 12)
  else
    putdec2(addr, curhour // 12)
  putdec2(addr + 3, curmin)
  putdec2(addr + 6, cursec)
  return 10

PRI putymd(addr)

  trmove(addr, string("2000-00-00"), 10)
  putdec2(addr + 2, curyear)
  putdec2(addr + 5, curmonth)
  putdec2(addr + 8, curday)
  return 10
  
PRI putmdy(addr)

  trmove(addr, string("00/00/2000"), 10)
  putdec2(addr + 8, curyear)
  putdec2(addr, curmonth)
  putdec2(addr + 3, curday)
  return 10
  
PRI putdmy(addr)

  trmove(addr, string("00.00.2000"), 10)
  putdec2(addr + 8, curyear)
  putdec2(addr + 3, curmonth)
  putdec2(addr, curday)
  return 10
  
PRI putdec2(addr, value)

  value //= 100
  byte[addr++] := tr(value / 10 + "0")
  byte[addr] := tr(value // 10 + "0")

PRI trmove(dst, src, n)

  repeat n
    byte[dst++] := tr(byte[src++])

PRI tr(c)

  return translate[c >> 4] ^ c            

PRI updatewindow

  if(activewindow)
    bytemove(activewindow, @_flag, HEADERSIZE)

PRI print(c) | i, nbuf, endline

  if (activewindow == 0 or _flag & TYPE)
    return
  nbuf~
  if (_xcur => _xdim)
    if (_ydim > 1)
      if (_flag & WORDWRAP)
        if(c <> " " and byte[endline := _base + _xdim * (_ycur + 1) - 1] <> trsp)
          repeat i from endline to endline - _xdim + 2
            if (byte[i] == trsp or byte[i] == trhy)
              nbuf := endline - i
              bytemove(@linebuf, i + 1, nbuf)
              bytefill(i + 1, trsp, nbuf)
              quit
      if (_ycur => _ydim - 1)
        if (_autoscroll)
          repeat i from 1 to 15
            scrollcurrentwindow(0, i)
            waitcnt(clkfreq / 1000 * _autoscroll + cnt)
        repeat until status & BLANKING
        scrollcurrentwindow(0, 0)
        bytemove(_base, _base + _xdim, _xdim * (_ydim - 1))
        bytefill(_base + _xdim * (_ydim - 1), trsp, _xdim + 1)
      _xcur := 0
      if (_ycur < _ydim - 1)
        _ycur++
      if (_flag & WORDWRAP and c == " ")
        return
    else
      byte[_base + _xdim] := tr(c)
      if (_autoscroll)
        repeat i from 1 to 15
          scrollcurrentwindow(i, 0)
          waitcnt(clkfreq / 1000 * _autoscroll + cnt)
      repeat until status & BLANKING
      scrollcurrentwindow(0, 0)
      bytemove(_base, _base + 1, _xdim)
      _xcur := _xdim - 1
  if (nbuf)
    bytemove(_base + _xdim * _ycur + _xcur, @linebuf, nbuf)
    _xcur += nbuf
  byte[_base + _xdim * _ycur + _xcur++] := tr(c)

PRI whitespace(c)

  return lookdown(c: trsp, trhy) <> 0

DAT

              org       0

'-------[ Beginning of overlay display code. ]------------------------------------- 

display       mov       statusaddr,par
              add       statusaddr,#@status-@displayptr
              mov       curstatus,#0
              mov       winlistaddr,par
              add       winlistaddr,#@windowlist-@displayptr
              mov       ctra,ctra_vi            'Set up ctra for video PLL.      
              mov       frqa,frqa_vi
              mov       dira,vidswmask          'Connect video input to video output (passthru).
              mov       outa,vidswmask

resync        andn      curstatus,#GOTSYNC      'Indicate loss of sync in status value.
              or        curstatus,#BLANKING     'Assert blanking status.       
              wrword    curstatus,statusaddr    'Send status back to hub.
              mov       scr,#16                 'Clamp a random point in the incoming video to
              or        dira,clampmask          '  the digital threshold.

:resynclp     test      vidinpmask,ina wc       'Set clamp pin to opposite of video input.
              muxnc     outa,clampmask
              djnz      scr,#:resynclp          'Do this for 16 cycles.

              andn      dira,clampmask          'Done: tristate the clamp pin.
              andn      outa,clampmask

endfield      or        curstatus,#BLANKING
              wrword    curstatus,statusaddr
              call      #sync                   'Get the next sync. Fail back to resync if not found.
              cmp       time,half_sync wc       'Vertical sync pulse?
        if_c  jmp       #endfield               '  No:  Try again.

:vsyncs       call      #sync                   'Get another sync.
              cmp       time,half_sync wc       'Vertical sync pulse?
        if_nc jmp       #:vsyncs                '  Yes: Get another.

:equalize     mov       cur_line,#5             'Now need to pass five additional serrations.

:pulselp      call      #sync                   'Get next sync.
              djnz      cur_line,#:pulselp      'Back for another of the five.

              mov       ftime,htime             'Retrieve beginning of last sync.
              call      #sync                   'Get next sync.
              sub       ftime,htime             'Compute intersync time.
              cmps      ftime,even_odd_thld wc  'Is it regular length?
              muxc      cur_line,#1
              or        curstatus,#GOTSYNC
              wrword    curstatus,statusaddr

              rdword    slotptr,par wz          'Get display list address. Exists?
        if_z  jmp       #endfield               '  No:  End the field without displaying anything.

              add       frmcnt,#1
              mov       flags,#0
              mov       slot,#0

:winlp        call      #nextsync
:nxtwin       test      slot,#LASTSLT wc        'Was previous slot the last slot in screen?
        if_c  jmp       #endfield               '  Yes: End of field. 

              rdlong    slot,slotptr wz         'Get next slot data.
              add       slotptr,#4              'Update display list address
        if_z  jmp       #endfield               'End of field if slot is empty.
        
              andn      curstatus,#BLANKING     'Getting ready to display; not blanking anymore.
              wrword    curstatus,statusaddr    'Tell the hub.

              mov       winptr,slot
              shl       winptr,#1
              and       winptr,#$7e wz
        if_z  jmp       #:nxtwin
        
              add       winptr,winlistaddr
              rdword    winptr,winptr wz
        if_z  jmp       #:winlp

              mov       left_edge,slot
              shr       left_edge,#8
              and       left_edge,_0xffff

              mov       top_line,slot
              shr       top_line,#23            'Field line = scan line * 2.

              rdbyte    flags,winptr            'Get the flags.
              add       winptr,#1               'Increment pointer.

              rdbyte    ncols,winptr
              add       winptr,#1
              
              rdbyte    nrows,winptr
              add       winptr,#1
              
              rdbyte    vshift,winptr
              add       winptr,#1
              
              mov       scr,vshift
              
              shr       scr,#4
              and       vshift,#$0f
              
              mov       vscl_lborder,vscl_border0
              mov       vscl_lshift,vscl_row0
              mov       vscl_row,vscl_row0
              mov       vscl_rshift,vscl_rshift0
              mov       vscl_rborder,vscl_border0

              test      scr,#1 wc
              muxnc     vscl_lborder,#CLKSPERPIXEL 'Modulate width of left border.
              muxc      vscl_rborder,#CLKSPERPIXEL 'Modulate width of right border.
             
              and       scr,#$0e             'Set value to use for vscl.
              mov       hshift,scr           'Pixels get shifted by hshift * 2
              shl       hshift,#1
              shl       scr,# >|CLKSPERPIXEL-1
              
              sub       vscl_lshift,scr
              movs      vscl_rshift,scr
              
              test      flags,#DOUBLEWIDE wc    'Double-width characters?
        if_c  shl       vscl_lborder,#1         '  Yes: Double the video timing.
        if_c  shl       vscl_lshift,#1
        if_c  shl       vscl_row,#1
        if_c  shl       vscl_rshift,#1
        if_c  shl       vscl_rborder,#1

              test      flags,#DOUBLEHIGH wc    'Double-height characters?
        if_c  movs      :nxtline,#4             '  Yes: Increment font address by 4 bytes per scan line.
        if_nc movs      :nxtline,#8             '  No:  Increment font address by 8 bytes per scan line.

              rdbyte    scr,winptr
              add       winptr,#1
              
              mov       vidoutmask,scr
              and       vidoutmask,#$f0
              shl       vidoutmask,#7
              
              and       scr,#$0f
              mov       frqb_sw,scr
              shl       scr,#4
              or        frqb_sw,scr
              mov       scr,frqb_sw
              shl       scr,#8
              or        frqb_sw,scr
              mov       scr,frqb_sw
              shl       scr,#16
              or        frqb_sw,scr
              
              rdbyte    scr,winptr              'Get colors for this window.
              add       winptr,#4               'Increment pointer.
              
              test      slot,#SHOWSLT wc
        if_nc mov       vidoutmask,#0
        if_nc mov       scr,#%00010001              

              movs      :load_eb,scr            'Color is %ffffbbbb. Lookup and assemble colors.
              andn      :load_eb,#$f0           'Isolate background color for even background.
              movs      :load_ob,:load_eb       'Copy to odd background,
              movs      :load_ebb,:load_eb      '  to even background-only,
              movs      :load_obb,:load_eb      '  and to odd background-only.
              
              add       :load_eb,#evenbg        'Add table addresses to each.
              add       :load_ob,#oddbg
              add       :load_ebb,#evenfg
              add       :load_obb,#oddfg

              shr       scr,#4                  'Get foregournd color in bits 3..0.
              movs      :load_ef,scr            'Copy to even foreground.
              add       :load_ef,#evenfg        'Add table address.
              movs      :load_of,scr            'Copy to odd foreground.
              add       :load_of,#oddfg         'Add table address.

:load_eb      mov       even_colors,0-0         'Get the even background colors.
              mov       even_bkgnd,even_colors  'Copy to even bacground-only.
:load_ef      or        even_colors,0-0         'OR in the even foreground colors.
:load_ebb     or        even_bkgnd,0-0          'OR in the backgroun-only colors.
:load_ob      mov       odd_colors,0-0          'Get the odd background colors.
              mov       odd_bkgnd,odd_colors    'Copy to odd background-only colors.
:load_of      or        odd_colors,0-0          'OR in the odd foreground colors.
:load_obb     or        odd_bkgnd,0-0           'OR in the odd background-only colors.

              test      flags,#BLINKING wc      'Blinking AND
              test      frmcnt,#$20 wz          '  in alternate 32 frames of frame count?
   if_c_and_z mov       even_colors,even_bkgnd  '  Yes: Convert foreground colors to background.
   if_c_and_z mov       odd_colors,odd_bkgnd

              mov       rowptr,winptr           'Save pointer, which points to first character in _ypos.
              mov       rowcnt,nrows            'Initialize _ypos counter.

              mov       plyptr,vshift           'Plyptr points into character pixel row.
              shl       plyptr,#3            
              mov       plycnt,#16
              sub       plycnt,vshift           'Adjust pixel row count by vertical smooth scroll amount.
              call      #goto_line              'Go to nxt_line.

              jmp       #:adjptr

:rowlp        mov       plyptr,#0               'Next character row always starts with a whole character.
              mov       plycnt,#16
              
:adjptr       test      cur_line,#1 wc
              muxc      plyptr,#%0100
              test      flags,#DOUBLEHIGH wc
        if_c  shl       plycnt,#1
        if_c  sub       plycnt,#1

:plylp        mov       chrptr,rowptr
              call      #nextsync               'Beginning of scan line. Get next horizontal sync.
              cmp       time,#480 wc            'Is it too wide?
        if_nc jmp       #resync                 '  Yes: We've lost sync, so resync.

              mov       chrcnt,ncols            'Initialize character counter.
              add       chrcnt,#1

              test      hshift,hshift wz        'Check for smooth horizontal scrolling (used later).

              rdbyte    char,chrptr             'Get the first character in the line.
              add       chrptr,#1               'Increment pointer.

              jmpret    :getpix_ret,#:getpix    'Get colors and pixels for first character.
              mov       colorsx,colors          'Save them.
              mov       pixelsx,pixels
              shr       pixelsx,hshift          'Shift pixels according to hshift.

              rdbyte    char,chrptr             'Read the second character in the line.
              add       chrptr,#1               'Increment pointer.

              jmpret    :getpix_ret,#:getpix    'Get colors and pixels for second character.
              movs      :getpix_ret,#:chrlp     'Restore jump addr to point to loop beginning for inline code.

              mov       time,left_edge          'Get left margin value.
              add       time,htime              'Add to beginning of horizontal sync.
              waitcnt   time,#0                 'Wait for left margin position.
              mov       vscl,vscl_lborder       'Set left border width (4 or 5, depending on hshift).
              mov       vcfg,vcfg0
              waitvid   colors,#0
              or        dira,vidoutmask         'Turn on video pins.
              andn      outa,vidswmask          'Turn off video passthru.
              mov       vscl,vscl_lshift        'Set width of first character (depends on hshift).
              waitvid   colorsx,pixelsx         'Display first character.                 \
              mov       vscl,vscl_row           'Set vscl for full-width character.        |_ Maintain 1 instr. apart.
                                                '                                          |
:chrlp        waitvid   colors,pixels           'Display second and subsequent characters./
              rdbyte    char,chrptr             'Get next character.
              add       chrptr,#1               'Increment pointer.
              
:getpix       shr       char,#1 wc              'Prepare glyph address from first character. Set c for odd character.
              shl       char,#7
              add       char,plyptr
              add       char,font_addr
              rdlong    pixels,char             'Get the pixels for this ply of the first character.
        if_c  mov       colors,odd_colors       'Get odd colors for odd character;
        if_nc mov       colors,even_colors      '  even colors for even character.
:getpix_ret   djnz      chrcnt,#:chrlp          'Loop back (or return to caller) while counting down chrs.

        if_nz mov       vscl,vscl_rshift        'If hshift <> 0, display shifted piece of extra character.
        if_nz waitvid   colors,pixels
        
:endline      mov       vscl,vscl_rborder       'Set width of right border (4 or 5, depending on hshift).              
              waitvid   colors,#0               'Display right border.
              mov       vscl,vscl_row           'Restore vscl.
              waitvid   colors,#0               'Wait for right border to finish.
              or        outa,vidswmask          'Turn on video passthru.
              andn      dira,vidoutmask         'Turn off video outputs.
              or        dira,vidswmask          'Enable video passthru.
              mov       vscl,vscl_border0
              waitvid   colors,pixels
              mov       vcfg,#0                 'Turn off video system.
:nxtline      add       plyptr,#0-0             'Increment character plyptr.
              djnz      plycnt,#:plylp
              
              add       rowptr,ncols            'Point to beginning of next _ypos.
              djnz      rowcnt,#:rowlp          'Loop back to block begin.

              tjz       vshift,#:winlp

              mov       even_colors,even_bkgnd
              mov       odd_colors,odd_bkgnd
              mov       rowcnt,#1
              mov       plycnt,vshift
              test      flags,#DOUBLEHIGH wc
        if_c  shl       plycnt,#1
              mov       vshift,#0
              jmp       #:plylp

'-------[ Go to the line indicated in top_line. ]-------------------------------

goto_line     cmp       cur_line,top_line wc    'Is current => next line?
goto_line_ret
        if_nc ret                               '  Yes: Return
              call      #nextsync               'Get next horizontal sync.
              jmp       #goto_line              'Go back and check if done.

'-------[ Wait for the next horizontal sync. ]----------------------------------

nextsync      cmp       cur_line,#503 wc
        if_nc jmp       #endfield
              add       htime,frontporch        'Wait for front porch of current line.
              waitcnt   htime,#0
              mov       ctrb,ctrb_fp            'Clamp front porch to proper level to help locate sync.
              mov       frqb,frqb_fp
              or        dira,clampmask
              mov       scr,#16                 'Do this for 64 microseconds.
:fplp         djnz      scr,#:fplp
              andn      dira,clampmask          'Turn off clamp, and fall thru to sync.
              add       cur_line,#2

'-------[ Wait for, and measure, the next sync pulse. ]------------------------- 

sync          test      vidinpmask,ina wc       'Is sync already low?
        if_nc jmp       #resync                 '  Yes: Loss of sync, so abort call and resync.

              mov       scr,line_thld           'Set maximum wait time for sync.

              mov       ctrb,ctrb_lo            'Set ctrb to count up on video input low.
              mov       frqb,frqb_lo
              mov       phsb,#0

:waitlow      test      vidinpmask,ina wc       'Test video input. Is it low (sync)?
        if_c  djnz      scr,#:waitlow           '  No: Decrment wait time, and try again.
        if_c  jmp       #resync                 'If wait time exceeded, abort call and resync.

              mov       htime,cnt               'Get time of hsnc leading edge.
              sub       htime,phsb              'Adjust by counts in ctrb for 1-clock precision.

              mov       ctrb,ctrb_cl            'Set up ctrb to clamp sync pulse to proper level.
              mov       frqb,frqb_cl
              mov       phsb,#0                 'Synchronize phsb to :synclp.

:synclp       test      vidinpmask,ina wc       'Check if still in sync.           \
              muxnc     dira,clampmask          'Clamp to sync level if it is.      |__ Must be 4 instr. long.
              mov       time,cnt                'Record time.                       |
        if_nc djnz      scr,#:synclp            'Loop back if still in sync pulse. /

              andn      dira,clampmask          'Turn off clamp.
              mov       ctrb,ctrb_sw            'Set up ctrb for passthru transparency.
              mov       frqb,frqb_sw
        if_nc jmp       #resync                 'If timed out, abort call and resync.

              sub       time,htime              'Compute length of pulse.
              cmp       time,#120 wc            'Is pulse < 1.5 us?
        if_c  jmp       #sync                   '  Yes: Noise, so try again.
                      
sync_ret
nextsync_ret  ret                               'Return to caller.

'--------[Constants]------------------------------------------------------------

ctra_vi       long      %00001 << 26 | (%011 + >| CLKSPERPIXEL) << 23
frqa_vi       long      $16e8_b9fd
ctrb_sw       long      %00110 << 26 | VIDSW
ctrb_fp
ctrb_cl       long      %00110 << 26 | CLAMP
frqb_fp       long      $8000_0000
frqb_cl       long      $5f00_0000
ctrb_lo       long      %01100 << 26 | VIDIN
frqb_lo       long      1
_0xffff       long      $ffff

evenfg        long      $00000000,$08000800,$10001000,$18001800
              long      $20002000,$28002800,$30003000,$38003800
              long      $40004000,$48004800,$50005000,$58005800
              long      $60006000,$68006800,$70007000,$78007800
oddbg         long      $00000000,$00008888,$00011110,$00019998
              long      $00022220,$0002aaa8,$00033330,$0003bbb8
              long      $00044440,$0004ccc8,$00055550,$0005ddd8
              long      $00066660,$0006eee8,$00077770,$0007fff8
oddfg         long      $00000000,$08080000,$10100000,$18180000
              long      $20200000,$28280000,$30300000,$38380000
              long      $40400000,$48480000,$50500000,$58580000
              long      $60600000,$68680000,$70700000,$78780000
evenbg        long      $00000000,$00880088,$01100110,$01980198
              long      $02200220,$02a802a8,$03300330,$03b803b8
              long      $04400440,$04c804c8,$05500550,$05d805d8
              long      $06600660,$06e806e8,$07700770,$07f807f8

vscl_border0  long      CLKSPERPIXEL << 12 | (CLKSPERPIXEL * 4)
vscl_rshift0  long      CLKSPERPIXEL << 12
vscl_row0     long      CLKSPERPIXEL << 12 | (CLKSPERPIXEL * 16)
vcfg0         long      %01 << 29 | 1 << 28 | %001 << 9 | %1111 << PINOFFSET
font_addr     long      0-0
vidinpmask    long      1 << VIDIN
clampmask     long      1 << CLAMP
vidswmask     long      1 << VIDSW

darkmask      long      1 << 5
lightmask     long      1 << 4

half_sync     long      1200
even_odd_thld long      -3840
line_thld     long      960
frontporch    long      80 * 62

'-------[ Variables ]-----------------------------------------------------------

statusaddr    res       1
curstatus     res       1
slotptr       res       1
winlistaddr   res       1
winptr        res       1
rowptr        res       1
plyptr        res       1
chrptr        res       1
firstchr      res       1

rowcnt        res       1
chrcnt        res       1
plycnt        res       1
frmcnt        res       1

vscl_lborder  res       1
vscl_lshift   res       1
vscl_row      res       1
vscl_rshift   res       1
vscl_rborder  res       1

slot          res       1
left_edge     res       1
top_line      res       1
ncols         res       1
nrows         res       1
hshift        res       1
vshift        res       1
vidoutmask    res       1
frqb_sw       res       1
even_colors   res       1       '(FGND << ((VIDOUT & 7) + 3)) * $0100_0100 + (BGND << ((VIDOUT & 7) + 3)) * $0011_0011
odd_colors    res       1       '(FGND << ((VIDOUT & 7) + 3)) * $0101_0000 + (BGND << ((VIDOUT & 7) + 3)) * $0000_1111
even_bkgnd    res       1       '(BGND << ((VIDOUT & 7) + 3)) * $0100_0100 + (BGND << ((VIDOUT & 7) + 3)) * $0011_0011       
odd_bkgnd     res       1       '(BGND << ((VIDOUT & 7) + 3)) * $0101_0000 + (BGND << ((VIDOUT & 7) + 3)) * $0000_1111
colors        res       1
colorsx       res       1
pixels        res       1
pixelsx       res       1

scr           res       1
time          res       1
htime         res       1
ftime         res       1
cur_line      res       1
char          res       1
flags         res       1
tchar         res       1

              fit

displayptr    word      0       'Points to current display in slotlist. Must on a long boundary.
status        word      0       'Current status of asm cog. Must come one word after displayptr.
bufptr        word      0       'Points to next free byte in buffer.
bufmax        word      0       'Points one byte past end of buffer.
activewindow  word      0       'Window address of the currently active window.
cogno         byte      0       'Cog number of the assembly code, plus one.
timecogno     byte      0       'Cog number of the timekeeper, if any, plus one.

slotlist      long      0[64]   'List of slots.
windowlist    word      0[64]   'List of window pointers.
tstack        long      0[64]
_base         word      0
_flag         byte      0
_xdim         byte      0
_ydim         byte      0
_xyscroll     byte      0
_mask_trans   byte      0
_fg_bg        byte      0
_xcur         byte      0
_ycur         byte      0
_autoscroll   byte      0
cmd           byte      0
nargs         byte      0
arg0          byte      0
arg1          byte      0
arg2          byte      0
arg3          byte      0
arg4          byte      0
arg5          byte      0
linebuf       byte      0[MAXCOLS]
timebuf       byte      0[24]
curtime                         'Current time: yr:mo:day:hr:min:sec:0:0.
curyear       byte      0
curmonth      byte      0
curday        byte      0
curhour       byte      0
curmin        byte      0
cursec        byte      0
timelock      byte      0
translate     byte      0[16]
trsp          byte      " "
trhy          byte      "-"


''-----------[ TERMS OF USE ]---------------------------------------------------
''
'' Permission is hereby granted, free of charge, to any person obtaining a copy of
'' this software and associated documentation files (the "Software"), to deal in
'' the Software without restriction, including without limitation the rights to use,
'' copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
'' Software, and to permit persons to whom the Software is furnished to do so,
'' subject to the following conditions: 
''
'' The above copyright notice and this permission notice shall be included in all
'' copies or substantial portions of the Software. 
''
'' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'' INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
'' PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
'' HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
'' OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'' SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.      