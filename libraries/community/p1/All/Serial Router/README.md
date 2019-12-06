# Serial Router

By: m.k. borri

Language: Spin, Assembly

Created: Apr 16, 2013

Modified: April 16, 2013

Assumptions -- @ is delimiter char, <cr> is end of packet char / begin buffering next packet char. Max packet length is 256 bytes if you want more there's room :)

Router checks the first 4 bytes of a packet: if they match the regexpr, it's an address, if not send the packet to the default destination for that port. regexpr is delimiter, digit, digit, delimiter. (So port 0 must be addressed as @00@, @0@ is invalid).

Ports 00 to 11 are device ports. Max baud rate is 57600. OK to have fewer than 11 port, frees up cogs & hardware pins.

Port 12 is the terminal port. Max baud rate is 230400.

Port 13 is the router itself and commands can be sent to it.

Port 14 is the remaining cogs on the Propeller chip and can be addressed as a separate device, if some hardware pins aren't used, this acts as an extra microcontroller that can be used to read ADCs, control motors and what not. 2 cogs are currently free (if using all serial ports).

Examples:

If device 4 sends Hello\_There to device 0, it would do so like this:

@00@Hello\_There<cr>

Device 0 would receive this:

@04@Hello\_There@<cr>

If logging is set, the terminal would receive @04>00@<cr> (logging set to 1) or @04>00@Hello\_There@<cr> (logging set to 2)

Adding 50 to the port address (so @50@ to @64@ ) sends out the packet "stealthily", that is, without the origin address prefix. So if any device sends  
@00@Boo!<cr>  
then device 0 would receive  
Boo!<cr>

In addition, if a device sends out a packet without address  
information, it will be delivered to that device's default  
destination.

These two things + a bit of configuration from the terminal allow using devices that cannot be made aware of the addressing protocol at all (such as GPSs).

The router at the moment only executes two commands, as follows:

R:n  
Reboot, N can be any number.

L:x  
Sets logging level to terminal to 0, 1 or 2.

D:xx>yy  
Sets default destination for port xx to port yy. OK to use stealthing with yy (it will do nothing if used with xx). Thus the terminal can decide what talks to what in realtime.

There is ample room to make the microcontroller do other things if desired :) Interfacing given our components is done thru resistors since signal inversion can be defined in software. Baud rates are NOT limited to standard bauds (so a baudrate of say 24000 is fine).

This was done for the PhoneSat group at NASA-AMES if anyone cares, so it will into space in a few months :)

UPDATE: Uses improved serial objects from http://forums.parallax.com/showthread.php?129714-Tim-Moore-s-pcFullDuplexSerial4FC-with-larger-(512-byte)-rx-buffer
