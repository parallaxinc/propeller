For discussions:
https://forums.parallax.com/discussion/173278/display-driver-architecture#latest

Currently no more documentation, so have a look into Display_Demo.spin2. The usage is pretty much self explaining. All the interna will be documented later.

Changelog:
* [16.04.2021]
  * "Display driver" for a debug windown has been added. This way the screen buffer, created with a compatible real hardware driver, can be sent to a "Emulate Display" debug window. Compatible means that the color encoding and the resolution has to be the same, as in the debug display driver.
  * Function circle has been converted to PASM2
  * Function for converting a 24RGB Bitmap file into screen-buffer has been added and converted to PASM2
  
* [11.04.2021]
  * Now the color that is passed to the Graphics functions has 8R8G8B format and is converted to device format in the pixel functions.
  * That previous change made a bug visible, hidden in pasmSMC.spin2. Update the relative address for COG variables did only work for the first instruction so far ;o)
  * The calculation of the adress for accessing the font data was only working for 8x8 fonts and has been fixed.
