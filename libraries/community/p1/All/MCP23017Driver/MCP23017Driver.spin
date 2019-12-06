{{ MCP23017Driver
 Erlend Fj. 2015
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

 Driver for the remote io chip mcp23017. Provides routines for configuring, reading and writing io

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements:  

=======================================================================================================================================================================

 About

 
 REF:


=======================================================================================================================================================================
}
 
CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                      'use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                     'system freq as a constant
          mSec     = clk_freq / 1_000                               'ticks in 1ms
          uSec     = clk_freq / 1_000_000                           'ticks in 1us     (80 ticks)
          

         'Register addresses, defalult - with IOCON.BANK= 0
         '==================================================
          IODIRA           = $00         '%1111_1111 DEFAULT                       
          IODIRB           = $01         '%1111_1111
          IPOLA            = $02         '%0000_0000
          IPOLB            = $03         '%0000_0000
          GPINTENA         = $04         '%0000_0000
          GPINTENB         = $05         '%0000_0000
          DEFVALA          = $06         '%0000_0000
          DEFVALB          = $07         '%0000_0000
          INTCONA          = $08         '%0000_0000
          INTCONB          = $09         '%0000_0000
          IOCON            = $0A         '%0000_0000
          GPPUA            = $0C         '%0000_0000
          GPPUB            = $0D         '%0000_0000
          INTFA            = $0E         '%0000_0000
          INTFB            = $0F         '%0000_0000
          INTCAPA          = $10         '%0000_0000
          INTCAPB          = $11         '%0000_0000
          GPIOA            = $12         '%0000_0000
          GPIOB            = $13         '%0000_0000
          OLATA            = $14         '%0000_0000
          OLATB            = $15         '%0000_0000
                                         
          Chip             = $22                                           '<= Demo: set chip address here!

            
VAR
          LONG  symbol


          
OBJ
          bus:    "i2cDriver"
          pst:    "Parallax Serial Terminal"


          
PUB Main | value, state                                                           'Demo code (comment out if the space is needed)

   pst.Start(9600)                                         
   WAITCNT(2* clkfreq + cnt)                                  
                                                             
   pst.Str(String("Test of MCP23017, push button to start")) 
   value := pst.DecIn
   pst.Chars(pst#NL, 2)
   pst.Str(String("Will first initiate bus, if not already done, and check for ACK: "))
   Init(7, 6)                                                              '<= Demo: specify pin numbers here!
   value:= bus.CallChip(Chip<<1)
   pst.dec(value)
   pst.Chars(pst#NL, 2)
   IF value == 0
     pst.Str(String("Will now configure all of bank A for input, all of bank B for output"))
     CfgDirA(Chip, %11111111)
     CfgDirB(Chip, %00000000)
     pst.Chars(pst#NL, 2)
     pst.Str(String("Will now configure input bank A for internal pull-up resistors"))
     CfgPUrA(Chip, %11111111)
     pst.Chars(pst#NL, 2)
     pst.Str(String("Reading inputs (bank A): "))
     value:= GetA(Chip)
     pst.bin(value, 8)
     pst.Chars(pst#NL, 2)
     pst.Str(String("Reading outputs (bank B): "))
     value:= GetB(Chip)
     pst.bin(value, 8)
     pst.Chars(pst#NL, 2)
     pst.Str(String("Setting a bank B (output) pin. enter pin number to set (0-7): "))
     value:= pst.DecIn
     pst.dec(value)
     pst.Str(String("   then enter pin state to set: "))
     state:= pst.DecIn
     pst.dec(state)     
     SetPin(Chip, value, state)
     pst.Chars(pst#NL, 2)
     pst.Str(String("Reading outputs (bank B) again: "))
     value:= GetB(Chip)
     pst.bin(value, 8)   
   ELSE
     pst.Chars(pst#NL, 2)
     pst.Str(String("Chip does not respond"))    
                                         
   
PUB Init(PINscl, PINsda)
   
   IF NOT bus.IsInitialized
     bus.Init(PINscl, PINsda)
     

PUB CfgDirA(chipAddress, value)

   bus.WriteByteA8(Chip, IODIRA, value)
   

PUB CfgDirB(chipAddress, value)

   bus.WriteByteA8(Chip, IODIRB, value)
   

PUB CfgPUrA(chipAddress, value)

   bus.WriteByteA8(Chip, GPPUA, value)
   

PUB CfgPUrB(chipAddress, value)

   bus.WriteByteA8(Chip, GPPUB, value)
   

PUB CfgIntA(chipAddress, value)

PUB CfgIntB(chipAddress, value)

PUB SetA(chipAddress, value)

   bus.WriteByteA8(Chip, GPIOA, value)
   

PUB SetB(chipAddress, value)

   bus.WriteByteA8(Chip, GPIOB, value)
   

PUB SetAB(chipAddress, value)

PUB SetPin(chipAddress, pin, state) | bank

   bank:= bus.ReadByteA8(Chip, GPIOB)
   bank:= (bank & !(1<<pin)) | state<<pin    
   bus.WriteByteA8(Chip, GPIOB, bank)
   

PUB GetA(chipAddress)

   RETURN bus.ReadByteA8(Chip, GPIOA)
   
   
PUB GetB(chipAddress)

   RETURN bus.ReadByteA8(Chip, GPIOB)
   

PUB GetAB(chipAddress)

PUB GetPin(chipAddress, value)


PRI private_method_name                                                                                                                      


DAT
name    byte  "string_data",0        


{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}