# GPS Float Lite Demo

By: I.Kövesdi

Language: Spin

Created: Apr 9, 2013

Modified: April 9, 2013

This Parallax Serial Terminal (PST) demo application introduces the 'GPS\_Str\_NMEA\_Lite.spin v1.0' and the 'GPS\_Float\_Lite.spin v1.0' driver objects. 

The 'GPS\_Str\_NMEA\_Lite' driver interfaces the Propeller to a GPS receiver. This NMEA-0183 parser captures and decodes RMC and GGA type sentences of the GPS Talker device in a robust way.

The 'GPS\_Float' driver object bridges a SPIN program to the strings and longs provided by the basic 'GPS\_Str\_NMEA\_Lite' driver and translates them into long and float values and checks errors wherever appropriate. 

These 2 'Lite' objects have standard version at Obex, too.
