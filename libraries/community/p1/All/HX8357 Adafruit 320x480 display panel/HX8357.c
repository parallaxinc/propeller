/**
 * @brief HX8357 320x480 display panel
 * @author Michael Burmeister
 * @date March 11, 2019
 * @version 1.0
*/

#include "simpletools.h"
#include "HX8357.h"
#include "HX8357Reg.h"

void writeCmd(int);
int readCmd(int);
void drawLine(short, short, short, short, short);
void spi_out(int, int);

char _CLK;
char _MISO;
char _MOSI;
char _CS;
char _DC;
char _RST;
char _LITE;
int _DMask;
int _Dmask;
int _CMask;
int _Cmask;
short _width;
short _height;
short _cursorX;
short _cursorY;
short _fgc;
short _bgc;

char Gamma[] = {0x02, 0x0a, 0x11, 0x1d, 0x23, 0x35, 0x41, 0x4b, 0x42, 0x3a, 0x27, 0x1b, 0x08, 0x09, 0x03,
                0x02, 0x0a, 0x11, 0x1d, 0x23, 0x35, 0x41, 0x4b, 0x42, 0x3a, 0x27, 0x1b, 0x08, 0x09, 0x03,
                0x00, 0x01};

// font 5x7 in 8x8 format line by line
long Font_57[] = {0x1f1f1f1f, 0x1f1f1f1f, //0x0
               0x07030101, 0x3f1f0f07, //0x1
               0x151b111f, 0x1f111b15, //0x2
               0x1c1e1e1f, 0x10101818, //0x3
               0x18040201, 0x01020418, //0x4
               0x1f000000, 0x0000001f, //0x5
               0x04040404, 0x04040404, //0x6
               0x1111111f, 0x1f111111, //0x7
               0x150a150a, 0x150a150a, //0x8
               0x150a150a, 0x150a150a, //0x9
               0x150a150a, 0x150a150a, //0xa
               0x150a150a, 0x150a150a, //0xb
               0x150a150a, 0x150a150a, //0xc
               0x150a150a, 0x150a150a, //0xd
               0x150a150a, 0x150a150a, //0xe
               0x150a150a, 0x150a150a, //0xf
               0x1f1f1f1f, 0x1f1f1f1f, //0x10
               0x071b1d1e, 0x1e1d1b07, //0x11
               0x00001f1f, 0x1f1f0000, //0x12
               0x11111111, 0x11111111, //0x13
               0x151b1b1f, 0x1f1b1b15, //0x14
               0x1313131f, 0x1f131313, //0x15
               0x1919191f, 0x1f191919, //0x16
               0x1111111f, 0x1f111111, //0x17
               0x1111111f, 0x1f111111, //0x18
               0x1111111f, 0x1f111111, //0x19
               0x1111111f, 0x1f111111, //0x1a
               0x1111111f, 0x1f111111, //0x1b
               0x1111111f, 0x1f111111, //0x1c
               0x1111111f, 0x1f111111, //0x1d
               0x1111111f, 0x1f111111, //0x1e
               0x1111111f, 0x1f111111, //0x1f
               0x00000000, 0x00000000, //0x20
               0x01010101, 0x00010001, //0x21
               0x0012091b, 0x00000000, //0x22
               0x0a1f0a00, 0x00000a1f, //0x23
               0x0e051e04, 0x00040f14, //0x24
               0x04081111, 0x00111102, //0x25
               0x02050502, 0x00160915, //0x26
               0x0004080c, 0x00000000, //0x27
               0x04040810, 0x00100804, //0x28
               0x04040201, 0x00010204, //0x29
               0x0e150400, 0x0004150e, //0x2a
               0x1f040400, 0x00000404, //0x2b
               0x00000000, 0x01020300, //0x2c
               0x1f000000, 0x00000000, //0x2d
               0x00000000, 0x00030300, //0x2e
               0x04081010, 0x00010102, //0x2f
               0x1519110e, 0x000e1113, //0x30
               0x04040604, 0x000e0404, //0x31
               0x0810110e, 0x001f0106, //0x32
               0x0e10110e, 0x000e1110, //0x33
               0x090a0c08, 0x0008081f, //0x34
               0x100f011f, 0x000e1110, //0x35
               0x0f01020c, 0x000e1111, //0x36
               0x0408101f, 0x00020202, //0x37
               0x0e11110e, 0x000e1111, //0x38
               0x1e11110e, 0x00060810, //0x39
               0x00030300, 0x00000303, //0x3a
               0x00030300, 0x01020303, //0x3b
               0x02040810, 0x00100804, //0x3c
               0x001f0000, 0x0000001f, //0x3d
               0x08040201, 0x00010204, //0x3e
               0x0810110e, 0x00040004, //0x3f
               0x1515110e, 0x001e010d, //0x40
               0x11110a04, 0x0011111f, //0x41
               0x0f11110f, 0x000f1111, //0x42
               0x0101120c, 0x000c1201, //0x43
               0x11110907, 0x00070911, //0x44
               0x0f01011f, 0x001f0101, //0x45
               0x0f01011f, 0x00010101, //0x46
               0x0101110e, 0x000e1119, //0x47
               0x1f111111, 0x00111111, //0x48
               0x0404041f, 0x001f0404, //0x49
               0x10101010, 0x000e1110, //0x4a
               0x03050911, 0x00110905, //0x4b
               0x01010101, 0x001f0101, //0x4c
               0x15151b11, 0x00111111, //0x4d
               0x15131111, 0x00111119, //0x4e
               0x1111110e, 0x000e1111, //0x4f
               0x0f11110f, 0x00010101, //0x50
               0x1111110e, 0x00160915, //0x51
               0x0f11110f, 0x00110905, //0x52
               0x0e01110e, 0x000e1110, //0x53
               0x0404041f, 0x00040404, //0x54
               0x11111111, 0x000e1111, //0x55
               0x0a111111, 0x0004040a, //0x56
               0x15111111, 0x000a1515, //0x57
               0x040a1111, 0x0011110a, //0x58
               0x040a1111, 0x00040404, //0x59
               0x0408101f, 0x001f0102, //0x5a
               0x0303031f, 0x001f0303, //0x5b
               0x04020101, 0x00101008, //0x5c
               0x1818181f, 0x001f1818, //0x5d
               0x0a040000, 0x00000011, //0x5e
               0x00000000, 0x1f000000, //0x5f
               0x000c0408, 0x00000000, //0x60
               0x100e0000, 0x001e111e, //0x61
               0x110f0101, 0x000f1111, //0x62
               0x011e0000, 0x001e0101, //0x63
               0x111e1010, 0x001e1111, //0x64
               0x110e0000, 0x001e011f, //0x65
               0x0f02120c, 0x00020202, //0x66
               0x110e0000, 0x0e101e11, //0x67
               0x110f0101, 0x00111111, //0x68
               0x04060004, 0x000e0404, //0x69
               0x080c0008, 0x06090808, //0x6a
               0x09110101, 0x00110906, //0x6b
               0x04040406, 0x000e0404, //0x6c
               0x151b0000, 0x00111515, //0x6d
               0x110f0000, 0x00111111, //0x6e
               0x110e0000, 0x000e1111, //0x6f
               0x110f0000, 0x01010f11, //0x70
               0x111e0000, 0x10101e11, //0x71
               0x031d0000, 0x00010101, //0x72
               0x011e0000, 0x000f100e, //0x73
               0x020f0202, 0x000c1202, //0x74
               0x11110000, 0x00161911, //0x75
               0x11110000, 0x00040a11, //0x76
               0x11110000, 0x001b1515, //0x77
               0x0a110000, 0x00110a04, //0x78
               0x11110000, 0x0e101e11, //0x79
               0x081f0000, 0x001f0204, //0x7a
               0x0306061c, 0x001c0606, //0x7b
               0x04040404, 0x04040404, //0x7c
               0x180c0c07, 0x00070c0c, //0x7d
               0x000d1600, 0x00000000, //0x7e
               0x1f1f1f1f, 0x1f1f1f1f}; //0x7f


