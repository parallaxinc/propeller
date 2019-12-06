# ILI9325 320x240 TFT driver

By: MarkT

Language: Spin, Assembly

Created: Apr 9, 2013

Modified: April 9, 2013

ILI9325 320x240 TFT driver with simple graphics support (dot/line/rect/characters).

See demo vid at http://www.youtube.com/watch?v=zTDWFc4P4io

XPT2046 touchscreen controller chip support added.

Supports 8-bit parallel mode for the ILI9325 as on various cheap 2.4" TFT displays available on eBay. My example is labelled "2.4TFT haixiang00" and includes a XPT2046 resistive touchscreen controller too.

Slight variation on 9320 driver - auto-sensing the driver chip is specifically not provided as some modules are write-only
