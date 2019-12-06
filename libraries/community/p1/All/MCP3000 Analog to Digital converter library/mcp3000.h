/**
 * @file mcp3000.h
 * @brief Read MCP3000 Analog to Digital Chips
 * @author Michael Burmeister
 * @date February 16, 2016
 * @version 1.1
 * 
*/

/**
 * @brief Open connection to mcp3000 chip
 *
 * @param CS Chip Select low
 * @param CLK Serial in Clock
 * @param DOUT Data Out
 * @param DIN Data In
*/
void mcp3000_open(int CS, int CLK, int DOUT, int DIN);

/**
 * @brief Read the digital voltage value for channel 0 or 1
 * @param channel 0 or 1
 * @return value from 0 - 4096 (12 bit)
*/
int mcp3202_read(char channel);

/**
 * @brief Convert the reading to a voltage for channels 0 or 1
 *
 * @param r reference voltage used
 * @param channel 0 or 1
 * @return voltage in mili volts
*/
int mcp3202_volts(int r, char channel);

/**
 * @brief Read the digital voltage value for channel 0 or 1
 * @param channel 0 or 1
 * @return value from 0 - 1024 (10 bit)
 */
int mcp3002_read(char channel);

/**
 * @brief Convert the reading to millivolts for channel 0 or 1
 * @param r reference voltage used
 * @param channel 0 or 1
 * @return millivolts
 */
int mcp3002_volts(int r, char channel);

/**
 * @brief Read the digital voltage value for channels 0, 1, 2, or 3
 *        This code will also work for the 8 channel mcp3208
 * @param channel 0, 1, 2, or 3
 * @return value
 */
int mcp3204_read(char channel);

/**
 * @brief Convert the reading to millivolts for channels 0, 1, 2, or 3
 *        This code will also work for the 8 channel mcp3208
 * @param r reference voltage used
 * @param channel 0, 1, 2, or 3
 * @return millivolts
 */
int mcp3204_volts(int r, char channel);
