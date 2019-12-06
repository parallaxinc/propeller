{{

      Motor_Minder_Reversible.spin
      a version of Motor_Minder.spin with Rotation Direction
      Modified by Gregg Erickson
      15 May 2011

      Original Code by:

      Motor_Minder.spin
      Tom Doyle
      6 March 2007



    Motor_Minder monitors the speed and revolution count of a motor using a shaft encoder.
    It was tested with the Melexis 90217 Hall-Effect Sensor (Parallax 605-00005) and a single
    magnet mounted (Parallax 605-00006) on the shaft. It should work with any type of
    sensor that puts out one pulse per revolution. The object runs in a new cog updating
    varibles in the calling cogs address space. It has been tested with one motor. To clear
    the revolution counter memory call the start procedure again.

    Counter A is used to measure the period of revolution. Counter B is used to count revolutions.

    The Parallax hall-effect sensor and magnet eliminated all the alignment problems with
    reflective optical sensors that were used initially.

    ***This minor update will detect a second slightly offset sensor on the next pin (p+1).  If the
    second pin is high during the negative edge then change the sign on the period to negative to
    indicate reverese rotation. The concept is the same as on encoders. The rest of the code
    matches the original.

}}
      

CON

  _CLKMODE = XTAL1 + PLL16X        ' 80 Mhz clock
  _XINFREQ = 5_000_000


VAR

   byte cog
   long Stack[20]

  
PUB Start(encoderPin, addrPer, addrRevs) : result
{{
    encoderPin - prop pin for shaft encoder
    addrPer    - address of period of revolution
    addrRevs   - address of revolution counter variable

    returns cog number + 1
}}

  
  cog := cognew(mindMotor(encoderPin, addrPer, addrRevs), @Stack) + 1
  result := cog


PUB Stop
{{
   stop cog if in use
}}

    if cog
      cogstop(cog~ -1)



PUB mindMotor(encoderPin, adrPW, adrRevs) |  period,  oldCount
{{
   measures period of motor in counter A
   counts revolutions in counter B
   updates period and rev counter variables
}}

  oldcount := 0 ' initialize oldcount
  dira[encoderPin]~
  dira[encoderPin+1]~

  'start revolution counter in counter B
  frqb := 1
  ctrb := 0     ' stop counter
  phsb := 0     ' zero counter
  ctrb := (%01010 << 26 ) | (encoderPin)     ' count positive going edges in counter B

  repeat      
  while oldcount == phsb                     ' sync to start of revolutin
  oldcount := 0

  repeat
  
    frqa :=  1
    long[adrRevs] := phsb                    ' update rev counter
    oldcount := phsb

    ctra := (%11111 << 26 )                  ' count always in counter A
    phsa := 0                                ' zero count
                  
    repeat
      
    while oldcount == phsb                   ' count during revolution
       
    ctra := (%00000 << 26 )    ' stop counting    
              
    If ina[encoderPin+1]==0
      period := ( phsa  / (clkfreq / 1_000_000) + 1) / 1000
    else
      period := -1*( phsa  / (clkfreq / 1_000_000) + 1) / 1000  

         
    long[adrPW] := period
     
    oldcount := phsb
