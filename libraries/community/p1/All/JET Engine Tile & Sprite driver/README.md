# JET Engine Tile & Sprite driver

By: Ada Gottensträter

Language: Assembly

Created: Oct 4, 2018

Modified: October 5, 2018

Somewhat of a work-in-progess: Stable and functional, but with room for improvement.

This is a game graphics driver with NTSC and PAL60 output.

Short overview of features:

*   256x224 resolution
*   uses 5 cogs and a bunch of memory
*   16x16 tiles and sprites
*   32 sprites on screen, 8 per scanline
*   4 colors per scanline per sprite/tile
*   8-way scrolling
*   full-screen post-"processing"
*   Antialiased ROM font text
*   Screen can be split into horizontal strips - "subscreens" for status displays, parallax (heh) scrolling and more

For more detailed info, look at the scrolltext in demo.spin, aswell as just the code itself. I tried documenting the PASM rendering code as well as possible: most lines have a comment explaining what they do!  
  
NEW: JETViewer, a solution for capturing screenshots and videos of JET Engine running over serial.
