# Light Dimmer / Triac Driver

By: DDS

Language: Spin, Assembly

Created: Apr 10, 2013

Modified: April 10, 2013

This is a small driver for controlling / making a Triac based light dimmer. Nothing exceptional but it works and is easy to work with - 1 variable. It uses the zero crossing signal from an opto-isolator and then delays triggering the triac (also through an opto-isolator) until the proper amount of time has elapsed. Allows setting the brightness of a light (or other resistive load) from 0% to 100% in 256 steps. I have also included a small 120-Hz zero-crossing simulator object so you can either simulate the hardware signal during development or use it to dim LEDs or other Pulse Width Modulated devices not attached to a 60-Hz power line.
