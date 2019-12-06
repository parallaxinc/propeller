{ This assumes there is a transistor attached to the drive pins (apin, bpin, cpin)


**************************************************
* Brushless DC Motor Demo      V2.0              *
* Author: Paul Rowntree / University of Guelph   *
* Copyright (c) 2009                             *
* See end of file for terms of use.              *
**************************************************

Written by Paul Rowntree, based on the Uwe Oehler's ideas for a PIC-based system

- please call each of the Configure routines first, then the SetControlLevel, and finally the Start routine
- call the Set and Get routines as rquired by your application

}

CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000             

    apin = 8                    ' this sequence gives a CW rotation on my machine, looking at the spindle.
    bpin = 9                    ' these assignments assume that the motor interface is in Socket B of SpinStudio
    cpin = 10

    tpin = 15                   ' trigger pin, will go high to mark start of an A-B-C cycle
     
    disc_in = 14                ' raw opto-interrupter signal input
    disc_conin = 13             ' Schmitt-conditioned opto-interrupter signal input
obj
   vp      : "Conduit411"        ' Hanno's ViewPort code.  This is a terrific piece of programming

   motor   : "BLDC_Driver v2"    ' Rowntree's driver for the motor, based on Uwe Oehler's ideas for the PIC
   
var

' the following variables are linked with ViewPort
' 
   long vp_Freq, vp_PW, vp_SetPoint, vp_CycleTime, vp_CoilTime, vp_On, vp_Phase
    
pub Main   | i, low, high

{{ If you are not using Hanno Sander's ViewPort program, comment out or delete the next vp-related lines,
as well as the object reference above
}}

  vp.config(string("var:Freq,PW,SetPt,Cycle,Coil,On,Phase"))
  vp.config(string("start:dso"))
  vp.config(string("edit:SetPt(mode=text),PW(mode=text),Phase(mode=text)"))
  vp.config(string("dso:view=[Freq,On],timescale=1s"))
      
  vp.share( @vp_Freq, @vp_Phase )

{ these are the two control variables
}

    vp_SetPoint := 50                  ' should easily do ~50 Hz with this
    vp_PW := 60
    vp_Phase := 1
    
    motor.ConfigureEncoder( disc_ConIn )                 ' conditioned signal pin
    motor.ConfigureMotor( 4, 6, 3)                      ' coil sets per rotation, spokes per coil, dead time
    motor.ConfigureDrive( apin, bpin, cpin, tpin )       ' tpin is a trigger used to show start of cycles
    motor.SetControlLevel( vp_PW, vp_SetPoint )          ' duty cycle, target set point
    
    motor.start_V1

{{ the following loop polls the driver for values, and sets the control levels back to the driver.
It presumes that ViewPort is updating these variables in the background.

If you are not running ViewPort, you are free to set and forget the motor parameters,
or you could program a specific ramping pattern, etc.
}}
    repeat   
        motor.SetControlLevel( vp_PW, vp_SetPoint )
        
        vp_CycleTime := motor.GetCycleTime
        vp_CoilTime := motor.GetCoilTime
        vp_On := motor.GetOnState
        vp_Freq := motor.GetFreq
        
        waitcnt( clkfreq/100 +cnt )
 
DAT
{{
**********************************************************************************************************************************
*                                                   TERMS OF USE: MIT License                                                    *  
**********************************************************************************************************************************
*  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    *
*  files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    *  
*  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software*  
*  is furnished to do so, subject to the following conditions:                                                                   *  
*                                                                                                                                *  
*  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.*  
*                                                                                                                                *  
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          *  
*  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         *  
*  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *  
*  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         *  
**********************************************************************************************************************************
}}   