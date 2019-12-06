/**
 * @file ina260.c
 * @brief INA260 Adafruit power driver
 * @author Michael Burmeister
 * @date June 23, 2019
 * @version 1.0
 * 
*/

#include "ina260.h"
#include "simpletools.h"

void _writeWord(unsigned char register, unsigned short data);
unsigned short _readWord(unsigned char register);
void _readBytes(unsigned char register, unsigned char cnt, unsigned char *dest);

unsigned char _INA260;
i2c *_INA260C;


unsigned short INA260_open(unsigned char address, char clock, char data)
{
  unsigned short id;
  
  if (address == 0)
    _INA260 = INA260_I2CADDR;
  else
    _INA260 = address;

  _INA260C = i2c_open(_INA260C, clock, data, 0);
  
  id = _readWord(INA260_MFGID);
  return id;
}

short INA260_getCurrent(void)
{
  int v;
  
  v = _readWord(INA260_CURRENT);
  v = v * 125;
  
  return v/100;
}

short INA260_getVoltage(void)
{
  int v;
  
  v = _readWord(INA260_VOLTAGE);
  v = v * 125;
  
  return v/1000;
}

short INA260_getPower(void)
{
  int v;
  
  v = _readWord(INA260_POWER);
  v = v * 10;

  return v;
}

void  INA260_setConfig(char mode, char current, char voltage, char average, char reset)
{
  unsigned short v;
  
  v = reset << 15;
  v = v | average << 9;
  v = v | voltage << 6;
  v = v | current << 3;
  v = v | mode;
  
  _writeWord(INA260_CONFIG, v);
}

unsigned short INA260_getConfig(void)
{
  unsigned short v;
  
  v = _readWord(INA260_CONFIG);
  return v;
}

void INA260_setMask(unsigned short mask)
{
 
  _writeWord(INA260_ALERTEN, mask);
  
}

unsigned short INA260_getMask(void)
{
  unsigned short v;
  
  v = _readWord(INA260_ALERTEN);
  
  return v;
}

void INA260_setAlert(unsigned short alert)
{
  _writeWord(INA260_ALERTV, alert);
}

/* basic read write funcitons
 */

/**
 * @brief I2C read write routines
 * @param reg register on device
 * @param data to write
*/
void _writeWord(unsigned char reg, unsigned short data)
{
  unsigned char v[2];
  
  v[0] = data >> 8;
  v[1] = data;
  
  i2c_out(_INA260C, _INA260, reg, 1, v, 2);
}

/**
 * @brief I2C read routine
 * @param reg register on device
 * @return byte value
*/
unsigned short _readWord(unsigned char reg)
{
  unsigned short v;
  unsigned char data[2];
  
  i2c_in(_INA260C, _INA260, reg, 1, data, 2);
  
  v = data[0] << 8 | data[1];
  
  return v;
}

/**
 * @brief I2C read routine
 * @param reg register on device
 * @param cnt number of bytes to read
 * @param dest returned byte of data from device
*/
void _readBytes(unsigned char reg, unsigned char cnt, unsigned char *dest)
{
  i2c_in(_INA260C, _INA260, reg, 1, dest, cnt);
}
