/**
 * @file newhaven.c
 * @brief Interface New Haven Display
 * @author Michael Burmeister
 * @date July 30, 2018
 * @version 1.2
 * 
*/

/**
 * @brief uncomment the follow line to turn on instruction decode
 */
//#define _NEWHAVENDEBUG

#include "simpletools.h"
#include "newhaven.h"

void _StringCmd(char *);
#ifdef _NEWHAVENDEBUG
void Instruction(int);
void Decode(void);
void begin(int);
#endif

int _cs;
int _mosi;
int _miso;
int _sclk;
int _power;
unsigned int _Dl;


unsigned char openNewHaven(char Cs, char Mosi, char Miso, char Sclk, char Pwr)
{
  unsigned char i;
  
  _cs = Cs;
  _mosi = Mosi;
  _miso = Miso;
  _sclk = Sclk;
  _power = Pwr;
  _Dl = 0;
  
  high(_cs);
  low(_power);
  pause(300);
  high(_power);
  pause(300);
  HostCommand(ACTIVE);
  HostCommand(ACTIVE);
  pause(200);
  return readID();
}

void setDisplay(int h, int v)
{
  _write16(REG_HCYCLE, 928);
  _write16(REG_HOFFSET, 88);
  _write16(REG_HSYNC0, 0);
  _write16(REG_HSYNC1, 48);
  _write16(REG_VCYCLE, 525);
  _write16(REG_VOFFSET, 32);
  _write16(REG_VSYNC0, 0);
  _write16(REG_VSYNC1, 3);
  _write8(REG_SWIZZLE, 0);
  _write8(REG_PCLK_POL, 0);
  _write8(REG_CSPREAD, 1);
  _write8(REG_DITHER, 1);
  _write16(REG_HSIZE, h);
  _write16(REG_VSIZE, v);
  _write8(REG_PCLK, 2);
  // set DISP pin to on
  GPIODir(15, 1);
  setGPIO(15, 1);
}

void GPIODir(unsigned char g, unsigned char d)
{
  int i, j;
  
  j = 1 << g;
  
  i = _read32(REG_GPIOX_DIR);
  i = i & ~j;
  i = i | j;
  _write32(REG_GPIOX_DIR, i);
  
}

void setGPIO(unsigned char g, unsigned char s)
{
  int i, j;
  
  j = 1 << g;
  
  i = _read32(REG_GPIOX);
  i = i & ~j;
  if (s != 0)
    i = i | j;

  _write32(REG_GPIOX, i);
}

unsigned char getGPIO(unsigned char g)
{
  int i, j;
  
  j = 1 << g;
  i = _read32(REG_GPIOX);
  i = i & j;
  if (i == 0)
    return 0;
  else
    return 1;
}
    
void setBrightness(unsigned char b)
{
  _write8(REG_PWM_DUTY, b);
}

unsigned char readID()
{
  int d = REG_ID;
  d = _read8(d);
  return d;
}

int cmdFree()
{
  int i;
  
  i = _read32(REG_CMDB_SPACE);
  return i;  
}

void DoList()
{
  _write32(REG_DLSWAP, 2);
}
  
void setRotation(unsigned char r)
{
  int i = r;
  cmd(CMD_SETROTATE);
  _write32(REG_CMDB_WRITE, i);
}
  
int cmd(unsigned int i)
{
  _write32(REG_CMDB_WRITE, i);
  if (_read32(REG_CMD_READ) == 4095)
    return -1;
  else
    return 0;
}

unsigned int CLEAR(char c, char s, char t)
{
  unsigned int V = _CLEAR << 24;
  V = V | c << 2 | s << 1 | t;
  return V;
}

unsigned int CLEAR_COLOR_RGB(unsigned char r, unsigned char g, unsigned char b)
{
  unsigned int V = _CLEAR_COLOR_RGB << 24;
  V = V | r << 16 | g << 8 | b;
  return V;
}

unsigned int DISPLAY()
{
  unsigned int V = _DISPLAY << 24;
  return V;
}

unsigned int BEGIN(unsigned char p)
{
  unsigned int V = _BEGIN << 24;
  V = V | p;
  return V;
}

