# FemtoBasic

By: Michael Green

Language: Spin, Assembly

Created: Apr 10, 2007

Modified: May 2, 2013

FemtoBasic is a simple Basic interpreter for the Propeller. It supports a keyboard and either a VGA or TV display as well as an optional SD card with PC compatible FAT file system. It runs on the Propeller Demo Board, Protoboard, and Hydra. On the Hydra, the VGA version doesn't work with the SD card because the I/O pins involved conflict. An extended version with support for the IR Buddy is included as an example of extending the interpreter. Fix: SD card turned off when unmounted (thanks Cluso99). Changes: IR Buddy no longer supported. fsrwFemto updated to 2.6 (thanks Rokicki) so it supports FAT32. Documentation for KEYCODE corrected.
