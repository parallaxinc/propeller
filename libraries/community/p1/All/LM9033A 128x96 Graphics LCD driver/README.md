# LM9033A 128x96 Graphics LCD driver

By: Timothy D. Swieter

Language: Spin, Assembly

Created: Apr 10, 2013

Modified: April 10, 2013

This is a demo program (0.1) and driver (0.2) for the Brilldea LM9033A Graphics LCD. This driver is an ASM driver requiring one cog. This driver reads "video memory" of the hub ram for the data to be displayed. The "video memory" is drawn in by the Parallax graphics.spin driver.

This driver is a good example of structuring an ASM routine for a task oriented approach. That is, the ASM routine waits for a task to be given to it such as updating the display or changing the contrast. This driver uses the 4-wire SPI interface.
