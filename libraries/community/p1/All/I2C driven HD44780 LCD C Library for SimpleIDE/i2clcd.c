#include "i2clcd.h"

uint8_t  _Addr = 39;
uint8_t  _cols = 20;
uint8_t  _rows = 4;
uint8_t  _backlightval = LCD_NOBACKLIGHT;
uint8_t  _displayfunction;
uint8_t  _numlines;
uint8_t  _displaycontrol;
uint8_t  _displaymode;

i2clcd *lcd_init(uint8_t address, uint8_t lines, uint8_t cols)
{
   _Addr = address; _rows = lines; _cols = cols;
   _displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS;
   lcd_begin(_cols, _rows, LCD_5x8DOTS);  
}

void lcd_begin(uint8_t cols, uint8_t lines, uint8_t dotsize)
{
	if (lines > 1)
	{
		_displayfunction |= LCD_2LINE;
	}
	_numlines = lines;

	// for some 1 line displays you can select a 10 pixel high font
	if ((dotsize != 0) && (lines == 1))
	{
		_displayfunction |= LCD_5x10DOTS;
	}

	// SEE PAGE 45/46 FOR INITIALIZATION SPECIFICATION!
	// according to datasheet, we need at least 40ms after power rises above 2.7V
	// before sending commands. Arduino can turn on way befer 4.5V so we'll wait 50
	pause(50); 
  
	// Now we pull both RS and R/W low to begin commands
	lcd_expanderWrite(_backlightval);	// reset expander and turn backlight off (Bit 8 =1)
	pause(10);

  	// put the LCD into 4 bit mode
	// this is according to the hitachi HD44780 datasheet
	// figure 24, pg 46 - not sure why this has to go through twice... 
   //could be due to resistor that makes the display very slow
   for (int i = 0; i < 2; i++)
   {
      	// we start in 8bit mode, then try to set 4 bit mode
      	lcd_write4bits(0x03);
      	pause(50); // wait min 4.1ms
	
      	// finally, set to 4-bit interface
      	lcd_write4bits(0x02); 

      	// set # lines, font size, etc.
      	lcd_command(LCD_FUNCTIONSET | _displayfunction);  
   }
   	
	// turn the display on with no cursor or blinking default
	_displaycontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF;
	lcd_displayOn();
	
	// clear it off
	lcd_clear();
	
	// Initialize to default text direction (for roman languages)
	_displaymode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT;
	
	// set the entry mode
	lcd_command(LCD_ENTRYMODESET | _displaymode);
	
	lcd_home();
}

/********** high level commands, for the user! */
void lcd_clear()
{
	lcd_command(LCD_CLEARDISPLAY);// clear display, set cursor position to zero
	pause(500);  // this command takes a long time!
}

void lcd_home()
{
	lcd_command(LCD_RETURNHOME);  // set cursor position to zero
	pause(500);  // this command takes a long time!
}

void lcd_setCursor(uint8_t row, uint8_t col)
{
	int row_offsets[] = { 0x00, 0x40, 0x14, 0x54 };
	if ( row > _numlines )
	{
		row = _numlines-1;    // we count rows starting w/0
	}
	lcd_command(LCD_SETDDRAMADDR | (col + row_offsets[row]));
}

// Turn the display on/off (quickly)
void lcd_displayOff()
{
	_displaycontrol &= ~LCD_DISPLAYON;
	lcd_command(LCD_DISPLAYCONTROL | _displaycontrol);
}

void lcd_displayOn()
{
	_displaycontrol |= LCD_DISPLAYON;
	lcd_command(LCD_DISPLAYCONTROL | _displaycontrol);
}

// Turns the underline cursor on/off
void lcd_cursorOff()
{
	_displaycontrol &= ~LCD_CURSORON;
	lcd_command(LCD_DISPLAYCONTROL | _displaycontrol);
}

void lcd_cursorOn()
{
	_displaycontrol |= LCD_CURSORON;
	lcd_command(LCD_DISPLAYCONTROL | _displaycontrol);
}

