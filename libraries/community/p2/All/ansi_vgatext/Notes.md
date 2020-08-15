# VGA TILE DRIVER

This is a simple VGA tile driver that supports standard ANSI escape
codes. It's still a work in progress.

- Revision 1.0: Re-factored and simplified for inclusion in the OBEX
- Revision 0.9: Ported to PNut
- Revision 0.8: Allow for 16 pixel wide fonts
- Revision 0.7: Added 2 byte/char and 1 byte/char modes
- Revision 0.6: Made C drivers work with riscvp2 and Catalina, and
added support for new hardware
- Revision 0.5: Made the text drivers more independent, created C and
BASIC demos
- Revision 0.4: Fixed a bug with vsync polarity
- Revision 0.3: Added 1028x768 support and polarity
- Revision 0.2: Started work on ANSI escape codes

## Files

vga_tile_driver.spin2 is the low level driver the drives the VGA. It takes most of its parameters (including the pins to use) in a parameter block that is passed in when it starts up. See below for details of this parameter block. Since the pin set to use is a parameter, you can launch multiple copies of the driver and output to multiple VGA monitors.

ansi.spin2 is the text driver. It sets up the VGA timing (based on constants in files like timing640x480.spin2) and font.


## Operation

Tiles must always be either 8 or 16 pixels wide. Theoretically they can be any height, but the demos use 16 pixels (15 for the 800x600, which is achieved by just ignoring the first row of an 8x16 font). There are some 8x8 fonts provided too, and a 16x32 font.

The character data is ROWS*COLS*CELL_SIZE bytes long. CELL_SIZE is the number of bytes each character takes, and may be either 1, 2, 4 or 8.  It is passed to the driver in the initial parameter mailbox.

For CELL_SIZE=8, each character takes 8 bytes in memory.  This consists of 24 bits foreground color, 8 bits of the actual character index, 24 bits of background color, and 8 unused bits (write 0's for these -- it matters!). This means that foreground and background colors are independent and may be any color at all.

For CELL_SIZE=4, the foreground and background colors are only 8 bits each, and index into a color palette. For now only the standard ANSI color palette is supported.

For CELL_SIZE=2, the foreground color is 4 bits, background color is 3 bits, and there is 1 bit for a blinking effect. The character is 8 bits. This is a standard VGA mode.

For CELL_SIZE=1 there is 1 bit for blinking and 7 bits for the character (so only the standard ASCII characters are supported).

## Demo

The Spin demo (demo.spin2) is an example of how to use the driver. This should work with either fastspin/flexgui or PNut.

There is also a FlexBasic demo (basdemo.bas).


## Internals

The actual driver is vga_tile_driver.spin2, which runs in its own COG.  It reads parameters from a mailbox, which has the following longs in order:

    starting pin for VGA
    character data address
    number of columns (e.g. 80 or 100)
    number of rows (e.g. 30 or 40)
    font data address
    width of font (must be 8 or 16)
    height of font
    clock scaling factor (see below)
    horizontal front porch, pixels
    horizontal sync time, pixels
    horizontal back porch, pixels
    vertical front porch, lines
    vertical sync time, lines
    vertical back porch, lines
    vertical/horizonal polarity (0 for both positive, 3 for both negative)
    cell size (8, 4, 2, or 1)
    
The clock scaling factor is the pixel clock divided by the system clock, and multiplied by $8000_0000. The system clock required depends on the pixel clock and the CELL_SIZE variable. The monochrome driver (CELL_SIZE==1) is the most efficient, requiring that the system clock be at least twice the pixel clock. The full color (CELL_SIZE==8) is next most efficient, it works for system clock >= 3 * pixel clock; the other cell sizes require system clock >= 4 * pixel clock. So for example to run at 1024x768 60Hz requires a 65 MHz pixel clock, which means a system clock of at least 130 MHz for monochrome, 195 MHz for full color, and 260 MHz for the other modes. 640x480 should work comfortably in pretty much all configurations, unless for some reason you have a very low system clock setting.

If you use a 16 pixel wide font, the timing requirements are reduced by half, so 260 MHz should work for all resolutions.

The driver works by reading a whole line of the font during blanking, then reading the individual character colors (and index). The colors are stuffed into the LUT, and the index is used to look up the font information in COG RAM, which is then output with an immediate LUT streamer command. We ping-pong between two sets of LUT entries so we can change the color every pixel.


## Font

The font is an 8xN or 16xN bitmap, but it's laid out a bit differently from most fonts:

(1) The characters are all placed in one row in the bitmap; that is, byte 0 is the first row of character 0, byte 1 is the first row of character 1, and so on, until we get to byte 256 which is the second row of character 0. This is because we have to keep the data we need for all characters in COG memory, but we'll only ever need the data for one font row at a time. This data is read during the horizontal sync and blanking period.

(2) The rows are output bit 0 first, then bit 1, and so on, so the individual characters are "reversed" from how most fonts store them.  This is due to the way the streamer works in immediate mode.


## Credits

The VGA code itself is heavily based on earlier P2 work by Rayman and Cluso99, and of course Chip's original VGA driver.

The unscii font is from http://pelulamu.net/unscii/

The P1 font is from the Propeller1 ROM.
