//
// VGA 64 demo - using a COG C based VGA driver.
// This is a very basic translation of Kwabena W. Agyeman's
// VGA64 6 Bits Per Pixel demo to C. I haven't included all
// of the methods of the original Spin object, just enough to
// get the visual demo going.
// Interested readers should get the original object; it is very
// well written and commented (unlike this code, unfortunately, which
// is just a proof-of-concept).
//
// The original is Copyright (c) 2010 Kwabena W. Agyeman
// C version is Copyright (c) 2011 Eric R. Smith
// Terms of use (MIT license) at end of file.
//
#define printf __simple_printf
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "vga.h"
#include "propeller.h"
#include "fdserial.h"

fdserial *term;

volatile struct {
    unsigned stack[8];
    struct vga_param v;
} par;
/*
 * function to start up a new cog running the toggle
 * code (which we've placed in the .coguser0 section)
 */
void startvga(volatile void *parptr)
{
    extern unsigned int _load_start_vga_cog[];
    int r;
    r = cognew(_load_start_vga_cog, parptr);
}

#define COLS 160
#define ROWS 120
#define PINGROUP 2

#define w COLS
#define h ROWS
unsigned char framebuffer[ROWS*COLS];


#define mapWidth 24
#define mapHeight 24

char worldMap[mapWidth][mapHeight]=
{
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
};

