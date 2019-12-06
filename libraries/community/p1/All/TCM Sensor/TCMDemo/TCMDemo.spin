{{
  Propeller: TCMDemo.SPIN
  Written by: Earl Foster

  Program will display Heading, Sensor Temperature, Pitch & Roll Angle of teh TCM-5 Sensor
}}
con
   _clkmode = xtal1 + pll16x  
   _xinfreq = 5_000_000
   
var
   long heading, temperature, pitch, roll
   
obj
   pni:         "TCMSensor"
   fstring:     "floatstring"
   debug:       "FullDuplexSerial"

pub main

   Debug.start(31, 30, 0, 9600)      'Start the debug terminal
   pni.StartPNI(1,0,9600,1)          'Review TCMSensor object for parameter explanation
   waitcnt(clkfreq+cnt)              'Allows TCMSensor object time to populate data
   repeat
    get_data
    show_data
    waitcnt(clkfreq+cnt)
    
pub get_data

   heading := pni.get_heading
   temperature := pni.get_temp
   pitch := pni.get_pitch
   roll := pni.get_roll

pub show_data

   debug.str(string("Heading:     "))
   debug.str(fstring.FloatToFormat(heading,6,1))
   debug.str(string("°"))
   debug.tx(13)
   debug.str(string("Temperature: "))
   debug.str(fstring.FloatToFormat(temperature,6,1))
   debug.str(string("°C"))
   debug.tx(13)
   debug.str(string("Pitch Angle: "))
   debug.str(fstring.FloatToFormat(pitch,6,1))
   debug.str(string("°"))
   debug.tx(13)
   debug.str(string("Roll Angle:  "))
   debug.str(fstring.FloatToFormat(roll,6,1))
   debug.str(string("°"))
   debug.tx(13)
   debug.tx(13)
   