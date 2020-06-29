/**
 * @file newhaven.h
 * @brief Interface New Haven Display
 * @author Michael Burmeister
 * @date July 30, 2018
 * @version 1.2
 * @mainpage Custom Libraries
 * <a href="newhaven_8h.html">NewHaven Display Driver.</a><br>
*/

#include "newhavenreg.h"

/**
 * @details Set Display pins used
 * @param CS - chip select
 * @param MOSI - master out slave in
 * @param MISO - master in slave out
 * @param SCLK - slave clock
 * @param POWER - power down
 * @return value
 */
unsigned char openNewHaven(char CS, char MOSI, char MISO, char SCLK, char POWER);

/**
 *@details read display panel id 7C
 *@return ID
 */
unsigned char readID(void);

/**
 *@details get command free space
 *@return bytes free
 */
int cmdFree(void);

/**
 *@details make display list active
 */
void DoList(void);

/**
 *@brief setup display values
 *@param horizontal 800
 *@param vertical 480
 */
void setDisplay(int horizontal, int vertical);

/**
 *@brief set GPIO direction
 *@param GPIO
 *@param DIRECTION
 */
void GPIODir(unsigned char GPIO, unsigned char DIRECTION);

/**
 *@brief set GPIO state
 *@param GPIO
 *@param STATE
 */
void setGPIO(unsigned char GPIO, unsigned char STATE);

/**
 *@brief get GPIO state
 *@param GPIO
 *@return state pin state
 */
unsigned char getGPIO(unsigned char GPIO);

/**
 *@brief set background light value 0 - 128
 *@param intensity
 */
void setBrightness(unsigned char intensity);

/**
 *@brief set display rotation
 *@param orientation
 */
void setRotation(unsigned char orientation);

/**
 *@brief send coprocessor instructions
 *@param instruction for coprocessor
 */
int cmd(unsigned int instruction);

/**
 *@brief send clear coprocessor instruction
 *@param color clear color if 1
 *@param stencil clear stencil if 1
 *@param tag clear tag buffer if 1
 *@return instruction
 */
unsigned int CLEAR(char color, char stencil, char tag);

/**
 *@brief send display coprocessor instruction
 *@return display instruction code
 */
unsigned int DISPLAY(void);

/**
 *@brief send clear color coprocessor instruction
 *@param Red color value
 *@param Green color value
 *@param Blue color value
 *@return clear color instruction code
 */
unsigned int CLEAR_COLOR_RGB(unsigned char Red, unsigned char Green, unsigned char Blue);

/**
 *@brief build begin co-processor instruction
 *@param graphics primitive
 *@return begin instruction code
 */
unsigned int BEGIN(unsigned char graphics);

/**
 *@brief build color coprocessor instruction
 *@param Red
 *@param Green
 *@param Blue
 *@return Color instruction code
 */
unsigned int COLOR_RGB(unsigned char Red, unsigned char Green, unsigned char Blue);

/**
 *@brief build point size coprocessor instruction
 *@param point size in 16ths
 *@return point size instruction code
 */
unsigned int POINT_SIZE(short point);

/**
 *@brief build vertex2ii coprocessor instruction
 *@param x axis value
 *@param y axis value
 *@param bit map handle
 *@param cell number
 *@return vertex2ii instruction code
 */
unsigned int VERTEX2II(short x, short y, unsigned char bit, unsigned char cell);

/**
 *@brief set x vertex offset
 *@param offset value in 16ths
 *@return offset instruction code
 */
unsigned int VERTEX_TRANSLATE_X(short offset);

/**
 *@brief set y vertex offset
 *@param offset value in 16ths
 *@return offset instruction code
 */
unsigned int VERTEX_TRANSLATE_Y(short offset);

/**
 *@brief build end coprocessor instruction
 *@return end instruction code
 */
unsigned int END(void);

/**
 *@brief build vertex2f coprocessor instruction
 *@param x axis
 *@param y axis
 *@return vertex2f instruction code
 */