unsigned int COLOR_RGB(unsigned char r, unsigned char g, unsigned char b)
{
  unsigned int V = _COLOR_RGB << 24;
  V = V | r << 16 | g << 8 | b;
  return V;
}

unsigned int POINT_SIZE(short p)
{
  unsigned int V = _POINT_SIZE << 24;
  V = V | p;
  return V;
}

unsigned int VERTEX2II(short x, short y, unsigned char h, unsigned char c)
{
  unsigned int V = _VERTEX2II << 24;
  V = V | x << 21 | y << 12 | h << 7 | c;
  return V;
}

unsigned int VERTEX_TRANSLATE_X(short x)
{
  unsigned int V = _VERTEX_TRANSLATE_X << 24;
  V = V | x;
  return V;
}

unsigned int VERTEX_TRANSLATE_Y(short y)
{
  unsigned int V = _VERTEX_TRANSLATE_Y << 24;
  V = V | y;
  return V;
}

unsigned int END(void)
{
  unsigned int V = _END << 24;
  return V;
}  

unsigned int VERTEX2F(short x, short y)
{
  unsigned int V = _VERTEX2F << 24;
  V = V | x << 15 | y;
  return V;
}

unsigned int LINE_WIDTH(short w)
{
  unsigned int V = _LINE_WIDTH << 24;
  V = V | w;
  return V;
}

unsigned int PALETTE_SOURCE(int s)
{
  unsigned int V = _PALETTE_SOURCE << 24;
  V = V | s;
  return V;
}

unsigned int RESTORE_CONTEXT()
{
  unsigned int V = _RESTORE_CONTEXT << 24;
  return V;
}

unsigned int RETURN()
{
  unsigned int V = _RETURN << 24;
  return V;
}

unsigned int SAVE_CONTEXT(void)
{
  unsigned int V = _SAVE_CONTEXT << 24;
  return V;
}

unsigned int SCISSOR_SIZE(int w, int h)
{
  unsigned int V = _SCISSOR_SIZE << 24;
  V = V | w << 12 | h;
  return V;
}

unsigned int SCISSOR_XY(int x, int y)
{
  unsigned int V = _SCISSOR_XY << 24;
  V = V | x << 11 | y;
  return V;
}

unsigned int ALPHA_FUNC(short f, short r)
{
  unsigned int V = _ALPHA_FUNC << 24;
  V = V | f << 8;
  V = V | r;
  return V;
}

unsigned int BITMAP_HANDLE(short h)
{
  unsigned int V = _BITMAP_HANDLE << 24;
  V = V | h;
  return V;
}

unsigned int BITMAP_LAYOUT(short f, short l, short h)
{
  unsigned int V = _BITMAP_LAYOUT << 24;
  V = V | f << 19;
  V = V | l << 9;
  V = V | h;
  return V;
}

unsigned int BITMAP_LAYOUT_H(unsigned char l, unsigned char h)
{
  unsigned int V = _BITMAP_LAYOUT_H << 24;
  V = V | l << 2;
  V = V | h;
  return V;
}

unsigned int BITMAP_SIZE(unsigned char f, unsigned char x, unsigned char y, short w, short h)
{
  unsigned int V = _BITMAP_SIZE << 24;
  V = V | f << 20;
  V = V | x << 19;
  V = V | y << 18;
  V = V | w << 9;
  V = V | h;
  return V;
}

unsigned int BITMAP_SIZE_H(unsigned char w, unsigned char h)
{
  unsigned int V = _BITMAP_SIZE_H << 24;
  V = V | w << 2;
  V = V | h;
  return V;
}

unsigned int BITMAP_SOURCE(int a)
{
  unsigned int V = _BITMAP_SOURCE << 24;
  V = V | a;
  return V;
}

unsigned int BITMAP_TRANSFORM_A(unsigned short c)
{
  unsigned int V = _BITMAP_TRANSFORM_A << 24;
  V = V | c;
  return V;
}

unsigned int BITMAP_TRANSFORM_B(unsigned short c)
{
  unsigned int V = _BITMAP_TRANSFORM_B << 24;
  V = V | c;
  return V;
}

