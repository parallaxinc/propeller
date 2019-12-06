/**
 * @file ds1302.h
 * @brief Clock Calender device
 * @author Michael Burmeister
 * @date January 14, 2017
 * @version 1.0
 * 
*/

#define DS1302SECONDS 0x81
#define DS1302MINUTES 0x83
#define DS1302HOURS   0x85
#define DS1302DAY     0x87
#define DS1302MONTH   0x89
#define DS1302WEEKDAY 0x8B
#define DS1302YEAR    0x8D
#define DS1302WP      0x8F


/**
 * @brief open connection to clock
 * @param MOSI, CS, SCLK, MISO
 *
*/
void DS1302_open(short mosi, short cs, short sclk, short miso);

/**
 * @brief get seconds
 * @return seconds
 *
*/
short DS1302_getSeconds(void);

/**
 * @brief get minutes
 * @return minutes
*/
short DS1302_getMinutes(void);

/**
 * @brief get hours
 * @return seconds
*/
short DS1302_getHours(void);

/**
 * @brief get day
 * @return day
*/
short DS1302_getDay(void);

/**
 * @brief get month
 * @return month
*/
short DS1302_getMonth(void);

/**
 * @brief get day of the week
 * @return day
 */
short DS1302_getWeekDay(void);

/**
 * @brief get year
 * @return year
 */
short DS1302_getYear(void);

/**
 * @brief set year
 * @param year
 */
void DS1302_setYear(short year);

/**
 * @brief set month
 * @param month
 */
void DS1302_setMonth(short month);

/**
 * @brief set day
 * @param day
 */
void DS1302_setDay(short day);

/**
 * @brief set hour
 * @param hour
 */
void DS1302_setHour(short hour);

/**
 * @brief set minutes
 * @param minutes
 */
void DS1302_setMinute(short minutes);

/**
 * @brief set seconds
 * @param seconds
 */
void DS1302_setSecond(short seconds);

short DS1302_getWriteProtect(void);

void DS1302_setWriteProtect(void);

void DS1302_clearWriteProtect(void);
