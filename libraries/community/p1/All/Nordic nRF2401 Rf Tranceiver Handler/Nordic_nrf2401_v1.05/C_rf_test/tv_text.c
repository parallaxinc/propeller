/**
 * @file tv_text.c
 * TV_Text native device driver interface.
 *
 * Copyright (c) 2008, Steve Denson
 * See end of file for terms of use.
 */
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <propeller.h>

#include "TV_Array.h"
#include "tv_text.h"

/**
 * This is the main global tv text control/status structure.
 */
tvText_t gTvText;

/**
 * This is the TV text screen area.
 */
static short gscreen[TV_TEXT_SCREENSIZE];

/**
 * This is the TV color palette area.
 */
static int gcolors[TV_TEXT_COLORTABLE_SIZE];

/**
 * These are variables to keep up with display;
 */
static int col, row, flag;

static int blank = 0x220;

/**
 * This is the TV paletC:\Documents and Settings\Steve\Desktop\TradeWinds 2.lnk
te.
 */
static char gpalette[TV_TEXT_COLORTABLE_SIZE] =     
{                   // fgRGB  bgRGB
    0x07, 0x0a,     // 0    white / dark blue
    0x07, 0xbb,     // 1   yellow / brown
    0x9e, 0x9b,     // 2  magenta / black
    0x04, 0x07,     // 3     grey / white
    0x3d, 0x3b,     // 4     cyan / dark cyan
    0x6b, 0x6e,     // 5    green / gray-green
    0xbb, 0xce,     // 6      red / pink
    0x3e, 0x0a      // 7     cyan / blue
};

/*
 * This should set the character foreground and screen background.
 * API are available to get/set this.
 */
static int color = 0;

/*
 * global var to keep cogid so we don't have to pass parm to stop
 */
static int gTvTextCog = 0;

/*
 * delay function used after start cog and during screen updates
 * @param per is number of ticks to wait ....
 * Careful, if per is too small, the processor will wait until the next count
 * which can be on the order of minutes. 
 *
static void wait(int per)
{
    int time = 0;
    asm("mov        %time, cnt");
    asm("add        %time, %per");
    asm("waitcnt    %time, %per");
}    
 */
 
/*
 * TV_Text start function starts TV on a cog
 * See header file for more details.
 */
int     tvText_start(int basepin)
{
    int id = 0;

    col   = 0; // init vars
    row   = 0;
    flag  = 0;

    gTvText.status = 0;
    gTvText.enable = 1;
    gTvText.pins   = ((basepin & 0x38) << 1) | (((basepin & 4) == 4) ? 0b101 : 0);
    gTvText.mode   = 0b10010;
    gTvText.screen = (long) gscreen;
    gTvText.colors = (long) gcolors;
    gTvText.ht = TV_TEXT_COLS;
    gTvText.vt = TV_TEXT_ROWS;
    gTvText.hx = 4;
    gTvText.vx = 1;
    gTvText.ho = 0;
    gTvText.vo = 0;
    gTvText.broadcast = 0;
    gTvText.auralcog  = 0;
      
    id = cognew_native((void*)TV_Array, (void*)&gTvText);
    wait(1000000);
    gTvTextCog = id+1;
    
    // set main fg/bg color here
    tvText_setColorPalette(&gpalette[TV_TEXT_PAL_WHITE_BLUE]);
    wordfill(&gscreen[0], blank, TV_TEXT_SCREENSIZE);
    
    return id;
}

/**
 * stop stops the cog running the native assembly driver 
 */
void tvText_stop(void)
{
    int id = gTvTextCog - 1;
    if(gTvTextCog > 0) {
        asm("cogstop %id");
    }
}
/*
 * TV_Text setcolors function sets the palette to that defined by pointer.
 * See header file for more details.
 */
void    tvText_setColorPalette(char* ptr)
{
    int  ii = 0;
    int  mm = 0;
    int  fg = 0;
    int  bg = 0;
    for(ii = 0; ii < TV_TEXT_COLORTABLE_SIZE; ii += 2)
    {
        mm = ii + 1; // beta1 ICC has trouble with math in braces. use mm
        fg = ptr[ii] << 0;
        bg = ptr[mm] << 0;
        gcolors[ii]  = fg << 24 | bg << 16 | fg << 8 | bg;
        gcolors[mm]  = fg << 24 | fg << 16 | bg << 8 | bg;
   }        
}

