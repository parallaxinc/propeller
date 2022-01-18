{{

  Project: EE-7 Practical 1 - ToF
  Platform: Parallax Project USB Board
  Revision: 1.0
  Author: Kenichi
  Date: 10th Nov 2021
  Log:
    Date: Desc
    v1
    10/11/2021: Creating object file for Ultrasonic sensors & ToF sensors

  Revision: 1.1
  Author: Muhd Syamim
  Date: 14 Nov 2021
  Log:
    Date: Desc
    v1.1
    14/14/2021: Moved PINrs from VAR to DAT; minimize OBJ duplication
                Init method now always changes I2C bus; address collision, multiple bus required

  Adopted from  Erlend Fj.'s VL6180Driver, dated 2015.
  Drives the range finder microchip from ST Microelectronics over I2C bus communication.

}}
CON
 'VL6180X REGISTERS (not complete)
 '=======================================================
  ID_MODEL_ID                          = $00
  IDENTIFICATION_MODEL_ID              = $B4    ' VL6180X

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

  SLAVE_DEVICE_ADDRESS                 = $212           'For setting new chip address

  INTERLEAVED_MODE_ENABLE              = $2A3


VAR
  'LONG  PINrs

DAT
  PINrs   LONG

OBJ
  bus   :    "i2cDriver.spin"

PUB Init(PINscl, PINsda, _PINrs)
{{ Init I2C & reset toggle pins }}
  'if NOT bus.IsInitialized
    bus.Init(PINscl, PINsda)

  PINrs := _PINrs                                                                    'Sets default reset pin
  DIRA[PINrs]:= 1
  return PINrs


PUB FreshReset(iChipAddr) | testVal
{{ Reset prior to loading setting - based on Standard Ranging }}
  testVal := bus.ReadWordA16(iChipAddr, SYSTEM_FRESH_OUT_OF_RESET)
  return

PUB SetFreshReset(iChipAddr)
  bus.WriteByteA16(iChipAddr,SYSTEM_FRESH_OUT_OF_RESET, $00)
  return

PUB MandatoryLoad(iChipAddr)
{{ Mandatory register loads, ref Application Notes }}
  bus.WriteByteA16(iChipAddr,$0207, $01)
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
  return

PUB RecommendedLoad(iChipAddr)
{{ 'Recommended register loads }}
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
  return

PUB RecommendedLoad2(iChipAddr)
{{ Beta Testing Settings }}
  bus.WriteByteA16(iChipAddr, $0011, $10)   ' Enables polling for (New Sample ready) when measurement completes
  bus.WriteByteA16(iChipAddr, $010a, $30)   ' Set the averaging sample peroid
  bus.WriteByteA16(iChipAddr, $003f, $46)   ' Sets the light and dark gain (upper nibble)
  bus.WriteByteA16(iChipAddr, $0031, $FF)   ' Sets the # of range measurements after which auto calibration
  bus.WriteByteA16(iChipAddr, $0034, $63)   ' Sets ALS integration time 100 ms
  bus.WriteByteA16(iChipAddr, $002e, $01)   ' perform a single temperature calibration of the ranging sensor
  '' Optional
  bus.WriteByteA16(iChipAddr, $001b, $09)   ' Set default ranging inter-measurement peroid to 100 ms
  bus.WriteByteA16(iChipAddr, $003e, $31)   ' Set default ALS inter-measurement peroid to 500 ms
  bus.WriteByteA16(iChipAddr, $0014, $24)   ' Configures interrupt on (New Sample Ready threshold event)
  return

PUB ChipReset(EndState)
{{ 'Reset this chip and give it time to wake up }}
  OUTA[PINrs]:= 0
  WAITCNT((clkfreq/1000) + cnt)
  OUTA[PINrs]:= EndState
  return

PUB IsThere(iChipAddr)
{{ Verify that the particular chip is responding to it's address on the bus}}
  return bus.ReadByteA16(iChipAddr, ID_MODEL_ID)

PUB GetSingleRange(iChipAddr) | status
{{ Set and start single shot ranging }}
  status:= 0
  bus.WriteByteA16(iChipAddr, SYSRG_START, $01)

  repeat until status == $04                                                        'Repeat until ranging status equals New Sample Ready (bit2=1)
    status:= (bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $07)              'Check the result interrupt status, and extract the ranging status

  result:= bus.ReadByteA16(iChipAddr, RESULT_RANGE_VAL)                             'Return value
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next
  return result


PUB GetSingleLight(iChipAddr, gain) | raw, ALSintPrd, status
{{ Single Shot ALS }}
  status:= 0
  bus.WriteByteA16(iChipAddr, SYSALS_ANALOGUE_GAIN, gain)                           'Load parameter gain
  bus.WriteByteA16(iChipAddr, SYSALS_START, $01)                                    'Set and start single shot als

  repeat until status == $20                                                        'Repeat until ranging status equals New Sample Ready (bit5=1)
    status := bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $38              'Check the result interrupt status, and extract the ranging status
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next

  raw:= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL) << 8                             'Read raw value MSB
  raw|= bus.ReadByteA16(iChipAddr, RESULT_ALS_VAL + 1)                              'Read raw value LSB and put into same variable
  ALSintPrd:= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD)  << 8           'Read als integration period, MSB
  ALSintPrd|= bus.ReadByteA16(iChipAddr, SYSALS_INTEGRATION_PERIOD + 1)             'Read als integration period, LSB, and put into same variable

  result := (320_000 / (ALSintPrd * ALSgain[gain & $F])) * raw                       'Calculate and return result as ambient light in mLux (as pre-calibrated)
  return result

PUB BeginContRG(iChipAddr, interval)
{{ Continous ranging }}
  bus.WriteByteA16(iChipAddr, SYSRG_INTERMEASUREMENT_PERIOD, interval)              'Set the polling intervals in steps of 10mS (not too tight!)
  bus.WriteByteA16(iChipAddr, SYSRG_START, $03)                                     'Start (toggle) continous mode operation      '
  return

PUB WaitRange(iChipAddr) | Status
{{ Reading of range during contiuous, wait for result ready }}

  status:= 0
  repeat until status == $04                                                        'Repeat until ranging status equals New Sample Ready (bit2=1)
    status := bus.ReadByteA16(iChipAddr, RESULT_INT_STATUS_GPIO) & $04
  result := bus.ReadByteA16(iChipAddr, RESULT_RANGE_VAL)                             'Check the result interrupt status, and extract the ranging status
  bus.WriteByteA16(iChipAddr, SYSTEM_INTERRUPT_CLEAR, $07)                          'Clear the 3 interrupt flags, make ready for next
  return result

PUB GetRange(iChipAddr)
  result := bus.ReadByteA16(iChipAddr, RESULT_RANGE_VAL)
  return result

PUB RangeErrors(iChipAddr)
  return bus.ReadByteA16(iChipAddr, RESULT_RANGE_STATUS)


DAT
          ALSgain LONG 200, 103, 52, 26, 17, 13, 10, 400                           'Actual gainx10 lookup table