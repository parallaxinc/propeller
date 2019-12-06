' This is a driver and demonstration program for the AD7822
' The AD7822 can sample data at 2MS/second at 8 bit resolution
' This program grabs data at 2MS/second, stores it in cog memory, then
' transfers it to hub memory.  This also contains a little demonstration program that transfers the
' data in hub memory to the Parallax Serial Terminal.
' in order to maximize the amount of data that can be grabbed before hub memory is saturated,
' each long in hub memory stores four 8 bit data points



CON
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

' here are the relevant pin masks. This demonstration program connects
' pin 6 to the input for EOC, 7 to CONVST, 8-15 ADC input.
' see the AD7822 data sheet for reference

'PINREFERENCE     %10987654321098765432109876543210    ' this is just to prevent your eyes crossing when changing the pin mask
_PINMASK =        %00000000000000000000000010000000    ' the 1s are the selected output pins, if your application uses additional output pins you will need to change them to a 1 here.   The only required output pin for the ADC conversion is the CONVST pin
_ADCPINMASK =     %00000000000000001111111100000000    ' the 1s are the selected parallel pins to recieve the ADC input
_PINMASKCONVST =  %00000000000000000000000010000000    ' the 1 is the CONVST pin
_PINMASKEOC    =  %00000000000000000000000001000000    ' the 1 is the EOC pin
'_PINPD =          %00000000000000000000000000010000   ' power down pin, not currently used; simply tie this per the AD7822 data sheet


_PAUSE = 40000            ' pause before repeating the loop
_NUMADC = 150              ' number of ADC samples to take -- must take care not to overrun hub memory. There will be four data points per _NUMADC





VAR


byte HubData[((_NUMADC*4)+1)] ' the first byte is a semaphore, the remaining array is the data dumped from the assembly cog


OBJ

pst : "Parallax Serial Terminal"
 

PUB Main| i, r


cognew(@Toggle, @HubData)   

' here, launch new cog to read in data

pst.Start(115200)

 
 repeat

   r:=pst.CharIn
   if (r=="A")
    repeat i from 1 to (_NUMADC*4+1)
      pst.hex(HubData[i], 2)


  
                      


DAT

              ORG 0 'Begin at Cog RAM addr 0
Toggle     
                    
              mov dira, PinMask 'Set Pins to output and p input
              or outa, PinCONVST ' set PinConvst to high
              
:loop
     
                         
              mov Time, cnt
              add Time, Pause
              waitcnt Time, #$1ff

              mov Pings, #_NUMADC
              mov AnalogDataPtr, #AnalogData 


:clearLoop    mov AnalogData, #$0
              add AnalogDataPtr, #$1
              movd :clearLoop, AnalogDataPtr
              djnz Pings, #:clearLoop


              mov ShiftAmount, #$20

' note that the data is read in at the end, so the first piece of data is junk; this is to speed up the loop

:loop2        sub ShiftAmount, #$8 
              mov Pings, #_NUMADC
              mov AnalogDataPtr, #AnalogData
:loop3        
              xor outa, PinCONVST
              xor outa, PinCONVST

      
              and ADCInput0, ADCPinmask                    
              rol ADCInput0, ShiftAmount 
:ArrayPtr     or AnalogData, ADCInput0
              add AnalogDataPtr, #$1
              movd :ArrayPtr, AnalogDataPtr 


              waitpne PinEOC, PinEOC
              mov ADCInput0, ina
'             
              djnz Pings, #:loop3
              tjnz ShiftAmount, #:loop2





' the cramming of the bytes into the long in hub memory is a bit non intuitive.
' this unscrambles it and sends it to the hub.

              mov HubAddr, par 
              mov ShiftAmount, #$0
              mov ADCInput0, #$4                ' ADCInput0 is just going to be used here as a placeholder to count down the loop

              mov Pings, 0
              wrbyte Pings, HubAddr             ' this sets it to zero right before starting. The other cog will wait to see that this is zero before starting transmission.


:HubTLoop0    mov Pings, #_NUMADC
              mov AnalogDataPtr, #AnalogData 
:HubTLoop1    add HubAddr, #$1
:ArrayPtrT0   mov AnalogData, AnalogData
              rol AnalogData, ShiftAmount
              wrbyte AnalogData, HubAddr
              add AnalogDataPtr, #$1
              movs :ArrayPtrT0, AnalogDataPtr
              djnz Pings, #:HubTLoop1
              add ShiftAmount, #$8
              djnz ADCInput0, #:HubTLoop0
 

             

              jmp #:loop

PinPing       long      _PINMASKPING            'Pin number for mask.
PinCONVST     long      _PINMASKCONVST          ' pin number for conversion start
PinEOC        long      _PINMASKEOC             ' pin number for end of conversion
Pause         long      _PAUSE                 'Clock cycles to delay. Largest literal value is 1FF, so we have to put it in a long.
ADCPinmask    long      _ADCPINMASK             
PinMask       long      _PINMASK


HubAddr       res       1
Time          res       1                       'System Counter Workspace
Pings         res       1                       ' used as the counting variable in the data listening and transferring
ADCInput0     res       1                       ' used as the workspace for ADCInput, then later as a second counting variable
AnalogDataPtr res       1                       ' Pointer to the current memory adddress in the Analog Data section
ShiftAmount   res       1
AnalogData    res       _NUMADC

              FIT 496