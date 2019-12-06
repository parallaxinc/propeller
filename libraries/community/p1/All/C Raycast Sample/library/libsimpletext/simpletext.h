/**
 * @file simpletext.h
 *
 * @author Steve Denson
 *
 * @copyright
 * Copyright (C) Parallax, Inc. 2014. All Rights MIT Licensed.
 *
 * @brief This library provides a collection of functions for communicating
 * with text devices such as SimpleIDE Terminal, serial peripheral devices,
 * and even VGA displays.  Libraries like serial, fdserial, and vgatext
 * return pointer/identifiers that can be used with this library's dprint, 
 * dscan, and write/read function parameters that have text_t types.  The
 * identifier allows the application's code to specify which connection to use
 * for sending and receiving formatted text. 
 * 
 * @details Features: 
 *
 * @li Generic IO devices support with reduced code size
 * @li Supports IO devices with rxChar/txChar functions.
 * @li Contains 2 built-in device drivers - fdserial and simpleserial.
 * @li Can get and print decimal, binary, float, hex, char, and string.
 * @li Supports print format values to buffer comparable to sprintf
 * (printBuffFormat and sprint).  
 * @li Supports format values from buffer comparable to sscanf
 * (scanBuffFormat and sscan).
 *
 * @par Core Usage 
 * Functions in this library do not use any additional cores; however, the
 * device driver library that returns a text_t pointer for use with this 
 * library might.  For example, fdserial and vgatext each take launch a core.
 * Check the device driver library's documentation for details.  
 *
 * @par Memory Models
 * Use with CMM, LMM, or XMMC. 
 *
 * @version 0.98 Digits versions of put/get and write/read added for
 * transmitting and receiving values with fixed numbers of digits.  Floating
 * point output functions updated to handle nan (not a number) and +/- inf
 * (infinity).  printi, dprinti, scani, dscani, sprinti, sscani functions
 * added for supporting non-floating point with less program space. 
 * functions with Len in their names added for transmitting strings and
 * values represented with a fixed number of characters.
 */
 
#ifndef __SimpleTEXT__
#define __SimpleTEXT__

#include <propeller.h>

