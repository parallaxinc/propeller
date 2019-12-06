{{

Purpose: Light Dimmer Controller

WARNING: Be extremely careful when working with 120 Vac power as it is lethal!
 While this code is safe, working with high voltage should only be done by those competent
 and trained to work with high voltage circuits!

Purpose: This program triggers a Triac from 0% on to 100% on using 1 Propeller COG.
 The output from the Triac is used to set the brighness of an attached light bulb or other resistive load.
 The program can also be used to set the brightness of a LED.

Usage: Call the 'Load' routine which loads a PASM routine in a cog.
  The address of the 'level' variable is passed to the PASM code and the variable
  can be located anywhere in the propeller memory.
  
  Once loaded, to change the brightness, simply change the value of 'level' from 0 to 255.
  This sets the brightness (duty cycle) from 0 to 100%. Any values outside of the range of 0 to 255
  are rounded to 0 or 255 respectively.
  I have included a LCD display code in this demo to show the brightness level.
  The LCD code can be removed as the dimmer routine doesn't need the LCD code to operate.

  I have also included a 120-Hz clock simulator using the timer on the propeller to replace the zero-crossing
    signal that normally would come from the H11AA1 opto-isolator chip. If you are dimming LEDs on the demo board
    you can use this clock simulator. If you are dimming lights with the Triac, you will need the actual zero-crossing
    signal from the H11AA1 as it is the basis for the 60-Hz phase synchronization. 


   See the attached TIFF file for wiring instructions.
    
   For this demo program, I am using the follwing pins but they could be any pins you desire.
   
   I/O 23 - Zero Crossing Signal H11AA1 Zero Crossing Detector. Signal goes HIGH for very short period of time.
            Pull pin5 of H11AA1 to +3.3 with 10k resistor.
             
   I/O 16 - Output to MOC3010M Opto-Diac via 180 ohm resistor. Output goes HIGH to turn on MOC3010M.

            For a clean output, you should use a series inductor with the triac.
            You should also include a "snubber" circuit across the triac to prevent false triggering.
            You will have to do your own research on designing the circuitry around the triac. 

}}

VAR
    long    level                  '' Variable that contains the value of the dimmer level (0 - 255)

    long Stack[20]                 '' Stack space

OBJ
    LCD         :"LCD_16X2_4BIT"   '' LCD code - can be removed
    Simulator   :"Clock_Simulator" '' Simulates a 120-Hz pulse from the zero-crossing H11AA1 Opto-Isolator (Short High Pulse)
    
  
CON
  _CLKMODE      =   XTAL1 + PLL16X                         
  _XINFREQ      =   5_000_000

  CrossDetect   =   23  '' Input pin number, Active HIGH from H11AA1
  Output        =   16  '' Output pin number, Active HIGH to MOC3010M to turn on Opto-Diac            

PUB Start | tmp, Delay

        ' DEMO Code to show how it works.
        
        Delay:=1000                 '' how long to delay in this demo program.

        Simulator.go(CrossDetect)   '' load the zero-crossing simulator that triggers 120 times a second.
        LCD.start                   '' LCD driver to see what level the demo program is commanding.
        
        lcd.str(string("Loading Dimmer"))


' Load the Dimmer PASM code.
level:=0                            '' Set the initial brightness level to off = 0.       
load(@level)                        '' Load the actual PASM Dimmer code. Tell it where the brightness variable lives.


        ' Continue with the demo program.
        
        lcd.move(1,1)        
        lcd.str(string("Dimmer Loaded   "))

        lcd.move(1,2)
        lcd.str(string("Level: "))

        level:=-1000                '' set the brightness level to full off = 0. Any value less than 0 is limited to 0
        lcd.move(7,2)
        lcd.dec(level)
        lcd.str(string("          "))            
        waitcnt(clkfreq*2+cnt)
             
        level:=1000                '' set the brightness level to full on = 255. Any value greater than 255 is limited to 255
        lcd.move(7,2)
        lcd.dec(level)
        lcd.str(string("          "))            
        waitcnt(clkfreq*2+cnt)

        level:=1                    '' Set brightness to 1, this is on 1/255 = about .4% ON
        lcd.move(7,2)
        lcd.dec(level)
        lcd.str(string("          "))            
        waitcnt(clkfreq*2+cnt)

        level:=254                  '' Set brightness to 254, this is on 254/255 = 99.6% ON.
        lcd.move(7,2)
        lcd.dec(level)
        lcd.str(string("          "))            
        waitcnt(clkfreq*2+cnt)

        lcd.move(1,2)
        lcd.str(string("Sweeping Up/Down"))
        
        repeat
            repeat tmp from 0 to 255                        '' sweep from off to on then on to off.
                level:=tmp
                waitcnt(clkfreq/Delay+cnt)
            
            repeat tmp from 255 to 0
                level:=tmp                                 
                waitcnt(clkfreq/Delay+cnt)


