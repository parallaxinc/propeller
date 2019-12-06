CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


OBJ

  text : "vga_text"
  gps  : "GPS_IO_mini"
  

pub main | gmt
gps.start
text.start(16)
text.str(string(13,"Loading..."))
text.out(" ")
repeat
  text.out(00)
  text.str((string("Latitude ")))
  text.str(gps.latitude)
  text.out(13)
  text.str((string("Longitude ")))
  text.str(gps.longitude)
  text.out(13)
  text.str((string("GPS Altitude ")))
  text.str(gps.GPSaltitude)
  text.out(13)
  text.str((string("Speed ")))
  text.str(gps.speed)
  text.out(13)
  text.str((string("Satellites ")))
  text.str(gps.satellites)
  text.out(13)
  text.str((string("Time GMT ")))
  text.str(gps.time)
  text.out(13)
  text.str((string("Date ")))
  text.str(gps.date)
  text.out(13)
  text.str((string("Heading ")))
  text.str(gps.heading)
   text.str((string(" ")))
   text.str(gps.N_S)
   text.str(gps.e_w)    
  text.out(13)
  waitcnt(1_000_000_0 + cnt)
