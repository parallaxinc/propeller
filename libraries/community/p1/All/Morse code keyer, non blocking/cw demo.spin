CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        
  cwpin = 10
  pitch = 650
  wpm = 15
  volume = 40
  busypin = 23
  
OBJ
  keyer         : "CW keyer"
    
PUB start  | rtc
 rtc := keyer.start(cwpin,pitch,wpm,volume,busypin)
 keyer.send(string("test de on5te"))

  repeat 5
   keyer.setvolume(10)
   waitcnt(80000000+cnt)
   keyer.setvolume(90)
   waitcnt(80000000+cnt)
 
 keyer.send(string("ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
 
 waitpeq(0, |< busypin, 0) 'Wait for busypin to go low
 keyer.stop  
 