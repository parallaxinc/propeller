{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SD Card Profiler
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
// On startup the program blinks the status LED at 4 Hz signaling that it is writing basic file system data. After the program
// finishes writing basic file system data it then begins to speed test the file system and blink the status LED at 8 Hz. Once
// finished speed testing the file system the program then waits for reset or power down and keeps the status LED lit solid.
// If an error occurs that the program is unable to handle it will blink the status LED at 1 Hz and wait for reset or power
// down. Remove the SD card from the propeller chip once the program finishes as indicated by the status LED and insert the SD
// card into a computer to see the results of the profiler. Do not remove the SD card until the propeller chip is finished
// running the profiler program or the SD card partition may become corrupted.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x ' The clkfreq is 80MHz.
  _xinfreq = 5_000_000 ' Demo board compatible.

  _dopin = 0
  _clkpin = 1
  _dipin = 2
  _cspin = 3
  _cdpin = -1 ' -1 if unused.
  _wppin = -1 ' -1 if unused.

  _rtcres1 = -1 ' -1 always.
  _rtcres2 = -1 ' -1 always.  
  _rtcres3 = -1 ' -1 always.  

  _statuspin = 23 ' Status LED pin number.

OBJ

  fat0: "SD-MMC_FATEngine.spin"
  fat1: "SD-MMC_FATEngine.spin"

PUB main | errorString

  ' "fatEngineStart" is only called once. Either driver object can call it.
  fat0.fatEngineStart( _dopin, _clkpin, _dipin, _cspin, _wppin, _cdpin, {
                    } _rtcres1, _rtcres2, _rtcres3)

  statusLED(4) ' Make the status LED blink quickly.
  errorString := \profiler ' Returns the address of the error string or null.

  if(fat0.partitionMounted)
    \fat0.unmountPartition
  if(fat1.partitionMounted)
    \fat1.unmountPartition

  if(errorString)
    statusLED(1) ' Blink the LED if an error occurs.
  else
    statusLED(-1) ' Light the LED if no error occurred.

  waitcnt(clkfreq + cnt)
  fat0.fatEngineStop ' Give the block driver a second to finish up.

  repeat ' Wait until reset or power down.

PRI profiler | errorString, errorNumber, buffer, counter, data[128] ' Separate method to trap aborts.

  fat0.mountPartition(0)
  fat1.mountPartition(0)

  ' Try to create a new file called "Profile.txt".
  errorString := \fat0.newFile(string("Profile.txt"))
  errorNumber :=  fat0.partitionError ' Returns zero if no error occurred.

  if(errorNumber) ' Try to handle the "entry_already_exist" error.
    if(errorNumber == fat0#Entry_Already_Exist)

      ' Re-create the file.
      fat0.deleteEntry(string("Profile.txt"))
      fat0.newFile(string("Profile.txt"))

    else
      abort errorString ' Unable to handle the error. Continue passing the error.

  ' Try to create a new file called "Test.dat".
  errorString := \fat1.newFile(string("Test.dat"))
  errorNumber :=  fat1.partitionError ' Returns zero if no error occurred.

  if(errorNumber) ' Try to handle the "entry_already_exist" error.
    if(errorNumber == fat1#Entry_Already_Exist)

      ' Re-create the file.
      fat1.deleteEntry(string("Test.dat"))
      fat1.newFile(string("Test.dat"))

    else
      abort errorString ' Unable to handle the error. Continue passing the error.

  fat0.openFile(string("Profile.txt"), "W")
  fat1.openFile(string("Test.dat"), "W")

  fat0.writeString(string("### SD Card Profile ###", 13, 10, 13, 10))
  fat0.writeString(string("Disk Signature: "))
  printHexadecimal(fat0.partitionDiskSignature)

  fat0.writeString(string(13, 10, 13, 10, "Partition 0 - "))
  printHexadecimal(fat0.partitionVolumeIdentification)
  fat0.writeString(string(13, 10))

  fat0.writeString(fat0.partitionVolumeLabel)
  fat0.writeByte(" ")
  fat0.writeString(fat0.partitionFileSystemType)
  fat0.writeString(string(13, 10, 13, 10))

  printDecimal(fat0.partitionBytesPerSector)
  fat0.writeString(string(" - Bytes Per Sector", 13, 10))
  printDecimal(fat0.partitionSectorsPerCluster)
  fat0.writeString(string(" - Sectors Per Cluster", 13, 10))
  printDecimal(fat0.partitionDataSectors)
  fat0.writeString(string(" - Total Sectors", 13, 10))
  printDecimal(fat0.partitionCountOfClusters)
  fat0.writeString(string(" - Total Clusters", 13, 10))
  printDecimal(fat0.partitionUsedSectorCount("F"))
  fat0.writeString(string(" - Used Sectors", 13, 10))
  printDecimal(fat0.partitionFreeSectorCount("F"))
  fat0.writeString(string(" - Free Sectors", 13, 10, 13, 10))

  fat0.writeString(string("32 KB Stride Speed Test:", 13, 10, 13, 10))
  statusLED(8) ' Make the LED blink even faster.

  ' Start speed test.

  fat0.writeString(string("writeByte - "))
  buffer := cnt
  repeat counter from 32_768 to 65_535 step 1
    fat1.writeByte(byte[counter])
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))

  fat0.writeString(string("writeShort - "))
  buffer := cnt
  repeat counter from 32_768 to 65_535 step 2
    fat1.writeShort(word[counter])
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))

  fat0.writeString(string("writeLong - "))
  buffer := cnt
  repeat counter from 32_768 to 65_535 step 4
    fat1.writeLong(long[counter])
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))

  fat0.writeString(string("writeData - "))
  buffer := cnt
  fat1.writeData(32_768, 32_768)
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))
  fat1.fileSeek(0) ' Back to the beginning.

  fat0.writeString(string("readByte - "))
  buffer := cnt
  repeat counter from 32_768 to 65_535 step 1
    if(fat1.readByte <> byte[counter])
      fat0.writeString(string("Failure", 13, 10))
      abort string("Failure")
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))

  fat0.writeString(string("readShort - "))
  buffer := cnt
  repeat counter from 32_768 to 65_535 step 2
    if(fat1.readShort <> word[counter])
      fat0.writeString(string("Failure", 13, 10))
      abort string("Failure")
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))

  fat0.writeString(string("readLong - "))
  buffer := cnt
  repeat counter from 32_768 to 65_535 step 4
    if(fat1.readLong <> long[counter])
      fat0.writeString(string("Failure", 13, 10))
      abort string("Failure")
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))

  fat0.writeString(string("readData - "))
  buffer := cnt
  fat1.readData(32_768, 32_768)
  printDecimal(multiplyDivide(32_768, (cnt - buffer)) >> 10)
  fat0.writeString(string(" KBs", 13, 10))
  fat1.fileSeek(fat1.fileTell - 32_768) ' Go back to verify written data.

  repeat counter from 32_768 to 65_535 step 512
    ' Read in 512 bytes at a time.
    fat1.readData(@data, 512)
    repeat buffer from 0 to 127
      ' Verify 128 longs at a time.
      if(data[buffer] <> long[counter + (buffer << 2)])
        fat0.writeString(string("Failure", 13, 10))
        abort string("Failure")

  ' End speed test and close all open files.

  fat0.unmountPartition
  fat1.unmountPartition