unsigned int BITMAP_TRANSFORM_C(unsigned int c)
{
  unsigned int V = _BITMAP_TRANSFORM_C << 24;
  V = V | c;
  return V;
}

unsigned int BITMAP_TRANSFORM_D(unsigned short c)
{
  unsigned int V = _BITMAP_TRANSFORM_D << 24;
  V = V | c;
  return V;
}

unsigned int BITMAP_TRANSFORM_E(unsigned short c)
{
  unsigned int V = _BITMAP_TRANSFORM_E << 24;
  V = V | c;
  return V;
}

unsigned int BITMAP_TRANSFORM_F(unsigned int c)
{
  unsigned int V = _BITMAP_TRANSFORM_F << 24;
  V = V | c;
  return V;
}

unsigned int BLEND_FUNC(unsigned char s, unsigned char d)
{
  unsigned int V = _BLEND_FUNC << 24;
  V = V | s << 3;
  V = V | d;
  return V;
}

unsigned int CALL(unsigned short a)
{
  unsigned int V = _CALL << 24;
  V = V | a;
  return V;
}

unsigned int CELL(unsigned char c)
{
  unsigned int V = _CELL << 24;
  V = V | c;
  return V;
}

unsigned int CLEAR_COLOR_A(unsigned char a)
{
  unsigned int V = _CLEAR_COLOR_A << 24;
  V = V | a;
  return V;
}

unsigned int CLEAR_STENCIL(unsigned char s)
{
  unsigned int V = _CLEAR_STENCIL << 24;
  V = V | s;
  return V;
}

unsigned int CLEAR_TAG(unsigned char t)
{
  unsigned int V = _CLEAR_TAG << 24;
  V = V | t;
  return V;
}

unsigned int COLOR_A(unsigned char c)
{
  unsigned int V = _COLOR_A << 24;
  V = V | c;
  return V;
}

unsigned int COLOR_MASK(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
  unsigned int V = _COLOR_MASK << 24;
  V = V | r << 3;
  V = V | g << 2;
  V = V | b << 1;
  V = V | a;
  return V;
}

unsigned int JUMP(unsigned short a)
{
  unsigned int V = _JUMP << 24;
  V = V | a;
  return V;
}

unsigned int MACRO(unsigned char r)
{
  unsigned int V = _MACRO << 24;
  V = V | r;
  return V;
}

unsigned int NOP(void)
{
  unsigned int V = _NOP << 24;
  return V;
}

unsigned int STENCIL_FUNC(unsigned char f, unsigned char r, unsigned char m)
{
  unsigned int V = _STENCIL_FUNC << 24;
  V = V | f << 16;
  V = V | r << 8;
  V = V | m;
  return V;
}

unsigned int STENCIL_MASK(unsigned char m)
{
  unsigned int V = _STENCIL_MASK << 24;
  V = V | m;
  return V;
}

unsigned int STENCIL_OP(unsigned char f, unsigned char p)
{
  unsigned int V = _STENCIL_OP << 24;
  V = V | f << 3;
  V = V | p;
  return V;
}

unsigned int TAG_MASK(unsigned char m)
{
  unsigned int V = _TAG_MASK << 24;
  V = V | m;
  return V;
}

unsigned int VERTEX_FORMAT(unsigned char f)
{
  unsigned int V = _VERTEX_FORMAT << 24;
  V = V | f;
  return V;
}

void MACRO_0(unsigned int i)
{
  _write32(REG_MACRO_0, i);
}

void MACRO_1(unsigned int i)
{
  _write32(REG_MACRO_1, i);
}

void CMD_BUTTON(short x, short y, short w, short h, short f, short o, char *s)
{
  int i;
  char v[4];
  
  cmd(_CMD_BUTTON);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = h << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = o << 16 | f;
  _write32(REG_CMDB_WRITE, i);
  _StringCmd(s);
}

void CMD_TEXT(short x, short y, short f, short o, char *s)
{
  int i;
  char v[4];
  
  cmd(_CMD_TEXT);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = o << 16 | f;
  _write32(REG_CMDB_WRITE, i);
  _StringCmd(s);
}

