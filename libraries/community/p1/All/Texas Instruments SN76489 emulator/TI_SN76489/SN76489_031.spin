{{
=========================================================================== 

** Texas Instruments SN76489 Chip Sound Driver **

AUTHOR: Francesco de Simone, www.digimorf.com
LAST MODIFIED: 10.11.2012
VERSION 3.1

FILENAME: SN76489_031.spin

COMMENTS:
This version of the SN76489 emulator has been adapted to be compatible with ZiCOG and zq80 Z80 propeller emulators
by adding a customized port listener. You have to change the ports if you want to fit your design ( see write_cmd label ).

This chip has been used in arcade machines, home computers and game consoles of the eighties.
This driver generates sound through the audio pin, and emulates the chip Texa Instruments SN76489.
The C3 uses the same design for audio as do most of the Propeller development boards.
Its simply a RC integrator passed by a capacitor to the audio port.

REQUIRES: Parallax Propeller C3 Board
LICENSE: See end of file for terms of use

=========================================================================== }}
{

Taken from: http://www.smspower.org/Development/SN76489

------------
Introduction
------------
This page describes the Programmable Sound Generators based on the SN76489 family of devices.
They are almost all identical but produce very different output.

-----------------
SN76489 sightings
-----------------
The SN76489AN discrete chip is used in Sega's SG-1000 Mark I and II, and SC-3000 machines,
and the Othello Multivision clone. I do not know if the Mark III has a discrete chip or not.
The Sega Master System and Game Gear have it integrated into their VDP chips, for backward
compatibility to varying extents.
The Mega Drive integrates it into its VDP, although it is often then referred to as an SN76496.
It was included to allow for the system's Master System backwards compatibility mode, but was
also commonly used because it provides sounds that are impossible to create using the system's
main FM synthesis sound hardware (YM2612).
It is used on many of Acorn's BBC and "Business Computer" computers such as the BBC Micro.
The Colecovision uses it too, as a discrete chip as the Colecovision has virtually no custom chips.
The Coleco Adam presumably has one too. Furthermore, it is present in the Sord M5, sold by Takara
in Japan and by several others in Europe. Several Memotech home micro computers, such as the
MTX-512, included the chip. The SN76489 was also used in a modified form, with the designation
 changed to TMS9919 to fit in the 99xx series (from which the SC-3000 VDP comes as well), in the TI-99/4A.
 
Other computers thought to use the chip are:
Hanimex Pencil
Video Technology CreatiVision

It is undoubtedly used in a LOT of arcade machines. This is a partial list;
numbers in brackets signify how many SN76489s are present:
Bank Panic (3)
Champion Boxing
Champion Pro Wrestling
Gigas (4)
Gigas Mark II (4)
Free Kick
Lady Bug (2)
Mr. Do! (2)
Mr. Do's Castle (4)
Mr. Do's Wild Ride (4)
Super Locomotive (2)
Wonder Boy: Monster Land (2)

A clone of the SN76489 is included in the Tandy 1000 home computer, for compatibility
 with the one in the IBM PCjr of which it is itself a clone.

----------------------------------- 
Accessing the SN76489 from software
-----------------------------------
The SN76489 has an 8-bit write-only data bus, so it is controlled in software by writing bytes to it.
How this is done depends on the system.
Sega Game 1000 (SG-1000)
Sega Computer 3000 (SC-3000)
Sega Master System (SMS)
Sega Game Gear (GG)
Sega Mega Drive/Genesis (in Master System compatibility mode)

The SN76489 can be accessed by writing to any I/O port

-----------------
SN76489 registers
-----------------
The SN76489 has 8 "registers" - 4 x 4 bit volume registers, 3 x 10 bit tone registers
and 1 x 3 bit noise register. Of course, for hardware reasons these may internally be wider.

Channel Volume registers        Tone & noise registers
0       Vol0    Tone0
1       Vol1    Tone1
2       Vol2    Tone2
3       Vol3    Noise

----------------
Volume registers
----------------
The value represents the attenuation of the output. Hence, %0000 is full volume and %1111 is silence.

--------------
Tone registers
--------------
These give a counter reset value for the tone generators. Hence, low values give high frequencies and vice versa.

--------------
Noise register
--------------
One bit selects the mode ("periodic" or "white") and the other two select a shift rate.

It appears the initial state of these registers depends on the hardware:
Discrete chips seem to start with random values (an SC-3000 is reported to start with a
tone before the chip is written to by the software).
The Sega integrated versions seem to start initialised with zeroes in the tone/noise registers
and ones in the volume registers (silence).

-----------------------
SN76489 register writes
-----------------------
When a byte is written to the SN76489, it processes it as follows:

If bit 7 is 1 then the byte is a LATCH/DATA byte.
  %1cctdddd
    |||````-- Data
    ||`------ Type
    ``------- Channel
    
Bits 6 and 5 (cc) give the channel to be latched, ALWAYS.
This selects the row in the above table - %00 is channel 0, %01 is channel 1,
%10 is channel 2, %11 is channel 3 as you might expect.

Bit 4 (t) determines whether to latch volume (1) or tone/noise (0) data - this gives the column.
The remaining 4 bits (dddd) are placed into the low 4 bits of the relevant register.
For the three-bit noise register, the highest bit is discarded.
The latched register is NEVER cleared by a data byte.

If bit 7 is 0 then the byte is a DATA byte.
  %0-DDDDDD
    |``````-- Data
    `-------- Unused
    
If the currently latched register is a tone register then the low 6 bits of the byte (DDDDDD)
are placed into the high 6 bits of the latched register. If the latched register is less than 6 bits wide
 (ie. not one of the tone registers), instead the low bits are placed
 into the corresponding bits of the register, and any extra high bits are discarded.
 
The data have the following meanings (described more fully later):

Tone registers
DDDDDDdddd = cccccccccc
DDDDDDdddd gives the 10-bit half-wave counter reset value.

Volume registers
(DDDDDD)dddd = (--vvvv)vvvv
dddd gives the 4-bit volume value.

If a data byte is written, the low 4 bits of DDDDDD update the 4-bit volume value. However, this is unnecessary.

Noise register
(DDDDDD)dddd = (---trr)-trr

The low 2 bits of dddd select the shift rate and the next highest bit (bit 2) selects the mode (white (1) or "periodic" (0)).
If a data byte is written, its low 3 bits update the shift rate and mode in the same way.
}

