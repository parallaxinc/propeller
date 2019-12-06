# RX input / RC Receiver Input

By: W9GFO

Language: Spin

Created: Jul 15, 2009

Modified: May 2, 2013

This object uses counters to monitor 6 pins for RC inputs. In the demo, pins 1 - 6 are connected to a Radio Control receiver or other device which outputs servo signals. The pulse widths for each channel are displayed on an LCD and the signals are output on pins 7 - 12 using the Servo32v6 object.

It does not matter which order the pins are hooked up. It also does not matter if all the pins are connected. It will work with any or all of the pins connected.

A check is performed at startup to determine which pins are active. Make sure that there is a valid servo signal before powering up.

More pins can be monitored by launching additional cogs - 2 pins per cog.

*   Updated to remove the (+ 3) that was added to counters as it turns out it is not needed.
*   Updated to use the Servo32v6 object.
*   Updated to go back to a slightly modified Servo32v5 until Servo32v6 is working right.
*   Updated to use the new Servo32v6 AND an updated LCD driver