PUB Load (BrightnessAt)

'' Call this routine with address of brighness variable.
'' The brighness variable should be set from 0-255, 0=full off, 255=full on.

'' BrightnessAt is address of variable to pass to PASM code to set the brighness (0 - 255)

        ZeroPin :=  |< CrossDetect  ' bit mask for Zero Crossing Detector Pin (Active High)
        OutputPin :=  |< Output     ' bit mask for Output Pin (Active High)

        BrightVarAt:=BrightnessAt             ' Push address of brighness into PASM code

        cognew(@Dimmer,@Stack)
        

DAT
{

Enter with the ADDRESS of the LONG that contains the brighness level.
The brightness level can be any value but it is looking for 0 = full off to 255 = full on.
If the value is less than 0, it is set to 0.
If the value is greater than 255, it is set to 255

}

    org     0
                                                                                                
Dimmer
                mov     St1,OutputPin           ' Set all bits for input except output pin
                mov     dira, St1
:loop0          mov     outa,#0                 ' Clear output

:loop1          '' Look for leading edge of zero crossing input
                mov     st3,ina                 ' Read input value
                and     st3,ZeroPin wz          ' Mask off all but input bit
        if_z    jmp     #:loop1                 ' Bit not high, do it again


                rdlong  st1,BrightVarAt
                maxs    st1,#255
                mins    st1,#0

                mov     st3,#255                ' Invert because delay makes light dimmer
                sub     st3,st1

                '' See if full on, if so, skip delay
                cmp     st3,#0 wz
        if_z    jmp     #:loop2
        
                '' See if full off, if so, skip delay
                cmp     st3,#255 wz
        if_z    jmp     #:loop3
        
                '' Calculate number of clock cycles to delay for 0-255 level
                '' 100% on time = 80_000_000 / 120 = total of 666_667 clock cycles  (666_667/255 = 2614 counts/bit)
                '' Our full on = 2048+512+32+16=2608 clock cycles per level (2608*255=665_040 total clock cycles)
                  
                mov     st1,st3                 ' 80Mhz / (1/256 x 1/120) = 2604 clock cycles per half cycle 
                shl     st3,#11                 ' level x 2048 (2614 - 2048 = 566)

                mov     st2,st1                 
                shl     st2,#9                  ' level x 512 (566 - 512 = 54)
                add     st3,st2

                mov     st2,st1                 
                shl     st2,#5                  ' level x 32 (54 - 32 = 22) ' error of 22/2614 = insignificant but not 100% on
                add     st3,st2

                mov     st2,st1                 
                shl     st2,#4                  ' level x 16 (22 - 16 = 6) ' error of 6/2614 = insignificant but not 100% on
                add     st3,st2                 ' so if level = 255, skip timing and turn on immediately.

                add     st3,cnt                 ' Delay until this clock value is reached

                '' Check to see if main delay value is reached                
                waitcnt   st3,#0                ' Wait until main count time is reached, time to turn on Triac
:loop2
                mov     outa,OutputPin          ' Turn on output pin

:loop3          '' Look for trailing edge of zero crossing input
                mov     st3,ina                 ' Read input value
                and     st3,ZeroPin wz          ' Mask off all but input bit
        if_nz   jmp     #:loop3                 ' Bit high, do it again
                
:loop4          '' Look for leading edge of zero crossing input to go HIGH again to start next cycle
                mov     st3,ina                 ' Read input value
                and     st3,ZeroPin wz          ' Mask off all but input bit
        if_z    jmp     #:loop4                 ' Bit not high, loop until cycle ends

                '' Done with this half cycle, do it again
                mov     outa,#0
                jmp     #:loop0
                
              
ZeroPin         long    0                       ' Pin number for Zero-Crossing Pulse (Active High)
OutputPin       long    0                       ' Pin number for output to MOC3010M
BrightVarAt     long    0                       ' Address of brighness variable
     
ST1             res     1                       ' Temp 1
ST2             res     1                       ' Temp 2
ST3             res     1                       ' Temp 1

                fit     496         ' Make sure it fits within a cog's memory space