CON
  _clkmode = xtal1 + pll16x ' enable external clock and pll times 16
  _xinfreq = 5_000_000      ' set frequency to 5 MHZ
' -------------------------------------------------------------------------------------------------------------
VAR
  long Registers[16]       ' Memory mapped registers for the chip
' -------------------------------------------------------------------------------------------------------------   
PUB start ( cmd_port )
  io_command := cmd_port
  cognew( @entry, @Registers[0] )

' -------------------------------------------------------------------------------------------------------------                                                                                        
DAT
org 0
entry                or     dira, audio_pin_mask             ' direction of I/O to output ( C3 bit 24 set )                                                                                                                                       
                     movs   ctra, #24                        ' set counter A pin to the audio pin ( C3 = 24 )                                                                                                        
                     movi   ctra, #%0_00110_000              ' duty cycle mode "00110", single ended
' ############################################################################################################################
idle                 mov    cnt_accu, cnt                    ' init counter                                                                                                                                           
                     add    cnt_accu, cnt_for_sample
                     
                     call   #refresh                         ' refresh the audio channels
                     ' ------------------------------------   
                     rdlong port_command, io_command         ' wait for a command on port
                     mov    port_no, port_command            ' get a copy of the io_command long into the port_no
                     shr    port_command, #24 wz             ' extract the io command ( 1:write, 2:read )
                if_z jmp    #idle                            ' if zero go back to idle status
                     ' ------------------------------------
                     mov    port_data, port_no               ' get a copy of the port_no long into the port_data   
                     shr    port_no, #8                      ' align the port byte 
                     and    port_no, #$FF                    ' and extract it 
                     cmp    port_command, #1 wz              ' check the io command if 1 ( write )
               if_nz jmp    #idle                            ' go back to idle status if other commands are found
                     ' ------------------------------------
write_cmd            cmp    port_no, #$7F wz                 ' check if the write command is addressed on port $7F ( SC-3000 PSG )
               if_nz jmp    #idle                            ' You have to change this port number on your needs
                     ' -----------------------------------
write_psg            and    port_data, #$FF                  ' extract the data byte addressed to the port
                     test   port_data, #$80 wz               ' check if data is a register or data for the PSG
               if_nz call   #write_reg
                if_z call   #write_data
                     
                     mov    port_command, #0                 ' reset the io command to tell Z80 that the data has been stored 
                     wrlong port_command, io_command         ' send the io command to the memory mapped register
                     jmp    #idle                            ' go back to idle status
' ----------------------------------------------------------------------------------------------------------------------------  
write_reg            mov    register, port_data
                     and    register, #%111_0000   
                     shr    register, #2
                     and    port_data, #%1111

                     mov    tab_registers, par               ' get caller parameters pointer into a variable
                     add    tab_registers, register 

                     rdlong r0, tab_registers                ' get the period of the actual channel being processed
                     andn   r0, #$F
                     or     r0, port_data
                     wrlong r0, tab_registers                ' get the period of the actual channel being processed