int HX8357_open(char Clk, char MISO, char MOSI, char CS, char DC, char RST, char LITE)
{
  int i;
  
  _CLK = Clk;
  _MOSI = MOSI;
  _MISO = MISO;
  _CMask = 1 << Clk;
  _Cmask = ~_CMask;
  _DMask = 1 << MOSI;
  _Dmask = ~_DMask;
  _CS = CS;
  _DC = DC;
  _RST = RST;
  _LITE = LITE;
  _cursorX = 0;
  _cursorY = 0;
  _fgc = 65535;
  _bgc = 0;
  
  low(_DC);
  high(_CS);
  input(_MISO);
  high(_MOSI);
  low(_RST);
  pause(500);
  high(_RST);
  pause(500);
  
  low(_CS); // begin data
  low(_CLK);
  
  writeCmd(HX8357_SWRESET);
  
  pause(500);
  
  writeCmd(HX8357D_SETC);
  spi_out(8, 0xff);
  spi_out(8, 0x83);
  spi_out(8, 0x57);
  pause(300);
  // setRGB which also enables SDO  
  writeCmd(HX8357_SETRGB);
  spi_out(8, 0x80); //enable SDO pin!
  // shift_out(MOSI, _CLK, MSBFIRST, 8, 0x00); //disable SDO pin!
  spi_out(8, 0x0);
  spi_out(8, 0x06);
  spi_out(8, 0x06);
  
  writeCmd(HX8357D_SETCOM);
  spi_out(8, 0x25); // -1.52V
  
  writeCmd(HX8357_SETOSC);
  spi_out(8, 0x68); // Normal mode 70Hz, Idle mode 55 Hz
  
  writeCmd(HX8357_SETPANEL);
  spi_out(8, 0x05); // BGR, Gate direction swapped
  
  writeCmd(HX8357_SETPWR1);
  spi_out(8, 0x00); // Not deep standby
  spi_out(8, 0x15); //BT
  spi_out(8, 0x1c); //VSPR
  spi_out(8, 0x1c); //VSNR
  spi_out(8, 0x83); //AP
  spi_out(8, 0xaa); //FS
  
  writeCmd(HX8357D_SETSTBA);
  spi_out(8, 0x50); //OPON normal
  spi_out(8, 0x50); //OPON idle
  spi_out(8, 0x01); //STBA
  spi_out(8, 0x3c); //STBA
  spi_out(8, 0x1e); //STBA
  spi_out(8, 0x08); //GEN
  
  writeCmd(HX8357D_SETCYC);
  spi_out(8, 0x02); //NW 0x02
  spi_out(8, 0x40); //RTN
  spi_out(8, 0x00); //DIV
  spi_out(8, 0x2a); //DUM
  spi_out(8, 0x2a); //DUM
  spi_out(8, 0x0d); //GDON
  spi_out(8, 0x78); //GDOFF
  
  writeCmd(HX8357D_SETGAMMA);
  for (i=0;i<sizeof(Gamma);i++)
    spi_out(8, Gamma[i]);

  writeCmd(HX8357_COLMOD);
  spi_out(8, 0x55); // 16 bit
  
  writeCmd(HX8357_MADCTL);
  spi_out(8, 0xc0);
  
  writeCmd(HX8357_TEON);
  spi_out(8, 0x00); // TE off
  
  writeCmd(HX8357_TEARLINE);
  spi_out(8, 0x00); // tear line
  spi_out(8, 0x02);
  
  writeCmd(HX8357_SLPOUT);  // exit sleep
  pause(150);
  
  high(CS);
  _width  = HX8357_TFTWIDTH;
  _height = HX8357_TFTHEIGHT;
  
  i = readCmd(HX8357_RDPOWMODE);
  
  return i;
}

