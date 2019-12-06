'' AiGeneric_Driver_TV
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

CON

  COLUMNS                        = 40                   ' 40
  ROWS_PAL                       = 25                   ' 26 Maximum
  ROWS_NTSC                      = 25                   ' 26 Maximum

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     NTSC Video Information                                                                          |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'
  
  NTSC_COLOUR_FREQUENCY          = 3_579_545      

  NTSC_PIXELS_PER_LINE           = 320
  NTSC_LINES_PER_FRAME           = 244
  
  'NTSC_NUMBER_OF_DISPLAY_PIXELS  = NUMBER_OF_COLUMNS * 8
  'NTSC_NUMBER_OF_BORDER_PIXELS   = NTSC_PIXELS_PER_LINE - NTSC_NUMBER_OF_DISPLAY_PIXELS
  'NTSC_NUMBER_OF_LFT_BORDER_PIXS = NTSC_NUMBER_OF_BORDER_PIXELS / 2
  'NTSC_NUMBER_OF_RGT_BORDER_PIXS = NTSC_NUMBER_OF_BORDER_PIXELS - NTSC_NUMBER_OF_LFT_BORDER_PIXS

  NTSC_NUMBER_OF_DISPLAY_LINES   = ROWS_NTSC * 8
  NTSC_NUMBER_OF_BORDER_LINES    = NTSC_LINES_PER_FRAME - NTSC_NUMBER_OF_DISPLAY_LINES
  NTSC_NUMBER_OF_TOP_BORDER_LINS = NTSC_NUMBER_OF_BORDER_LINES / 2
  NTSC_NUMBER_OF_BOT_BORDER_LINS = NTSC_NUMBER_OF_BORDER_LINES - NTSC_NUMBER_OF_TOP_BORDER_LINS

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     PAL Video Information                                                                           |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'

  PAL_COLOUR_FREQUENCY          = 4_433_618      

  PAL_PIXELS_PER_LINE           = 320
  PAL_LINES_PER_FRAME           = 286
  
  'PAL_NUMBER_OF_DISPLAY_PIXELS  = NUMBER_OF_COLUMNS * 8
  'PAL_NUMBER_OF_BORDER_PIXELS   = PAL_PIXELS_PER_LINE - PAL_NUMBER_OF_DISPLAY_PIXELS
  'PAL_NUMBER_OF_LFT_BORDER_PIXS = PAL_NUMBER_OF_BORDER_PIXELS / 2
  'PAL_NUMBER_OF_RGT_BORDER_PIXS = PAL_NUMBER_OF_BORDER_PIXELS - PAL_NUMBER_OF_LFT_BORDER_PIXS

  PAL_NUMBER_OF_DISPLAY_LINES   = ROWS_PAL * 8
  PAL_NUMBER_OF_BORDER_LINES    = PAL_LINES_PER_FRAME - PAL_NUMBER_OF_DISPLAY_LINES
  PAL_NUMBER_OF_TOP_BORDER_LINS = PAL_NUMBER_OF_BORDER_LINES / 2
  PAL_NUMBER_OF_BOT_BORDER_LINS = PAL_NUMBER_OF_BORDER_LINES - PAL_NUMBER_OF_TOP_BORDER_LINS

VAR

  byte cog
      
PUB Open(ptrToParams)

  Close
  result := cog := cognew(@SmallFontDriver,ptrToParams) + 1
  
PUB Close

  if cog
    cogstop(cog~ - 1)

DAT

SmallFontDriver         org     0

