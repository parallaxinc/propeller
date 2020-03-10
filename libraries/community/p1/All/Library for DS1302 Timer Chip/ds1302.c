/**
 * @brief Clock Calender module
 * @author Michael Burmeister
 * @date January 14, 2017
 * @version 1.2
 * 
*/

#include "ds1302.h"
#include "simpletools.h"
#include "sys/time.h"

short _MM[] = {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};
char AMPM[][3] = {"AM", "PM"};
char _Msg[32];
short _AMPM;
short _SCLK;
short _MOSI;
short _CS;
short _MISO;

int DS1302_read(short);
void DS1302_write(short, short);


void DS1302_open(short mosi, short cs, short sclk, short miso)
{
  _SCLK = sclk;
  _CS = cs;
  _MOSI = mosi;
  _MISO = miso;
  low(_CS);
  memset(_Msg, 0, sizeof(_Msg));
  _AMPM = -1;
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
  if ((i & 0x80) != 0)
  {
    if ((i & 0x20) != 0)
      _AMPM = 1;
    else
      _AMPM = 0;
    j = i & 0x0f;
    i = i >> 4;
    i = j + i * 10;
  }
  else
  {
    j = i & 0x0f;
    i = i & 0x3f;
    i = i >> 4;
    i = j + i * 10;
  }

  return i;
}

char* DS1302_getAMPM()
{
  return AMPM[_AMPM];
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

void DS1302_setDate(short year, short month, short day)
{
  DS1302_setYear(year);
  DS1302_setMonth(month);
  DS1302_setDay(day);
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

void DS1302_setWeekDay(short weekday)
{
  short i;
  
  i = weekday & 0x0f;
  DS1302_write(DS1302WEEKDAY, i);
}

void DS1302_setTime(short hours, short minutes, short seconds)
{
  DS1302_setHour(hours);
  DS1302_setMinute(minutes);
  DS1302_setSecond(seconds);
}

void DS1302_setHour(short hr)
{
  short i, j;
  
  i = hr / 10;
  j = hr % 10;
  i = (i << 4) + j;
  DS1302_write(DS1302HOURS, i);
}

void DS1302_set12Hour(short hr, char AmPm)
{
  short i, j;
  
  i = hr / 10;
  j = hr % 10;
  i = (i << 4) + j;
  if (AmPm == 'P')
    i = i | 0x20;
  i = i | 0x80;
  DS1302_write(DS1302HOURS, i);
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

void DS1302_setDateTime(void)
{
  struct timeval tv;
  
  int v = (30 + DS1302_getYear()) * 36525/100;
  v = v + _MM[DS1302_getMonth()-1] + DS1302_getDay() - 1;
  if ((DS1302_getYear() % 4) == 0)
    if (DS1302_getMonth() > 2)
      v = v + 1;
  v = v * 24 + DS1302_getHours();
  v = v * 60 + DS1302_getMinutes();
  v = v * 60 + DS1302_getSeconds();
  tv.tv_usec = 0;
  tv.tv_sec = v;
  settimeofday(&tv, 0);
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

void DS1302_setMessage(char *msg)
{
  int i;

  high(_CS);
  shift_out(_MISO, _SCLK, LSBFIRST, 8, DS1302BURSTMM-1);
  for (i=0;i<31;i++)
  {
    shift_out(_MISO, _SCLK, LSBFIRST, 8, msg[i]);
  }    
  low(_CS);
}

char *DS1302_getMessage()
{
  int i;
  
  high(_CS);
  shift_out(_MISO, _SCLK, LSBFIRST, 8, DS1302BURSTMM);
  for (i=0;i<31;i++)
  {
    _Msg[i] = shift_in(_MOSI, _SCLK, LSBPRE, 8);
  }    
  low(_CS);
  return _Msg;
}

/*
void DS1302_burstRead()
{
  int i;
  
  high(_CS);
  shift_out(_MISO, _SCLK, LSBFIRST, 8, DS1302BURSTRD);
  i = shift_in(_MOSI, _SCLK, LSBPRE, 32);
  putHex(i);
  putChar('\n');
  low(_CS);
} 
*/ 