void HX8357_rotation(char rotation)
{
  char i;
  
  rotation = rotation & 0x03;
  switch (rotation)
  {
    case 0:
      i = MADCTL_MX | MADCTL_MY | MADCTL_RGB;
      _width  = HX8357_TFTWIDTH;
      _height = HX8357_TFTHEIGHT;
      break;
    case 1:
      i = MADCTL_MV | MADCTL_MY | MADCTL_RGB;
      _width  = HX8357_TFTHEIGHT;
      _height = HX8357_TFTWIDTH;
      break;
    case 2:
      i = MADCTL_RGB;
      _width  = HX8357_TFTWIDTH;
      _height = HX8357_TFTHEIGHT;
      break;
    case 3:
      i = MADCTL_MX | MADCTL_MV | MADCTL_RGB;
      _width  = HX8357_TFTHEIGHT;
      _height = HX8357_TFTWIDTH;
      break;
  }          
  low(_CS);
  writeCmd(HX8357_MADCTL);
  spi_out(8, i); //shift_out(_MOSI, _CLK, MSBFIRST, 8, i);
  high(_CS);
}

void HX8357_invert(char yes)
{
  low(_CS);
  if (yes != 0)
    writeCmd(HX8357_INVON);
  else
    writeCmd(HX8357_INVOFF);
  high(_CS);
}

