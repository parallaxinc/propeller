# LCD Debug Cog

![debugthumb.jpg](debugthumb.jpg)

By: Brandon Nimon

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

LCD Debug Cog:

  
This object can be used as a drop-in replacement for the Debug\_Lcd object. It uses a cog to control the LCD, thus freeing the source cog of the wait time required to display information on the LCD. The only method that is missing is the custom method which allowed custom character maps. An added method: cr, it is used for carriage return (same as putc($0D) or putc(13)).  
Version 1.1 uses a queue system to allow for up to four commands to be sent in short succession without great delay (only a few cycles each to set variables). The commands will be executed in order by the debug cog. If a fifth command is given before the first has completed the source cog will have to wait until the fourth position is made available (and so on).

In Debug\_Cog Demo, the Demo can be executed with Debug\_Lcd in 2,363,072 cycles, Debug\_Cog V1.0 took 1,472,048 cycles, but version 1.1 took only 45,552 cycles!
