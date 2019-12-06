{{
TPA81 Object Test

by Joe Lucia - 2joester@gmail.com
http://irobotcreate.googlepages.com

This is to demonstrate the use of the TPA81 object.  This example starts the TPA81Object on a Cog.


}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  RadioRXPin                    = 0 '3.3v device, no resistor necessary
  RadioTXPin                    = 1
  RADIOBAUD                     = 57600

  i2cSCLPin                     = 24                     ' 5v i2c bus
  i2cSDAPin                     = 25

OBJ
  tpa81         : "TPA81Object"
  Radio         : "FullDuplexSerial"                    
  

VAR
  long  spos
  long  sdir
  long  lowscan, highscan
  
PUB Main | x, avg
  Radio.Start(RadioRXPin, RadioTXPin, 0, RADIOBAUD)     
  tpa81.New(i2cSDAPin, i2cSCLPin)                       ' start the Cog

  lowscan :=15
  highscan:=19

  ' set my preferred scan low and high positions 
  tpa81.SetLowScan(lowscan)
  tpa81.SetHighScan(highscan)
  ' set the speed at which to scan and accumulate readings
  tpa81.SetScanSpeed(100)

  ' starting scan direction
  sdir:=1
  ' starting servo position to request                  
  spos:=lowscan
  
  repeat
    waitcnt(clkfreq/1000*50+cnt)

    '' Packet Format:
    'F spos ambientT Pix1T Pix2T Pix3T Pix4T Pix5T Pix6T Pix7T Pix8T [CR]
    radio.tx("F")                                       ' header character
    radio.tx(" ")
    radio.dec(spos)                                     ' servo position
    radio.tx(" ")
    radio.dec(tpa81.AmbientTemperature(spos))           ' ambient temperature at spos
    radio.tx(" ")
    avg:=0    
    repeat x from 0 to 7                                ' output 8 array pixels
      radio.dec(tpa81.GetValue(spos, x))
      radio.tx(" ")    
    radio.tx(13)                                        ' terminator


    ' update servo position we want to read next
    if lowscan <> highscan
      spos := spos + sdir
       
      if spos>highscan
        sdir := -1
        spos := highscan-1
       
      if spos<lowscan
        sdir := 1
        spos := lowscan+1
       

      