PRI printDecimal(integer) | temp[3] ' Writes a decimal string.

  if(integer < 0) ' Print sign.
    fat0.writeByte("-")

  byte[@temp][10] := 0
  repeat result from 9 to 0 ' Convert number.
    byte[@temp][result] := ((||(integer // 10)) + "0")
    integer /= 10

  result := @temp ' Skip past leading zeros.
  repeat while((byte[result] == "0") and (byte[result + 1]))
    result += 1

  fat0.writeString(result~) ' Print number.

PRI printHexadecimal(integer) ' Writes a hexadecimal string.

  fat0.writeString(string("0x")) ' Write header.

  repeat 8 ' Print number.
    integer <-= 4
    fat0.writeByte(lookupz((integer & $F): "0".."9", "A".."F"))

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

PRI multiplyDivide(dividen, divisor) | productHigh, productLow

  productHigh := (clkfreq ** dividen)
  productLow := (clkfreq * dividen)

  if((productHigh ^ negx) < (divisor ^ negx)) ' Return 0 on overflow.
    result := 1
    repeat 32 ' Preform (((clkfreq * dividen) / divisor) + 1) ... all unsigned.

      dividen := (productHigh < 0) ' Carry bit.
      productHigh := ((productHigh << 1) + (productLow >> 31))
      productLow <<= 1
      result <-= 1

      if(((productHigh ^ negx) => (divisor ^ negx)) or dividen) ' Unsigned "=>".
        productHigh -= divisor
        result += 1

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