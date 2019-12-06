''******************************
''*    GPRMC parse+interp      *
''*   (C) 2006 Matteo K. Borri *
''******************************

' All the log stuff ended up here because it was practical to do so. It can be moved back to the main file at some point probably.                                                              


var     
        long          GPSSA
        long          GPSStack[l#GPSStackSize] 'GPSStack[100)] ' temporary
        long          gpscog ' cog flag/id
        'long          SensorDataAddress ' init to @SensorData
        long          SensorDataAddressLast ' init to @SensorData
        long          SensorDataAddressDelta ' init to @SensorData
        long          InterpRoundAddress

        byte          gpspin
        long          baud
        byte          gpsround


        long          lastbear
        long          lasthead
        long          lastspeed_g
        long          lastspeed_d


        long          gettingnum
        long          interpround
        long          rounds
        long          gpsindex
        long          time
        long          lat_temp
        long          lon_temp
        long          vel_lat
        long          vel_lon      
        long          wplatindex
        long          wplonindex
        long          currwp
        long          wplat_float
        long          wplon_float
        long          head
        long          dist
        long          trak

        long          temphead
        long          tempspeed
        long          numrounds
        long          temptime
        long          cosh
        long          sinh
        long          fint
        long          GpsMisses

        long          buffaddr ' start of GPS serial receive buffer

        byte          dodist
        byte          dotrak
        byte          dolog
        

'dat        
'gpsstring_spare               byte "$________________________________________________________________________________________"


dat
'logtype byte "dat____",0
' this works like TelemetryType in the main file...
 
' coordinates are defined by 1 letter because what's the point in logging only lat or only lon?
' cordinate system:
' d decdegrees
' m milliminutes (raw)

obj     
        m         :   "DynamicMathLib"
        timer     : "dyntimerF" ' or dyntimerF if we need it fudge-factored to go a little faster
        GPSSerial : "FullDuplexSerialExt"
        'GPSSerial2: "Simple_Serial_RX"
        l       : "NavAI_Lib" ' small library w/ memory map in it
        fto   : "FtoF" ' only used for parsing
        i2c   :"EEPROM_I2C_Driver"
        stak    : "stack_length_debug" ' remove once we know how big the stack must be
        sd : "SDCARD_LOGONLY" ' SUPER simplified system to write on a SD card, dynamically loads a cog as needed so run AFTER the serial port has done its thing!
        
con gpsinvert = %0111 ' the first 1 is to avoid driving the TX line in case the laptop wants to talk to the vector....


PUB start (GPS1PinTx, GPS_Pin, GPSBaud, SensorDataLastAddr, SensorDataDeltaAddr, InterpRoundsAddr, GPSStringAddr, DLTFlag) : okay
  stop

  dodist := DLTFlag & 1
  dotrak := DLTFlag & 2
  dolog  := DLTFlag & 4
  
  m.start
  'SensorDataAddress := SensorDataAddr
  SensorDataAddressLast := SensorDataLastAddr
  SensorDataAddressDelta := SensorDataDeltaAddr
  GPSSA := GPSStringAddr  '@gpsstring
  InterpRoundAddress := InterpRoundsAddr

  stak.Init(@GPSStack,l#GPSStackSize)

  
  gpspin := GPS_Pin
  baud := ||(GPSBaud)
'
  repeat 
     okay := gpscog := cognew(GPSUpdate, @GPSStack) + 1
  until okay

PUB stop


  m.stop
  sd.close
  GPSSerial.stop
  'fto.stop
  
  if gpscog
    cogstop(gpscog~ - 1)

                                      
PUB GetStackLength
    return stak.GetLength  
con keeplock = true
    numcommands = 3 ' See main function for this
    SPEEDTRE = 0.2 ' meters per second
                              
PRI GPSUpdate | tempvar, tempfloat, tempint1, tempint2' | gettingnum, interpround, gpsindex, time, dist, lat_temp, lon_temp, vel_lat, vel_lon, speed_temp, wplatindex, wplonindex, head, trak, currwp, wplat_float, wplon_float, rounds


  GPSSerial.start(GPSPin, -1, gpsinvert, baud)
  buffaddr := GPSSerial.RXBufferAddress
{
  sd.open(@filename)
  sd.log(string("GPSInit",13,10))
  sd.close
}  
  'sd.logstring(@filename,0,string("GPSinit",13,10),0)
  
    ' get lock on gps output
  repeat
       byte[(gettingnum)] := GPSSerial.rx
  until (byte[(gettingnum)] == "$")

  
  gpsindex~
  GpsMisses~

  ' use gps

  
  repeat ' main loop

    ' wait until we get something, dammit!
   
    repeat
      gpsindex := (gpsindex + 1) // 85
       
    until (byte[(buffaddr + gpsindex)] == $0A)  ' wait until we get the last byte of the string
  

    bytemove(GPSSA, buffaddr, 85)
    GPSSA[86]~ ' paranoia

    GPSSerial.stopnoflush
    {
    sd.open(@filename)
    sd.log(GPSSA)
    sd.close
    }


    gettingnum := GPSSA ' start of gps string offset

   if byte[(GPSSA+17)] <> "A"  ' byte[(GPSSA+19)] == "V" or  byte[(GPSSA+8)] == "V"' invalid sat fix, do an extra interpolation round
'   if byte[(GPSSA+17)] == "V"  or byte[(GPSSA+19)] == "V" or  byte[(GPSSA+8)] == "V"' invalid sat fix, do an extra interpolation round

     time++
     
     long[constant(l#SensorDataAddress  + l#gpsstatus)]~
      if (m.fcmpi(tempspeed, -1, long[constant(l#SensorDataAddress  + l#HeadTre)]))  and long[constant(l#SensorDataAddress  + l#Compass)]
          temphead := long[constant(l#SensorDataAddress  + l#Compass)]
      else
          temphead := InterpolateHeadingWithBearing

     long[constant(l#SensorDataAddress  + l#Heading)] := temphead

     long[constant(l#SensorDataAddress  + l#lonGPS)] := long[constant(l#SensorDataAddress  + l#lon)]
     long[constant(l#SensorDataAddress  + l#latGPS)] := long[constant(l#SensorDataAddress  + l#lat)]

      long[constant(l#SensorDataAddress  + l#cur_speed)] := m.fadd(lastspeed_g,((m.fsub(long[constant(l#SensorDataAddress  + l#dif_Speed)], lastspeed_d)))) 

      lastbear := long[constant(l#SensorDataAddress  + l#Compass)]
      lasthead := long[constant(l#SensorDataAddress  + l#Heading)]

      lastspeed_g := long[constant(l#SensorDataAddress  + l#cur_speed)]
      lastspeed_d := long[constant(l#SensorDataAddress  + l#dif_speed)]

      GpsMisses++
     
     
   else
   
     GpsMisses~
     long[constant(l#SensorDataAddress  + l#gpsstatus)] := 1.0
     
' actual parsing starts here.... first we have $GPRMC which we ignore, then time

     ' first is time
     gettingnum := GPSSA
     gettingnum += fto.ParseNextFloat(gettingnum, @tempfloat)
     time := m.fround(tempfloat) ' tempint1 * 100 + tempint2 ' always *100 for now anyway, don't divide     

     ' alternate solution: extract degrees, replace degree digits with zeros, use parsenextfloat on seconds THEN multiply and convert to integers.

    ' next is degrees&minutes N/S
     gettingnum += fto.ParseNextInt(gettingnum, @tempint1)
     tempint2 := (tempint1 // 100) * 10000' minutes
     tempint1 := tempint1 / 100 * constant(60*100*100)' degrees
     tempint1 := tempint1 + tempint2 ' goes into minutes
     ' next is fractional minutes N/S
     byte[--gettingnum] := "0"                               ' ugly, but effective fix for GPS models that use a nonstandard number of digits 
     byte[--gettingnum] := "@"                               ' ugly, but effective fix for GPS models that use a nonstandard number of digits 
     gettingnum += fto.ParseNextFloat(gettingnum, @tempfloat)
     tempint2 := m.fround(m.fmul(tempfloat,10000.0))   ' keep everyting in decimilliminutes
     lat_temp := (tempint1 + tempint2)'((tempint2 + 5) / 10))
      if (byte[++gettingnum] == "S")
         lat_temp *= -1


    ' next is degrees&minutes E/W
     gettingnum += fto.ParseNextInt(gettingnum, @tempint1)
     tempint2 := (tempint1 // 100) * 10000' minutes
     tempint1 := tempint1 / 100 * constant(60*100*100)' degrees
     tempint1 := tempint1 + tempint2 ' goes into minutes
     ' next is fractional minutes E/W
     byte[--gettingnum] := "0"                               ' ugly, but effective fix for GPS models that use a nonstandard number of digits 
     byte[--gettingnum] := "@"                               ' ugly, but effective fix for GPS models that use a nonstandard number of digits 
     gettingnum += fto.ParseNextFloat(gettingnum, @tempfloat) 
     tempint2 := m.fround(m.fmul(tempfloat,10000.0))   ' keep everyting in decimilliminutes
     lon_temp := (tempint1 + tempint2)'+ ((tempint2 + 5) / 10))
     if (byte[++gettingnum] == "W")
         lon_temp *= -1

     
     ' next is speed and heading: floats, easy
     
     ' speed
     gettingnum += fto.ParseNextFloat(gettingnum, @tempfloat)
     tempspeed := m.slowfmul(tempfloat,0.514444444)   ' knots to meters per second


        

     ' heading it's already in degrees?)
     gettingnum += fto.ParseNextFloat(gettingnum, @head)

     
     ' check if we're going backwards by comparing COG and heading
      if m.fcmpi(m.fabs(m.FMathTurnAmount(head,long[constant(l#SensorDataAddress  + l#Compass)])), m#MORETHAN, 90.0)
         tempspeed := m.fneg(tempspeed)
         
      if m.fcmpi(tempspeed, -1 ,SPEEDTRE)
         tempspeed~' := 0.0

     
      if (m.fcmpi(tempspeed, m#LESSTHAN, long[constant(l#SensorDataAddress  + l#HeadTre)]))
          head := long[constant(l#SensorDataAddress  + l#Compass)]
      elseif (m.fcmpi(tempspeed & $7FFF_FFFF, m#MORETHAN, long[constant(l#SensorDataAddress  + l#COGTre)]))
          long[constant(l#SensorDataAddress  + l#CompassTrim)] := m.FMathTurnAmount(long[constant(l#SensorDataAddress  + l#Compass)],head) ' may need to flip this subtraction
          


     
      bytemove(GPSSA, buffaddr, 85) 'restore string for telemetry
     
     ' get vectors for interpolation later
      vel_lat := m.fmul(tempspeed,m.FcosD(long[head]))
      vel_lon := m.fmul(tempspeed,m.FsinD(long[head]))

                                                         

    ' note that the current waypoint is locked between real gps updates

      m.IMaybeCorrectedNavCalculation(lon_temp, lat_temp, i2c.GetWaypointLon(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), i2c.GetWaypointLat(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), @dist, @trak, dodist, dotrak)   ' this one here WORKS!!!!!

                 
    ' proceed
     long[constant(l#SensorDataAddress  + l#lonGPS)] := lon_temp
     long[constant(l#SensorDataAddress  + l#latGPS)] := lat_temp
     long[constant(l#SensorDataAddress  + l#lat_delta)] :=  0.0 'm.fadd(0.0,(m.fmul(m.fmul(vel_lat,2.1739),fint))))      ' my fudge factor was 0.460, 1/0.46 is 2.1739, mul faster than div
     long[constant(l#SensorDataAddress  + l#lon_delta)] :=  0.0 'm.fadd(0.0,(m.fmul(m.fmul(vel_lon,2.1739),fint))))






'    if (||(lat_temp - long[constant(l#SensorDataAddress  + l#lat)]) < 32767) ' sanity check
      long[constant(l#SensorDataAddress  + l#lat)] :=  lat_temp
      long[constant(l#SensorDataAddress  + l#lon)] := lon_temp
      long[constant(l#SensorDataAddress  + l#cur_speed)] := tempspeed
'     long[(SpeedAddr)] := speed_temp



      long[constant(l#SensorDataAddress  + l#Heading)] :=  head
         
      ' else use the last compass reading i guess... once we find one that works >_>

      long[constant(l#SensorDataAddress  + l#Distance)] := dist
      long[constant(l#SensorDataAddress  + l#GPSTracking)] :=  trak


      lastbear := long[constant(l#SensorDataAddress  + l#Compass)]
      lasthead := long[constant(l#SensorDataAddress  + l#Heading)]

      lastspeed_g := long[constant(l#SensorDataAddress  + l#cur_speed)]
      lastspeed_d := long[constant(l#SensorDataAddress  + l#dif_speed)]


       
   long[constant(l#SensorDataAddress  + l#GPSTime)] :=  (time * 100)  'seconds, howmany, startround, endround, baudrate, WPLat, WPLon, gpsactivateround
    long[constant(l#SensorDataAddress  + l#GPSTimeReceive)] := 1.0


    UpdateDeltas

    gpsround := (long[(InterpRoundAddress)]*4)/5


    Interpolate(1, long[(InterpRoundAddress)], 1, long[(InterpRoundAddress)]+1, i2c.GetWaypointLat(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), i2c.GetWaypointLon(long[constant(l#SensorDataAddress  + l#CurWaypointInBuffer)]), gpsround)


pri InterpolateHeadingWithBearing
'''' THIS NEEDS TO BE FIXED!!!!!!! now that turnamount works better.
return m.fMathTurnAmount((m.fmul(m.fMathAngle(m.FMathTurnAmount(long[constant(l#SensorDataAddress  + l#Compass)], lastbear)),long[constant(l#SensorDataAddress  + l#CompassMultiplier)])),lasthead)
var long numroundscached, latm, lonm ' made global for optimization purposes
                                                             
pri Interpolate (seconds, howmany, startround, endround, WPLat, WPLon, gpsactivateround) | currentround, logged

  latm := m.LatMeters(m.ffloat(long[constant(l#SensorDataAddress  + l#lat)]))
  lonm := m.LonMeters(m.ffloat(long[constant(l#SensorDataAddress  + l#lat)]))
  numroundscached := m.fdiv(1.0,m.ffloat(howmany))
  logged~
  repeat seconds
    currentround := startround
    temptime := (((long[constant(l#SensorDataAddress  + l#GPSTime)] + 51) / 100) * 100)
    long[constant(l#SensorDataAddress  + l#GPSTime)] := temptime
    repeat (endround -  startround)
         timer.markSIF(95_000 / howmany)

         temptime := DoInterpCalculations(howmany, currentround++, WPLat, WPLon, numroundscached)

         if (currentround == gpsactivateround)


             XMitLog
             logged~~
             {
              ' NOTE: This works, but it fills the SD card with crap right now. Working areas: 5-16, 30-40.
              repeat 3
               logged := m.fround(m.fmul(long[constant(l#SensorDataAddress  + l#alt)],100.0))
               sd.open(@filestr)'string("NAVCOMAI.GPS"))
               byte[@fil2str]++
               sd.log(fto.indecdegrees(long[constant(l#SensorDataAddress  + l#lon)]))
               sd.log(string(","))
               sd.log(fto.indecdegrees(long[constant(l#SensorDataAddress  + l#lat)]))
               sd.log(string(","))
               sd.log(fto.IntToFormatPN(logged, 0, 2, 0,"-"))
               sd.log(string(32,13,10))  ' the space is to make google earth happy
               sd.close
               logged~~
              byte[@fil2str]:="1"
              }
               
             GPSSerial.start(gpspin, -1, gpsinvert, baud)
             buffaddr := GPSSerial.RXBufferAddress
             GPSSerial.str(GPSSA)

         
         elseif (howmany < 30)
                timer.waitSIF(0)

         long[constant(l#SensorDataAddress  + l#GPSTime)] := temptime    ' this also triggers the main AI function, so make sure it's updated last!!!!!



pub XMitLog | tempvar

            if (dolog)
              ' NOTE: Add a class of commands to make sure what we log is configurable (as per the telemetry string).
               sd.open(@filestr)'string("NAVCOMAI.GPS"))
               sd.log(fto.indecdegrees(long[constant(l#SensorDataAddress  + l#lon)]))
               sd.log(string(","))
               sd.log(fto.indecdegrees(long[constant(l#SensorDataAddress  + l#lat)]))
               sd.log(string(","))
               sd.log(fto.IntToFormatPN(m.fround(m.fmul(long[constant(l#SensorDataAddress  + l#alt)],100.0)), 0, 2, 0,"-"))
               sd.log(string(32,13,10))  ' the space is to make google earth happy
               sd.close


pub DoInterpCalculations(numroundspersec, localround, WPLat, WPLon, numroundsflipped)

      if (rounds > 30)
         m.lock ' this is the function that does the most heavy lifting math wise, so let's dedicate a cog to it

      cosh := m.FcosD(long[constant(l#SensorDataAddress  + l#Heading)])
      sinh := m.FsinD(long[constant(l#SensorDataAddress  + l#Heading)])   ' does this fix the negative-loc thing? must check
'      fint := m.fdiv(m.ffloat(localround),m.ffloat(numroundspersec))
      fint := m.fmul(m.ffloat(localround), numroundsflipped)


    ' cross-interp between differential speed from sensor (accelerometer, PSID, tach) and current GPS speed
      tempspeed := m.fadd(lastspeed_g,((m.fsub(long[constant(l#SensorDataAddress  + l#dif_Speed)], lastspeed_d))))

      {
      vel_lat := m.fmul(long[constant(l#SensorDataAddress  + l#cur_speed)],cosh)
      vel_lon := m.fmul(long[constant(l#SensorDataAddress  + l#cur_speed)],sinh)
      }

      vel_lat := m.fmul(tempspeed,cosh)
      vel_lon := m.fmul(tempspeed,sinh)
      
      temptime := ((long[constant(l#SensorDataAddress  + l#GPSTime)] / 100 * 100) + (100 * localround / numroundspersec))
'      m.ICorrectedNavCalculation(long[constant(l#SensorDataAddress  + l#lon)], long[constant(l#SensorDataAddress  + l#lat)], WPLon, WPLat, @tempdst, @temptrk)   ' this one here WORKS!!!!!

      if (m.fcmpi(tempspeed, -1, long[constant(l#SensorDataAddress  + l#HeadTre)]))  and long[constant(l#SensorDataAddress  + l#Compass)]
          temphead := long[constant(l#SensorDataAddress  + l#Compass)]
      else
          temphead := InterpolateHeadingWithBearing
 '     temphead := InterpolateHeadingWithBearing'm.fMathTurnAmount((m.fmul(m.fMathAngle(m.FMathTurnAmount(long[constant(l#SensorDataAddress  + l#Compass)], lastbear)),2.0)),lasthead)
'                                              
      long[constant(l#SensorDataAddress  + l#lat_delta)] :=  (m.fmul(m.fdiv(vel_lat,latm),fint))      ' my fudge factor was 0.460, 1/0.46 is 2.1739, mul faster than div - then for fractional fint, multiplied by 3
      long[constant(l#SensorDataAddress  + l#lon_delta)] :=  (m.fmul(m.fdiv(vel_lon,lonm),fint))      ' at these coords, only the lattiude fudger is good. USE A TABLE DAMIT
'      long[constant(l#SensorDataAddress  + l#lat_delta)] :=  (m.slowfmul(m.fdiv(vel_lat,m.LatMeters(m.ffloat(long[constant(l#SensorDataAddress  + l#lat)]))),fint))      ' my fudge factor was 0.460, 1/0.46 is 2.1739, mul faster than div - then for fractional fint, multiplied by 3
'      long[constant(l#SensorDataAddress  + l#lon_delta)] :=  (m.slowfmul(m.fdiv(vel_lon,m.LonMeters(m.ffloat(long[constant(l#SensorDataAddress  + l#lat)]))),fint))      ' at these coords, only the lattiude fudger is good. USE A TABLE DAMIT

      long[constant(l#SensorDataAddress  + l#lat)] :=  (long[constant(l#SensorDataAddress  + l#latGPS)] + m.fround(long[constant(l#SensorDataAddress  + l#lat_delta)]))
      long[constant(l#SensorDataAddress  + l#lon)] :=  (long[constant(l#SensorDataAddress  + l#lonGPS)] + m.fround(long[constant(l#SensorDataAddress  + l#lon_delta)]))
      
      'm.ICorrectedNavCalculation(long[constant(l#SensorDataAddress  + l#lon)], long[constant(l#SensorDataAddress  + l#lat)], WPLon, WPLat, @tempdst, @temptrk)   ' this one here WORKS!!!!!
      m.IMaybeCorrectedNavCalculation(long[constant(l#SensorDataAddress  + l#lon)], long[constant(l#SensorDataAddress  + l#lat)], WPLon, WPLat, @dist, @trak, dodist, dotrak)   ' this one here WORKS!!!!!

      long[constant(l#SensorDataAddress  + l#cur_speed)] := tempspeed
      long[constant(l#SensorDataAddress  + l#Heading)] := temphead
      long[constant(l#SensorDataAddress  + l#Distance)] := dist

      UpdateDeltas   
      return temptime

 
pri UpdateDeltas | tempd, tempdelta

      tempd~
      if (rounds > 30)
         m.lock ' this is the function that does the most heavy lifting math wise, so let's dedicate a cog to it
      repeat
      
        'if (long[(l#SensorDataAddress + tempd)] <> long[(SensorDataAddressLast + tempd)])
            long[(SensorDataAddressDelta + tempd)] := m.fadd(long[(l#SensorDataAddress + tempd)], (long[(SensorDataAddressLast + tempd)] ^ $8000_0000))  ' optimized subtraction
            if long[constant(l#SensorDataAddress  + l#PredictionFrames)]
               long[(l#SensorDataAddress + tempd)] := m.fadd(long[(l#SensorDataAddress + tempd)], m.fmul(long[constant(l#SensorDataAddress  + l#PredictionFrames)],long[(SensorDataAddressDelta + tempd)]))

        tempd += 4
      until tempd == constant(26*4)
      m.unlock

      longmove(SensorDataAddressLast, l#SensorDataAddress, 26)'constant(l#LastVar/4))


{
dat
filename  byte "NAVCOM"
filename2 byte "AI.LOG",0
crlfstr   byte 13,10,0
}                       

dat
filestr byte "NAVCOMAI"
filedot byte "."
extstr  byte "LOG",0



