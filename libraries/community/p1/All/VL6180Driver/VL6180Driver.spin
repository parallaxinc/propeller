{{
 VL6180Driver. Drives the range finder microchip from ST Microelectronics over I2C bus communication.
 Erlend Fj. 2015
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Provides methods for identifying, address-changing, initializing, and reading range and ALS single-shot or interleaved continous. 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Revisions:
 - Added method to re-address chips when several on same bus, and powered through RC delay
 - Fixed incomplete pub for returning result range status

}}
{
 Acknowledgements:  Builds on the work by John Abshier

=======================================================================================================================================================================
 Hardware & wiring:

 Connects to I2C bus through SCL and SDA pins. P-u resistors needed. If more VL's are on the same bus, the Reset pin needs to be controlled such that one at the time
 boots up and gets its adress re-written. One way to do this is to connect the Resets to +V through  RC networks, where R x C provides a delayed boot, each C different
 to ensure each chip boots after the other. A routine needs to be run to continously listen for chips answering on the default address, and re-wrtie them as they appear.
 Thereafter the chips will respond on their newly re-written addresses.

 Data sheet: http://www.st.com/web/en/resource/technical/document/datasheet/DM00112632.pdf
             http://www.st.com/st-web-ui/static/active/en/resource/technical/document/application_note/DM00122600.pdf
=======================================================================================================================================================================
}

CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                          ' use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                         ' system freq as a constant
          mSec     = clk_freq / 1_000                                   ' ticks in 1ms
          uSec     = clk_freq / 1_000_000                               ' ticks in 1us
             
             
 'VL6180X REGISTERS (not complete)
 '=======================================================         
          ID_MODEL_ID                          = $00                    

          SYSTEM_MODE_GPIO0                    = $10 
          SYSTEM_MODE_GPIO1                    = $11 
          SYSTEM_HISTORY_CTR                   = $12 
          SYSTEM_INTERRUPT_CONFIG_GPIO         = $14 
          SYSTEM_INTERRUPT_CLEAR               = $15 
          SYSTEM_FRESH_OUT_OF_RESET            = $16 
          SYSTEM_GROUPED_PARAMETER_HOLD        = $17
           
          SYSRG_START                          = $18
          SYSRG_THRESH_HIGH                    = $19
          SYSRG_THRESH_LOW                     = $1A
          SYSRG_INTERMEASUREMENT_PERIOD        = $1B
          SYSRG_MAX_CONVERGENCE_TIME           = $1C
          SYSRG_XTALK_COMPENSATION_RATE        = $1E 
          SYSRG_XTALK_VALID_HEIGHT             = $21 
          SYSRG_EARLY_CONVERGENCE_EST          = $22 
          SYSRG_PART_TO_PART_RNG_OFFSET        = $24 
          SYSRG_RNG_IGNORE_VALID_HEIGHT        = $25 
          SYSRG_RANGE_IGNORE_THRESHOLD         = $26
          SYSRG_MAX_AMBIENT_LEVEL_MULT         = $2C
          SYSRG_RANGE_CHECK_ENABLES            = $2D
          SYSRG_VHV_RECALIBRATE                = $2E
          SYSRG_VHV_REPEAT_RATE                = $31
          
          SYSALS_START                         = $38 
          SYSALS_THRESH_HIGH                   = $3A
          SYSALS_THRESH_LOW                    = $3C
          SYSALS_ANALOGUE_GAIN                 = $3F 
          SYSALS_INTEGRATION_PERIOD            = $40 
          SYSALS_INTERMEASUREMENT_PERIOD       = $3E

          RESULT_RANGE_STATUS                  = $4D
          
          RESULT_INT_STATUS_GPIO               = $4F
          RESULT_ALS_VAL                       = $50 
          READOUT_AVERAGE_SAMPLE_PERIOD        = $10A
          RESULT_RANGE_VAL                     = $62 

          FIRMWARE_RESULT_SCALER               = $120

          SLAVE_DEVICE_ADDRESS                 = $212                              'For setting new chip address
          
          INTERLEAVED_MODE_ENABLE              = $2A3

DAT
          ALSgain LONG 200, 103, 52, 26, 17, 13, 10, 400                           'Actual gainx10 lookup table
        
