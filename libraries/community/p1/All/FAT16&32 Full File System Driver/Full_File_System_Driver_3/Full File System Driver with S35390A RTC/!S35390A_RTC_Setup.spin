{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// S35390A RTC Setup
//
// Author: Kwabena W. Agyeman
// Updated: 3/13/2011
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2011 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 3/13/2011.
//
// On startup the program writes to the real time clock module. Once the program finishes it will wait for reset or power down
// and keep the status LED lit solid. If an error occurs it will blink the status LED at 1 Hz and wait for reset or power
// down. Setup the new time and date for the real time clock below.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x ' The clkfreq is 80MHz.
  _xinfreq = 5_000_000 ' Demo board compatible.

  _rtcclkpin = 28 ' -1 if unused.
  _rtcdatpin = 29 ' -1 if unused.
  _rtcbuslck = -1 ' -1 if unused.

  _statuspin = 23 ' Status LED pin number.

  _set_year_to = 2011 ' 2000 to 2099.
  _set_month_to = 3 ' 1 to 12.
  _set_date_to = 13 ' 1 to 31. For most months.
  _set_day_to = 1 ' 1 = Sunday, 2 = Monday, ..., 7 = Saturday.
  _set_hours_to = 1 ' 0 to 23.
  _set_minutes_to = 36 ' 0 to 59.
  _set_seconds_to = 0 ' 0 to 59.

OBJ

  rtc: "S35390A_RTCEngine.spin"

PUB main

  ' "rtcEngineStart" must be called first to setup and pins and lock number.
  rtc.rtcEngineStart(_rtcdatpin, _rtcclkpin, _rtcbuslck)

  if(rtc.writeTime(_set_seconds_to, _set_minutes_to, _set_hours_to, _set_day_to, _set_date_to, _set_month_to, _set_year_to))
    statusLED(-1) ' Light the LED if no error occurred.
  else
    statusLED(1) ' Blink the LED if an error occurs.

  repeat ' Wait until reset or power down.

PRI statusLED(frequency) | buffer, counter ' Configure the status LED.

  ' Frequency must be between 0 and (clkfreq / 2). Otherwise output is always 1.

  buffer := ((0 < frequency) and (frequency =< (clkfreq >> 1)))

  outa[_statuspin] := (not(buffer))
  ctra := (buffer & constant((%00100 << 26) + _statuspin))
  dira[_statuspin] := true

  counter := 1
  repeat 32 ' Preform (((frequency << 32) / clkfreq) + 1)

    frequency <<= 1
    counter <-= 1

    if(frequency => clkfreq)
      frequency -= clkfreq
      counter += 1

  frqa := (buffer & counter) ' Output is always 0 if frequency is 0.

{{

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}