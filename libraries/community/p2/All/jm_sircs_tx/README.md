# Sony IRCS Tx (infrared control system transmitter)

By: Jon "JonnyMac" McPhalen

Language: Spin2

Created: 22-JUL-2020

Category: protocol, signals

Description:
This object takes advantage of the P2 smart pins to modulate an IR LED using the Sony IRCS command protocol. Output can be inline (blocking) or run in the background if a spare cog is available. The tx() method allows the program to define the code, the number of bits for that code (usually 12, 15, or 20), and the number of times to repeat the code (at typical TV remote will repeat a code three to five times).

License: MIT (see end of source code)
