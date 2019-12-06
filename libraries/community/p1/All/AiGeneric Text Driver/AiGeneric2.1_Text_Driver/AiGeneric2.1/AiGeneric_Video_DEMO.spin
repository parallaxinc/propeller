'' AiGeneric_Video_DEMO
'' :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
'' :: AiGeneric V2.1  :: Colaboration of work by: Doug,Hippy,OBC,Baggers  ::
'' ::                                                                     ::
'' :: This version supports the following:                                ::
'' ::                                                                     ::
'' ::   * Multiple font files  (See OBJ section: AiGeneric_Driver_002)    ::
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
  '' Uncomment section for your configuration type:

'' Demoboard/Protoboard/SpinStudio Boards
   _clkmode  = xtal1 + pll16x
   _xinfreq  = 5_000_000
   video     = 12 '' I/O for composite video connection

{
'' Hydra Boards
   _clkmode  = xtal1 + pll8x
   _xinfreq  = 10_000_000
    video     = 24 '' I/O for composite video connection 
}   

{
'' Hybrid Boards
   _clkmode  = xtal1 + pll16x
   _xinfreq  = 6_000_000
    video     = 24 '' I/O for composite video connection 
}

  BLACK             = $02 
  GREY              = $03
  LWHITE            = $06
  BWHITE            = $07
  LMAGENTA          = $A3 
  WHITE             = $AF
  RED               = $A2
  LRED              = $1A
  LPURPLE           = $1B
  PURPLE            = $03 
  LGREEN            = $1C
  SKYBLUE           = $1D
  YELLOW            = $1E
  BYELLOW           = $A6
  LGREY             = $1F
  DGREY             = $08
  GREEN             = $A4
  ORANGE            = $06
  BLUE              = $A1 
  CYAN              = $1C
  MAGENTA           = $FC
  LYELLOW           = $1E

  CR                = $0D
  LF                = $0A
  TAB               = $09
  BKS               = $08
   
OBJ
     text  : "aigeneric_driver"
     
PUB mainProgram  | data

  text.start(video)

  text.cls
  text.color(lred)
  text.center(string("* * * AIGENERIC V2.1 * * *"))
  text.out(13)
  text.out(13)
  text.color(SKYBLUE)
  text.str(string("Modified version of Hippys aichip driver",CR))
  text.color(orange)
  text.str(string("based on Doug's char 8x8 driver",CR))
  text.color(green)
  text.str(string("Written as a near drop-in for "))
  text.color(cyan)
  text.str(string("tv-text",CR))
  text.color(YELLOW)
  text.str(string("with "))
  text.color(MAGENTA)
  text.str(string("c"))
  text.color(RED)
  text.str(string("o"))
  text.color(BLUE)
  text.str(string("l"))
  text.color(ORANGE)
  text.str(string("o"))
  text.color(PURPLE)
  text.str(string("r"))
  text.color(white)
  text.out(13)
  text.out(13)
  text.str(string("Decimal:"))
  text.dec(10)
  text.out(13)
  text.str(string(" Binary:"))
  text.bin(242,8)
  text.out(13)
  text.out(13)
  text.color(cyan)
  text.str(String("Now with .redefine we can redefine",CR,"fonts on the fly."))
  text.out(13)
  text.out(13)
  text.color(white)
  text.str(string("Character 70 ---> FFFFFF <--- becomes..."))
  repeat 1500000 'Cheap delay for effect

  text.redefine(70,255,195,195,195,195,195,195,255)

  '' How .redefine works:
  '' 70 = Character to change. (character must be in use by font)
  '' 11111111 = 255   (Row 1)
  '' 11000011 = 195   (Row 2)    Design the new font row by row in binary.
  '' 11000011 = 195   (Row 3)    Convert each row to decimal and use in
  '' 11000011 = 195   (Row 4)    .define(CHAR,ROW1,ROW2,ROW3,ROW3......)
  '' 11000011 = 195   (Row 5)
  '' 11000011 = 195   (Row 6)    Thie should look somewhat familiar to
  '' 11000011 = 195   (Row 7)    Commodore 64 users. :)
  '' 11111111 = 255   (Row 8)      Thank you Baggers!!


  text.out(13)
  text.color(white)
  text.str(string("By redefining each row of the 8x8 font."))
  text.str(string(CR,"See the source for detail explaination."))
  text.out(13)
  text.out(13)
  text.color(YELLOW)
  text.str(string("The font can be changed by simply",Cr))
  text.str(string("replacing the loaded font file in the",CR))
  text.redefine(95,0,0,0,0,0,0,0,255) 'Redefine underscore for below _
  text.str(string("obj section of ai_driver_002.spin",CR))
  text.color(skyblue)
  text.out(13)
  text.str(string("Want to change the fonts?",CR,"Additional fonts included in this zip."))

  
  '' Demonstrate use of .getchar & .pokechar
  '' Display the word 'Demo' from the characters taken.
  '' NOTE: Top left corner of display is (0,0)
  
  data:=text.getchar(3,9)      'Get the D in 'Doug' on line 4
  text.pokechar(7,20,2,data)   'Place the character at 7,20 color 2

  data:=text.getchar(2,10)     'Get the e in 'version' on line 3
  text.pokechar(7,21,3,data)   'Place the character at 7,21 color 3

  data:=text.getchar(13,34)    'Get the m in 'becomes' on line 14
  text.pokechar(7,22,4,data)   'Place the character at 7,22 color 4

  data:=text.getchar(3,6)      'Get the o in 'color' on line 4
  text.pokechar(7,23,5,data)   'Place the character at 7,23 color 5
  