{{
CMU Camera Object

by Joe Lucia
http://irobotcreate.googlepages.com
2joester@gmail.com

Uses 2 cogs, one for FullDuplexSerial, one to process the received data

Features:
  TrackWindow   - tracks mean color in the center of the camera view 
  TrackColor    - tracks a color 

}}

OBJ
  ser   : "FullDuplexSerial"

VAR
  byte  RXPIN, TXPIN
  long  BAUDRATE

  byte Mmx, Mmy, Mx1, My1, Mx2, My2, Mpixels, Mconfidence

  long stk[100]

  byte cog

  byte _isTracking

pub Start(_rxpin, _txpin, _baudrate)                    '' Start the cogs
  Stop

  RXPIN := _rxpin
  TXPIN := _txpin
  BAUDRATE := _baudrate

  return (cog := cognew(ProcessCamera, @stk)+1)
  
pub Stop                                                '' Stop the cogs
  if cog
    ser.Stop
    cogstop(cog~ - 1)

pub ProcessCamera | b                                   '' Main Camera Data Processing routine

  ser.Start(rxpin, txpin, 0, baudrate)

  repeat
    if (b := ser.rxtime(50)) => 0
      if b==255                                         ' start of packet
        b := ser.rxtime(50)
        if b=="M"                                       '' process middle-mass packet
          Mmx := ser.rxtime(50)
          Mmy := ser.rxtime(50)
          Mx1 := ser.rxtime(50)
          My1 := ser.rxtime(50)
          Mx2 := ser.rxtime(50)
          My2 := ser.rxtime(50)
          Mpixels := ser.rxtime(50)
          Mconfidence := ser.rxtime(50)
          
pub SetBinaryMode                                       '' Set RawMode for received data
  ser.str(string("RM 3"))
  ser.tx(13)
  _isTracking := false

pub TrackWindow                                         '' Track MiddleMass of camera views mean center color
  if not _isTracking
    SetBinaryMode
    repeat until ser.rxcheck==":"
    _isTracking:=true
  else  ' calling again stops tracking
    _isTracking := false
  ser.str(string("TW"))
  ser.tx(13)

pub TrackColor(rmin, rmax, gmin, gmax, bmin, bmax)      '' Track MiddleMass of specific color
  if not _isTracking
    SetBinaryMode
    repeat until ser.rxcheck==":"
    _isTracking:=true
  else  ' calling this procedure again stops the tracking
    _isTracking := false

  ser.str(string("TC "))
  ser.dec(rmin)
  ser.tx(" ")
  ser.dec(rmax)
  ser.tx(" ")
  ser.dec(gmin)
  ser.tx(" ")
  ser.dec(gmax)
  ser.tx(" ")
  ser.dec(bmin)
  ser.tx(" ")
  ser.dec(bmax)
  ser.tx(" ")
  ser.tx(13)


pub MmxValue                                            '' return X coordinate of Middle of tracked color
  return Mmx

pub MmyValue                                            '' return Y coordinate of Middle of tracked color
  return Mmy

pub MconfidenceValue                                    '' return Confidence of tracked color                                  
  return Mconfidence

pub isTracking                                          '' indicates we are currently tracking a color
  return _isTracking
  