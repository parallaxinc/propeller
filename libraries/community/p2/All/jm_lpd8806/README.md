# LPD8806 "Smart" Pixel Driver

By: Jon "JonnyMac" McPhalen

Language: Spin2, PASM2

Created: 26-NOV-2020

Category: display

Description:
This object allows the P2 to control LPD880x pixels. The output is auto-updating which allows the programmer to manually manipulate the color buffer for advanced applications. Standard interface methods for setting pixels to specific colors are included.

Note: The LPD880x vendor does not publish a protocol specification for these pixels. This code is based on work done by others -- some of whom have reverse-engineered the protocol from LPD880x-compatible controllers.

License: MIT (see end of source code)
