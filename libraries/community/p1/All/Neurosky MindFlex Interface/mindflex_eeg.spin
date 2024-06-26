'' NeuroSky Serial Interface for MindFlex and other NeuroSky over Serial
'' ***************************************
'' By Riley August, Robots Everywhere LLC
'' https://www.robots-everywhere.com
'' ***************************************

'' This is a very basic object for talking to a Neurosky-based interface like a Mindflex headset.
'' DO NOT USE A WIRED INTERFACE TO AN EEG IT IS TOO NOISY. Bluetooth HC05 or HC06 is recommended and works out of the box.
'' The MIT License (MIT)
''
''Copyright © 2022 <copyright holders>
''
''Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
''
''The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
''
''THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
''
''Contact Robots Everywhere to collaborate, commercialize, or if you are looking for support with this or other Robots Everywhere software or objects.
VAR
byte freshPacket, inPacket, packetIndex, packetLength, eegPowerLength, hasPower, checksum, checksumAccumulator
byte minSQ, maxSQ
byte signalQuality, attention, meditation
byte payload[256]
byte currentDataValue[256]
byte eegPower[256]
long rawValue
long delta
long theta
long lowalpha
long highalpha
long lowbeta
long highbeta
long lowgamma
long midgamma
byte maxattention
byte maxmeditation
long sqcount, avgsq
OBJ
serial: "FullDuplexSerialExt" ' Input from EEG
com0:"FullDuplexSerialExt" ' Output to other devices or for debugging
con
leftear = 10
rightear = 11
eeginput = 12
led = 9

CON
invertleftear = false
invertrightear = false
leftearfudge = 0
rightearfudge = 0
debug = false ' this shit doesn't really work
CON
syncbyte = $AA
excode = $55
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000                                'Note Clock Speed for your setup!!

PUB Start ' Initialize the serial port, debug port (if on)
  DIRA[led] := 1 ' output pin
  serial.start(eeginput, 23, %1100, 9600)     ' there's no output pin
  if(debug)        ' debug doesn't really work
    com0.start(31,30,%0000,115200)
    com0.str(string("TEST")) ' debug on
    com0.tx(13)
    com0.tx(10)
  OUTA[led] := 0   ' start the LED off. On for good signal. Toggle only if good to bad packet.
  repeat
    reset
    makePacket
    parsePacket
pri makePacket| inbyte, inbyte2
  ' read until 2 sync bytes
  repeat until ((inbyte == inbyte2) AND (inbyte == syncbyte))
    inbyte2 := inbyte
    inbyte := serial.rx
    if(debug)
      if(inbyte == inbyte2)
       com0.str(string("PAIR DETECTED"))
      com0.hex(inbyte, 2)
      com0.tx(13)
      com0.tx(10)
  packetLength := serial.rx
  if(debug)
    com0.str(string("PACKET LENGTH:"))
    com0.dec(packetLength)
    com0.str(string(13,10))
  if(packetLength > 170)
    if(debug)
      com0.str(string("ERROR: Packet too large."))
      com0.tx(13)
    return ' abort with error packet too large
  repeat while (packetIndex < packetLength) ' read the payload
    payload[packetIndex] := serial.rx
    if(debug)
      com0.str(string("NEXT BYTE"))
      com0.hex(payload[packetIndex],2)
      com0.str(string(13,10))
    checksumAccumulator += payload[packetIndex]
    packetIndex++
  ' read the checksum
  checksum := serial.rx ' still need to read checksum byte, can't use it
  ' verify checksum [WE DO NOT SUPPOR THIS FOR THESE EARS]
  'if(checksum <> checksumAccumulator)
    ''com0.str(string("ERROR: Packet Checksum Mismatch"))
    ''com0.tx(checksum)
    ''com0.tx(13)
    ''com0.tx(10)
    ''com0.tx(checksumAccumulator)
    ''com0.tx(13)
    ''com0.tx(10)
  return
