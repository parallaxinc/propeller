{{
******************************************
* PS2_Wrapper.spin                       *
*Kristian Charboneau                     *
*Copyright (c) 2013 Kristian Charboneau  *
*See end of file for terms of use        *
*Version: 2.0                            *
******************************************

This object provides a simple spin interface around Juan Carlos Orozco's Play Station 2 Controller driver.
Each button has its own method which returns 1 if button is pressed or 0 if button is not pressed.
See PS2_controller.spin for instructions on how to set up the controller connection.

Changes:
        Changed evaluation method to bitwise & operator, instead of string conversion and comparison.
        Replaced mode_int and mode_hex with mode; ID_int and ID_hex with id
        Removed stringCompareCI, hexadecimalToInteger, checkDigit, ignoreSpace, checkSign, ignoreCase, Parse, ihex, clrstr, hexstr
}}
OBJ

 PS2 : "PS2_Controller"
                                
 
PUB init(first_pin, request_delay)         'initializes PS2 object
  PS2.start(first_pin,request_delay)       'first_pin: First of four pins (DAT pin)
                                           'request_delay: Delay(in ms) between requests to poll the controller,
                                           '1000 should for wired and some wireless controllers, if not try 5000

PUB X
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %01000000000000000000000000000000 == %01000000000000000000000000000000
   Result := 0     'return 0
return 
PUB circle
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00100000000000000000000000000000 == %00100000000000000000000000000000
   Result := 0     'return 0
return 
PUB triangle
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00010000000000000000000000000000 == %00010000000000000000000000000000
   Result := 0     'return 0
return
PUB square
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %10000000000000000000000000000000 == %10000000000000000000000000000000
   Result := 0     'return 0
return
PUB R1             
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00001000000000000000000000000000 == %00001000000000000000000000000000
   Result := 0     'return 0
return
PUB R2
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000010000000000000000000000000 == %00000010000000000000000000000000
   Result := 0     'return 0
return
PUB L1
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000100000000000000000000000000 == %00000100000000000000000000000000
   Result := 0     'return 0
return
PUB L2
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000001000000000000000000000000 == %00000001000000000000000000000000
   Result := 0     'return 0
return
Pub D_down         'D pad down arrow
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000010000000000000000000000 == %00000000010000000000000000000000
   Result := 0     'return 0
return
PUB D_up           'D pad up arrow
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000000100000000000000000000 == %00000000000100000000000000000000
   Result := 0     'return 0
return
PUB D_left         'D pad left arrow
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000100000000000000000000000 == %00000000100000000000000000000000
   Result := 0     'return 0
return
PUB D_right        'D pad right arrow
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000001000000000000000000000 == %00000000001000000000000000000000
   Result := 0     'return 0
return
PUB start
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000000010000000000000000000 == %00000000000010000000000000000000
   Result := 0     'return 0
return
PUB select
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000000000010000000000000000 == %00000000000000010000000000000000
   Result := 0     'return 0
return
PUB L3             ' only works when analog is activated
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000000000100000000000000000 == %00000000000000100000000000000000
   Result := 0     'return 0
return
PUB R3             ' only works when analog is activated 
 IF PS2.get_Data1 & %00000000000000000000000000000000 == %00000000000000000000000000000000
   Result := 1     'if button pressed return 1
 IF PS2.get_Data1 & %00000000000001000000000000000000 == %00000000000001000000000000000000
   Result := 0     'return 0
return
PUB RightX         'returns a decimal from 0 to 255(0 being one extreme and 255 being the other extreme
result := PS2.get_rightx
return
PUB RightY         'returns a decimal from 0 to 255(0 being one extreme and 255 being the other extreme
result := PS2.get_righty
return
PUB LeftX          'returns a decimal from 0 to 255(0 being one extreme and 255 being the other extreme
result := PS2.get_leftx
return
PUB LeftY          'returns a decimal from 0 to 255(0 being one extreme and 255 being the other extreme
result := PS2.get_lefty
return
PUB mode | temp    'indicates analog or digital
temp := PS2.get_Data1
result:= byte[@temp][0]  'analog if result == $73, digital if result == $41
return
PUB id | temp    
temp := PS2.get_Data1
result:= byte[@temp][1]
return

DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}          