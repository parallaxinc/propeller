For discussions:
https://forums.parallax.com/discussion/173278/display-driver-architecture#latest

Currently no more documentation, so have a look into Display_Demo.spin2. The usage is pretty much self explaining. All the interna will be documented later.

Changelog:
* [11.04.2021]
  * Now the color that is passed to the Graphics functions has 8R8G8B format and is converted to device format in the pixel functions.
  * That made a bug visible, hidden in pasmSMC.spin2. Update the relative address for COG variables did only work for the first instruction so far ;o)
  * The calculation of the adress for accessing the font data was only working for 8x8 fonts and has been fixed.
