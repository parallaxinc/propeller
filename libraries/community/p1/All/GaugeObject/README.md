# GaugeObject

By: Prophead100

Language: Spin, Assembly

Created: Apr 9, 2013

Modified: April 9, 2013

The Gauge Object provides a simple gauge face method for use with the Graphics Object by the top object. It handles some common overhead issues such as scaling, fitting within the screen, converting readings to degrees and uniform handling of colors. It uses default values but allows customization. The resulting bitmap can be displayed by the TV.SRC or VGA.SRC driver called by the top object. By using multiple copies of the object, many gauges can easily be drawn with minimum effort.

This Object was designed to be used with single or double buffered graphics memory with a minimum of gitter. There is plenty of room to refine and optimize the code for a particular application. For more detailed refinements that optimize each pixel, the programmer can copy/modify the methods and/or access the graphics routine directly. The "Numbers" Object can also be dropped by using predefined  
text instead doing conversions as was done by example for the scale ratio "t" using in TimesX Method.

If no other methods in the top object are using graphics then the programmer may chose to add the TV object to a version of this object by incorporating related code such as tile definitions and clock speeds into this object. It could also be run in automatic mode thus displaying readings independent of other actions if the user modifies it to launch in another cog with a repeat loop and pointer to the reading variables. For limited term use such as diagnostics, the ability to start and stop cogs would also allow a user to determine the need for video (e.g sense the video plug) and only use the resources to run the TV, Graphics and Gauge Objects when needed without recompiling or modifying the main code.
