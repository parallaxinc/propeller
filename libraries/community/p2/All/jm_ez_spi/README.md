# EZ SPI

By: Jon "JonnyMac" McPhalen

Language: Spin2

Created: 01-SEP-2020

Category: protocol

Description:
This object enables Mode 0 SPI communications using P2 smart pins. This allows for high-speed SPI without needing PASM2 code. The object includes methods for shifting out, shifting in, and full-duplex shifting of output and input data. LSBFIRST and MSBFIRST bit order modes are supported.

A short program connects to the P2 flash memory to demonstrate shiftout() and shiftin() at 10MHz using Spin2 code.

License: MIT (see end of source code)