OBJ
          bus:    "i2cDriver"                                             
          pst   : "Parallax Serial Terminal"


VAR
          LONG      PINrs


 'DEMO CODE
 '==================================================                                 'Comment out this section if memory space is premium
PUB Main  | value, range, light, comb                                              

    pst.Start(9600)                   
    WAITCNT((2*(clkfreq/1000)) + cnt)
    pst.Str(String("Press key to begin...")) 
    value := pst.DecIn   
    pst.Chars(pst#NL, 2)
    pst.Str(String("Testing of VL6180:..."))
    pst.Chars(pst#NL, 2)                                '                      
    Init(7,6,5)                                                                      'Init(PINscl, PINsda, _PINrs) 
    ChipReset(1)                                                                     'Un-reset chip
    WAITCNT((1*(clkfreq)) + cnt)                                             
    IF IsThere($29)
      pst.Str(String("VL6180 detected!"))
    ELSE
      pst.Str(String("VL6180 not found!"))
      ABORT
      
    LoadChip($29)
    
    range:= GetSingleRange($29)
    light:= GetSingleLight($29, 2)                                                    'Gain should be between 0 and 7
    pst.Chars(pst#NL, 2)
    pst.Str(String("Single range shot range: "))
    pst.Dec(range)
    pst.Str(String("  light: "))
    pst.Dec(light)
    WAITCNT((1*(clkfreq)) + cnt)
    pst.Chars(pst#NL, 2)
    
    pst.Str(String("Begin continuous ranging... press enter for new readout "))
    BeginContRG($29, 6)
    REPEAT 5                                                                           'Interval of 6*10mS
      value := pst.DecIn
      pst.Chars(pst#NL, 2)
      pst.Str(String("Range= "))
      range:= WaitRange($29)
      pst.Dec(range)
    pst.Chars(pst#NL, 2)
    EndContRG($29)
         
    pst.Str(String("Begin continuous ALS ... press enter for new readout "))
    BeginContALS($29, 6)
    REPEAT 5
      value := pst.DecIn
      pst.Chars(pst#NL, 2)
      pst.Str(String("Light= "))
      light:= WaitALS($29, 2)                                                  
      pst.Dec(light) 
    pst.Chars(pst#NL, 2)
    EndContRG($29)
    
    pst.Str(String("Demo finished. Bye."))      

   
 'DRIVER CODE,
 'CONTROL LEVEL COMMANDS
 '---------------------------------------------------------------------------------    
PUB Init(PINscl, PINsda, _PINrs)

   IF NOT bus.IsInitialized
     bus.Init(PINscl, PINsda)

   PINrs:= _PINrs                                                                    'Sets default reset pin
   DIRA[PINrs]:= 1


PUB SetRS(_PINrs)                                                                    'In case different chips are connected to different reset pin

   PINrs:= _PINrs

   
PUB ChipReset(EndState)

   OUTA[PINrs]:= 0                                                                   'Reset this chip and give it time to wake up
   WAITCNT((clkfreq/1000) + cnt)        
   OUTA[PINrs]:= EndState


PUB ReAddr(ChipAddr, PINpwr) | NewAddr, tries                                        'Write new address to chip by utilizing R-C delayed wake-up

   OUTA[PINpwr]:= 0                                                                  'Pull down the power cntl pin
   DIRA[PINpwr]:= 1
   
   NewAddr:= ChipAddr + 1
   tries:= 0                                                                          
   DIRA[PINpwr]:= 0                                                                  'Let power cntl pin float to high  (Chip GPIO0 through PU resistor & capacitor to gnd)
                                                                       
   REPEAT UNTIL tries> 100 OR (NewAddr > ChipAddr + 10)                              'number of tries depend on RC circuit time delay value
     IF bus.ReadByteA16(ChipAddr, ID_MODEL_ID)==  $B4                                'Check for reply
       bus.WriteByteA16(ChipAddr, SLAVE_DEVICE_ADDRESS, NewAddr)                     'Write new address
       NewAddr++
    tries++   


 'CHIP LEVEL COMMANDS
 '-------------------------------------------------------------------------------
PUB NewAddress(iChipAddr, iNewChipAddr)                                              'Use this call in combination with a sequenced boot of several chips to set new address as each chip comes on line

   RETURN bus.WriteByteA16(iChipAddr, SLAVE_DEVICE_ADDRESS, iNewChipAddr)
  
                                                     
PUB IsThere(iChipAddr)                                                               'Verify that the particular chip is responding to it's address on the bus

   RETURN bus.ReadByteA16(iChipAddr, ID_MODEL_ID)


PUB LoadChip(iChipAddr)                                                              'Load chip with default and best practice settings

   MandatoryLoad(iChipAddr)
   RecommendedLoad(iChipAddr)


   
 'APPLICATION LEVEL COMMANDS
 '-------------------------------------------------------------------------------
  'Single shot operation
 '===============================================================================  
PUB GetSingleRange(iChipAddr) | status                                               'Single Shot Range
 
   status:= 0
   bus.WriteByteA16(iChipAddr, SYSRG_START, $01)                                     'Set and start single shot ranging
     
   REPEAT UNTIL status == $04                                                        'Repeat until ranging status equals New Sample Ready (bit2=1)
     status:= (bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO)& $07)              'Check the result interrupt status, and extract the ranging status
   RESULT:= bus.ReadByteA16(iChipAddr, RESULT_RANGE_VAL)                             'Return value
   bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next
  
  
PUB GetSingleLight(iChipAddr, gain) | raw, ALSintPrd, status                         'Single Shot ALS

  status:= 0  
  bus.WriteByteA16(iChipAddr, SYSALS_ANALOGUE_GAIN, gain)                           'Load parameter gain 
  bus.WriteByteA16(iChipAddr, SYSALS_START, $01)                                    'Set and start single shot als
  
  REPEAT UNTIL status == $20                                                        'Repeat until ranging status equals New Sample Ready (bit5=1)
    status := bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $38              'Check the result interrupt status, and extract the ranging status    
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next
  
  raw:= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL) << 8                             'Read raw value MSB
  raw|= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL + 1)                              'Read raw value LSB and put into same variable 
  ALSintPrd:= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD)  << 8           'Read als integration period, MSB
  ALSintPrd|= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD + 1)             'Read als integration period, LSB, and put into same variable
   
  RESULT:= (320_000 / (ALSintPrd * ALSgain[gain & $F])) * raw                       'Calculate and return result as ambient light in mLux (as pre-calibrated)
  


 'Continuous operation
 '=============================================================================
 'Range finding ---------------------------------------------------------------

PUB BeginContRG(iChipAddr, interval)                                               'Continous ranging                          
                      
  bus.WriteByteA16(iChipAddr, SYSRG_INTERMEASUREMENT_PERIOD, interval)              'Set the polling intervals in steps of 10mS (not too tight!)
  bus.WriteByteA16(iChipAddr, SYSRG_START, $03)                                     'Start (toggle) continous mode operation      '                            


PUB WaitRange(iChipAddr) | Status                                                   'Reading of range during contiuous, wait for result ready

  status:= 0
  REPEAT UNTIL status == $04                                                        'Repeat until ranging status equals New Sample Ready (bit2=1)
    status := bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $04
  RESULT:= bus.ReadByteA16(iChipAddr, RESULT_RANGE_VAL)                             'Check the result interrupt status, and extract the ranging status    
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next


PUB GetRange(iChipAddr)

  RESULT:= bus.ReadByteA16(iChipAddr, RESULT_RANGE_VAL)


PUB EndContRG(iChipAddr)

  bus.WriteByteA16(iChipAddr, SYSRG_START, $01)
  

 'Ambient light measurement ---------------------------------------------------
 
PUB BeginContALS(iChipAddr, interval)                                               'Continous ALS

  bus.WriteByteA16(iChipAddr, SYSALS_INTERMEASUREMENT_PERIOD, interval)             'Set the polling intervals in steps of 10mS (not too tight!)
  bus.WriteByteA16(iChipAddr, SYSALS_START, $03)                                    'Start (toggle) continous      ' 


PUB WaitALS(iChipAddr, gain) | raw, ALSintPrd, status                               'Reading of ambient light during continuous, wait for result ready

  status:= 0
  REPEAT UNTIL status == $20
    status:= bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $38               'Check the result interrupt status, and extract the als status
  raw:= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL) << 8                             'Read raw value MSB
  raw|= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL + 1)                              'Read raw value LSB and put into same variable 
  ALSintPrd:= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD)  << 8           'Read als integration period, MSB
  ALSintPrd|= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD + 1)             'Read als integration period, LSB, and put into same variable   
  RESULT:= (320_000 / (ALSintPrd * ALSgain[gain & $F])) * raw                       'Calculate and return result as ambient light in mLux (as pre-calibrated)
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next