void CMD_CLOCK(short x, short y, short r, short o, short h, short m, short s, short ms)
{
  int i;
  
  cmd(_CMD_CLOCK);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = o << 16 | r;
  _write32(REG_CMDB_WRITE, i);
  i = m << 16 | h;
  _write32(REG_CMDB_WRITE, i);
  i = ms << 16 | s;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_BGCOLOR(int c)
{
  cmd(_CMD_BGCOLOR);
  _write32(REG_CMDB_WRITE, c);
}

void CMD_FGCOLOR(int c)
{
  cmd(_CMD_FGCOLOR);
  _write32(REG_CMDB_WRITE, c);
}

void CMD_ROMFONT(unsigned char f, unsigned char s)
{
  cmd(_CMD_ROMFONT);
  _write32(REG_CMDB_WRITE, f);
  _write32(REG_CMDB_WRITE, s);
}
  
void CMD_GAUGE(short x, short y, short r, short o, short mj, short mn, short v, short rg)
{
  int i;
  
  cmd(_CMD_GAUGE);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = o << 16 | r;
  _write32(REG_CMDB_WRITE, i);
  i = mn << 16 | mj;
  _write32(REG_CMDB_WRITE, i);
  i = rg << 16 | v;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_GRADCOLOR(short c)
{
  cmd(_CMD_GRADCOLOR);
  _write32(REG_CMDB_WRITE, c);
}

void Wait()
{
  int i = 0;
  while (_read32(REG_CMD_READ) != _read32(REG_CMD_WRITE))
  {
    if (i++ > 100)
    {
      i = _read32(REG_CMD_WRITE) - _read32(REG_CMD_READ);
      i = i % 4096;
      putDec(i);
      putChar(' ');
      i = 0;
      return;
    }
    pause(100);
  }    
}
  
void CMD_PROGRESS(short x, short y, short w, short h, short o, short v, short r)
{
  int i;
  
  cmd(_CMD_PROGRESS);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = h << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = v << 16 | o;
  _write32(REG_CMDB_WRITE, i);
  i = r;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_SCROLLBAR(short x, short y, short w, short h, short o, short v, short s, short r)
{
  int i;
  
  cmd(_CMD_SCROLLBAR);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = h << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = v << 16 | o;
  _write32(REG_CMDB_WRITE, i);
  i = r << 16 | s;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_SLIDER(short x, short y, short w, short h, short o, short v, short r)
{
  int i;
  
  cmd(_CMD_SLIDER);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = h << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = v << 16 | o;
  _write32(REG_CMDB_WRITE, i);
  i = r;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_DIAL(short x, short y, short r, short o, short v)
{
  int i;
  
  cmd(_CMD_DIAL);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = o << 16 | r;
  _write32(REG_CMDB_WRITE, i);
  i = v;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_TOGGLE(short x, short y, short w, short f, short o, short s, char *c)
{
  int i;
  
  cmd(_CMD_TOGGLE);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = f << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = s << 16 | o;
  _write32(REG_CMDB_WRITE, i);
  _StringCmd(c);
}

void CMD_SETBASE(int b)
{
  cmd(_CMD_SETBASE);
  _write32(REG_CMDB_WRITE, b);
}

void CMD_NUMBER(short x, short y, short f, short o, int v)
{
  int i;
  
  cmd(_CMD_NUMBER);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = o << 16 | f;
  _write32(REG_CMDB_WRITE, i);
  i = v;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_KEYS(short x, short y, short w, short h, short f, short o, char *k)
{
  int i;
  
  cmd(_CMD_KEYS);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = h << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = o << 16 | f;
  _write32(REG_CMDB_WRITE, i);
  _StringCmd(k);
}

void CMD_SPINNER(short x, short y, short st, short sc)
{
  int i;
  
  cmd(_CMD_SPINNER);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = sc << 16 | st;
  _write32(REG_CMDB_WRITE, i);
}

void CMD_SKETCH(short x, short y, short w, short h, int p, short f)
{
  int i;
  
  cmd(_CMD_SKETCH);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = h << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = p;
  _write32(REG_CMDB_WRITE, i);
  i = f;
  _write32(REG_CMDB_WRITE, i);
}

int TouchScreen()
{
  int i;
  
  i = _read32(REG_TOUCH_SCREEN_XY);
  return i;
}

unsigned char TouchTag()
{
  int i;
  
  i = _read32(REG_TOUCH_TAG);
  return i;
}

unsigned int TAG(unsigned char t)
{
  int V = _TAG << 24;
  V = V | t;
  return V;
}

unsigned int Tracker()
{
  int i;
  
  i = _read32(REG_TRACKER);
  return i;
}

void CMD_TRACK(short x, short y, short w, short h, short t)
{
  int i;

  cmd(_CMD_TRACK);
  i = y << 16 | x;
  _write32(REG_CMDB_WRITE, i);
  i = h << 16 | w;
  _write32(REG_CMDB_WRITE, i);
  i = t;
  _write32(REG_CMDB_WRITE, i);
}
  
void DumpCmd()
{
  unsigned char v;
  int i = 0;
  int j = _read32(REG_CMD_WRITE);
  
  putStr("Dump -> ");
  while (i < j)
  {
    v = readMemory(RAM_CMD + i++);
    putHexLen(v, 2);
    if (i % 8 == 0)
      putStr("\n        ");
    else
      putChar(' ');
  }
  putChar('\n');
}

void DumpDL()
{
  unsigned int v;
  int i = 0;
  int n = 0;
  int true = -1;
  putStr("\nDumpDL\n");
  while (true)
  {
    v = readMemory(RAM_DL + i++);
    v |= readMemory(RAM_DL + i++) << 8;
    v |= readMemory(RAM_DL + i++) << 16;
    v |= readMemory(RAM_DL + i++) << 24;
    putDecLen(n, 4);
    putStr(" 0x");
    putHexLen(v,8);
#ifdef _NEWHAVENDEBUG
    Instruction(v);
#endif
    putStr("\n");
    if (n++ > 2047)
      true = 0;
    if (v == 0)
      true = 0;
  }
  putStr("\n");
}
  
void _StringCmd(char *s)
{
  int i;
  char v[4];
  
  i = 0;
  while (*s != 0)
  {
    v[i++] = *s;
    s++;
    if (i > 3)
    {
      i = v[3] << 24 | v[2] << 16 | v[1] << 8 | v[0];
      _write32(REG_CMDB_WRITE, i);
      i = 0;
      memset(v , 0, sizeof(v));
    }
  }
  i = v[3] << 24 | v[2] << 16 | v[1] << 8 | v[0];
  _write32(REG_CMDB_WRITE, i);
}

void HostCommand(unsigned char h)
{
  int i = 0;
  
  low(_cs);
  i = h << 16;
  shift_out(_mosi, _sclk, MSBFIRST, 24, i);
  high(_cs);
}
  

/**
 *@brief Read Write SPI basic functions
 */
void _write8(int address, unsigned char data)
{
  address = RAM_REG + 0x800000 + address;

  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 24, address);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data);
  high(_cs);
}

unsigned char _read8(unsigned int address)
{
  address = RAM_REG + address;
  address = address << 8;
  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 32, address);
  int d = shift_in(_miso, _sclk, MSBPRE, 8);
  high(_cs);
  return d;
}

unsigned char readMemory(unsigned int address)
{
  address = address << 8;

  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 32, address);
  int d = shift_in(_miso, _sclk, MSBPRE, 8);
  high(_cs);
  return d;
}

unsigned int readMemory32(unsigned int address)
{
  address = address << 8;

  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 32, address);
  unsigned int d = shift_in(_miso, _sclk, MSBPRE, 8);
  d = d << 8 | shift_in(_miso, _sclk, MSBPRE, 8);
  d = d << 8 | shift_in(_miso, _sclk, MSBPRE, 8);
  d = d << 8 | shift_in(_miso, _sclk, MSBPRE, 8);
  high(_cs);
  return d;
}
  
void writeMemory(unsigned int address, unsigned char data)
{
  address = 0x800000 + address;

  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 24, address);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data);
  high(_cs);
}

