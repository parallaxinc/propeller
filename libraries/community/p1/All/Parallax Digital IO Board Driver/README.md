# Parallax Digital I/O Board Driver

![thumbnail.gif](thumbnail.gif)

By: Michael duPlessis

Language: Spin

Created: Apr 12, 2013

Modified: May 20, 2013

This Program is used to shift Data in and out data of the Parallax Digital IO Board.

The Parallax Digital I/O Board makes use of two shift registers, namely the 74HC595 (Serial to Parallel) and the 74HC165 (Parallel to Serial) Shift registers. This program starts two cogs to handle shifting-out(SHiftOUT) and shifting-in(ShiftIN) data simultaneously.  
  
This is by no means the most optimised design and uses 6 I/O pins and 2 cogs to run. But on the upside it should be fast as data can be read and written at the same time.

Version 1.1 has a small fix to the output relays.  
In the previous version relay 8 would pickup if you shifted 1 into the register - now relay 1 will pick up.

Version 2.2 edited out some delays to speed things up.  
Remove the edits if you want to slow things down. It is easier seeing how things work when they go slower - feel free to play.
