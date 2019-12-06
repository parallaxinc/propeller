{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// S35390A Real Time Clock Engine
//
// Author: Kwabena W. Agyeman
// Updated: 3/23/2011
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2011 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 3/23/2011.
//
// For each included copy of this object only one spin interpreter should access it at a time.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// I2C Circuit:
//
//                  3.3V
//                   |
//                   R 10KOHM
//                   |
// Data Pin Number  --- S35390A SDA Pin.
//
//                  3.3V
//                   |
//                   R 10KOHM
//                   |
// Clock Pin Number --- S35390A SCL Pin.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  #1, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
  #1, January, February, March, April, May, June, July, August, September, October, November, December
  #16, INT_1Hz, #8, INT_2Hz, #4, INT_4Hz, #2, INT_8Hz, #1, INT_16Hz

VAR byte time[8]

PUB clockSecond '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached second (0 - 59) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return time

PUB clockMinute '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached minute (0 - 59) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return time[1]

PUB clockHour '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached hour (0 - 23) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := time[2]
  if(result > 11)
    result -= 40

PUB clockDay '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached day (1 - 7) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (time[3] + 1)

PUB clockDate '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached date (1 - 31) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return time[4]

PUB clockMonth '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached month (1 - 12) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return time[5]

PUB clockYear '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached year (2000 - 2099) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (time[6] + 2_000)

PUB clockMeridiemHour '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the cached meridiem hour (12 - 11) from the real time clock.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := (clockHour // 12)
  ifnot(result)
    result += 12

PUB clockMeridiemTime '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true if the cached meridiem hour is post meridiem and false if the meridiem cached hour is ante meridiem.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (clockHour => 12)

PUB clockCorrection(value) '' 19 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Changes the clock correction's register value. Returns true on success and false on failure.
'' //
'' // Value - The value to change the clock correction location to. (0 - 255). Please refer to the S35390A datasheet.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(6, $FF, (value >< 8))

PUB readTime | buffer, counter '' 9 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Caches the current real time clock settings. Returns true on success and false on failure.
'' //
'' // Call "checkSecond" to get the real time clock second after calling this method first.
'' // Call "checkMinute" to get the real time clock minute after calling this method first.
'' // Call "checkHour" to get the real time clock hour after calling this method first.
'' // Call "checkDay" to get the real time clock day after calling this method first.
'' // Call "checkDate" to get the real time clock date after calling this method first.
'' // Call "checkMonth" to get the real time clock month after calling this method first.
'' // Call "checkYear" to get the real time clock year after calling this method first.
'' // Call "checkMeridiemHour" to get the real time clock meridiem hour after calling this method first.
'' // Call "checkMeridiemTime" to get the real time clock meridiem time after calling this method first.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  bytefill(@time, 0, 8)

  startDataTransfer
  result := transmitPacket(constant((%0110_010 << 1) | 1))

  if(result)
    repeat counter from 6 to 0
      buffer := (receivePacket(counter) >< 8)
      time[counter] := (((buffer >> 4) * 10) + (buffer & $F))

  stopDataTransfer

PUB writeTime(second, minute, hour, day, date, month, year) | index, information[7] '' 33 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Changes the current real time clock time settings. Returns true on success and false on failure.
'' //
'' // Second - Number to set the second to between 0 - 59.
'' // Minute - Number to set the minute to between 0 - 59.
'' // Hour - Number to set the hour to between 0 - 23.
'' // Day - Number to set the day to between 1 - 7.
'' // Date - Number to set the date to between 1 - 31.
'' // Month - Number to set the month to between 1 - 12.
'' // Year - Number to set the year to between 2000 - 2099.
'' //
'' // If the real time clock was previously powered on but not initialized this method will initialize the real time clock
'' // setting all registers to zero and clearing all interrupts. After doing so the time and date will be setup.
'' //
'' // If the real time clock previously browned out but was not re-initialized this method will re-initialize the real time
'' // clock setting all registers to zero and clearing all interrupts. After doing so the time and date will be setup.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if((readRegister(0) & $3) or (readRegister(1) & $1))
    modifyRegister(0, $80, $80)

  result := modifyRegister(0, $40, $40)
  if(result)

    information := ((second <# 59) #> 0)
    information[1] := ((minute <# 59) #> 0)
    information[2] := ((hour <# 23) #> 0)
    information[3] := (((day <# 7) #> 1) - 1)
    information[4] := ((date <# 31) #> 1)
    information[5] := ((month <# 12) #> 1)
    information[6] := (((year <# 2_099) #> 2_000) - 2_000)

    startDataTransfer

    result and= transmitPacket(constant((%0110_010 << 1) | 0))

    repeat index from 6 to 0
      result and= transmitPacket(convertTime(information[index]))

    stopDataTransfer

PUB INT1Shutdown '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Shutsdown all interrupt functionality of INT1. Returns true on success and false on failure.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $F0, $0)

PUB INT2Shutdown '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Shutsdown all interrupt functionality of INT2. Returns true on success and false on failure.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $E, $0)

PUB INT1Frequency(frequencies) '' 19 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT1 pin toggle at the specified AND'ed frequencies. Returns true on success and false on failure.
'' //
'' // The INT1 pin mirrors the output of the below five frequencies logically AND'ed together for each enabled frequency.
'' //
'' // Frequencies - (Bit 4 = 1 Hz), (Bit 3 = 2 Hz), (Bit 2 = 4 Hz), (Bit 1 = 8 Hz), (Bit 0 = 16 Hz). 1 = On, 0 = Off.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := clearAlarmInterrupt(4, 0)
  result and= modifyRegister(1, $F0, $80)
  result and= clearAlarmInterrupt(4, (frequencies << 3))

PUB INT2Frequency(frequencies) '' 19 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT2 pin toggle at the specified AND'ed frequencies. Returns true on success and false on failure.
'' //
'' // The INT2 pin mirrors the output of the below five frequencies logically AND'ed together for each enabled frequency.
'' //
'' // Frequencies - (Bit 4 = 1 Hz), (Bit 3 = 2 Hz), (Bit 2 = 4 Hz), (Bit 1 = 8 Hz), (Bit 0 = 16 Hz). 1 = On, 0 = Off.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := clearAlarmInterrupt(5, 0)
  result and= modifyRegister(1, $E, $8)
  result and= clearAlarmInterrupt(5, (frequencies << 3))

PUB INT1PerMinuteEdge '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT1 pin go low every minute. Returns true on success and false on failure.
'' //
'' // The INT1 pin does not return back to high automatically.
'' //
'' // The INT1 functionality must be shutdown and then reset to per-minute edge again to re-trigger.
'' //
'' // If turned off and then on after an edge in 7.9 ms the output is low again. Reset after a 7.9 ms wait to avoid problems.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $F0, $40)

PUB INT2PerMinuteEdge '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT2 pin go low every minute. Returns true on success and false on failure.
'' //
'' // The INT2 pin does not return back to high automatically.
'' //
'' // The INT2 functionality must be shutdown and then reset to per-minute edge again to re-trigger.
'' //
'' // If turned off and then on after an edge in 7.9 ms the output is low again. Reset after a 7.9 ms wait to avoid problems.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $E, $4)

PUB INT1MinutePeriodical '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT1 pin toggle between high and low every minute. Returns true on success and false on failure.
'' //
'' // The output has a 50% duty cycle. The pin is high 30 s and low 30 s.
'' //
'' // If turned off and then on after an edge in 7.9 ms the output is high or low again (depending on the previous state).
'' //
'' // Reset after a 7.9 ms wait after an edge to avoid problems.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $F0, $C0)

PUB INT2MinutePeriodical '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT2 pin toggle between high and low every minute. Returns true on success and false on failure.
'' //
'' // The output has a 50% duty cycle. The pin is high 30 s and low 30 s.
'' //
'' // If turned off and then on after an edge in 7.9 ms the output is high or low again (depending on the previous state).
'' //
'' // Reset after a 7.9 ms wait after an edge to avoid problems.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $E, $C)

PUB INT1Alarm(week, hour, minute) '' 21 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT1 pin go low and stay low when the alarm triggers. Returns true on success and false on failure.
'' //
'' // Turn off the alarm and then re-enable the alarm to reset the trigger.
'' //
'' // Only triggers once in the matching period - unless the minute, hour, or week changes again during the matching period.
'' //
'' // Week - The day of the week the alarm should trigger. -1 for don't care. (1 - 7).
'' // Hour - The hour of the day the alarm should trigger. -1 for don't care. (0 - 23).
'' // Minute - The minute of the day the alarm should trigger. -1 for don't care. (0 - 59).
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := clearAlarmInterrupt(4, 0)
  result and= modifyRegister(1, $F0, $20)
  result and= setAlarmInterrupt(4, week, hour, minute)

PUB INT2Alarm(week, hour, minute) '' 21 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT2 pin go low and stay low when the alarm triggers. Returns true on success and false on failure.
'' //
'' // Turn off the alarm and then re-enable the alarm to reset the trigger.
'' //
'' // Only triggers once in the matching period - unless the minute, hour, or week changes again during the matching period.
'' //
'' // Week - The day of the week the alarm should trigger. -1 for don't care. (1 - 7).
'' // Hour - The hour of the day the alarm should trigger. -1 for don't care. (0 - 23).
'' // Minute - The minute of the day the alarm should trigger. -1 for don't care. (0 - 59).
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := clearAlarmInterrupt(5, 0)
  result and= modifyRegister(1, $E, $2)
  result and= setAlarmInterrupt(5, week, hour, minute)

PUB INT1AlarmCheck '' 11 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true after the INT1 alarm triggers - and then sets the flag being checked to false.
'' //
'' // After the alarm triggers the flag being checked is reset back to high after every second until the alarm is turned off.
'' //
'' // The flag status is temporarily cleared if the time is written after the trigger has gone off or alarm 2 is checked.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result or= (readRegister(0) & $8)

PUB INT2AlarmCheck '' 11 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true after the INT2 alarm triggers - and then sets the flag being checked to false.
'' //
'' // After the alarm triggers the flag being checked is reset back to high after every second until the alarm is turned off.
'' //
'' // The flag status is temporarily cleared if the time is written after the trigger has gone off or alarm 1 is checked.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result or= (readRegister(0) & $4)

PUB INT1MinuteEdge '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT1 pin toggle between high and low every minute. Returns true on success and false on failure.
'' //
'' // The output does not have a 50% duty cycle. The pin is high 59.9921 s and low 7.9 ms.
'' //
'' // The output will delay going low for 0.5 s if the real time data is being read during the minute edge.
'' //
'' // If the real time data is being written the output will re-synchronize to the next minute edge.
'' //
'' // For example: If the seconds register is set to 50 s the output will go low in 10 s. If set to 10 s, goes low in 50 s.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $F0, $E0)

PUB INT1ClockFrequency '' 18 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Makes the INT1 pin toggle between high and low at 32,768 Hz. Returns true on success and false on failure.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(1, $F0, $10)

PUB readFreeRegister '' 11 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Reads a value from the free register.
'' //
'' // Returns the value on success and false on failure.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (readRegister(7) >< 8)

PUB writeFreeRegister(value) '' 19 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Writes a value to the free register. Returns true on success and false on failure.
'' //
'' // Value - The value to write (0 - 255).
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return modifyRegister(7, $FF, (value >< 8))

PUB pauseForSeconds(number) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Pauses execution for a number of seconds.
'' //
'' // Number - Number of seconds to pause for between 0 and 4,294,967,295.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := cnt
  repeat number
    result += clkfreq
    waitcnt(result)

PUB pauseForMilliseconds(number) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Pauses execution for a number of milliseconds.
'' //
'' // Number - Number of milliseconds to pause for between 0 and 4,294,967,295.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := cnt
  repeat number
    result += (clkfreq / 1_000)
    waitcnt(result)

PUB RTCEngineStart(dataPinNumber, clockPinNumber, lockNumberToUse) '' 9 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Changes the I2C Circuit pins.
'' //
'' // Returns true on success and false on failure.
'' //
'' // DataPinNumber - Pin to use to drive the SDA data line circuit. Between 0 and 31.
'' // ClockPinNumber - Pin to use to drive the SCL clock line circuit. Between 0 and 31.
'' // LockNumberToUse - Lock number to use if sharing the I2C bus (0 - 7). -1 to disable.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  RTCEngineStop

  dataPin := dataPinNumber
  clockPin := clockPinNumber
  lockNumber := (((lockNumberToUse & $7) + 1) & (lockNumberToUse <> -1))
  return ((dataPinNumber <> clockPinNumber) and (chipver == 1))

PUB RTCEngineStop '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Clears the cached real time clock settings.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  bytefill(@time, 0, 8)

PRI clearAlarmInterrupt(command, data) ' 9 Stack Longs

  startDataTransfer
  result := transmitPacket(computeCommand(command))

  repeat 3
    result and= transmitPacket(data)

  stopDataTransfer

PRI setAlarmInterrupt(command, week, hour, minute) | temporary ' 12 Stack Longs

  startDataTransfer

  result := transmitPacket(computeCommand(command))
  result and= transmitPacket(convertTime(((week <# 7) #> 1) - 1) | ((week <> -1) & 1))

  temporary := ((hour <# 23) #> 0)

  result and= transmitPacket(convertTime(temporary) | ((temporary > 11) & $2) | ((hour <> -1) & $1))
  result and= transmitPacket(convertTime((minute <# 59) #> 0) | ((minute <> -1) & 1))

  stopDataTransfer

PRI modifyRegister(command, mask, data) | temporary ' 15 Stack Longs

  temporary := readRegister(command)

  startDataTransfer

  result := transmitPacket(computeCommand(command))
  result and= transmitPacket((mask & data) | ((!mask) & temporary))

  stopDataTransfer

PRI readRegister(command) ' 8 Stack Longs

  startDataTransfer

  result := transmitPacket(computeCommand(command) | 1)
  result &= receivePacket(false)

  stopDataTransfer

PRI computeCommand(command) ' 4 Stack Longs

  return ((constant(%0110_000) | (command & $7)) << 1)

PRI convertTime(decimal) ' 4 Stack Longs

  return ((((decimal / 10) << 4) + (decimal // 10)) >< 8)

PRI transmitPacket(value) ' 4 Stack Longs

  value := ((!value) >< 8)

  repeat 8
    dira[dataPin] := value
    dira[clockPin] := false
    dira[clockPin] := true
    value >>= 1

  dira[dataPin] := false
  dira[clockPin] := false
  result := not(ina[dataPin])
  dira[clockPin] := true
  dira[dataPin] := true

PRI receivePacket(aknowledge) ' 4 Stack Longs

  dira[dataPin] := false

  repeat 8
    result <<= 1
    dira[clockPin] := false
    result |= ina[dataPin]
    dira[clockPin] := true

  dira[dataPin] := (not(not(aknowledge)))
  dira[clockPin] := false
  dira[clockPin] := true
  dira[dataPin] := true

PRI startDataTransfer ' 3 Stack Longs

  if(lockNumber)
    repeat while(lockset(lockNumber - 1))

  outa[dataPin] := false
  outa[clockPin] := false
  dira[dataPin] := true
  dira[clockPin] := true

PRI stopDataTransfer ' 3 Stack Longs

  dira[clockPin] := false
  dira[dataPin] := false

  if(lockNumber)
    lockclr(lockNumber - 1)

DAT

' //////////////////////Variable Array/////////////////////////////////////////////////////////////////////////////////////////

dataPin                 byte 29 ' Default data pin.
clockPin                byte 28 ' Default clock pin.
lockNumber              byte 00 ' Driver lock number.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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