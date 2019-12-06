# led_pwm

By: Colin Fox

Language: Spin, Assembly

Created: Apr 10, 2013

Modified: April 10, 2013

led\_pwm is a PWM driver for up to 32 leds, written in prop assembly. It supports optional automatic decay, and 64 brightness levels for the LEDs.

The pwm is done entirely in software, and allows for efficient control of all 32 leds from a single cog. 32 longs are used as control values, and may be updated in realtime by a spin program. These values are read by the assembly language pwm driver and applied to each LED.
