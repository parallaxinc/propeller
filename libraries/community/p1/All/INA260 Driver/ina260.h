/**
 * @file ina260.h
 * @brief INA260 Adafruit power driver
 * @author Michael Burmeister
 * @date June 23, 2019
 * @version 1.0
 * 
*/

#define INA260_I2CADDR 0x40
#define INA260_CONFIG  0x00
#define INA260_CURRENT 0x01
#define INA260_VOLTAGE 0x02
#define INA260_POWER   0x03
#define INA260_ALERTEN 0x04
#define INA260_ALERTV  0x05
#define INA260_MFGID   0xFE
#define INA260_DIEID   0xFF

enum _mode {
  INA260_SHUTDOWN,
  INA260_TRIGGER,
  INA260_CONTINOUS
} INA260_MODES;

/**
 * @brief open connection to INA260 device
 * @param address 0 - default
 * @param clock pin number
 * @param data pin number
 * @return id manufactor id
 */
unsigned short INA260_open(unsigned char address, char clock, char data);
  
/**
 * @brief read current in milliamps
 * @return current
 */
short INA260_getCurrent(void);

/**
 * @brief read voltage in hundredths
 * @return voltage
 */
short INA260_getVoltage(void);

/**
 * @brief read power in milliwatts
 * @return power
 */
short INA260_getPower(void);

/**
 * @brief config device
 * @param mode of operation
 * @param current conversion
 * @param voltage conversion
 * @param average amount
 * @param reset device
 */
void  INA260_setConfig(char mode, char current, char voltage, char average, char reset);

/**
 * @brief read device configuration
 * @return config
 */
unsigned short INA260_getConfig(void);

/**
 * @brief mask enable register
 * @param mask value
 */
void INA260_setMask(unsigned short mask);

/**
 * @brief get mask enable value
 * @return mask value
 */
unsigned short INA260_getMask(void);

/**
 * @brief set alert limit value
 * @param alert value
 */
void INA260_setAlert(unsigned short alert);
