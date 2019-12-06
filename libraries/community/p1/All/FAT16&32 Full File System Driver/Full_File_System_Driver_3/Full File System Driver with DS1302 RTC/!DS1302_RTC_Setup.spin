{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DS1302 RTC Setup
//
// Author: Kwabena W. Agyeman
// Updated: 3/23/2011
// Designed For: P8X32A
// Version: 1.0 - Special
//
// Copyright (c) 2011 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Special - Original release - 3/23/2011.
//
// On startup the program writes to the real time clock module.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x ' The clkfreq is 80MHz.
  _xinfreq = 5_000_000 ' Demo board compatible.

  _rtciopin = 14 ' -1 if unused.
  _rtcsclkpin = 15 ' -1 if unused.
  _rtccepin = 13 ' -1 if unused.

  _set_year_to = 2011 ' 2000 to 2099.
  _set_month_to = 3 ' 1 to 12.
  _set_date_to = 24 ' 1 to 31. For most months.
  _set_day_to = 5 ' 1 = Sunday, 2 = Monday, ..., 7 = Saturday.
  _set_hours_to = 11 ' 0 to 23.
  _set_minutes_to = 0 ' 0 to 59.
  _set_seconds_to = 0 ' 0 to 59.

OBJ

  rtc: "DS1302_RTCEngine.spin"

PUB main

  ' "rtcEngineStart" must be called first to setup and pins.
  rtc.rtcEngineStart(_rtciopin, _rtcsclkpin, _rtccepin)

  ' "rtcWriteTime" updates the time of any real time clock attached.
  rtc.writeTime(_set_seconds_to, _set_minutes_to, _set_hours_to, _set_day_to, _set_date_to, _set_month_to, _set_year_to)

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