{
LaserMaze v1.1
by Thomas M. Doylend

Use the gamepad to move the smiley.
Collect all of the keys to move to the next level.
You can press START to replay current level.

Have fun!!!
}

CON

  _clkmode = xtal2 + pll8x       ' enable external clock range 5-10MHz and pll times 8
  _xinfreq = 10_000_000 + 0000   ' set frequency to 10 MHZ plus some error due to XTAL (1000-5000 usually works)
  _stack   = 128                 ' accomodate display memory and stack

  ' button ids/bit masks
  ' NES bit encodings general for state bits
  NES_RIGHT  = %00000001
  NES_LEFT   = %00000010
  NES_DOWN   = %00000100
  NES_UP     = %00001000
  NES_START  = %00010000
  NES_SELECT = %00100000
  NES_B      = %01000000
  NES_A      = %10000000

  ' NES bit encodings for NES gamepad 0
  NES0_RIGHT  = %00000000_00000001
  NES0_LEFT   = %00000000_00000010
  NES0_DOWN   = %00000000_00000100
  NES0_UP     = %00000000_00001000
  NES0_START  = %00000000_00010000
  NES0_SELECT = %00000000_00100000
  NES0_B      = %00000000_01000000
  NES0_A      = %00000000_10000000

  ' NES bit encodings for NES gamepad 1
  NES1_RIGHT  = %00000001_00000000
  NES1_LEFT   = %00000010_00000000
  NES1_DOWN   = %00000100_00000000
  NES1_UP     = %00001000_00000000
  NES1_START  = %00010000_00000000
  NES1_SELECT = %00100000_00000000
  NES1_B      = %01000000_00000000
  NES1_A      = %10000000_00000000

  ' color constant's to make setting colors for parallax graphics setup easier
  COL_Black       = %0000_0010
  COL_DarkGrey    = %0000_0011
  COL_Grey        = %0000_0100
  COL_LightGrey   = %0000_0101
  COL_BrightGrey  = %0000_0110
  COL_White       = %0000_0111 

  ' colors are in reverse order from parallax drivers, or in order 0-360 phase lag from 0 = Blue, on NTSC color wheel
  ' so code $0 = 0 degrees, $F = 360 degrees, more intuitive mapping, and is 1:1 with actual hardware
  COL_PowerBlue   = %1111_1_100 
  COL_Blue        = %1110_1_100
  COL_SkyBlue     = %1101_1_100
  COL_AquaMarine  = %1100_1_100
  COL_LightGreen  = %1011_1_100
  COL_Green       = %1010_1_100
  COL_GreenYellow = %1001_1_100
  COL_Yellow      = %1000_1_100
  COL_Gold        = %0111_1_100
  COL_Orange      = %0110_1_100
  COL_Red         = %0101_1_100
  COL_VioletRed   = %0100_1_100
  COL_Pink        = %0011_1_100
  COL_Magenta     = %0010_1_100
  COL_Violet      = %0001_1_100
  COL_Purple      = %0000_1_100

  
  buffersz        = 12*16   'Size of level buffer
  numlevels       = 2       'number of levels

'//////////////////////////////////////////////////////////////////////////////
' VARS SECTION ////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////

VAR

' begin parameter list ////////////////////////////////////////////////////////
' tile engine data structure pointers (can be changed in real-time by app!)
long tile_map_base_ptr_parm       ' base address of the tile map
long tile_bitmaps_base_ptr_parm   ' base address of the tile bitmaps
long tile_palettes_base_ptr_parm  ' base address of the palettes
long tile_map_sprite_cntrl_parm   ' pointer to the value that holds various "control" values for the tile map/sprite engine
long tile_sprite_tbl_base_ptr_parm ' base address of sprite table
long tile_status_bits_parm      ' vsync, hsync, etc.


byte sbuffer[80]      ' string buffer for printing
'long x,y, index, dir, tile_map_index  ' demo working vars

long coloff
long redpal[4]
long ticks

long guy_x
long guy_y
byte onbar

long numkeys              ' Number of keys in this level left to collect.
word map_buffer[buffersz] ' This is the temporary map. The guy is drawn onto it.
byte level                ' Level index.

