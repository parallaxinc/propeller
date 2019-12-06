#ifndef __I2CLCD_H
#define __I2CLCD_H

#include "simpletools.h"

#ifdef __cplusplus
extern "C"
{
#endif

typedef text_t i2clcd;

// commands
#define LCD_CLEARDISPLAY 0x01
#define LCD_RETURNHOME 0x02
#define LCD_ENTRYMODESET 0x04
#define LCD_DISPLAYCONTROL 0x08
#define LCD_CURSORSHIFT 0x10
#define LCD_FUNCTIONSET 0x20
#define LCD_SETCGRAMADDR 0x40
#define LCD_SETDDRAMADDR 0x80

// flags for display entry mode
#define LCD_ENTRYRIGHT 0x00
#define LCD_ENTRYLEFT 0x02
#define LCD_ENTRYSHIFTINCREMENT 0x01
#define LCD_ENTRYSHIFTDECREMENT 0x00

// flags for display on/off control
#define LCD_DISPLAYON 0x04
#define LCD_DISPLAYOFF 0x00
#define LCD_CURSORON 0x02
#define LCD_CURSOROFF 0x00
#define LCD_BLINKON 0x01
#define LCD_BLINKOFF 0x00

// flags for display/cursor shift
#define LCD_DISPLAYMOVE 0x08
#define LCD_CURSORMOVE 0x00
#define LCD_MOVERIGHT 0x04
#define LCD_MOVELEFT 0x00

// flags for function set
#define LCD_8BITMODE 0x10
#define LCD_4BITMODE 0x00
#define LCD_2LINE 0x08
#define LCD_1LINE 0x00
#define LCD_5x10DOTS 0x04
#define LCD_5x8DOTS 0x00

// flags for backlight control
#define LCD_BACKLIGHT 0x08
#define LCD_NOBACKLIGHT 0x00

#define En 0b00000100  // Enable bit
#define Rw 0b00000010  // Read/Write bit
#define Rs 0b00000001  // Register select bit

i2clcd *lcd_init(uint8_t address, uint8_t lines, uint8_t cols);
void lcd_begin(uint8_t cols, uint8_t lines, uint8_t dotsize);
void lcd_clear();
void lcd_home();
void lcd_setCursor(uint8_t col, uint8_t row);
void lcd_displayOff();
void lcd_displayOn();
void lcd_cursorOff();
void lcd_cursorOn();
void lcd_blinkOff();
void lcd_blinkOn();
void lcd_scrollDisplayLeft();
void lcd_scrollDisplayRight();
void lcd_leftToRight();
void lcd_rightToLeft();
void lcd_autoscrollOn();
void lcd_autoscrollOff();
void lcd_backlightOff();
void lcd_backlightOn();
void lcd_command(uint8_t value);
size_t lcd_write(uint8_t value);
void lcd_send(uint8_t value, uint8_t mode);
void lcd_write4bits(uint8_t value);
void lcd_expanderWrite(uint8_t _data);
void lcd_pulseEnable(uint8_t _data);
//void load_custom_character(uint8_t char_num, uint8_t *rows);
//void lcd_setBacklight(uint8_t new_val);
size_t lcd_print(const char *str);

#ifdef __cplusplus
}
#endif

#endif