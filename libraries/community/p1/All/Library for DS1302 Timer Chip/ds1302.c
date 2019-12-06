/**
 * @file ds1302.c
 * @brief Clock Calender device
 * @author Michael Burmeister
 * @date January 14, 2017
 * @version 1.0
 * 
*/

#include "ds1302.h"
#include "simpletools.h"

short _SCLK;
short _MOSI;
short _CS;
short _MISO;

int DS1302_read(short);
void DS1302_write(short, short);

/*
 *
*/
void DS1302_open(short mosi, short cs, short sclk, short miso)
{
  _SCLK = sclk;
  _CS = cs;
  _MOSI = mosi;
  _MISO = miso;
  low(_CS);
}

short DS1302_getSeconds()
{
  short i, j;
  
  i = DS1302_read(DS1302SECONDS);
  i = i & 0x7f;
  j = i >> 4;
  i = (i & 0x0f) + j * 10;
  return i;
}

short DS1302_getMinutes()
{
  short i, j;
  
  i = DS1302_read(DS1302MINUTES);
  i = i & 0x7f;
  j = i >> 4;
  i = (i & 0x0f) + j * 10;
  return i;
}

short DS1302_getHours()
{
  short i, j;
  
  i = DS1302_read(DS1302HOURS);
  i = i & 0x3f;
  j = i >> 4;
  i = (i & 0x0f) + j * 10;
  return i;
}

short DS1302_getDay()
{
  short i, j;
  
  i = DS1302_read(DS1302DAY);
  j = i >> 4;
  i = (i & 0x0f) + j * 10;
  return i;
}

short DS1302_getMonth()
{
  short i, j;
  
  i = DS1302_read(DS1302MONTH);
  j = i >> 4;
  i = (i & 0xf) + j * 10;
  return i;
}

short DS1302_getWeekDay()
{
  short i, j;
  
  i = DS1302_read(DS1302WEEKDAY);
  return i;
}

short DS1302_getYear()
{
  short i, j;
  
  i = DS1302_read(DS1302YEAR);
  j = i >> 4;
  i = (i & 0xf) + j * 10;
  return i;
}

void DS1302_setYear(short yr)
{
  short i, j;
  
  i = yr / 10;
  j = yr % 10;
  i = (i << 4) + j;
  DS1302_write(DS1302YEAR, i);
}

void DS1302_setMonth(short mn)
{
  short i, j;
  
  i = mn / 10;
  j = mn % 10;
  i = (i << 4) + j;
  DS1302_write(DS1302MONTH, i);
}

void DS1302_setDay(short dy)
{
  short i, j;
  
  i = dy / 10;
  j = dy % 10;
  i = (i << 4) + j;
  DS1302_write(DS1302DAY, i);
}

void DS1302_setHour(short hr)
{
  short i, j;
  
  i = hr / 10;
  j = hr % 10;
  i = (i << 4) + j;
  DS1302_write(DS1302HOURS, hr);
}

void DS1302_setMinute(short mn)
{
  short i, j;
  
  i = mn / 10;
  j = mn % 10;
  i = (i << 4) + j;
  DS1302_write(DS1302MINUTES, i);
}

void DS1302_setSecond(short s)
{
  short i, j;
  
  i = s / 10;
  j = s % 10;
  i = (i << 4) + j;
  DS1302_write(DS1302SECONDS, i);
}
    
short DS1302_getWriteProtect()
{
  short i;
  
  i = DS1302_read(DS1302WP);
  if (i == 0x80)
    return -1;
  else
    return 0;
}

void DS1302_setWriteProtect()
{
  DS1302_write(DS1302WP, 0x80);
}

void DS1302_clearWriteProtect()
{
  DS1302_write(DS1302WP, 0x00);
}

    
/*
 * @brief read data
 * 
 */
int DS1302_read(short control)
{
  int i;
  
  high(_CS);
  shift_out(_MISO, _SCLK, LSBFIRST, 8, control);
  i = shift_in(_MOSI, _SCLK, LSBPRE, 8);
  low(_CS);
  return i;
}

/*
 * @brief write data
 * 
 */
void DS1302_write(short control, short data)
{
  
  high(_CS);
  shift_out(_MISO, _SCLK, LSBFIRST, 8, control-1);
  shift_out(_MISO, _SCLK, LSBFIRST, 8, data);
  low(_CS);
}
  