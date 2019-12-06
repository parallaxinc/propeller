{{
 Demo of PowerStep1driver.spin
 Erlend Fj 2016
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Write and read to the PowerStep1 stepper motor driver, using SPI bus
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements: help and encouragementfrom the Forum 

=======================================================================================================================================================================
 Hardware & wiring:  This Demo is developed on and tested with the X-NUCLEO-IHM03A1 carrier board. Only Control Mode= 'Voltage Mode' is supported. 'Current Mode not tested'.

 
 +------+            +---------------------------+
 |      +-------+Gnd |GND                   IOREF|- 3.3V
 | P8X32|            |      powerStep01          |
 |      +-------+Clk |SCK      on             GND++Gnd +
 |      |            |      X-NUCLEO-IHM03A      |     |
 |      +-------+Miso|MISO                       |     |
 |      |            |                           |     |
 |      +-------+Mosi|MOSI                       |     |
 |      |            |                           |     |
 |      +-------+Cs  |CS                         |     |
 |      |            |                           |     |
 |      |            |PWM         +--------------------+
 |      |            |            |              |
 |      +-------+Rst |RST         |              |
 |      |            |            +              |
 |      |            |     A+ B+ GND B- A-       |
 |      |            +---------------------------+             +------------+
 |      |                  |  |   |  |  |----------------------+            |
 |      |                  |  |   |  +-------------------------|  STEPPER   |
 |      |                  |  |   +----------------------------|   MOTOR    |
 |      |                  |  +--------------------------------|            |
 +------+                  +-----------------------------------+            |
                                                               +------------+

 
=======================================================================================================================================================================
}

CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                          ' use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                         ' system freq as a constant
          mSec     = clk_freq / 1_000                                   ' ticks in 1ms
          uSec     = clk_freq / 1_000_000                               ' ticks in 1us


                
VAR
           BYTE  BusInitialized                      'Flag to store if init is done
           LONG  PINmosi, PINmiso, PINclk, PINrs, MsbLsb, Delay, FrameSize, Mode 
           
        

OBJ
           pst   : "Parallax Serial Terminal"
           ps1   : "PowerStep01Driver"
          

PUB Main | value                                  

  pst.Start(57600)                      
  WAITCNT((1*(clkfreq)) + cnt)
  pst.Str(String("Testing of PowerStep1 driver over SPI bus. ENTER to begin."))
  value := pst.DecIn     'Wait for keyboard entry before continue

  repeat                                                                        
    pst.Chars(pst#NL, 2)                                                        
    pst.Str(String("Enter 0-Initiate, 1-Base settings, 2- Print reg values,  3 - RunSpeed,  4- MoveSteps, 5- GotoPos, 6- Home, 7- SoftStop,"))
    pst.Chars(pst#NL, 2)
    pst.Str(String("8- GetStatus -1- Quit: "))
    value := pst.DecIn                                                          
    pst.Chars(pst#NL, 2)                                                    

    CASE value
        0  : Initiate
        1  : BaseSet
        2  : PrintRegs
        3  : RunSpeed
        4  : MoveSteps
        5  : GotoPos
        6  : Home
        7  : SoftStop
        8  : GetStatus  
        -1 : QUIT
      OTHER: pst.Str(String("Sorry - invalid input."))
     
  pst.Str(String(pst#NL,"Bye."))                  


                                                                               
PUB Initiate 
                                                               
   ps1.Init(1, 2, 3, 1, 500, 8, 3, 0, 4)                              'Init(PINmosi, PINmiso, PINclk, MsbLsb, Delay, FrameSize, Mode, _PINcs, _PINrs)
   pst.Str(String("Initialization done."))
   pst.Chars(pst#NL, 2)
   BusInitialized:= TRUE


PUB BaseSet | value                                               'CM= 0 default; Voltage Mode, CM=1 Current Mode

   pst.Str(String("Voltage Mode (=0) or Current Mode (=1)"))
   value := pst.DecIn
   ps1.BaseSettings(value)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Base settings done."))
   pst.Chars(pst#NL, 2)
   

PUB RunSpeed | Speed, Dir, value, flgCmdErr

   pst.Str(String("RunSpeed, enter speed [-15 000 to  +15 000] "))
   value := pst.DecIn
   Speed:= || value
   IF value < 0
     Dir:= 0
   ELSE
     Dir:= 1  
   flgCmdErr:= ps1.Run(Dir, Speed)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Run commanded (=0 is OK): "))
   pst.Bin(flgCmdErr, 1)
   pst.Chars(pst#NL, 2)
   

PUB MoveSteps | Steps, Dir, value, flgCmdErr

   pst.Str(String("MoveSteps, enter microsteps [-4 mill to  +4 mill] "))
   value := pst.DecIn
   Steps:= || value
   IF value < 0
     Dir:= 0
   ELSE
     Dir:= 1  
   flgCmdErr:= ps1.Move(Dir, Steps)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Move commanded (=0 is OK): "))
   pst.Bin(flgCmdErr, 1)
   pst.Chars(pst#NL, 2)
 

PUB GotoPos | Steps, Dir, value, flgCmdErr

   pst.Str(String("GotoPos, enter absolut position [0 to  +4 mill] "))
   Steps:= || pst.DecIn
   flgCmdErr:= ps1.GoTo(Steps)
   pst.Chars(pst#NL, 2)
   pst.Str(String("GoTo commanded (=0 is OK): "))
   pst.Bin(flgCmdErr, 1)
   pst.Chars(pst#NL, 2)
   

PUB Home | flgCmdErr

   flgCmdErr:= ps1.GoHome
   pst.Chars(pst#NL, 2)
   pst.Str(String("GoHome commanded (=0 is OK): "))
   pst.Bin(flgCmdErr, 1)
   pst.Chars(pst#NL, 2)   


PUB SoftStop | flgCmdErr

   flgCmdErr:= ps1.SoftStop
   pst.Chars(pst#NL, 2)
   pst.Str(String("SoftStop commanded (=0 is OK): "))
   pst.Bin(flgCmdErr, 1)
   pst.Chars(pst#NL, 2)   


PUB GetStatus | Data32 

   Data32:= ps1.GetStatus
   pst.Str(String("Status word: "))
   pst.Bin(Data32, 16)
   pst.Chars(pst#NL, 2)      

   
PUB PrintRegs | Data32, bitCM_VM


   IF NOT BusInitialized
     pst.Str(String("Forgot to initialize, will do that first."))
     pst.Chars(pst#NL, 2)
     Initiate

   pst.Chars(pst#NL, 2) 
   pst.Str(String("======================================================================"))
   pst.Chars(pst#NL, 2) 
   pst.Str(String("ADDR    REG NAME       VALUE bin                             VALUE hex "))
   pst.Chars(pst#NL, 2) 
   pst.Str(String("======================================================================"))
                  '0001    regABS_POS     000000000000000000000000.........000000 
   pst.Chars(pst#NL, 2)

   bitCM_VM:= (ps1.ReadReg(ps1#regSTEP_MODE, 1) & ( 1 << 3 )) >> 3         'Extract the CM bit from STEP_MODE byte          
 
   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regABS_POS,4)
   Data32:= ps1.ReadReg(ps1#regABS_POS, 3)
   pst.Str(String("....regABS_POS....."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6) 
   
   
   pst.Chars(pst#NL, 2) 
   pst.Hex(ps1#regEL_POS,4)
   Data32:= ps1.ReadReg(ps1#regEL_POS, 2)
   pst.Str(String("....regEL_POS......"))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6) 


   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regMARK,4)
   Data32:= ps1.ReadReg(ps1#regMARK, 3)
   pst.Str(String("....regMARK........"))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regSPEED,4)
   Data32:= ps1.ReadReg(ps1#regSPEED, 3)
   pst.Str(String("....regSPEED......."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   
 
   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regACC,4)
   Data32:= ps1.ReadReg(ps1#regACC, 2)
   pst.Str(String("....regACC........."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   
   
   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regDEC,4)
   Data32:= ps1.ReadReg(ps1#regDEC, 2)
   pst.Str(String("....regDEC........."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regMAX_SPEED,4)
   Data32:= ps1.ReadReg(ps1#regMAX_SPEED, 2)
   pst.Str(String("....regMAX_SPEED..."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regMIN_SPEED,4)
   Data32:= ps1.ReadReg(ps1#regMIN_SPEED, 2)
   pst.Str(String("....regMIN_SPEED..."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6) 

   
   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regADC_OUT,4)
   Data32:= ps1.ReadReg(ps1#regADC_OUT, 1)
   pst.Str(String("....regADC_OUT....."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regOCD_TH,4)
   Data32:= ps1.ReadReg(ps1#regOCD_TH, 1)
   pst.Str(String("....regOCD_TH......"))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regFS_SPD,4)
   Data32:= ps1.ReadReg(ps1#regFS_SPD, 2)
   pst.Str(String("....regFS_SPD......"))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   
   
   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regSTEP_MODE,4)
   Data32:= ps1.ReadReg(ps1#regSTEP_MODE, 1)
   pst.Str(String("....regSTEP_MODE..."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6) 
   pst.Str(String("....CM_VM= "))
   pst.Bin(bitCM_VM, 1)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regALARM_EN,4)
   Data32:= ps1.ReadReg(ps1#regALARM_EN, 1)
   pst.Str(String("....regALARM_EN...."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regGATECFG1,4)
   Data32:= ps1.ReadReg(ps1#regGATECFG1, 2)
   pst.Str(String("....regGATECFG1...."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regGATECFG2,4)
   Data32:= ps1.ReadReg(ps1#regGATECFG2, 1)
   pst.Str(String("....regGATECFG2...."))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regSTATUS,4)
   Data32:= ps1.ReadReg(ps1#regSTATUS, 2)
   pst.Str(String("....regSTATUS......"))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)
   

   pst.Chars(pst#NL, 2)
   pst.Hex(ps1#regCONFIG,4)
   Data32:= ps1.ReadReg(ps1#regCONFIG, 2)
   pst.Str(String("....regCONFIG......"))
   pst.Bin(Data32, 32)
   pst.Str(String("........"))
   pst.Hex(Data32, 6)

   
'------------------------------------------------------------------
' if Voltage mode set (CM_VM bit in STEP_MODE register is set to 0)
'------------------------------------------------------------------

   IF bitCM_VM== 0                       'Voltage mode

     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regKVAL_HOLD,4)
     Data32:= ps1.ReadReg(ps1#regKVAL_HOLD, 1)                     
     pst.Str(String("....regKVAL_HOLD..."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
     
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regKVAL_RUN,4)
     Data32:= ps1.ReadReg(ps1#regKVAL_RUN, 1)                     
     pst.Str(String("....regKVAL_RUN...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)                                  

     
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regKVAL_ACC,4)
     Data32:= ps1.ReadReg(ps1#regKVAL_ACC, 1)                       
     pst.Str(String("....regKVAL_ACC...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)                                 
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regKVAL_DEC,4)
     Data32:= ps1.ReadReg(ps1#regKVAL_DEC, 1)                     
     pst.Str(String("....regKVAL_DEC...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
               
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regINT_SPEED,4)
     Data32:= ps1.ReadReg(ps1#regINT_SPEED, 2)                       
     pst.Str(String("....regINT_SPEED..."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                 
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regST_SLP,4)
     Data32:= ps1.ReadReg(ps1#regST_SLP, 1)                    
     pst.Str(String("....regST_SLP......"))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                     
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regFN_SLP_ACC,4)
     Data32:= ps1.ReadReg(ps1#regFN_SLP_ACC, 1)              
     pst.Str(String("....regFN_SLP_ACC.."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)                                 

           
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regFN_SLP_DEC,4)
     Data32:= ps1.ReadReg(ps1#regFN_SLP_DEC, 1)                      
     pst.Str(String("....regFN_SLP_DEC.."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                       
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regK_THERM,4)
     Data32:= ps1.ReadReg(ps1#regK_THERM, 1)                     
     pst.Str(String("....regK_THERM....."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                 
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regSTALL_TH,4)
     Data32:= ps1.ReadReg(ps1#regSTALL_TH, 1)                      
     pst.Str(String("....regSTALL_TH...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)              
     
'------------------------------------------------------------------
' if Current mode set (CM_VM bit in STEP_MODE register is set to 1)
'------------------------------------------------------------------
   IF bitCM_VM== 1                       'Current mode

     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regTVAL_HOLD,4)
     Data32:= ps1.ReadReg(ps1#regTVAL_HOLD, 1)                    
     pst.Str(String("....regTVAL_HOLD..."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                   
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regTVAL_RUN,4)
     Data32:= ps1.ReadReg(ps1#regTVAL_RUN, 1)                   
     pst.Str(String("....regTVAL_RUN...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                     
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regTVAL_ACC,4)
     Data32:= ps1.ReadReg(ps1#regTVAL_ACC, 1)                    
     pst.Str(String("....regTVAL_ACC...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)                                 

          
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regTVAL_DEC,4)
     Data32:= ps1.ReadReg(ps1#regTVAL_DEC, 1)                     
     pst.Str(String("....regTVAL_DEC...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                      
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regT_FAST,4)
     Data32:= ps1.ReadReg(ps1#regT_FAST, 1)                      
     pst.Str(String("....regT_FAST......"))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                      
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regTON_MIN,4)
     Data32:= ps1.ReadReg(ps1#regTON_MIN, 1)                     
     pst.Str(String("....regTON_MIN....."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)
                
                                                
     pst.Chars(pst#NL, 2)
     pst.Hex(ps1#regTOFF_MIN,4)
     Data32:= ps1.ReadReg(ps1#regTOFF_MIN, 1)                     
     pst.Str(String("....regTOFF_MIN...."))     
     pst.Bin(Data32, 32)
     pst.Str(String("........"))
     pst.Hex(Data32, 6)                

   pst.Chars(pst#NL, 2) 
   pst.Str(String("====================================================================="))
   pst.Chars(pst#NL, 2)

   
DAT
name    byte  "string_data",0        
        