{{
 Demo of i2cDriver.spin
 Erlend Fj 2015
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Executes I2C bus commands such as Initiate, WhoOnBus, Read, and Write - provided through the PST serial terminal
 Also provides some ad-hoc features such as for re-writing chip addresses for several VL6108 chips on same bus
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements:  

==================================================================
 Hardware & wiring:


 Data sheet: <link>

=======================================================================================================================================================================
}

CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                          ' use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                         ' system freq as a constant
          mSec     = clk_freq / 1_000                                   ' ticks in 1ms
          uSec     = clk_freq / 1_000_000                               ' ticks in 1us
        
                
VAR
           BYTE  BusInitilized                                            'Flag to store if init is done
           LONG  OnBus[120] '                                             'Hold list of slaves detected, and put total number of slaves in OnBus[0]
        

OBJ
           bus   : "i2cDriver"
           pst   : "Parallax Serial Terminal"
          

PUB Main | value                                  

  pst.Start(9600)                      'PST speed is set low to allow batch transfer to be done without loosing characters. If File Send has an option for 
  WAITCNT((2*(clkfreq/1000)) + cnt)                                                           'inter-byte delay, use that, and you may go to higher speeds.
  value := pst.DecIn                                                     
  
  BusInitilized:= FALSE  
  
  pst.Str(String("Testing of I2C driver and bus."))                             
  repeat                                                                        
    pst.Chars(pst#NL, 2)                                                        
    pst.Str(String("Enter 0-Initiate, 1-WhoOnBus, 2-Read, 3-Write, 4-EEPROM Batch write, 5-Read first 100 from $8000, 6-New Address VL6108, -1-Quit: ")) 
    value := pst.DecIn                                                          
    pst.Chars(pst#NL, 2)                                                    

    CASE value
        0  : Initiate
        1  : ScanBus
        2  : Read
        3  : Write
        4  : Batch
        5  : Inspect

        -1 : QUIT
      OTHER: pst.Str(String("Sorry - invalid input."))
    
      
  pst.Str(String(pst#NL,"Bye."))                  
                                                            


PUB Initiate | PINscl, PINsda

    REPEAT
      pst.Str(String("Enter SCL pin number:"))
      PINscl:= || pst.DecIn
      pst.Dec(PINscl)
      pst.Chars(pst#NL, 2)
      pst.Str(String("Enter SDA pin number:"))
      PINsda:= || pst.DecIn
      pst.Dec(PINsda)
      pst.Chars(pst#NL, 2)
      IF PINscl>31 OR PINsda>31
        pst.Str(String("Pin number maximum 31!"))
        pst.Chars(pst#NL, 2)
      ELSE
        QUIT
        
    pst.Str(String("Now initialising bus..."))   
    bus.Init(PINscl, PINsda)
    pst.Chars(pst#NL, 2)
    pst.Str(String("Status of SCL: "))
    IF INA[PINscl] == 1
      pst.Str(String(" HIGH (good)"))
    ELSE
      pst.Str(String(" LOW (pull-up resistor missing?)"))
    pst.Chars(pst#NL, 2)
    pst.Str(String("Status of SDA: "))
    IF INA[PINsda] == 1
      pst.Str(String(" HIGH (good)"))
    ELSE
      pst.Str(String(" LOW (pull-up resistor missing?)"))
    pst.Chars(pst#NL, 2)   
    pst.Str(String("Bus initialization completed."))
    BusInitilized:= TRUE

    
PUB ScanBus | i
 
   IF NOT BusInitilized
     pst.Chars(pst#NL, 2)
     pst.Str(String("Bus not initialized, will do that first..."))
     pst.Chars(pst#NL, 2)     
     Initiate
       
   pst.Chars(pst#NL, 2)
   pst.Str(String("Now scanning bus..."))
   pst.Chars(pst#NL, 2)    
   bus.WhoOnBus(@OnBus)
   
   IF OnBus[0] > 0
     REPEAT i FROM 1 TO OnBus[0]
       pst.Str(String("Bus slave detected at address: $"))
       pst.Hex(OnBus[i], 4)
       pst.Chars(pst#NL, 2)
   pst.Dec(OnBus[0])
   pst.Str(String("  slaves found.  "))
   pst.Str(String("Scan completed."))   
   pst.Chars(pst#NL, 2)
   

PUB Read | ChipAddr, RegAddr, AddrForm, value 

   IF NOT BusInitilized
     pst.Chars(pst#NL, 2)
     pst.Str(String("Bus not initialized, will do that first..."))
     pst.Chars(pst#NL, 2)     
     Initiate    

   pst.Chars(pst#NL, 2)
   pst.Str(String("Enter Chip address (HEX):"))
   ChipAddr:= pst.HexIn
   pst.Hex(ChipAddr,4)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Enter Register address (HEX):"))
   RegAddr:= pst.HexIn
   pst.Hex(RegAddr, 4)
   pst.Chars(pst#NL, 2)
   
   REPEAT   
      pst.Str(String("-1-Quit, 1-8bit format, 2-16bit format, 3-8bitAddr Word data:"))
      AddrForm:= pst.DecIn      
      pst.Chars(pst#NL, 2)
   
      CASE AddrForm
          1  : value:= bus.ReadByteA8(ChipAddr, RegAddr)
            QUIT
          2  : value:= bus.ReadByteA16(ChipAddr, RegAddr)
            QUIT
          3  : value:= bus.ReadWordA8(ChipAddr, RegAddr)
            QUIT
          -1 : RETURN
        OTHER: pst.Str(String("Chose -1, 1, 2, or 3!"))
               pst.Chars(pst#NL, 2)
                
   pst.Str(String("Reply from chip: $"))    
   pst.Hex(value, 4)                                                                    
   pst.Str(String("   %"))
   pst.Bin(value, 32)
   pst.Str(String("   Dec: "))
   pst.Dec(value)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Read completed."))   
   pst.Chars(pst#NL, 2)


      
PUB Write | ChipAddr, RegAddr, AddrForm, Value 

   IF NOT BusInitilized
     pst.Chars(pst#NL, 2)
     pst.Str(String("Bus not initialized, will do that first..."))
     pst.Chars(pst#NL, 2)     
     Initiate

   pst.Chars(pst#NL, 2)
   pst.Str(String("Enter Chip address (HEX):"))
   ChipAddr:= pst.HexIn
   pst.Hex(ChipAddr, 4)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Enter Register address (HEX):"))
   RegAddr:= pst.HexIn
   pst.Hex(RegAddr, 4)
   pst.Chars(pst#NL, 2)
  
   REPEAT            
      pst.Str(String("-1-Quit, 1-8bit format, 2-16bit format, 3-8bitAddr Word data:"))
      AddrForm:= pst.DecIn      
      pst.Chars(pst#NL, 2)      
      pst.Str(String("Enter value to be written (HEX):"))
      Value:= pst.HexIn
      pst.Hex(Value, 4)
      pst.Chars(pst#NL, 2)
   
      CASE AddrForm
          1  : bus.WriteByteA8(ChipAddr, RegAddr, Value)
            QUIT
          2  : bus.WriteByteA16(ChipAddr, RegAddr, Value)
            QUIT
          3  : bus.WriteWordA8(ChipAddr, RegAddr, Value)
            QUIT
          -1 : RETURN
        OTHER: pst.Str(String("Chose -1, 1, 2, or 3!"))
               pst.Chars(pst#NL, 2)

   pst.Str(String("Write completed."))   
   pst.Chars(pst#NL, 2)         


PUB Batch | Value, ChipAddr, LocAddr, PointAddr, Terminator, count, choice

   IF NOT BusInitilized
     pst.Chars(pst#NL, 2)
     pst.Str(String("Bus not initialized, will do that first..."))
     pst.Chars(pst#NL, 2)     
     Initiate

   pst.Chars(pst#NL, 2)
   pst.Str(String("Enter Chip address (HEX):"))
   ChipAddr:= pst.HexIn
   pst.Hex(ChipAddr, 4)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Enter write start location (HEX):"))
   LocAddr:= pst.HexIn
   pst.Hex(LocAddr, 4)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Enter termination character (e.g. |):"))
   Terminator:= pst.CharIn
   pst.Char(Terminator)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Get ready to initiate batch transfer"))
   REPEAT 5
     WAITCNT(clkfreq/2 + cnt)
     pst.Str(String("."))
   pst.Chars(pst#NL, 2)  
   pst.Str(String("Start transfer!"))  
   pst.Chars(pst#NL, 2)

   PointAddr:= LocAddr
   Value:= 0
   count:=0
   REPEAT UNTIL Value== Terminator
     Value:= pst.CharIn
     bus.WriteByteA16(ChipAddr, PointAddr, Value)
     PointAddr+= 8
     count++

   pst.Str(String("Transfer of "))
   pst.Dec(count)
   pst.Str(String(" finished. Read back? Y/N"))
   choice:= pst.CharIn
   pst.Chars(pst#NL, 2)
   IF choice=="Y" OR choice=="y"
     PointAddr:= LocAddr 
     Value:= 0
     REPEAT count
       pst.Char(bus.ReadByteA16(ChipAddr, PointAddr))
       PointAddr+= 8
   pst.Chars(pst#NL, 2)  
   pst.Str(String("Done"))


PUB Inspect | PointAddr

   PointAddr:= $8000
   REPEAT 100
       pst.Char(bus.ReadByteA16($50, PointAddr))
       PointAddr+= 8
   pst.Chars(pst#NL, 2)  
   pst.Str(String("Done"))





   
DAT
               

{{

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and    
associated documentation files (the "Software"), to deal in the Software without restriction,        
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:                                                                 
                                                                                                     
The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.                                                                            
                                                                                                     
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}                                    