pri parsePacket | excodeLevel, code, valueLength, counter
  'if(freshPacket <> true) [code flow doesn't really need this; holdover from old algorithm]
  '  abort
  packetIndex := 0 ' reset index, start reading packet from 0
  repeat while(payload[packetIndex] == excode)
    excodeLevel++
    packetIndex++
  repeat until (packetIndex > packetLength)
    code := payload[packetIndex++]
    case code
      $02:
        signalQuality := payload[packetIndex++]
        if(signalQuality < minSQ)
          minSQ := signalQuality
        if (signalQuality > maxSQ)
          maxSQ := signalQuality
        avgsq := ((sqcount * avgsq) + signalQuality) / (++sqcount)
        if(debug)
          com0.str(string("SIGNAL QUALITY"))
          com0.dec(signalQuality)
          com0.str(string(10,13))
          com0.str(string("MIN SQ"))
          com0.dec(minSQ)
          com0.str(string(10,13))
          com0.str(string("MAX SQ"))
          com0.dec(maxSQ)
          com0.str(string(10,13))
          com0.str(string("AVG SQ"))
          com0.dec(avgSQ)
          com0.str(string(10,13))
        if (signalQuality == 0)
          OUTA[led] := 1  ' led on to detect good signal
        else
          OUTA[led] := 0
      $04:
        attention := payload[packetIndex++]
        if(attention > maxattention)
          maxattention := attention
        if(debug)
         com0.str(string("ATTENTION"))
         com0.dec(attention)
         com0.str(string(10,13))
         com0.str(string("MAXATTENTION"))
         com0.dec(maxattention)
         com0.str(string(10,13))

      $05:

        meditation := payload[packetIndex++]
        if(meditation > maxmeditation)
          maxmeditation := meditation
        if(debug)
          com0.str(string("Meditation"))
          com0.dec(meditation)
          com0.str(string(10,13))
          com0.str(string("MAXMEDITATION"))
          com0.dec(maxmeditation)
          com0.str(string(10,13))
      ' ASIC_EEG_POWER: eight big-endian 3-uint8_t unsigned integer values representing delta,
      'theta, low-alpha high-alpha, low-beta, high-beta, low-gamma, and mid-gamma EEG band
      'power values
      ' The next uint8_t sets the length, usually 24 (Eight 24-bit numbers... big endian?)
      ' We dont' use this value so let's skip it and just increment i
      $83:
        hasPower := true
        packetIndex++ ' skip value length bit
        ' extract the values
        delta := parse24BitBigEndian(payload[packetIndex+=3])' this might be a float

        theta := parse24BitBigEndian(payload[packetIndex+=3])

        lowalpha := parse24BitBigEndian(payload[packetIndex+=3])

        highalpha := parse24BitBigEndian(payload[packetIndex+=3])
        '
        lowbeta := parse24BitBigEndian(payload[packetIndex+=3])

        highbeta := parse24BitBigEndian(payload[packetIndex+=3])
        '
        lowgamma := parse24BitBigEndian(payload[packetIndex+=3])
        '
        midgamma := parse24BitBigEndian(payload[packetIndex+=3])
        if(debug)
          com0.str(string("Eight 24 bit EEG power strings"))
          com0.tx(13)
          com0.dec(delta)
          com0.tx(13)
          com0.tx(10)
          com0.dec(theta)
          com0.tx(13)
          com0.tx(10)
          com0.dec(lowalpha)
          com0.tx(13)
          com0.tx(10)
          com0.dec(highalpha)
          com0.tx(13)
          com0.tx(10)
          com0.dec(lowbeta)
          com0.tx(13)
          com0.tx(10)
          com0.dec(highbeta)
          com0.tx(13)
          com0.tx(10)
          com0.dec(lowgamma)
          com0.tx(13)
          com0.tx(10)
          com0.dec(midgamma)
          com0.tx(13)
          com0.tx(10)
        if(signalQuality <> 0)
          com0.str(string("Output is good"))
      $80: 'Unsupported by arduino Brain; this is a 16 bit raw value out
        packetIndex++
        rawValue := (payload[packetIndex++] << 8) + payload[packetIndex++]
      OTHER: ' error
       if(debug)
        com0.str(string("ERROR: Couldn't parse packet with code: "))
        com0.hex(code, 2)
        com0.tx(13)
        com0.tx(10)
        com0.tx("*")
pri reset ' turn off the led, reset packet variables, get ready to wait for a new packet
  OUTA[led]:= 0 ' turn the led off
  packetIndex := 0
  eegPowerLength := 0
  checksumAccumulator := 0
  attention := 0
  meditation := 0
  BYTEFILL(@payload, 0, 256)
  packetLength := 0
  freshPacket := false
pri parse24BitBigEndian(initial): value
  value := initial.BYTE[2] << 16 + initial.BYTE[1] << 8 + initial.BYTE[0]
  return value
pri parseBigEndianFloat(initial): value
  value := initial.BYTE[3] << 24 + initial.BYTE[2] << 16 + initial.BYTE[1] << 8 + initial.BYTE[0]
  return value