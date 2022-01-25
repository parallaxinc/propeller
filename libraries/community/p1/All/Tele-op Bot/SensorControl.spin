{
  Project: EE-7 Practical 1
  Platform: Parallax Project USB Board
  Revision: 1.3.1
  Author: Muhammad Syamim
  Date: 10th Nov 2021
  Log:
    Date: Desc
    v1
    10/11/21:   Added ToF and Ultrasonic Driver OBJ
                Sensor reads success
    v1.1
    11/11/21:   Added new cog initialisation

    v1.2
    14/11/21:   Added stop flag pointer

    v1.3
    16/11/21:   Added Post-Clear operator for SensorCogID
                Sensor values stored in cog 0
    v1.3.1
    17/11/21:   Added ready flag pointer
                Synced Milliseconds within OBJs
}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        ultra1SCL = 8, ultra1SDA = 9                                            'Front Ultrasonic Sensor Pins
        ultra2SCL = 6, ultra2SDA = 7                                            'Rear Ultrasonic Sensor Pins
        tof1SCL = 0, tof1SDA = 1, tof1RST = 14                                  'Front ToF Pins
        tof2SCL = 2, tof2SDA = 3, tof2RST = 15                                  'Rear ToF Pins
        tofADD = $29                                                            'Common ToF I2C Address
        Front = 1, Rear = 2, Ult = 1, ToF = 2                                   'Macros

VAR
  long  SensorCogID, SensorMotorStack[64]
  long  _Ms_001

OBJ
  Ultra         : "Ultra.spin"                                             'HC-SR04
  ToFDriver     : "ToF_edited.spin"                                        'VL6180X

PUB Init(F_UltPtr, R_UltPtr, F_ToFPtr, R_ToFPtr, RDYPtr, MsVal)                                         'Initialise Core for Sensors

  _Ms_001 := MsVal
  StopCore                                                                                              'Prevent stacking drivers
  SensorCogID := cognew(Start(F_UltPtr, R_UltPtr, F_ToFPtr, R_ToFPtr, RDYPtr), @SensorMotorStack)       'Start new cog with Start method
  return SensorCogID                                                                                    'Return cogID for tracking

PUB StopCore                                                                    'Stop active cog
  if SensorCogID                                                                'Check if any active driver cog
    cogstop(SensorCogID~)                                                       'Stop the cog and reset the value

  return

PUB Start(F_UltPtr, R_UltPtr, F_ToFPtr, R_ToFPtr, RDYPtr)                       'Looping Code for sensor updates

  InitToF                                                                       'Initialise the Time of Flight Sensors
  BYTE[RDYPtr]++

  repeat                                                                        'Update sensor values to cog 0
    LONG[F_UltPtr] := ReadUltraSonic(Front)                                     'Polling rate of Ultrasonic sensor set to 40ms/sensor
    LONG[F_ToFPtr] := ReadToF(Rear)
    LONG[R_UltPtr] := ReadUltraSonic(Rear)
    LONG[R_ToFPtr] := ReadToF(Front)

PUB ReadUltraSonic(Sensor_num)                                                  'Reads UltraSonic values

  if Sensor_num == Front                                                        'Select Sensor & switch the I2C bus
    Ultra.Init(ultra1SCL, ultra1SDA)
  elseif Sensor_num == Rear
    Ultra.Init(ultra2SCL, ultra2SDA)

  Pause(40)                                                                     'Ultrasonic Latency

  return Ultra.readSensor                                                       'Return Sensor reading

PUB ReadToF(Sensor_num)                                                         'Reads ToF values

  if Sensor_num == Front                                                        'Select Sensor & switch the I2C bus and reset pin
    ToFDriver.Init(tof1SCL, tof1SDA, tof1RST)
  elseif Sensor_num == Rear
    ToFDriver.Init(tof2SCL, tof2SDA, tof2RST)

  return TofDriver.GetSingleRange(tofADD)                                       'Return Sensor reading

PRI InitToF | i                                                                 'Initialise ToF Sensors

  repeat i from 0 to 1                                                          'Cycle through the two sensors
    if i == 0
      ToFDriver.Init(tof1SCL, tof1SDA, tof1RST)                                 'Change the I2C bus and reset pins
    elseif i == 1
      ToFDriver.Init(tof2SCL, tof2SDA, tof2RST)
    ToFDriver.ChipReset(1)                                                      'Reset the memory array
    Pause(1000)
    ToFDriver.FreshReset(tofADD)                                                'Start-up sequence
    ToFDriver.MandatoryLoad(tofADD)
    ToFDriver.RecommendedLoad(tofADD)
    ToFDriver.FreshReset(tofADD)
    Pause(1000)

  return

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)

  return