void writeMemory32(unsigned int address, unsigned int data)
{
  address = 0x800000 + address;

  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 24, address);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data >> 24);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data >> 16);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data >> 8);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data);
  high(_cs);
}
  
void _write16(int address, int data)
{
  address = RAM_REG + 0x800000 + address;

  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 24, address);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data >> 8);
  high(_cs);
}

short _read16(unsigned int address)
{
  address = RAM_REG + address;
  address = address << 8;
  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 32, address);
  int d = shift_in(_miso, _sclk, MSBPRE, 8);
  d = d | (shift_in(_miso, _sclk, MSBPRE, 8) << 8);
  high(_cs);
  return d;
}
  
void _write32(int address, int data)
{
  address = RAM_REG + 0x800000 + address;

  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 24, address);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data >> 8);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data >> 16);
  shift_out(_mosi, _sclk, MSBFIRST, 8, data >> 24);
  high(_cs);
}

int _read32(unsigned int address)
{
  address = RAM_REG + address;
  address = address << 8;
  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 32, address);
  int d = shift_in(_miso, _sclk, MSBPRE, 8);
  d = d | (shift_in(_miso, _sclk, MSBPRE, 8) << 8);
  d = d | (shift_in(_miso, _sclk, MSBPRE, 8) << 16);
  d = d | (shift_in(_miso, _sclk, MSBPRE, 8) << 24);
  high(_cs);
  return d;
}

