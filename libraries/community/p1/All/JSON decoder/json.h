/**
 * @file json.h
 * @brief Convert Json data to values
 * @author Michael Burmeister
 * @date December 29, 2018
 * @version 1.0
 * 
*/

/**
 * @brief init json converter
 * @param json data
 */
void json_init(char *json);

/**
 * @brief find element
 * @param element full name
 * @return string value
 */
char *json_find(char *element);

/**
 * @brief put string element and value
 * @param item Item name
 * @param value Item value
 */
void json_putStr(char *item, char *value);

/**
 * @brief put integer value
 * @param item Item name
 * @param value decimal value
 */
void json_putDec(char *item, char *value);