// Turn on and off the blinking cursor
void lcd_blinkOff()
{
	_displaycontrol &= ~LCD_BLINKON;
	lcd_command(LCD_DISPLAYCONTROL | _displaycontrol);
}

void lcd_blinkOn()
{
	_displaycontrol |= LCD_BLINKON;
	lcd_command(LCD_DISPLAYCONTROL | _displaycontrol);
}

// These commands scroll the display without changing the RAM
void lcd_scrollDisplayLeft(void)
{
	lcd_command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT);
}

void lcd_scrollDisplayRight(void)
{
	lcd_command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT);
}

// This is for text that flows Left to Right
void lcd_leftToRight(void)
{
	_displaymode |= LCD_ENTRYLEFT;
	lcd_command(LCD_ENTRYMODESET | _displaymode);
}

// This is for text that flows Right to Left
void lcd_rightToLeft(void)
{
	_displaymode &= ~LCD_ENTRYLEFT;
	lcd_command(LCD_ENTRYMODESET | _displaymode);
}

// This will 'right justify' text from the cursor
void lcd_autoscrollOn(void)
{
	_displaymode |= LCD_ENTRYSHIFTINCREMENT;
	lcd_command(LCD_ENTRYMODESET | _displaymode);
}

// This will 'left justify' text from the cursor
void lcd_autoscrollOff(void)
{
	_displaymode &= ~LCD_ENTRYSHIFTINCREMENT;
	lcd_command(LCD_ENTRYMODESET | _displaymode);
}

// Allows us to fill the first 8 CGRAM locations
// with custom characters
//void createChar(uint8_t location, uint8_t charmap[])
//{
//	location &= 0x7; // we only have 8 locations 0-7
//	command(LCD_SETCGRAMADDR | (location << 3));
//	for (int i=0; i<8; i++)
//	{
//		write(charmap[i]);
//	}
//}

// Turn the (optional) backlight off/on
void lcd_backlightOff(void)
{
	_backlightval=LCD_NOBACKLIGHT;
	lcd_expanderWrite(0);
}

void lcd_backlightOn(void)
{
	_backlightval=LCD_BACKLIGHT;
	lcd_expanderWrite(0);
}

/*********** mid level commands, for sending data/cmds */

void lcd_command(uint8_t value)
{
	lcd_send(value, 0);
}

size_t lcd_write(uint8_t value)
{
	lcd_send(value, Rs);
}

/************ low level data pushing commands **********/

// write either command or data
void lcd_send(uint8_t value, uint8_t mode)
{
	uint8_t highnib=value&0xf0;
	uint8_t lownib=(value<<4)&0xf0;
    lcd_write4bits((highnib)|mode);
	lcd_write4bits((lownib)|mode); 
}

void lcd_write4bits(uint8_t value)
{
	lcd_expanderWrite(value);
	lcd_pulseEnable(value);
}

void lcd_expanderWrite(uint8_t _data)
{                                        
	i2c__write(_Addr, (long)(_data) | _backlightval);
}

void lcd_pulseEnable(uint8_t _data)
{
	lcd_expanderWrite(_data | En);	// En high
	pause(1);		// enable pulse must be >450ns
	lcd_expanderWrite(_data & ~En);	// En low
	pause(50);		// commands need > 37us to settle
} 

//void load_custom_character(uint8_t char_num, uint8_t *rows)
//{
//		createChar(char_num, rows);
//}

//void lcd_setBacklight(uint8_t new_val)
//{
//	if(new_val)
//	{
//		lcd_backlight();		// turn backlight on
//	}
//	else
//	{
//		lcd_noBacklight();		// turn backlight off
//	}
//}

size_t lcd_print(const char *str)
{
   if (str == NULL)
      return 0;
   else
   {
      size_t size = strlen(str);
      char *buffer = str;
      size_t n = 0;
      while (size--)
      {
         n += lcd_write(*buffer++);
      }
      return n;
   }
}