write_reg_ret        ret
' ----------------------------------------------------------------------------------------------------------------------------                      
write_data           and    port_data, #%111111
                     shl    port_data, #4
                     mov    tab_registers, par
                     add    tab_registers, register          ' get caller parameters pointer into a variable
                     
                     rdlong r0, tab_registers                ' get the period of the actual channel being processed
                     and    r0, #$F  
                     or     r0, port_data
                     wrlong r0, tab_registers                ' get the period of the actual channel being processed
write_data_ret       ret                                  
' ############################################################################################################################
refresh              mov    channel_no, #4                   ' start the loop for the three tone channels
                     '--------------------------------------   
                     mov    tab_registers, par               ' get caller parameters pointer into a variable
                     mov    tab_internals, tab_registers     ' to create the entry points for the registers,
                     add    tab_internals, #32               ' the internal counters and oscillators,
                     '--------------------------------------  
                     mov    out_audio, dc_offset             ' add DC offset ( PWM 50% duty cycle )            
                     '--------------------------------------                                                                         
loop_channels        rdlong psg_period, tab_registers        ' get the period of the actual channel being processed
                     add    tab_registers, #4                ' go ahead 4 bytes in the memory ( next long )
                     rdlong psg_attenuator, tab_registers    ' get the attenuation of the actual channel being processed
                     add    tab_registers, #4                ' go ahead 4 bytes in the memory ( next long )
                     ' -------------------------------------
                     rdlong psg_oscillator, tab_internals    ' get the oscillator state of the actual channel being processed
                     add    tab_internals, #4                ' go ahead 4 bytes in the memory ( next long )       
                     rdlong psg_counter, tab_internals       ' get the counter value of the actual channel being processed
                                                             ' align back the pointer, done after to save cycles (*)
                     ' ------------------------------------- 
                     ' GET ATTENUATION VALUE
                     mov    tab_output_pwm, #pwm_table       ' create a pointer to the pwm output table                                     
                     add    tab_output_pwm, psg_attenuator   ' add the correct index to that pointer                                        
                     movs   :put, tab_output_pwm             ' move the pointer to the source field of instruction at :put position
                     sub    tab_internals, #4                ' (*) go ahead 4 bytes in the memory ( next long )
:put                 mov    psg_out, 0-0
' RENDER TONE CHANNELS ----------------------------------------------------------------------------------------
                     cmp    channel_no, #1                wz ' if the actual channel is the the noise, 
                if_z jmp    #noise                           ' then go render it
                     ' CALCULATE OSCILLATOR  
                     sub    psg_counter, #2               wc ' decrease counter and keep the c flag                                         
                if_c mov    psg_counter, psg_period       wz ' if c flag, the counter reaches 0, so resets the counter                       
         if_c_and_nz xor    psg_oscillator, #1               ' flip the oscillator only if the period > 0 and have been reset
                     test   psg_oscillator, #1            wz ' now refresh the output and test the oscillator
                     negz   psg_out, psg_out                 ' so we negate the output when z is not 0                                                                                                   
                     add    out_audio, psg_out               ' add the output value to the final audio channel                 
                     ' -------------------------------------                                                     
                     wrlong psg_oscillator, tab_internals    ' write back the oscilator value
                     add    tab_internals, #4                ' go ahead 4 bytes in the memory ( next long ) 
                     wrlong psg_counter, tab_internals       ' write back the counter value   
                     add    tab_internals, #4                ' go ahead 4 bytes in the memory ( next long )
                     ' ------------------------------------- 
                     cmp    channel_no, #2                wz ' if the actual channel is the tone 2,    
                if_z mov    old_psg_period, psg_period       ' then store its period for the noise rendering
                     ' -------------------------------------
                     djnz   channel_no, #loop_channels
' RENDER NOISE CHANNEL ----------------------------------------------------------------------------------------
noise                mov    TapBits, psg_period              ' get a copy of the period and stores into TapBits
                     and    psg_period, #3                   ' the two low bits are isolated to set the shift rate 
                     cmp    psg_period, #3                wc ' if the rate is less than 3 then the period is 
                     ' CALCULATE NOISE RENDERER              ' calculated in this way:
                if_c mov    old_psg_period, #$10             ' $10 << shift rate ( 0:2 )                   
                if_c shl    old_psg_period, psg_period       ' which gives $10, $20, $40                  
                     mov    psg_period, old_psg_period    wz ' then the period is updated to this rate or to the period of tone 2
                     ' ------------------------------------- 
                     sub    psg_counter, #1               wc ' decrease the counter and if it reaches 0 recharge and render noise
               if_nc jmp    #mixer                           ' otherwise skip this section and render the noise
                if_c mov    psg_counter, psg_period        
                if_c test   TapBits, #%100                wz ' check the tapped bits to render the correct type of noise
         if_c_and_nz test   ShiftRegister, #9             wc ' white, xor the two bits of the white noise setting   
          if_c_and_z test   ShiftRegister, #1             wc ' periodic, just take the carry bit from the shift                             
                     ' ------------------------------------- 
