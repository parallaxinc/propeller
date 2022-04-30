# Graphics Display Driver Architecture

By: MagIO2

Language: Spin2 & PASM2

Created: 10-APR-2021

Category: display

Description:
Graphic Display Drivers

Currently it covers some functionality I'd call a 0.6 version ;o) But it is already usable for projects.
Key features:
  * Hardware drivers for 3 kind of displays
    * 1.3inch 240x240 16 bit color LCD display from Waveshare with a ST7789 driver
    * 1.14inch 240x135 16 bit color LCD display from Waveshare with a ST7789 driver
    * 1.5inch 128x128 16 grayscale OLED display from Waveshare with a SSD1327 driver
    * of course chances are good that other displays with the mentioned drivers work with little tweaks
    * template for creating your own driver ( please contribute )
    * debug "driver" allows to send the screen-buffer data to a Propeller Tool / PNut debug window
  * a device independent graphics lib with 
    * pixel
    * line
    * circle ( filled and unfilled )
    * box ( filled and unfilled )
    * text drawing ( with or without background color )
    * draw a 24bit BMP file to screen ( remember, RGB screens above are 16bit with 5R6G5B color ) 
  * flexible code for different fonts at the same time, if needed (5 included so far)
  * exchanging the display means no code change needed (except the resolution also changes)

For discussions:
https://forums.parallax.com/discussion/173278/display-driver-architecture#latest

Currently no more documentation, so have a look into Display_Demo.spin2. The usage is pretty much self explaining. All the interna will be documented later.

Changelog:
* [22.04.2021]
  * Font_Header has been renamed to Font_Manager, because the font registration has been move out of Graphics.spin2 into there. That was necessary, because other objects also need to access font data. Does not make sense to register each font in each object that needs font data.
  * Same principle has been introduced to display drivers. There is now a Display_Manager, which helps to access data and functions of a display driver. So, now displays are used by the index used when adding them to the Display_Manager.
  * Currently under development: Desktop object and TextWindow object (might be coming soon)

* [16.04.2021]
  * "Display driver" for a debug windown has been added. This way the screen buffer, created with a compatible real hardware driver, can be sent to a "Emulate Display" debug window. Compatible means that the color encoding and the resolution has to be the same, as in the debug display driver.
  * Function circle has been converted to PASM2
  * Function for converting a 24RGB Bitmap file into screen-buffer has been added and converted to PASM2
  
* [11.04.2021]
  * Now the color that is passed to the Graphics functions has 8R8G8B format and is converted to device format in the pixel functions.
  * That previous change made a bug visible, hidden in pasmSMC.spin2. Update the relative address for COG variables did only work for the first instruction so far ;o)
  * The calculation of the adress for accessing the font data was only working for 8x8 fonts and has been fixed.
