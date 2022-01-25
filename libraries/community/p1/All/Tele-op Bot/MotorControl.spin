{
  Project: EE-6 Practical 1
  Platform: Parallax Project USB Board
  Revision: 1.3
  Author: Muhammad Syamim
  Date: 14th Nov 2021
  Log:
    Date: Desc
    05/11/21:   Added RoboClaw and Serial OBJ
                Motor control success
    v1.1
    07/11/21:   Added new cog initialisation
                Added track selection
    v1.2
    14/11/21:   Added stop flag pointer

    v1.3
    16/11/21:   Added Post-Clear operator for MotorCogID
                Offloaded Directional control to cog 0
                Synced Milliseconds within OBJs
    v1.4
    26/11/21:   Offloaded Speed to cog 0
}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        M1 = 10, M2 = 11, M3 = 12, M4 = 13                                      'Motor Pins

        M1_zero = 1520                                                          'RoboClaw initial pulse width for zero velocity
        M2_zero = 1520                                                          '1120 = Full Reverse
        M3_zero = 1520                                                          '1520 = Full Stop
        M4_zero = 1520                                                          '1920 = Full Forward

        'Macros
        'SPD = 20                                                                'Speed setting from 0% to 100%
        DST = 1000                                                              'Distance in milliseconds
        ANG = 1000                                                              'Angle in milliseconds

VAR
  long MotorCogID, MotorCogStack[64]
  long _Ms_001

OBJ
  MDriver       : "Servo8Fast_vZ2.spin"                                         '1120 Full reverse, 1520 stop, 1920 Full Forward

PUB Start(StopFlagPtr, DirFlagPtr, FSpdPtr, RSpdPtr, RDYPtr) | i                'Track Selection
  MDriver.Init                                                                  'Initialise RoboClaw encoder pins
  MDriver.AddSlowPin(M1)
  MDriver.AddSlowPin(M2)
  MDriver.AddSlowPin(M3)
  MDriver.AddSlowPin(M4)
  MDriver.Start
  Pause(1000)                                                                   'Delay for RoboClaw calibration procedure
  StopAllMotors                                                                 'Calibrate RoboClaw to new zero point value
  Pause(1000)
  BYTE[RDYPtr]++                                                                'Update Ready BYTE
  repeat until BYTE[StopFlagPtr]                                                'Check for EStop
    case BYTE[DirFlagPtr]                                                       'Check with cog 0 for directions
      0:
        StopAllMotors
      2:
        if NOT BYTE[StopFlagPtr + 1]                                            'Check for obstacle in front
          Forward(BYTE[FSpdPtr])
        else
          StopAllMotors
      1:
        if NOT BYTE[StopFlagPtr + 2]                                            'Check for obstacle in rear
          Reverse(BYTE[RSpdPtr])
        else
          StopAllMotors
      3:
        TurnRight((BYTE[FSpdPtr] + BYTE[RSpdPtr]) / 2)
      4:
        TurnLeft((BYTE[FSpdPtr] + BYTE[RSpdPtr]) / 2)

PUB Init(StopFlagPtr, DirFlagPtr, FSpdPtr, RSpdPtr, RDYPtr, MsVal)                                      'Initialise Core for motor control
  _Ms_001 := MsVal                                                                                      'Sync time delays
  StopCore                                                                                              'Prevent stacking drivers
  MotorCogID := cognew(Start(StopFlagPtr, DirFlagPtr, FSpdPtr, RSpdPtr, RDYPtr), @MotorCogStack)        'Start new cog with Start method
  return MotorCogID                                                                                     'Return cogID for tracking

PUB StopCore                                                                    'Stop active cog
  if MotorCogID                                                                 'Check for active cog
    cogstop(MotorCogID~)                                                        'Stop the cog and zero out ID
  return MotorCogID

PUB Set(motor, speed)                                                           'Set the speed of selected motor

 speed *= 4                                                                     'Convert speed into value within range

 case motor                                                                     'Select motor & set the speed with respect to zero point
    1:
      MDriver.Set(M1, M1_zero + speed)
    2:
      MDriver.Set(M2, M2_zero + speed)
    3:
      MDriver.Set(M3, M3_zero + speed)
    4:
      MDriver.Set(M4, M4_zero + speed)

 return

PUB StopAllMotors | i                                                           'Set all motors to zero point

  repeat i from 1 to 4                                                          'Cycle through all the motors
    Set(i,0)                                                                    'Set the motor to zero point in %

  return

PUB Forward(speed) | i                                                          'Set motors to forward direction

  repeat i from 0 to 4                                                          'Cycle through all the motors
    Set(i, speed)                                                               'Set the motor to the speed

  return

PUB Reverse(speed) | i                                                          'Set motors to reverse direction

  repeat i from 1 to 4                                                          'Cycle through all the motors
    Set(i, -speed)                                                              'Set the motor to the speed

  return

PUB TurnRight(speed)                                                            'Set motors to turn right

  Set(1, -speed)                                                                'Pivot point on centre of machine
  Set(2, speed)
  Set(3, -speed)
  Set(4, speed)

  return

PUB TurnLeft(speed)                                                             'Set motors to turn left

  Set(1, speed)                                                                 'Pivot point on centre of machine
  Set(2, -speed)
  Set(3, speed)
  Set(4, -speed)

  return

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)

  return