/*
 * print a new line
 */
static void newline(void)
{
    col = 0;
    if (++row == TV_TEXT_ROWS) {
        row--;
        wordmove(&gscreen[0], &gscreen[TV_TEXT_COLS], TV_TEXT_LASTROW); // scroll
        wordfill(&gscreen[TV_TEXT_LASTROW], blank, TV_TEXT_COLS); // clear new line
    }
}

/*
 * print a character
 */
static void printc(int c)
{
    int   ndx = row * TV_TEXT_COLS + col;
    short val = 0;
    
    val  = (color << 1 | c & 1) << 10;
    val += 0x200 + (c & 0xFE);

    // Driver updates during invisible. Need some delay so screen updates right.
    // For flicker-free once per scan update, you can wait for status != invisible.
    // while(gTvText.status != TV_TEXT_STAT_INVISIBLE)    ;
    
    // Needed some delay before so printing works correctly. Seems ok without now.
    // wait(50);
    
    gscreen[ndx] = val; // works

    /* AJM */
    col++;
//    if (++col == TV_TEXT_COLS) {
//        newline();
//    }
}

/*
 * TV_Text getTile gets tile data from x,y position
 * See header file for more details.
 */
short   tvText_getTile(int x, int y)
{
    if(x >= TV_TEXT_COLS)
        return 0; 
    if(y >= TV_TEXT_ROWS)
        return 0;
    return gscreen[y * TV_TEXT_COLS + x];
}

/*
 * TV_Text setTile sets tile data at x,y position
 * See header file for more details.
 */
void tvText_setTile(int x, int y, short tile)
{
    if(x >= TV_TEXT_COLS)
        return; 
    if(y >= TV_TEXT_ROWS)
        return;
    gscreen[y * TV_TEXT_COLS + x] = tile;
}

/*
 * TV_Text setTileColor sets tile data color at x,y position
 * See header file for more details.
 */
int tvText_getTileColor(int x, int y)
{
    short tile = 0;
    int shift  = 11;
    int   mask = ((TV_TEXT_COLORS-1) << shift);
    int   ndx  = y * TV_TEXT_COLS + x;
    int   color = 0;
    
    if(x >= TV_TEXT_COLS)
        return 0; 
    if(y >= TV_TEXT_ROWS)
        return 0;
    color = gscreen[ndx] & mask;
    color >>= shift;
    return color;
}


/*
 * TV_Text setTileColor sets tile data color at x,y position
 * See header file for more details.
 */
void tvText_setTileColor(int x, int y, int color)
{
    short tile = 0;
    int shift  = 11;
    int   mask = ((TV_TEXT_COLORS-1) << shift);
    int   ndx  = y * TV_TEXT_COLS + x;
    
    while(gTvText.status != TV_TEXT_STAT_INVISIBLE)
        ;
    if(x >= TV_TEXT_COLS)
        return; 
    if(y >= TV_TEXT_ROWS)
        return;

    color <<= shift; 
    tile = gscreen[ndx];
    tile = tile & ~mask;
    tile = tile | color;
    gscreen[ndx] = tile;
}

/*
 * TV_Text str function prints a string at current position
 * See header file for more details.
 */
void    tvText_str(char* sptr)
{
    while(*sptr) {
#ifdef TV_TEXT_OUT
        tvText_out(*(sptr++));
#else
        putchar(*(sptr++));
#endif
    }
}

/*
 * TV_Text dec function prints a decimal number at current position
 * See header file for more details.
 */
void    tvText_dec(int value)
{
    char b[128];
    itoa(b, value, 10);
    tvText_str(b);
}

/*
 * TV_Text hex function prints a hexadecimal number at current position
 * See header file for more details.
 */