' *******************************************************************************************************
' *                                                                                                     *
' *     Get Parameters and Initialise Driver                                                            *
' *                                                                                                     *
' *******************************************************************************************************

                        mov     paramPtr, PAR           ' Point to parameter block

                        call    #GetParam               ' [0] Pointer to screen buffer
                        mov     screenBuffer,paramValue

                        call    #GetParam               ' [1] Pointer to font table
                        mov     fontTable,paramValue

                        call    #GetParam               ' [2] Base pin number
                        mov     r0,paramValue

                        ' %0_xx_x_x_x_xxx : Not used
                        ' %x_10_x_x_x_xxx : Composite video to bottom nibble, broadcast to top nibble
                        ' %x_11_x_x_x_xxx : Composite video to top nibble, broadcast to bottom nibble
                        ' %x_xx_0_x_x_xxx : 2 color mode
                        ' %x_xx_1_x_x_xxx : 4 color mode
                        ' %x_xx_x_0_x_xxx : Enable chroma on broadcast
                        ' %x_xx_x_x_1_xxx : Enable chroma on baseband
                        ' %x_xx_x_x_x_000 : Broadcast Aural FM bits ( not sued )

                        and     r0,#%100 WZ             ' Top or bottom nibble
              IF_NZ     mov     r0,#%0_01_000_000       ' Top nibble
                        or      r0,#%0_10_001_000
                        mov     vcfg_2_color_mode,r0                          
                        or      r0,#%0_10_101_000
                        mov     vcfg_4_color_mode,r0                          

                        mov     r0,#%0000_0111          ' Select pin mask upper/lower nibble
              IF_NZ     shl     r0,#4
                        movs    VCFG, r0                


                        mov     r0,paramValue           ' Set VCFG Pin Group
                        shr     r0,#3
                        movd    VCFG,r0                 

                        movi    VCFG,vcfg_4_color_mode

                        mov     r0,#%0111               ' Set video pins as outputs
                        shl     r0,paramValue
                        mov     DIRA, r0                 

                        call    #GetParam               ' [3] Background and border colour
                        mov     backColour,paramValue
                        mov     borderColour,paramValue
                        shl     borderColour,#8
                        or      borderColour,paramValue
                        shl     borderColour,#8
                        or      borderColour,paramValue
                        shl     borderColour,#8
                        or      borderColour,paramValue
                        
                        call    #GetParam               ' [4] PAL=non-zero, NTSC=zero
              IF_Z      mov     r0,#NTSC_PARAMS         
              IF_NZ     mov     r0,#PAL_PARAMS         
                        mov     r1,#PARAMS
                        mov     r2,#10
                        call    #MoveLongs

                        mov     r1,colourFrequency      ' Get Color Frequency ( eg  3_579_545 Hz )
                        rdlong  r2,#0                   ' Get Clock Frequency ( eg 80_000_000 Hz )
                        call    #DivideFract            ' Calculate r3 = 2^32 * r1 / r2
                        mov     FRQA, r3                ' Set frequency for counter

                        movi    CTRA,#%00001_111        ' Set PLL video, PHSx+=FRQx (mode 1) + pll(16x)

' *******************************************************************************************************
' *                                                                                                     *
' *     Draw Frame                                                                                      *
' *                                                                                                     *
' *******************************************************************************************************

DrawFrame               call    #VerticalSync
                        mov     counter,numberOfTopBorderLines
                        call    #DrawTopBotBorder
                        call    #DrawTextArea
                        mov     counter,numberOfBotBorderLines
                        call    #DrawTopBotBorder
                        jmp     #DrawFrame

' *******************************************************************************************************
' *                                                                                                     *
' *     Vertical Synch                                                                                  *
' *                                                                                                     *
' *******************************************************************************************************

VerticalSync            mov     r1,pixels_vSyncHigh1 
                        mov     r2,pixels_vSyncHigh2
                        call    #VerticalSyncPulses
                        
                        mov     r1,pixels_vSyncLow1 
                        mov     r2,pixels_vSyncLow2
                        call    #VerticalSyncPulses

                        mov     r1,pixels_vSyncHigh1 
                        mov     r2,pixels_vSyncHigh2
                        call    #VerticalSyncPulses
                        
VerticalSync_ret        ret
                        
VerticalSyncPulses      mov     counter, #6
           
:Loop                   mov     VSCL,vscl_hSync
                        waitvid syncColours,r1
                        mov     VSCL, vscl_activeVideo
                        waitvid syncColours,r2

                        djnz    counter, #:Loop
VerticalSyncPulses_ret  ret

' *******************************************************************************************************
' *                                                                                                     *
' *     Draw Top or Bottom Border                                                                       *
' *                                                                                                     *
' *******************************************************************************************************

DrawTopBotBorder        call    #HorizontalSync
                        call    #DrawLeftBorder
                        call    #DrawBlankLine
                        call    #DrawRightBorder
                        
                        djnz    counter,#DrawTopBotBorder
                        
DrawTopBotBorder_ret    ret
 
' *******************************************************************************************************
' *                                                                                                     *
' *     Draw Text Area                                                                                  *
' *                                                                                                     *
' *******************************************************************************************************

DrawTextArea            mov     counter,numberOfDisplayLines
                        mov     fontLine,#0
                        mov     charPtr,screenBuffer   ' Point to first character in the screen buffer