void HX8357_window(short x, short y, short w, short h)
{
  int xa, xy;
  
  xa = x << 16 | (x+w-1);
  xy = y << 16 | (y+h-1);
  writeCmd(HX8357_CASET); // set column address
  spi_out(32, xa); //shift_out(_MOSI, _CLK, MSBFIRST, 32, xa);
  writeCmd(HX8357_PASET); // set row address
  spi_out(32, xy); //shift_out(_MOSI, _CLK, MSBFIRST, 32, xy);
  
  writeCmd(HX8357_RAMWR); // write to ram
}

void HX8357_pushColor(short color)
{
  low(_CS);
  spi_out(16, color); //shift_out(_MOSI, _CLK, MSBFIRST, 16, color);
  high(_CS);
}

void HX8357_writePixel(short color)
{
  spi_out(16, color); //shift_out(_MOSI, _CLK, MSBFIRST, 16, color);
}

void HX8357_writeColor(short color, int len)
{
  int i;
  
  for (i=0;i<len;i++)
    spi_out(16, color); //shift_out(_MOSI, _CLK, MSBFIRST, 16, color);
}
  
void HX8357_plot(short x, short y, short color)
{
  if ((x < 0) || (y < 0) || (x >= _width) || (y >= _height))
    return;
  
  HX8357_window(x, y, 1, 1);
  HX8357_writePixel(color);
}

void HX8357_fillRectangle(short x, short y, short width, short height, short color)
{
  int x2, y2;
  
  if ((x >= _width) || (y >= _height))
    return;
  x2 = x + width - 1;
  y2 = y + height - 1;
  if ((x2 < 0) || (y2 < 0))
    return;
  
  // Clip left/top
  if (x < 0)
  {
    x = 0;
    width = x2 + 1;
  }
  if (y < 0)
  {
    y = 0;
    height = y2 + 1;
  }
  
  // clip right/bottom
  if (x2 >= _width)
    width = _width - x;
  if (y2 >= _height)
    height = _height - y;
  
  x2 = width * height;
  HX8357_window(x, y, width, height);
  HX8357_writeColor(color, x2);
}

void HX8357_drawPixel(short x, short y, short color)
{
  low(_CS);
  HX8357_plot(x, y, color);
  high(_CS);
}

void HX8357_cls(short color)
{
  low(_CS);
  HX8357_fillRectangle(0, 0, _width, _height, color);
  high(_CS);
}

