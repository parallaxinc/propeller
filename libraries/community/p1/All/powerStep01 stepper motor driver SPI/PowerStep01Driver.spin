{{
 PowerStep01Driver.spin
 Erlend Fj 2016
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Write and read to the PowerStep01 stepper motor driver, using SPI bus
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements: help and encouragementfrom the Forum 

=======================================================================================================================================================================
 Hardware & wiring:
 The X-NUCLEO-IHM03A1 carrier board has been used to test the driver. This board only supports control mode 'Voltage Mode'
  
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
 Data sheet:
 http://www.st.com/content/ccc/resource/technical/document/data_brief/61/d2/55/60/bf/b5/47/59/DM00151763.pdf/files/DM00151763.pdf/jcr:content/translations/en.DM00151763.pdf
 http://www.st.com/content/ccc/resource/technical/document/datasheet/3f/48/e2/37/6b/ac/4c/f5/DM00090983.pdf/files/DM00090983.pdf/jcr:content/translations/en.DM00090983.pdf
=======================================================================================================================================================================
}

CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                          ' use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                         ' system freq as a constant
          mSec     = clk_freq / 1_000                                   ' ticks in 1ms
          uSec     = clk_freq / 1_000_000                               ' ticks in 1us


          'REGISTER ADDRESSES         registers take from 1 to 3 byte parameters, ref datasheet                             
          '===================================================================================================================
          regABS_POS            = $01         'STATUS bits:      (default) Active=       Latch?                                    
          regEL_POS             = $02         '----------------------------------------------------                                
          regMARK               = $03         '15     STALL_A       (1)      0            L                                        
          regSPEED              = $04         '14     STALL_B       (1)      0            L                                        
          regACC                = $05         '13     OCD           (1)      0            L                                        
          regDEC                = $06         '12     TH_STATUS     (0)      ref          L                                        
          regMAX_SPEED          = $07         '11     TH_STATUS     (0)      table        L                                   
          regMIN_SPEED          = $08         '10     UVLO_ADC      (1)      0            L                                        
          regADC_OUT            = $12         '09     UVLO          (1)      0            L                                        
          regOCD_TH             = $13         '08     STCK_MOD      (0)      1            -                                        
          regFS_SPD             = $15                                                                                              
          regSTEP_MODE          = $16         '07     CMD_ERROR     (0)      1            L                                        
          regALARM_EN           = $17         '06     MOT_STATUS    (0)      ref          -                                        
          regGATECFG1           = $18         '05     MOT_STATUS    (0)      table        -                                        
          regGATECFG2           = $19         '04     DIR           (0)      0/1          -                                        
          regSTATUS             = $1B         '03     SW_EVN        (0)      1            L      ======================                                  
          regCONFIG             = $1A         '02     SW_F          (0)      1            -      STATUS 'normal' value:                                  
                                              '01     BUSY          (1)      0            -      11100110_00000011                                       
                                              '00     HiZ           (1)      0/1          -      ======================                                                                                                                                             
          'for voltage mode (default)                                                                                
                                                                                                 
          regKVAL_HOLD          = $09                                                                                                                    
          regKVAL_RUN           = $0A                                                                                                                    
          regKVAL_ACC           = $0B         'CONFIG bits:         (CM_VM=1)                                                                            
          regKVAL_DEC           = $0C         '---------------------------------------------------                                 
          regINT_SPEED          = $0D         '15     F_PWM_INT     (PRED_EN)                                                      
          regST_SLP             = $0E         '14     F_PWM_INT     (TSW)         PWM frequency                                    
          regFN_SLP_ACC         = $0F         '13     F_PWM_INT     (TSW)         parameters                                       
          regFN_SLP_DEC         = $10         '12     F_PWM_DEC     (TSW)              or                                          
          regK_THERM            = $11         '11     F_PWM_DEC     (TSW)        (Current control                                  
                                              '10     F_PWM_DEC     (TSW)         parameters)                                       
          regSTALL_TH           = $14         '09     VCCVAL        Gate driver Vcc =7.5 (0) =15(1)                                
                                              '08     UVLOVAL       Undervoltage lock ~6V(0)~10V(1)                                
          'for current mode                                                                                                        
                                              '07     OC_SD         Overcurrent shutdown (1)                                       
          regTVAL_HOLD          = $09         '06     na                                                                           
          regTVAL_RUN           = $0A         '05     EN_VSCOMP     (EN_TQREG)                                                     
          regTVAL_ACC           = $0B         '04     SW_MODE       Enable ext switch hard stop (0)                                
          regTVAL_DEC           = $0C         '03     EXT_CLK       Enable external clock (0)          ======================                             
          regT_FAST             = $0E         '02     OSC_SEL       ref.                               CONFIG 'normal' value:                            
          regTON_MIN            = $0F         '01     OSC_SEL       oscillator                         00001111_00011011                                 
          regTOFF_MIN           = $10         '00     OSC_SEL       config table                       ======================                       
                                                                                                       
                                                                         
          'COMMAND CODES
          '===========================================================================================================================
          cmdNOP                = %0000_0000                       'No operation                                                                                  
          cmdSetParam           = %0000_0000 '+ reg                'Set register parameter value, 1-3 bytes, MSB first                                            
          cmdGetParam           = %0010_0000 '+ reg                'Gets register parameter value, 1-3 bytes, MSB first                                           
          cmdRun                = %0101_0000 '+ Dir                'Runs at speed set by parameter as 3 bytes (20bit), MSB first                                  
          cmdStepClock          = %0101_1000 '+ Dir                'Switch to step-clock mode, i.e. microstep to external step clocking                           
          cmdMove               = %0100_0000 '+ Dir                'Move N steps given by parameter bytes 1-3                                                     
          cmdGoTo               = %0110_0000                       'Brings motor in ABS_POS position, minimum path                                                
          cmdGoToDir            = %0110_1000 '+ Dir                'Brings motor in ABS_POS position forcing DIR direction                                        
          cmdGoUntil            = %1000_0010 '+ Act + Dir          'Performs a motion in DIR direction with speed SPD until SW is closed                          
          cmdRelSw              = %1001_0010 '+ Act + Dir          'Performs a motion in DIR direction at minimum speed until the SW is released                  
          cmdGoHome             = %0111_0000                       'Brings the motor in HOME position                                                             
          cmdGoMark             = %0111_1000                       'Brings the motor in MARK position                                                             
          cmdResetPos           = %1101_1000                       'Resets the ABS_POS register                                                                   
          cmdResetDev           = %1100_0000                       'Device is reset to power-up conditions                                                        
          cmdSoftStop           = %1011_0000                       'Stops motor with a deceleration phase                                                         
          cmdHardstop           = %1011_1000                       'Hard stop                                                                                     
          cmdSoftHiZ            = %1010_0000                       'Puts the bridges in high impedance status aftera deceleration phase                           
          cmdHardHiZ            = %1010_1000                       'Puts the bridges in high impedance statusimmediately                                          
          cmdGetStatus          = %1101_0000                       'Returns the status register value                                                             

                
VAR
           BYTE  PINcs                                             'Chip select
           BYTE  PINrs                                             'Chip reset
        

OBJ
           bus   : "SPIdriver"
          

PUB Main                                                           'Demo

   Init(1, 2, 3, 1, 500, 8, 3, 0, 4)
   BaseSettings(0)
   Run(0, 100)
   WAITCNT((4*clkfreq) + cnt)
   Run(1, 10000)
   WAITCNT((4*clkfreq) + cnt)

   

PUB Init(PINmosi, PINmiso, PINclk, MsbLsb, Delay, FrameSize, Mode, _PINcs, _PINrs)
  
   IF NOT bus.IsInitialized                                             'Bus initialization is likely done by parent already
     bus.Init(PINmosi, PINmiso, PINclk, MsbLsb, Delay, FrameSize, Mode)
                                                             
   PINcs:= _PINcs                                                       'ChipSelect for this chip
   PINrs:= _PINrs                                                       'Reset for this chip
   DIRA[PINrs]:= 1
   ChipReset(1)                                                         'Reset this chip and give it time to wake up
   bus.DeselectChip(PINcs)                                              '


  'Control level commands
  '----------------------------------------------------------------
PUB SetCS(_PINcs)                                                       'Used by parent to select an other chip

   PINcs:= _PINcs

   
PUB SetRS(_PINrs)

   PINrs:= _PINrs

   
PUB ChipReset(EndState)

   OUTA[PINrs]:= 0                                                      'Reset this chip and give it time to wake up
   WAITCNT((clkfreq/1000) + cnt)        
   OUTA[PINrs]:= EndState


PUB SelectChip

    bus.SelectChip(PINcs)


PUB DeselectChip

   bus.DeselectChip(PINcs)
   
    

  'Chip level commands
  '---------------------------------------------------------------
PUB Cmd3Bytes(cmdCode, parByte2, parByte1, parByte0)

   bus.SelectChip(PINcs)
   bus.Transfer(cmdCode)
   bus.DeselectChip(PINcs)
   
   bus.SelectChip(PINcs)
   bus.Transfer(parByte2)
   bus.DeselectChip(PINcs)
            
   bus.SelectChip(PINcs)            
   bus.Transfer(parByte1)      
   bus.DeselectChip(PINcs)
   
   bus.SelectChip(PINcs)            
   bus.Transfer(parByte0)      
   bus.DeselectChip(PINcs)

   
PUB Cmd2Bytes(cmdCode, parByte1, parByte0)

   bus.SelectChip(PINcs)
   bus.Transfer(cmdCode)
   bus.DeselectChip(PINcs)
            
   bus.SelectChip(PINcs)            
   bus.Transfer(parByte1)      
   bus.DeselectChip(PINcs)
   
   bus.SelectChip(PINcs)            
   bus.Transfer(parByte0)      
   bus.DeselectChip(PINcs)

   
PUB Cmd1Byte(cmdCode, parByte0)

   bus.SelectChip(PINcs)
   bus.Transfer(cmdCode)
   bus.DeselectChip(PINcs)
   
   bus.SelectChip(PINcs)            
   bus.Transfer(parByte0)      
   bus.DeselectChip(PINcs)


PUB Cmd0Bytes(cmdCode)

   bus.SelectChip(PINcs)
   bus.Transfer(cmdCode)
   bus.DeselectChip(PINcs)
   
   
PUB ReadReg(regAddr, bytes) | Data32

   bus.SelectChip(PINcs)
   bus.Transfer(cmdGetParam + regAddr)
   bus.DeselectChip(PINcs)
   IF bytes== 3  
     bus.SelectChip(PINcs)
     Data32.BYTE[2]:= bus.Transfer(cmdNOP)
     bus.DeselectChip(PINcs)
   IF bytes=> 2  
     bus.SelectChip(PINcs)            
     Data32.BYTE[1]:= bus.Transfer(cmdNOP)      
     bus.DeselectChip(PINcs)
   bus.SelectChip(PINcs)            
   Data32.BYTE[0]:= bus.Transfer(cmdNOP)      
   bus.DeselectChip(PINcs)
   
   RETURN Data32                                                     'Returns a LONG with all the info bits from the 1 to 3 bytes transferred
   


PUB BaseSettings(CM) | cfg1, cfg0, stpm                              'Loads a basic set of configuration values to get up and running

   Cmd1Byte(cmdSetParam + regALARM_EN, %1110_1111 )                   'Enables all alarms but the ADC low level alarm  
  
   IF CM >0
   'For Current Mode:
  '-----------------
     cfg1:= %0_00000_1_1                                             'Precompensation Off, Switching 4uS, VCC=15V, UVLO low                                             
     cfg0:= %1_0_0_1_1011                                            'Overcurrent SD on, X, Torque Reg off, Switch f/ Hard Stop, Int.Clock 16MHz o/p 16MHz              
     stpm:= %0_111_1_111                                             'Synch disabled, Step 1/128 uSteps, Current Mode,  Sync 1/128 uSteps                               
                                                                                                                                                                       
   ELSE                                                              'Note: X-NUCLEO-IHM03A1 carrier board has not populated the components for the ADC for Voltage comp
   'For Voltage Mode:                                                                                                                                                   
  '-----------------                                                                                                                                                   
     cfg1:= %000_011_1_1                                             'PWM div factor 1, PWM multip factor 1, VCC=15V, UVLO low                                          
     cfg0:= %0_0_0_1_1011                                            'Overcurrent SD off, X, Voltage comp off, Switch f/ Hard Stop, Int.Clock 16MHz o/p 16MHz           
     stpm:= %0_111_0_111                                             'Synch disabled, Step 1/128 uSteps, Voltage Mode,  Sync 1/128 uSteps                                
                                                                                                                                                                       
   Cmd2Bytes(cmdSetParam + regCONFIG, cfg1, cfg0)                    '                                                                                                    
   Cmd1Byte(cmdSetParam + regSTEP_MODE, stpm)                                                                                                                      
   Cmd1Byte(cmdSetParam + regSTALL_TH, %000_11111)                    'Stall A or B threshold= 1V                                                                       
   Cmd1Byte(cmdSetParam + regOCD_TH, %0001_1111)                      'Overcurrent threshold= 1V                                                                        
   Cmd2Bytes(cmdSetParam + regGATECFG1, %0000_0_000, %110_00000)      'X, Clock WD off, Overboost= 0, Gate current= 64mA, Constant current dur= 125nS

   
   
  'Application level commands
  '-------------------------------------------------------------------

PUB ReadStatus

   RETURN ReadReg(regSTATUS, 2)                                       'Returns a LONG with all the status bits from the bytes transferred
  

   
PUB Run(Dir, Speed) | parSpeed                                        'Dir 1=Forward 0=Reverse, Speed steps/S, max 15625                                              
    
   parSpeed:= Speed * 67                                              'Convert from steps/Sec to some internal format        
   NoOpSynch    
   Cmd3Bytes(cmdRun + Dir, parSpeed.BYTE[2], parSpeed.BYTE[1], parSpeed.BYTE[0])      'SpeedByte2(nibble), SpeedByte1, SpeedByte0
   
   RETURN (ReadStatus & 1<<7) >>7                                      'Returns the CMD_ERROR bit (=1 for command error, else =0)

   
PUB StepClock(Dir)                                                    'Puts into step-mode
                                             
   NoOpSynch
   Cmd0Bytes(cmdStepClock + Dir) 
   
   RETURN (ReadStatus & 1<<7) >>7
   

PUB Move(Dir, Steps)                                                  
                                              
   NoOpSynch
   Cmd3Bytes(cmdMove + Dir, Steps.BYTE[2], Steps.BYTE[1], Steps.BYTE[0]) 
   
   RETURN (ReadStatus & 1<<7) >>7


PUB GoTo(AbsPos)                                                       'Goes shortest path to absolute position
                                              
   NoOpSynch
   Cmd3Bytes(cmdGoTo, AbsPos.BYTE[2], AbsPos.BYTE[1], AbsPos.BYTE[0]) 
   
   RETURN (ReadStatus & 1<<7) >>7


PUB GoToDir(Dir, AbsPos)                                                  
                                              
   NoOpSynch
   Cmd3Bytes(cmdGoToDir + Dir, AbsPos.BYTE[2], AbsPos.BYTE[1], AbsPos.BYTE[0]) 
   
   RETURN (ReadStatus & 1<<7) >>7
   
      
PUB GoUntil(Dir, Speed) | parSpeed                                     'Parameter ACT is not supported, (left =0) 
                                                                       'use Cmd3Bytes direct, if it needs setting
   parSpeed:= Speed * 67                                              
   NoOpSynch
   Cmd3Bytes(cmdGoUntil + Dir, parSpeed.BYTE[2], parSpeed.BYTE[1], parSpeed.BYTE[0]) 
   
   RETURN (ReadStatus & 1<<7) >>7
                                   

PUB ReleaseSw(Dir)                                                     'Runs at MIN_SPEED in Dir, and HardStops when switch is opened    
                                              
   NoOpSynch
   Cmd0Bytes(cmdRelSw + Dir) 
   
   RETURN (ReadStatus & 1<<7) >>7
   

PUB GoHome                                                             'Runs shortest path to Home position    
                                              
   NoOpSynch
   Cmd0Bytes(cmdGoHome)
   
   RETURN (ReadStatus & 1<<7) >>7
   

PUB GoMark                                                             'Runs shortest path to Mark position    
                                              
   NoOpSynch
   Cmd0Bytes(cmdGoMark)
   
   RETURN (ReadStatus & 1<<7) >>7
   

PUB ResetPos                                                            'Resets ABS_POS to zero    
                                              
   NoOpSynch
   Cmd0Bytes(cmdResetPos)
   
   RETURN (ReadStatus & 1<<7) >>7
   
   
PUB ResetDevice                                                        'Resets the device to power up conditions    
                                              
   NoOpSynch
   Cmd0Bytes(cmdResetDev)
   
   RETURN (ReadStatus & 1<<7) >>7


PUB SoftStop                                                           'Deceleration to full stop    
                                              
   NoOpSynch
   Cmd0Bytes(cmdSoftStop)
   
   RETURN (ReadStatus & 1<<7) >>7


PUB HardStop                                                           'Immediate full stop    
                                              
   NoOpSynch
   Cmd0Bytes(cmdHardstop)
   
   RETURN (ReadStatus & 1<<7) >>7


PUB SoftHiZ                                                           'Deceleration to full stop, then bridges into high impedance    
                                              
   NoOpSynch
   Cmd0Bytes(cmdSoftHiZ)
   
   RETURN (ReadStatus & 1<<7) >>7
   

PUB HardHiZ                                                           'Immediate full stop, then bridges into high impedance    
                                              
   NoOpSynch
   Cmd0Bytes(cmdHardHiZ)
   
   RETURN (ReadStatus & 1<<7) >>7
   
   
PUB GetStatus | Data32                                                 'Reads and resets Status register

   bus.SelectChip(PINcs)
   bus.Transfer(cmdGetStatus)
   bus.DeselectChip(PINcs)  
   bus.SelectChip(PINcs)            
   Data32.BYTE[1]:= bus.Transfer(cmdNOP)      
   bus.DeselectChip(PINcs)
   bus.SelectChip(PINcs)            
   Data32.BYTE[0]:= bus.Transfer(cmdNOP)      
   bus.DeselectChip(PINcs)
                                                                  
   RETURN Data32                                                      'Returns a LONG with all the info bits from the 1 to 3 bytes transferred
 
 
   
PRI NoOpSynch                                                          'Sends 3 consecutive NOP to clear 'hanging commands'
                                                                       'for a more noise immune link
   REPEAT 3
     bus.SelectChip(PINcs)            
     bus.Transfer(cmdNOP)   
     bus.DeselectChip(PINcs)

   
DAT
name    byte  "string_data",0        
        