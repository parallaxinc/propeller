# uPD161704A TFT driver, 8bit parallel

By: MarkT

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

Companion to SPI driver for this LCD controller - as featured on Waveshares 2.2" TFT modules (cheap, ebay).

Note that the module comes configured for SPI/serial by default and some solder jumpers need to be reworked for 8-bit parallel (see legend on the board).

The 40pin connector is arranged so that one one row of 20 pins is needed for either serial or 8-bit parallel operation, which is convenient, but the touchscreen chip shares only with the serial row.