void HX8357_displayOn(char m)
{
  low(_CS);
  if (m == 0)
    writeCmd(HX8357_DISPOFF);
  else
    writeCmd(HX8357_DISPON);
  high(_CS);
}

void HX8357_sleepOn(char sleep)
{
  low(_CS);
  if (sleep == 0)
    writeCmd(HX8357_SLPOUT);
  else
    writeCmd(HX8357_SLPIN);
  high(_CS);
}
  
void HX8357_inverse(char inverse)
{
  low(_CS);
  if (inverse == 0)
    writeCmd(HX8357_INVOFF);
  else
    writeCmd(HX8357_INVON);
  high(_CS);
}

void HX8357_allPixels(char set)
{
  low(_CS);
  if (set == 0)
    writeCmd(HX8357_ALLPXOFF);
  else
    writeCmd(HX8357_ALLPXON);
  high(_CS);
}

void HX8357_displayMode(char mode)
{
  low(_CS);
  if (mode == 0)
    writeCmd(HX8357B_NORON);
  else
    writeCmd(HX8357B_PTLON);
  high(_CS);
}

void HX8357_setCursor(short x, short y)
{
  _cursorX = x;
  _cursorY = y;
}

void HX8357_textColor(short fgcolor, short bgcolor)
{
  _fgc = fgcolor;
  _bgc = bgcolor;
}

void HX8357_writeSStr(short x, short y, char *text)
{
  int i, v;
  int x1;
  
  x1 = x;
  i = 0;
  while ((i < _width) && (text[i] > 0))
  {
    v = text[i++];
    HX8357_writeSChar(x, y, v);
    x = x + 8;
  }    
}

void HX8357_writeSChar(short x, short y, char c)
{
  char t;
  long v;

  if ((x < 0) || (y < 0) || (x >= _width) || (y >= _height))
    return;
    
  low(_CS);
  HX8357_window(x, y, 8, 8);
  
  t = c * 2;
  for (int l=0;l<2;l++)
  {
    v = Font_57[t++];
    for (int i=0;i<4;i++)
    {
      for (int j=0;j<8;j++)
      {
        if ((v & 0x01) == 1)
          spi_out(16, _fgc);
        else
          spi_out(16, _bgc);
        v = v >> 1;
      }
      y++;
    }
  }
  high(_CS);
}

void HX8357_writeChar(short x, short y, char c)
{
  long *base;
  int offset;
  long v;

  if ((x < 0) || (y < 0) || (x >= _width) || (y >= _height))
    return;
  
  low(_CS);
  HX8357_window(x, y, 16, 32);
  
  offset = c & 0xfe; // Two characters per location
  base = (long*)(0x8000 + (offset << 6)); // jump to character position

  offset = 0;
  for (int i=0;i<32;i++)
  {
    v = base[offset++];
    if (c & 0x01)
      v = v >> 1;
  
    for (int j=0;j<16;j++)
    {
      if ((v & 0x01) == 1)
        spi_out(16, _fgc);
      else
        spi_out(16, _bgc);
      v = v >> 2;
    }
  }
  high(_CS);
}

void HX8357_writeStr(short x, short y, char* s)
{
  int i, v;
  char x1;
  
  x1 = x;
  i = 0;
  while ((i < _width) && (s[i] > 0))
  {
    v = s[i++];
    HX8357_writeChar(x, y, v);
    x = x + 16;
  }
}

void HX8357_writeXChar(short x, short y, char c)
{
  long *base;
  int offset;
  long v;

  if ((x < 0) || (y < 0) || (x >= _width) || (y >= _height))
    return;
  
  low(_CS);
  HX8357_window(x, y, 32, 64);
  
  offset = c & 0xfe; // Two characters per location
  base = (long*)(0x8000 + (offset << 6)); // jump to character position

  offset = 0;
  for (int i=0;i<64;i++)
  {
    if ((i & 0x01) == 1)
      v = base[offset++];
    else
      v = base[offset];
    if (c & 0x01)
      v = v >> 1;
  
    for (int j=0;j<16;j++)
    {
      if ((v & 0x01) == 1)
        spi_out(16, _fgc);
      else
        spi_out(16, _bgc);
      if ((v & 0x01) == 1)
        spi_out(16, _fgc);
      else
        spi_out(16, _bgc);
      v = v >> 2;
    }
  }
  high(_CS);
}

