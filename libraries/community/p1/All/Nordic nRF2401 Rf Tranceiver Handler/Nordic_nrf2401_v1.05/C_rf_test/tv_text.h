/**
 * @file tv_text.h
 * TV_Text native device driver interface
 *
 * Copyright (c) 2008, Steve Denson
 * See end of file for terms of use.
 */
 
/**
 * This module uses the TV.spin driver defined as an array of 
 * longs which was generated using the included px.bat file.
 * The px.bat file uses cygwin/linux applications od, sed, and cut.
 *
 * Currently setting individual character foreground/background
 * colors do not work. Setting a screen palette is ok though i.e.
 * setColorPalette(&gpalette[TV_TEXT_PAL_MAGENTA_BLACK]);
 */
 
#ifndef __TV_TEXT__
#define __TV_TEXT__

/**
 * TV_Text color indicies
 */
#define TV_TEXT_WHITE_BLUE     0
#define TV_TEXT_WHITE_RED      1
#define TV_TEXT_YELLOW_BROWN   2
#define TV_TEXT_GREY_WHITE     3
#define TV_TEXT_CYAN_DARKCYAN  4
#define TV_TEXT_GREEN_WHITE    5
#define TV_TEST_RED_PINK       6
#define TV_TEXT_CYAN_BLUE      7

#define TV_TEXT_COLORS 8

/**
 * TV_Text palette color indicies
 */
#define TV_TEXT_PAL_WHITE_BLUE     0
#define TV_TEXT_PAL_WHITE_RED      2
#define TV_TEXT_PAL_YELLOW_BROWN   4
#define TV_TEXT_PAL_GREY_WHITE     6
#define TV_TEXT_PAL_CYAN_DARKCYAN  8
#define TV_TEXT_PAL_GREEN_WHITE    10
#define TV_TEST_PAL_RED_PINK       12
#define TV_TEXT_PAL_CYAN_BLUE      14


/**
 * TV_Text color table size.
 * Table holds foreground and background info, so size is 2 x table colors.
 */
#define TV_TEXT_COLORTABLE_SIZE 8*2

/**
 * TV_Text column count
 */
#define  TV_TEXT_COLS 44

/**
 * TV_Text row count
 */
#define  TV_TEXT_ROWS 14

/**
 * TV_Text screensize count
 */
#define  TV_TEXT_SCREENSIZE (TV_TEXT_COLS * TV_TEXT_ROWS)

/**
 * TV_Text lastrow position count
 */
#define  TV_TEXT_LASTROW (TV_TEXT_SCREENSIZE-TV_TEXT_COLS)

/**
 * TV_Text status enum
 */
typedef enum {
    TV_TEXT_STAT_DISABLED,
    TV_TEXT_STAT_INVISIBLE,
    TV_TEXT_STAT_VISIBLE
} tvTextStat_t;

/**
 * TV_Text control struct
 */
typedef struct _tv_text_struct
{
    long status     ; //0/1/2 = off/invisible/visible              read-only
    long enable     ; //0/non-0 = off/on                           write-only
    long pins       ; //%pppmmmm = pin group, pin group mode       write-only
    long mode       ; //%tccip = tile,chroma,interlace,ntsc/pal    write-only
    long screen     ; //pointer to screen (words)                  write-only      
    long colors     ; //pointer to colors (longs)                  write-only                            
    long ht         ; //horizontal tiles                           write-only                            
    long vt         ; //vertical tiles                             write-only                            
    long hx         ; //horizontal tile expansion                  write-only                            
    long vx         ; //vertical tile expansion                    write-only                            
    long ho         ; //horizontal offset                          write-only                            
    long vo         ; //vertical offset                            write-only                            
    long broadcast  ; //broadcast frequency (Hz)                   write-only                            
    long auralcog   ; //aural fm cog                               write-only      
} tvText_t;

/*
 * TV_Text public API
 */

/**
 * TV_Text start function starts TV on a cog
 * @param basepin is first pin number (out of 8) connected to TV
 * param clockrate is the clockrate defined for the platform.
 * @returns non-zero cogid on success
 */
int     tvText_start(int basepin);

/**
 * TV_Text stop function stops TV cog
 */
void    tvText_stop(void);

/*
 * TV_Text getTile gets tile data from x,y position
 * See header file for more details.
 */
short   tvText_getTile(int x, int y);

/*
 * TV_Text setTile sets tile data at x,y position
 * @param x is screen column position
 * @param y is screen row position
 * @param tile is tile index
 */
void tvText_setTile(int x, int y, short tile);

/*
 * TV_Text setTileColor sets tile data color at x,y position
 * @param x is screen column position
 * @param y is screen row position
 * @returns tile color palette index
 */