short dl(unsigned int instr)
{
  unsigned int address = RAM_DL + 0x800000 + _Dl;
  
  low(_cs);
  shift_out(_mosi, _sclk, MSBFIRST, 24, address);
  shift_out(_mosi, _sclk, MSBFIRST, 8, instr);
  shift_out(_mosi, _sclk, MSBFIRST, 8, instr >> 8);
  shift_out(_mosi, _sclk, MSBFIRST, 8, instr >> 16);
  shift_out(_mosi, _sclk, MSBFIRST, 8, instr >> 24);
  high(_cs);
  _Dl += 4;
  return _Dl;
}

void ClearDL()
{
  _Dl = 0;
}


/**
 * @brief decode display instructions
 * @param instruction
 */
#ifdef _NEWHAVENDEBUG
void Instruction(int I)
{
  int i;

  i = I >> 24;

  printi("  ");

  if ((i & 0x40) == 0x40)
  {
    printi("VERTEX2F(%d, %d)", I >> 15 & 0x7fff, I & 0x7fff);
    return;
  }
  if ((i & 0x80) == 0x80)
  {
    printi("VERTEX2II(%d, %d, %d, %d)", I >> 21 & 0x1ff, I >> 12 & 0x1ff, I >> 7 & 0x1f, I & 0x7f);
    return;
  }
          
  switch (i)
  {
    case 0x09: printi("ALPHA_FUNC(%d, %d)", I >> 8 & 0x07, I & 0xff);
              break;
    case 0x1f: begin(I);
              break;
    case 0x05: printi("BITMAP_HANDLE(%d)", I & 0x1f);
              break;
    case 0x07: printi("BITMAP_LAYOUT(%d, %d, %d)", I >> 19 & 0x1f, I >> 9 & 0x3ff, I & 0x1ff);
              break;
    case 0x28: printi("BITMAP_LAYOUT_H(%d, %d)", I >> 2 & 0x03, I & 0x03);
              break;
    case 0x08: printi("BITMAP_SIZE(%d, %d, %d, %d, %d", I >> 19 & 0x01, I >> 18 & 0x01, I >> 17 & 0x01, I >> 9 & 0x1ff, I & 0x1ff);
              break;
    case 0x29: printi("BITMAP_SIZE_H(%d, %d)", I >> 2 & 0x03, I & 0x03);
              break;
    case 0x01: printi("BITMAP_SOURCE(%d)", I & 0x3fffff);
              break;
    case 0x15: printi("BITMAP_TRANSFORM_A(%d)", I & 0xffff);
              break;
    case 0x16: printi("BITMAP_TRANSFORM_B(%d)", I & 0xffff);
              break;
    case 0x17: printi("BITMAP_TRANSFORM_C(%d)", I & 0xffffff);
              break;
    case 0x18: printi("BITMAP_TRANSFORM_D(%d)", I & 0xffff);
              break;
    case 0x19: printi("BITMAP_TRANSFORM_E(%d)", I & 0xffff);
              break;
    case 0x1a: printi("BITMAP_TRANSFORM_F(%d)", I & 0xffffff);
              break;
    case 0x0b: printi("BLEND_FUNC(%d, %d)", I >> 3 & 0x07, I & 0x07);
              break;
    case 0x1d: printi("CALL(%d)", I & 0xffff);
               break;
    case 0x06: printi("CELL(%d)", I & 0x7f);
              break;
    case 0x26: printi("CLEAR(%d,%d,%d)", I >> 2 & 0x01, I >> 1 & 0x01, I & 0x01);
              break;
    case 0x0f: printi("CLEAR_COLOR_A(%d)", I & 0x0f);
              break;
    case 0x02: printi("CLEAR_COLOR_RGB(%d, %d, %d)", I >> 16 & 0xff, I >> 8 & 0xff, I & 0xff);
              break;
    case 0x11: printi("CLEAR_STENCIL(%d)", I & 0xff);
              break;
    case 0x12: printi("CLEAR_TAG(%d)", I & 0xff);
              break;
    case 0x10: printi("COLOR_A(%d)", I & 0xff);
              break;
    case 0x20: printi("COLOR_MASK(%d, %d, %d, %d)", I >> 3 & 0x01, I >> 2 & 0x01, I >> 1 & 0x01, I & 0x01);
              break;
    case 0x04: printi("COLOR_RGB(%d, %d, %d)", I >> 16 & 0xff, I >> 8 & 0xff, I & 0xff);
              break;
    case 0x00: printi("DISPLAY()");
              break;
    case 0x21: printi("END()");
              break;
    case 0x1e: printi("JUMP(%d)", I & 0xff);
              break;
    case 0x0e: printi("LINE_WIDTH(%d)", I & 0x3f);
              break;
    case 0x25: printi("MACRO(%d)", I & 0x01);
              break;
    case 0x2d: printi("NOP()");
              break;
    case 0x2a: printi("PALETTE_SOURCE(%d)", I & 0x1fff);
              break;
    case 0x0d: printi("POINT_SIZE(%d)", I & 0xfff);
              break;
    case 0x23: printi("RESTORE_CONTEXT()");
              break;
    case 0x24: printi("RETURN()");
              break;
    case 0x22: printi("SAVE_CONTEXT()");
              break;
    case 0x1c: printi("SCISSOR_SIZE(%d, %d)", I >> 12 & 0xfff, I & 0xfff);
              break;
    case 0x1b: printi("SCISSOR_XY(%d, %d)", I >> 11 & 0x3ff, I & 0x3ff);
              break;
    case 0x0a: printi("STENCIL_FUNC()");
              break;
    case 0x13: printi("STENCIL_MASK()");
              break;
    case 0x0c: printi("STENCIL_OP()");
              break;
    case 0x03: printi("TAG(%d)", I & 0xff);
              break;
    case 0x14: printi("TAG_MASK(%d)", I & 0x01);
              break;
    case 0x27: printi("VERTEX_FORMAT(%d)", I & 0x07);
              break;
    case 0x2b: printi("VERTEX_TRANSLATE_X(%d)", I & 0xffff);
              break;
    case 0x2c: printi("VERTEX_TRANSLATE_Y(%d)", I & 0xffff);
              break;
  }
  
}

void begin(int i)
{
  i = i & 0xf;
  putStr("BEGIN(");
  if (i == 1) putStr("BITMAPS");
  if (i == 2) putStr("POINTS");
  if (i == 3) putStr("LINES");
  if (i == 4) putStr("LINE_STRIP");
  if (i == 5) putStr("EDGE_STRIP_R");
  if (i == 6) putStr("EDGE_STRIP_L");
  if (i == 7) putStr("EDGE_STRIP_A");
  if (i == 8) putStr("EDGE_STRIP_B");
  if (i == 9) putStr("RECTS");
  putStr(")");
}

#endif