PUB GetALS(iChipAddr, gain) | raw, ALSintPrd                                        'Unsynchronized reading of als during continuous, i.e risk of skipped reading of new value

  raw:= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL) << 8                             'Read raw value MSB                                           
  raw|= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL + 1)                              'Read raw value LSB and put into same variable                
  ALSintPrd:= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD)  << 8           'Read als integration period, MSB                             
  ALSintPrd|= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD + 1)             'Read als integration period, LSB, and put into same variable 
  RETURN (320_000 / (ALSintPrd * ALSgain[gain & $F])) * raw                         'Calculate and return result as ambient light in mLux (as pre-calibrated)


PUB EndContALS(iChipAddr)

   bus.WriteByteA16(iChipAddr, SYSALS_START, $01)                                   'Start (toggle) continous
   

{ 'Interleaved light and range operation-----------------------------------------    *** CANNOT GET INTERLEAVED MODE WORKING ***
                                                                                     *******************************************
PUB BeginInterleaved(iChipAddr, interval)

   bus.WriteByteA16(iChipAddr, INTERLEAVED_MODE_ENABLE, $01)                        'Device mode select Interleaved mode
   bus.WriteByteA16(iChipAddr, SYSALS_INTERMEASUREMENT_PERIOD, interval)            'Set the polling intervals in steps of 10mS (not too tight!)
   bus.WriteByteA16(iChipAddr, SYSALS_START, $02)                                   'Start (toggle) continous


PUB WaitInterleaved(iChipAddr, gain) | raw, ALSintPrd, status, light, range         'Reads light when ready, then reads range when ready (interleaved)

  status:= 0
  REPEAT UNTIL status == $20
    status:= bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $20               'Check the result interrupt status, and extract the als status
  raw:= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL) << 8                             'Read raw value MSB
  raw|= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL + 1)                              'Read raw value LSB and put into same variable 
  ALSintPrd:= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD)  << 8           'Read als integration period, MSB
  ALSintPrd|= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD + 1)             'Read als integration period, LSB, and put into same variable   
  light:= (320_000 / (ALSintPrd * ALSgain[gain & $F])) * raw                        'Calculate and return result as ambient light in mLux (as pre-calibrated)
 
  status:= 0
  REPEAT UNTIL status == $04                                                        'Repeat until ranging status equals New Sample Ready (bit2=1)
    status := bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $04
  range:= bus.ReadByteA16(iChipAddr, RESULT_RANGE_VAL)                              'Check the result interrupt status, and extract the ranging status
  
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next
                                                                                   
  RETURN light<<16 + range & $FF                                                    'Package the two results into one LONG
  