unsigned int VERTEX2F(short x, short y);

/**
 *@brief set line width for drawing
 *@param width of line
 *@return line width instruction code
 */
unsigned int LINE_WIDTH(short width);

/**
 *@brief set palette source
 *@param source address
 *@return palette source instruction code
 */
unsigned int PALETTE_SOURCE(int source);

/**
 *@brief restore context
 *@return restore context instruction code
 */
unsigned int RESTORE_CONTEXT(void);

/**
 *@brief return from call
 *@return return instruction code
 */
unsigned int RETURN(void);

/**
 *@brief save current context
 *@return save context instruction code
 */
unsigned int SAVE_CONTEXT(void);

/**
 *@brief set scissor size
 *@param width
 *@param height
 *@return scissor size instruction code
 */
unsigned int SCISSOR_SIZE(int width, int height);

/**
 *@brief set scissor location
 *@param x
 *@param y
 *@return scissor x y instruction code
 */
unsigned int SCISSOR_XY(int x, int y);

/**
 *@brief alpha test function
 *@param function value
 *@param reference value
 *@return alpha function instruction code
 */
unsigned int ALPHA_FUNC(short function, short reference);

/**
 *@brief bitmap handle
 *@param handle
 *@return bitmap handle instruction code
 */
unsigned int BITMAP_HANDLE(short handle);

/**
 *@brief bitmap layout
 *@param format
 *@param linestride
 *@param height
 *@return bitmap handle instructin code
 */
unsigned int BITMAP_LAYOUT(short format, short linestride, short height);

/**
 *@brief bitmap layout h
 *@param linestride
 *@param height
 *@return bitmap layout h instruction code
 */
unsigned int BITMAP_LAYOUT_H(unsigned char linestride, unsigned char height);

/**
 *@brief bitmap size
 *@param filter
 *@param wrapx
 *@param wrapy
 *@param width
 *@param height
 *@return bitmap size instruction code
 */
unsigned int BITMAP_SIZE(unsigned char filter, unsigned char wrapx, unsigned char wrapy, short width, short height);

/**
 *@brief bitmap size h
 *@param width
 *@param height
 *@return bitmap size h instruction code
 */
unsigned int BITMAP_SIZE_H(unsigned char width, unsigned char height);

/**
 *@brief bitmap source
 *@param address
 *@return bitmap source instruction code
 */
unsigned int BITMAP_SOURCE(int address);

/**
 *@brief bitmap transform a coefficient
 *@param coefficient
 *@return bitmap transform a instruction code
 */
unsigned int BITMAP_TRANSFORM_A(unsigned short coefficient);

/**
 *@brief bitmap transform b coefficient
 *@param coefficient
 *@return bitmap transform b instruction code
 */
unsigned int BITMAP_TRANSFORM_B(unsigned short coefficient);

/**
 *@brief bitmap transform c coefficient
 *@param coefficient
 *@return bitmap transform c instruction code
 */
unsigned int BITMAP_TRANSFORM_C(unsigned int coefficient);

/**
 *@brief bitmap transform d coefficient
 *@param coefficient
 *@return bitmap transform d instruction code
 */
unsigned int BITMAP_TRANSFORM_D(unsigned short coefficient);

/**
 *@brief bitmap transform e coefficient
 *@param coefficient
 *@return bitmap transform e instruction code
 */
unsigned int BITMAP_TRANSFORM_E(unsigned short coefficient);

/**
 *@brief bitmap transform f coefficient
 *@param coefficient
 *@return bitmap transform f instruction code
 */
unsigned int BITMAP_TRANSFORM_F(unsigned int coefficient);

/**
 *@brief blend function
 *@param source
 *@param destination
 *@return blend function instruction code
 */
unsigned int BLEND_FUNC(unsigned char source, unsigned char destination);

/**
 *@brief call
 *@param address
 *@return call instruction code
 */
unsigned int CALL(unsigned short address);

