/**
 * @file newhavenreg.h
 * @brief Register definitions for Newhaven Display
 * @author Michael Burmeister
 * @date July 30, 2018
 * @version 1.2
 * 
*/

#define RAM_G 0x000000
#define ROM_FONT 0x1e0000
#define ROM_FONT_ADDR 0x2ffffc
#define RAM_DL 0x300000
#define RAM_REG 0x302000
#define RAM_CMD 0x308000
#define CHIP_ID 0x0c0000

#define REG_PCLK 0x70
#define REG_PCLK_POL 0x6c
#define REG_CSPREAD 0x68
#define REG_SWIZZLE 0x64
#define REG_DITHER 0x60
#define REG_OUTBITS 0x5c
#define REG_ROTATE 0x58
#define REG_VSYNC1 0x50
#define REG_VSYNC0 0x4c
#define REG_VSIZE 0x48
#define REG_VOFFSET 0x44
#define REG_VCYCLE 0x40
#define REG_HSYNC1 0x3c
#define REG_HSYNC0 0x38
#define REG_HSIZE 0x34
#define REG_HOFFSET 0x30
#define REG_HCYCLE 0x2c
#define REG_DLSWAP 0x54
#define REG_TAG 0x7c
#define REG_TAG_Y 0x78
#define REG_TAG_X 0x74
#define REG_PLAY 0x8c
#define REG_SOUND 0x88
#define REG_VOL_SOUND 0x84
#define REG_VOL_PB 0x80
#define REG_PLAYBCK_PLAY 0xcc
#define REG_PLAYBACK_LOOP 0xc8
#define REG_PLAYBACK_FORMAT 0xc4
#define REG_PLAYBACK_FREQ 0xc0
#define REG_MACRO_0 0xd8
#define REG_MACRO_1 0xdc
#define REG_PLAYBACK_READPTR 0xbc
#define REG_PLAYBACK_LENGTH 0xb8
#define REG_PLAYBACK_START 0xb4
#define REG_TOUCH_CONFIG 0x168
#define REG_TOUCH_TRANSFORM_F 0x164
#define REG_TOUCH_TRANSFORM_E 0x160
#define REG_TOUCH_TRANSFORM_D 0x15c
#define REG_TOUCH_TRANSFORM_C 0x158
#define REG_TOUCH_TRANSFORM_B 0x154
#define REG_TOUCH_TRANSFORM_A 0x150

#define REG_TOUCH_MODE 0x104
#define REG_TOUCH_ADC_MODE 0x108
#define REG_TOUCH_CHARGE 0x10c
#define REG_TOUCH_SETTLE 0x110
#define REG_TOUCH_OVERSAMPLE 0x114
#define REG_TOUCH_RZTHRESH 0x118
#define REG_TOUCH_RAW_XY 0x11c
#define REG_TOUCH_RZ 0x120
#define REG_TOUCH_SCREEN_XY 0x124
#define REG_TOUCH_TAG_XY 0x128
#define REG_TOUCH_TAG 0x12c
#define REG_TOUCH_DIRECT_Z1Z2 0x190
#define REG_TOUCH_DIRECT_XY 0x18c
#define REG_CTOUCH_MODE 0x104
#define REG_CTOUCH_EXTEND 0x108
#define REG_CTOUCH_TOUCH_XY 0x124
#define REG_CTOUCH_TOUCH1_XY 0x11c
#define REG_CTOUCH_TOUCH2_XY 0x18c
#define REG_CTOUCH_TOUCH3_XY 0x190
#define REG_CTOUCH_TOUCH4_X 0x16c
#define REG_CTOUCH_TOUCH4_Y 0x120
#define REG_CTOUCH_RAW_XY 0x11c
#define REG_CTOUCH_TAG 0x12c
#define REG_CTOUCH_TAG1 0x134
#define REG_CTOUCH_TAG2 0x13c
#define REG_CTOUCH_TAG3 0x144
#define REG_CTOUCH_TAG4 0x14c
#define REG_CTOUCH_TAG_XY 0x128
#define REG_CTOUCH_TAG1_XY 0x130
#define REG_CTOUCH_TAG2_XY 0x138
#define REG_CTOUCH_TAG3_XY 0x140
#define REG_CTOUCH_TAG4_XY 0x148