:Loop                   call    #HorizontalSync
                        call    #DrawLeftBorder
                        call    #DrawLineOfText
                        call    #DrawRightBorder
                        
                        ' Update the font scan line. With 8 lines per char, count 0..7 and when it rolls
                        ' back to zero we are on the next line. If not, we need to adjust the charPtr so
                        ' it points to the character at the start of the line.
                        
                        add     fontline,#1
                        and     fontline,#7 WZ
              IF_NZ     sub     charPtr,#COLUMNS<<1

                        djnz    counter,#:Loop
                                                  
DrawTextArea_ret        ret

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     HorizSynch                                                                                      |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'
           
HorizontalSync          mov     VSCL,vscl_hSync
                        movi    VCFG,vcfg_4_color_mode
                        waitvid syncColours,pixels_hSync

HorizontalSync_ret      ret

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     Draw Left Border for a Single Line of Text                                                      |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'
           
DrawLeftBorder          mov     VSCL,vscl_leftBorder
                        movi    VCFG,vcfg_4_color_mode
                        waitvid borderColour,#0

DrawLeftBorder_ret      ret

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     Draw a Single Line of Text                                                                      |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'

DrawLineOfText          mov     VSCL,vscl_text           ' Set VSCL for 8 pixel blocks          
                        movi    VCFG,vcfg_2_color_mode   ' Two color mode

                        mov     fontOffset,fontTable     ' Index into font table    
                        add     fontOffset,fontLine      ' Index by font line we are on

                        mov     charCount,#COLUMNS

:Loop                   rdword  r1,charPtr              ' Get colour / character from screen buffer
                        mov     r2,r1                   ' r2 = fore colour
                        and     r1,#$FF                 ' r1 = char
                        shl     r1,#3                   ' Multiply by 8, for char offset
                        add     r1,fontOffset           ' Index into font table    
                        rdbyte  r1,r1                   ' Read font pixels
                        andn    r2,#$FF                 ' Lose the background colour
                        or      r2,backColour           ' force the background colour
                        waitvid r2,r1                   ' Put pixels to the screen
                        
                        add     charPtr,#2              ' Point to next character in the screen buffer

                        djnz    charCount,#:Loop

DrawLineOfText_ret      ret

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |     Draw a Single Blank Line                                                                        |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'

DrawBlankLine           mov     VSCL,vscl_text          ' set VSCL for 8 pixel blocks          
                        movi    VCFG,vcfg_2_color_mode  ' two color mode

                        mov     charCount,#COLUMNS

:Loop                   waitvid blackColour,#0          ' Put pixels to the screen
                        djnz    charCount,#:Loop
                        
DrawBlankLine_ret       ret

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |      Draw Right Border for a Single Line of Text                                                    |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'
                        
DrawRightBorder         mov     VSCL,vscl_rightBorder
                        movi    VCFG,vcfg_2_color_mode   'two color mode
                        waitvid borderColour,#0
                        movi    VCFG,vcfg_4_color_mode  ' This must be here don't know why

DrawRightBorder_ret     ret

' *******************************************************************************************************
' *                                                                                                     *
' *        Utility Routines                                                                             *
' *                                                                                                     *
' *******************************************************************************************************

DivideFract             mov     r0,#32+1

:Loop                   cmpsub  r1,r2 WC
                        rcl     r3,#1
                        shl     r1,#1
                        djnz    r0,#:Loop

DivideFract_ret         ret                             '+140

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |      Retrieve a parameter from the parameter block passed in                                        |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'
 
GetParam                rdlong  paramValue,paramPtr WZ
                        add     paramPtr,#4
GetParam_ret            ret

' .-----------------------------------------------------------------------------------------------------.
' |                                                                                                     |
' |      MoveLongs                                                                          |
' |                                                                                                     |
' `-----------------------------------------------------------------------------------------------------'
 
MoveLongs               movs    :Loop,r0
                        movd    :Loop,r1
                        nop

:Loop                   mov     PARAMS,NTSC_PARAMS
                        add     :Loop,IncDst1_And_IncSrc1
                        djnz    r2,#:Loop

MoveLongs_ret           ret
                           
' *******************************************************************************************************
' *                                                                                                     *
' *     Pre-Defined Constants                                                                           *
' *                                                                                                     *
' *******************************************************************************************************

blackColour             long    $02020202
borderColour            long    $02020202

backColour              long    $02

