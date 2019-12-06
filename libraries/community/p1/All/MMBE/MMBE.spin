{
        Copyright (c) 2008 Parallax & Alexander Stevenson
        See end of file for terms of use.

                  *****************|| Motor Mind B Enhanced ||*********************

  This program is intended for the use of the Motor Mind B Enhanced motor controller product. I have had
  great success with it, and so far have experienced no problems. Please e-mail me at astevenson@lorch.com
  if you stumble across ANY problems with my code, or additions you feel I should make so that I can address
  them immediately. I will continue to modify and update the code as necessary. Also feel free to email me
  with any questions or concerns you have. I am accessible 8 AM - 4:30 PM EST every Monday through Friday.
  I am also accessible on the Parallax Forums at forums.parallax.com/forums under the username Aleks.

  Enjoy!

  ~Some men see things as they are and ask "why?"
  I see things that never were and ask "why not?"~
  
}

CON

  sync = $55
  stop = $0
  reverse = $1
  setdc = $3
  thestatus = $5
  count = $6
  readcounter = $B
  readfirm = $E




VAR

  long  sin, sout, inverted, bitTime, started, rxOkay, txOkay, status, speed   




OBJ

  serial : "FullDuplexSerial"                              ' bit-bang serial driver

  
PUB start(txPin, rxPin, baud)                           'Declare the transmit pin, receive pin, and baud rate

  
  if lookdown(rxPin : 0..31)                            ' qualify rx pin
    sin := rxPin                                        ' save it
    rxOkay := started := true                           ' set flags

  if lookdown(txPin : 0..31)                            ' qualify tx pin
    sout := txPin                                       ' save it   
    txOkay := started := true                           ' set flags 

  if started
    serial.start(sin, sout, 0, baud)
  return started

PUB set(power)                                        'Used to setdc as illustrated in the MMBE documentation
                                                        'Power is a byte, decimal range of 0-255 with 255 being
                                                        '100% of the voltage on the VMotor pin
  if started
      serial.tx(sync)
      serial.tx(setdc)
      serial.tx(power)
      return true
  else
    return false

PUB motorstop                                           'Used to set motor speed to 0
  set(0)

PUB motorrev                                            'Used to reverse the direction of the motor
  if started
    serial.tx(sync)
    serial.tx(reverse)
    return true
  else
    return false

PUB getstatus                                           'Used to access the status byte *see MMBE documentation*
  if started
    serial.tx(sync)
    serial.tx(thestatus)
    status := serial.rx
    speed := serial.rx
  return status

PUB getspeed                                            'Used to acquire the current speed of the motor
  if started
    serial.tx(sync)
    serial.tx(thestatus)
    status := serial.rx
    speed := serial.rx
  return speed
  
PUB checkdir                                            'Used to check the direction of the motor. Returns the 
  status := getstatus                                   'MOTDIR bit of the status byte (1 = reverse, 0 = forward)
  return status
  
PUB setdir(state)                                       'Used to set the direction of the motor. Returns true
  if state == checkdir                                  'when successful. Hangs up program until success
    return true
  else
    motorrev
    setdir(state)
  
       

{{
                            TERMS OF USE: MIT License                                                           

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}    