PUB EndInterleaved(iChipAddr)

   bus.WriteByteA16(iChipAddr, SYSALS_START, $01)                                    'Start (toggle) continous
   bus.WriteByteA16(iChipAddr, INTERLEAVED_MODE_ENABLE, $00)                         'Device mode select NOT Interleaved mode

}   
   

 'SYSTEM STATUS LEVEL COMMANDS
 '===========================================================================
PUB RangeErrors(iChipAddr)

  RETURN bus.ReadByteA16(iChipAddr, RESULT_RANGE_STATUS)

   

PRI MandatoryLoad(iChipAddr)                                                        'Mandatory register loads, ref Application Notes
                                                        
  bus.WriteByteA16(iChipAddr,$0207, $01)                               '
  bus.WriteByteA16(iChipAddr,$0208, $01)
  bus.WriteByteA16(iChipAddr,$0096, $00)
  bus.WriteByteA16(iChipAddr,$0097, $fd)
  bus.WriteByteA16(iChipAddr,$00e3, $00)
  bus.WriteByteA16(iChipAddr,$00e4, $04)
  bus.WriteByteA16(iChipAddr,$00e5, $02)
  bus.WriteByteA16(iChipAddr,$00e6, $01)
  bus.WriteByteA16(iChipAddr,$00e7, $03)
  bus.WriteByteA16(iChipAddr,$00f5, $02)
  bus.WriteByteA16(iChipAddr,$00d9, $05)
  bus.WriteByteA16(iChipAddr,$00db, $ce)
  bus.WriteByteA16(iChipAddr,$00dc, $03)
  bus.WriteByteA16(iChipAddr,$00dd, $f8)
  bus.WriteByteA16(iChipAddr,$009f, $00)
  bus.WriteByteA16(iChipAddr,$00a3, $3c)
  bus.WriteByteA16(iChipAddr,$00b7, $00)
  bus.WriteByteA16(iChipAddr,$00bb, $3c)
  bus.WriteByteA16(iChipAddr,$00b2, $09)
  bus.WriteByteA16(iChipAddr,$00ca, $09)
  bus.WriteByteA16(iChipAddr,$0198, $01)
  bus.WriteByteA16(iChipAddr,$01b0, $17)
  bus.WriteByteA16(iChipAddr,$01ad, $00)
  bus.WriteByteA16(iChipAddr,$00ff, $05)
  bus.WriteByteA16(iChipAddr,$0100, $05)
  bus.WriteByteA16(iChipAddr,$0199, $05)
  bus.WriteByteA16(iChipAddr,$01a6, $1b)
  bus.WriteByteA16(iChipAddr,$01ac, $3e)
  bus.WriteByteA16(iChipAddr,$01a7, $1f)
  bus.WriteByteA16(iChipAddr,$0030, $00)

  
