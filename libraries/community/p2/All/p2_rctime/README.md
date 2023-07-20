# P2_rctime

By: phonoclese

Language: Spin2

Created: 19-JUL-2023

Category: human input, sensor

Description:
This object updates the rctime object from the P1 library for the P2 processor.

It uses a Smart pin configured with Schmitt trigger to count pin high states and generate an interrupt signal which launches an isr to save the clock count and then recharge the rc circuit.

The code remains resident in cog RAM and runs in the background using a small number of registers beginning at $1B0.

License: MIT
