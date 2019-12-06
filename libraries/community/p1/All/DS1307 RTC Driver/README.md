# DS1307 RTC Driver

![clock.jpg](clock.jpg)

By: Kwabena W. Agyeman

Language: Spin

Created: Apr 5, 2013

Modified: April 5, 2013

A DS1307 RTC driver. The code has been fully optimized with a super simple spin interface for maximum speed and is also fully commented.

Provides full support for:

*   Getting the Seconds, Minutes, Hours, Days, Date, Month, and Years, 
*   Setting the Seconds, Minutes, Hours, Days, Date, Month, and Years,
*   Reading the NVSRAM,
*   Writing the NVSRAM,
*   Turning the Squarewave generator on, 
*   Turning the Squarewave generator off,
*   Pausing Code execution for milliseconds,
*   Pausing Code execution for seconds,

Caches the time when the DS1307 RTC is accessed to prevent time desynchronization through multiple accesses to library.

Supports locking of the I2C bus to support multiprocessor access.
