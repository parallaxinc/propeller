'' ***************************************
'' * Test Pos control kit w HB25           
'' * #27906 driver
'' * Test for version 1.3      
'' * Author: Henk Kiela Opteq           
'' * Copyright (c) 2011 Parallax, Inc.  
'' * See end of file for terms of use.     
'' ***************************************

{{

Code Description : Implements command set for HB25 drives of Parallax .
Can be used for Parallax Robot Base Kit

}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


'' Serial Debug port
   TXD = 30
   RXD = 31
   Baud = 115200

'' Control chars.
   CR = 13
   LF = 10
   CS = 16
   CE = 11                 'CE: Clear to End of line

'' Debug Led
  LED1          = 23       ' I/O PIN for LED 1

'' HB25 pins
   MotorData = 16          ' Left Motor serial data 

VAR
  Long HB25cog, Speed, Dir
  Byte Ch
  
OBJ

  ppc    : "PPC_DriverV1.3"             'Driver for position controller
  ser    : "Parallax Serial Terminal"   'Debug cog      
  t      : "Timing.spin"
'  DrvMtr : "Simple_Serial"

    
PUB Start | i
  
  dira[LED1] ~~
  Init
  Speed:=50
' ppc.MtrMove(0,0)
'  ppc.GoForward(0,20)
  repeat
    ch:=ser.RxCheck
    if Ch
      DoCommand
      
'    ppc.MtrMove(Speed,10)
'     ppc.GoForward(0,20)
    ser.str(string("Set Speed : "))
    ser.dec(ppc.GetSetSpeed(0))
    ser.tx(" ")
    ser.dec(ppc.GetSetSpeed(1))
    ser.str(string("Set Position : "))
    ser.dec(ppc.GetSetPosition(0))
    ser.tx(" ")
    ser.dec(ppc.GetSetPosition(1))
    ser.str(string(" Act Pos : "))
    ser.dec(ppc.Position(0))
    ser.tx(" ")
    ser.dec(ppc.Position(1))
    ser.str(string(" Enabled : "))
    ser.dec(ppc.GetEnabled)
'    ser.str(string(" Set Speed : "))
'    ser.dec(ppc.GetSetSpeed(1))
'    ser.str(string(" Set Pos : "))
'    ser.dec(ppc.GetSetPosition(1))
    ser.str(string(" State : "))
    ser.dec(ppc.GetState)
    ser.str(string(" Cntr : "))
    ser.dec(ppc.GetCntr)
    ser.tx(CR)
'   ppc.MtrMove(Speed,10)
    !outa[LED1]              
    t.Pause1ms(300)


PRI DoCommand
  case ch
'    "r","R" : ppc.GoForward(0,20)
'    "f","F" : ppc.GoForward(0,-20)
    "d","D" : ppc.Disable
              ppc.EmergencyStop
    "e","E" : ppc.Enable
    "c","C" : ppc.EmergencyStop
    "S","s" : ppc.MtrMove(0,0)
    "H","h" : ppc.MtrMove(1,1)
    "L","l" : ppc.MtrMove(20,-30)
    "R","r" : ppc.MtrMove(20,30)
    "1"     : ppc.MtrMove(0,-30)
    "2"     : ppc.MtrMove(0,30)
    "3"     : ppc.MtrMove(-20,-30)
    "4"     : ppc.MtrMove(-20,30)
              

PRI Init

  ser.start(Baud)   'Start debug port
  t.Pause1ms(500)
  ser.tx(CS)
  t.Pause1ms(1500)
  
  HB25cog:=ppc.start(MotorData)
'   cognew(Jog,@JogStack)

  ser.str(string("Test HB25 Pos control HJK V1", CR))
  ser.str(string("Motor Cog : "))
  ser.dec(HB25cog)
  ser.tx(CR)
  ser.tx(CR)
  
VAR Long JogStack[50], JogCntr, JogSpeed
PRI Jog   'Jog velocity forward and backward
  repeat
     repeat 10
       t.Pause1ms(100)
       JogSpeed:=JogSpeed+5
       ppc.MtrMove(JogSpeed,0)
     repeat 10
       JogSpeed:=JogSpeed-5
       t.Pause1ms(100)
       ppc.MtrMove(JogSpeed,0)

     repeat 10
       t.Pause1ms(100)
       JogSpeed:=JogSpeed-20
       ppc.MtrMove(JogSpeed,0)
     repeat 10
       JogSpeed:=JogSpeed+20
       t.Pause1ms(100)
       ppc.MtrMove(JogSpeed,0)

    JogCntr++