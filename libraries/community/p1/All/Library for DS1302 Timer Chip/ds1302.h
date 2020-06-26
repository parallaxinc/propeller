/**
 * @file ds1302.h
 * @brief Clock Calender device
 * @author Michael Burmeister
 * @date January 14, 2017
 * @version 1.2
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
#define DS1302BURSTRD 0xBF
#define DS1302BURSTMM 0xFF

/**
 * @brief open connection to clock chip
 * @param mosi Master out slave in pin
 * @param cs Chip Select pin
 * @param sclk System Clock pin
 * @param miso Master in slave out pin
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
 *  returns the hours in 24 hour format
 *  or 12 hour format.  In 12 hour format use getAMPM
 *  to return a string with AM/PM value.
*/
short DS1302_getHours(void);

/**
 * @brief get am/pm string
 * @return ampm AM/PM string
 */
char *DS1302_getAMPM(void);

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
 * @brief Get year value 
 * @return year only last 2 digits
 */
short DS1302_getYear(void);

/**
 * @brief set Date 
 * @param year last two digits only
 * @param month
 * @param day
 */
void DS1302_setDate(short year, short month, short day);

/**
 * @brief set year
 * @param year only the last 2 digits of the year
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
 * @brief set day of the week
 * @param weekday number from 1-sunday, 7 - saturday
 */
void DS1302_setWeekDay(short weekday);

/**
 * @brief set time
 * @param hours
 * @param minutes
 * @param seconds
 *  hours are in 24 hour format
 */
void DS1302_setTime(short hours, short minutes, short seconds);

/**
 * @brief set hours
 * @param hour
 *  Must be in 24 hour format
 */
void DS1302_setHour(short hour);

/**
 * @brief set 12 hour format
 * @param hour in 12 hour format
 * @param AmPm use A for AM and P for PM
 */
void DS1302_set12Hour(short hour, char AmPm);

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

/**
 * @brief get write protect state
 * @return 0 - false 1 - true
 */
short DS1302_getWriteProtect(void);

/**
 * @brief set write protect state
 *  prevents any register from
 *  being written to
 */
void DS1302_setWriteProtect(void);

/**
 * @brief clear write protect state
 *  must be called before changing
 *  any date/time value or message
 */
void DS1302_clearWriteProtect(void);

/**
 * @brief set propeller date/time
 *  This sets the tick value for
 *  unix date time functions used
 *  in the propeller libraries and the
 *  time must be accessed before every
 *  54 seonds or time will be lost
 */
void DS1302_setDateTime(void);

/**
 * @brief save message in ram
 * @param msg
 *  Save a short message to 
 *  ram 31 bytes max
 */
void DS1302_setMessage(char *msg);

/**
 * @brief get message from ram
 * @return message
 */
char *DS1302_getMessage(void);