void    tvText_hex(int value, int digits)
{
    int ndx;
    char hexlookup[] =
    {
        '0', '1', '2', '3', '4', '5', '6', '7',
        '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
    };
    while(digits-- > 0) {
        ndx = (value >> (digits<<2)) & 0xf;
        printc(hexlookup[ndx]);
    }   
}


/*
 * TV_Text bin function prints a binary number at current position
 * See header file for more details.
 */
void    tvText_bin(int value, int digits)
{
    int bit = 0;
    while(digits-- > 0) {
        bit = (value >> digits) & 1;
        printc(bit + '0');
    }   
}

//#ifdef TV_TEXT_OUT
/*
 * TV_Text out function prints a character at current position or performs
 * a screen function.
 * See header file for more details.
 */
void    tvText_out(int c)
{
    if(flag == 0)
    {
        switch(c)
        {
            case 0:
                wordfill(&gscreen[0], color << 11 | blank, TV_TEXT_SCREENSIZE);
                col = 0;
                row = 0;
                break;
            case 1:
                col = 0;
                row = 0;
                break;
            case 8:
                if (col)
                    col--;
                break;
            case 9:
                do {
                    printc(' ');
                } while(col & 7);
                break;
            case 0xA:   // fall though
            case 0xB:   // fall though
            case 0xC:   // fall though
                flag = c;
                return;
            case 0xD:
                newline();
                break;
            default:
                printc(c);
                break;
        }
    }
    else
    if (flag == 0xA) {
        col = c % TV_TEXT_COLS;
    }
    else
    if (flag == 0xB) {
        row = c % TV_TEXT_ROWS;
    }
    else
    if (flag == 0xC) {
        color = c & 0xf;
    }
    flag = 0;
}
//#endif

/*
 * TV_Text print null terminated char* to screen with normal stdio definitions
 * See header file for more details.
 */
void    print(char* s)
{
    while(*s) {
        putchar(*(s++));
    }
}

/*
 * TV_Text putchar print char to screen with normal stdio definitions
 * See header file for more details.
 */
int     putchar(char c)
{
    switch(c)
    {
        case '\b':
            if (col)
                col--;
            break;
        case '\t':
            do {
                printc(' ');
            } while(col & 7);
            break;
        case '\n':
            newline();
            break;
        case '\r':
            col = 0;
            break;
        default:
            printc(c);
            break;
    }
    return (int)c;
}

/*
 * TV_Text setCurPosition function sets position to x,y.
 * See header file for more details.
 */
void    tvText_setCurPosition(int x, int y)
{
    col = x;
    row = y;
}

/*
 * TV_Text setCoordPosition function sets position to Cartesian x,y.
 * See header file for more details.
 */
void    tvText_setCoordPosition(int x, int y)
{
    col = x;
    row = TV_TEXT_ROWS-y-1;
}

/*
 * TV_Text setXY function sets position to x,y.
 * See header file for more details.
 */
void    tvText_setXY(int x, int y)
{
    col = x;
    row = y;
}

/*
 * TV_Text setX function sets column position value
 * See header file for more details.
 */
void    tvText_setX(int value)
{
    col = value;
}

/*
 * TV_Text setY function sets row position value
 * See header file for more details.
 */
void    tvText_setY(int value)
{
    row = value;
}

/*
 * TV_Text getX function gets column position
 * See header file for more details.
 */
int tvText_getX(void)
{
    return col;
}

/*
 * TV_Text getY function gets row position
 * See header file for more details.
 */
int tvText_getY(void)
{
    return row;
}

/*
 * TV_Text setColors function sets palette color set index
 * See header file for more details.
 */
void tvText_setColors(int value)
{
    color = value % TV_TEXT_COLORS;
}

/*
 * TV_Text getColors function gets palette color set index
 * See header file for more details.
 */
int tvText_getColors(void)
{
    return color % TV_TEXT_COLORS;
}

/*
 * TV_Text getWidth function gets screen width.
 * See header file for more details.
 */
int tvText_getColumns(void)
{
    return TV_TEXT_COLS;
}

/*
 * TV_Text getHeight function gets screen height.
 * See header file for more details.
 */
int tvText_getRows(void)
{
    return TV_TEXT_ROWS;
}

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