'//////////////////////////////////////////////////////////////////////////////
'OBJS SECTION /////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////

OBJ

game_pad :      "gamepad_drv_001.spin"
gfx:            "HEL_GFX_ENGINE_040.SPIN"

'//////////////////////////////////////////////////////////////////////////////
'PUBS SECTION /////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////

' COG INTERPRETER STARTS HERE...@ THE FIRST PUB

PUB Start
' This is the first entry point the system will see when the PChip starts,
' execution ALWAYS starts on the first PUB in the source code for
' the top level file

' star the game pad driver
game_pad.start

loadlevel

tile_map_base_ptr_parm        := @map_buffer
tile_bitmaps_base_ptr_parm    := @tile_bitmaps
tile_palettes_base_ptr_parm   := @palette_map
tile_map_sprite_cntrl_parm    := $00_00 ' 0 sprites, tile map set to 0=16 tiles wide, 1=32 tiles, 2=64 tiles, etc.
tile_sprite_tbl_base_ptr_parm := 0 
tile_status_bits_parm         := 0

redpal[0] := $07_5C_5C_02
redpal[1] := $07_5D_5D_02
redpal[2] := $07_5E_5E_02
redpal[3] := $07_5D_5D_02
 
gfx.start(@tile_map_base_ptr_parm)

dira[0] := 1
outa[0] := 0

repeat while 1

  outa[0] := numkeys==0
  
  if (game_pad.button(NES0_START))
    loadlevel
  if (numkeys ==  0)
    level++
    loadlevel

    
  if (game_pad.button(NES0_DOWN))
    if (map_buffer[guy_x + (guy_y+1) << 4] == $00_00 or map_buffer[guy_x + (guy_y+1) << 4] == $04_07)
      if !onbar
        map_buffer[guy_x + guy_y << 4] := $00_00
      if onbar
        map_buffer[guy_x + guy_y << 4] := $02_02
        onbar := 0
      guy_y++
      if map_buffer[guy_x + (guy_y) << 4] == $04_07
        numkeys--
    if (map_buffer[guy_x + (guy_y+1) << 4] == $02_05 )
      map_buffer[guy_x + guy_y << 4] := $00_00
      onbar := 1
      guy_y ++


  if (game_pad.button(NES0_UP))
    if (map_buffer[guy_x + (guy_y-1) << 4] == $00_00 or map_buffer[guy_x + (guy_y-1) << 4] == $04_07)
      if !onbar
        map_buffer[guy_x + guy_y << 4] := $00_00
      if onbar
        map_buffer[guy_x + guy_y << 4] := $02_02
        onbar := 0
      guy_y--
      if map_buffer[guy_x + (guy_y) << 4] == $04_07
        numkeys--
    if (map_buffer[guy_x + (guy_y-1) << 4] == $02_05 )
      map_buffer[guy_x + guy_y << 4] := $00_00
      onbar := 1
      guy_y --

      
  if (game_pad.button(NES0_LEFT))
    if (map_buffer[(guy_x-1) + (guy_y) << 4] == $00_00 or map_buffer[(guy_x-1) + (guy_y) << 4] == $04_07)
      if !onbar
        map_buffer[guy_x + guy_y << 4] := $00_00
      if onbar
        map_buffer[guy_x + guy_y << 4] := $02_03
        onbar := 0
      guy_x--
      if map_buffer[guy_x + (guy_y) << 4] == $04_07
        numkeys--
    if (map_buffer[(guy_x-1) + (guy_y) << 4] == $02_06 )
      map_buffer[guy_x + guy_y << 4] := $00_00
      onbar := 1
      guy_x --

      
  if (game_pad.button(NES0_RIGHT))
    if (map_buffer[(guy_x+1) + (guy_y) << 4] == $00_00 or map_buffer[(guy_x+1) + (guy_y) << 4] == $04_07)
      if !onbar
        map_buffer[guy_x + guy_y << 4] := $00_00
      if onbar
        map_buffer[guy_x + guy_y << 4] := $02_03
        onbar := 0
      guy_x++
      if map_buffer[guy_x + (guy_y) << 4] == $04_07
        numkeys--
    if (map_buffer[(guy_x+1) + (guy_y) << 4] == $02_06 )
      map_buffer[guy_x + guy_y << 4] := $00_00
      onbar := 1
      guy_x++
    
    
  'outa[0] := !outa[0]
  coloff += 1    'Animate laser bars
  if coloff == 4
    coloff := 0
  palette_map[2] := redpal[coloff]
  
  map_buffer[guy_x + guy_y << 4] := $03_04 'Draw guy
  
  repeat 45_000

