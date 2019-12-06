'' AiGeneric_Driver_002
'' :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' :: AiGeneric V2.1cf :: Colaboration of work by: Doug,Hippy,OBC,Baggers ::
'' ::                                                                     ::
'' :: This version supports the following:                                ::
'' ::                                                                     ::
'' ::   * .64c font files  (See DAT section: AiGeneric_Driver_002)        ::
'' ::   * On-the-fly character definition.           .redefine            ::
'' ::   * Exact character placement.                 .pokechar,.putchar   ::
'' ::   * Exact character retrivial.                 .getchar             ::
'' ::   * 16 text colors                             .color               ::
'' ::   * text centering                             .center              ::
'' ::   * Most standard tv_text functions.                                ::
'' ::                                                                     ::
'' ::     Intended as a drop-in replacement anywhere tv_text is used.     ::
'' :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
''   Special thanks to Doug & Hippy for doing a bulk of the heavy lifting.


OBJ

  tv_SmallFont_Driver           : "AiGeneric_Driver_TV"

  
CON

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     Driver Attributes                                                                               |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'

  COLUMNS                       = tv_SmallFont_Driver#COLUMNS
  ROWS_PAL                      = tv_SmallFont_Driver#ROWS_PAL
  ROWS_NTSC                     = tv_SmallFont_Driver#ROWS_NTSC
  COLOURS                       = 16
  
'  FONT_CHARS                    = tv_SmallFont_Font_0#FONT_CHARS

  ROWS_MAX                      = ROWS_NTSC #> ROWS_PAL
  
  SCREEN_SIZE_CHARS             = COLUMNS * ROWS_MAX

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     Characters for drawing boxes                                                                    |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'
  
  CHR_TOP_LEFT                  = $15
  CHR_TOP_MID                   = $16
  CHR_TOP_RIGHT                 = $17
  CHR_LFT_BAR                   = $7C
  CHR_BOT_LEFT                  = $18
  CHR_BOT_RIGHT                 = $19

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     Characters for drawing logic analyser traces                                                    |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'

  CHR_BIT_0_TO_0                = $13
  CHR_BIT_0_TO_1                = $10
  CHR_BIT_1_TO_0                = $12
  CHR_BIT_1_TO_1                = $11

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     Mode bit settings - Must be the same as AiChip_TvText_001.spin                                  |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'

  TV_MODE_NTSC                  = %0000_0000
  TV_MODE_PAL                   = %0000_0001

  TV_MODE_LARGE_FONT            = %0000_0000
  TV_MODE_SMALL_FONT            = %0000_0010

  TV_MODE_FAST_UPDATE           = %0000_0000
  TV_MODE_FLICKER_FREE          = %0000_0100

  TV_MODE_COLOR                 = %0000_0000
  TV_MODE_COLOUR                = %0000_0000
  TV_MODE_MONOCHROME            = %0000_1000
  
  TV_MODE_INTERLACED            = %0000_0000
  TV_MODE_NON_INTERLACED        = %0001_0000

  TV_MODE_COMPOSITE             = %0000_0000
  TV_MODE_BASEBAND              = %0000_0000
  TV_MODE_BROADCAST             = %0010_0000

  TV_MODE_FONT_0                = %0000_0000
  TV_MODE_FONT_1                = %0100_0000

  TV_MODE_RUNNING               = %1000_0000

VAR

  word screenBuffer[SCREEN_SIZE_CHARS]
  word colorPalette[COLOURS]

  long params[5]                ' [0] pointer to screen memory
                                ' [1] pointer to font table
                                ' [2] base pin number = 12 for Demo Board / 24 for Hydra
                                ' [3] background and border colour
                                ' [4] PAL=non-zero, NTSC=zero
  byte mode
  byte rows
  word lastRow

' *******************************************************************************************************
' *                                                                                                     *
' *     Device Handling Routines                                                                        *
' *                                                                                                     *
' *******************************************************************************************************
                 