void HX8357_writeXStr(short x, short y, char* s)
{
  int i, v;
  char x1;
  
  x1 = x;
  i = 0;
  while ((i < _width) && (s[i] > 0))
  {
    v = s[i++];
    HX8357_writeXChar(x, y, v);
    x = x + 32;
  }
}

void HX8357_drawLine(short x0, short y0, short x1, short y1, short c)
{
  short dx, dy, D, x, y, z;
  
  dx = x1 - x0;
  if (dx < 0)
  {
    x = x0;x0 = x1;x1 = x;
    y = y0;y0 = y1;y1 = y;
  }
  dx = abs(dx);
  dy = y1 - y0;
  if (dy < 0)
    z = -1;
  else
    z = 1;
  dy = abs(dy);
  if (dx < dy)
  {
    drawLine(x0, y0, x1, y1, c);
    return;
  }
  D = 2 * dy - dx;
  y = y0;
  
  for (x = x0;x <= x1;x++)
  {
    HX8357_drawPixel(x, y, c);
    if (D > 0)
    {
      y = y + z;
      D = D - 2 * dx;
    }
    D = D + 2 * dy;
  }          
}

void drawLine(short x0, short y0, short x1, short y1, short c)
{
  short dx, dy, D, x, y, z;
  
  dy = y1 - y0;
  if (dy < 0)
  {
    y = y0;y0 = y1;y1 = y;
    x = x0;x0 = x1;x1 = x;
  }
  dy = abs(dy);
  dx = x1 - x0;
  if (dx < 0)
    z = -1;
  else
    z = 1;
  dx = abs(dx);
  D = 2 * dx - dy;
  x = x0;
  
  for (y = y0;y <= y1;y++)
  {
    HX8357_drawPixel(x, y, c);
    if (D > 0)
    {
      x = x + z;
      D = D - 2 * dy;
    }
    D = D + 2 * dx;
  }
}

void HX8357_drawBox(short x0, short y0, short x1, short y1, short c)
{
  HX8357_drawLine(x0, y0, x1, y0, c);
  HX8357_drawLine(x0, y0, x0, y1, c);
  HX8357_drawLine(x1, y0, x1, y1, c);
  HX8357_drawLine(x0, y1, x1, y1, c);
}

unsigned short HX8357_color(char red, char green, char blue)
{
  unsigned short c;
  
  c = red & 0x1f;
  c = c << 6 | (green & 0x2f);
  c = c << 5 | (blue & 0x1f); 
  return c;
}


// low level functions
void writeCmd(int cmd)
{
  low(_DC);
  spi_out(8, cmd); //shift_out(_MOSI, _CLK, MSBFIRST, 8, cmd);
  high(_DC);
}

int readCmd(int cmd)
{
  int r;
  
  low(_DC);
  low(_CS);
  spi_out(8, cmd); //shift_out(_MOSI, _CLK, MSBFIRST, 8, cmd);
  
  high(_DC);
  
  r = shift_in(_MISO, _CLK, MSBPRE, 8);

  high(_CS);
  
  return r;
}

void __attribute__((fcache))spi_out(int bits, int value)
{
  unsigned long b;
  int i;
  
  b = 1 << (bits - 1);
  
  for(i = 0; i < bits; i++)
  {
    if ((value & b) != 0)
      OUTA |= _DMask;
    else
      OUTA &= _Dmask;
    OUTA &= _Cmask;
    OUTA |= _CMask;
    OUTA &= _Cmask;
    b = b >> 1;
  }
}
