# Wiznet W5100 SPI Driver

![W5100_1.jpg](W5100_1.jpg)

By: Timothy D. Swieter

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

An ASM driver for communicating with the Wiznet W5100 Ethernet IC using SPI. This driver launches a COG that handles FAST reading and writing to the W5100. There are routines in both ASM and SPIN for establishing communication and transferring data and settings.

See the file for further instructions on usage. Included in the Auxiliary files is a demo demonstrating how to use the driver. The Propeller will receive UDP frames and then echo the data back to the sender.

0.6 - Updated the file for various bugs pointed out to me in PM and on the forum. I also reviewed the tx/rx routines for UDP/TCP to be sure they were the same between the Indirect/Parallel code and the SPI code.

Please note that the most up-to-date code may be available via Google Code:

http://code.google.com/p/spinneret-web-server/

http://spinneret-web-server.googlecode.com/svn/trunk/W5100\_SPI\_Driver.spin
