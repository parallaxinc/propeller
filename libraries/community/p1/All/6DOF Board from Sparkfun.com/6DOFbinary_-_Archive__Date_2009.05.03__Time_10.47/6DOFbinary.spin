{
    The Atomic 6DOF Reader Object in 'Spin" code
    Device available from Sparkfun.com
    By earl@uphi.net

    call readDOF to get a buffer full of data @115200 baud on pins 22 & 23

    The string returned in @buffer is....
    starting with "A" then tab deliniated data (count,x,y,z accl x,y,z gyro) "Z" end char

    as such ------>
    
    1byte letterA tab 2byte count tab 2byte X-accl tab 2byte Y-accl tab 2byte Z-accl
    tab 2byte X-gyro tab 2byte Y-gyro tab 2byte Z-gyro tab 1byte letterZ

    Looks like this if unit is in ASCII mode ----->
    
    A   12345   500             500                     500                     500                     500                     500                     Z
          
    Looks like this in hex with seperating spaces ----->

    65 09 hh ll 09 hh ll 09 hh ll 09 hh ll 09 hh ll 09 hh ll 09 hh ll 09 5A
     
    This one prints on TV the values if 6DOF is running in BINARY NOT ASCII mode !
    See data sheet how to put unit in Binary or ASCII mode.
     
    Binary mode is best because it is easier to parse as values are always in same place in returned string.
    
}
CON
                                                
  _CLKMODE            = XTAL1 + PLL16X
  _XINFREQ            = 5_000_000

' 6DOF PIN Assignments                                   
  DOFin     = 22                                       ' fm GPS NEMA data
  DOFout    = 23                                       ' to GPS (to set baud, SIRF or NMEA etc. May be needed for your GPS)


' Video Output Assignments                              
  TVBase    = 12                                        ' TV  base pin         
                                                                                                                 
VAR

  byte buffer [ 36]
  byte cdat [ 12]
  byte xdat [ 12]
  byte ydat [ 12]
  byte zdat [ 12]
  byte Rx,loop
  long cptr ,count,tabcount,s 
  long x,y,z,Pitch,roll,yaw
  word RunningCount,ax,ay,az,gx,gy,gz
OBJ                                                    
  clock      :  "Clock"                                 ' overall timers 
  tv         :  "tv_text"                               ' TV video output driver
  uart       :  "FullDuplexSerialPlusDOF"               ' serial driver

PUB start

''Initialize all necessary routines as appropriate
 
Clock.Init(_XINFREQ)                    ' set up clock for accurate 10/second
Clock.SetClock(_CLKMODE)                ' video update rate
Clock.MarkSync
tv.start(TVBase)                        ' start TV display
uart.start(22,23,0,115200)              ' start uart on pins 22,23 for 6DOF Atomic board

                                         
Main                                   ' go do main program of getting and printing 6DOF serial data

PUB Main                               ' primary loop

readDOF                                ' Put the data in a buffer from 6DOF

  RunningCount := buffer[ 1]<<8 + buffer[ 2]  'Put buffer data into variables
  ax := buffer[ 3]<<8 + buffer[ 4]
  ay := buffer[ 5]<<8 + buffer[ 6]
  az := buffer[ 7]<<8 + buffer[ 8]
  gx := buffer[ 9]<<8 + buffer[ 10]
  gy := buffer[ 11]<<8 + buffer[ 12]
  gz := buffer[ 13]<<8 + buffer[ 14]

tv.str(string($A,1,$B,1,8))
tv.str(string("# of bytes in string "))
s := strsize(@buffer)
tv.dec(cptr)
tv.out(13)
tv.str(string("Data in HEX "))
tv.out(13)
tv.out(13)

tabcount :=0

  repeat while tabcount < s
    tv.hex(buffer[tabcount],2)
   tv.out(32)
     tabcount ++
      tv.out(32)
tv.out(13)
   
tv.str(string($A,1,$B,7))
tv.str(string("       Running Count"))
tv.str(string($A,1,$B,7))
tv.dec(RunningCount)

tv.str(string($A,1,$B,9))
tv.str(string("      X-Accl"))
tv.str(string($A,1,$B,9))
tv.dec(ax)
  
tv.dec(z)
tv.str(string($A,1,$B,10))
tv.str(string("     Y-Accl"))
tv.str(string($A,1,$B,10))
tv.dec(ay)
 
tv.str(string($A,1,$B,11))
tv.str(string("     Z-Accl"))
tv.str(string($A,1,$B,11))
tv.dec(az)

tv.str(string($A,16,$B,9))
tv.str(string("     X-Gyro"))
tv.str(string($A,16,$B,9))
tv.dec(gx)

tv.str(string($A,16,$B,10))
tv.str(string("     Y-Gyro"))
tv.str(string($A,16,$B,10))
tv.dec(gy)

tv.str(string($A,16,$B,11))
tv.str(string("     Z-Gyro"))
tv.str(string($A,16,$B,11))
tv.dec(gz)

waitcnt (1000 +cnt)

Main                                     'Do everything over and over !
 


PUB readDOF
 Rx:=0                                 'initialize, so we know definitely what's in before checking content in the while
 repeat while Rx <> "A"                ' wait for the "A" to insure we are starting with
    Rx := uart.rxcheck
 cptr := 0                                ' zero the buffer pointer to start
 byte[ cptr++ ]:=Rx                    ' NOW the A is really in the buffer
 
 repeat while Rx <> "Z" and cptr < 16  ' continue to collect data until the end of sentence ("Z")
     Rx := uart.rx                  ' get character from uart Rx
     buffer[ cptr++ ] := Rx            ' save the character in the buff

return                                    ' return to calling routine