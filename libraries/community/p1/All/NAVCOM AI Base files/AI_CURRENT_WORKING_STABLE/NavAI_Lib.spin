con
        SensorDataAddress = $0000_007C'80'88'A0'9C '98 ' Memory location for the whole damn thing (see F8)
        SensorDataChecksum  = $0000_02F0      ' change this if the function table changes
        EEPROMStart = $0000_8000              ' if only using main eeprom, leave this alone
        EEPROMEnd   = $0001_FFFF              ' if only using main eeprom, set to $0000_FFFF

        WingCommander = 4.123106              ' shhh!

        
CON     ' Offsets from sensor data address for sensor values -- saves some ram. See ReadSensorVal and WriteSensorVal below
        'usage: long[@SensorData + SensorName] := whatever
        'usage: whatever := long[@SensorData + SensorName]

        ' Note that this constant block has to be copied to all functions that use it -- sensor parser, GPS parser... and it must be IDENTICAL

        HeadingTreshhold = 0.15
        
        ' let's not waste time with word and byte vars -- use longs for everything and if we use 20 bytes more, who cares...       
        AA      =    0 ' altitude
        BB      =    4 ' float AS A RATIO OF LOW BATTERY!!!! so if low battery is 7.2 and actual battery voltage is 7.5, this is 1.042
        CC      =    8 ' bearing, either from compass sensor or gyro. Is used DIFFERENTIALLY by the interpolator, so x-y orientation isn't a big deal
        DD      =   12 ' distance from waypoint in meters (corrected for spheroid, but Mercator, not great-circle)
        EE      =   16 ' needs to be done, not used right now
        FF      =   20 ' reserved for Chrissy
        GG      =   24 ' Float for g-force? Probably accel in the vertical axis: ask Chrissy
        HH      =   28 ' heading from GPS and/or compass
        II      =   32 ' reserved for Chrissy
        JJ      =   36 ' Servo 1 previous value, useful for delta calcs
        KK      =   40 ' Servo 2 previous value, useful for delta calcs
        LL      =   44 ' Servo 3 previous value, useful for delta calcs
        MM      =   48 ' Servo 4 previous value, useful for delta calcs
        NN      =   52 ' turNamount delta - used to self-calibrate rudder, IF it ever works
        OO      =   56 ' Time since mission start in seconds
        PP      =   60 ' Line-of-sight suggested tracking
        QQ      =   64 ' Force-vectored tracking I think(?)
        RR      =   68 ' Arrival distance in meters
        SS      =   72 ' speed, duh
        TT      =   76 ' not necessarily the GPSTracking, could be vectored tracking; either way, tracking that will be actually used
        UU      =   80 ' see above for derivation
        VV      =   84 ' wind velocity in m/s
        WW      =   88 ' sind direction in m/s
        XX      =   92 ' this variable can be set to reference any of the ones above or below for application-specific use; point to itself for generic scratchpad val
        YY      =   96 ' this variable can be set to reference any of the ones above or below for application-specific use; point to itself for generic scratchpad val
        ZZ      =  100 ' this variable can be set to reference any of the ones above or below for application-specific use; point to itself for generic scratchpad val
        
                
 ' these cannot be accessed directly
      
        CompassField = 104 ' mag field intensity
        WindField = 108 ' reserved for future use

        Sonar1  =  112 ' Delta for sonar according to the sensor (as opposed to the prop) 
        Sonar2  =  116 ' Delta for sonar according to the sensor (as opposed to the prop)  
        Sonar3  =  120 ' Delta for sonar according to the sensor (as opposed to the prop)
        unused2  =  124 ' Acceleration in the left-right axis
        unused3  =  128 ' Acceleration in the front-back axis (to stay consistent with 2D maps)
        Radio   =  132 ' Radio control being on or off (might be used for "marginal" servos? do we even need this?)
        UpdCycle=  136 ' Update cycle for sensor parser (IT'S AN INTEGER, WARNING). Used mostly for display and sensor watchdog reset.
        GPSTime =  140 ' UTC time in seconds
        lat      = 144 ' IT'S AN INTEGER, it shouldn't be used in equations anyway. Used by interpolator and occasionally command parser.
        lon      = 148 ' IT'S AN INTEGER, it shouldn't terpolator and occasionally command parser
        curwayp   = 152  ' long

        COGTre = 156    ' Above this speed, trim compass to COG because we're hauling ass

        HeadTre = 160   ' Below this speed, use compass only to determine heading: above, use COG and compass

    GPSTracking =  164 ' Tracking as suggested by the GPS parser  

