' Developed by Dennis B. Page 25 August 2016
' Based on "40000-Touch-Buttons-LED-Spin-Demo-v1" provided by Parallax Inc.
' See MIT license below

' This is based a demo that is provided by Parallax for the Propeller Quickstart board called
' "40000-Touch-Buttons-LED-Spin-Demo-v1."                

' This an entertaining and educational aid that uses the Parallax Quickstart board to demonstrate a
' single-cog real-time programming technique and state machine that is responsive to button touches
' while performing an independent process that displays visually interesting patterns while the processor
' waits for a button press

CON

  _CLKMODE = XTAL1 + PLL16X
  _CLKFREQ = 80_000_000

  Up   =  0 
  Down = -1

OBJ

  Buttons          : "Touch Buttons"

PUB Main | b,d,p,s

  Buttons.start(_CLKFREQ / 100)                         ' Launch the touch buttons driver sampling 100 times a second
  dira[23..16]~~                                        ' Set the LEDs as outputs
  d := Up                       ' direction
  p := 0                        ' pattern
  s := 0                        ' sequence
  repeat
    b := Buttons.State                                  ' Check buttons
    case b==0
      TRUE  : case s
                0..3    : if !d                        
                            outa[23..16] := P1[p++]    
                            if p == 3                  
                              d := Down              
                          else                         
                            outa[23..16] := P1[p--]    
                            if p == 0                                       
                              d := Up                 
                              s++                      
                              if s == 4                
                                p := 4                 
                4..7     : if !d                       
                             outa[23..16] := P1[p++]   
                             if p == 8                 
                               d := Down             
                           else                        
                             outa[23..16] := P1[p--]   
                             if p == 4                 
                               d := Up
                               s++
                               if s == 8
                                 p := 8
                8..11     : if !d
                              outa[23..16] := P1[p++]  
                              if p == 12               
                                d := Down            
                            else                       
                              outa[23..16] := P1[p--]  
                              if p == 8                
                                d := Up               
                                s++                    
                                if s == 12             
                                  p := $80             
                12..15    : if !d
                              outa[23..16] := p
                              p >>= 1
                              if p == 1                 
                                d := Down             
                            else                        
                              outa[23..16] := p
                              p <<= 1
                              if p == $80               
                                d := Up                
                                s++                     
                                if s == 16              
                                  p := 12               
                16..17    : if !d                        
                              outa[23..16] := P1[p++]    
                              if p == 28                 
                                d := Down              
                            else                         
                              outa[23..16] := P1[p--]    
                              if p == 12                 
                                d := Up                 
                                s++                      
                                if s == 18               
                                  p := 29                
                18..25    : if !d                        
                              outa[23..16] := P1[p++]    
                              if p == 30                 
                                d := Down              
                            else                         
                              outa[23..16] := P1[p--]    
                              if p == 29                 
                                d := Up                 
                                s++                      
                                if s == 26               
                                  p := 0                 
                                  s := 0
                            waitcnt(clkfreq/10 + cnt)   ' Add an extra wait for this sequence range
                other      : outa[23..16] := s          ' Debug tool - Display sequence
              waitcnt(clkfreq/10 + cnt)
      FALSE : outa[23..16] := b                         ' Light the corresponding LED when touching a button

DAT                  ' p
  P1 byte %10000001  ' 0
     byte %01000010  ' 1
     byte %00100100  ' 2
     byte %00011000  ' 3
     byte %00000000  ' 4 Transition
     byte %10000001  ' 5
     byte %11000011  ' 6 
     byte %11100111  ' 7      
     byte %11111111  ' 8 Transition 
     byte %01111110  ' 9 
     byte %00111100  ' 10
     byte %00011000  ' 11
     byte %00000000  ' 12 Transition
     byte %10000000  ' 13
     byte %11000000  ' 14
     byte %11100000  ' 15
     byte %11110000  ' 16
     byte %11111000  ' 17
     byte %11111100  ' 18
     byte %11111110  ' 19
     byte %11111111  ' 20 Transition
     byte %01111111  ' 21
     byte %00111111  ' 22
     byte %00011111  ' 23
     byte %00001111  ' 24
     byte %00000111  ' 25
     byte %00000011  ' 26
     byte %00000001  ' 27
     byte %00000000  ' 28 Transition
     byte %10101010  ' 29
     byte %01010101  ' 30

{
* TERMS OF USE: MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 }                        