''********************************************
''*           GPS Driver Demo v0.1           *
''*         By: Ryan David, 2/21/10          *
''*                                          *
''*    See GPSDriver file for more info      *
''********************************************

{-----------------REVISION HISTORY-----------------
 v0.1 - 2/23/2010, first official release.
}

CON
   
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  GPS_Rx        = 19            'Change these to reflect your setup
  GPS_Baud      = 115_200

OBJ
  GPS   : "GPSDriver"
  Debug : "FullDuplexSerial"

PUB Main | pointer
  Debug.start(31, 30, 0, 57_600)                        'Set up serial output to 57600 Baud
  pointer := GPS.start(GPS_Rx, 0, GPS_Baud)              'Start GPS Driver object
  waitcnt(clkfreq+cnt)

  repeat
    Debug.dec(long[pointer])                            'Echo course once a second
    waitcnt(clkfreq+cnt)
