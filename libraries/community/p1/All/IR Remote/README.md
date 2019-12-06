# IR Remote

By: Thomas Doyle

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

The IR\_Remote.spin object receives and decodes keycodes from a TV remote control. The procedure to read and decode is run in a separate cog. This eliminates the big problem of the mainline program hanging while waiting for a key to be pressed. When a keycode is received it is written into a variable in the address space of the calling cog.
