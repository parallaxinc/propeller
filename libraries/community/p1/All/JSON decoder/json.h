/**
 * @file json.h
 * @brief Convert Json data to values
 * @author Michael Burmeister
 * @date December 29, 2018
 * @version 1.5
 * @mainpage Custom Libraries
 * <a href="json_8h.html">JSON Encoding and Decoding Data.</a><br>
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

/**
 * @brief put array of objects
 * @param item object array or NULL for end
 */
void json_putArray(char* item);

/**
 * @brief put object values
 * @param item object name NULL for end of object
 */
void json_putObject(char* item);

/**
 * @brief put more items
 */
void json_putMore(void);
