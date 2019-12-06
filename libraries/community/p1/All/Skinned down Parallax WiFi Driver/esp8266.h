/**
 * @file esp8266.h
 * @brief Connect to Parallax WX board
 * @author Michael Burmeister
 * @date April 4, 2019
 * @version 1.0
 * 
*/
#include "fdserial.h"
#include "timer.h"

/**
 * @brief open connection to esp8266 board
 * @param rx recieve pin
 * @param tx transmit pin
 */
fdserial *esp8266_open(int rx, int tx);

/**
 * @brief open connection to url and port
 * @param url website
 * @param port usually 80
 * @return handle or negative
 */
int esp8266_connect(char *url, char port);

/**
 * @brief send request data
 * @param handle
 * @param request
 * @param opt option close/leave connection open
 * @return status
 */
int esp8266_send(char handle, char *request, short opt);

/**
 * @brief receive request data
 * @param handle
 * @param *data
 * @return error
 */
int esp8266_recv(char handle, char *data);

/**
 * @brief close handle
 * @param handle
 */
void esp8266_close(char handle);

/**
 * @brief get return value
 * @return results
 */
int esp8266_results(void);

/**
 * @brief special print
 * @param *data
 */
void esp8266_print(char *data);
