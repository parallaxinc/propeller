# SNES Mouse and Gamepad Driver

By: Ada Gottensträter

Language: Spin

Created: Oct 24, 2020

Well, here's a driver that handles SNES mice (and normal gamepads, too). It's mostly compatible with the PS/2 driver that you get with PropTool, but it has some extra features:

* Read two game pads OR a mouse and a gamepad
* Run it in a cog or call a function to poll it, saving a cog
* Set mouse speed/sensitivity
* smaller than the PS/2 driver
