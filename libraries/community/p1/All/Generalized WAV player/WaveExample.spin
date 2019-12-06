'  Example of waveplayer usage

con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  bufferLen = 800

obj
  ser : "FullDuplexSerial"
  wpl : "WavePlayerSdAccess"

var                 
  byte buff[bufferLen]
  long stack[50]

pub main | sdBasePin, HeadphoneRightPin, HeadphoneLeftPin
  ser.start(31,30,0,19200)
  'wait for any input from terminal
  'ser.rx

  'change values to match your setup
  sdBasePin := 12
  HeadphoneRightPin := 24
  HeadphoneLeftPin := 25
  wpl.start(sdBasePin, HeadphoneRightPin, HeadphoneLeftPin, @buff, bufferLen)

  'not nessesary if background playing isn't needed(only uses extra cog while playing)
  wpl.setStack(@stack)
       
  ser.str(string("Wave Player example", 13))   

  'replace "winst.wav" with any wav on your sd card        
  wpl.playbgwave(string("winst.wav"))

  'possibly anoying but pause and unpause wave playing in background  
  repeat while wpl.bgisPlaying
    waitcnt(cnt + 20_000_000)
    'wpl.togglebgPause

  'play wave again using current cog
  wpl.playwave(string("winst.wav"))

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