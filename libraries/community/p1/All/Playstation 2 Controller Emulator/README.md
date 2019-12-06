# Playstation 2 Controller Emulator

By: Micah Dowty

Language: Spin, Assembly

Created: Apr 12, 2013

Modified: April 12, 2013

This object emulates a Playstation 2 Dual Shock controller. Run five wires between the Propeller and a Playstation or Playstation 2 console, and the Propeller can impersonate a controller. Use this module to experiment with new or non-traditional video game controllers, or to create applications that sit between a Playstation system and your controllers. It supports all the features of the Dual Shock controller, including force feedback and pressure-sensitive buttons.

This object was written for the Unicone2 project, a controller emulator which forwards Playstation controller data over long lengths of cat-5 cable. Further description of the Unicone2 as well as full source code is available:  
http://scanwidget.livejournal.com/26815.html

This object starts a dedicated Cog to manage controller emulation. You supply one or several buffers for outgoing controller state (buttons, axes, pressure sensors) and incoming force-feedback data. To use this module successfully, you'll need to know at least the basics of the Playstation controller's packet format. This is documented in several places on the internet.