pri loadlevel
    numkeys := level_data[level*3]
    guy_x := level_data[level*3+1]
    guy_y := level_data[level*3+2]
    onbar := 0
    wordmove(@map_buffer,@tile_maps+(level*buffersz*2),buffersz)
  

dat
tile_maps
tile_map0     word      $00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01 ' row 0
              word      $00_01,$03_04,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 1
              word      $00_01,$00_00,$01_01,$01_01,$01_01,$02_05,$01_01,$01_01,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 2
              word      $00_01,$00_00,$01_01,$04_07,$00_00,$00_00,$00_00,$01_01,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 3
              word      $00_01,$00_00,$01_01,$00_00,$00_00,$00_00,$00_00,$01_01,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 4
              word      $00_01,$00_00,$01_01,$01_01,$02_05,$01_01,$01_01,$01_01,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 5
              word      $00_01,$00_00,$02_06,$00_00,$00_00,$04_07,$00_00,$02_06,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 6
              word      $00_01,$00_00,$01_01,$02_05,$01_01,$01_01,$02_05,$01_01,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 7
              word      $00_01,$00_00,$01_01,$04_07,$00_00,$01_01,$04_07,$01_01,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 8
              word      $00_01,$00_00,$01_01,$01_01,$02_05,$01_01,$02_05,$01_01,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 9
              word      $00_01,$04_07,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 10
              word      $00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01 ' row 11

tile_map1     word      $00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01 ' row 0
              word      $00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 1
              word      $00_01,$00_00,$03_04,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 2
              word      $00_01,$00_00,$00_00,$04_08,$04_09,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 3
              word      $00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 4
              word      $00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 5
              word      $00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 6
              word      $00_01,$00_00,$00_00,$01_01,$01_01,$01_01,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 7
              word      $00_01,$00_00,$00_00,$01_01,$04_07,$01_01,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 8
              word      $00_01,$00_00,$00_00,$01_01,$01_01,$01_01,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 9
              word      $00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00,$00_01,$00_00,$00_00,$00_00,$00_00,$00_00,$00_00 ' row 10
              word      $00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01,$00_01 ' row 11
tile_bitmaps long
              ' tile bitmap memory, each tile 16x16 pixels, or 1 LONG by 16,
              ' 64-bytes each, also, note that they are mirrored right to left
              ' since the VSU streams from low to high bits, so your art must
              ' be reflected, we could remedy this in the engine, but for fun
              ' I leave it as a challenge in the art, since many engines have
              ' this same artifact
              ' for this demo, only 4 tile bitmaps defined

              ' empty tile
              ' palette black, blue, gray, white
tile_blank    long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0 ' tile 0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0

             ' box segment
tile_plus     long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0 ' tile 1
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1
              long      %%1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              
tile_horizbar long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0 ' tile 2
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_1_1_1_1_1_1_1_1_1_1_1_1_1_1_0
              long      %%1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1
              long      %%1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1
              long      %%0_1_1_1_1_1_1_1_1_1_1_1_1_1_1_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              
tile_vertibar long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_1_1_0_0_0_0_0_0_0

