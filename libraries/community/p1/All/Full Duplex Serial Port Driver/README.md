# Full Duplex Serial Port Driver

![serial__.jpg](serial__.jpg)

By: Kwabena W. Agyeman

Language: Spin, Assembly

Created: Apr 9, 2013

Modified: May 20, 2013

A full duplex serial port driver that runs on one cog. The code has been fully optimized with a super simple spin interface for maximum speed and is also fully commented.

Provides full support for:

*   Receiving bytes,
*   Receiving words,
*   Receiving longs,
*   Receiving strings,
*   Transmitting bytes,
*   Transmitting words,
*   Transmitting longs,
*   Transmitting strings,
*   Getting the number of bytes in the RX buffer.
*   Getting the number of bytes in the TX buffer.
*   Checking if the RX buffer is empty or full.
*   Checking if the TX buffer is empty or full.
*   Flushing the RX buffer.
*   Filling the TX buffer.
*   Live baud rate changing.
*   Live stop bit changing.

Baud Rate from 1 BPS to 250,000 BPS @ 96 MHz - Full Duplex

This driver has a 256 byte receiving FIFO buffer.  
This driver has a 256 byte transmitting FIFO buffer.
