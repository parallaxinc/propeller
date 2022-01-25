{{

  Project: EE-7 Practical 1 - Ultrasonic
  Platform: Parallax Project USB Board
  Revision: 1.0
  Author: Kenichi
  Date: 10th Nov 2021
  Log:
    Date: Desc
    v1
    10/11/2021: Creating object file for Ultrasonic sensors & ToF sensors

  Adopted from  Erlend Fj.'s VL6180Driver, dated 2015.
  Drives the range finder microchip from ST Microelectronics over I2C bus communication.

}}
CON

  ACK = 0                                                   'signals ready for more
  NAK = 1                                                   'signals not ready for more

  '' Reference for HC-SR04 (I2C)
  UltraAdd  = $57

OBJ
  bus   :    "i2cDriver.spin"

PUB Init(sclPin, sdaPin)
  return bus.Init(sclPin, sdaPin)

PUB readSensor | ackBit, clearBus
{{ Get a reading from Ultrasonic sensor }}
  bus.WriteByteA8(UltraAdd, $01, ackBit)
  waitcnt(cnt + clkfreq/10)
  result := bus.readLongA8(UltraAdd, ackBit)/254/1000
  clearBus := bus.readBus(ackBit)
  return result