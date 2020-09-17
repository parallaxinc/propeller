# ESP32

By: Riley August (riley@robots-everywhere.com)

Language: Spin2

Created: 17-SEP-2020

Category: protocol

Description:
This group of modular objects is designed to interface with an ESP32 microcontroller using a 2 pin serial UART. It is designed for the default ESP32 "AT firmware", by Espressif, which is the default on most modules.

Information on the AT commands can be found here: https://www.espressif.com/sites/default/files/documentation/esp32_at_instruction_set_and_examples_en.pdf. It is flashed by default on the majority of commercial ESP32 modules.

This is a modular spin2 object, not all of its functionality is contained within one file, so that you can save program memory and only use what you need. To use this object, import esp32_core to set up serial and interface with the ESP32. For wifi functionality, import esp32_wifi. For TCP/IP networking, import esp32_tcpip. For TCP server functionality, import esp32_tcpip_tl2_beta.

License: MIT (see end of source code)
