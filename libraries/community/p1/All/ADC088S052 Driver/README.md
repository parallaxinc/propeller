# ADC088S052 Driver

By: Cannibal Robot

Language: Spin

Created: Oct 17, 2008

Modified: June 17, 2013

This cog free runs sampling all 8 A to D channels sequentially. The ADC088S052 is a good choice to work with the Prop as it uses a 3.3v supply. For circuit simplicity Va,Vd can be tied directly to 3.3v and Agnd & Dgnd tied to ground if pot references are the same. This eliminates the need for reference voltage sources.

_NOTE: This implementation runs below the rated minimum speed for this ADC but in robotic applications sensing pot positions and joystick movement, no problems have been encountered._
