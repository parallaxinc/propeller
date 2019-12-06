{
        Copyright (c) 2008 Parallax & Alexander Stevenson
        See end of file for terms of use.

                                *****************|| Absolute Magnetic Encoder ||*********************

  With the implementation of this program, the utilization of the MA3-P12 absolute magnetic encoder, as offered
  by US Digital, will become possible. I have taken the time to carefully review the data sheet, and have come to realize
  that the data output is actually based on a PWM system, instead of the standard I2C communication we have been
  implementing with the DRBG-11-AA-01AA resolver, as offered by Moog Components Group, that we were using previously. This
  library should hopefully monitor the input of the resolver pin and match the PWM to a specific shaft angle in order to
  give us our relative shaft location, and thus the location of all parts in the drivetrain of the connected system.

  **| note |**
  
  8-19-2008     This program is not perfect. I am using it simply because it works for my purpose. In all reality, the MA3-P12
                has a 4096 resolution, and I am securing well over this number. This is because I am using a crude method of
                measuring the duty cycle to determine a rough estimate of it's location. I will continue to modify this code
                and provide, soon, the true 4096 resolution offered by this marvelous product. 
                 
}

var
  long pin, controller, motor, set, counter[10]

pub initialize(input)                                   'Use this routine to declare the data line of the MA3-P12
  dira[input]~ 
  pin := input
  return pin     
{
  If the pin (input) == 1, the binary value for the pin/high variable is %10 which == 2.
  Thus, because this is a binary base we can use the formula 2 ^ input to determine the
  value of pin and high. 
}   
    
pub read                                                'Use this routine to recall the current shaft location
  controller := 0                              
  repeat until controller == 10                
    waitpeq(0, |< pin, 0)                     
    waitpeq(|< pin, |< pin, 0)                     
    motor := cnt                           
    waitpeq(0, |< pin, 0)                     
    set := cnt
    waitpeq(|< pin, |< pin, 0)                             
    counter[controller] :=((set-motor)/40)-1      
    controller++
  motor := ((counter[0]+counter[1]+counter[2]+counter[3]+counter[4]+counter[5]+counter[6]+counter[7]+counter[8]+counter[9])/10)
  return motor

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