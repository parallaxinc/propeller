# FAT16 routines with secure digital card layer

By: Tomas Rokicki

Language: Spin, Assembly

Created: Mar 27, 2013

Modified: March 27, 2013

This contains the full set of code you need to read and write files to secure digital cards in a way that is compatible with your PC.

The primary source is at http://fsrw.sf.net/.

A FAT16/FAT32 filesystem layer is provided (no subdirectories or long file names right now).

Several different versions of secure digital block-level I/O are provided.

Read speed should be about 900KBytes/second and write speed should be around 1.8 MBytes/second (or faster or slower depending on the card).

In these routines emphasis has been on keeping the code as short as possible.
