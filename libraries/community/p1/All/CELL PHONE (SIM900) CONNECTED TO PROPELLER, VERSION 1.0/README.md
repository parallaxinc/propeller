# CELL PHONE (SIM900) CONNECTED TO PROPELLER, VERSION 1.0

By: iceman

Language: Spin

Created: Feb 5, 2015

Modified: September 6, 2016

Please note........AT&T has notified me that effective 1/1/2017, they will no longer support G2 devices. The sim900 module is a G2 device.

I am working on updating the project to work with a G3 module. At this time, I have not decided which G3 module to use.

This object demonstrates how to connect a SIM900 GSM (cell phone) module to a Propeller, and operate them on the AT&T network. The object demonstrates Basic functionality and is intended as a starting point for those interested in adding Cell phone service to a propeller project. Included are two programs the first demonstrates basic functionality of the cell phone, the second sends a ‚Äúhello world‚Äù Text message. 

I have relied heavily on the previous excellent work done by Jay Kickliter and Massimo.

When the BASIC\_FUNCTIONS  program is run, it will demonstrate several ‚ÄúAT‚Äù commands and the responses from the SIM900 module. When the SEND\_TEXT program is run, it will send a text number to the phone number you have supplied.

This is the link to the breakout board fabricators web site. It describes how to connect The SIM900 in more detail. Pay particular attention to functions of the LEDS on the Breakout board.              http://www.geeetech.com/wiki/index.php/Arduino\_GPRS\_Shield

For a complete list of AT commands, here is the link:

http://www.simcom.us/act\_admin/supportfile/SIM900\_ATC\_V1.00.pdf

I am a perennial amateur at coding, if you discover any bugs or other issues, please pm me. 

**HARWARE REQUIREMENTS:**

A SIM900 module on a breakout and a Power supply (wallwart) 5VDC, rated at 350MA or greater A propeller Proto  board, I am using the proto board Parallax part number 32212, and a power supply. An AT&T sim card and an active account with text messaging.  Other carrier may work I have not tested them.

**  CAUTION CAUTION CAUTION**

The pinouts on the SIM900 breakout board shown may not be the same as those currently available
