# Dual Quadrature Encoder Driver

![encoder.gif](encoder.gif)

By: Kwabena W. Agyeman

Language: Spin, Assembly

Created: Apr 5, 2013

Modified: April 5, 2013

A dual quadrature encoder driver that runs in one cog. The code has been fully optimized with a super simple spin interface for maximum speed and is also fully commented.

Provides full support for:

*   The current encoder position delta in encoder ticks.
*   The current encoder speed in encoder ticks per second.

The encoder driver is written in assembly so that it can handle high RPM motors.

The sample period is about 4us. This allows a conservative 125,000 - (8us apart) encoder ticks per second per channel.
