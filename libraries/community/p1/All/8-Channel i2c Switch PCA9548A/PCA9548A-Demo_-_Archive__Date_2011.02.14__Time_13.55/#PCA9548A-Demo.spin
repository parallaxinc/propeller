{{
''   File....... PCA9548A Demo File
''   Purpose.... Refer to PCA9548A Object File
''               Reading the 3AD Accelerometer as Demo
''   Author..... MacTuxLin
''               Copyright (c) 2011 
''               -- see below for terms of use
''   E-mail..... MacTuxLin@gmil.com
''   Started.... 30 Jan 2011
''   Updated.... Refer to PCA9548A Object File

}}


CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                                          ' use 5MHz crystal

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000
  US_001   = CLK_FREQ / 1_000_000


CON

  'Use for comm with PST 
  _Rx1 = 31
  _Tx1 = 30
  _PST_Mode = 0
  _BaudRate = 57_600



CON

  'Device Address of 3AD Accelerometer
  _add3AD_1 = $1D


OBJ

  Com : "FullDuplexSerial_rr004"
  PCA : "PCA9548Av1"   'I2C 1-to-8 Switch


PUB Main | x

  'Setting for PST
  ifnot Com.Start(_Rx1, _Tx1, _PST_Mode, _BaudRate)
    reboot
  waitcnt(cnt + clkfreq*3)
  Com.Tx(0)


  'This is required to set which i2c device you would want to start communicating wth.
  'After this there is no limit to the amount of data you want to send to your i2c device UNTIL
  'you want to communicate with another i2c device on another channel.
  'Just a thought but not tested, seems that if the i2c is addressable, you can connect 8xtotal addressable i2c device!  
  Com.Str(String("Select Device 4 ... Reply: "))
  Com.Bin(PCA.PSelect(4, 0), 8)   '<--Reply %00000000 means PASSED. If not, the bit that fails will tell you which portion of the setting failed. 
  Com.Tx(13)


  'Once the above passed, you can start the normal communication with whatever i2c device
  'is connected to the channel you've selected.
  Com.Str(String("Init 3AD @ SD4... Reply: "))
  Com.Bin(PCA.Debug_PWriteAccelReg(_add3AD_1, $16, %0101), 8)   '<--Reply %00000000 means PASSED. If not, the bit that fails will tell you which portion of the setting failed.
  Com.Tx(13)
  waitcnt(cnt + clkfreq*3)
    
  repeat
    x := PCA.Get3AD_X8(4, _add3AD_1)   'I2CDevice# & 3AD Address connected on PCA9548A
  
    Com.Str(String("X Point : "))
    Com.Dec(x)
    Com.Tx(13)
    waitcnt(cnt + clkfreq/100)
         
    
    

       

dat

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}

    