happy         long      %%0_0_0_0_1_1_1_1_1_1_1_1_0_0_0_0
              long      %%0_0_1_1_1_1_1_1_1_1_1_1_1_1_0_0
              long      %%0_1_1_1_1_1_1_1_1_1_1_1_1_1_1_0
              long      %%0_1_1_1_3_3_1_1_1_1_3_3_1_1_1_0
              long      %%1_1_1_1_3_3_1_1_1_1_3_3_1_1_1_1
              long      %%1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1
              long      %%1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1
              long      %%1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1
              long      %%1_1_1_2_2_1_1_1_1_1_1_2_2_1_1_1
              long      %%1_1_1_2_2_1_1_1_1_1_1_2_2_1_1_1
              long      %%1_1_1_2_2_1_1_1_1_1_1_2_2_1_1_1
              long      %%1_1_1_1_2_2_1_1_1_1_2_2_1_1_1_1
              long      %%0_1_1_1_1_2_2_2_2_2_2_1_1_1_1_0
              long      %%0_1_1_1_1_1_2_2_2_2_1_1_1_1_1_0
              long      %%0_0_1_1_1_1_1_1_1_1_1_1_1_1_0_0
              long      %%0_0_0_0_1_1_1_1_1_1_1_1_0_0_0_0

tile_uhoriz   long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_3_3_0_0_3_3_0_0_3_3_0_0_0
              long      %%3_0_0_3_3_0_0_3_3_0_0_3_3_0_0_3
              long      %%0_3_3_0_0_3_3_0_0_3_3_0_0_3_3_0
              long      %%0_3_3_0_0_3_3_0_0_3_3_0_0_3_3_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0

tile_uvertic  long      %%0_0_0_0_0_0_0_3_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_3_3_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_3_3_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_3_3_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_3_3_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_3_3_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_3_3_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_3_3_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_3_0_0_0_0_0_0_0_0
              
tile_key1     long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0 ' tile 7
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_1_1_1_1_0_0_0_0_0_0_0_0_0
              long      %%0_0_1_1_1_1_1_1_0_0_0_0_0_0_0_0
              long      %%0_1_1_1_0_0_1_1_1_0_0_0_0_0_0_0
              long      %%0_1_1_0_0_0_0_1_1_1_1_1_1_1_1_0
              long      %%0_1_1_0_0_0_0_1_1_1_1_1_1_1_1_0
              long      %%0_1_1_1_0_0_1_1_1_0_1_1_0_1_1_0
              long      %%0_0_1_1_1_1_1_1_0_0_1_1_0_1_1_0
              long      %%0_0_0_1_1_1_1_0_0_0_1_1_0_1_1_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0

tile_win1     long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0 ' tile 8
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%1_0_0_0_1_0_0_0_0_0_1_0_0_0_1_0
              long      %%1_0_0_0_1_0_0_0_0_0_1_0_0_0_1_0
              long      %%1_0_1_0_1_0_0_0_0_0_1_0_0_0_1_0
              long      %%1_0_1_0_1_0_0_0_0_0_1_0_0_0_1_0
              long      %%1_0_1_0_1_0_0_0_0_0_1_0_0_0_1_0
              long      %%1_0_1_0_1_0_0_0_0_0_1_0_0_0_1_0
              long      %%0_1_1_1_0_0_0_0_0_0_0_1_1_1_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0

tile_win2     long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0 ' tile 9
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_1_0_0_1_0_0_0_1_0_1_1_1_0
              long      %%0_0_0_1_0_0_1_0_0_1_1_0_0_1_0_0
              long      %%0_0_0_1_0_0_1_0_1_0_1_0_0_1_0_0
              long      %%0_0_0_1_0_0_1_1_0_0_1_0_0_1_0_0
              long      %%0_0_0_1_0_0_1_0_0_0_1_0_0_1_0_0
              long      %%0_0_0_0_0_0_1_0_0_0_1_0_0_1_0_0
              long      %%0_0_0_1_0_0_1_0_0_0_1_0_1_1_1_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
              long      %%0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0            



palette_map   long $07_5C_0C_02 ' palette 0 - background and wall tiles, 0-black, 1-blue, 2-red, 3-white
              long $07_5C_BC_02 ' palette 1 - background and wall tiles, 0-black, 1-green, 2-red, 3-white
              long $07_5C_5C_02
              long $0B_5B_7D_02
              long $07_07_07_02

level_data    byte 5,1,1 'format is (numkeys,xpos,ypos) for each level
              byte 1,2,2