/**
 * @file esp8266.h
 * @brief Connect to Parallax WX board
 * @author Michael Burmeister
 * @date April 4, 2019
 * @version 1.1
 * @mainpage Custom Libraries
 * <a href="esp8266_8h.html">ESP8266 Parallax WX WiFi Interface.</a><br>
*/
#include "fdserial.h"

#define HTTP 0xF7
#define WS 0xF6

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
int esp8266_connect(char *url, short port);

/**
 * @brief send request data
 * @param handle
 * @param request
 * @return status
 */
int esp8266_send(char handle, char *request);

/**
 * @brief send http request
 * @param handle
 * @param request
 * @param opt option 0 - close, 1 - keep alive
 * @return status
 */
int esp8266_http(char handle, char *request, short opt);

/**
 * @brief send binary data
 * @param handle connection handle
 * @param data binary data to send
 * @param size length of binary data
 * @return status
 */
int esp8266_sendbin(char handle, unsigned char *data, short size);

/**
 * @brief receive request data
 * @param handle
 * @param *data
 * @param size buffer size < 2048
 * @return error
 */
int esp8266_recv(char handle, char *data, int size);

/**
 * @brief open UDP connection
 * @param url host or address to use
 * @param port remote port number to use
 * @return status
 */
int esp8266_udp(char *url, short port);

/**
 * @brief close handle
 * @param handle
 */
void esp8266_close(char handle);

/**
 * @brief join network router
 * @param ssd router name
 * @param pwd password for router
 * @return statue
 */
int esp8266_join(char *ssd, char *pwd);

/**
 * @brief set environment value
 * @param env environment item
 * @param value environment value string
 * @return status
 */
int esp8266_set(char *env, char *value);

/**
 * @brief get environment value
 * @param env environment item
 * @return environment value
 */
char *esp8266_check(char *env);

/**
 * @brief poll connection status
 * @param handle connection handle
 * @return status
 */
int esp8266_poll(char handle);

/**
 * @brief set listen uri
 * @param protocal 
 * @param uri to listen for /
 */
int esp8266_listen(char protocal, char *uri);

/**
 * @brief drop WiFi station connection
 */
int esp8266_drop(void);

/**
 * @brief get return value
 * @return results
 */
int esp8266_results(void);

/**
 * @brief special print
 * @param *data
 * @param size total size of data
 */
void esp8266_print(char *data, int size);