#define REG_CMD_DL 0x100
#define REG_CMD_WRITE 0xfc
#define REG_CMD_READ 0xf8
#define REG_CMDB_SPACE 0x574
#define REG_CMDB_WRITE 0x578
#define REG_TRACKER 0x7000
#define REG_TRACKER_1 0x7004
#define REG_TRACKER_2 0x7008
#define REG_TRACKER_3 0x700c
#define REG_TRACKER_4 0x7010
#define REG_MEDIAFIFO_READ 0x7014
#define REG_MEDIAFIFO_WRITE 0x718

#define REG_CPURESET 0x20
#define REG_PWM_DUTY 0xd4
#define REG_PWM_HZ 0xd0
#define REG_INT_MASK 0xb0
#define REG_INT_EN 0xac
#define REG_INT_FLAGS 0xa8
#define REG_GPIO_DIR 0x90
#define REG_GPIO 0x94
#define REG_GPIOX_DIR 0x98
#define REG_GPIOX 0x9c
#define REG_FREQUENCY 0x0c
#define REG_CLOCK 0x08
#define REG_FRAMES 0x04
#define REG_ID 0x00

#define REG_TRIM 0x10256c
#define REG_SPI_WIDTH 0x180

#define _ALPHA_FUNC 0x09
#define _BEGIN 0x1f
#define _BITMAP_HANDLE 0x05
#define _BITMAP_LAYOUT 0x07
#define _BITMAP_LAYOUT_H 0x28
#define _BITMAP_SIZE 0x08
#define _BITMAP_SIZE_H 0x29
#define _BITMAP_SOURCE 0x01
#define _BITMAP_TRANSFORM_A 0x15
#define _BITMAP_TRANSFORM_B 0x16
#define _BITMAP_TRANSFORM_C 0x17
#define _BITMAP_TRANSFORM_D 0x18
#define _BITMAP_TRANSFORM_E 0x19
#define _BITMAP_TRANSFORM_F 0x1a
#define _BLEND_FUNC 0x0b
// processor function codes
#define _CALL 0x1d
#define _CELL 0x06
#define _CLEAR 0x26
#define _CLEAR_COLOR_A 0x0f
#define _CLEAR_COLOR_RGB 0x02
#define _CLEAR_STENCIL 0x11
#define _CLEAR_TAG 0x12
#define _COLOR_A 0x10
#define _COLOR_MASK 0x20
#define _COLOR_RGB 0x04
#define _DISPLAY 0x00
#define _END 0x21
#define _JUMP 0x1e
#define _LINE_WIDTH 0x0e
#define _MACRO 0x25
#define _NOP 0x2d
#define _PALETTE_SOURCE 0x2a
#define _POINT_SIZE 0x0d
#define _RESTORE_CONTEXT 0x23
#define _RETURN 0x24
#define _SAVE_CONTEXT 0x22
#define _SCISSOR_SIZE 0x1c
#define _SCISSOR_XY 0x1b
#define _STENCIL_FUNC 0x0a
#define _STENCIL_MASK 0x13
#define _STENCIL_OP 0x0c
#define _TAG 0x03
#define _TAG_MASK 0x14
#define _VERTEX2F 0x40
#define _VERTEX2II 0x80
#define _VERTEX_FORMAT 0x27
#define _VERTEX_TRANSLATE_X 0x2b
#define _VERTEX_TRANSLATE_Y 0x2c
// Command codes
#define CMD_CODE 0xffffff00
#define CMD_DLSTART 0xffffff00
#define CMD_DLSWAP 0xffffff01
#define CMD_COLDSTART 0xffffff32
#define CMD_INTERRUPT 0xffffff02
#define CMD_APPEND 0xffffff1e
#define CMD_REGREAD 0xffffff19
#define CMD_MEMWRITE 0xffffff1a
#define CMD_INFLATE 0xffffff22
#define CMD_LOADIMAGE 0xffffff24
#define CMD_MEDIAFIFO 0xffffff39
#define CMD_PLAYVIDEO 0xffffff3a
#define CMD_VIDEOSTART 0xffffff40
#define CMD_VIDEOFRAME 0xffffff41
#define CMD_MEMCRC 0xffffff18
#define CMD_MEMZERO 0xffffff1c
#define CMD_MEMSET 0xffffff1b
#define CMD_MEMCPY 0xffffff1d
#define _CMD_BUTTON 0xffffff0d
#define _CMD_CLOCK 0xffffff14
#define _CMD_FGCOLOR 0xffffff0a
#define _CMD_BGCOLOR 0xffffff09
#define _CMD_GRADCOLOR 0xffffff34
#define _CMD_GAUGE 0xffffff13
#define _CMD_ROMFONT 0xffffff3f
#define _CMD_KEYS 0xffffff0e
#define _CMD_PROGRESS 0xffffff0f
#define _CMD_SCROLLBAR 0xffffff11
#define _CMD_SLIDER 0xffffff10
#define _CMD_TEXT 0xffffff0c
#define _CMD_TRACK 0xffffff2c
#define _CMD_SETBASE 0xffffff38
#define _CMD_NUMBER 0xffffff2e
#define CMD_CALIBRATE 0xffffff15
#define CMD_SETROTATE 0xffffff36
#define _CMD_SPINNER 0xffffff16
#define CMD_SCREENSAVER 0xffffff2f
#define _CMD_SKETCH 0xffffff30
#define CMD_STOP 0xffffff17
#define CMD_SETFONT 0xffffff2b
#define CMD_SETFONT2 0xffffff3b
#define CMD_SETSCRATCH 0xffffff3c
#define CMD_SNAPSHOT 0xffffff1f
#define CMD_SNAPSHOT2 0xffffff37
#define CMD_SETBITMAP 0xffffff43
#define CMD_LOGO 0xffffff31
#define CMD_CSKETCH 0xffffff35
#define _CMD_DIAL 0xffffff2d
#define _CMD_TOGGLE 0xffffff12