/**
 *@brief cell
 *@param cell
 *@return cell instruction code
 */
unsigned int CELL(unsigned char cell);

/**
 *@brief clear color alpha
 *@param alpha
 *@return clear color alpha instruction code
 */
unsigned int CLEAR_COLOR_A(unsigned char alpha);

/**
 *@brief clear stencil buffer value
 *@param stencil
 *@return clear stencil instruction code
 */
unsigned int CLEAR_STENCIL(unsigned char stencil);

/**
 *@brief clear tag buffer value
 *@param tag
 *@return clear tag instruction code
 */
unsigned int CLEAR_TAG(unsigned char tag);

/**
 *@brief color alpha value
 *@param color
 *@return color alpha instruction code
 */
unsigned int COLOR_A(unsigned char color);

/**
 *@brief color mask
 *@param red
 *@param green
 *@param blue
 *@param alpha
 *@return color mask instruction code
 */
unsigned int COLOR_MASK(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha);

/**
 *@brief jump
 *@param address
 *@return jump instruction code
 */
unsigned int JUMP(unsigned short address);

/**
 *@brief macro register
 *@param register
 *@return macro instruction code
 */
unsigned int MACRO(unsigned char register);

/**
 *@brief nop
 *@return nop instruction code
 */
unsigned int NOP(void);

/**
 *@brief stencil function
 *@param function
 *@param reference
 *@param mask
 *@return stencil instruction code
 */
unsigned int STENCIL_FUNC(unsigned char function, unsigned char reference, unsigned char mask);

/**
 *@brief stencil mask
 *@param mask
 *@return stencil mask instruction code
 */
unsigned int STENCIL_MASK(unsigned char mask);

/**
 *@brief stencil opperation
 *@param fail
 *@param pass
 *@return stencil op instruction code
 */
unsigned int STENCIL_OP(unsigned char fail, unsigned char pass);

/**
 *@brief tag mask
 *@param mask
 *@return tag mask instruction code
 */
unsigned int TAG_MASK(unsigned char mask);

/**
 *@brief vertex format
 *@param fraction
 *@return vertex format instruction code
 */
unsigned int VERTEX_FORMAT(unsigned char fraction);

/**
 *@brief macro 0
 *@param instruction code
 */
void MACRO_0(unsigned int instruction);

/**
 *@brief macro 1
 *@param instruction code
 */
void MACRO_1(unsigned int instruction);

/**
 *@brief build Button object
 *@param x
 *@param y
 *@param width
 *@param height
 *@param font
 *@param option
 *@param string
 */
void CMD_BUTTON(short x, short y, short width, short height, short font, short option, char *string);

/**
 *@brief write Text string
 *param x
 *param y
 *param font
 *param option
 *param string
 */
void CMD_TEXT(short x, short y, short font, short option, char *string);

/**
 *@brief draw clock face
 *@param x
 *@param y
 *@param radius
 *@param options
 *@param hours
 *@param minutes
 *@param seconds
 *@param miliseconds
 */
void CMD_CLOCK(short x, short y, short radius, short options, short hours, short minutes, short seconds, short miliseconds);

/**
 *@brief set background color
 *@param color rgb color value
 */
void CMD_BGCOLOR(int color);

/**
 *@brief set foreground color
 *@param color
 */
void CMD_FGCOLOR(int color);

/**
 *@brief load rom font
 *@param font
 *@param romslot
 */
void CMD_ROMFONT(unsigned char font, unsigned char romslot);

/**
 *@brief draw gauge
 *@param x
 *@param y
 *@param radius
 *@param options
 *@param major
 *@param minor
 *@param val
 *@param range
 */
void CMD_GAUGE(short x, short y, short radius, short options, short major, short minor, short val, short range);

/**
 *@brief gradent color
 *@param color
 */
void CMD_GRADCOLOR(short color);

/**
 *@brief wait for co-processor
 *@return
 */
void Wait(void);

