{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VGA64 Bitmap Engine
//
// Author: Kwabena W. Agyeman
// Updated: 7/15/2010
// Designed For: P8X32A
// Version: 1.1
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 9/28/2009.
// v1.1 - Merged and rewrote code and added more features - 7/15/2010.
//
// For each included copy of this object only one spin interpreter should access it at a time.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Video Circuit:
//
//     0   1   2   3 Pin Group
//
//                     240OHM
// Pin 0,  8, 16, 24 ----R-------- Vertical Sync
//
//                     240OHM
// Pin 1,  9, 17, 25 ----R-------- Horizontal Sync
//
//                     470OHM
// Pin 2, 10, 18, 26 ----R-------- Blue Video
//                            |
//                     240OHM |
// Pin 3, 11, 19, 27 ----R-----
//
//                     470OHM
// Pin 4, 12, 20, 28 ----R-------- Green Video
//                            |
//                     240OHM |
// Pin 5, 13, 21, 29 ----R-----
//
//                     470OHM
// Pin 6, 14, 22, 30 ----R-------- Red Video
//                            |
//                     240OHM |
// Pin 7, 15, 23, 31 ----R-----
//
//                            5V
//                            |
//                            --- 5V
//
//                            --- Vertical Sync Ground
//                            |
//                           GND
//
//                            --- Hoirzontal Sync Ground
//                            |
//                           GND
//
//                            --- Blue Return
//                            |
//                           GND
//
//                            --- Green Return
//                            |
//                           GND
//
//                            --- Red Return
//                            |
//                           GND
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  #$FC, Light_Grey, #$A8, Grey, #$54, Dark_Grey
  #$C0, Light_Red, #$80, Red, #$40, Dark_Red
  #$30, Light_Green, #$20, Green, #$10, Dark_Green
  #$0C, Light_Blue, #$08, Blue, #$04, Dark_Blue
  #$F0, Light_Orange, #$A0, Orange, #$50, Dark_Orange
  #$CC, Light_Purple, #$88, Purple, #$44, Dark_Purple
  #$3C, Light_Teal, #$28, Teal, #$14, Dark_Teal
  #$FF, White, #$00, Black

PUB plotCharacter(characterValue, xPixel, yPixel, displayBase) '' 7 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Plots a 16x32 pixel character on screen.
'' //
'' // CharacterValue - The ASCII character to plot on screen from the internal character ROM. BG = %%0. FG = %%1
'' // XPixel - The X cartesian pixel coordinate, will be forced to be multiple of 16. Y will be forced to be a multiple of 32.
'' // YPixel - The Y cartesian pixel coordinate. Note that this axis is inverted like on all other graphics drivers.
'' // DisplayBase - The address of the display buffer to draw to.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  displayBase += ( ((((xPixel <# (horizontalPixels - 1)) #> 0) >> 4) << (bitsPerPixel + 1)) + {
                 } (((((yPixel <# (verticalPixels - 1)) #> 0) >> 5) * horizontalLongs) << 7) )

  characterValue := (characterValue // 256)
  xPixel := (characterValue & 1)
  characterValue := (((characterValue >> 1) << 7) + $80_00)

  repeat result from 0 to 31
    yPixel := (long[characterValue][result] >> xPixel)

    ifnot(bitsPerPixel)
      yPixel := (yPixel & $11_11_11_11) | ((yPixel & $44_44_44_44) >> 1)
      yPixel := (yPixel & $03_03_03_03) | ((yPixel & $30_30_30_30) >> 2)
      yPixel := (yPixel & $00_0F_00_0F) | ((yPixel & $0F_00_0F_00) >> 4)
      word[displayBase] := (yPixel & $00_00_00_FF) | ((yPixel & $00_FF_00_00) >> 8)
    else
      long[displayBase] := (yPixel & $55_55_55_55)

    displayBase += (horizontalLongs << 2)
    if(displayBase => (((horizontalLongs * verticalPixels) << 2) + screenPointer))
      quit

PUB plotPixel(pixelValue, xPixel, yPixel, displayBase) '' 7 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Plots a 1x1 pixel on screen.
'' //
'' // PixelValue - The pixel to plot on screen. Between %%0 and %%1 or between %%0, %%1, %%2, and %%3 depending on color mode.
'' // XPixel - The X cartesian pixel coordinate, will be forced to be multiple of 1. Y will be forced to be a multiple of 1.
'' // YPixel - The Y cartesian pixel coordinate. Note that this axis is inverted like on all other graphics drivers.
'' // DisplayBase - The address of the display buffer to draw to.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  xPixel := ((xPixel <# (horizontalPixels - 1)) #> 0)
  displayBase += (((horizontalLongs * ((yPixel <# (verticalPixels - 1)) #> 0)) + (xPixel >> (5 - bitsPerPixel))) << 2)

  xPixel := ((xPixel & ($1F >> bitsPerPixel)) << bitsPerPixel)
  yPixel := (!((1 + (bitsPerPixel << 1)) << xPixel))

  long[displayBase] := ((long[displayBase] & yPixel) | (((pixelValue <# (1 + (bitsPerPixel << 1))) #> 0) << xPixel))

PUB displayState(state) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Enables or disables the BMP Driver's video output - turning the monitor off or putting it into standby mode.
'' //
'' // State - True for active and false for inactive.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  displayIndicator := state

PUB displayRate(rate) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true or false depending on the time elasped according to a specified rate.
'' //
'' // Rate - A display rate to return at. 0=0.234375Hz, 1=0.46875Hz, 2=0.9375Hz, 3=1.875Hz, 4=3.75Hz, 5=7.5Hz, 6=15Hz, 7=30Hz.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result or= (($80 >> ((rate <# 7) #> 0)) & syncIndicator)

PUB displayWait(frames) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Waits for the display vertical refresh.
'' //
'' // The best time to draw on screen for flicker free operation is right after this function returns.
'' //
'' // Frames - Number of vertical refresh frames to wait for.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  repeat (frames #> 0)
    result := syncIndicator
    repeat until(result <> syncIndicator)

PUB displayPointer(newDisplayPointer) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Changes the display pointer for the whole screen.
'' //
'' // In 1 bit per pixel mode each pixel can have a value of 0 or 1 which map to the 0 and 1 colors for the whole screen.
'' // In 2 bits per pixel mode each pixel can have a value of 0 to 3 which map to the 0-3 colors for the whole screen.
'' //
'' // In 1 bit per pixel mode the display buffer must be of size ((horizontalPixels * verticalPixels) / 32) in longs.
'' // In 2 bits per pixel mode the display buffer must be of size ((horizontalPixels * verticalPixels) / 16) in longs.
'' //
'' // In 1 bit per pixel mode each long holds 32 pixels.
'' // In 2 bits per pixel mode each long holds 16 pixels.
'' //
'' // The LSB/LBSs of every long is/are the left most pixel while the MSB/MSBs of every long is/are the right most pixel.
'' //
'' // NewDisplayPointer - The address of the new display buffer to be displayed after the vertical refresh.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  screenPointer := newDisplayPointer

PUB displayColor(pixelNumber, newColor) '' 5 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Changes a pixel color for the whole screen.
'' //
'' // PixelNumber - The pixel number to change for the whole screen. Between 0 and 1 or 0 to 3.
'' // NewColor - A color byte (%RR_GG_BB_xx) describing the pixel's new color for the whole screen.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  pixelColors.byte[(pixelNumber <# (1 + (bitsPerPixel << 1))) #> 0] := newColor

PUB displayClear(patternValue, displayBase) '' 5 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Clears the whole screen.
'' //
'' // PatternValue - The pattern to plot on screen.
'' // DisplayBase - The address of the display buffer to draw to.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  longfill(displayBase, patternValue, (horizontalLongs * verticalPixels))

PUB BMPEngineStart(pinGroup, colorMode, horizontalResolution, verticalResolution, newDisplayPointer) '' 11 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Starts up the BMP driver running on a cog.
'' //
'' // Returns true on success and false on failure.
'' //
'' // PinGroup - Pin group to use to drive the video circuit. Between 0 and 3.
'' // ColorMode - Color mode to use for the whole screen. Between 1 bit per pixel or 2 bits per pixel.
'' // HorizontalResolution - The driver will force this value to be a factor of 640 and divisible by 16 or 32. 16/32 to 640.
'' // VerticalResolution - The driver will force this value to be a factor of 480. 1 to 480.
'' // NewDisplayPointer - The address of the new display buffer to be displayed after the vertical refresh.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  BMPEngineStop
  if(chipver == 1)

    pinGroup := ((pinGroup <# 3) #> 0)
    bitsPerPixel := ((colorMode <# 2) #> 1)

    directionState := ($FF << (8 * pinGroup))
    videoState := ($20_00_00_FF | (pinGroup << 9) | ((--bitsPerPixel) << 28))

    pinGroup := constant((25_175_000 + 1_600) / 4)
    frequencyState := 1

    repeat 32
      pinGroup <<= 1
      frequencyState <-= 1
      if(pinGroup => clkfreq)
        pinGroup -= clkfreq
        frequencyState += 1

    horizontalResolution := ((horizontalResolution <# 640) #> (32 >> bitsPerPixel))
    repeat while((640 // horizontalResolution) or ((horizontalResolution--) // (32 >> bitsPerPixel)))
    horizontalScaling := (640 / (++horizontalResolution))

    verticalResolution := ((verticalResolution <# 480) #> 1)
    repeat while(480 // verticalResolution--)
    verticalScaling := (480 / (++verticalResolution))

    horizontalPixels := (640 / horizontalScaling)
    verticalPixels := (480 / verticalScaling)

    visibleScale := ((horizontalScaling << 12) + ((constant(640 * 32) >> bitsPerPixel) / horizontalPixels))
    invisibleScale := (((8 << bitsPerPixel) << 12) + 160)

    horizontalLongs := (horizontalPixels / (32 >> bitsPerPixel))
    horizontalLoops := (horizontalLongs * 4)

    screenPointer := newDisplayPointer
    pixelColorsAddress := @pixelColors
    displayIndicatorAddress := @displayIndicator
    syncIndicatorAddress := @syncIndicator

    cogNumber := cognew(@initialization, @screenPointer)
    result or= ++cogNumber

PUB BMPEngineStop '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Shuts down the BMP driver running on a cog.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if(cogNumber)
    cogstop(-1 + cogNumber~)

DAT

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       BMP Driver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        org     0

' //////////////////////Initialization/////////////////////////////////////////////////////////////////////////////////////////

initialization          mov     vcfg,                 videoState                    ' Setup video hardware.
                        mov     frqa,                 frequencyState                '
                        movi    ctra,                 #%0_00001_101                 '

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Active Video
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

loop                    rdlong  buffer,               par                           ' Set/Reset tiles fill counter.
                        mov     tilesCounter,         verticalPixels                '

tilesDisplay            mov     tileCounter,          verticalScaling               ' Set/Reset tile fill counter.

tileDisplay             mov     vscl,                 visibleScale                  ' Set/Reset the video scale.
                        mov     counter,              horizontalLongs               '

' //////////////////////Visible Video//////////////////////////////////////////////////////////////////////////////////////////

videoLoop               rdlong  screenPixels,         buffer                        ' Download new pixels.
                        add     buffer,               #4                            '

                        waitvid screenColors,         screenPixels                  ' Update display scanline.

                        djnz    counter,              #videoLoop                    ' Repeat.

' //////////////////////Invisible Video////////////////////////////////////////////////////////////////////////////////////////

                        mov     vscl,                 invisibleScale                ' Set/Reset the video scale.

                        waitvid HSyncColors,          syncPixels                    ' Horizontal Sync.

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////

                        sub     buffer,               horizontalLoops               ' Repeat.
                        djnz    tileCounter,          #tileDisplay                  '

                        add     buffer,               horizontalLoops               ' Repeat.
                        djnz    tilesCounter,         #tilesDisplay                 '

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Inactive Video
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        rdlong  screenColors,         pixelColorsAddress            ' Get new screen colors.
                        or      screenColors,         HVSyncColors                  '

' //////////////////////Update Indicator///////////////////////////////////////////////////////////////////////////////////////

                        add     refreshCounter,       #1                            ' Update sync indicator.
                        wrbyte  refreshCounter,       syncIndicatorAddress          '

' //////////////////////Front Porch////////////////////////////////////////////////////////////////////////////////////////////

                        mov     counter,              #11                           ' Set loop counter.

frontPorch              mov     vscl,                 blankPixels                   ' Invisible lines.
                        waitvid HSyncColors,          #0                            '

                        mov     vscl,                 invisibleScale                ' Horizontal Sync.
                        waitvid HSyncColors,          syncPixels                    '

                        djnz    counter,              #frontPorch                   ' Repeat # times.

' //////////////////////Vertical Sync//////////////////////////////////////////////////////////////////////////////////////////

                        mov     counter,              #(2 + 2)                      ' Set loop counter.

verticalSync            mov     vscl,                 blankPixels                   ' Invisible lines.
                        waitvid VSyncColors,          #0                            '

                        mov     vscl,                 invisibleScale                ' Vertical Sync.
                        waitvid VSyncColors,          syncPixels                    '

                        djnz    counter,              #verticalSync                 ' Repeat # times.

' //////////////////////Back Porch/////////////////////////////////////////////////////////////////////////////////////////////

                        mov     counter,              #31                           ' Set loop counter.

backPorch               mov     vscl,                 blankPixels                   ' Invisible lines.
                        waitvid HSyncColors,          #0                            '

                        mov     vscl,                 invisibleScale                ' Horizontal Sync.
                        waitvid HSyncColors,          syncPixels                    '

                        djnz    counter,              #backPorch                    ' Repeat # times.

' //////////////////////Update Display Settings////////////////////////////////////////////////////////////////////////////////

                        rdbyte  buffer,               displayIndicatorAddress wz    ' Update display settings.
                        muxnz   dira,                 directionState                '

' //////////////////////Loop///////////////////////////////////////////////////////////////////////////////////////////////////

                        jmp     #loop                                               ' Loop.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Data
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

blankPixels             long    640                                                 ' Blank scanline pixel length.
syncPixels              long    $00_00_3F_FC                                        ' F-porch, h-sync, and b-porch.
HSyncColors             long    $01_03_01_03                                        ' Horizontal sync color mask.
VSyncColors             long    $00_02_00_02                                        ' Vertical sync color mask.
HVSyncColors            long    $03_03_03_03                                        ' Horizontal and vertical sync colors.

' //////////////////////Configuration Settings/////////////////////////////////////////////////////////////////////////////////

directionState          long    0
videoState              long    0
frequencyState          long    0
horizontalScaling       long    0
verticalScaling         long    0
horizontalPixels        long    0
verticalPixels          long    0
visibleScale            long    0
invisibleScale          long    0
horizontalLongs         long    0
horizontalLoops         long    0

' //////////////////////Addresses//////////////////////////////////////////////////////////////////////////////////////////////

pixelColorsAddress      long    0
displayIndicatorAddress long    0
syncIndicatorAddress    long    0

' //////////////////////Run Time Variables/////////////////////////////////////////////////////////////////////////////////////

counter                 res     1
buffer                  res     1

tileCounter             res     1
tilesCounter            res     1

screenPixels            res     1
screenColors            res     1

refreshCounter          res     1
displayCounter          res     1

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        fit     496

DAT

' //////////////////////Variable Arrary////////////////////////////////////////////////////////////////////////////////////////

screenPointer           long    0                                                   ' Screen pointer.
pixelColors             long    0                                                   ' Screen colors.
displayIndicator        byte    1                                                   ' Video output control.
syncIndicator           byte    0                                                   ' Video update control.
cogNumber               byte    0                                                   ' Cog ID.
bitsPerPixel            byte    0                                                   ' Bits ID.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{{

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}