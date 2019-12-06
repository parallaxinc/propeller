# 1.8 MHz SPI Slave

By: Tom Crawford

Language: Assembly

Created: Mar 5, 2016

Modified: March 5, 2016

This PASM SPI Slave has been tested at 1.8 MHz.  Once started, it will look for a LOW on the chip select pin and will accumulate up to 32 bits.  When chip select goes HIGH, it will store the accumulated data and a bit count into hub memory.