PUB Open( setBasePin, setMode, ptrToPalette )
  
  if mode <> setMode

    Close
    
    mode := setMode

    mode &= ! TV_MODE_PAL                               ' Driver does not support PAL at present
    mode &= ! TV_MODE_FLICKER_FREE                      ' Driver does not support Flicker Free
    mode &= ! TV_MODE_MONOCHROME                        ' Driver does not support Monochrome
    mode &= ! TV_MODE_BROADCAST                         ' Driver does not support Broadcast

    if mode & TV_MODE_PAL
      rows := ROWS_PAL
    else
      rows := ROWS_NTSC
    lastRow := (rows-1) * COLUMNS

    SetPalette(ptrToPalette)
    
    params[0] := @screenBuffer  
    params[1] := GetPtrToFontTable( setMode & TV_MODE_FONT_1 )
    params[2] := setBasePin
    params[3] := byte[ ptrToPalette ]
    params[4] := mode & TV_MODE_PAL
  
    Cls
    
    tv_SmallFont_Driver.Open(@params)

  return mode

PUB Close

  if mode
    tv_SmallFont_Driver.Close
    mode := 0

' *******************************************************************************************************
' *                                                                                                     *
' *     Font Handling Routines                                                                          *
' *                                                                                                     *
' *******************************************************************************************************

PRI GetPtrToFontTable( fontNumber ) | ptr

   result := @font+2'tv_SmallFont_Font_0.GetPtrToFontTable 

 ptr := result
' if byte[ ptr+constant(" "*8) ]~ 
   repeat (get_font_num_chars * 8)
     byte[ ptr++ ] ><= 8
    
' *******************************************************************************************************
' *                                                                                                     *
' *     Text Handling Routines                                                                          *
' *                                                                                                     *
' *******************************************************************************************************

PUB Scroll

  wordmove(@screenBuffer, @screenBuffer+(COLUMNS<<1), lastrow)
  wordfill(@screenBuffer+(lastrow<<1), " ", COLUMNS)

PUB Cls

  wordfill(@screenBuffer, " ", SCREEN_SIZE_CHARS)

PUB PokeChar( row, col, colour, c )

  screenBuffer[row * COLUMNS + col] := ( colorPalette[ colour // COLOURS ] & $FF00 ) | ( c // get_font_num_chars )

pub define(c,c0,c1,c2,c3,c4,c5,c6,c7) | p 
 p:=@font+2+(c<<3)
 byte[p][0]:=c0
 byte[p][1]:=c1
 byte[p][2]:=c2
 byte[p][3]:=c3
 byte[p][4]:=c4
 byte[p][5]:=c5
 byte[p][6]:=c6
 byte[p][7]:=c7


PUB GetChar( row, col )

  return screenBuffer[row * COLUMNS + col]

PUB PutChar( row, col, chr )

  screenBuffer[row * COLUMNS + col]:=chr

' *******************************************************************************************************
' *                                                                                                     *
' *     Logic Analyser Trace Handling Routines                                                          *
' *                                                                                                     *
' *******************************************************************************************************

PUB GetLogicAnalyserBit(thisBit,nextBit)

  result := LookUpZ ( ( ( thisBit >> 30 ) & 2 ) | ( nextBit >> 31 ) : CHR_BIT_0_TO_0, CHR_BIT_0_TO_1, CHR_BIT_1_TO_0, CHR_BIT_1_TO_1 )

' *******************************************************************************************************
' *                                                                                                     *
' *     Attribute Handling for Video Drivers                                                            *
' *                                                                                                     *
' *******************************************************************************************************

PUB GetColourCount

  result := COLOURS

PUB GetColumnCount

  result := COLUMNS
    
PUB GetRowCount

  result := rows

' *******************************************************************************************************
' *                                                                                                     *
' *     Colour Palette Handling for Video Drivers                                                       *
' *                                                                                                     *
' *******************************************************************************************************

PUB SetPalette( ptrToPalette ) | i, back

  back := byte[ptrToPalette]
  repeat i from 0 to COLOURS-2
    SetPaletteColour(i,byte[ptrToPalette+i+1],back)
  SetPaletteColour(COLOURS-1,byte[ptrToPalette+1],byte[ptrToPalette+COLOURS])

PUB SetPaletteColour( colorIdx, fore, back )

   colorPalette[colorIdx] := fore << 8 | back

' *******************************************************************************************************
' *                                                                                                     *
' *     End of AiChip_SmallFont_002.spin                                                                *
' *                                                                                                     *
' *******************************************************************************************************

pub get_font_num_chars
  return (((@fontend-@font)-2)/8)


dat

font  file "c64_lower.64c"

fontend byte
    