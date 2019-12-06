{{
  SayItDriver_V5.spin, v3.0
   Copyright (c) 2010 Jeffrey J. Rick
   Last update: 01-07-11
   *See end of file for terms of use*

   Allows the control of the Parallax Say-It Module through the Propeller Chip
   See the sub-routines below for info on how to use them.
 }}
OBJ
     SAY : "SayItDriver_VR"     'Say-it driver
   
CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000
    
  'Pins                    
  COM_RX   = 13       ' Say-It Module RX Pin             
  COM_TX   = 12       ' Say-It Module TX Pin             
  VRLED    = 14       ' Say-It Module LED Pin                              
  PUSHBUTTON    = 23  ' Pushbutton Input Pin   (ADDED FOR TESTING)
'********************************************************************  
    SAY_BAUD  = 9600
'********************************************************************
      
PUB MAIN

  

  SAY.START(13, 12, 14, 9600)
'**********************************************************************************


  
                                           '***************PLACE MARKER 1*******************
                                           '************************************************
                                           '************************************************
                                           
'*****************************************************************************************************
{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 
   
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}