' this needs to go to a specialized Delta memory table that should mirror the main memtab.... IF we need it, which we shouldn't but hey.

        lat_delta = 168    ' - this should NOT be here at all actually, but it's easier to work with the gps if it is
        lon_delta = 172    ' - this should NOT be here at all actually, but it's easier to work with the gps if it is

        Sonar4  =  176 '  Absolute value  
        Sonar5  =  180'   Absolute value; generally center sonar is backward-facing if R and L are present 
        unused4  =  184 '  Absolute value
      GPSUpdRate = 188 ' integer, in 100ths of a second -- used by gps to differentiate TXT, NMEA1 and NMEA2
        BatteryMultiplier = 192   ' integer in millivolts
        unused1  = 196   ' integer in millivolts for minimum value
  GPSTimeReceive = 200 ' 1 when we get a gps ping, 0 otherwise  
        
        latGPS   = 204 ' last non-interpolated gps coords
        lonGPS   = 208 ' last non-interpolated gps coords
        trnGPS   = 212 ' last non-interpolated gps turn amount 
    dif_Speed    = 216  ' differential speed for interpolator (use with PSID or tach)
        AccelZ   = 220 ' Acceleration in the front-back axis (to stay consistent with 2D maps)
     gpsStatus   = 224 ' temperature (in nothing specific right now)

       zero_alt  = 228  'this is so ck can zero the alt on the fly! @qz is command - this is Chrissy's stuff so no touchy

       AlphaOffset = 232 ' the letters below are preconfigured in alphabetical order

       Alt     =   232 ' A      altitude
       Battery =   236 ' B      float 
       Compass =   240 ' C      bearing, either from compass sensor or gyro. Is used DIFFERENTIALLY by the interpolator, so x-y orientation isn't a big deal
       Distance =  244 ' D      distance from waypoint in meters (corrected for spheroid, but Mercator, not great-circle)
       ETA     =   248 ' E      needs to be done, not used right now
       Fudge   =   252 ' F      reserved for Chrissy
       Gravity =   256 ' G      Float for g-force? Probably accel in the vertical axis: ask Chrissy
       Heading =   260 ' H      heading from GPS and/or compass
ImpatientEquation =264 ' I      extra equation result goes in here
       OldSer1Val =268 ' Servo 1 previous value, useful for delta calcs
       OldSer2Val      =   272 ' Servo 2 previous value, useful for delta calcs
       OldSer3Val      =   276 ' Servo 3 previous value, useful for delta calcs
       OldSer4Val      =   280 ' Servo 4 previous value, useful for delta calcs
       NROT      =   284 ' rotatioNal speed used to countersteer
       Optime  =   288 ' Time since mission start in seconds
       RawGPSTracking      =   292 ' Line-of-sight suggested tracking
       RawGo2Tracking      =   296 ' Force-vectored tracking I think(?)
       aRRivaldistance   =   300 ' Arrival distance in meters
   cur_Speed   =   304 ' speed, duh
      _Tracking =  308 ' not necessarily the GPSTracking, could be vectored tracking; either way, tracking that will be actually used
     _tUrnamount = 312 ' see above for derivation
   windVel     =   316 ' wind velocity in m/s
       Winddir =   320 ' sind direction in m/s

       CurWaypointInBuffer = 324  ' long

       WantedLat = 328       ' long
       WantedLon = 332       ' long
       ReachedTime = 336     ' float, -1 means not reached
       ReachedLat = 340      ' long
       ReachedLon = 344      ' long
       ReachedAlt = 348      ' float, also works for depth
       ReachedHdg = 352      ' float
       ReachedDist = 356     ' float

       LastWaypointInBuffer = 360  ' long
       LastLat = 364
       LastLon = 368
       
       CompassMultiplier = 372 ' heading-bearing, updated when going fast enough
       CompassTrim = 376 ' add-subtract this from compass in order to trim it to COG
       
       DirectControlTimeout = 380
       ZanyEquation = 384
       PredictionFrames = 388
       NROTDeadZone = 392 ' if NROT is less than this, set it to zero: prevents jitter

       AltitudeMultiplier = 396

       LastVar =  396 ' END of this series - see above and below. Must be there to tell the compiler how much space to allocate!

       EndOfBuffer = 400 ' END of the buffer (may be same or bigger, never smaller)
        

