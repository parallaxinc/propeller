# uLCD(SK)-32PTU Touch Screen v2.0 DEMO Driver

By: Parallax Inc

Language: Spin

Created: Jan 22, 2015

Modified: January 22, 2015

General info:

This is a simple/small driver for the uLCD(SK)-32PTU. This driver uses the common Parallax serial terminal as it's main  
communication system. This LCD is a good choice for many reasons and seems to have a little bit of everything. It can  
draw boxes, lines, triangles, and is equipped with a built in speaker, not to mention it has a touch screen that is super  
easy to interact with.  It can display text and graphics and makes it relatively easy to understand. It is capable of 65  
thousand colors in two bytes and has a resolution of 320x240 pixels. It also uses a reliable communication system.

\*\*\*\* For Display Configuration information: \*\*\*\*

Please refer to Section 2.1 of the "PICASO Serial Command Set Reference Manual" PDF. Also visit the Youtube video: http://www.youtube.com/watch?v=ZIlAoABmQ0w

*   **Note**, this PDF is no longer included in the download.  Please download the latest version from http://www.4dsystems.com.au/productpages/PICASO/downloads/PICASO\_serialcmdmanual\_R\_1\_18.pdf,
*   or go to www.4dsystems.com.au/ and search for "PICASO Serial Command Set Reference Manual".

\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

Revision History:  uLCD(SK)-32PTU --> migrated from uOLED-128-G2 display

*   10-05-2013
    *   \- first release
*   10-25-2013  v1.0
    *   \- added functions that were undocumented in original GOLDELOX-SPE-COMMAND-SET-REV1.3 datasheet
    *   \- changed constant naming to reflect PICASO-GFX2-4DGL-Internal-Functions-rev3  datasheet
*   11-06-2013  v2.0
    *   \- modified display commands for the uLCD(SK)-32PTU display
    *   \* known issues:
        *   \- file mounting problems with some SD cards affecting other file related commands
        *   \- media operations mounting the SD card seem to be ok, but are not fully tested