/**
 *@brief draw prograss bar
 *@param x
 *@param y
 *@param width
 *@param height
 *@param options
 *@param value
 *@param range
 */
void CMD_PROGRESS(short x, short y, short width, short height, short options, short value, short range);

/**
 *@brief draw scroll bar
 *@param x
 *@param y
 *@param width
 *@param height
 *@param options
 *@param value
 *@param size
 *@param range
 */
void CMD_SCROLLBAR(short x, short y, short width, short height, short options, short value, short size, short range);

/**
 *@brief draw slider
 *@param x
 *@param y
 *@param width
 *@param height
 *@param options
 *@param value
 *@param range
 */
void CMD_SLIDER(short x, short y, short width, short height, short options, short value, short range);

/**
 *@brief draw dial control
 *@param x
 *@param y
 *@param radius
 *@param option
 *@param value
 */
void CMD_DIAL(short x, short y, short radius, short option, short value);

/**
 *@brief draw toggle control
 *@param x
 *@param y
 *@param width
 *@param font
 *@param options
 *@param state
 *@param string text to display
 */
void CMD_TOGGLE(short x, short y, short width, short font, short options, short state, char* string);

/**
 *@brief set number base
 *@param base number base 10, 16, 8
 */
void CMD_SETBASE(int base);

/**
 *@brief display number
 *@param x
 *@param y
 *@param font
 *@param options
 *@param value
 */
void CMD_NUMBER(short x, short y, short font, short options, int value);

/**
 *@brief draw command keys
 *@param x
 *@param y
 *@param width of keys
 *@param height of keys
 *@param font number
 *@param options key pressed
 *@param keys string
 */
void CMD_KEYS(short x, short y, short width, short height, short font, short options, char *keys);

/**
 *@brief draw spinner
 *@param x
 *@param y
 *@param style
 *@param scale
 */
void CMD_SPINNER(short x, short y, short style, short scale);

/**
 *@brief sketch input
 *@param x
 *@param y
 *@param width
 *@param height
 *@param pointer
 *@param format
 */
void CMD_SKETCH(short x, short y, short width, short height, int pointer, short format);

/**
 *@brief touch screen cordinates
 *@return xy cordinates
 */
int TouchScreen(void);

/**
 *@brief touch tag
 *@return tag value
 */
unsigned char TouchTag(void);

/**
 *@brief set tag value
 *@param tag object tag value
 */
unsigned int TAG(unsigned char tag);

/**
 *@brief get tracker value
 *@return value
 */
unsigned int Tracker(void);

/**
 *@brief start tracking area
 *@param x
 *@param y
 *@param width
 *@param height
 *@param tag
 */
void CMD_TRACK(short x, short y, short width, short height, short tag);

/**
 *@brief dump commands
 */
void DumpCmd(void);

/**
 *@brief dump display screen instruction codes
 */
void DumpDL(void);

/**
 *@brief send host commands
 *@param function value
 */
void HostCommand(unsigned char function);

/**
 *@brief write dl instruction using _Dl offset
 *@param instruction
 *@return next address
 */
short dl(unsigned int instruction);

/**
 *@brief clear Dl pointer
 */
void ClearDL(void);

/**
 *@brief read byte from memory area
 *@param address
 *@return data
 */
unsigned char readMemory(unsigned int address);

/**
 *@brief read 4 bytes from memory area
 *@param address
 *@return data
 */
unsigned int readMemory32(unsigned int address);

/**
 *@brief write byte to memory area
 *@param address
 *@param data
 */
void writeMemory(unsigned int address, unsigned char data);

/**
 *@brief write 4 bytes to memory area
 *@param address
 *@param data
 */
void writeMemory32(unsigned int address, unsigned int data);



/**
 *@brief SPI Read Write Functions
 */
unsigned char _read8(unsigned int);

void _write8(int, unsigned char);

short _read16(unsigned int);

void _write16(int, int);

int _read32(unsigned int);

void _write32(int, int);

