/**
 * @file HX8357.h
 * @brief HX8357 320x480 display panel
 * @author Michael Burmeister
 * @date March 11, 2019
 * @version 1.0
 * 
*/

// Color definitions
#define HX8357_BLACK   0x0000
#define HX8357_BLUE    0x001F
#define HX8357_RED     0xF800
#define HX8357_GREEN   0x07E0
#define HX8357_CYAN    0x07FF
#define HX8357_MAGENTA 0xF81F
#define HX8357_YELLOW  0xFFE0  
#define HX8357_WHITE   0xFFFF

/**
 * @brief set connection parameters
 * @param Clk
 * @param MISO
 * @param MOSI
 * @param CS
 * @param DC
 * @param RST
 * @param LITE
 * @return open
 */
int HX8357_open(char Clk, char MISO, char MOSI, char CS, char DC, char RST, char LITE);

/**
 * @brief set rotation
 * @param rotation
 */
void HX8357_rotation(char rotation);

/**
 * @brief invert display
 * @param yes
 */
void HX8357_invert(char yes);

/**
 * @brief set window location
 * @param x
 * @param y
 * @param width
 * @param height
 */
void HX8357_window(short x, short y, short width, short height);

/**
 * @brief push color
 * @brief color
 */
void HX8357_pushColor(short color);

/**
 * @brief write pixel color
 * @param color
 */
void HX8357_writePixel(short color);

/**
 * @brief write color
 * @param color
 * @param len
 */
void HX8357_writeColor(short color, int len);

/**
 * @brief plot point color
 * @param x
 * @param y
 * @param color
 */
void HX8357_plot(short x, short y, short color);

/**
 * @brief fill rectangle
 * @param x
 * @param y
 * @param width
 * @param height
 * @param color
 */
void HX8357_fillRectangle(short x, short y, short width, short height, short color);

/**
 * @brief draw pixel color
 * @param x
 * @param y
 * @param color
 */
void HX8357_drawPixel(short x, short y, short color);

/**
 * @brief clear screen
 * @param color
 */
void HX8357_cls(short color);

/**
 * @brief set display on
 * @param mode 0/1 off/on
 */
void HX8357_displayOn(char mode);

/**
 * @brief put display to sleep
 * @param sleep 0/1 off/on
 */
void HX8357_sleepOn(char sleep);

/**
 * @brief set inverse on/off
 * @param inverse 0/1 on/off
 */
void HX8357_inverse(char inverse);

/**
 * @brief set all pixels on/off
 * @param set 0/1 on/off
 */
void HX8357_allPixels(char set);

/**
 * @brief display mode normal/partial
 * @brief mode 0/1 normal/partial
 */
void HX8357_displayMode(char mode);

/**
 * @brief set text color
 * @param fgcolor
 * @param bgcolor
 */
void HX8357_textColor(short fgcolor, short bgcolor);

/**
 * @brief write small string 8x8 (5x7)
 * @param x
 * @param y
 * @param text
 */
void HX8357_writeSStr(short x, short y, char *text);

/**
 * @brief write small character 8x8 (5x7)
 * @param x
 * @param y
 * @param character
 */
void HX8357_writeSChar(short x, short y, char character);

/**
 * @brief write character 16x32
 * @param x offset
 * @param y offset
 * @param c character
 */
void HX8357_writeChar(short x, short y, char c);

/**
 * @brief write string 16x32
 * @param x offset
 * @param y offset
 * @param s pointer to string
 */
void HX8357_writeStr(short x, short y, char* s);

/**
 * @brief write extra large character 32x64
 * @param x offset
 * @param y offset
 * @param c character
 */
void HX8357_writeXChar(short x, short y, char c);

/**
 * @brief write extra large string 32x64
 * @param x offset
 * @param y offset
 * @param s pointer to string
 */
void HX8357_writeXStr(short x, short y, char *s);

/*
 * @brief draw line 
 * @param x start point
 * @param y start point
 * @param x1 end point
 * @param y1 end point
 * @param color
 */
void HX8357_drawLine(short x, short y, short x1, short y1, short color);

/*
 * @brief draw a box
 * @param x start point
 * @param y start point
 * @param x1 end point
 * @param y1 end point
 * @param color On/Off
 */
void HX8357_drawBox(short x, short y, short x1, short y1, short color);

/* @brief build 888 rgb color value
 * @param red 8 bits
 * @param green 8 bits
 * @param blue 8 bits
 * @return color
 */
unsigned short HX8357_color(char red, char green, char blue);
