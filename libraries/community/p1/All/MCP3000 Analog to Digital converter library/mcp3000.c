/**
 * @file mcp3000.c
 * @brief Read MCP3202 Voltage
 * @author Michael Burmeister
 * @date February 16, 2016
 * @version 1.0
*/

#include "simpletools.h"
#include "mcp3000.h"

int mcpCS;
int mcpCLK;
int mcpDOUT;
int mcpDIN;


void mcp3000_open(int CS, int CLK, int DOUT, int DIN)
{
  
  mcpCS = CS;
  mcpCLK = CLK;
  mcpDOUT = DOUT;
  mcpDIN = DIN;

}

// millivolts times 1000
int mcp3202_read(char c)
{
  unsigned int i;
  
  i = 0x06 | c;
  i = (i << 1) | 0x01; // add MSBF bit
  low(mcpCS);
  shift_out(mcpDIN, mcpCLK, MSBFIRST, 4, i);
  i = shift_in(mcpDOUT, mcpCLK,  MSBPOST, 12);
  high(mcpCS);
  return i;
}
  
int mcp3202_volts(int r, char c)
{
  int i;
  
  i = mcp3202_read(c);
  i = i * 1000 * r / 4096;
  return i;
}
  
int mcp3002_read(char c)
{
  unsigned int i;
  
  i = 0x06 | c;
  i = (i << 1) | 0x01; // add MSBF bit
  low(mcpCS);
  shift_out(mcpDIN, mcpCLK, MSBFIRST, 4, i);
  i = shift_in(mcpDOUT, mcpCLK,  MSBPOST, 10);
  high(mcpCS);
  return i;
}

int mcp3002_volts(int r, char c)
{
  int i;
  
  i = mcp3202_read(c);
  i = i * 1000 * r / 1024;
  return i;
}

int mcp3204_read(char c)
{
  int i;
  
  i = 0x18 | c;
  i = i << 1; // add pulse delay
  low(mcpCS);
  shift_out(mcpDIN, mcpCLK, MSBFIRST, 6, i);
  i = shift_in(mcpDOUT, mcpCLK,  MSBPOST, 12);
  high(mcpCS);
  return i;
}

int mcp3204_volts(int r, char c)
{
  int i;
  
  i = mcp3204_read(c);
  i = i * 1000 * r / 4096;
  return i;
}
  