// Sub commands
enum {
  BITMAPS = 1,
  POINTS,
  LINES,
  LINE_STRIP,
  EDGE_STRIP_R,
  EDGE_STRIP_L,
  EDGE_STRIP_A,
  EDGE_STRIP_B,
  RECTS
} beginprimitives;

// Host Commands
enum {
  ACTIVE = 0,
  STANDBY = 0x41,
  SLEEP = 0x42,
  PWRDOWN = 0x43,
  CLKEXT = 0x44,
  CLKINT = 0x45
} hostcommands;

// Text Options
enum {
  NONE = 0,
  OPT_3D = 0,
  OPT_RGB565 = 0,
  OPT_MONO = 1,
  OPT_NODL,
  OPT_FLAT = 256,
  OPT_SIGNED = 256,
  OPT_CENTERX = 512,
  OPT_CENTERY = 1024,
  OPT_CENTER = 1536,
  OPT_RIGHTX = 2048,
  OPT_NOBACK = 4096,
  OPT_NOTICKS = 8192,
  OPT_NOHM = 16384,
  OPT_NOPOINTER = 16384,
  OPT_NOSECS = 32768,
  OPT_NOHANDS = 49152,
  OPT_NOTEAR = 4,
  OPT_FULLSCREEN  = 8,
  OPT_MEDIAFIFO = 16,
  OPT_SOUND = 32
} Options;

enum {
  NEAREST = 0,
  BILINEAR = 1,
  BORDER = 0,
  REPEAT = 1
} Filter;

enum {
  ARGB1555 = 0,
  L1 = 1,
  L4 = 2,
  L8 = 3,
  RGB332 = 4,
  ARGB2 = 5,
  ARGB4 = 6,
  RGB565 = 7,
  TEXT8X8 = 9,
  TEXTVGA = 10,
  BARGRAPH = 11,
  PALETTED565 = 14,
  PALETTED4444 = 15,
  PALETTED8 = 16,
  L2 = 17
} Layout;
  