{     Copyright (c) 2008 Parallax & Alexander Stevenson & Spencer Crockett

        Basic driver for the Memkey tool. Just for reference, all we've done so far is break the
        memkey out of the package, hook it up to a 4x4 Matrix Keypad from the parallax store,
        and using the default values of the keys (0 - 15) read back each individual key.
        Assuming the use of an LCD object to display the values pressed, our testing program
        resembled this : 

                con
                  delay = 3_000_000
                  _clkmode = xtal1 + pll4x
                  _xinfreq = 10_000_000
                 
                obj
                  memkey : "memkey"
                  lcd : "LCD"
                var
                  long y
                PUB main
                  memkey.init(2, 3, 2400) 
                  lcd.start(8, 2400)
                  lcd.on
                  repeat
                    lcd.cls
                    lcd.str(string("Hello") )
                    waitcnt(cnt + clkfreq)
                    lcd.cls
                    y := memkey.read
                    lcd.str(string("value ="))
                    lcd.print(y)
                    waitcnt(cnt + clkfreq)

        With this program we initialized the memkey on pins 2 & 3, started our LCD on pin 8,
        and looped a memkey reader to read the keys as we pressed them. Feel free to edit to
        revise any code as you deem fit, and if you come up with any ways to improve this let
        me know at astevenson@lorch.com, or pm Aleks on the parallax forums. We will continue
        to update this as necessary to repair any bugs we come across, and to add to the program.

**| Requires the use of Simple_Serial.spin, available for download at Parallax's Propeller Object
        Exchange  |** 

**| Revision History |**

	~8-27-2008	Updated the driver to include program(...) and reset, used to personalize
			the key structure of the attached keypad, and to reset to default values,
			respectively.   *Work of Spencer Crockett*    
}
con
  changekey = $0A
  keyreset = $11
  
var
  long x, tx, fx, rate
  
obj
  comm : "Simple_Serial"
  
pub init(tm, fm, baud)                                  'Use to identify the tx and rx pins, and the baud rate
  tx := tm
  fx := fm
  rate := baud
  
pub read                                                'Returns the value of the pressed key
  comm.start(fx, tx, rate)
  x := comm.rx
  comm.stop
  return x

pub program (key, value)                                'Used to program the key to return a specified value
  comm.start(fx, tx, rate)     				'Key is physical key to change (see key map), value
  comm.tx($0A)                 				'is desired value to change key to
  comm.tx(key)                 
  comm.tx(value)               
  comm.stop
                  
pub reset                                                 'Resets the keypad to it's original values
  comm.start(fx, tx, rate)                                
  comm.tx($11)                 
  comm.stop   
  
{
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
 }