con  GPSStackSize =    100   ' stacks for spin objects that use them
     SensorStackSize = 80    ' stacks for spin objects that use them
     MainStackSize =   180   ' stacks for spin objects that use them -- should be big, but do we actually need it ? it can vary a lot, consider using end of main memory instead


con
     meterstofeet = 3.2808399
     feettometers = 1.0 / meterstofeet
     

{
' shared so it'll work with every frequency BUT not need more overhead than that
dat
zsec  long 0
zusec long 0
zmsec long 0

pub sec
  if not zsec
     zsec:= clkfreq
  return zsec
pub msec
  if not zmsec
     zmsec:= clkfreq / 1_000
  return zmsec
pub usec
  if not zusec
     zusec:= clkfreq / 1_000_000
  return zusec

}
  
{
PUB PULSIN_uS (Pin, State) : Duration | ClkStart, clkStop, timeout
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1uS resolution
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_uS(5,1)
    BS2.Debug_Dec(x)
}}
 
   Duration := PULSIN_Clk(Pin, State) / us + 1             ' Use PulsinClk and calc for 1uS increments
    
PUB PULSIN_Clk(Pin, State) : Duration 
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1/clkFreq increments - 12.5nS at 80MHz
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_Clk(5,1)
    BS2.Debug_Dec(x)
}}

  DIRA[pin]~
  ctra := 0
  if state == 1
    ctra := (%11010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, A level count
  else
    ctra := (%10101 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, !A level count
  frqa := 1
  waitpne(State << pin, |< Pin, 0)                         ' Wait for opposite state ready
  phsa:=0                                                  ' Clear count
  waitpeq(State << pin, |< Pin, 0)                         ' wait for pulse
  waitpne(State << pin, |< Pin, 0)                         ' Wait for pulse to end
  Duration := phsa                                         ' Return duration as counts
  ctra :=0                                                 ' stop counter
}

pub startcounters
    ctra := %0_11111_000_00000000_000000_000_000000                                                
    ctrb := %0_11111_111_00000000_000000_000_000000

    frqa := 1 ' 125 means 1/8*1000 makes division a little simpler hopeully... ' add this every clock cycle, let's keep it simple for now
    frqb := 1 ' 125 means 1/8*1000 makes division a little simpler hopeully... ' add this every clock cycle, let's keep it simple for now

    phsa~ ' start NOW                                               
    phsb~ ' start NOW



pub serialxmit(TxPin, BaudRate, StringAddr) | inverted, t, txByte                                              
  inverted := BaudRate < 0
  BaudRate := clkfreq / ||BaudRate                                              '  Convert BaudRate to bit period

  repeat
   txByte := byte[StringAddr++]
   if txByte  
    outa[TxPin] := !inverted                             ' set idle state
    dira[TxPin]~~                                        ' make tx pin an output        
    txByte := ((txByte | $100) << 2) ^ inverted         ' add stop bit, set mode 
    t := cnt                                            ' sync
    repeat 10                                           ' start + eight data bits + stop
      waitcnt(t += BaudRate)                             ' wait bit time
      outa[TxPin] := (txByte >>= 1) & 1                  ' output bit (true mode)  
   else
    dira[TxPin]~                                       ' release to pull-up/pull-down
    return  