void
displayWait(int frames)
{
    int frameNo;
    while (frames-- > 0) {
        frameNo = par.v.frameCounter;
        do {} while (frameNo == par.v.frameCounter);
    }
}
static void
scrollfill(unsigned char color)
{
    int i;
    for (i = 0; i < ROWS; i++) {
        memcpy(framebuffer, framebuffer+COLS, COLS*(ROWS-1));
        memset(framebuffer+(COLS*(ROWS-1)), color, COLS);
    }
}
/* draw a horizontal line */
void
setpixel(unsigned char *frame, int x, int y, unsigned char color)
{
    int i;
    frame += (y*COLS) + x;
    *frame++ = color;
}
 void drawFloor(int x, int drawStart, int drawEnd, char color)
{
    int y;
    int xt = (40-x)/8;
    int startGrey = (xt*xt);
    for (y = drawStart; y < drawEnd; ++y)
    {
      if (y-115 > startGrey)
        setpixel(framebuffer, x, y, LightF);
      else if (y-100 > startGrey)
        setpixel(framebuffer, x, y, GreyF);
      else if (y-90 > startGrey)
        setpixel(framebuffer, x, y, DarkF);
      else
        setpixel(framebuffer, x, y, Black);
    }   
}  
void drawCeil(int x, int drawStart, int drawEnd, char color)
{
    int y;
    int xt = (40-x)/8;
    int startGrey = (xt*xt);
    for (y = drawStart; y < drawEnd; ++y)
    {
      if (5-y > startGrey)
        setpixel(framebuffer, x, y, LightF);
      else if (10 - y > startGrey)
        setpixel(framebuffer, x, y, GreyF);
      else if (15-y > startGrey)
        setpixel(framebuffer, x, y, DarkF);
      else
        setpixel(framebuffer, x, y, Black);
    }      
}  
 void drawWall(int x, int drawStart, int drawEnd, char color)
{
    int y;
    int xt = (40-x)/8;
    int startGrey = (xt*xt);
    char mask = Black;
    for (y = drawStart; y < drawEnd; ++y)
    {
      if (5-y > startGrey)
        mask = LightF;
      else if (10 - y > startGrey)
        mask = GreyF;
      else if (15-y > startGrey)
        mask = DarkF;
      else
        mask = Black;
      
      if (y-115 > startGrey)
        mask = mask|LightF;
      else if (y-100 > startGrey)
        mask = mask|GreyF;
      else if (y-90 > startGrey)
        mask = mask|DarkF;
        
      if (y > drawStart && y < drawEnd-1)
        setpixel(framebuffer, x, y, color|mask);
        else if (y > drawStart)
        setpixel(framebuffer, x, y, Dark_Grey|mask);
        else
        setpixel(framebuffer, x, y, Dark_Grey|mask);
        
    }      
} 
int
main()
{
  {
    unsigned int frequency, i, testval;
    unsigned int clkfreq = _CLKFREQ;

    _DIRA = (1<<15);
    _OUTA = 0;

    par.v.displayBuffer = framebuffer;
    par.v.directionState = (0xff << (8*PINGROUP));
    par.v.videoState = 0x300000FF | (PINGROUP<<9);
    testval = (25175000 + 1600) / 4;
    frequency = 1;
    for (i = 0; i < 32; i++) {
        testval = testval << 1;
        frequency = (frequency << 1) | (frequency >> 31);
        if (testval >= clkfreq) {
            testval -= clkfreq;
            frequency++;
        }
    }
    par.v.frequencyState = frequency;
    par.v.enabled = 1;

    // start up the video cog
    //memset(framebuffer, Grey, ROWS*COLS);
    startvga(&par.v);
  }    
  term = fdserial_open(31,30,0,115200);
  float posX = 22, posY = 12;  //x and y start position
  float dirX = -1, dirY = 0; //initial direction vector
  float planeX = 0, planeY = 0.66; //the 2d raycaster version of camera plane
  char c;
    
    while (1) {
        int x;

     
        //displayWait(60);
        //memset(framebuffer, Black, ROWS*COLS);
      for(x = 0; x < w; x++)
      {
        
        //calculate ray position and direction 
        float cameraX = 2 * x / (float)w - 1; //x-coordinate in camera space
        float rayPosX = posX;
        float rayPosY = posY;
        float rayDirX = dirX + planeX * cameraX;
        float rayDirY = dirY + planeY * cameraX;
        //which box of the map we're in  
        int mapX = (int)rayPosX;
        int mapY = (int)rayPosY;
         
        //length of ray from current position to next x or y-side
        float sideDistX;
        float sideDistY;
         
         //length of ray from one x or y-side to next x or y-side
        float deltaDistX = sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX));
        float deltaDistY = sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY));
        float perpWallDist;
         
        //what direction to step in x or y-direction (either +1 or -1)
        int stepX;
        int stepY;
  
        int hit = 0; //was there a wall hit?
        int side; //was a NS or a EW wall hit?
        //calculate step and initial sideDist
        if (rayDirX < 0)
        {
          stepX = -1;
          sideDistX = (rayPosX - mapX) * deltaDistX;
        }
        else
        {
          stepX = 1;
          sideDistX = (mapX + 1.0 - rayPosX) * deltaDistX;
        }
        if (rayDirY < 0)
        {
          stepY = -1;
          sideDistY = (rayPosY - mapY) * deltaDistY;
        }
        else
        {
          stepY = 1;
          sideDistY = (mapY + 1.0 - rayPosY) * deltaDistY;
        }
        
        //perform DDA
        while (hit == 0)
        {
          //jump to next map square, OR in x-direction, OR in y-direction
          if (sideDistX < sideDistY)
          {
            sideDistX += deltaDistX;
            mapX += stepX;
            side = 0;
          }
          else
          {
            sideDistY += deltaDistY;
            mapY += stepY;
            side = 1;
          }
          //Check if ray has hit a wall
          if (worldMap[mapX][mapY] > 0) hit = 1;
        } 
        //Calculate distance projected on camera direction (oblique distance will give fisheye effect!)
        if (side == 0)
        perpWallDist = fabs((mapX - rayPosX + (1 - stepX) / 2) / rayDirX);
        else
        perpWallDist = fabs((mapY - rayPosY + (1 - stepY) / 2) / rayDirY);
        
        //Calculate height of line to draw on screen
        int lineHeight = abs((int)(h / perpWallDist));
         
        //calculate lowest and highest pixel to fill in current stripe
        int drawStart = -lineHeight / 2 + h / 2;
        if(drawStart < 0)drawStart = 0;
        int drawEnd = lineHeight / 2 + h / 2;
        if(drawEnd >= h)drawEnd = h - 1;
          
        //choose wall color
        char color = Blue;
        /*
        switch(worldMap[mapX][mapY])
        {
          case 1:  color = Grey;  break; //red
          case 2:  color = Green;  break; //green
          case 3:  color = Blue;   break; //blue
          case 4:  color = White;  break; //white
          default: color = Grey; break; //yellow
        }*/
         
        //give x and y sides different brightness
        if (side == 1) {color = DkBlue;}
  
        //draw the pixels of the stripe as a vertical line
        //verLine(x, drawStart, drawEnd, color);
        drawWall(x,drawStart,drawEnd,color);
        drawCeil(x,0,drawStart,Dark_Grey);
        drawFloor(x,drawEnd,h-1,Dark_Grey);
      }
      c = fdserial_rxChar(term);
      if (c == 'w' || c == 's' || c == 'a' || c == 'd')
      {
        
        float moveSpeed = 0.42; //the constant value is in squares/second
        float rotSpeed = 3.141592/21.42; //the constant value is in radians/second
        if (c == 's')
        moveSpeed = -moveSpeed;
        else if (c == 'a')
        rotSpeed = -rotSpeed;
        if (c == 'a' || c == 'd')
        {
          //both camera direction and camera plane must be rotated
          float oldDirX = dirX;
          dirX = dirX * cosf(-rotSpeed) - dirY * sinf(-rotSpeed);
          dirY = oldDirX * sinf(-rotSpeed) + dirY * cosf(-rotSpeed);
          float oldPlaneX = planeX;
          planeX = planeX * cosf(-rotSpeed) - planeY * sinf(-rotSpeed);
          planeY = oldPlaneX * sinf(-rotSpeed) +   planeY * cosf(-rotSpeed);
        }
        else
        {        
          if(worldMap[(int)(posX + dirX * moveSpeed)][(int)(posY)] == 0)
            posX += dirX * moveSpeed;
          if(worldMap[(int)(posX)][(int)(posY + dirY * moveSpeed)] == 0)
            posY += dirY * moveSpeed;
        }          
      }          
    }
}
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
