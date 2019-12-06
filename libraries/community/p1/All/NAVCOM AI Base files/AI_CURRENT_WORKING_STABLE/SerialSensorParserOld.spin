''******************************
''*   NMEA-like sensor parser  *
''*   (C) 2006 Matteo K. Borri *
''* portions by Chrissy Keller *
''******************************                                                                
''

con numsensors = 8
var     
        byte          sensorstringtype[numsensors]
        byte          length
        long          SensorStack[((l#SensorStackSize))] ' temporary
        'long          SecondarySensorStack[((l#SensorStackSize))] ' temporary
        long          cog ' cog flag/id
       ' long          cog2
        byte          sensorstring[(70)]
        byte          sensorstring2[(70)]
        long          updatecycle
      
        long          SensorStringAddress
        long          Value1 ' these all have global scope here to reduce number of parameters passed
        long          Value2 ' these all have global scope here to reduce number of parameters passed
        long          Value3 ' these all have global scope here to reduce number of parameters passed
        long          Value4 ' these all have global scope here to reduce number of parameters passed
        long          lowestbatt
        long          addr

        long          FreqS[numsensors]
'        long          Freq1
'        long          Freq2
'        long          Freq3
'        long          Freq4
'        long          FreqB
        long          baudflag  
'        long          baudsp
        long          baud
        byte          RadioPinS
        byte          RadioPinD
        
        long          temp ' redneck serial buffer

        byte          localcnt
        byte          pintemp

        byte          pin[numsensors]
        
        'long          SensorDataAddress ' init to @SensorData
        long          SensorTypeAddress ' init to @SensorData

con        SerialGrace = 400 ' serial port autodetect grace period

           VaneDamageTre = 120.0 ' adjust depending on wind vane magnet
           CompDamageTre = 20.0 ' adjust depending on wind vane magnet
' copy this to anything that uses sensors!
'usage: long[(@SensorData + SensorName)] := whatever        


' Note that the smallest the number, the more often this gets checked. 

' these should really be pre-called by the ai function....

con BatteryOffset = 0'2210 ' offset between voltages seen by the sensor and a voltmeter across the battery directly
    BatteryMult = 5
con
           CompassFrequency =   1 ' ideally very urgent
           HeadingFrequency =   1 ' 10Hz maximum anyway, but give priority
           PSIAFrequency    =   8
           PSIDFrequency    =   8
           BathyFrequency   =   4 ' relatively urgent since it's needed for logging
           SonarFrequency   =   8
           MedleyFrequency  =  16
           WindFrequency    =  32  ' XI with compass anyway, so not that urgent
           BatteryFrequency = 256  ' not at all urgent


obj     serB:  "FullDuplexSerialExt"
        m:     "DynamicMathLib"
        fto:   "FtoF" 'for parsing
        l:     "NavAI_Lib"


        stak:  "stack_length_debug" ' remove once we know how big the stack must be


pub pincheck (pinIn, checkfor) | timeouts

  timeouts~
  if (pinIn <> $FF) ' was -1
     serB.start(pinIn, -1, baudflag, baud)
     repeat                                     
         temp := serB.rxtime(constant(SerialGrace))'/5))
         if (temp == -1)
             timeouts+= 50'+ 'pinB := -1  
         else
             timeouts++
     until (timeouts > 500 or ((temp & $FF)== checkfor))

     serB.stop

     if (timeouts > 250)
         return ((pinIn & $FF) | $80) ' assumes pin 0 isn't being used for this
         
  return (pinIn & $FF)

 
'PUB start (SensorPinRD, SensorPinRS, SensorBaud, SensorPinB, SensorPin1, SensorPin2, SensorPin3, SensorPin4, SensorTypeAddr) : okay 
PUB start (SensorBaud, BattPinRx, ADPinRx, HeadingPinRX, Sensor1Rx, Sensor2Rx, Sensor3Rx, Sensor4Rx, Sensor5Rx, Sensor6Rx, Sensor7Rx, SensorType) : okay

  stop
  'cog2~
  pin[(0)] := BattPinRx
  pin[(1)] := ADPinRx
  pin[(2)] := HeadingPinRX
  pin[(3)] := Sensor1Rx
  pin[(4)] := Sensor2Rx
  pin[(5)] := Sensor3Rx
  pin[(6)] := Sensor4Rx
  pin[(7)] := Sensor5Rx
  
  localcnt~
  repeat 
    dira[(pin[(localcnt)])]~
    pin[(localcnt)]   |= $80
  until localcnt++ == numsensors
  

  RadioPinS~' := SensorPinRS
  RadioPinD~' := SensorPinRD

'  SensorDataAddress := SensorDataAddr
  SensorTypeAddress := SensorType + 1
' this checks for whether there actually are sensors connected -- ties up a cog.

'  gettingnum:=0
'  repeat 57
'  gpsstring[(gettingnum)]:=0
'  gettingnum:=gettingnum+1

'  baudsp := || SensorBaud
  baud := || SensorBaud
  
  baudflag~ ':= %0000
  if (SensorBaud < 0)
     baudflag := %0001

' initialize everything to 128 to make sure it gets run
  longfill(@FreqS[(0)], $00000080, numsensors)

  stak.Init(@SensorStack,l#SensorStackSize)

  repeat
    okay := cog := cognew(SensorUpdate, @SensorStack) + 1
  until okay


con

utc =  82_800.00 + 3_540.00 + 59.00 + 0.99
echopin = -1

PUB GetStackLength
    return stak.GetLength  
PUB stop

'' Stop GPS driver - frees a cog
  m.stop
  fto.init
  serB.stop
 ' if cog2
 '   cogstop(cog2~ - 1)
  if cog
    cogstop(cog~ - 1)
    


PRI SensorRead (SensorIndex)    

    
    if (pin[(SensorIndex)] < $80)
    
      if (FreqS[(SensorIndex)] == 1) or (((long[constant(l#SensorDataAddress  + l#UpdCycle)]) // FreqS[(SensorIndex)]) == 0) '(Frequency(FreqS[(SensorIndex)]))

        length~ ' := 0


'        if (serB.try(pin[(SensorIndex)], -1, baudflag, baud,10) == false)  ' cog clog -- abort and try later
'               return
        serB.start(pin[(SensorIndex)],echopin,baudflag,baud)
        
        repeat
          temp := serB.rxtime(SerialGrace) 
        until (temp == "$" or temp == -1)
          if (temp == -1)
             pin[(SensorIndex)] |= $80
             sensorstringtype[(SensorIndex)] := "_"
             FreqS[(SensorIndex)] := BatteryFrequency
             return
          else
             sensorstring[0] := "$"
             'serB.tx("$")
             
        'ReadSensorString(@sensorstring,SensorIndex) ' in the meantime, calculate the PREVIOUS sensor string while we wait for the buffer to fill

        repeat
           sensorstring[(++length)] := serB.rxtime(SerialGrace) & $7F
           'serB.tx(sensorstring[(length)])
        until (sensorstring[(length)] == 13 or sensorstring[(length)] == "*" or sensorstring[(length)] == $7F)
        {
        ' special case for the Vector: get it twice!
        if sensorstring[2] == "E"
         repeat
           sensorstring[(++length)] := serB.rxtime(SerialGrace) & $7F
           'serB.tx(sensorstring[(length)])
         until (sensorstring[(length)] == 13 or sensorstring[(length)] == "*" or sensorstring[(length)] == $7F)
        }
        serB.stop
        sensorstring[length+1]~ ' prevent string fuckup
         

         
          if (sensorstring[(length)] == $7F)
             pin[(SensorIndex)] |= $80 ' flag as inconclusive
             sensorstringtype[(SensorIndex)] := "?" ' "_"
             FreqS[(SensorIndex)] := 128
             return
             
        sensorstring[(0)] := temp & $7F   ' do this here so it doesn't mess with the timing during the loop
        sensorstring[(++length)]~
        bytemove (@sensorstring2,@sensorstring, 69) ' in the meantime, calculate the PREVIOUS sensor string while we wait for the buffer to fill 
        ReadSensorString(@sensorstring,SensorIndex) ' in the meantime, calculate the PREVIOUS sensor string while we wait for the buffer to fill 
        sensorstringtype[(SensorIndex)] := sensorstring[(2)]
           
        return

      
    else

        
        pintemp := (pin[(SensorIndex)] & $7F) 
        if (ina[(pintemp)])         ' ... but i am getting something on input...
             pin[(SensorIndex)] := pincheck(pintemp, "$")  ' ... see if a sensor has reconnected

    'long[constant(l#SensorDataAddress  + l#Radio)] := (ina[(RadioPinS)])  ' condensed CheckRadioStatus


PRI SensorUpdate ' | radiolet, temp, cursor1, cursor2, SensorType1, SensorType2, SensorType3, SensorType4
    LowestBatt := 65536.0
    
    long[constant(l#SensorDataAddress  + l#UpdCycle)]~'
    byte[(SensorTypeAddress-1)] := "-"
    bytefill(@sensorstringtype, "_", numsensors) ' 0-48
    bytefill(@sensorstring, "#", 69) ' 0-48
    sensorstring[(39)]~

    l.startcounters

    ' initialize counters as freerunning as fast as possible (this causes no real overhead anyway)
            '0  mode pll   nothing  apin  n    bpin

    ' new autodetect only checks pins to which something is actually connected -- much faster!
{    
    localcnt~
    repeat
      pin[(localcnt)] |= $80 ':= pincheck(pin[(cc)], "$")
    until ++localcnt == 5
}                                                                                                                                                                                                               
    repeat
'      long[constant(l#SensorDataAddress  + l#UpdCycle)] := ++long[constant(l#SensorDataAddress  + l#UpdCycle)] & $000002FF '// 512

      localcnt~
      repeat
        SensorRead(localcnt)
'        bytemove(SensorTypeAddress, @SensorStringType, 5) 
      until ++localcnt == numsensors
      
      long[constant(l#SensorDataAddress  + l#UpdCycle)] := ++long[constant(l#SensorDataAddress  + l#UpdCycle)] & $000002FF '// 512
      

'      bytemove(SensorTypeAddress, @SensorStringType, 5)

pub debug
     return (@sensorstring2)      

pri ReadSensorString(stringaddr, SensorIndex) ', temp, temp2, temp3, temp4, sonartemp1, sonartemp2  

      addr := stringaddr+2

      m.forceslow
      fto.fast
      
      case byte[(addr)]

        0:
          byte[(stringaddr+2)]~  '
          byte[(stringaddr)]~
          m.allowfast  '
          fto.init 
          return
        ' ok for the LAST TIME: B is for battery and C is for compass. This is FINAL.
      
       "R":  ' Aux A/Ds -- do not use for now
          FreqS[(SensorIndex)] := BatteryFrequency

       ' downward-aiming sonar $SDDBS
       "D":
          'Value1 := addr
'          repeat until byte[(++Value1)] == "f" ' bypass feet, we want altitude in meters, for consistency
          fto.ParseNextFloat(addr,@Value1)
          long[constant(l#SensorDataAddress  + l#Alt)] := m.fmul(long[constant(l#SensorDataAddress + l#AltitudeMultiplier)], Value1) ' feet -> meters with better accuracy
          FreqS[(SensorIndex)] := BathyFrequency

       ' battery/companion picaxe
       "B","W":
            if byte[addr] == "W"
                           long[constant(l#SensorDataAddress  + l#Radio)] := byte[addr+2]  ' radio signal type, L-H-A
            'long[constant(l#SensorDataAddress  + l#UpdCycle)] := long[constant(l#SensorDataAddress  + l#UpdCycle)] + 1' prevents annoying lockup
            fto.ParseNextInt(addr, @Value1)
            if Value1 == 0
               fto.ParseNextInt(addr, @Value1)
            Value1 := m.fmul(m.ffloat(Value1),long[constant(l#SensorDataAddress  + l#BatteryMultiplier)])   
            if (m.fcmpi(Value1, m#LESSTHAN, LowestBatt))  ' sanity check
              LowestBatt := Value1  ' servos pull battery voltage down, so this gives us a conservative estimate
              long[constant(l#SensorDataAddress  + l#Battery)] := LowestBatt '(1 + (LowestBatt * 5)+ Value1 ) / 6
            FreqS[(SensorIndex)] := BatteryFrequency


       "E":  ' vector - use as compass heading since it's wildly inaccurate 'does this give true heading or compass heading?
          'EHDT,,T*
         if (strsize(addr)) > 8
           fto.ParseNextFloat(addr,@Value1)
             m.lock
             temp := m.fMathAngle(m.fadd(Value1,long[constant(l#SensorDataAddress  + l#CompassTrim)]))
             if (long[constant(l#SensorDataAddress  + l#WindDir)])     
                addr := long[constant(l#SensorDataAddress  + l#Compass)]
                addr := m.fMathTurnAmount(temp,addr)
                long[constant(l#SensorDataAddress  + l#WindDir)] := m.fMathAngle(m.fadd(long[constant(l#SensorDataAddress  + l#WindDir)], addr)) ' may need turnamount
             long[constant(l#SensorDataAddress  + l#CompassTrim)]~

             Value1 := m.fMathAngle(Value1)' new heading is here, old heading is still in the main map

             Value2 := m.fmul(m.ffloat(phsa~ >> 16), 0.00125) ' pretty good approximation for use
             ' calculate rotational velocity ~ in degrees per second
             Value2 := m.fdiv(m.fMathTurnAmount(long[constant(l#SensorDataAddress  + l#Heading)],Value1),Value2)
             'long[constant(l#SensorDataAddress  + l#NROT)] := Value2'm.favg(long[constant(l#SensorDataAddress  + l#NROT)], Value2)

             ' clamp a bit
             if m.fcmpi(Value2, m#LESSTHAN,     long[constant(l#SensorDataAddress  + l#NROTDeadZone)] | $8000_0000 )
                long[constant(l#SensorDataAddress  + l#NROT)] := m.fadd(Value2,long[constant(l#SensorDataAddress  + l#NROTDeadZone)] & $7FFF_FFFF )
             elseif m.fcmpi(Value2, m#MORETHAN, long[constant(l#SensorDataAddress  + l#NROTDeadZone)] & $7FFF_FFFF )
                long[constant(l#SensorDataAddress  + l#NROT)] := m.fadd(Value2,long[constant(l#SensorDataAddress  + l#NROTDeadZone)] | $8000_0000 )
             else
                long[constant(l#SensorDataAddress  + l#NROT)]~
             
             m.unlock
             long[constant(l#SensorDataAddress  + l#Compass)] := temp
             long[constant(l#SensorDataAddress  + l#Heading)] := Value1

           FreqS[(SensorIndex)] := HeadingFrequency
           'long[constant(l#SensorDataAddress  + l#UpdCycle)]++ ' prevents random resets hopefully?
         else
           byte[addr] := "e"
           FreqS[(SensorIndex)] := MedleyFrequency

{


       "T": fto.ParseNextFloat(addr,@Value1)
            fto.ParseNextFloat(addr,@Value2)
            fto.ParseNextFloat(addr,@Value3)
            temp := m.fMathAngle(m.fadd(Value1,long[constant(l#SensorDataAddress  + l#CompassTrim)]))'m.fadd(Value1,m.ffloat(long[constant(l#SensorDataAddress  + l#UpdCycle)] // 2)))'(m.fadd(Value1,90.0))
             if (long[constant(l#SensorDataAddress  + l#WindDir)])     
                addr := long[constant(l#SensorDataAddress  + l#Compass)]
                addr := m.fMathTurnAmount(temp,addr)
                long[constant(l#SensorDataAddress  + l#WindDir)] := m.fMathAngle(m.fadd(long[constant(l#SensorDataAddress  + l#WindDir)], addr)) ' may need turnamount
            long[constant(l#SensorDataAddress  + l#Compass)] := temp 'm.favg(temp,long[constant(l#SensorDataAddress  + l#Compass)])  
            long[constant(l#SensorDataAddress  + l#AccelY)]  := m.fMathAngle(Value2)
            long[constant(l#SensorDataAddress  + l#AccelX)]  := m.fMathAngle(Value3)
            FreqS[(SensorIndex)] := CompassFrequency



            
       "C","c":
{
          ' disable compass if heading sensor is functioning
          addr := @sensorstringtype
          repeat 5
              if byte[addr++] == "E"
                 byte[stringaddr+2] := "x"
                 return
          addr := stringaddr+2
}          
          if byte[(addr)] == "C"
            temp := fto.ParseNextInt(addr, @Value1)
            if (addr[(temp+1)] == "L")
               Value1 := Value1 * -1
            m.lock
            temp := m.fmul(m.ffloat(Value1),0.1)'m.fdiv(m.ffloat(Value1),10.0)
            long[constant(l#SensorDataAddress  + l#CompassField)] := constant(CompDamageTre + 10.0)
          else
            fto.ParseNextInt(addr, @Value1)
            fto.ParseNextInt(addr, @Value2)
            if (Value1 > 32767)
              Value1 -= 65536
            if (Value2 > 32767)
              Value2 -= 65536
            m.lock
            Value1 := m.ffloat(Value1)
            Value2 := m.ffloat(Value2)
            long[constant(l#SensorDataAddress  + l#CompassField)] := m.FDist(Value1, Value2)
            temp := m.FCoordsToDegs(0,0,(Value1),(Value2))
            temp := m.FMathAngle(m.fadd(temp,long[constant(l#SensorDataAddress  + l#CompassTrim)]))
               ' if compass has moved, move wind direction also
          if (m.fcmpi(long[constant(l#SensorDataAddress  + l#CompassField)], 1, CompDamageTre))      ' detects wind sensor breakage
             long[constant(l#SensorDataAddress  + l#Compass)] := temp
             if (long[constant(l#SensorDataAddress  + l#WindDir)])     
                addr := long[constant(l#SensorDataAddress  + l#Compass)]
                addr := m.fMathTurnAmount(temp,addr)
                long[constant(l#SensorDataAddress  + l#WindDir)] := m.fMathAngle(m.fadd(long[constant(l#SensorDataAddress  + l#WindDir)], addr)) ' may need turnamount


          m.unlock
          FreqS[(SensorIndex)] := CompassFrequency

       "W":
      ' smart wind sensor
            temp := fto.ParseNextInt(addr, @Value1)
            if (stringaddr[(temp+1)] == "L")
               Value1 := Value1 * -1
            long[constant(l#SensorDataAddress  + l#WindDir)] := Value1
            FreqS[(SensorIndex)] := WindFrequency

       "w":
      ' raw wind sensor
            fto.ParseNextInt(addr, @Value1)
            fto.ParseNextInt(addr, @Value2)
            if (Value1 > 32767)
              Value1 := Value1 - 65536
            if (Value2 > 32767)
              Value2 := Value2 - 65536

            Value1 := m.ffloat(Value1)
            Value2 := m.ffloat(Value2)
            m.lock
            temp := (m.FCoordsToDegs(0,0,(Value2),(Value1)))

             
            'temp :=  m.fmod(m.fadd(temp, float(3600 - 1350)),360.0) ' // 3600
            long[constant(l#SensorDataAddress  + l#WindField)] := m.FDist(Value1, Value2)
            if (m.fcmpi(long[constant(l#SensorDataAddress  + l#WindField)], 1, VaneDamageTre))      ' detects wind sensor breakage
                 long[constant(l#SensorDataAddress  + l#WindDir)] := m.fMathAngle(temp)'m.FMathAngle(m.fadd(temp,135.0))
            m.unlock
            FreqS[(SensorIndex)] := WindFrequency


       "S":
' sonar, two transducers. Sonars should be parsed as 1 transducer, 2 transducer and 3 transducers and
' if we have 1tran on a different pin than 2tran, have it happen LATER so we get proper overwrite.            
            fto.ParseNextInt(addr, @Value1)
            fto.ParseNextInt(addr, @Value2)
            fto.ParseNextInt(addr, @Value3)
            fto.ParseNextInt(addr, @Value4)
            
            
            'Value3 := Value3 - 50 ' since the picaxe only outputs positives
            'Value4 := Value4 - 50 ' since the picaxe only outputs positives
            if (Value1 < 2)
                  Value1 := 255              
            if (Value2 < 2)
                  Value2 := 255              
            long[constant(l#SensorDataAddress  + l#SonarL)] := m.fmul(m.ffloat(Value1), 0.01)
            long[constant(l#SensorDataAddress  + l#SonarR)] := m.fmul(m.ffloat(Value2), 0.01)
            long[constant(l#SensorDataAddress  + l#SonarPL)] := m.fmul(m.ffloat(Value3), 0.01)
            long[constant(l#SensorDataAddress  + l#SonarPR)] := m.fmul(m.ffloat(Value4), 0.01)

            length~ ' acts as delimiter for sensorstringtype
            if fto.Contains(@sensorstringtype, "M") == -1
              if fto.Contains(@sensorstringtype, "s") == -1
                sonartemp1 := m.fmul(m.ffloat(((Value1 * 2) + (Value2 * 2) + 2) / 4),0.01)  ' avoid data overlap if we have 3 sonars
                sonartemp2 := m.fmul(m.ffloat(((Value3 * 2) + (Value4 * 2) + 2) / 4),0.01)  ' avoid data overlap if we have 3 sonars

            FreqS[(SensorIndex)] := SonarFrequency

            

' sonar, one transducer. Sonars should be parsed as 1 transducer, 2 transducer and 3 transducers and
' if we have 1tran on a different pin than 2tran, have it happen LATER so we get proper overwrite.            
       "s":
            fto.ParseNextInt(addr, @Value1)
            fto.ParseNextInt(addr, @Value3)
            
            'Value3 := Value3 - 50 ' since the picaxe only outputs positives
            sonartemp1 := m.fmul(m.ffloat(Value1),0.01)           ' avoid data overlap if we have 3 sonars
            sonartemp2 := m.fmul(m.ffloat(Value3),0.01)           ' avoid data overlap if we have 3 sonars'

            FreqS[(SensorIndex)] := SonarFrequency

' "medley" sensor (xaccel-yaccel-temperature-sonar)
' this is a bit of a hack but i wanted to max out a picaxe

       "M": fto.ParseNextInt(addr, @Value1)
            fto.ParseNextInt(addr, @Value2)
            fto.ParseNextInt(addr, @Value3)
            fto.ParseNextInt(addr, @Value4)
            long[constant(l#SensorDataAddress  + l#AccelX)] := m.fmul(m.ffloat(Value1), 0.1)
            long[constant(l#SensorDataAddress  + l#AccelY)] := m.fmul(m.ffloat(Value2), 0.1)

            ' needs code for inclination from accels above here
            
            'long[constant(l#SensorDataAddress  + l#Temperature)] := m.ffloat(Value3)
            sonartemp1 := m.fmul(m.ffloat(Value4),0.01)
            sonartemp2 := m.fsub(sonartemp1, sonartemp3) ' temp
            sonartemp3 := sonartemp1
            FreqS[(SensorIndex)] := MedleyFrequency  ' temp
      



            'CK's PSIA sensor*******************************************************************************************
       "a":  'this is d cuz my alt picaxe broke and i don't feel like reprogrmaaing the d one and we are not using d anyway
            fto.ParseNextInt(addr, @Value1)                                                  
            Value1:=m.fdiv(m.fsub((m.ffloat(Value1)),long[(l#SensorDataAddress + l#zero_alt)]),261.54)  'meters up, and 210 feet or about 60 meters is full scale
            'Value1:=m.fdiv(m.fsub((m.ffloat(Value1)),long[(SensorDataAddress +l#zero_alt)]),79.73)  'feet up, and 210 feet or about 60 meters is full scale
            long[constant(l#SensorDataAddress  + l#Alt)] := Value1 'this is commented out for the car test so we can use psia as the drp_dst display variable
            FreqS[(SensorIndex)] := PSIAFrequency

            'CK's PSID sensor*******************************************************************************************
       "d":
            fto.ParseNextInt(addr, @Value1)  '
            Value1:=m.fmul(1.411459,m.fsqr(m.ffloat(Value1)))  'meters per second
            ' this doesn't seem to be saving anything... shouldn't it save into speed? added
            
            ' pick one of these two:
            'long[constant(l#SensorDataAddress  + l#cur_Speed)] := Value1 ' current speed : authoritative, replaces GPS speed entirely

            long[constant(l#SensorDataAddress  + l#dif_Speed)] := Value1 ' differential speed gets cross-interpolated with GPS speed, good if sensor is differentially reliable but not absolutely i.e. PSID

            FreqS[(SensorIndex)] := PSIDFrequency 

}       


       "S":
' sonar, two transducers. Sonars should be parsed as 1 transducer, 2 transducer and 3 transducers and
' if we have 1tran on a different pin than 2tran, have it happen LATER so we get proper overwrite.            
            m.unlock
            fto.ParseNextInt(addr, @Value1)
            fto.ParseNextInt(addr, @Value2)
            fto.ParseNextInt(addr, @Value3)
            fto.ParseNextInt(addr, @Value4)
            if value1 == 0
               value1 := 999
            long[constant(l#SensorDataAddress  + l#Sonar1)] := m.ffloat(Value1)'m.fmul(m.ffloat(Value1), 1.0)'0.006768) ' make it a configurable multiplier later
            if value2 == 0
               value2 := 999
            long[constant(l#SensorDataAddress  + l#Sonar2)] := m.ffloat(Value2)'m.fmul(m.ffloat(Value2), 1.0)'0.006768)
            if value3 == 0
               value3 := 999
            long[constant(l#SensorDataAddress  + l#Sonar3)] := m.ffloat(Value3)'m.fmul(m.ffloat(Value3), 1.0)'0.006768)
            if value4 == 0
               value4 := 999
            long[constant(l#SensorDataAddress  + l#Sonar4)] := m.ffloat(Value4)'m.fmul(m.ffloat(Value4), 1.0)'0.006768)
            fto.ParseNextInt(addr, @Value1)
            if value1 == 0
               value1 := 999
            long[constant(l#SensorDataAddress  + l#Sonar5)] := m.fmul(m.ffloat(Value1), 0.006768)
            FreqS[(SensorIndex)] := SonarFrequency

       other: ' badness happened, reset pin, but check it again soonish
           if byte[addr-1] == "G"
               FreqS[(SensorIndex)] := FreqS[(SensorIndex)] ' it's a GPS string, ignore it and keep reading the sensor
               byte[(addr)]:= "$"
           else

             byte[(addr)]:= "?"
             FreqS[(SensorIndex)] := BatteryFrequency
           'pin[(SensorIndex)] |= $80 
           'SensorFreq := 15
           
      sensorstringtype[(SensorIndex)] := byte[(addr)] 
      byte[SensorTypeAddress+SensorIndex] := byte[(addr)] 
      byte[(stringaddr+2)]~  '
      byte[(stringaddr)]~
      fto.init 
      m.allowfast  ' 