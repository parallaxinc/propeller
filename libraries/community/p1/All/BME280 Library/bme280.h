/**
 * @file bme280.h
 * @brief BME280 sensor library
 * @author Michael Burmeister
 * @date December 14, 2017
 * @version 1.1
 * 
 * @details sample code:
 * 
 * i = BME280_open(BMESCL, BMESDA);<br>
 * BME280_reset();<br>
 * BME280_setHumidity(oversample_1);<br>
 * BME280_setTemp(oversample_1);<br>
 * BME280_setPressure(oversample_1);<br>
 * BME280_setStandbyRate(standby625);<br>
 * BME280_setMode(BME280_normal);<br>
 * while (BME280_getStatus() != 0);<br>
 * BME280_getTempF();<br>
 * 
*/

// #define DODOUBLE

enum
{
  oversample_0,
  oversample_1,
  oversample_2,
  oversample_4,
  oversample_8,
  oversample_16
};
  
enum
{
  BME280_sleep,
  BME280_forced,
  BME280_forced1,
  BME280_normal
};

enum
{
  standby5,
  standby625,
  standby1250,
  standby2500,
  standby5000,
  standby10000,
  standby100,
  standby200
};

enum
{
  filter0,
  filter2,
  filter4,
  filter8,
  filter16
};

/**
 * @brief Open i2c connection to BME280
 * 
 * @param scl I2c clock pin
 * @param sda I2c data pin
 * @return 0x60 or -1 if not found
 */
int BME280_open(int scl, int sda);

/**
 * @brief Get BME280 ID (0x60)
 * 
 * @return 0x60
 */
int BME280_getID(void);

/**
 * @brief Do soft reset of BME280
 * 
 */
void BME280_reset(void);

/**
 * @brief Get measurement status 
 * 
 * @return status bit 3 = measurement running, bit 0 = copying measurement
 */
int BME280_getStatus(void);

/**
 * @brief Forced mode standby rate
 *        .5, 62.5 125, 250, 500, 1000, 100, and 200
 * @param s Standby Item name
 */
void BME280_setStandbyRate(int s);

/**
 * @brief Forced mode filter rate
 *        0, 2, 4, 8, 16
 * @param f Filter rate item name
 */
void BME280_setFilterRate(int f);

/**
 * @brief Set BME280 Mode of operation
 *        Sleep, Forced, and Normal
 * @param m Mode item name
 */
void BME280_setMode(int m);

/**
 * @brief get BME280 Mode of operation
 * 
 * @return Mode value for Sleep, Forced and Normal
 */
int BME280_getMode(void);

/**
 * @brief Set pressure measurement sampling
 *        0, 1, 2, 4, 8, 16
 * @param f Frequency Item Name
 */
void BME280_setPressure(int f);

/**
 * @brief Set Temperature measurment sampling
 *        0, 1, 2, 4, 8, 16
 * @param f Frequency Item Name
 */
void BME280_setTemp(int f);

/**
 * @brief Set Humidity measurement sampling
 *        0, 1, 2, 4, 8, 16
 * @param f Frquency Item Name
 */
void BME280_setHumidity(int f);

/**
 * @brief Get Pressure in pascals
 * 
 * @return Pascal value
 */
int BME280_getPressure(void);

/**
 * @brief Get Temperature in celius
 * 
 * @return celius temperature
 */
int BME280_getTemp(void);

/**
 * @brief Get Humidity in percent times 100
 * 
 * @return Percent humidity time 100
 */
int BME280_getHumidity(void);

/**
 * @brief Get Temperature in Fahrenheit
 * 
 * @return Temperature in Fahrenheit time 100
 */
int BME280_getTempF(void);

/**
 * @brief Get Pressure in inch of mercury
 * 
 * @return inches of mercury time 100
 */
int BME280_getPressureM(void);

#ifdef DODOUBLE

float BME280_getTemperature(void);

float BME280_getPressuref(void);

float BME280_getHumidityf(void);

#endif
