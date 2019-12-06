' This is where you set up NOSIC and SEBELS for use with  your particular Antbot.
'
con

  ' Used to address the antbot(s) you want to talk to. Currently a byte value.
  AntbotID = 0 or 1 depending

con
  ' Is the Antbot equipped with ping sensors that are connected directly? If not, use -1. If you only have ping sensors for front or back, only turn those off.
  PING_RF = 19
  PING_LF = 20 
  PING_RB = 18
  PING_LB = 17

con
  ' Is the propeller chip on the Antbot set up to listen to NMEA sensors? If so, identify that pin (if the Picaxe is set to output serial data, it will do so on pin 16 if you use the jumper). If not, use -1.
  NMEA_0 = 16
  NMEA_1 = -1
  NMEA_2 = -1
  NMEA_3 = -1


con
  ' Is the propeller chip on the Antbot set up to listen to a GPS? If so, identify that pin. If not, use -1. If the GPS wants an initialization string, also identify that pin.
  GPS_RX = -1
  GPS_TX = -1
  ' Enter gps baud rate here -- negative numbers mean inverted signals (handheld GPSs usually do this, embedded modules usually do not)
  GPS_BD = -9600

con
  ' Is the Antbot equipped with a camera daughterboard?
  '
  ' no camera = 0
  ' c3088 or similar parallel camera = 1
  ' serial JPEG output camera = 2
  
  CAMERA = 1
 
con
  ' Is the Antbot equipped with a SD card daughterboard? If so, identify the first pin here (normally 12). If not, use -1.
  SD_CARD = -1

con
  ' Use this to flip the left-right and forward-backward axes of the motors.
  FLIP_X = 0
  FLIP_Y = 0

con
  ' The Antbot supports additional servos: you can change these definition within the Antbot's operating system, but you can define the defaults here. If you're not using a servo, use -1.

  SERVO0 = 12
  SERVO1 = 13
  SERVO2 = 14
  SERVO3 = 15
  SERVO4 = 255
  SERVO5 = 255
  SERVO6 = 255
  SERVO7 = 21
  SERVO8 = 22
  SERVO9 = 23


con
' we need at least 1 public function, might as well put it in here. This will read/write the antbot's ID number.
pub id(rw)        
    if rw == -1
       return vid
    vid := rw // $FF
    return vid
dat
vid byte AntbotID