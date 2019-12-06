# Winbond Flash and Microchip SRAM Driver

By: Michael Green

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

This is a driver for Winbond Flash Memory (W25X16AVDAIZ 2MB) as well as equivalent 1MB, 4MB and 8MB memories. It also supports 1 or 2 Microchip 23K256 SPI SRAM. It provides a simple file system with 8.3 named files and basic wear levelling through distributing files across the memory. Multiple files can be open at the same time.

Included is a version of FemtoBasic for a VGA display that uses this driver for its file I/O and includes access to the low-level flash and the SRAM routines.

Included is a version specifically for the Parallax C3 board. The initialization method (.start) is slightly different because of the way the C3 selects SPI devices. There's a method included for reading the C3's ADC.