noise_out            shr    ShiftRegister, #1                ' feed the shift register at the MSB 
                if_c or     ShiftRegister, MSB15  
                     ' ------------------------------------- 
mixer                test   ShiftRegister, #1             wz                                                                                              
                if_z add    out_audio, psg_out               ' add the output value to the final audio channel 
' #############################################################################################################               
                     add    tab_internals, #4                                                                    
                     wrlong psg_counter, tab_internals       ' write back the counter value
                     mov    frqa, out_audio                  ' update master output frequence to change the duty cycle
                     '-----------------------------       
                     waitcnt cnt_accu, cnt_for_sample        ' wait for a "sample" period                                       
refresh_ret          ret                         ' continue rendering samples
' #############################################################################################################

r0                  long    0
register            long    0
port_command        long    0
io_command          long    0
port_no             long    0
port_data           long    0
                                                                                                                                                                                   
cnt_accu            long    0           ' counter accumulator                                          
cnt_for_sample      long    358<<1      ' cycles to wait each render cylce *** Probably to FIX ***

audio_pin_mask      long    $01000000   ' 24 for PropC3
channel_no          long    0

psg_counter         long    0           ' counter channel accumulators
psg_oscillator      long    1           ' channel oscillators                         
psg_attenuator      long    15          ' channel attenuators
psg_period          long    0           ' channel periods
old_psg_period      long    0           ' temporary period
psg_out             long    0           ' output values

ShiftRegister       long    $8000                                   
MSB15               long    $8000
TapBits             long    0

out_audio           long    0           ' master output value
dc_offset           long    $8000_0000  ' PWM duty cycle of 50% for the audio generation

tab_output_pwm      long    0           ' pointer for the use of the tables                                         
tab_registers       long    0           
tab_internals       long    0

pwm_table           long    536870911  ' lookup tables to emulate logaritmic output volume
                    long    426455766 
                    long    338749538 
                    long    269066260
                    long    213735804
                    long    169776190
                    long    134860821
                    long    107613397
                    long    85084710 
                    long    67586064 
                    long    53692007 
                    long    42648854 
                    long    33866762 
                    long    26903350 
                    long    21365389 
                    long    0        

{
------------------
Volume/attenuation
------------------
The mixer then multiplies each channel's output by the corresponding volume
(or, equivalently, applies the corresponding attenuation), and sums them.
 The result is output to an amplifier which outputs them at suitable levels for audio.
The SN76489 attenuates the volume by 2dB for each step in the volume register.
 This is almost completely meaningless to most people, so here's an explanation.
The decibel scale is a logarithmic comparative scale of power.

One bel is defined as
     power 1
 log -------
     power 2
     
Whether it's positive or negative depends on which way around you put power 1 and power 2.
 The log is to base 10.
However, this tends to give values that are small and fiddly to deal with, so the standard
is to quote values as decibels (1 decibel = 10 bels). Thus,
                      power 1
    decibels = 10 log -------
                      power 2
                      
One decibel is just above the threshold at which most people will notice a change in volume.
In most cases we are not dealing with power, we are instead dealing with voltages in the
form of the output voltage being used to drive a speaker. You may remember from school that
 power is proportional to the square of the voltage. Thus, applying a little mathematical knowledge:
 
                      (voltage 1)'^2^'          voltage 1
    decibels = 10 log ------------ = 20 log ---------
                      (voltage 2)'^2^'          voltage 2
                      
Rearranging,

    voltage 1     (decibels / 20)
    --------- = 10
    voltage 2
    
Thus, a drop of 2dB will correspond to a ratio of 10-0.1 = 0.79432823 between the current and
 previous output values. This can be used to build an output table, for example:
 
 int volume_table[16]={
   32767, 26028, 20675, 16422, 13045, 10362,  8231,  6568,
    5193,  4125,  3277,  2603,  2067,  1642,  1304,     0
 };

 Which has been adapted to a range of 0:$1fffffff    which is $80000000 / 4 channels
 
}

{{                   
 ______________________________________________________________________________________________________________________________
|                                                   TERMS OF USE: MIT License                                                  |                                                            
|______________________________________________________________________________________________________________________________|
|Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    |     
|files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    |
|modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software|
|is furnished to do so, subject to the following conditions:                                                                   |
|                                                                                                                              |
|The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.|
|                                                                                                                              |
|THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          |
|WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         |
|COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   |
|ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         |
 ------------------------------------------------------------------------------------------------------------------------------ 
}}