int tvText_getTileColor(int x, int y);

/*
 * TV_Text setTileColor sets tile data color at x,y position
 * @param x is screen column position
 * @param y is screen row position
 * @param tile color palette index
 */
void tvText_setTileColor(int x, int y, int color);

/**
 * TV_Text str function prints a string at current position
 * @param sptr is string to print
 */
void    tvText_str(char* sptr);

/**
 * TV_Text dec function prints a decimal number at current position
 * @param value is number to print
 */
void    tvText_dec(int value);

/**
 * TV_Text hex function prints a hexadecimal number at current position
 * @param value is number to print
 * @param digits is number of digits in value to print
 */
void    tvText_hex(int value, int digits);

/**
 * TV_Text bin function prints a binary number at current position
 * @param value is number to print
 * @param digits is number of digits in value to print
 */
void    tvText_bin(int value, int digits);

/**
 * TV_Text out function prints a character at current position or performs
 * a screen function based on the following table:
 *
 *    $00 = clear screen
 *    $01 = home
 *    $08 = backspace
 *    $09 = tab (8 spaces per)
 *    $0A = set X position (X follows)
 *    $0B = set Y position (Y follows)
 *    $0C = set color (color follows)
 *    $0D = return
 * others = printable characters
 *
 * @param value is number to print
 * @param digits is number of digits in value to print
 */
void    tvText_out(int c);

/**
 * TV_Text setcolors function sets the palette to that defined by pointer.
 *
 * Override default color palette
 * palette must point to a list of up to 8 colors
 * arranged as follows (where r, g, b are 0..3):
 *
 *               fore   back
 *               ------------
 * palette  byte %%rgb, %%rgb     'color 0
 *          byte %%rgb, %%rgb     'color 1
 *          byte %%rgb, %%rgb     'color 2
 *          ...
 *
 * @param palette is a char array[16].
 */
void    tvText_setColorPalette(char* palette);

/**
 * TV_Text setTileColor sets tile data color at x,y position
 * @param x is current x screen position
 * @param y is current y screen position
 */
int     tvText_getTileColor(int x, int y);

/**
 * TV_Text setTileColor sets tile data color at x,y position
 * @param x is current x screen position
 * @param y is current y screen position
 * @param color is color to set
 */
void    tvText_setTileColor(int x, int y, int color);

/**
 * TV_Text setCurPositon function sets position to x,y.
 * @param x is column counted from left.
 * @param y is row counted from top.
 */
void    tvText_setCurPosition(int x, int y);

/**
 * TV_Text setCoordPosition function sets position to cartesian x,y.
 * @param x is column counted from left.
 * @param y is row counted from bottom.
 */
void    tvText_setCoordPosition(int x, int y);

/**
 * TV_Text setXY function sets position to x,y.
 * @param x is column counted from left.
 * @param y is row counted from top.
 */
void    tvText_setXY(int x, int y);

/**
 * TV_Text setX function sets column position value
 * @param value is new column position
 */
void    tvText_setX(int value);

/**
 * TV_Text setY function sets row position value
 * @param value is new row position
 */
void    tvText_setY(int value);

/**
 * TV_Text getX function gets column position
 * @returns column position
 */
int tvText_getX(void);

/**
 * TV_Text getY function gets row position
 * @returns row position
 */
int tvText_getY(void);

/**
 * TV_Text setColors function sets palette color set index
 * @param value is a color set index number 0 .. 7
 */
void tvText_setColors(int value);

/**
 * TV_Text getColors function gets palette color set index
 * @returns number representing color set index
 */
int tvText_getColors(void);

/**
 * TV_Text getWidth function gets screen width.
 * @returns screen column count.
 */
int tvText_getColumns(void);

/**
 * TV_Text getHeight function gets screen height.
 * @returns screen row count.
 */
int tvText_getRows(void);

/**
 * TV_Text print null terminated char* to screen with normal stdio definitions
 * @param s is null terminated string to print using putchar
 */
void    print(char* s);

/**
 * TV_Text putchar print char to screen with normal stdio definitions
 * @param c is character to print
 */
// void    putchar(char c); // let stdio.h define


#endif
//__TV_TEXT__

/*
+------------------------------------------------------------------------------------------------------------------------------+
¦                                                   TERMS OF USE: MIT License                                                  ¦                                                            
+------------------------------------------------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ¦ 
¦files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ¦
¦modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software¦
¦is furnished to do so, subject to the following conditions:                                                                   ¦
¦                                                                                                                              ¦
¦The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.¦
¦                                                                                                                              ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ¦
¦WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ¦
¦COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ¦
¦ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ¦
+------------------------------------------------------------------------------------------------------------------------------+
*/