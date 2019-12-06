# ADB bridge beta (Also contains android and source)

By: m.k. borri

Language: Spin, Assembly

Created: Apr 2, 2011

Modified: June 17, 2013

Uses usb-fs-host, gives the Propeller MULTIPLE shells or TCP sockets into an Android phone.

The apk source is very basic in its behavior -- write to the Prop in the upper textbox, read from the Prop in the lower (using your favorite terminal app prop-side) and the button in the middle is to send and receive, no asynchronous message passing to avoid spamming logcat & making debugging easier. Prop side, you should hit enter to send a line (this will be used for NMEA packets mostly, so I want to do things line by line, but that's easy to change).

This is based off microbridge for the arduino+usb host shield http://code.google.com/p/microbridge/

Related videos:

http://www.youtube.com/watch?v=QcR0ZG\_7YC8

http://www.youtube.com/watch?v=PfSSPTtacnk&feature=channel\_video\_title

![res/drawable/icon.png](res/drawable/icon.png)