PRI RecommendedLoad(iChipAddr)                                                      'Recommended register loads
                                                                                                                                              
'Interrupts on Conversion Complete                                                                                                            
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CONFIG_GPIO, $24 )                   'Set GPIO1 high when sample complete                      
  bus.WriteByteA16(iChipAddr, SYSTEM_MODE_GPIO1, $10)                               'Set GPIO1 high when sample complete                      
  bus.WriteByteA16(iChipAddr, READOUT_AVERAGE_SAMPLE_PERIOD, $30)                   'Set Avg sample period                                    
  bus.WriteByteA16(iChipAddr, SYSALS_ANALOGUE_GAIN, $46)                            'Set the ALS gain                                         
  bus.WriteByteA16(iChipAddr, SYSRG_VHV_REPEAT_RATE, $FF)                           'Set auto calibration period (Max = 255)/(OFF = 0)        
  bus.WriteByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD, $63)                       'Set ALS integration time to 100ms                        
  bus.WriteByteA16(iChipAddr, SYSRG_VHV_RECALIBRATE, $01)                           'Perform a single temperature calibration                 
                                                                                                                                              
'Interval of continuos sampling, and sample ready signal                                                                                      
  bus.WriteByteA16(iChipAddr, SYSRG_INTERMEASUREMENT_PERIOD, $09)                   'Set default ranging inter-measurement period to 100ms    
  bus.WriteByteA16(iChipAddr, SYSALS_INTERMEASUREMENT_PERIOD, $0A)                  'Set default ALS inter-measurement period to 100ms        
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CONFIG_GPIO, $24)                    'Configures interrupt on New Sample Ready threshold event 
  
'Convergence, integration, gain, range, ans stuff
  bus.WriteByteA16(iChipAddr, SYSRG_MAX_CONVERGENCE_TIME, $32)
  bus.WriteByteA16(iChipAddr, SYSRG_RANGE_CHECK_ENABLES, $10 | $01) 
  bus.WriteByteA16(iChipAddr, SYSRG_EARLY_CONVERGENCE_EST + 1, $7B )
  bus.WriteByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD + 1, $64)                   'Limit to 255 milliseconds since only writing the LSB 
  bus.WriteByteA16(iChipAddr, READOUT_AVERAGE_SAMPLE_PERIOD, $30)
  bus.WriteByteA16(iChipAddr, SYSALS_ANALOGUE_GAIN, $40)                            'ALS gain= 20
  bus.WriteByteA16(iChipAddr, FIRMWARE_RESULT_SCALER, $01)
    
DAT
  
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