IncDst1                 long    1 << 9
IncDst1_And_IncSrc1     long    1 << 9 | 1

pixels_hSync            long    %%11_0000_1_2222222_11
pixels_vSyncHigh1       long    %%11111111111_222_11
pixels_vSyncHigh2       long    %%1111111111111111
pixels_vSyncLow1        long    %%22222222222222_11
pixels_vSynclow2        long    %%1_222222222222222

NTSC_PARAMS             long    NTSC_COLOUR_FREQUENCY                           ' colourFrequency
                        long    NTSC_NUMBER_OF_TOP_BORDER_LINS                  ' numberOfTopBorderLines  
                        long    NTSC_NUMBER_OF_DISPLAY_LINES                    ' numberOfDisplayLines   
                        long    NTSC_NUMBER_OF_BOT_BORDER_LINS                  ' numberOfBotBorderLines
                        long    $00_00_02_8A                                    ' synch colours ...
                        long    160368
                        long    3008
                        long    NTSC_leftBorderVscl
                        long    NTSC_rightBorderVscl
                        long    NTSC_textVscl

PAL_PARAMS              long    PAL_COLOUR_FREQUENCY                            ' colourFrequency
                        long    PAL_NUMBER_OF_TOP_BORDER_LINS                   ' numberOfTopBorderLines  
                        long    PAL_NUMBER_OF_DISPLAY_LINES                     ' numberOfDisplayLines   
                        long    PAL_NUMBER_OF_BOT_BORDER_LINS                   ' numberOfBotBorderLines
                        long    $00_00_02_AA                                    ' synch colours ...
                        long    160368
                        long    3008
                        long    PAL_leftBorderVscl
                        long    PAL_rightBorderVscl
                        long    PAL_textVscl

                        
' *******************************************************************************************************
' *                                                                                                     *
' *     Display paramaters                                                                              *
' *                                                                                                     *
' *******************************************************************************************************

PARAMS                  

colourFrequency         res     1                       ' NTSC_COLOUR_FREQUENCY
numberOfTopBorderLines  res     1                       ' NTSC_NUMBER_OF_TOP_BORDER_LINS
numberOfDisplayLines    res     1                       ' NTSC_NUMBER_OF_DISPLAY_LINES
numberOfBotBorderLines  res     1                       ' NTSC_NUMBER_OF_BOT_BORDER_LINS
syncColours             res     1                       ' $00_00_02_8A
vscl_hSync              res     1                       ' 160368
vscl_activeVideo        res     1                       ' 3008
vscl_leftBorder         res     1                       ' NTSC_leftBorderVscl
vscl_rightBorder        res     1                       ' NTSC_rightBorderVscl
vscl_text               res     1                       ' NTSC_textVscl

r0                      res     1               
r1                      res     1                
r2                      res     1                
r3                      res     1

counter                 res     1                       ' General purpose counter
screenBuffer            res     1                       ' Pointer to screen buffer
charPtr                 res     1                       ' Pointer to current character
charCount               res     1                       ' Counter of number of chars on a line
fontTable               res     1                       ' Pointer to font table
fontLine                res     1                       ' Which line/row in font we are showing
fontOffset              res     1
paramPtr                res     1                       ' Parameter pointer
paramValue              res     1                       ' Paramater value

vcfg_2_color_mode       res     1
vcfg_4_color_mode       res     1

' *******************************************************************************************************
' *                                                                                                     *
' *                                                                                                     *
' *                                                                                                     *
' *******************************************************************************************************

                        FIT     $1F0
                                
CON

NTSC_overscan = 448  
NTSC_leftBorderVscl = 208
NTSC_rightBorderVscl = (NTSC_overscan - NTSC_leftBorderVscl) ' 448-208 = 240

NTSC_clocks_per_pixel = 2560 / NTSC_PIXELS_PER_LINE ' 2560 / 320 = 8
NTSC_textVscl = (NTSC_clocks_per_pixel) << 12 + ( NTSC_clocks_per_pixel * 8 )

PAL_overscan = 448   
PAL_leftBorderVscl = 208
PAL_rightBorderVscl = (PAL_overscan - PAL_leftBorderVscl)

PAL_clocks_per_pixel = 2560 / NTSC_PIXELS_PER_LINE ' 2560 / 320 = 8
PAL_textVscl = (PAL_clocks_per_pixel) << 12 + ( PAL_clocks_per_pixel * 8 )


                                                          