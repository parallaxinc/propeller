# HD44780 Driver

By: Aaron Rudolph

Language: Spin, Assembly

Created: Apr 9, 2013

Modified: July 8, 2013

Finally, a driver for HD44780 LCD Displays written in Assembly. Limited as of now, but I plan to add more features soon. Currently, only writing of data and raw instructions to the display is supported.

This object uses one cog, and is more or less independent of the host program.

Thanks in advance for checking this out. It is my first (working) assembly program.

**\*UPDATE:** I fixed a bug regarding the printing of two consecutive strings. Now when you print two strings one right after another, they don't get jumbled up.