#ifdef __cplusplus
extern "C"
{
#endif

#if !defined(__PROPELLER_32BIT_DOUBLES__)
#error "This library requires 32bit doubles"
#endif

#define TERM_NAME_LEN 20
#define TERM_COG_LEN  7

typedef struct text_struct
{
  int  (*rxChar)(struct text_struct *p);         // Required for terminal
  int  (*txChar)(struct text_struct *p, int ch); // required for terminal
  int  cogid[TERM_COG_LEN];                      // Pointer to cog(s)  
  volatile void *devst;                          // Device info struct pointer
} text_t;

#define getStopCOGID(id) ((id)-(1))
#define setStopCOGID(id) ((id)+(1))

/**
 * By default the terminal will use simple serial for input/output
 * It can be overloaded.
 */
#include "serial.h"

/* Values for use with SimpleIDE Terminal */
#ifndef HOME
/**
 * @brief HOME character (1) sends SimpleIDE Terminal's cursor to top-left
 * "home" position.
 */
#define HOME   (1)
#endif

#ifndef CRSRXY
/**
 * @brief CRSRXY character (2) sends cursor to a certain number of spaces
 * over (X) and returns (Y) down from SimpleIDE Terminal's top-left HOME
 * position.  This character has to be followed immediately by the X and Y
 * values when transmitted to the SimpleIDE Terminal. 
 */
#define CRSRXY (2)
#endif

#ifndef CRSRLF
/**
 * @brief CRSRLF character (3) sends the SimpleIDE Terminal's cursor one
 * column (space) to the left of its current position.
 */
#define CRSRLF (3)
#endif

#ifndef CRSRRT
/**
 * @brief CRSRRT character (4) sends the SimpleIDE Terminal's cursor one
 * column (space) to the right of its current position.
 */
#define CRSRRT (4)
#endif

#ifndef CRSRUP
/**
 * @brief CRSRUP character (5) sends the SimpleIDE Terminal's cursor one row 
 * (carriage return) upward from its current position.
 */
#define CRSRUP (5)
#endif

#ifndef CRSRDN
/**
 * @brief CRSRDN character (6) sends the SimpleIDE Terminal's cursor one row 
 * (carriage return) downward from its current position.
 */
#define CRSRDN (6)
#endif

#ifndef BEEP
/**
 * @brief BEEP character (7) makes the system speaker in some computers beep 
 * when received by SimpleIDE Terminal.
 */
#define BEEP   (7)
#endif

#ifndef BKSP
/**
 * @brief BKSP character (8) sends the SimpleIDE Terminal's cursor one column 
 * (space) to the left of its current position and erases whatever character 
 * was there.
 */
#define BKSP   (8)
#endif

#ifndef TAB
/**
 * @brief TAB character (9) advances the cursor to the right by a tab's worth 
 * of spaces.  
 */
#define TAB    (9)
#endif

#ifndef NL
/**
 * @brief NL character (10) sends the SimpleIDE Terminal's cursor to the
 * leftmost character in the next line down.
 */
#define NL     (10)
#endif

#ifndef LF
/**
 * @brief LF is same as NL.
 */
#define LF     (10)
#endif

#ifndef CLREOL
/**
 * @brief CLREOL character (11) erases all SimpleIDE Terminal characters to
 * the right of the cursor.
 */
#define CLREOL (11)
#endif

#ifndef CLRDN
/**
 * @brief CLRDN character (12) erases all SimpleIDE Terminal characters
 * below the cursor.
 */
#define CLRDN  (12)
#endif

#ifndef CR
/**
 * @brief CR character (13) sends SimpleIDE Terminal's cursor one row
 * downward.
 */
#define CR     (13)
#endif

#ifndef CRSRX
/**
 * @brief CRSRX character (14) positions SimpleIDE Terminal's cursor X
 * characters from the its left edge.
 */
#define CRSRX  (14)
#endif

#ifndef CRSRY
/**
 * @brief CRSRY character (15) sends SimpleIDE Terminal's cursor Y rows to
 * the from its top edge.  
 */
#define CRSRY  (15)
#endif

#ifndef CLS
/**
 * @brief CLS character (16) clears SimpleIDE's screen, erasing all
 * characters and lacing the cursor in the top-left corner.
 */
#define CLS    (16)
#endif


typedef text_t terminal;

 
/**
 * @brief Print format "..." args to the default simple terminal device.
 * The output is limited to 256 bytes.
 *
 * @details Format specifiers for print dprint, and sprint:
 *
 * %%
 * Prints % sign to the output.
 *
 * %b
 * Prints binary representation of an int parameter.  
 * Note: %b is not an ANSI standard format specifier.
 *
 * %c
 * Prints char representation of a char parameter.
 *
 * %d
 * Prints decimal integer representation of an int parameter.
 *
 * %f
 * Prints floating point representation of a float parameter.
 *
 * %s
 * Prints string representation of a char* parameter.
 *
 * %u
 * Prints unsigned integer representation of an unsigned int parameter.
 *
 * %x
 * Prints hexadecimal integer representation of an int parameter.
 *
 * Width and precision %n.p cause n integer digits of a float to print, and
 * p digits to the right of the decimal to print.
 *
 * @param format C printf comparable format string.
 * 
 * @param ... Arguments to use with the format string.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int print(const char *format, ...) __attribute__((format (printf, 1, 2)));


/**
 * @brief Convert formatted simple terminal input to the "..." args.
 * The input is limited to 256 bytes.
 *
 * @details Format specifiers for scan, dscan, and sscan:
 *
 * - %%
 * Scan % sign to the input.
 *
 * - %b
 * Scans binary representation to the int parameter.
 * Note: %b is not an ANSI standard format specifier.
 *
 * - %c
 * Scans char representation to a char parameter.
 *
 * - %d
 * Scans integer representation to an int parameter.
 *
 * - %f
 * Scans floating point representation to a float parameter.
 *
 * - %s
 * Scans string representation to a char* parameter.
 *
 * - %u
 * Scans unsigned integer representation to an unsigned int parameter.
 *
 * - %x
 * Scans hexadecimal integer representation to the int parameter.
 *
 * Width and precision %n.p cause n integer digits to scan to the left
 * of the decimal point, p digits to the right.
 *
 * @param *fmt C printf comparable format string.
 * 
 * @param ... Arguments where output will go and must be pointers.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int scan(const char *fmt, ...) __attribute__((format (printf, 1, 2)));
 
 
/**
 * @brief Print format "..." args to the output buffer.
 * The output buffer *must be* big enough for the output.
 *
 * @note See print for format specifiers.
 *
 * @param buffer Pointer to memory where formatted output can be stored.
 * 
 * @param *format is a C printf comparable format string.
 * 
 * @param ... is the arguments to use with the format string.
 * 
 * @returns the number of bytes placed into the buffer.
 */
int sprint(char *buffer, const char *format, ...) __attribute__((format (printf, 2, 3)));


/**
 * @brief Convert formatted buffer to the "..." args.
 *
 * @note See scan for format specifiers.
 *
 * @param *buffer Pointer to memory where formatted output can be stored.
 *
 * @param *fmt C printf comparable format string.
 *
 * @param ... Arguments where output will go and must be pointers.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int sscan(const char *buffer, const char *fmt, ...) __attribute__((format (printf, 2, 3)));


/**
 * @name Print/Scan for Device Communication
 * @{
 */


/**
 * @brief Print format "..." args to the device
 * The output is limited to 256 bytes.
 *
 * @note See print for format specifiers.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param format C printf comparable format string.
 * 
 * @param ... Arguments to use with the format string.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int dprint(text_t* device, const char *format, ...) __attribute__((format (printf, 2, 3)));


/**
 * @brief Convert formatted device input to the "..." args.
 * The input is limited to 256 bytes.
 *
 * @note See scan for format specifiers.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param *fmt C printf comparable format string.
 * 
 * @param ... Arguments where output will go and must be pointers.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int dscan(text_t* device, const char *fmt, ...) __attribute__((format (printf, 2, 3)));


/**
 * @name Integer-Only Versions
 * For reduced program sizes if no floating point values are printed/scanned.
 * @{
 */


/**
 * @brief Print integer and char only format "..." args to the default simple 
 * terminal device.  This version does not support floating point.  The
 * output is limited to 256 bytes.
 *
 * @note See print for format specifiers except %f.
 *
 * @param format C printf comparable format string.
 * 
 * @param ... Arguments to use with the format string.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int printi(const char *format, ...) __attribute__((format (printf, 1, 2)));


/**
 * @brief Convert formatted simple terminal input to the "..." args.
 * This version does not provide floating point conversions.
 * The input is limited to 256 bytes.
 *
 * @note See scan for format specifiers.
 *
 * @param *fmt C printf comparable format string.
 * 
 * @param ... Arguments where output will go and must be pointers.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int scani(const char *fmt, ...) __attribute__((format (printf, 1, 2)));


/**
 * @brief Print integer and char only format "..." args to the default
 * simple terminal device.
 * This version does not support floating point.
 * The output is limited to 256 bytes.
 *
 * @note See print for format specifiers except %f.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param format C printf comparable format string.
 * 
 * @param ... Arguments to use with the format string.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int dprinti(text_t* device, const char *format, ...) __attribute__((format (printf, 2, 3)));


/**
 * @brief Convert formatted device input to the "..." args.
 * This version does not provide floating point conversions.
 * The input is limited to 256 bytes.
 *
 * @note See scan for format specifiers.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param *fmt C printf comparable format string.
 * 
 * @param ... Arguments where output will go and must be pointers.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int dscani(text_t* device, const char *fmt, ...) __attribute__((format (printf, 2, 3)));


/**
 * @brief Print integer and char only format "..." args to the default
 * simple terminal device.  This version does not support floating point.
 * The output is limited to 256 bytes.
 *
 * @note See print for format specifiers except %f.
 *
 * @param buffer Pointer to memory where formatted output can be stored.
 * 
 * @param *format C printf comparable format string.
 * 
 * @param ... Arguments to use with the format string.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int sprinti(char *buffer, const char *format, ...) __attribute__((format (printf, 2, 3)));


/**
 * @brief Convert formatted buffer to the "..." args.
 * This version does not provide floating point conversions.
 *
 * @note See scan for format specifiers.
 *
 * @param buffer Pointer to memory where formatted output can be stored.
 * 
 * @param format C printf comparable format string.
 * 
 * @param ... Arguments where output will go and must be pointers.
 * 
 * @returns Number of bytes placed into the buffer.
 */
int sscani(const char *buffer, const char *fmt, ...) __attribute__((format (printf, 2, 3)));

 
/**
 * @name Output to Terminal
 * @{
 */


/**
 * @brief Print a char to the debug port.
 * 
 * @param c Char to send. 
 */
void putChar(char c);


/**
 * @brief Print string to the debug port.
 * 
 * @param *str Null terminated string to send. 
 */
int  putStr(const char* str);


/**
 * @brief Print string representation of a decimal number to the debug port.
 *
 * @param value Number to print. 
 */
void putDec(int value);


/**
 * @brief Print string representation of a 32 bit floating point number to
 * the debug port.
 * 
 * @param value Number to print. 
 */
void putFloat(float value);


/**
 * @brief Print string representation of a binary number to the debug port.
 *
 * @param value Number to print. 
 */
void putBin(int value);


/**
 * @brief Print string representation of a hexadecimal number to the debug
 * port.
 * 
 * @param value Number to print. 
 */
void putHex(int value);


/**
 * @brief Send a string with a certain number of characters.
 * 
 * @param str Null terminated string to send. 
 * 
 * @param width Number of characters to print padded by spaces. 
 */
int  putStrLen(char* str, int width);


/**
 * @brief Print string representation of a decimal number to the debug port.
 *
 * @param value Number to print. 
 *
 * @param width Number of characters to print padded by zeroes. 
 */
void putDecLen(int value, int width);


/**
 * @brief Print string representation of a 32 bit floating point number to
 * the debug port with a fixed number of digits.
 * 
 * @param value Number to print. 
 *
 * @param width Number of characters to print. 
 * 
 * @param precision Number of decimal point digits to print. 
 */
void putFloatPrecision(float value, int width, int precision);


/**
 * @brief Print string representation of a binary number to debug port with
 * a fixed number of digits.
 *
 * @param value Number to print. 
 * 
 * @param digits Number of characters to print. 
 */
void putBinLen(int value, int digits);


/**
 * @brief Print string representation of a hexadecimal number to the debug
 * port with a fixed number of digits.
 *
 * @param value Number to print.
 * 
 * @param digits Number of hexadecimal characters to print padded by zeroes. 
 */
void putHexLen(int value, int digits);


/**
 * @brief Print string + new line on the transmit debug port.
 * 
 * @param *str Null terminated string to send. 
 */
int  putln(const char* str);


/**
 * @brief Print string + new line on the transmit debug port. This is an
 * alias of putln.
 * 
 * @param *str Null terminated string to send. 
 */
int  putLine(const char* str);


/**
 * @}
 *
 * @name Input from Terminal
 * @{
 */


/**
 * @brief Get binary number from the debug port.
 * 
 * @returns Value received.
 */
int  getBin(void);


/**
 * @brief Get char from the debug port.
 * 
 * @returns Character received as an integer.
 */
int  getChar(void);


/**
 * @brief Get decimal number from the debug port.
 * 
 * @returns Value received.
 */
int  getDec(void);


/**
 * @brief Get floating point number from the debug port.
 * 
 * @returns Value received.
 */
float getFloat(void);


/**
 * @brief Get hexadecimal number from the debug port.
 * 
 * @returns Value received.
 */
int  getHex(void);


/**
 * @brief Get string of chars from the debug port.
 * 
 * @param *buffer array of chars with enough elements to hold the input
 * string plus 2 null terminators.
 * 
 * @param max Maximum size to read and should be less or equal buffer size.
 *
 * @returns Pointer to string received.
 */
char *getStr(char *buffer, int max);

 
/**
 * @}
 *
 * @name Output to Device
 * @{
 */


/**
 * @brief Send a character to the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param c Character to send. 
 */
void  writeChar(text_t *device, char c);


/**
 * @brief Send a string to the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param str Null terminated string to send. 
 */
int  writeStr(text_t *device, char* str);


/**
 * @brief Print string representation of a decimal number to output.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param value Number to print. 
 */
void writeDec(text_t *device, int value);


/**
 * @brief Print string representation of a 32 bit floating point number to
 * device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param value Number to print. 
 */
void writeFloat(text_t *device, float value);


/**
 * @brief Print string representation of a binary number to the receive
 * device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param value Number to print. 
 */
void writeBin(text_t *device, int value);


/**
 * @brief Print string representation of a hexadecimal number to output
 * device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param value Number to print. 
 */
void writeHex(text_t *device, int value);


/**
 * @brief Send a string to the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param str Null terminated string to send. 
 * 
 * @param width Number of characters to print padded by spaces. 
 */
int  writeStrLen(text_t *device, char* str, int width);


/**
 * @brief Print string representation of a decimal number to output device 
 * with a fixed number of digits.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param value Number to print. 
 * 
 * @param width Number of characters to print padded by spaces. 
 */
void writeDecLen(text_t *device, int value, int width);


/**
 * @brief Print string representation of a 32 bit floating point number to
 * device with a certain number of decimal point digits.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param width Number of characters to print. 
 * 
 * @param precision Number of decimal point digits to print. 
 * 
 * @param value Number to print. 
 */
void writeFloatPrecision(text_t *device, float value, int width, int precision);


/**
 * @brief Print string representation of a binary number to output with a
 * fixed number of digits.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param value Number to print. 
 * 
 * @param digits Number of characters to print. 
 */
void writeBinLen(text_t *device, int value, int digits);


/**
 * @brief Print string representation of a hexadecimal number to output
 * device with a fixed number of digits.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param value Number to print. 
 * 
 * @param digits Number of hexadecimal characters to print. 
 */
void writeHexLen(text_t *device, int value, int digits);


/**
 * @brief Send a string + new line to the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param str Null terminated string to send. 
 */
int  writeLine(text_t *device, char* str);
 
 
/**
 * @}
 *
 * @name Input from Device
 * @{
 */


/**
 * @brief Get char from the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @returns character received as an int value.
 */
int  readChar(text_t *device);


/**
 * @brief Get string of chars from the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @param buffer Char array with enough elements to hold the input string.
 * 
 * @param max Maximum size to read and should be less or equal buffer size.
 * 
 * @returns string received.
 */
char *readStr(text_t *device, char *buffer, int max);


/**
 * @brief Get decimal number from the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @returns Number received.
 */
int  readDec(text_t *device);


/**
 * @brief Get floating point number from the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @returns Number received.
 */
float readFloat(text_t *device);


/**
 * @brief Get binary number from the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @returns Number received.
 */
int  readBin(text_t *device);


/**
 * @brief Get hexadecimal number from the device.
 * 
 * @param *device Connection identifier to  serial, fdserial, or other text_t
 * compatible device that has been opened.
 * 
 * @returns Number received.
 */
int  readHex(text_t *device);


/**
 * @}
 *
 * @name For Passing Terminal Control between Cogs
 * @{
 */
 
 
/**
 * @brief Reopens the SimpleIDE Terminal connection if it was closed
 * previously.  The SimpleIDE Terminal connection transmits on P30 and
 * receives on P31 at 115200 bps.  The port is a simple serial driver
 * running in the same cog, and does not buffer bytes.
 *
 * @returns 0 if port is already open, else returns term pointer.
 */
terminal *simpleterm_open(void);

/**
 * @brief Closes the SimpleIDE Terminal connection in one cog so that it can
 * be opened in another cog with simpleterm_open, fdserial_open(30, 31, 0,
 * 115200), or some other driver.
 */
void      simpleterm_close(void);

/**
 * @brief Gracefully closes and reopens simple terminal.
 *
 * @param rxpin Serial input pin, receives serial data.
 * 
 * @param txpin Serial output pin, transmits serial data.
 * 
 * @param mode Unused mode field (for FdSerial compatibility)
 * 
 * @param baudrate Bit value transmit rate, 9600, 115200, etc...
 *
 * @returns simpleterm pointer for use as an identifier for serial 
 * and simpletext library functions that have serial or text_t 
 * parameter types.  
 */
terminal *simpleterm_reopen(int rx, int tx, int mode, int baud);

/**
 * @brief Sets default debug port device. Make sure to open a connection to
 * the device before calling the function. This function may cause bad character
 * output in some cases. Please use the simpleterm_reopen() function instead.
 *
 * @param *ptr Device ID pointer to serial, fdserial, or other text_t device.
 */
static inline void simpleterm_set(text_t *ptr)
{
  extern text_t *dport_ptr;
  simpleterm_close();
  dport_ptr = ptr;
}

/**
 * @brief Get default device pointer to SimpleIDE Terminal.
 *
 * @returns terminal* Pointer to SimpleIDE Terminal device.
 */
terminal *simpleterm_pointer(void);

 
 /**
  * @}
  */

 
 /*  
  * @cond
  * API not intended for public use 
  */
int   printNumber(text_t *p, unsigned long u, int base, int width, int fill_char);
char* _safe_gets(text_t *term, char* origBuf, int count);
const char* _scanf_getf(const char *str, float* dst);
const char* _scanf_getl(const char *str, int* dst, int base, unsigned width, int isSigned);

int SPUTC(int c, char *buf);
int SPUTS(char *s, char *obuf);
int SPUTL(unsigned long u, int base, int width, int fill_char, char *obuf);

#include <stdarg.h>
int   _doscanf(const char* str, const char *fmt, va_list args);
int   _intscanf(const char* str, const char *fmt, va_list args);
int   _dosprnt(const char *fmt, va_list args, char *obuf);
int   _intsprnt(const char *fmt, va_list args, char *obuf);

char* float2string(float f, char *s, int width, int precision);
float string2float(char *s, char **end);

 /*  
  * @endcond
  * API not intended for public use 
  */

#ifdef __cplusplus
}
#endif

#endif
/* __SimpleTEXT__ */


/**
 * @par TERMS OF USE: MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
