# Multi Cog Fifo

By: Jacky2k

Language: Spin

Created: Mar 28, 2013

Modified: March 28, 2013

This is a spimple fifo, it is multi cog able.

Only one cog can read at the same time! The same for writing.  If two cogs will try to write at the same time data will be loss! The same problem with reading!  While a cog is reading an other one can write. You have to give this fifo a byte array with any size between 9 and 65535 bytes. With 9 bytes you will have 1 byte for data, this seems not to be very usefull :P

**Important update in version 0.2:**

The init function was splitted in InitNew and InitExisting. So InitNew will be called once, InitExisting can be called a lot of times.

**Version 0.1**

The Init function will reset the fifo, in version 0.2 it's possible to "jump in" the fifo, also if it's alreading in use!
